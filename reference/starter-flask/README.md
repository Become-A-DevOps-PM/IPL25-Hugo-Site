# Starter Flask - Azure Container Apps with SQL Database

A minimal Flask deployment to Azure Container Apps with optional Azure SQL Database support. Features **graceful degradation**: the app starts and serves pages even without a database connection.

## Prerequisites

- Azure CLI installed and logged in (`az login`)
- Active Azure subscription

## Quick Start

### Option 1: With Azure SQL Database

```bash
# 1. Provision SQL Database (~5 minutes)
./deploy/provision-sql.sh

# 2. Deploy application (~5-10 minutes)
./deploy/deploy.sh

# 3. Test
curl https://<your-app-url>/
curl https://<your-app-url>/notes

# 4. Cleanup
./deploy/delete.sh
```

### Option 2: Without Database (Graceful Degradation)

```bash
# Deploy without database
./deploy/deploy.sh

# App works, but note operations show error message
curl https://<your-app-url>/
```

## What Gets Created

| Resource | Purpose | Cost |
|----------|---------|------|
| Resource Group | Container for all resources | Free |
| Container Registry | Stores container images | ~$5/month |
| Container Apps Environment | Managed Kubernetes | Free |
| Log Analytics Workspace | Logging and monitoring | Free tier |
| Container App | Running Flask application | ~$5-10/month |
| Azure SQL Database | Data persistence (optional) | ~$5/month (free tier available) |

**Total estimated cost:** ~$15-20/month

## Directory Structure

```
starter-flask/
├── README.md               # This file
├── application/
│   ├── app.py              # Flask application factory
│   ├── config.py           # Configuration classes
│   ├── models.py           # SQLAlchemy Note model
│   ├── routes.py           # Route handlers
│   ├── wsgi.py             # Gunicorn entry point
│   ├── requirements.txt    # Python dependencies
│   ├── Dockerfile          # Container build with ODBC driver
│   ├── migrations/         # Flask-Migrate database migrations
│   ├── templates/          # Jinja2 templates
│   │   ├── base.html
│   │   ├── home.html
│   │   ├── form.html
│   │   └── notes.html
│   └── tests/              # pytest test suite
├── deploy/
│   ├── provision-sql.sh    # Create Azure SQL Database
│   ├── deploy.sh           # Deploy to Container Apps
│   └── delete.sh           # Remove all resources
└── docs/                   # Documentation
    ├── architecture.md     # Architecture and design patterns
    ├── future-improvements.md  # Enhancement ideas
    ├── disable-airplay-macos.md  # macOS port 5000 fix
    └── planning/           # Development history
        ├── 01-initial-plan.md  # Original minimal Flask plan
        ├── 02-database-plan.md # Database feature plan
        ├── 03-notes-list-plan.md   # Notes list feature plan
        ├── 04-migrations-design.md # Migrations design
        └── test-report.md  # Test results
```

## Application Endpoints

| Route | Method | Description |
|-------|--------|-------------|
| `/` | GET | Home page |
| `/notes` | GET | List all notes |
| `/notes/new` | GET | Show form |
| `/notes/new` | POST | Create note (redirects to `/notes`) |

## Key Design: Graceful Degradation

The application is designed to **start and serve pages without a database**:

1. **App starts** even if `DATABASE_URL` is not set
2. **Home page (`/`)** works without database
3. **Notes page (`/notes`)** displays without database (shows error message)
4. **Form submission** fails gracefully with error message (no crash)

This allows deploying and testing the app before provisioning the database.

## Running Tests

```bash
cd application

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=. --cov-report=term-missing
```

## Local Development

```bash
cd application

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Apply database migrations (uses SQLite by default)
flask db upgrade

# Start the application with hot reload
flask run --debug

# Access at http://localhost:5000
```

To stop: Press `Ctrl+C`

To deactivate the virtual environment:
```bash
deactivate
```

## Database Migrations

This project uses **Flask-Migrate** (Alembic) for database schema management.

### Common Commands

```bash
cd application
source .venv/bin/activate

# Apply pending migrations
flask db upgrade

# Create a new migration after model changes
flask db migrate -m "Add new field to Note"

# Rollback one migration
flask db downgrade

# Show current migration version
flask db current

# Show migration history
flask db history
```

### Container Deployment

After deploying with `deploy.sh`, run migrations manually:

```bash
# Open interactive shell in container
az containerapp exec --name starter-flask-app --resource-group rg-starter-flask

# Inside the container, run migrations
flask db upgrade
exit
```

This ensures migrations run once during deployment, not on every container startup.

## Troubleshooting

### View Logs

```bash
az containerapp logs show \
    --name "starter-flask-app" \
    --resource-group "rg-starter-flask" \
    --follow
```

### Check Status

```bash
az containerapp show \
    --name "starter-flask-app" \
    --resource-group "rg-starter-flask" \
    --query "{name:name, url:properties.configuration.ingress.fqdn, status:properties.runningStatus}"
```

### Redeploy After Changes

```bash
./deploy/deploy.sh
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `FLASK_ENV` | No | `local` (default), `azure`, or `pytest` |
| `DATABASE_URL` | Azure only | Azure SQL connection string |
| `SECRET_KEY` | Recommended | Flask session encryption key |
| `USE_SQLITE` | No | Set to `true` to force SQLite in azure config |

## Azure SQL Connection String Format

```
mssql+pyodbc://{user}:{password}@{server}.database.windows.net/{database}?driver=ODBC+Driver+18+for+SQL+Server
```

## Why Dockerfile?

Azure SQL requires **ODBC Driver 18**, which the default container builder (Oryx++) doesn't install automatically. The Dockerfile:

- Installs Microsoft ODBC Driver 18 for SQL Server
- Uses Gunicorn for production serving

## Learn More

- [docs/architecture.md](docs/architecture.md) - Architecture and design patterns
- [docs/future-improvements.md](docs/future-improvements.md) - Enhancement ideas
- [Azure Container Apps Documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Azure SQL Database Documentation](https://learn.microsoft.com/en-us/azure/azure-sql/)
