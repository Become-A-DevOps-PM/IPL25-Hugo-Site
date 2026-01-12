# Phase 4: Admin Authentication - Implementation Guide

**Project:** dev-3tier-flask Reference Implementation
**Purpose:** Complete implementation guide for unattended execution of Phase 4
**Created:** 2026-01-09
**Prerequisite:** Phase 3 must be complete (74 tests passing)

---

## Overview

This document provides a complete, self-contained guide for implementing Phase 4 (Admin Authentication) of the dev-3tier-flask reference project. It is designed to enable **unattended execution** with the ability to resume from any point.

### What Phase 4 Delivers

Secure admin routes with session-based authentication:

```
+-------------------------------------------------------------------------------+
|  PHASE 4 FEATURES                                                             |
+-------------------------------------------------------------------------------+
|                                                                               |
|  1. USER MODEL WITH PASSWORD HASHING                                          |
|     - User model with Werkzeug password hashing                               |
|     - Secure password storage (never plain text)                              |
|     - Username uniqueness enforced                                            |
|                                                                               |
|  2. FLASK-LOGIN SESSION MANAGEMENT                                            |
|     - User session handling                                                   |
|     - Remember me functionality                                               |
|     - Login required protection                                               |
|                                                                               |
|  3. AUTHENTICATION SERVICE                                                    |
|     - Authenticate users by credentials                                       |
|     - Create admin users programmatically                                     |
|     - Secure password verification                                            |
|                                                                               |
|  4. LOGIN FORM WITH WTFORMS                                                   |
|     - Username/password fields                                                |
|     - CSRF protection (existing)                                              |
|     - Validation and error display                                            |
|                                                                               |
|  5. AUTH BLUEPRINT                                                            |
|     - Login page and form handling                                            |
|     - Logout with session cleanup                                             |
|     - Redirect after authentication                                           |
|                                                                               |
|  6. PROTECTED ADMIN ROUTES                                                    |
|     - @login_required on /admin/attendees                                     |
|     - @login_required on /admin/export/csv                                    |
|     - Redirect to login if not authenticated                                  |
|                                                                               |
|  7. SECURITY HEADERS MIDDLEWARE                                               |
|     - X-Content-Type-Options                                                  |
|     - X-Frame-Options                                                         |
|     - X-XSS-Protection                                                        |
|     - Strict-Transport-Security (production)                                  |
|                                                                               |
|  8. CLI COMMAND FOR ADMIN CREATION                                            |
|     - flask create-admin command                                              |
|     - Interactive password input                                              |
|     - Duplicate username prevention                                           |
|                                                                               |
+-------------------------------------------------------------------------------+
```

### Key Principles

1. **Additive Development** - Never delete Phase 3 code; add new functionality alongside
2. **Layer-by-Layer** - Build from data layer up (Model -> Service -> Forms -> Routes)
3. **Test-Driven** - Add tests with each step; all tests must pass before proceeding
4. **Git Commits** - One commit per phase step for clear history
5. **Security First** - Use proven libraries, never roll own crypto

### PRD Requirements Addressed

| PRD Reference | Requirement | Phase 4 Step |
|---------------|-------------|--------------|
| NFR-003 | Secure Admin Access | 4.5, 4.6 |
| NFR-003 | Password Security | 4.1, 4.2 |
| NFR-003 | Session Management | 4.3 |
| NFR-003 | Security Headers | 4.7 |
| NFR-002 | IaC Compatible Setup | 4.8 |

---

## Execution Framework

### Status Tracking

**Status File:** `.phase4-status.json` (in project root)

```json
{
  "phase": "4",
  "current_step": "4.X",
  "steps": {
    "4.0": { "status": "pending|in_progress|completed", "exercise": "path", "commit": "sha" },
    "4.1": { "status": "pending", "exercise": null, "commit": null },
    "4.2": { "status": "pending", "exercise": null, "commit": null },
    "4.3": { "status": "pending", "exercise": null, "commit": null },
    "4.4": { "status": "pending", "exercise": null, "commit": null },
    "4.5": { "status": "pending", "exercise": null, "commit": null },
    "4.6": { "status": "pending", "exercise": null, "commit": null },
    "4.7": { "status": "pending", "exercise": null, "commit": null },
    "4.8": { "status": "pending", "exercise": null, "commit": null }
  },
  "started_at": null,
  "completed_at": null,
  "last_updated": null
}
```

### Exercise Files Location

All exercise markdown files go in: `docs/exercises/`

### Per-Step Workflow

For each step (4.0 through 4.8):

```
1. READ STATUS    -> cat .phase4-status.json
2. READ GIT LOG   -> git log --oneline -5
3. CREATE EXERCISE -> Write docs/exercises/phase-4.X-[name].md
4. IMPLEMENT CODE -> Create/modify files as specified
5. RUN TESTS      -> cd application && pytest tests/ -v
6. UPDATE STATUS  -> Edit .phase4-status.json
7. GIT COMMIT     -> git add . && git commit -m "Phase 4.X: [Message]"
8. PROCEED        -> Move to next step
```

