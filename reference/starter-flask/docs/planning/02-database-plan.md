# Starter Flask with Azure SQL Database - Implementation Plan

## Overview

This plan extends the minimal starter-flask application to include Azure SQL Database (Basic tier, ~$5/month) with a simple form page. The key requirement is **graceful degradation**: the application must start without a database connection and only fail when attempting to submit the form.

## Current State

- **Location:** `reference/starter-flask/`
- **App:** 17 lines of code, two endpoints (`/`, `/health`)
- **Deploy:** `az containerapp up` with Oryx++ (no Dockerfile)
- **Database:** None

## Target State

- **New endpoint:** `/form` with simple text entry form
- **Database:** Azure SQL Database (Basic tier, 5 DTU)
- **Graceful degradation:** App starts without DB, form submission fails gracefully
- **Dockerfile:** Required for ODBC Driver 18 installation

## Architecture

```
                                    ┌─────────────────────┐
                                    │  Azure SQL Database │
                                    │  (Basic tier, 5DTU) │
                                    └──────────┬──────────┘
                                               │
Internet ──HTTPS──→ Azure Container Apps ──→ Flask App ──→ Form submission
                    (managed ingress)         Port 5000    (fails gracefully
                                                            if no database)
```

## Key Design Decisions

### 1. Dockerfile Required (vs Oryx++)

**Decision:** Use Dockerfile instead of Oryx++ auto-detection.

**Rationale:** Azure SQL requires ODBC Driver 18 for SQL Server. Oryx++ does not install system packages automatically, so we must use a Dockerfile to install the driver.

### 2. Graceful Degradation

**Decision:** App starts without DATABASE_URL, fails only on form submission.

**Implementation:**
- `get_database_url()` returns `None` if DATABASE_URL not set
- Database initialization is skipped when URL is `None`
- `/health` endpoint returns `{"status": "ok", "database": "not_configured"}`
- Form GET works without database
- Form POST catches exception and shows user-friendly error

### 3. SQLite for Development/Testing

**Decision:** Use in-memory SQLite for pytest, file-based SQLite for local development.

**Rationale:** Fast, isolated tests without network dependencies. Same pattern used in stage-ultimate reference implementation.

### 4. Connection String Storage

**Decision:** Save DATABASE_URL to `.database-url` file (gitignored) during provisioning.

**Rationale:** Simple approach for learning environment. Production would use Azure Key Vault.

---

## Files to Create/Modify

### Application Code

| File | Action | Purpose |
|------|--------|---------|
| `application/config.py` | CREATE | Configuration with lazy DB init |
| `application/models.py` | CREATE | Note model (SQLAlchemy) |
| `application/routes.py` | CREATE | Blueprint with `/`, `/form`, `/health` |
| `application/app.py` | MODIFY | Application factory pattern |
| `application/wsgi.py` | CREATE | Gunicorn entry point |
| `application/requirements.txt` | MODIFY | Add SQLAlchemy, pyodbc, pytest |
| `application/Dockerfile` | CREATE | ODBC Driver 18 installation |

### Templates

| File | Action | Purpose |
|------|--------|---------|
| `application/templates/base.html` | CREATE | Base layout with nav |
| `application/templates/home.html` | CREATE | Home page |
| `application/templates/form.html` | CREATE | Form with single text field |
| `application/templates/thank_you.html` | CREATE | Success page |

### Infrastructure

| File | Action | Purpose |
|------|--------|---------|
| `deploy/provision-sql.sh` | CREATE | Azure SQL Database provisioning |
| `deploy/deploy.sh` | MODIFY | Handle DATABASE_URL env var |
| `deploy/delete.sh` | MODIFY | Include SQL Database cleanup |

### Tests

| File | Action | Purpose |
|------|--------|---------|
| `application/tests/conftest.py` | CREATE | pytest fixtures (in-memory SQLite) |
| `application/tests/test_routes.py` | CREATE | Route tests |
| `application/tests/test_models.py` | CREATE | Model tests |
| `application/tests/test_graceful.py` | CREATE | Graceful degradation tests |

---

## Implementation Details

### config.py - Lazy Database Initialization

```python
class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-change-in-production')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    USE_SQLITE = os.environ.get('USE_SQLITE', 'false').lower() == 'true'

    @classmethod
    def get_database_url(cls):
        if cls.USE_SQLITE:
            return 'sqlite:///notes.db'
        url = os.environ.get('DATABASE_URL')
        return url  # Returns None if not set (graceful degradation)
```

### models.py - Simple Note Model

```python
class Note(db.Model):
    __tablename__ = 'notes'
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.String(500), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
```

### routes.py - Graceful Form Handler

