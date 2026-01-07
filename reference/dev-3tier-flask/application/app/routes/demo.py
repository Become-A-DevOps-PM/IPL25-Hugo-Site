"""Demo blueprint for testing database connectivity.

This blueprint contains the Phase 1 demo application that was originally
at the root route. It demonstrates basic CRUD operations with the database.
"""

import os
from flask import Blueprint, request, render_template, redirect, url_for
from app.services.entry_service import EntryService

demo_bp = Blueprint('demo', __name__, url_prefix='/demo')


@demo_bp.route('/', methods=['GET', 'POST'])
def index():
    """Handle the demo page with entry form and list.

    GET: Display the form and recent entries.
    POST: Create a new entry and redirect to avoid form resubmission.
    """
    if request.method == 'POST':
        value = request.form.get('value')
        if value:
            EntryService.create_entry(value)
        return redirect(url_for('demo.index'))

    entries = EntryService.get_recent_entries(limit=10)
    count = EntryService.get_entry_count()
    db_type = 'PostgreSQL' if os.environ.get('DATABASE_URL') else 'SQLite (local)'

    return render_template('demo.html', entries=entries, count=count, db_type=db_type)
