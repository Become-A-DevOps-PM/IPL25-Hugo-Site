"""
Route handlers with graceful database degradation.

The application can start and serve pages even without a database connection.
Database errors only occur when actually attempting to save data.
"""

import logging
from flask import Blueprint, render_template, request, flash, current_app

logger = logging.getLogger(__name__)
bp = Blueprint('main', __name__)


@bp.route('/')
def home():
    """Home page - always works, no database required."""
    return render_template('home.html')


@bp.route('/form', methods=['GET', 'POST'])
def form():
    """
    Form page with database submission.

    GET: Shows form (always works, no database required)
    POST: Submits to database (fails gracefully if no database)
    """
    if request.method == 'POST':
        content = request.form.get('content', '').strip()

        if not content:
            flash('Please enter some text.', 'error')
            return render_template('form.html', content=content)

        # Try to save to database - fail here if no connection
        try:
            from models import db, Note

            # Check if database is configured
            if current_app.config.get('SQLALCHEMY_DATABASE_URI') is None:
                raise Exception("Database not configured. Set DATABASE_URL environment variable.")

            note = Note(content=content)
            db.session.add(note)
            db.session.commit()

            logger.info(f"Note saved: {note.id}")
            return render_template('thank_you.html', note=note)

        except Exception as e:
            logger.error(f"Database error: {e}")
            flash(f"Failed to save: {str(e)}", 'error')
            return render_template('form.html', content=content)

    return render_template('form.html')


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


@bp.route('/health')
def health():
    """
    Health check endpoint.

    Returns:
    - status: always "ok" (app is running)
    - database: "connected", "disconnected", or "not_configured"

    Note: Always returns HTTP 200 because the app itself is healthy.
    Database status is informational only.
    """
    result = {
        'status': 'ok',
        'database': 'unknown'
    }

    db_url = current_app.config.get('SQLALCHEMY_DATABASE_URI')

    if db_url is None:
        result['database'] = 'not_configured'
        return result, 200

    try:
        from models import db
        db.session.execute(db.text('SELECT 1'))
        result['database'] = 'connected'
        return result, 200
    except Exception as e:
        logger.warning(f"Database health check failed: {e}")
        result['database'] = 'disconnected'
        result['error'] = str(e)
        return result, 200  # Still 200 - app is running, just no database
