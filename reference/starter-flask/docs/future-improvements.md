# Future Improvements

Optional enhancements that can be added as the application grows.

## Logging

Add structured logging for debugging and monitoring.

In `app.py`:
```python
import logging

def create_app(config_name=None):
    # ... after app creation:
    logging.basicConfig(
        level=logging.DEBUG if app.config.get('DEBUG') else logging.INFO,
        format='%(asctime)s %(levelname)s %(name)s: %(message)s'
    )
    logger = logging.getLogger(__name__)

    if app.config['SQLALCHEMY_DATABASE_URI']:
        db_type = 'SQLite' if 'sqlite' in db_url else 'Azure SQL'
        logger.info(f"Database: {db_type}")
    else:
        logger.warning("No database configured")
```

In `routes.py`:
```python
import logging

logger = logging.getLogger(__name__)

@bp.route('/notes/new', methods=['GET', 'POST'])
def notes_new():
    # ... after successful save:
    logger.info(f"Note saved: {note.id}")

    # ... in except block:
    logger.error(f"Database error: {e}")
```

## Type Hints

Add type hints for better IDE support and documentation:

```python
def create_app(config_name: str = None) -> Flask:
    """Create and configure the Flask application."""
    ...
```

## Direct Execution

Add direct execution support for running without `flask run`:

```python
# At the end of app.py
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

Then run with: `python app.py`

## Health Check Endpoint

Add a health check for container orchestration and monitoring:

```python
@bp.route('/health')
def health():
    """Health check endpoint."""
    if not db_configured():
        return {'status': 'ok', 'database': 'not_configured'}

    try:
        db.session.execute(db.text('SELECT 1'))
        return {'status': 'ok', 'database': 'connected'}
    except Exception as e:
        return {'status': 'ok', 'database': 'disconnected', 'error': str(e)}
```

Update `templates/base.html` nav to include the link:
```html
<a href="{{ url_for('main.health') }}">Health</a>
```

## Model Enhancements

### Explicit Table Name

Override the auto-generated table name:

```python
class Note(db.Model):
    __tablename__ = 'notes'  # Without this, SQLAlchemy uses 'note'
    # ... columns ...
```

Useful when working with existing databases or naming conventions that require plural table names.

### Debug Representation

Add `__repr__` for easier debugging in the Python shell:

```python
class Note(db.Model):
    # ... existing columns ...

    def __repr__(self):
        return f'<Note {self.id}: {self.content[:20]}...>'
