+++
title = "Flask-Login and Login Routes"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Add session-based authentication with Flask-Login, a login form, and login/logout routes"
weight = 4
+++

# Flask-Login and Login Routes

## Goal

Add session-based authentication to the application using Flask-Login, a login form with CSRF protection, and login/logout routes that manage user sessions.

> **What you'll learn:**
>
> - How Flask-Login manages user sessions with secure cookies
> - How to create a login form with WTForms and CSRF protection
> - How to build authentication routes with login and logout
> - How to update navigation based on authentication state
> - How the `user_loader` callback connects Flask-Login to your User model

## Prerequisites

> **Before starting, ensure you have:**
>
> - Completed the User Model exercise with `set_password()` and `check_password()` methods
> - Completed the Authentication Service exercise with `AuthService.authenticate()`, `create_user()`, and `get_user_by_id()`
> - Completed the Admin Blueprint exercise with `admin_bp` registered
> - Flask application running with database migrations applied
> - `app/business/services/auth_service.py` exists and is tested

## Exercise Steps

### Overview

1. **Install Dependencies and Configure Flask-Login**
2. **Create the Login Form**
3. **Create the Auth Blueprint**
4. **Create Login Template and Update Navigation**
5. **Test the Login Flow**

### **Step 1:** Install Dependencies and Configure Flask-Login

Flask-Login manages user sessions -- it tracks who is logged in across requests using secure cookies. When a user logs in, Flask-Login stores their user ID in a signed session cookie. On each subsequent request, it reads the cookie and loads the user from the database automatically.

1. **Open** `requirements.txt` and **add** the following packages:

   > `requirements.txt`

   ```text
   Flask-Login==0.6.3
   Flask-WTF==1.2.2
   WTForms==3.2.1
   ```

   Flask-WTF and WTForms may already be installed if the optional WTForms exercise was completed. Adding them again is harmless -- pip skips already-installed packages.

2. **Install** the new dependencies:

   ```bash
   pip install -r requirements.txt
   ```

3. **Open** `app/config.py` and **add** `SECRET_KEY` to the `Config` base class if not already present. Flask-Login requires a secret key to sign session cookies:

   > `app/config.py`

   ```python
   SECRET_KEY: str = os.environ.get("SECRET_KEY", "dev-secret-key")
   ```

   If you completed the WTForms exercise, `SECRET_KEY` is already in your `Config` class and no change is needed.

4. **Update** `app/__init__.py` to set up Flask-Login. This is the most important step -- Flask-Login must be initialized in the application factory and connected to the User model through the `user_loader` callback.

   Here is the **complete** `app/__init__.py` file showing where Flask-Login setup goes relative to existing code:

   > `app/__init__.py`

   ```python
   """
   Application factory for News Flash.

   Creates and configures the Flask application with all extensions,
   blueprints, and the Flask-Login user loader.
   """

   from flask import Flask
   from flask_sqlalchemy import SQLAlchemy
   from flask_migrate import Migrate
   from flask_login import LoginManager

   db = SQLAlchemy()
   migrate = Migrate()


   def create_app(config_class=None):
       """Create and configure the Flask application."""
       app = Flask(
           __name__,
           template_folder="presentation/templates",
           static_folder="presentation/static",
       )

       # Load configuration
       if config_class is None:
           from app.config import DevelopmentConfig
           config_class = DevelopmentConfig
       app.config.from_object(config_class)

       # Initialize extensions
       db.init_app(app)
       migrate.init_app(app, db)

       # Initialize Flask-Login
       login_manager = LoginManager()
       login_manager.login_view = "auth.login"
       login_manager.login_message_category = "info"
       login_manager.init_app(app)

       @login_manager.user_loader
       def load_user(user_id):
           """Load a user by ID for Flask-Login session management."""
           from app.business.services.auth_service import AuthService
           return AuthService.get_user_by_id(user_id)

       # Import models so Flask-Migrate can detect them
       from app.data.models.subscriber import Subscriber  # noqa: F401
       from app.data.models.user import User  # noqa: F401

       # Register blueprints
       from app.presentation.routes.public import bp as public_bp
       app.register_blueprint(public_bp)

       from app.presentation.routes.admin import admin_bp
       app.register_blueprint(admin_bp)

       from app.presentation.routes.auth import auth_bp
       app.register_blueprint(auth_bp)

       return app
   ```

