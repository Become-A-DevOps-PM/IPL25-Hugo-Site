# Auth Blueprint with Login/Logout Routes

## Goal

Create the auth blueprint with login page, login handler, logout route, and login template.

> **What you'll learn:**
>
> - Creating authentication routes with Flask blueprints
> - Using Flask-Login's login_user() and logout_user()
> - Implementing "next" parameter redirect after login
> - Creating a login form template with error display

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 4.4 (Login Form)
> - ✓ All 95 tests passing
> - ✓ Understanding of Flask blueprints (from earlier phases)

## Exercise Steps

### Overview

1. **Create Auth Blueprint**
2. **Register Blueprint**
3. **Create Login Template**
4. **Add Login Page CSS**
5. **Add Auth Route Tests**
6. **Verify with pytest**

### **Step 1:** Create Auth Blueprint

Create routes for login and logout with proper redirect handling.

1. **Create** `application/app/routes/auth.py`:

   ```python
   """Auth blueprint for login and logout functionality."""
   from flask import Blueprint, render_template, redirect, url_for, flash, request
   from flask_login import login_user, logout_user, login_required, current_user
   from app.forms.login import LoginForm
   from app.services.auth_service import AuthService

   auth_bp = Blueprint('auth', __name__, url_prefix='/auth')


   @auth_bp.route('/login', methods=['GET', 'POST'])
   def login():
       """Display and handle the login form.

       GET: Display login form.
       POST: Validate credentials and log in user.

       Redirects authenticated users to admin page.
       """
       # Redirect if already logged in
       if current_user.is_authenticated:
           return redirect(url_for('admin.attendees'))

       form = LoginForm()

       if form.validate_on_submit():
           user = AuthService.authenticate(
               username=form.username.data,
               password=form.password.data
           )

           if user:
               login_user(user, remember=form.remember_me.data)
               flash('Login successful!', 'success')

               # Redirect to next page or admin
               next_page = request.args.get('next')
               if next_page and next_page.startswith('/'):
                   return redirect(next_page)
               return redirect(url_for('admin.attendees'))

           flash('Invalid username or password.', 'error')

       return render_template('auth/login.html', form=form)


   @auth_bp.route('/logout')
   @login_required
   def logout():
       """Log out the current user.

       Clears the session and redirects to home page.
       """
       logout_user()
       flash('You have been logged out.', 'info')
       return redirect(url_for('main.index'))
   ```

> ℹ **Concept Deep Dive**
>
> - **current_user.is_authenticated** checks if user is already logged in
> - **form.validate_on_submit()** checks both POST method and form validation
> - **login_user(user, remember=)** creates the session and optionally persists it
> - **request.args.get('next')** retrieves the page user was trying to access
> - **next_page.startswith('/')** prevents open redirect attacks (no external URLs)
> - **@login_required** on logout ensures only logged-in users can log out
>
> ⚠ **Common Mistakes**
>
> - Not checking if user is already authenticated (causes redirect loops)
> - Not validating the next parameter (security vulnerability)
> - Forgetting to flash messages for user feedback
> - Not using @login_required on logout
>
> ✓ **Quick check:** Login route handles GET/POST, logout requires authentication

### **Step 2:** Register Blueprint

1. **Open** `application/app/routes/__init__.py`

2. **Update** to include auth blueprint:

   ```python
   """Blueprint registration for the application.

   All blueprints are registered here to keep the application factory clean.
   """

   from app.routes.main import main_bp
   from app.routes.api import api_bp
   from app.routes.demo import demo_bp
   from app.routes.admin import admin_bp
   from app.routes.auth import auth_bp


   def register_blueprints(app):
       """Register all blueprints with the Flask application.

       Args:
           app: The Flask application instance.
       """
       app.register_blueprint(main_bp)
       app.register_blueprint(api_bp)
       app.register_blueprint(demo_bp)
       app.register_blueprint(admin_bp)
       app.register_blueprint(auth_bp)
   ```

> ✓ **Quick check:** auth_bp registered with the application

### **Step 3:** Create Login Template

1. **Create** directory `application/app/templates/auth/`

2. **Create** `application/app/templates/auth/login.html`:

   ```html
   {% extends "base.html" %}

   {% block title %}Admin Login{% endblock %}

   {% block content %}
   <div class="login-page">
       <h1>Admin Login</h1>
       <p>Enter your credentials to access the admin area.</p>

       <form method="POST" action="{{ url_for('auth.login') }}" class="login-form" novalidate>
           {{ form.hidden_tag() }}

           <div class="form-group {% if form.username.errors %}has-error{% endif %}">
               {{ form.username.label }}
               {{ form.username(placeholder='admin', class='form-control', autofocus=true) }}
               {% if form.username.errors %}
                   <ul class="errors">
                   {% for error in form.username.errors %}
                       <li class="error-message">{{ error }}</li>
                   {% endfor %}
                   </ul>
               {% endif %}
           </div>

           <div class="form-group {% if form.password.errors %}has-error{% endif %}">
               {{ form.password.label }}
               {{ form.password(placeholder='Enter password', class='form-control') }}
               {% if form.password.errors %}
                   <ul class="errors">
                   {% for error in form.password.errors %}
                       <li class="error-message">{{ error }}</li>
                   {% endfor %}
                   </ul>
               {% endif %}
           </div>

           <div class="form-group checkbox-group">
               {{ form.remember_me }}
               {{ form.remember_me.label }}
           </div>

           <div class="form-actions">
               {{ form.submit(class='btn btn-primary') }}
           </div>
       </form>

       <p class="back-link"><a href="{{ url_for('main.index') }}">Back to home</a></p>
   </div>
   {% endblock %}
   ```