### Resumption Protocol

When starting/resuming:

1. Read `.phase4-status.json` to find current step
2. Read `git log --oneline -10` for context
3. If current step is "in_progress" -> continue it
4. If current step is "completed" -> proceed to next
5. If current step is "pending" -> start it

### Pre-Implementation Verification

Before starting Phase 4, verify Phase 3 is complete:

```bash
cd application
source .venv/bin/activate
pytest tests/ -v
# Expected: 74 tests passing
```

---

## Phase 4.0: Setup and Dependencies

**Goal:** Add Flask-Login dependency (Werkzeug already available via Flask)

### Files to Create/Modify

| Action | File |
|--------|------|
| MODIFY | `application/requirements.txt` |
| CREATE | `.phase4-status.json` |

### requirements.txt Additions

Add this line to `application/requirements.txt`:

```
# Authentication
Flask-Login==0.6.3
```

**Note:** Werkzeug (for password hashing) is already installed as a Flask dependency.

### Install Dependencies

```bash
cd application
source .venv/bin/activate
pip install -r requirements.txt
```

### Create Status File

Create `.phase4-status.json` in project root:

```json
{
  "phase": "4",
  "current_step": "4.0",
  "steps": {
    "4.0": { "status": "in_progress", "exercise": null, "commit": null },
    "4.1": { "status": "pending", "exercise": null, "commit": null },
    "4.2": { "status": "pending", "exercise": null, "commit": null },
    "4.3": { "status": "pending", "exercise": null, "commit": null },
    "4.4": { "status": "pending", "exercise": null, "commit": null },
    "4.5": { "status": "pending", "exercise": null, "commit": null },
    "4.6": { "status": "pending", "exercise": null, "commit": null },
    "4.7": { "status": "pending", "exercise": null, "commit": null },
    "4.8": { "status": "pending", "exercise": null, "commit": null }
  },
  "started_at": "2026-01-09T00:00:00Z",
  "completed_at": null,
  "last_updated": "2026-01-09T00:00:00Z"
}
```

### Verification

```bash
pytest tests/ -v
# Expected: 74 tests still passing (no functional changes)

python -c "import flask_login; print('Flask-Login installed successfully')"
```

**Commit Message:** `Phase 4.0: Add Flask-Login dependency for authentication`

---

## Phase 4.1: User Model with Password Hashing

**Goal:** Create User model with Werkzeug password hashing

### Files to Create/Modify

| Action | File |
|--------|------|
| CREATE | `application/app/models/user.py` |
| MODIFY | `application/app/models/__init__.py` |
| MODIFY | `application/tests/test_routes.py` |

### user.py Content

Create `application/app/models/user.py`:

```python
"""User model for admin authentication."""
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from app.extensions import db


class User(UserMixin, db.Model):
    """Admin user with password authentication.

    Uses Werkzeug's security functions for password hashing.
    Passwords are never stored in plain text.
    """

    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(256), nullable=False)
    is_active = db.Column(db.Boolean, default=True)

    def __repr__(self):
        return f'<User {self.username}>'

    def set_password(self, password):
        """Hash and store password.

        Args:
            password: Plain text password to hash
        """
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        """Verify password against stored hash.

        Args:
            password: Plain text password to verify

        Returns:
            bool: True if password matches, False otherwise
        """
        return check_password_hash(self.password_hash, password)
```

### models/__init__.py Update

Update `application/app/models/__init__.py`:

```python
"""Data layer models.

All SQLAlchemy models are exported from this package.
"""

from app.models.entry import Entry
from app.models.registration import Registration
from app.models.user import User

__all__ = ['Entry', 'Registration', 'User']
```

### Generate Migration

```bash
cd application
source .venv/bin/activate
flask db migrate -m "Add user model for authentication"
flask db upgrade
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestUserModel:
    """Tests for the User model."""

    def test_user_repr(self, app):
        """Test User string representation."""
        with app.app_context():
            from app.models.user import User
            user = User(username='testadmin')
            user.set_password('testpass123')
            assert '<User testadmin>' in repr(user)

    def test_user_set_password_hashes(self, app):
        """Test that set_password creates a hash, not plain text."""
        with app.app_context():
            from app.models.user import User
            user = User(username='hashtest')
            user.set_password('mypassword')
            assert user.password_hash != 'mypassword'
            assert len(user.password_hash) > 50  # Hashes are long

    def test_user_check_password_correct(self, app):
        """Test password verification with correct password."""
        with app.app_context():
            from app.models.user import User
            user = User(username='verifytest')
            user.set_password('correctpass')
            assert user.check_password('correctpass') is True

    def test_user_check_password_incorrect(self, app):
        """Test password verification with incorrect password."""
        with app.app_context():
            from app.models.user import User
            user = User(username='verifytest2')
            user.set_password('correctpass')
            assert user.check_password('wrongpass') is False

    def test_user_is_active_default(self, app):
        """Test that is_active defaults to True."""
        with app.app_context():
            from app.models.user import User
            user = User(username='activetest')
            user.set_password('password')
            assert user.is_active is True
```