5. **Add** `UserMixin` to the User model. This provides the default implementations that Flask-Login expects.

   **Open** `app/data/models/user.py` and **update** the imports and class definition:

   > `app/data/models/user.py`

   ```python
   """User model for admin authentication."""

   from flask_login import UserMixin
   from werkzeug.security import generate_password_hash, check_password_hash
   from app import db


   class User(UserMixin, db.Model):
       """Admin user with secure password storage.

       Passwords are hashed using Werkzeug's PBKDF2 implementation.
       Never stores plain text passwords.

       UserMixin provides Flask-Login integration:
       is_authenticated, is_active, is_anonymous, get_id()
       """

       __tablename__ = "users"

       id = db.Column(db.Integer, primary_key=True)
       username = db.Column(db.String(80), unique=True, nullable=False, index=True)
       password_hash = db.Column(db.String(256), nullable=False)
       is_active = db.Column(db.Boolean, default=True)

       def __repr__(self):
           return f"<User {self.username}>"

       def set_password(self, password):
           """Hash and store a password."""
           self.password_hash = generate_password_hash(password)

       def check_password(self, password):
           """Verify a password against the stored hash."""
           return check_password_hash(self.password_hash, password)
   ```

> ℹ **Concept Deep Dive**
>
> Flask-Login stores the user ID in a signed session cookie. On each request, the `user_loader` callback loads the full user from the database using `AuthService.get_user_by_id()`. This keeps the session cookie small (just the ID) while making the full user object available as `current_user`.
>
> `UserMixin` provides default implementations of four properties Flask-Login requires:
>
> - `is_authenticated` -- returns `True` (logged-in users are authenticated)
> - `is_active` -- returns `True` (overridden by our `is_active` column)
> - `is_anonymous` -- returns `False` (real users are not anonymous)
> - `get_id()` -- returns `str(self.id)` (the ID stored in the session cookie)
>
> `login_view = "auth.login"` tells Flask-Login where to redirect unauthenticated users when they try to access a protected route. `login_message_category = "info"` sets the flash message category for the automatic "Please log in" message.
>
> ⚠ **Common Mistakes**
>
> - Placing `login_manager` setup outside `create_app()` breaks the application factory pattern
> - Forgetting to add `UserMixin` to the User class causes `AttributeError` on login
> - Importing `User` directly in the `user_loader` instead of using `AuthService` bypasses the business layer
>
> ✓ **Quick check:** Flask-Login is initialized in `create_app()`, `UserMixin` is added to User, and the `user_loader` callback is defined

### **Step 2:** Create the Login Form

The login form uses WTForms for field definitions and Flask-WTF for automatic CSRF protection. This is the same pattern used by the subscription form, but with username and password fields instead of email and name.

1. **Ensure** the forms directory and init file exist:

   ```bash
   mkdir -p app/presentation/forms
   touch app/presentation/forms/__init__.py
   ```

   If you completed the WTForms exercise, these already exist.

2. **Create** a new file named `login.py`:

   > `app/presentation/forms/login.py`

   ```python
   """Login form for admin authentication."""

   from flask_wtf import FlaskForm
   from wtforms import StringField, PasswordField, SubmitField
   from wtforms.validators import DataRequired


   class LoginForm(FlaskForm):
       """Admin login form.

       Uses WTForms validators for server-side validation
       and Flask-WTF for automatic CSRF protection.
       """

       username = StringField("Username", validators=[
           DataRequired(message="Username is required")
       ])
       password = PasswordField("Password", validators=[
           DataRequired(message="Password is required")
       ])
       submit = SubmitField("Log In")
   ```

> ℹ **Concept Deep Dive**
>
> `PasswordField` renders as `<input type="password">` in the browser, which masks the input with dots. Unlike `StringField`, the browser never autocompletes or displays password field values in plain text.
>
> The `DataRequired` validator checks that both fields are filled in before submission. If either is empty, WTForms sets per-field errors and `validate_on_submit()` returns `False`.
>
> `FlaskForm` automatically includes a hidden CSRF token field. The `{{ form.hidden_tag() }}` call in the template renders this token. On form submission, Flask-WTF verifies the token to prevent cross-site request forgery attacks.
>
> ✓ **Quick check:** File created at `app/presentation/forms/login.py` with `LoginForm` class containing username, password, and submit fields

### **Step 3:** Create the Auth Blueprint

The auth blueprint handles login and logout routes. It coordinates between Flask-Login (session management) and the AuthService (credential verification), keeping all authentication-related routes in one module.

