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
curl https://<your-app-url>/form
curl https://<your-app-url>/health

# 4. Cleanup
./deploy/delete.sh
```

### Option 2: Without Database (Graceful Degradation)

```bash
# Deploy without database
./deploy/deploy.sh

# App works, but form submissions show error message
curl https://<your-app-url>/health
# Returns: {"status": "ok", "database": "not_configured"}
```

## What Gets Created

| Resource | Purpose | Cost |
|----------|---------|------|
| Resource Group | Container for all resources | Free |
| Container Registry | Stores container images | ~$5/month |
| Container Apps Environment | Managed Kubernetes | Free |
| Log Analytics Workspace | Logging and monitoring | Free tier |
| Container App | Running Flask application | ~$5-10/month |
| Azure SQL Database | Data persistence (optional) | ~$5/month |

**Total estimated cost:** ~$15-20/month

## Directory Structure

```
starter-flask/
├── README.md               # This file
├── PLAN.md                 # Original minimal deployment design
├── PLAN-DATABASE.md        # Database extension design
├── TEST-REPORT.md          # Test results and verification
│
├── application/
│   ├── app.py              # Flask application factory
│   ├── config.py           # Configuration with lazy DB init
│   ├── models.py           # SQLAlchemy Note model
│   ├── routes.py           # Routes with graceful degradation
│   ├── wsgi.py             # Gunicorn entry point
│   ├── requirements.txt    # Python dependencies
│   ├── Dockerfile          # Container build with ODBC driver
│   ├── templates/          # Jinja2 templates
│   │   ├── base.html
│   │   ├── home.html
│   │   ├── form.html
│   │   └── thank_you.html
│   └── tests/              # pytest test suite
│       ├── conftest.py
│       ├── test_routes.py
│       ├── test_models.py
│       └── test_graceful.py
│
└── deploy/
    ├── provision-sql.sh    # Create Azure SQL Database
    ├── deploy.sh           # Deploy to Container Apps
    └── delete.sh           # Remove all resources
```

## Application Endpoints

| Route | Method | Response |
|-------|--------|----------|
| `/` | GET | Home page with link to form |
| `/form` | GET | Form with single text field |
| `/form` | POST | Saves note to database |
| `/health` | GET | `{"status": "ok", "database": "connected\|not_configured"}` |

## Key Design: Graceful Degradation

The application is designed to **start and serve pages without a database**:

1. **App starts** even if `DATABASE_URL` is not set
2. **Home page (`/`)** works without database
3. **Form page (`/form`)** displays without database
4. **Form submission** fails gracefully with error message (no crash)
5. **Health check** reports database status: `connected`, `disconnected`, or `not_configured`

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

**Test coverage:** 97% with 24 tests

## Local Development

```bash
cd application

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Run with SQLite (default for development)
export USE_SQLITE=true
python app.py

# Access at http://localhost:5000
```

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

### Check Database Connection

```bash
curl https://<your-app-url>/health | jq .
```

### Redeploy After Changes

```bash
./deploy/deploy.sh
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | No | Azure SQL connection string |
| `SECRET_KEY` | Recommended | Flask secret key |
| `FLASK_ENV` | No | `development` or `production` |
| `USE_SQLITE` | No | Set to `true` for SQLite mode |

## Azure SQL Connection String Format

```
mssql+pyodbc://{user}:{password}@{server}.database.windows.net/{database}?driver=ODBC+Driver+18+for+SQL+Server
```

## Why Dockerfile Instead of Oryx++?

The original minimal deployment used Oryx++ (no Dockerfile) for simplicity. However, Azure SQL requires **ODBC Driver 18**, which Oryx++ doesn't install automatically.

The Dockerfile:
- Installs Microsoft ODBC Driver 18 for SQL Server
- Uses multi-stage build for smaller image
- Runs as non-root user for security
- Includes health check configuration

## Learn More

- [PLAN-DATABASE.md](PLAN-DATABASE.md) - Detailed implementation design
- [TEST-REPORT.md](TEST-REPORT.md) - Test results and verification steps
- [Azure Container Apps Documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Azure SQL Database Documentation](https://learn.microsoft.com/en-us/azure/azure-sql/)