```python
@bp.route('/form', methods=['GET', 'POST'])
def form():
    if request.method == 'POST':
        content = request.form.get('content', '').strip()
        try:
            if current_app.config.get('SQLALCHEMY_DATABASE_URI') is None:
                raise Exception("Database not configured. Set DATABASE_URL.")
            note = Note(content=content)
            db.session.add(note)
            db.session.commit()
            return render_template('thank_you.html', note=note)
        except Exception as e:
            flash(f"Failed to save: {str(e)}", 'error')
            return render_template('form.html', content=content)
    return render_template('form.html')
```

### app.py - Application Factory

```python
def create_app(config_name: str = None) -> Flask:
    config_class = config_by_name.get(config_name, config_by_name['default'])
    app = Flask(__name__)
    app.config.from_object(config_class)

    db_url = config_class.get_database_url()
    app.config['SQLALCHEMY_DATABASE_URI'] = db_url

    # Initialize database ONLY if configured
    if db_url:
        from models import db
        db.init_app(app)
        if 'sqlite' in db_url:
            with app.app_context():
                db.create_all()
    else:
        logger.warning("No database configured - form submissions will fail")

    from routes import bp
    app.register_blueprint(bp)
    return app
```

### Dockerfile - ODBC Driver 18

```dockerfile
FROM python:3.11-slim AS builder

# Install ODBC Driver 18 for SQL Server
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl -fsSL https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18

# ... rest of Dockerfile
```

### provision-sql.sh - Azure SQL Database

```bash
# Create SQL Server
az sql server create \
    --name "$SQL_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    --admin-user "$SQL_ADMIN_USER" \
    --admin-password "$SQL_PASSWORD"

# Create database (Basic tier, ~$5/month)
az sql db create \
    --name "$SQL_DATABASE" \
    --server "$SQL_SERVER" \
    --edition "Basic" \
    --capacity 5 \
    --max-size 2GB
```

---

## Azure SQL Connection String Format

```
mssql+pyodbc://{user}:{password}@{server}.database.windows.net/{database}?driver=ODBC+Driver+18+for+SQL+Server
```

---

## Environment Variables

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `DATABASE_URL` | No | Azure SQL connection string | `mssql+pyodbc://...` |
| `SECRET_KEY` | Recommended | Flask secret key | Random 64-char hex |
| `FLASK_ENV` | No | Environment mode | `production` |
| `USE_SQLITE` | No | Force SQLite mode | `true` |

---

## Verification Checklist

### Local Testing
- [ ] `pytest tests/ -v` passes all tests
- [ ] App starts with `USE_SQLITE=true`
- [ ] Form submission works with SQLite
- [ ] App starts without DATABASE_URL (graceful degradation)
- [ ] Docker build succeeds locally

### Azure Deployment
- [ ] SQL Database provisioned (Basic tier)
- [ ] Container App deployed with Dockerfile
- [ ] Home page (`/`) loads
- [ ] Health check (`/health`) returns `{"status": "ok"}`
- [ ] Form page (`/form`) loads
- [ ] Form submission saves to Azure SQL

### Graceful Degradation
- [ ] App starts without DATABASE_URL
- [ ] `/health` returns `database: not_configured`
- [ ] `/form` GET works without database
- [ ] `/form` POST shows error message (not crash)

---

## Cost Estimate

| Resource | SKU | Monthly Cost |
|----------|-----|--------------|
| Azure SQL Database | Basic (5 DTU) | ~$5 |
| Container Apps | Consumption | ~$5-10 |
| Container Registry | Basic | ~$5 |
| **Total** | | **~$15-20** |

---

## Execution Order

1. Create `config.py`, `models.py`, `routes.py`
2. Modify `app.py` to application factory pattern
3. Create `wsgi.py`
4. Update `requirements.txt`
5. Create `Dockerfile`
6. Create templates (`base.html`, `home.html`, `form.html`, `thank_you.html`)
7. Create test files (`conftest.py`, `test_routes.py`, `test_models.py`, `test_graceful.py`)
8. Run `pytest` locally
9. Create `provision-sql.sh`
10. Update `deploy.sh`
11. Run `provision-sql.sh` (creates Azure SQL Database)
12. Run `deploy.sh` (deploys to Container Apps)
13. Verify deployment
14. Generate `TEST-REPORT.md`

---

## Comparison with Original Approach

| Aspect | Original (No DB) | With Azure SQL |
|--------|------------------|----------------|
| Dockerfile | None (Oryx++) | Required (ODBC driver) |
| Dependencies | 2 (flask, gunicorn) | 6 (+sqlalchemy, pyodbc, pytest, pytest-cov) |
| Endpoints | 2 (`/`, `/health`) | 3 (+`/form`) |
| Templates | None | 4 (base, home, form, thank_you) |
| Tests | None | 4 test files |
| Monthly cost | ~$10-15 | ~$15-20 |
| Complexity | Minimal | Low |
