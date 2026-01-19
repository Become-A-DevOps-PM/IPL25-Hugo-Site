# Starter Flask - Project Overview

A minimal Flask application demonstrating deployment to Azure Container Apps with optional Azure SQL Database. Designed for learning Flask, containerization, and Azure deployment patterns.

## Quick Start

```bash
# Local development (no Azure required)
cd application
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
flask db upgrade
flask run --debug
# Open http://localhost:5000
```

## Project Structure

```
starter-flask/
├── application/     # Flask application code
├── deploy/          # Azure deployment scripts
└── docs/            # Documentation and design history
```

Each directory contains its own `CLAUDE.md` with detailed information.

## Key Features

| Feature | Description |
|---------|-------------|
| **Graceful Degradation** | App starts without database; shows errors only when DB operations attempted |
| **Multi-Environment Config** | `local` (SQLite), `azure` (Azure SQL), `pytest` (in-memory) |
| **Flask-Migrate** | Database schema versioning with Alembic |
| **Container-Ready** | Dockerfile with ODBC Driver 18 for Azure SQL |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      User's Browser                              │
└───────────────────────────┬─────────────────────────────────────┘
                            │ HTTPS
┌───────────────────────────▼─────────────────────────────────────┐
│              Azure Container Apps (managed ingress)              │
└───────────────────────────┬─────────────────────────────────────┘
                            │ Port 5000
┌───────────────────────────▼─────────────────────────────────────┐
│                    Flask App (Gunicorn)                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   routes    │  │   models    │  │       templates         │  │
│  │  (routes.py)│  │ (models.py) │  │ (Jinja2 HTML rendering) │  │
│  └─────────────┘  └──────┬──────┘  └─────────────────────────┘  │
└──────────────────────────┼──────────────────────────────────────┘
                           │ SQLAlchemy
┌──────────────────────────▼──────────────────────────────────────┐
│                    Database Layer                                │
│  Local: SQLite (notes.db)  │  Azure: Azure SQL (Basic tier)     │
└─────────────────────────────────────────────────────────────────┘
```

## Endpoints

| Route | Method | Purpose |
|-------|--------|---------|
| `/` | GET | Home page |
| `/notes` | GET | List all saved notes |
| `/notes/new` | GET | Display note form |
| `/notes/new` | POST | Save new note |

## Configuration

Set via `FLASK_ENV` environment variable:

| Environment | Database | Use Case |
|-------------|----------|----------|
| `local` (default) | SQLite file | Development |
| `azure` | Azure SQL via `DATABASE_URL` | Production |
| `pytest` | In-memory SQLite | Automated tests |

## Deployment Options

### Option 1: With Database
```bash
./deploy/provision-sql.sh   # Create Azure SQL (~$5/month)
./deploy/deploy.sh          # Deploy to Container Apps
```

### Option 2: Without Database
```bash
./deploy/deploy.sh          # App runs, form shows graceful error
```

### Cleanup
```bash
./deploy/delete.sh          # Remove all Azure resources
```

## Development Workflow

```bash
# 1. Make code changes
# 2. Run tests
cd application && pytest tests/ -v

# 3. Test locally
flask run --debug

# 4. Deploy
./deploy/deploy.sh
```

## Cost Estimate

| Resource | Monthly Cost |
|----------|--------------|
| Container Apps | ~$5-10 |
| Container Registry | ~$5 |
| Azure SQL (optional) | ~$5 |
| **Total** | **~$15-20** |

## Design Philosophy

This is a **teaching application** demonstrating:
- Server-side rendering (Jinja2 templates, no JavaScript frameworks)
- Monolithic architecture (single deployable unit)
- Synchronous processing (no background jobs)
- Stateless design (cookie-based sessions)

For deeper architecture details, see `docs/architecture.md`.

## Related Files

| File | Purpose |
|------|---------|
| `README.md` | User-facing quick start guide |
| `docs/architecture.md` | Detailed design patterns and code review |
| `docs/future-improvements.md` | Enhancement ideas for extending the app |
