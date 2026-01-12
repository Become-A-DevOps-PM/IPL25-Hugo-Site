# Starter Flask Application

A minimal Flask app demonstrating database persistence with SQLAlchemy.

## Quick Start

```bash
# Start the app (creates venv, installs deps, runs migrations, starts server)
./run.sh
```

Open http://localhost:5005

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
flask run --port 5005 --debug
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

| Config | Use Case | Database |
|--------|----------|----------|
| `LocalConfig` | Your machine | SQLite |
| `AzureConfig` | Azure deployment | Azure SQL |
| `TestSuiteConfig` | pytest | In-memory SQLite |

Default is `LocalConfig` - no environment variables needed for local development.

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
