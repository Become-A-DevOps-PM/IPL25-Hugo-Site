"""Route handlers."""

from flask import Blueprint, render_template, request, flash, redirect, url_for, current_app
from models import db, Note

bp = Blueprint('main', __name__)


def db_configured():
    """Check if database is configured."""
    return current_app.config.get('SQLALCHEMY_DATABASE_URI') is not None


@bp.route('/')
def home():
    return render_template('home.html')


@bp.route('/notes')
def notes():
    if not db_configured():
        flash('Database not configured.', 'error')
        return render_template('notes.html', notes=[])

    try:
        all_notes = Note.query.order_by(Note.created_at.desc()).all()
        return render_template('notes.html', notes=all_notes)
    except Exception:
        flash('Failed to load notes. Please try again.', 'error')
        return render_template('notes.html', notes=[])


@bp.route('/notes/new', methods=['GET', 'POST'])
def notes_new():
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
            flash('Note saved!', 'success')
            return redirect(url_for('main.notes'))
        except Exception:
            flash('Failed to save note. Please try again.', 'error')
            return render_template('form.html', content=content)

    return render_template('form.html')