### Verification

```bash
pytest tests/ -v
# Expected: 74 + 5 = 79 tests passing
```

**Commit Message:** `Phase 4.1: Add User model with Werkzeug password hashing`

---

## Phase 4.2: Authentication Service

**Goal:** Create AuthService with authenticate and create_user methods

### Files to Create/Modify

| Action | File |
|--------|------|
| CREATE | `application/app/services/auth_service.py` |
| MODIFY | `application/app/services/__init__.py` |
| MODIFY | `application/tests/test_routes.py` |

### auth_service.py Content

Create `application/app/services/auth_service.py`:

```python
"""Business logic for user authentication."""
from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.user import User


class DuplicateUsernameError(Exception):
    """Raised when attempting to create user with existing username."""
    pass


class AuthService:
    """Service layer for authentication operations."""

    @staticmethod
    def authenticate(username, password):
        """Authenticate user by username and password.

        Args:
            username: User's username
            password: Plain text password to verify

        Returns:
            User: The authenticated user, or None if authentication fails
        """
        user = User.query.filter_by(username=username).first()
        if user and user.is_active and user.check_password(password):
            return user
        return None

    @staticmethod
    def create_user(username, password):
        """Create a new admin user.

        Args:
            username: Unique username for the admin
            password: Plain text password (will be hashed)

        Returns:
            User: The created user object

        Raises:
            DuplicateUsernameError: If username already exists
        """
        user = User(username=username)
        user.set_password(password)
        try:
            db.session.add(user)
            db.session.commit()
            return user
        except IntegrityError:
            db.session.rollback()
            raise DuplicateUsernameError(f"Username '{username}' already exists.")

    @staticmethod
    def get_user_by_id(user_id):
        """Get user by ID for Flask-Login.

        Args:
            user_id: User's database ID

        Returns:
            User: The user object, or None if not found
        """
        return db.session.get(User, int(user_id))

    @staticmethod
    def get_user_by_username(username):
        """Get user by username.

        Args:
            username: User's username

        Returns:
            User: The user object, or None if not found
        """
        return User.query.filter_by(username=username).first()
```

### services/__init__.py Update

Update `application/app/services/__init__.py`:

```python
"""Business logic layer services.

Services encapsulate business logic and database operations,
keeping routes thin and focused on request/response handling.
"""

from app.services.entry_service import EntryService
from app.services.registration_service import RegistrationService, DuplicateEmailError
from app.services.auth_service import AuthService, DuplicateUsernameError

__all__ = ['EntryService', 'RegistrationService', 'DuplicateEmailError',
           'AuthService', 'DuplicateUsernameError']
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestAuthService:
    """Tests for the AuthService."""

    def test_create_user(self, app):
        """Test creating a new user via service."""
        with app.app_context():
            from app.services.auth_service import AuthService
            user = AuthService.create_user('newadmin', 'securepass123')
            assert user.id is not None
            assert user.username == 'newadmin'

    def test_create_user_duplicate_raises(self, app):
        """Test that duplicate username raises error."""
        with app.app_context():
            from app.services.auth_service import AuthService, DuplicateUsernameError
            import pytest
            AuthService.create_user('duplicateuser', 'pass12345')
            with pytest.raises(DuplicateUsernameError):
                AuthService.create_user('duplicateuser', 'pass23456')

    def test_authenticate_success(self, app):
        """Test successful authentication."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('authtest', 'correctpassword')
            user = AuthService.authenticate('authtest', 'correctpassword')
            assert user is not None
            assert user.username == 'authtest'

    def test_authenticate_wrong_password(self, app):
        """Test authentication with wrong password."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('wrongpasstest', 'rightpassword')
            user = AuthService.authenticate('wrongpasstest', 'wrongpassword')
            assert user is None

    def test_authenticate_nonexistent_user(self, app):
        """Test authentication with nonexistent user."""
        with app.app_context():
            from app.services.auth_service import AuthService
            user = AuthService.authenticate('nouser', 'anypassword')
            assert user is None

    def test_authenticate_inactive_user(self, app):
        """Test that inactive users cannot authenticate."""
        with app.app_context():
            from app.services.auth_service import AuthService
            from app.extensions import db
            user = AuthService.create_user('inactivetest', 'password123')
            user.is_active = False
            db.session.commit()
            result = AuthService.authenticate('inactivetest', 'password123')
            assert result is None

    def test_get_user_by_id(self, app):
        """Test getting user by ID."""
        with app.app_context():
            from app.services.auth_service import AuthService
            created = AuthService.create_user('byidtest', 'password123')
            found = AuthService.get_user_by_id(created.id)
            assert found.username == 'byidtest'

    def test_get_user_by_username(self, app):
        """Test getting user by username."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('byusernametest', 'password123')
            found = AuthService.get_user_by_username('byusernametest')
            assert found is not None
            assert found.username == 'byusernametest'
```

### Verification