1. **Create** a new file named `auth.py` in the routes directory:

   > `app/presentation/routes/auth.py`

   ```python
   """
   Authentication routes for login and logout.

   Uses Flask-Login for session management and AuthService
   for credential verification.
   """

   from flask import Blueprint, render_template, redirect, url_for, flash, request
   from flask_login import login_user, logout_user, login_required, current_user

   from app.business.services.auth_service import AuthService
   from app.presentation.forms.login import LoginForm

   auth_bp = Blueprint("auth", __name__, url_prefix="/auth")


   @auth_bp.route("/login", methods=["GET", "POST"])
   def login():
       """Display and handle the login form."""
       # Already logged in? Redirect to admin
       if current_user.is_authenticated:
           return redirect(url_for("admin.subscribers"))

       form = LoginForm()

       if form.validate_on_submit():
           user = AuthService.authenticate(form.username.data, form.password.data)
           if user:
               login_user(user)
               flash("Login successful!", "success")

               # Redirect to originally requested page or admin
               next_page = request.args.get("next")
               if next_page and next_page.startswith("/"):
                   return redirect(next_page)
               return redirect(url_for("admin.subscribers"))
           else:
               flash("Invalid username or password.", "error")

       return render_template("auth/login.html", form=form)


   @auth_bp.route("/logout")
   @login_required
   def logout():
       """Log out the current user."""
       logout_user()
       flash("You have been logged out.", "info")
       return redirect(url_for("public.index"))
   ```

2. **Register** the auth blueprint in `app/__init__.py`. If you used the complete file from Step 1, this is already included. If not, **add** the following inside `create_app()` alongside the other blueprint registrations:

   > `app/__init__.py`

   ```python
   from app.presentation.routes.auth import auth_bp
   app.register_blueprint(auth_bp)
   ```

> ℹ **Concept Deep Dive**
>
> **The login flow works in three phases:**
>
> 1. **GET request** -- Renders the empty login form
> 2. **POST request (invalid)** -- `validate_on_submit()` returns `False` or `AuthService.authenticate()` returns `None`. Flash error message and re-render the form
> 3. **POST request (valid)** -- `login_user(user)` creates the session, then redirect to the admin area
>
> The `?next` parameter preserves where the user wanted to go before being redirected to login. For example, if a user visits `/admin/subscribers` while logged out, Flask-Login redirects to `/auth/login?next=/admin/subscribers`. After successful login, the route reads `next` and sends the user to their original destination.
>
> The `next_page.startswith("/")` check prevents **open redirect attacks** where an attacker crafts a URL like `/auth/login?next=https://evil-site.com`. By requiring the path to start with `/`, we ensure redirects only go to pages within our own application.
>
> `@login_required` on the logout route ensures only logged-in users can log out. Without it, an anonymous user accessing `/auth/logout` would cause an error.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to check `current_user.is_authenticated` at the top of the login route causes already-logged-in users to see the login form
> - Not validating the `next` parameter enables open redirect attacks
> - Using `redirect(url_for("admin.subscribers"))` without importing `redirect` causes a `NameError`
> - Forgetting `@login_required` on logout causes errors for anonymous users
>
> ✓ **Quick check:** Auth blueprint created with `/auth/login` and `/auth/logout` routes, registered in `app/__init__.py`

### **Step 4:** Create Login Template and Update Navigation

The login template renders the form with CSRF protection and per-field error messages. The base template navigation updates to show different links depending on whether the user is logged in.

1. **Create** the auth templates directory:

   ```bash
   mkdir -p app/presentation/templates/auth
   ```

2. **Create** the login template:

   > `app/presentation/templates/auth/login.html`

   ```html
   {% extends "base.html" %}

   {% block title %}Login - News Flash{% endblock %}

   {% block content %}
   <div class="login">
       <h1 class="login__title">Admin Login</h1>

       <form class="form" action="{{ url_for('auth.login') }}" method="POST">
           {{ form.hidden_tag() }}

           <div class="form__group">
               {{ form.username.label(class="form__label") }}
               {{ form.username(class="form__input", placeholder="Username", autofocus=true) }}
               {% if form.username.errors %}
               <ul class="form__errors">
                   {% for error in form.username.errors %}
                   <li>{{ error }}</li>
                   {% endfor %}
               </ul>
               {% endif %}
           </div>

           <div class="form__group">
               {{ form.password.label(class="form__label") }}
               {{ form.password(class="form__input", placeholder="Password") }}
               {% if form.password.errors %}
               <ul class="form__errors">
                   {% for error in form.password.errors %}
                   <li>{{ error }}</li>
                   {% endfor %}
               </ul>
               {% endif %}
           </div>

           {{ form.submit(class="form__button") }}
       </form>
   </div>
   {% endblock %}
   ```

