# Flask Contact Form Application

A production-ready Flask application demonstrating database persistence with Azure Key Vault integration, PostgreSQL support, and transparent secret management.

## Features

- **Contact Form** - Validated contact form with server-side validation
- **Database Persistence** - Supports both SQLite (development) and PostgreSQL (production)
- **Azure Key Vault Integration** - Transparent secret loading with fallback chain
- **Test Mode Indicator** - Visual banner when running with SQLite
- **Health Check Endpoint** - Monitoring endpoint for production deployments
- **Responsive Design** - Mobile-friendly interface with modern styling

## Quick Start

### Prerequisites

- Python 3.11+
- pip and venv

### Local Development (SQLite)

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run application
python -m flask --app app run --host=0.0.0.0 --port=5001

# Or with Gunicorn
gunicorn --workers 2 --bind 0.0.0.0:5001 wsgi:application
```

Visit http://localhost:5001/

The application will:
- Use SQLite database (creates `instance/messages.db`)
- Display orange "TEST MODE" banner
- Show "Database: SQLite" in footer

### Local Development (PostgreSQL)

```bash
# Start PostgreSQL with Docker
docker run --name flask-postgres \
  -e POSTGRES_USER=flaskadmin \
  -e POSTGRES_PASSWORD=localdev \
  -e POSTGRES_DB=contactform \
  -p 5432:5432 \
  -d postgres:17

# Set database URL
export DATABASE_URL='postgresql://flaskadmin:localdev@localhost:5432/contactform'

# Run application
python -m flask --app app run --host=0.0.0.0 --port=5001
```

The application will:
- Connect to PostgreSQL
- No test mode banner
- Show "Database: PostgreSQL" in footer

## Project Structure

```
application/
├── app.py                    # Application factory
├── config.py                 # Configuration with Key Vault integration
├── models.py                 # SQLAlchemy models
├── routes.py                 # Route handlers (Blueprint)
├── validators.py             # Input validation
├── keyvault.py              # Key Vault SDK integration
├── wsgi.py                  # Gunicorn entry point
├── requirements.txt         # Production dependencies
├── requirements-dev.txt     # Development dependencies
├── .env.example             # Template for local development
│
├── templates/
│   ├── base.html            # Base template with database indicator
│   ├── home.html            # Home page
│   ├── contact.html         # Contact form
│   ├── thank_you.html       # Form submission confirmation
│   ├── messages.html        # Message list
│   └── error.html           # Error page
│
└── static/
    └── style.css            # Styles including test mode banner
```

## Configuration

### Environment Variables

```bash
# Flask Configuration
FLASK_ENV=development           # development, production, testing
SECRET_KEY=your-secret-key      # Secret key for sessions

# Database Configuration
DATABASE_URL=postgresql://...   # PostgreSQL connection string (optional)
USE_SQLITE=true                 # Force SQLite even with DATABASE_URL set

# Azure Key Vault (production)
AZURE_KEYVAULT_URL=https://your-vault.vault.azure.net/
```

### Secret Loading Priority

The application loads secrets in this order:

1. **Environment Variable** - Direct env var (e.g., `DATABASE_URL`)
2. **Azure Key Vault** - If `AZURE_KEYVAULT_URL` is set (requires managed identity)
3. **Default Value** - Falls back to SQLite

Example:
```python
from keyvault import get_secret

# Tries: DATABASE_URL env var → database-url in Key Vault → default
database_url = get_secret('database-url', 'sqlite:///messages.db')
```

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Home page |
| `/contact` | GET, POST | Contact form |
| `/messages` | GET | Display all messages |
| `/health` | GET | Health check (JSON) |

### Health Check Response

```json
{
  "status": "healthy",
  "database": "connected",
  "database_type": "sqlite"
}
```

Returns HTTP 200 if healthy, 503 if unhealthy.

## Validation Rules

| Field | Required | Max Length | Validation |
|-------|----------|------------|------------|
| Name | Yes | 100 chars | Not empty |
| Email | Yes | 120 chars | Valid email format |
| Message | Yes | 5000 chars | Not empty |

## Database Schema

### Messages Table

```sql
CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL,
    message TEXT NOT NULL,
    ip_address VARCHAR(45),
    user_agent VARCHAR(256),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);
```

## Production Deployment

### 1. Set Environment Variables

```bash
export FLASK_ENV=production
export SECRET_KEY=$(python -c 'import secrets; print(secrets.token_hex(32))')
export DATABASE_URL='postgresql://user:pass@host:5432/dbname'
export AZURE_KEYVAULT_URL='https://your-vault.vault.azure.net/'
```

### 2. Store Secrets in Key Vault

```bash
# Using Azure CLI
az keyvault secret set \
  --vault-name your-vault \
  --name database-url \
  --value 'postgresql://user:pass@host:5432/dbname'

az keyvault secret set \
  --vault-name your-vault \
  --name secret-key \
  --value 'your-secret-key'
```

### 3. Configure Managed Identity

The application uses `DefaultAzureCredential` which supports:
- Managed Identity (for Azure VMs/App Service)
- Azure CLI (for local development)
- Environment variables (fallback)

### 4. Run with Gunicorn

```bash
gunicorn --workers 4 \
  --bind 0.0.0.0:5001 \
  --access-logfile - \
  --error-logfile - \
  wsgi:application
```

### 5. Behind Nginx (Recommended)

```nginx
location / {
    proxy_pass http://127.0.0.1:5001;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

## Development

### Install Development Dependencies

```bash
pip install -r requirements-dev.txt
```

### Run Tests

```bash
pytest
```

### Code Formatting

```bash
black .
```

### Linting

```bash
flake8 .
```

## Test Mode Indicator

When using SQLite (test mode), the application displays:

1. **Orange Banner** - Sticky at top: "⚠️ TEST MODE - Using SQLite database. Configure DATABASE_URL for production."
2. **Footer Indicator** - Shows "Database: SQLite"
3. **Health Endpoint** - Returns `database_type: sqlite`

This ensures developers and operators know the application is not production-ready.

## Troubleshooting

### Database Connection Errors

```bash
# Check database connectivity
curl http://localhost:5001/health

# Check logs
tail -f flask.log
```

### Key Vault Authentication Issues

```bash
# Test Azure CLI authentication
az account show

# Test Key Vault access
az keyvault secret list --vault-name your-vault
```

### SQLite Permission Errors

The SQLite database is created in `instance/messages.db`. Ensure the application has write permissions to this directory.

## Security Considerations

1. **Secret Key** - Never commit `SECRET_KEY` to version control
2. **Database Credentials** - Store in Key Vault, not in code
3. **Input Validation** - Server-side validation enforced
4. **SQL Injection** - Prevented by SQLAlchemy ORM
5. **XSS Protection** - Jinja2 auto-escaping enabled

## License

This is a reference implementation for educational purposes.

## Support

For issues or questions, refer to:
- PLAN-APPLICATION.md - Application specification
- VERIFICATION.md - Test results and verification