```bash
pytest tests/ -v
# Expected: 79 + 8 = 87 tests passing
```

**Commit Message:** `Phase 4.2: Add AuthService with authenticate and create_user methods`

---

## Phase 4.3: Flask-Login Integration

**Goal:** Configure Flask-Login and add login manager to extensions

### Files to Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/extensions.py` |
| MODIFY | `application/app/__init__.py` |
| MODIFY | `application/tests/test_routes.py` |

### extensions.py Update

Update `application/app/extensions.py`:

```python
"""Flask extensions initialization.

Extensions are instantiated here without being bound to an application.
They are initialized with the app in the application factory.
"""

from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager

# Database ORM
db = SQLAlchemy()

# Database migrations
migrate = Migrate()

# User session management
login_manager = LoginManager()
login_manager.login_view = 'auth.login'
login_manager.login_message = 'Please log in to access this page.'
login_manager.login_message_category = 'info'
```

### __init__.py Update

Update `application/app/__init__.py`:

```python
"""Application factory for the Flask application.

The factory pattern allows creating multiple app instances with different
configurations, which is useful for testing and running multiple instances.
"""
from flask import Flask, render_template
from app.extensions import db, migrate, login_manager


def create_app(config_name='development'):
    """Create and configure the Flask application.

    Args:
        config_name: Configuration to use ('development', 'production', 'testing').

    Returns:
        Configured Flask application instance.
    """
    app = Flask(__name__)

    # Load configuration
    config_map = {
        'development': 'config.DevelopmentConfig',
        'production': 'config.ProductionConfig',
        'testing': 'config.TestingConfig'
    }
    app.config.from_object(config_map.get(config_name, 'config.DevelopmentConfig'))

    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)

    # Configure user loader for Flask-Login
    from app.services.auth_service import AuthService

    @login_manager.user_loader
    def load_user(user_id):
        return AuthService.get_user_by_id(user_id)

    # Import models so they are registered with SQLAlchemy
    from app import models  # noqa: F401

    # Register blueprints
    from app.routes import register_blueprints
    register_blueprints(app)

    # Register error handlers
    register_error_handlers(app)

    return app


def register_error_handlers(app):
    """Register custom error handlers for the application."""

    @app.errorhandler(400)
    def bad_request_error(error):
        return render_template('errors/400.html'), 400

    @app.errorhandler(404)
    def not_found_error(error):
        return render_template('errors/404.html'), 404

    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        return render_template('errors/500.html'), 500
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestFlaskLoginSetup:
    """Tests for Flask-Login configuration."""

    def test_login_manager_configured(self, app):
        """Test that login manager is configured on the app."""
        assert hasattr(app, 'login_manager')

    def test_login_view_set(self, app):
        """Test that login view is configured."""
        from app.extensions import login_manager
        assert login_manager.login_view == 'auth.login'

    def test_user_loader_works(self, app):
        """Test that user loader can load a user."""
        with app.app_context():
            from app.services.auth_service import AuthService
            from app.extensions import login_manager

            created = AuthService.create_user('loadertest', 'password123')
            loaded = login_manager._user_callback(str(created.id))
            assert loaded.username == 'loadertest'
```

### Verification

```bash
pytest tests/ -v
# Expected: 87 + 3 = 90 tests passing
```

**Commit Message:** `Phase 4.3: Configure Flask-Login for session management`

---

## Phase 4.4: Login Form with WTForms

**Goal:** Create login form with username and password fields

### Files to Create/Modify

| Action | File |
|--------|------|
| CREATE | `application/app/forms/login.py` |
| MODIFY | `application/app/forms/__init__.py` |
| MODIFY | `application/tests/test_routes.py` |

### login.py Content

Create `application/app/forms/login.py`:

```python
"""Login form for admin authentication."""
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import DataRequired, Length


class LoginForm(FlaskForm):
    """Form for admin login.

    Fields:
    - username: Required, 3-80 characters
    - password: Required, minimum 8 characters
    - remember_me: Optional, for persistent sessions
    """

    username = StringField('Username', validators=[
        DataRequired(message='Username is required.'),
        Length(min=3, max=80, message='Username must be between 3 and 80 characters.')
    ])

    password = PasswordField('Password', validators=[
        DataRequired(message='Password is required.'),
        Length(min=8, message='Password must be at least 8 characters.')
    ])

    remember_me = BooleanField('Remember Me')

    submit = SubmitField('Log In')
```

### forms/__init__.py Update

Update `application/app/forms/__init__.py`:

```python
"""Form classes for the application."""
from app.forms.registration import RegistrationForm
from app.forms.login import LoginForm

__all__ = ['RegistrationForm', 'LoginForm']
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestLoginForm:
    """Tests for the LoginForm validation."""

    def test_login_form_rejects_empty_username(self, app):
        """Test that empty username is rejected."""
        with app.app_context():
            from app.forms.login import LoginForm
            form = LoginForm(data={
                'username': '',
                'password': 'validpassword123'
            })
            assert not form.validate()
            assert 'username' in form.errors

    def test_login_form_rejects_short_username(self, app):
        """Test that username shorter than 3 chars is rejected."""
        with app.app_context():
            from app.forms.login import LoginForm
            form = LoginForm(data={
                'username': 'ab',
                'password': 'validpassword123'
            })
            assert not form.validate()
            assert 'username' in form.errors

    def test_login_form_rejects_empty_password(self, app):
        """Test that empty password is rejected."""
        with app.app_context():
            from app.forms.login import LoginForm
            form = LoginForm(data={
                'username': 'validuser',
                'password': ''
            })
            assert not form.validate()
            assert 'password' in form.errors

    def test_login_form_rejects_short_password(self, app):
        """Test that password shorter than 8 chars is rejected."""
        with app.app_context():
            from app.forms.login import LoginForm
            form = LoginForm(data={
                'username': 'validuser',
                'password': 'short'
            })
            assert not form.validate()
            assert 'password' in form.errors

    def test_login_form_accepts_valid_data(self, app):
        """Test that valid credentials pass form validation."""
        with app.app_context():
            from app.forms.login import LoginForm
            form = LoginForm(data={
                'username': 'validuser',
                'password': 'validpassword123'
            })
            assert form.validate()
```

### Verification

```bash
pytest tests/ -v
# Expected: 90 + 5 = 95 tests passing
```

**Commit Message:** `Phase 4.4: Add LoginForm with WTForms validation`

---

## Phase 4.5: Auth Blueprint with Login/Logout Routes

**Goal:** Create auth blueprint with login page, login handler, and logout

### Files to Create/Modify

| Action | File |
|--------|------|
| CREATE | `application/app/routes/auth.py` |
| MODIFY | `application/app/routes/__init__.py` |
| CREATE | `application/app/templates/auth/login.html` |
| MODIFY | `application/tests/test_routes.py` |

### auth.py Content

Create `application/app/routes/auth.py`:

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

### routes/__init__.py Update

Update `application/app/routes/__init__.py`:

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

### auth/login.html Content

Create directory and file `application/app/templates/auth/login.html`:

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

### Additional CSS

Add to `application/app/static/css/style.css`:

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

### Tests to Add

Add to `application/tests/test_routes.py`:

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

### Verification

```bash
pytest tests/ -v
# Expected: 95 + 7 = 102 tests passing
```

**Commit Message:** `Phase 4.5: Add auth blueprint with login/logout routes`

---

## Phase 4.6: Protect Admin Routes with @login_required

**Goal:** Add authentication requirement to admin routes

### Files to Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/routes/admin.py` |
| MODIFY | `application/app/templates/base.html` |
| MODIFY | `application/tests/test_routes.py` |

### admin.py Update

Update `application/app/routes/admin.py`:

```python
"""Admin blueprint for managing registrations.

All routes require authentication via Flask-Login.
"""
from datetime import datetime
import csv
import io
from flask import Blueprint, render_template, request, Response
from flask_login import login_required
from app.services.registration_service import RegistrationService

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')


@admin_bp.route('/attendees')
@login_required
def attendees():
    """Display list of all webinar registrations with sorting.

    Requires authentication.

    Query parameters:
        sort: Field to sort by (name, email, company, job_title, created_at)
        order: Sort order (asc, desc)
    """
    sort_by = request.args.get('sort', 'created_at')
    order = request.args.get('order', 'desc')

    registrations = RegistrationService.get_registrations_sorted(sort_by, order)
    stats = RegistrationService.get_registration_stats()

    # Toggle order for column headers
    next_order = 'asc' if order == 'desc' else 'desc'

    return render_template('admin/attendees.html',
                          registrations=registrations,
                          stats=stats,
                          current_sort=sort_by,
                          current_order=order,
                          next_order=next_order)


@admin_bp.route('/export/csv')
@login_required
def export_csv():
    """Export all registrations as CSV file.

    Requires authentication.

    Returns a downloadable CSV file with all registration data.
    Filename includes current date for easy identification.
    """
    registrations = RegistrationService.get_all_registrations()

    # Create CSV in memory
    output = io.StringIO()
    writer = csv.writer(output)

    # Write header
    writer.writerow(['ID', 'Name', 'Email', 'Company', 'Job Title', 'Registered At'])

    # Write data rows
    for reg in registrations:
        writer.writerow([
            reg.id,
            reg.name,
            reg.email,
            reg.company,
            reg.job_title,
            reg.created_at.strftime('%Y-%m-%d %H:%M:%S') if reg.created_at else ''
        ])

    # Prepare response
    output.seek(0)
    date_str = datetime.now().strftime('%Y%m%d')
    filename = f'webinar-registrations-{date_str}.csv'

    return Response(
        output.getvalue(),
        mimetype='text/csv',
        headers={'Content-Disposition': f'attachment; filename={filename}'}
    )
```

### base.html Update

Update `application/app/templates/base.html` to show login/logout links:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}Flask App{% endblock %}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
    {% block extra_css %}{% endblock %}
