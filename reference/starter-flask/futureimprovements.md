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