3. **Update** `app/presentation/templates/base.html` to make the navigation conditional based on authentication state:

   > `app/presentation/templates/base.html`

   ```html
   <nav class="nav">
       <a href="{{ url_for('public.index') }}" class="nav__link">Home</a>
       <a href="{{ url_for('public.subscribe') }}" class="nav__link">Subscribe</a>
       {% if current_user.is_authenticated %}
       <a href="{{ url_for('admin.subscribers') }}" class="nav__link">Admin</a>
       <a href="{{ url_for('auth.logout') }}" class="nav__link">Logout</a>
       {% else %}
       <a href="{{ url_for('auth.login') }}" class="nav__link">Login</a>
       {% endif %}
   </nav>
   ```

   **Replace** the existing `<nav>` section with the code above. The Admin link that was previously visible to everyone is now only shown to authenticated users.

4. **Add** flash message support to `base.html` if not already present. If you completed the WTForms exercise, this block already exists. If not, **add** the following inside `<main>`, before `{% block content %}`:

   > `app/presentation/templates/base.html`

   ```html
   {% with messages = get_flashed_messages(with_categories=true) %}
   {% if messages %}
   <div class="flash-messages">
       {% for category, message in messages %}
       <div class="flash flash--{{ category }}">
           {{ message }}
           <button class="flash__close" onclick="this.parentElement.remove()">&times;</button>
       </div>
       {% endfor %}
   </div>
   {% endif %}
   {% endwith %}
   ```

5. **Add** CSS for flash messages if not already present. Place these styles in the `<style>` section or CSS block:

   > `app/presentation/templates/base.html`

   ```css
   .flash-messages {
       max-width: 600px;
       margin: 1rem auto;
       padding: 0 1rem;
   }

   .flash {
       padding: 0.75rem 1rem;
       border-radius: 0.5rem;
       margin-bottom: 0.5rem;
       display: flex;
       justify-content: space-between;
       align-items: center;
       font-size: 0.875rem;
   }

   .flash--success {
       background-color: #f0fdf4;
       border: 1px solid #bbf7d0;
       color: #166534;
   }

   .flash--error {
       background-color: #fef2f2;
       border: 1px solid #fecaca;
       color: #dc2626;
   }

   .flash--info {
       background-color: #eff6ff;
       border: 1px solid #bfdbfe;
       color: #1e40af;
   }

   .flash__close {
       background: none;
       border: none;
       font-size: 1.25rem;
       cursor: pointer;
       color: inherit;
       padding: 0 0.25rem;
   }
   ```

> ℹ **Concept Deep Dive**
>
> `current_user` is a proxy object provided by Flask-Login. It is available in **all templates automatically** -- you do not need to pass it from the route. When no user is logged in, `current_user` acts as an anonymous user where `current_user.is_authenticated` returns `False`.
>
> The `{% if current_user.is_authenticated %}` conditional hides admin-only navigation from anonymous users. This is a **UI convenience**, not a security measure. The actual security comes from `@login_required` on the routes. Even if someone manually typed `/admin/subscribers` in the browser, they would be redirected to the login page once `@login_required` is added to the admin routes.
>
> `form.hidden_tag()` renders the CSRF token as a hidden input field inside the form. This token is verified automatically on form submission by `validate_on_submit()`. Without it, every POST request would fail with a CSRF error.
>
> ⚠ **Common Mistakes**
>
> - Trying to pass `current_user` to templates manually -- Flask-Login injects it automatically
> - Forgetting to create the `auth/` subdirectory inside templates causes `TemplateNotFound`
> - Not including `form.hidden_tag()` in the login template causes CSRF validation failure on every login attempt
> - Relying on hidden navigation as a security measure instead of using `@login_required` on routes
>
> ✓ **Quick check:** Login template renders with CSRF token, navigation shows different links based on auth state

### **Step 5:** Test the Login Flow

Verify the complete authentication flow by testing login, logout, navigation changes, and edge cases.

1. **Create an admin user** via Flask shell:

   ```bash
   flask shell
   ```

   ```python
   from app.business.services.auth_service import AuthService
   AuthService.create_user("admin", "password123")
   ```

   Type `exit()` to leave the shell.

2. **Start the application:**

   ```bash
   flask run
   ```

3. **Verify the login page renders:**
   - **Navigate to** <http://localhost:5000/auth/login>
   - Verify the login form appears with username and password fields
   - **View page source** and confirm a hidden CSRF token input is present