</head>
<body>
    <nav class="navbar">
        <div class="nav-brand">
            <a href="{{ url_for('main.index') }}">Webinar Registration</a>
        </div>
        <div class="nav-links">
            <a href="{{ url_for('main.index') }}">Home</a>
            <a href="{{ url_for('main.webinar_info') }}">About</a>
            <a href="{{ url_for('main.register') }}">Register</a>
            {% if current_user.is_authenticated %}
                <a href="{{ url_for('admin.attendees') }}">Admin</a>
                <a href="{{ url_for('auth.logout') }}">Logout</a>
            {% else %}
                <a href="{{ url_for('auth.login') }}">Login</a>
            {% endif %}
        </div>
    </nav>

    <main class="container">
        {% with messages = get_flashed_messages(with_categories=true) %}
            {% if messages %}
                <div class="flash-messages">
                    {% for category, message in messages %}
                        <div class="flash flash-{{ category }}">
                            {{ message }}
                            <button type="button" class="flash-close" onclick="this.parentElement.remove()">&times;</button>
                        </div>
                    {% endfor %}
                </div>
            {% endif %}
        {% endwith %}

        {% block content %}{% endblock %}
    </main>

    <footer class="footer">
        <p>&copy; 2026 Webinar Registration. Built with Flask.</p>
    </footer>

    {% block extra_js %}{% endblock %}
</body>
</html>
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestProtectedAdminRoutes:
    """Tests for admin route protection."""

    def test_admin_attendees_requires_login(self, client):
        """Test that /admin/attendees redirects to login when not authenticated."""
        response = client.get('/admin/attendees', follow_redirects=False)
        assert response.status_code == 302
        assert '/auth/login' in response.location

    def test_admin_export_requires_login(self, client):
        """Test that /admin/export/csv redirects to login when not authenticated."""
        response = client.get('/admin/export/csv', follow_redirects=False)
        assert response.status_code == 302
        assert '/auth/login' in response.location

    def test_admin_attendees_accessible_when_logged_in(self, app, client):
        """Test that /admin/attendees is accessible when authenticated."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('adminaccess', 'password12345')

        client.post('/auth/login', data={
            'username': 'adminaccess',
            'password': 'password12345'
        })

        response = client.get('/admin/attendees')
        assert response.status_code == 200
        assert b'Attendees' in response.data

    def test_admin_export_accessible_when_logged_in(self, app, client):
        """Test that /admin/export/csv is accessible when authenticated."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('exportaccess', 'password12345')

        client.post('/auth/login', data={
            'username': 'exportaccess',
            'password': 'password12345'
        })

        response = client.get('/admin/export/csv')
        assert response.status_code == 200
        assert 'text/csv' in response.content_type

    def test_login_redirect_preserves_next_url(self, client):
        """Test that login redirect includes next parameter."""
        response = client.get('/admin/attendees', follow_redirects=False)
        assert response.status_code == 302
        # Flask-Login adds next parameter
        assert '/auth/login' in response.location

    def test_login_redirects_to_next_after_success(self, app, client):
        """Test that successful login redirects to the requested page."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('nexttest', 'password12345')

        response = client.post('/auth/login?next=/admin/attendees', data={
            'username': 'nexttest',
            'password': 'password12345'
        }, follow_redirects=False)

        assert response.status_code == 302
        assert '/admin/attendees' in response.location
```

### Verification

```bash
pytest tests/ -v
# Expected: 102 + 6 = 108 tests passing
```

**Commit Message:** `Phase 4.6: Protect admin routes with @login_required`

---

## Phase 4.7: Security Headers Middleware

**Goal:** Add security headers to all responses

### Files to Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/__init__.py` |
| MODIFY | `application/tests/test_routes.py` |

### __init__.py Update

Add security headers registration to `application/app/__init__.py`:

```python
"""Application factory for the Flask application.

