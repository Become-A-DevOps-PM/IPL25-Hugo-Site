"""Main blueprint for the landing page and registration.

This blueprint serves the application landing page and registration
form for the webinar signup feature.
"""
from flask import Blueprint, render_template, redirect, url_for, flash
from app.forms.registration import RegistrationForm
from app.services.registration_service import RegistrationService, DuplicateEmailError

main_bp = Blueprint('main', __name__)


@main_bp.route('/')
def index():
    """Render the landing page."""
    return render_template('landing.html')


@main_bp.route('/register', methods=['GET', 'POST'])
def register():
    """Display and handle the registration form.

    GET: Display the registration form with CSRF protection.
    POST: Validate form data and create registration if valid.
    """
    form = RegistrationForm()

    if form.validate_on_submit():
        try:
            RegistrationService.create_registration(
                name=form.name.data,
                email=form.email.data,
                company=form.company.data,
                job_title=form.job_title.data
            )
            flash('Registration successful!', 'success')
            return redirect(url_for('main.thank_you'))
        except DuplicateEmailError:
            form.email.errors.append('This email is already registered.')

    return render_template('register.html', form=form)


@main_bp.route('/thank-you')
def thank_you():
    """Display registration confirmation."""
    return render_template('thank_you.html')


@main_bp.route('/webinar')
def webinar_info():
    """Display webinar information page.

    Shows event details including topic, date, time, agenda,
    and speaker information as required by FR-001.
    """
    return render_template('webinar_info.html')