4. **Test with invalid credentials:**
   - Enter username `admin` and password `wrongpassword`
   - Click "Log In"
   - Verify flash error message "Invalid username or password." appears with red styling

5. **Test with valid credentials:**
   - Enter username `admin` and password `password123`
   - Click "Log In"
   - Verify redirect to `/admin/subscribers`
   - Verify flash success message "Login successful!" appears with green styling

6. **Verify navigation updates:**
   - Confirm the navigation shows "Admin" and "Logout" links
   - Confirm the "Login" link is no longer visible

7. **Test logout:**
   - Click "Logout" in the navigation
   - Verify redirect to the home page
   - Verify flash info message "You have been logged out." appears with blue styling
   - Verify the navigation shows "Login" again (not "Admin" or "Logout")

8. **Test redirect after login (optional):**
   - While logged out, **navigate to** <http://localhost:5000/auth/login?next=/admin/subscribers>
   - Log in with valid credentials
   - Verify you are redirected to `/admin/subscribers` instead of the default

> ✓ **Success indicators:**
>
> - Login form renders with CSRF token
> - Invalid credentials show error flash message
> - Valid credentials redirect to admin area with success message
> - Navigation updates based on authentication state
> - Logout clears session and redirects to home page
> - Flash messages display with correct color categories (green/red/blue)
>
> ✓ **Final verification checklist:**
>
> - [ ] Flask-Login initialized in `app/__init__.py` with `user_loader` callback
> - [ ] `UserMixin` added to User model in `app/data/models/user.py`
> - [ ] `LoginForm` created at `app/presentation/forms/login.py`
> - [ ] Auth blueprint created at `app/presentation/routes/auth.py`
> - [ ] Auth blueprint registered in `app/__init__.py`
> - [ ] Login template created at `app/presentation/templates/auth/login.html`
> - [ ] Navigation in `base.html` is conditional based on `current_user.is_authenticated`
> - [ ] Flash messages render with category-based styling
> - [ ] Login, logout, and navigation all work correctly

## Common Issues

> **If you encounter problems:**
>
> **"RuntimeError: A secret key is required":** Add `SECRET_KEY` to the `Config` base class in `app/config.py`. Flask-Login needs it to sign session cookies.
>
> **"AttributeError: 'User' object has no attribute 'is_active'" (unexpected behavior):** Ensure `UserMixin` is added to the User class definition: `class User(UserMixin, db.Model)`. `UserMixin` must come before `db.Model` in the inheritance list.
>
> **Login always fails:** Ensure the user was created with `AuthService.create_user()` which hashes the password. Manually setting `password_hash` to a plain text string will not work because `check_password()` expects a Werkzeug hash.
>
> **"Could not build url for endpoint 'auth.login'":** The auth blueprint is not registered in `app/__init__.py`. Add `app.register_blueprint(auth_bp)` inside `create_app()`.
>
> **Flash messages not showing:** Add the `get_flashed_messages` block to `base.html` before `{% block content %}`. Ensure it uses `with_categories=true` to get the category for color-coded styling.
>
> **"TemplateNotFound: auth/login.html":** Create the `auth/` subdirectory inside `app/presentation/templates/`. The directory name must match the path used in `render_template("auth/login.html")`.
>
> **Still stuck?** Test Flask-Login setup in Flask shell:
>
> ```python
> flask shell
> >>> from flask_login import current_user
> >>> print(current_user.is_authenticated)  # False (not logged in)
> ```

## Summary

You've added a complete session-based login system which:

- ✓ Installed and configured Flask-Login for session management
- ✓ Created a login form with WTForms and CSRF protection
- ✓ Built an auth blueprint with login and logout routes
- ✓ Updated navigation to show authentication state
- ✓ Implemented secure redirect handling with open redirect protection

> **Key takeaway:** Flask-Login handles the complexity of session management. The `user_loader` callback connects Flask-Login to the User model through the AuthService, keeping the three-tier architecture intact. Routes use `login_user()` and `logout_user()` for session management, and `current_user` is available everywhere -- in routes, templates, and any code running within a request context. The navigation conditionals are a UI convenience; actual security comes from `@login_required` on protected routes.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add a "Remember Me" checkbox to the login form using `login_user(user, remember=True)`
> - Implement password reset via email with time-limited tokens
> - Add login attempt rate limiting to prevent brute-force attacks
> - Research JWT tokens as an alternative to cookie-based sessions

## Done!

You've added a complete login system with session management. Users can now log in and out, and the navigation reflects their authentication state.
