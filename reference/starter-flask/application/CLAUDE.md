# Application Directory

The Flask application source code. Total: ~200 lines across 5 Python files.

## Quick Reference

```bash
# Setup
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# Run locally
flask db upgrade
flask run --debug

# Run tests
pytest tests/ -v
```

## File Overview

| File | Lines | Purpose |
|------|------:|---------|
| `app.py` | 77 | Application factory, debug footer injection |
| `config.py` | 49 | Environment-specific configuration classes |
| `models.py` | 14 | SQLAlchemy `Note` model |
| `routes.py` | 56 | HTTP route handlers |
| `wsgi.py` | 9 | Gunicorn production entry point |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `migrations/` | Flask-Migrate (Alembic) database migrations |
| `templates/` | Jinja2 HTML templates |
| `tests/` | pytest test suite |

## Application Factory Pattern

The app uses Flask's application factory pattern in `app.py`:

```python
from app import create_app
app = create_app('local')  # or 'azure', 'pytest'
```

This enables:
- Different configurations per environment
- Testability (fresh app for each test)
- Avoiding circular imports

## Configuration Classes

Defined in `config.py`:

| Class | Database | Purpose |
|-------|----------|---------|
| `LocalConfig` | SQLite file (`notes.db`) | Development |
| `AzureConfig` | `DATABASE_URL` env var | Production |
| `PytestConfig` | In-memory SQLite | Testing |

Selection: `FLASK_ENV` environment variable (defaults to `local`).

## MVC Structure

```
Request → routes.py (Controller)
              ↓
          models.py (Model) ←→ Database
              ↓
          templates/ (View)
              ↓
         HTML Response
```

## Key Design: Graceful Degradation

The app starts without a database:

1. `config.get_database_url()` returns `None` if no `DATABASE_URL`
2. `app.py` skips `db.init_app()` when URL is `None`
3. Routes check `db_configured()` before database operations
4. Users see friendly error messages, not crashes

## Blueprint Structure

Routes are organized in a Blueprint (`routes.py`):

```python
bp = Blueprint('main', __name__)

@bp.route('/')
def home():
    return render_template('home.html')
```

Registered in `app.py` via `app.register_blueprint(bp)`.

## Debug Footer

Every page displays environment info (controlled in `app.py`):

```
Environment: local | Database: SQLite
Variable      | Env Value  | Actual Value
FLASK_ENV     | (not set)  | local
DATABASE_URL  | (not set)  | sqlite:///path/notes.db
```

This helps students understand configuration behavior.

## Container Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Container build with ODBC Driver 18 |
| `.dockerignore` | Excludes `.venv/`, `notes.db`, etc. |
| `requirements.txt` | Python dependencies |

## Entry Points

| Command | Entry Point | Use |
|---------|-------------|-----|
| `flask run` | `app.py` (auto-detected) | Development |
| `gunicorn wsgi:app` | `wsgi.py` | Production |
| `pytest` | `tests/` | Testing |
