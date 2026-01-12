# Starter Flask Application

A minimal Flask app demonstrating database persistence with SQLAlchemy.

## Quick Start

```bash
# Start the app (creates venv, installs deps, runs migrations, starts server)
./run.sh
```

Open http://localhost:5000

## Manual Setup

```bash
# 1. Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run database migrations
flask db upgrade

# 4. Start with hot reload
flask run --debug
```

## Project Structure

```
application/
├── app.py          # Application factory
├── config.py       # Configuration classes
├── models.py       # Database models
├── routes.py       # Route handlers
├── templates/      # Jinja2 templates
├── migrations/     # Database migrations
├── tests/          # Test suite
├── notes.db        # SQLite database (local dev)
├── run.sh          # Development startup script
└── stop.sh         # Stop server script
```

## Routes

| Route | Method | Description |
|-------|--------|-------------|
| `/` | GET | Home page |
| `/notes` | GET | List all notes |
| `/notes/new` | GET | Show form |
| `/notes/new` | POST | Create note |

## Configuration

| FLASK_ENV | Config Class | Use Case | Database |
|-----------|--------------|----------|----------|
| `local` | `LocalConfig` | Your machine | SQLite |
| `azure` | `AzureConfig` | Azure deployment | Azure SQL Database |
| `pytest` | `PytestConfig` | Automated tests | In-memory SQLite |

Default is `LocalConfig` - no environment variables needed for local development.

**Graceful degradation:** The app starts even without a database configured. Pages that don't need the database work normally. Database operations fail with a clear error message, making it easier to understand which features require a database connection.

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `FLASK_ENV` | No | `local` | Configuration to use: `local`, `azure`, or `pytest` |
| `DATABASE_URL` | Azure only | None | Azure SQL Database connection string |
| `USE_SQLITE` | No | `false` | Set to `true` to force SQLite in production config |
| `SECRET_KEY` | Production | `dev-secret-...` | Flask session encryption key |

### Examples

**Local development** (no variables needed):
```bash
./run.sh
```

**Azure deployment**:
```bash
export FLASK_ENV=azure
export DATABASE_URL="mssql+pyodbc://user:pass@server.database.windows.net/dbname?driver=ODBC+Driver+18+for+SQL+Server"
export SECRET_KEY="your-secure-random-key"
```

**Force SQLite in any environment**:
```bash
export USE_SQLITE=true
flask run
```

## Testing

```bash
source .venv/bin/activate
pytest tests/ -v
```

## Stop Server

```bash
# If running in foreground: Ctrl+C

# If running in background:
./stop.sh
```

## Database

The SQLite database (`notes.db`) is stored in the application directory.

### Reset Migrations

To start fresh with a clean database and new migrations:

```bash
source .venv/bin/activate

# Delete migrations and database
rm -rf migrations/ notes.db

# Recreate migrations
flask db init
flask db migrate -m "Initial schema"
flask db upgrade
```

## Troubleshooting

### Port 5000 in use (macOS)

macOS Monterey and later uses port 5000 for AirPlay Receiver. To reclaim it:

1. Open **System Settings**
2. Go to **General** → **AirDrop & Handoff**
3. Turn off **AirPlay Receiver**

Alternatively, use a different port:
```bash
flask run --port 5001 --debug
```