```

Usage:
```python
>>> note = Note.query.first()
>>> note
<Note 1: Hello world...>
```

### JSON Serialization

Add `to_dict` for API responses:

```python
class Note(db.Model):
    # ... existing columns ...

    def to_dict(self):
        """Serialize for JSON responses."""
        return {
            'id': self.id,
            'content': self.content,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
```

Usage:
```python
@bp.route('/api/notes')
def api_notes():
    notes = Note.query.all()
    return {'notes': [n.to_dict() for n in notes]}
```

## API Endpoints

Add REST API endpoints for programmatic access:

```python
@bp.route('/api/notes', methods=['GET'])
def api_list_notes():
    notes = Note.query.order_by(Note.created_at.desc()).all()
    return {'notes': [n.to_dict() for n in notes]}

@bp.route('/api/notes', methods=['POST'])
def api_create_note():
    data = request.get_json()
    note = Note(content=data.get('content', ''))
    db.session.add(note)
    db.session.commit()
    return note.to_dict(), 201
```

## Input Validation

Add Flask-WTF for form validation:

```python
from flask_wtf import FlaskForm
from wtforms import TextAreaField
from wtforms.validators import DataRequired, Length

class NoteForm(FlaskForm):
    content = TextAreaField('Content', validators=[
        DataRequired(message='Please enter some text.'),
        Length(max=500, message='Note must be under 500 characters.')
    ])
```

## Pagination

Add pagination for the notes list:

```python
@bp.route('/notes')
def notes():
    page = request.args.get('page', 1, type=int)
    pagination = Note.query.order_by(Note.created_at.desc()).paginate(
        page=page, per_page=10, error_out=False
    )
    return render_template('notes.html', notes=pagination.items, pagination=pagination)
```

## Non-Root Container User

Run the container as a non-root user for improved security. If the container is compromised, the attacker has limited privileges.

Update `Dockerfile`:

```dockerfile
# Flask with Azure SQL Database
FROM python:3.11-slim

# Install ODBC Driver 18 for SQL Server
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gnupg2 unixodbc \
    && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl -fsSL https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd --create-home appuser
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chown=appuser:appuser . .

USER appuser
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "120", "wsgi:app"]
```

Key changes:
- `RUN useradd --create-home appuser` - Creates a non-root user
- `COPY --chown=appuser:appuser . .` - Sets file ownership
- `USER appuser` - Switches to non-root user before running the app

## Package Structure

The current flat structure works well for small applications. As the app grows, consider migrating to a package-based structure.

### When to Migrate

Consider restructuring when any of these occur:
- Adding a second blueprint (e.g., `admin`, `api`, `auth`)
- Adding a third model (e.g., `User`, `Comment`)
- Any single file exceeds 300 lines
- Multiple developers working on routes simultaneously

### Current Structure (Flat)

```
application/
├── app.py              # create_app()
├── config.py           # Config classes
├── models.py           # All models
├── routes.py           # All routes
└── wsgi.py
```

### Package Structure

```
application/
├── app/
│   ├── __init__.py           # create_app() lives here
│   ├── config.py
│   ├── models/
│   │   ├── __init__.py       # from .note import Note; from .user import User
│   │   ├── note.py           # Note model
│   │   └── user.py           # User model (future)
│   ├── routes/
│   │   ├── __init__.py       # Registers all blueprints
│   │   ├── main.py           # Home, health routes
│   │   ├── notes.py          # /notes routes
│   │   └── api.py            # /api routes (future)
│   └── templates/
├── tests/
│   ├── conftest.py
│   ├── models/
│   │   └── test_note.py
│   └── routes/
│       ├── test_main.py
│       └── test_notes.py
└── wsgi.py
```

### Key Changes

**Imports change from:**
```python
from models import db, Note
from config import config_by_name
```

**To:**
```python
from app.models import db, Note
from app.config import config_by_name
```

**`app/__init__.py`:**
```python
from flask import Flask
from flask_migrate import Migrate

from app.config import config_by_name
from app.models import db

migrate = Migrate()

def create_app(config_name=None):
    config_class = config_by_name.get(config_name, config_by_name['default'])

    app = Flask(__name__)
    app.config.from_object(config_class)
    app.config['SQLALCHEMY_DATABASE_URI'] = config_class.get_database_url()

    if app.config['SQLALCHEMY_DATABASE_URI']:
        db.init_app(app)
        migrate.init_app(app, db)

    from app.routes import main_bp, notes_bp
    app.register_blueprint(main_bp)
    app.register_blueprint(notes_bp)

    return app
```

**`app/models/__init__.py`:**
```python
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

from app.models.note import Note  # noqa: E402
```

**`app/routes/__init__.py`:**
```python
from app.routes.main import bp as main_bp
from app.routes.notes import bp as notes_bp
```

### Benefits

| Aspect | Flat | Package |
|--------|------|---------|
| Adding new routes | Edit single file | Create new file |
| Finding code | Scan one file | Navigate to specific module |
| Merge conflicts | More likely | Less likely |
| Circular imports | Manual care needed | Easier to avoid |
| Test organization | Mirrors flat structure | Mirrors package structure |

### Why Not Now

The starter-flask app has ~200 lines across 5 files. Package structure would:
- Triple the file count
- Add `__init__.py` boilerplate
- Make the app harder to understand at a glance

Keep it flat until complexity demands otherwise.
