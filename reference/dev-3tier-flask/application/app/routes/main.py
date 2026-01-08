"""Main blueprint for the landing page and registration.

This blueprint serves the application landing page and registration
form for the webinar signup feature (Phase 2).
"""

from flask import Blueprint, render_template, request, redirect, url_for
from app.services.registration_service import RegistrationService

main_bp = Blueprint('main', __name__)


@main_bp.route('/')
def index():
    """Render the landing page."""
    return render_template('landing.html')


@main_bp.route('/register', methods=['GET', 'POST'])
def register():
    """Display and handle the registration form.

    GET: Display the registration form.
    POST: Process form submission and redirect to thank-you page.
    """
    if request.method == 'POST':
        RegistrationService.create_registration(
            name=request.form.get('name'),
            email=request.form.get('email'),
            company=request.form.get('company'),
            job_title=request.form.get('job_title')
        )
        return redirect(url_for('main.thank_you'))
    return render_template('register.html')


@main_bp.route('/thank-you')
def thank_you():
    """Display registration confirmation.

    Note: This is a placeholder that will be fully implemented in Phase 2.6.
    """
    return '<h1>Thank you!</h1><p>Registration received.</p>'
