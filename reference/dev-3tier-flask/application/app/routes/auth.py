"""Authentication blueprint for admin login/logout.

This blueprint handles admin authentication using Flask-Login
for session management.
"""
from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_user, logout_user, current_user
from app.forms.login import LoginForm
from app.services.auth_service import AuthService

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')


@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    """Display and handle the login form.

    GET: Display the login form.
    POST: Validate credentials and log in user if valid.

    If user is already authenticated, redirects to admin page.
    After successful login, redirects to 'next' parameter or admin page.
    """
    if current_user.is_authenticated:
        return redirect(url_for('admin.attendees'))

    form = LoginForm()

    if form.validate_on_submit():
        user = AuthService.authenticate(form.username.data, form.password.data)
        if user:
            login_user(user, remember=form.remember_me.data)
            flash('Login successful!', 'success')

            # Redirect to requested page or admin
            next_page = request.args.get('next')
            if next_page and next_page.startswith('/'):
                return redirect(next_page)
            return redirect(url_for('admin.attendees'))
        else:
            flash('Invalid username or password.', 'error')
    elif request.method == 'POST':
        # Form didn't validate - show generic error
        flash('Invalid username or password.', 'error')

    return render_template('auth/login.html', form=form)


@auth_bp.route('/logout')
def logout():
    """Log out the current user and redirect to home."""
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('main.index'))
