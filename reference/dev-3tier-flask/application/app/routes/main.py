"""Main blueprint for the landing page and registration.

This blueprint serves the application landing page and registration
form for the webinar signup feature (Phase 2).
"""

from flask import Blueprint, render_template

main_bp = Blueprint('main', __name__)


@main_bp.route('/')
def index():
    """Render the landing page."""
    return render_template('landing.html')


@main_bp.route('/register')
def register():
    """Display the registration form."""
    return render_template('register.html')