The factory pattern allows creating multiple app instances with different
configurations, which is useful for testing and running multiple instances.
"""
from flask import Flask, render_template
from app.extensions import db, migrate, login_manager


def create_app(config_name='development'):
    """Create and configure the Flask application.

    Args:
        config_name: Configuration to use ('development', 'production', 'testing').

    Returns:
        Configured Flask application instance.
    """
    app = Flask(__name__)

    # Load configuration
    config_map = {
        'development': 'config.DevelopmentConfig',
        'production': 'config.ProductionConfig',
        'testing': 'config.TestingConfig'
    }
    app.config.from_object(config_map.get(config_name, 'config.DevelopmentConfig'))

    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)

    # Configure user loader for Flask-Login
    from app.services.auth_service import AuthService

    @login_manager.user_loader
    def load_user(user_id):
        return AuthService.get_user_by_id(user_id)

    # Import models so they are registered with SQLAlchemy
    from app import models  # noqa: F401

    # Register blueprints
    from app.routes import register_blueprints
    register_blueprints(app)

    # Register error handlers
    register_error_handlers(app)

    # Register security headers
    register_security_headers(app)

    return app


def register_error_handlers(app):
    """Register custom error handlers for the application."""

    @app.errorhandler(400)
    def bad_request_error(error):
        return render_template('errors/400.html'), 400

    @app.errorhandler(404)
    def not_found_error(error):
        return render_template('errors/404.html'), 404

    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        return render_template('errors/500.html'), 500


def register_security_headers(app):
    """Register security headers middleware.

    Adds security headers to all responses to protect against
    common web vulnerabilities.
    """

    @app.after_request
    def add_security_headers(response):
        # Prevent MIME type sniffing
        response.headers['X-Content-Type-Options'] = 'nosniff'

        # Prevent clickjacking
        response.headers['X-Frame-Options'] = 'SAMEORIGIN'

        # Enable XSS filter in browsers
        response.headers['X-XSS-Protection'] = '1; mode=block'

        # Referrer policy
        response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'

        # Only add HSTS in production (when not debug)
        if not app.debug:
            response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'

        return response
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestSecurityHeaders:
    """Tests for security headers middleware."""

    def test_x_content_type_options(self, client):
        """Test that X-Content-Type-Options header is set."""
        response = client.get('/')
        assert response.headers.get('X-Content-Type-Options') == 'nosniff'

    def test_x_frame_options(self, client):
        """Test that X-Frame-Options header is set."""
        response = client.get('/')
        assert response.headers.get('X-Frame-Options') == 'SAMEORIGIN'

    def test_x_xss_protection(self, client):
        """Test that X-XSS-Protection header is set."""
        response = client.get('/')
        assert response.headers.get('X-XSS-Protection') == '1; mode=block'

    def test_referrer_policy(self, client):
        """Test that Referrer-Policy header is set."""
        response = client.get('/')
        assert response.headers.get('Referrer-Policy') == 'strict-origin-when-cross-origin'

    def test_security_headers_on_all_routes(self, client):
        """Test that security headers are set on various routes."""
        routes = ['/', '/register', '/webinar', '/auth/login']
        for route in routes:
            response = client.get(route)
            assert response.headers.get('X-Content-Type-Options') == 'nosniff', f"Missing header on {route}"
```

### Verification

```bash
pytest tests/ -v
# Expected: 108 + 5 = 113 tests passing
```

**Commit Message:** `Phase 4.7: Add security headers middleware`

---

## Phase 4.8: CLI Command for Admin Creation

**Goal:** Add flask create-admin command for creating admin users

### Files to Create/Modify

| Action | File |
|--------|------|
| CREATE | `application/app/cli.py` |
| MODIFY | `application/app/__init__.py` |
| MODIFY | `application/tests/conftest.py` |
| MODIFY | `application/tests/test_routes.py` |

### cli.py Content

Create `application/app/cli.py`:

```python
"""Flask CLI commands for application management."""
import click
from flask.cli import with_appcontext


@click.command('create-admin')
@click.argument('username')
@click.option('--password', prompt=True, hide_input=True,
              confirmation_prompt=True, help='Admin password')
@with_appcontext
def create_admin_command(username, password):
    """Create a new admin user.

    Usage: flask create-admin USERNAME

    You will be prompted for a password (hidden input).
    Password must be at least 8 characters.

    Example:
        flask create-admin admin
    """
    from app.services.auth_service import AuthService, DuplicateUsernameError

    # Validate password length
    if len(password) < 8:
        click.echo('Error: Password must be at least 8 characters.')
        return

    try:
        user = AuthService.create_user(username, password)
        click.echo(f'Admin user "{user.username}" created successfully.')
    except DuplicateUsernameError:
        click.echo(f'Error: Username "{username}" already exists.')


def register_cli_commands(app):
    """Register CLI commands with the Flask application.

    Args:
        app: The Flask application instance.
    """
    app.cli.add_command(create_admin_command)
```

### __init__.py Update

Add CLI registration to `application/app/__init__.py` (add at end of create_app):

```python
    # Register CLI commands
    from app.cli import register_cli_commands
    register_cli_commands(app)

    return app
```

### conftest.py Update

Add CLI runner fixture to `application/tests/conftest.py`:

```python
@pytest.fixture
def runner(app):
    """Create a CLI test runner."""
    return app.test_cli_runner()
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestCreateAdminCLI:
    """Tests for the create-admin CLI command."""

    def test_create_admin_command_exists(self, runner):
        """Test that create-admin command is registered."""
        result = runner.invoke(args=['create-admin', '--help'])
        assert result.exit_code == 0
        assert 'Create a new admin user' in result.output

    def test_create_admin_success(self, app, runner):
        """Test successful admin user creation via CLI."""
        result = runner.invoke(
            args=['create-admin', 'cliadmin'],
            input='validpassword123\nvalidpassword123\n'
        )
        assert 'created successfully' in result.output

        # Verify user exists in database
        with app.app_context():
            from app.services.auth_service import AuthService
            user = AuthService.get_user_by_username('cliadmin')
            assert user is not None

    def test_create_admin_duplicate_username(self, app, runner):
        """Test that duplicate username shows error."""
        # Create first user
        runner.invoke(
            args=['create-admin', 'duplicate'],
            input='password12345678\npassword12345678\n'
        )

        # Try to create duplicate
        result = runner.invoke(
            args=['create-admin', 'duplicate'],
            input='password12345678\npassword12345678\n'
        )
        assert 'already exists' in result.output

    def test_create_admin_short_password(self, runner):
        """Test that short password is rejected."""
        result = runner.invoke(
            args=['create-admin', 'shortpass'],
            input='short\nshort\n'
        )
        assert 'at least 8 characters' in result.output

    def test_created_admin_can_login(self, app, runner, client):
        """Test that CLI-created admin can log in."""
        runner.invoke(
            args=['create-admin', 'loginableadmin'],
            input='securepassword123\nsecurepassword123\n'
        )

        response = client.post('/auth/login', data={
            'username': 'loginableadmin',
            'password': 'securepassword123'
        }, follow_redirects=False)

        assert response.status_code == 302
        assert '/admin/attendees' in response.location
```

### Verification

```bash
pytest tests/ -v
# Expected: 113 + 5 = 118 tests passing

# Manual CLI test
flask create-admin --help
```

**Commit Message:** `Phase 4.8: Add flask create-admin CLI command`

---

## Final Phase 4 Verification

### Documentation Updates

Update `docs/IMPLEMENTATION-PLAN.md`:
- Change Phase 4 status from `🔲 FUTURE` to `✅ COMPLETE`

### Test Count Progression

| Phase | New Tests | Total |
|-------|-----------|-------|
| Start (Phase 3 complete) | 0 | 74 |
| 4.0 | 0 | 74 |
| 4.1 | +5 | 79 |
| 4.2 | +8 | 87 |
| 4.3 | +3 | 90 |
| 4.4 | +5 | 95 |
| 4.5 | +7 | 102 |
| 4.6 | +6 | 108 |
| 4.7 | +5 | 113 |
| 4.8 | +5 | 118 |

### Git Commit Messages

| Phase | Message |
|-------|---------|
| 4.0 | `Phase 4.0: Add Flask-Login dependency for authentication` |
| 4.1 | `Phase 4.1: Add User model with Werkzeug password hashing` |
| 4.2 | `Phase 4.2: Add AuthService with authenticate and create_user methods` |
| 4.3 | `Phase 4.3: Configure Flask-Login for session management` |
| 4.4 | `Phase 4.4: Add LoginForm with WTForms validation` |
| 4.5 | `Phase 4.5: Add auth blueprint with login/logout routes` |
| 4.6 | `Phase 4.6: Protect admin routes with @login_required` |
| 4.7 | `Phase 4.7: Add security headers middleware` |
| 4.8 | `Phase 4.8: Add flask create-admin CLI command` |

### Final Completion Checklist

After all phases complete:

- [ ] All 118 tests pass
- [ ] 9 git commits (one per phase step)
- [ ] `.phase4-status.json` shows all completed
- [ ] `docs/IMPLEMENTATION-PLAN.md` Phase 4 marked complete
- [ ] Phase 1, 2, and 3 functionality preserved
- [ ] Admin can be created via CLI
- [ ] Admin routes require authentication
- [ ] Security headers present on all responses

### Files Created in Phase 4

```
application/
├── app/
│   ├── cli.py                    (4.8)
│   ├── models/
│   │   └── user.py               (4.1)
│   ├── services/
│   │   └── auth_service.py       (4.2)
│   ├── forms/
│   │   └── login.py              (4.4)
│   ├── routes/
│   │   └── auth.py               (4.5)
│   └── templates/
│       └── auth/
│           └── login.html        (4.5)
├── migrations/versions/
│   └── *_add_user_model.py       (4.1)
└── .phase4-status.json           (4.0)
```

### PRD Requirements Completed

| PRD Reference | Requirement | Status |
|---------------|-------------|--------|
| NFR-003 | Secure Admin Access | Complete (4.5, 4.6) |
| NFR-003 | Password Security | Complete (4.1, 4.2) |
| NFR-003 | Session Management | Complete (4.3) |
| NFR-003 | Security Headers | Complete (4.7) |
| NFR-002 | IaC Compatible Setup | Complete (4.8) |

---

## Deployment Considerations

After completing Phase 4, the deployment should be updated:

1. **Install new dependencies** on the server:
   ```bash
   pip install -r requirements.txt
   ```

2. **Run database migrations** for the User model:
   ```bash
   flask db upgrade
   ```

3. **Create admin user** in production:
   ```bash
   flask create-admin admin
   # Enter secure password when prompted
   ```

4. **Ensure SECRET_KEY is set** in production:
   ```bash
   export SECRET_KEY='your-secure-random-key-here'
   ```

5. **Restart the Flask application** to apply changes.

### Production Security Notes

- Use a strong, randomly generated SECRET_KEY (min 32 characters)
- Use HTTPS in production (HSTS header will be added automatically)
- Store admin credentials securely
- Consider adding rate limiting to login endpoint
- Monitor for failed login attempts
