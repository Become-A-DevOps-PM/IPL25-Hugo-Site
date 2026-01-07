"""Main blueprint for web interface routes."""

import os
from flask import Blueprint, request, render_template, redirect, url_for
from app.services.entry_service import EntryService

main_bp = Blueprint('main', __name__)


@main_bp.route('/', methods=['GET', 'POST'])
def index():
    """Handle the main page with entry form and list.

    GET: Display the form and recent entries.
    POST: Create a new entry and redirect to avoid form resubmission.
    """
    if request.method == 'POST':
        value = request.form.get('value')
        if value:
            EntryService.create_entry(value)
        return redirect(url_for('main.index'))

    entries = EntryService.get_recent_entries(limit=10)
    count = EntryService.get_entry_count()
    db_type = 'PostgreSQL' if os.environ.get('DATABASE_URL') else 'SQLite (local)'

    return render_template('index.html', entries=entries, count=count, db_type=db_type)
