# Plan: Add Notes List Page to Starter-Flask

## Overview

Add a simple page (`/notes`) to display all saved notes from the database, following the same patterns as existing pages.

## Current State

- **Routes**: `/`, `/form`, `/health`
- **Navigation**: Home, Form, Health
- **Database**: Azure SQL with Note model (id, content, created_at)
- **Deployed at**: https://starter-flask-app.wittydesert-1c125910.swedencentral.azurecontainerapps.io

## Target State

- **New route**: `/notes` - displays list of all saved notes
- **Updated navigation**: Home, Form, Notes, Health
- **Graceful degradation**: Shows error message if database not configured

---

## Files to Modify

| File | Change |
|------|--------|
| `application/routes.py` | Add `/notes` route |
| `application/templates/base.html` | Add "Notes" to nav |
| `application/templates/notes.html` | CREATE - notes list template |
| `application/tests/test_routes.py` | Add tests for `/notes` |

---

## Implementation Details

### 1. Add Route (`routes.py`)

Add after the `/form` route:

```python
@bp.route('/notes')
def notes():
    """
    Display all saved notes.

    Shows list of notes if database is connected,
    otherwise shows error message.
    """
    try:
        from models import db, Note

        if current_app.config.get('SQLALCHEMY_DATABASE_URI') is None:
            flash('Database not configured.', 'error')
            return render_template('notes.html', notes=[])

        all_notes = Note.query.order_by(Note.created_at.desc()).all()
        return render_template('notes.html', notes=all_notes)

    except Exception as e:
        logger.error(f"Database error: {e}")
        flash(f"Failed to load notes: {str(e)}", 'error')
        return render_template('notes.html', notes=[])
```

### 2. Update Navigation (`base.html`)

Change nav section from:
```html
<nav>
    <a href="{{ url_for('main.home') }}">Home</a>
    <a href="{{ url_for('main.form') }}">Form</a>
    <a href="{{ url_for('main.health') }}">Health</a>
</nav>
```

To:
```html
<nav>
    <a href="{{ url_for('main.home') }}">Home</a>
    <a href="{{ url_for('main.form') }}">Form</a>
    <a href="{{ url_for('main.notes') }}">Notes</a>
    <a href="{{ url_for('main.health') }}">Health</a>
</nav>
```

### 3. Create Template (`notes.html`)

```html
{% extends "base.html" %}

{% block title %}Saved Notes - Starter Flask{% endblock %}

{% block content %}
<h1>Saved Notes</h1>

{% if notes %}
    <p>{{ notes|length }} note(s) saved.</p>

    {% for note in notes %}
    <div style="background: #f0f0f0; padding: 1rem; border-radius: 4px; margin: 1rem 0;">
        <p><strong>#{{ note.id }}</strong> - {{ note.created_at.strftime('%Y-%m-%d %H:%M') if note.created_at else 'N/A' }}</p>
        <p>{{ note.content }}</p>
    </div>
    {% endfor %}
{% else %}
    <p>No notes saved yet.</p>
{% endif %}

<p><a href="{{ url_for('main.form') }}" class="button">Add a Note</a></p>
{% endblock %}
```

### 4. Add Tests (`test_routes.py`)

Add new test class:

```python
class TestNotesRoute:
    """Tests for GET /notes."""

    def test_notes_returns_200(self, client):
        """Notes page should return 200."""
        response = client.get('/notes')
        assert response.status_code == 200

    def test_notes_contains_title(self, client):
        """Notes page should contain title."""
        response = client.get('/notes')
        assert b'Saved Notes' in response.data

    def test_notes_shows_empty_message(self, client):
        """Notes page should show empty message when no notes."""
        response = client.get('/notes')
        assert b'No notes saved' in response.data

    def test_notes_shows_saved_notes(self, client, app):
        """Notes page should display saved notes."""
        from models import db, Note
        with app.app_context():
            note = Note(content='Test note for list')
            db.session.add(note)
            db.session.commit()

        response = client.get('/notes')
        assert b'Test note for list' in response.data
```

---

## Deployment Steps

1. Make code changes (routes.py, base.html, notes.html, test_routes.py)
2. Run tests locally: `pytest tests/ -v`
3. Deploy using existing script: `./deploy/deploy.sh`
4. Verify deployment

---

## Verification

### Local Testing
```bash
cd application
source .venv/bin/activate
pytest tests/ -v
```

### Post-Deployment Testing
```bash
# Test notes page
curl -s "https://starter-flask-app.wittydesert-1c125910.swedencentral.azurecontainerapps.io/notes" | grep -o "Saved Notes"

# Verify existing notes are displayed
curl -s "https://starter-flask-app.wittydesert-1c125910.swedencentral.azurecontainerapps.io/notes" | grep -E "(#1|#2)"
```

---

## Execution Order

1. Add `/notes` route to `routes.py`
2. Create `notes.html` template
3. Update nav in `base.html`
4. Add tests to `test_routes.py`
5. Run pytest locally
6. Deploy with `./deploy/deploy.sh`
7. Verify endpoints work
8. Commit changes
