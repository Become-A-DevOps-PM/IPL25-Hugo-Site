# Database Migrations Design

This document describes the database migration strategy for the starter-flask application.

## Overview

The application uses **Flask-Migrate** (an Alembic wrapper) for database schema management instead of `db.create_all()`. This provides:

- Version-controlled schema changes
- Ability to alter existing tables without data loss
- Rollback capability
- Production-safe schema updates
- Consistent behavior across development, testing, and production

## Migration Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Container Startup                         │
├─────────────────────────────────────────────────────────────┤
│  entrypoint.sh                                               │
│  ┌─────────────────────┐   ┌─────────────────────────────┐  │
│  │ DATABASE_URL set?   │──▶│ flask db upgrade            │  │
│  │                     │   │ (runs pending migrations)   │  │
│  └─────────────────────┘   └─────────────────────────────┘  │
│           │                           │                      │
│           ▼                           ▼                      │
│  ┌─────────────────────┐   ┌─────────────────────────────┐  │
│  │ No database         │   │ gunicorn wsgi:app           │  │
│  │ (graceful degrade)  │   │ (start application)         │  │
│  └─────────────────────┘   └─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
application/
├── migrations/
│   ├── alembic.ini         # Alembic configuration
│   ├── env.py              # Migration environment setup
│   ├── script.py.mako      # Migration template
│   └── versions/
│       └── 001_initial_schema.py  # Initial migration
├── entrypoint.sh           # Container startup script
└── ...
```

## Development Workflow

### Creating a New Migration

After modifying `models.py`:

```bash
cd application

# Generate migration from model changes
flask db migrate -m "Add email field to Note"

# Review the generated migration
cat migrations/versions/*_add_email_field_to_note.py

# Apply the migration
flask db upgrade
```

### Common Commands

| Command | Description |
|---------|-------------|
| `flask db upgrade` | Apply all pending migrations |
| `flask db downgrade` | Rollback one migration |
| `flask db current` | Show current migration version |
| `flask db history` | Show migration history |
| `flask db migrate -m "desc"` | Generate new migration |

## Testing Strategy

Tests use `db.create_all()` instead of migrations for:

1. **Speed** - Direct table creation is faster than running migrations
2. **Isolation** - Each test gets a fresh database
3. **Simplicity** - No migration state to manage

Migration files are tested separately by:
- Running `flask db upgrade` on a fresh database
- Verifying the schema matches the models
- Testing rollback with `flask db downgrade`

## Production Deployment

Migrations run automatically on container startup via `entrypoint.sh`:

```bash
#!/bin/bash
set -e

if [ -n "$DATABASE_URL" ]; then
    echo "Running database migrations..."
    flask db upgrade || echo "Migration failed - continuing anyway"
fi

exec gunicorn --bind 0.0.0.0:5000 --workers 2 wsgi:app
```

This ensures:
- Migrations run before the app starts
- App starts even if migrations fail (graceful degradation)
- Production database stays in sync with code

## Graceful Degradation

The migration system preserves the app's graceful degradation behavior:

1. **No DATABASE_URL** - Skip migrations, app starts without database
2. **Migration fails** - Log warning, app starts anyway
3. **Database disconnected** - App handles errors at route level

## Initial Schema

The initial migration creates the `notes` table:

```python
def upgrade():
    op.create_table('notes',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('content', sa.String(500), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=True)
    )

def downgrade():
    op.drop_table('notes')
```

## Rationale

### Why Not db.create_all()?

| Aspect | db.create_all() | Flask-Migrate |
|--------|-----------------|---------------|
| Schema changes | Only creates, can't alter | Full DDL support |
| Version control | None | Migration files in git |
| Rollback | Not possible | `flask db downgrade` |
| Production use | Risky | Industry standard |
| Learning value | Limited | Real-world pattern |

### Why Flask-Migrate Over Raw Alembic?

- Simpler `flask db` CLI commands
- Automatic model detection
- Better Flask integration
- Less boilerplate

## References

- [Flask-Migrate Documentation](https://flask-migrate.readthedocs.io/)
- [Alembic Tutorial](https://alembic.sqlalchemy.org/en/latest/tutorial.html)
- [SQLAlchemy Migrations Best Practices](https://alembic.sqlalchemy.org/en/latest/cookbook.html)
