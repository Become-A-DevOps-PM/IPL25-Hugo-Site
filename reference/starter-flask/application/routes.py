"""Route handlers with graceful database degradation."""

import logging
from flask import Blueprint, render_template, request, flash, current_app
from models import db, Note

logger = logging.getLogger(__name__)
bp = Blueprint('main', __name__)


def db_configured():
    """Check if database is configured."""
    return current_app.config.get('SQLALCHEMY_DATABASE_URI') is not None


@bp.route('/')
def home():
    """Home page."""
    return render_template('home.html')


@bp.route('/form', methods=['GET', 'POST'])
def form():
    """Form page with database submission."""
    if request.method == 'POST':
        content = request.form.get('content', '').strip()

        if not content:
            flash('Please enter some text.', 'error')
            return render_template('form.html', content=content)

        if not db_configured():
            flash('Database not configured.', 'error')
            return render_template('form.html', content=content)

        try:
            note = Note(content=content)
            db.session.add(note)
            db.session.commit()
            logger.info(f"Note saved: {note.id}")
            return render_template('thank_you.html', note=note)
        except Exception as e:
            logger.error(f"Database error: {e}")
            flash(f"Failed to save: {e}", 'error')
            return render_template('form.html', content=content)

    return render_template('form.html')


@bp.route('/notes')
def notes():
    """Display all saved notes."""
    if not db_configured():
        flash('Database not configured.', 'error')
        return render_template('notes.html', notes=[])

    try:
        all_notes = Note.query.order_by(Note.created_at.desc()).all()
        return render_template('notes.html', notes=all_notes)
    except Exception as e:
        logger.error(f"Database error: {e}")
        flash(f"Failed to load notes: {e}", 'error')
        return render_template('notes.html', notes=[])


@bp.route('/health')
def health():
    """Health check endpoint."""
    if not db_configured():
        return {'status': 'ok', 'database': 'not_configured'}

    try:
        db.session.execute(db.text('SELECT 1'))
        return {'status': 'ok', 'database': 'connected'}
    except Exception as e:
        logger.warning(f"Database health check failed: {e}")
        return {'status': 'ok', 'database': 'disconnected', 'error': str(e)}
