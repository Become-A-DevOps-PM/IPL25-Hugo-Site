# Flask Three-Tier Application

A well-structured Flask application demonstrating three-tier architecture with blueprints, service layer, and database migrations.

## Quick Start

### Prerequisites

- Python 3.11+
- pip

### Installation

```bash
# Create virtual environment
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate  # macOS/Linux
# .venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt
```

### Database Setup

**Option 1: Using migrations (recommended)**
```bash
export FLASK_APP=wsgi.py
flask db upgrade
```

**Option 2: Direct table creation**
```bash
export FLASK_APP=wsgi.py
flask db-init
```

### Run the Application

```bash
# Development server
python wsgi.py

# Or with Flask CLI
export FLASK_APP=wsgi.py
flask run --port 5001
```

The application will be available at: http://localhost:5001

### Run Tests

```bash
# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific test file
pytest tests/test_routes.py

# Run with coverage (requires pytest-cov)
pytest --cov=app
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Web interface - view and add entries |
| POST | `/` | Create new entry (form submission) |
| GET | `/api/entries` | List all entries as JSON |
| GET | `/api/health` | Health check endpoint |

## Project Structure

```
application/
├── config.py              # Configuration classes
├── wsgi.py                # Application entry point
├── requirements.txt       # Dependencies
│
├── app/
│   ├── __init__.py        # Application factory
│   ├── extensions.py      # Flask extensions
│   ├── models/            # Data layer
│   ├── services/          # Business logic layer
│   ├── routes/            # Presentation layer (blueprints)
│   ├── templates/         # Jinja2 templates
│   └── static/            # CSS, JavaScript
│
├── migrations/            # Database migrations
└── tests/                 # Test suite
```

## Configuration

The application supports three configurations:

| Config | Usage | Database |
|--------|-------|----------|
| `development` | Local development | SQLite (`local.db`) |
| `production` | Production deployment | PostgreSQL (via `DATABASE_URL`) |
| `testing` | Automated tests | In-memory SQLite |

Set configuration via environment variable:
```bash
export FLASK_ENV=production
```

## Database Migrations

```bash
# Create new migration after model changes
flask db migrate -m "Description of changes"

# Apply migrations
flask db upgrade

# Rollback last migration
flask db downgrade
```

## Production Deployment

```bash
# Using Gunicorn
gunicorn wsgi:app --bind 0.0.0.0:5001

# With environment variables
DATABASE_URL=postgresql://user:pass@host/db \
FLASK_ENV=production \
gunicorn wsgi:app
```