> ℹ **Concept Deep Dive**
>
> - **form.hidden_tag()** includes CSRF token for security
> - **has-error** class enables error styling from Phase 3.3
> - **autofocus=true** on username improves UX
> - **novalidate** disables browser validation (use server-side)
> - **checkbox-group** keeps checkbox and label inline
>
> ✓ **Quick check:** Template has form fields, error display, and back link

### **Step 4:** Add Login Page CSS

1. **Open** `application/app/static/css/style.css`

2. **Add** the following CSS:

   ```css
   /* ===== Login Page ===== */
   .login-page {
       max-width: 400px;
       margin: 2rem auto;
   }

   .login-form {
       background: #fff;
       padding: 2rem;
       border-radius: 8px;
       box-shadow: 0 2px 8px rgba(0,0,0,0.1);
   }

   .checkbox-group {
       display: flex;
       align-items: center;
       gap: 0.5rem;
   }

   .checkbox-group input[type="checkbox"] {
       width: auto;
   }
   ```

> ✓ **Quick check:** CSS centers login form with checkbox styling

### **Step 5:** Add Auth Route Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test classes:

   ```python
   class TestLoginPage:
       """Tests for the login page."""

       def test_login_page_loads(self, client):
           """Test that login page loads successfully."""
           response = client.get('/auth/login')
           assert response.status_code == 200

       def test_login_page_has_form(self, client):
           """Test that login page contains a form."""
           response = client.get('/auth/login')
           assert b'<form' in response.data
           assert b'username' in response.data
           assert b'password' in response.data

       def test_login_success_redirects(self, app, client):
           """Test successful login redirects to admin."""
           with app.app_context():
               from app.services.auth_service import AuthService
               AuthService.create_user('logintest', 'testpassword123')

           response = client.post('/auth/login', data={
               'username': 'logintest',
               'password': 'testpassword123'
           }, follow_redirects=False)

           assert response.status_code == 302
           assert '/admin/attendees' in response.location

       def test_login_failure_shows_error(self, client):
           """Test failed login shows error message."""
           response = client.post('/auth/login', data={
               'username': 'nonexistent',
               'password': 'wrongpassword1'
           })

           assert response.status_code == 200
           assert b'Invalid username or password' in response.data

       def test_login_redirects_authenticated_user(self, app, client):
           """Test that authenticated users are redirected from login page."""
           with app.app_context():
               from app.services.auth_service import AuthService
               AuthService.create_user('alreadyloggedin', 'password12345')

           # Login first
           client.post('/auth/login', data={
               'username': 'alreadyloggedin',
               'password': 'password12345'
           })

           # Try to access login page again
           response = client.get('/auth/login', follow_redirects=False)
           assert response.status_code == 302


   class TestLogout:
       """Tests for logout functionality."""

       def test_logout_redirects_to_home(self, app, client):
           """Test that logout redirects to home page."""
           with app.app_context():
               from app.services.auth_service import AuthService
               AuthService.create_user('logouttest', 'password12345')

           # Login first
           client.post('/auth/login', data={
               'username': 'logouttest',
               'password': 'password12345'
           })

           # Logout
           response = client.get('/auth/logout', follow_redirects=False)
           assert response.status_code == 302

       def test_logout_shows_flash_message(self, app, client):
           """Test that logout shows confirmation message."""
           with app.app_context():
               from app.services.auth_service import AuthService
               AuthService.create_user('flashlogout', 'password12345')

           client.post('/auth/login', data={
               'username': 'flashlogout',
               'password': 'password12345'
           })

           response = client.get('/auth/logout', follow_redirects=True)
           assert b'logged out' in response.data
   ```

> ✓ **Quick check:** 7 new tests for login and logout functionality

### **Step 6:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 95 + 7 = 102 tests passing

> ✓ **Success indicators:**
>
> - All 102 tests pass
> - Login page loads and handles authentication
> - Logout clears session and shows message

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `routes/auth.py` exists with auth_bp blueprint
> - ☐ Login route handles GET and POST methods
> - ☐ Login validates next parameter for security
> - ☐ Logout uses @login_required decorator
> - ☐ `routes/__init__.py` registers auth_bp
> - ☐ `templates/auth/login.html` exists with form
> - ☐ `style.css` has login page styling
> - ☐ `pytest tests/test_routes.py -v` passes (102 tests)

## Common Issues

> **If you encounter problems:**
>
> **Template not found:** Ensure directory is `templates/auth/` not `templates/authentication/`
>
> **Login redirect loop:** Check current_user.is_authenticated at start of login()
>
> **CSRF error on POST:** Ensure form.hidden_tag() is in template
>
> **Flash messages not showing:** Verify base.html has flash message display from Phase 3.3

## Summary

You've implemented the auth blueprint:

- ✓ Login route with form handling and redirect
- ✓ Logout route with session cleanup
- ✓ "Next" parameter handling for post-login redirect
- ✓ Security against open redirect attacks
- ✓ Login template with error display
- ✓ 7 new tests verify authentication flow

> **Key takeaway:** Authentication flows need careful attention to security. Validating the "next" parameter prevents open redirect attacks, and checking authentication status prevents redirect loops.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add password reset functionality
> - Implement two-factor authentication
> - Add login attempt logging

## Done!

Auth blueprint is complete. Next phase will protect admin routes with @login_required.
