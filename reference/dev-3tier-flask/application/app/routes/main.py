"""Main blueprint for the landing page.

This blueprint serves the application landing page, which will be
the starting point for Phase 2 development.
"""

from flask import Blueprint, render_template

main_bp = Blueprint('main', __name__)


@main_bp.route('/')
def index():
    """Render the landing page."""
    return render_template('landing.html')
