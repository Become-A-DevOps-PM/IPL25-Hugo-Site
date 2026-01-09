# Phase 3: Full Feature Implementation - Implementation Guide

**Project:** dev-3tier-flask Reference Implementation
**Purpose:** Complete implementation guide for unattended execution of Phase 3
**Created:** 2026-01-08
**Prerequisite:** Phase 2 must be complete (39 tests passing)

---

## Overview

This document provides a complete, self-contained guide for implementing Phase 3 (Full Feature Implementation) of the dev-3tier-flask reference project. It is designed to enable **unattended execution** with the ability to resume from any point.

### What Phase 3 Delivers

Complete PRD functional requirements with production-quality validation and user experience:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE 3 FEATURES                                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. FORM VALIDATION (Server + Client)                                       │
│     • WTForms integration for server-side validation                        │
│     • Field-specific error messages                                         │
│     • Length constraints enforced                                           │
│                                                                             │
│  2. DUPLICATE EMAIL PREVENTION                                              │
│     • Unique constraint on email field                                      │
│     • User-friendly error message                                           │
│     • Database-level enforcement                                            │
│                                                                             │
│  3. WEBINAR INFORMATION PAGE (FR-001)                                       │
│     • Event details display                                                 │
│     • Speaker information                                                   │
│     • Call-to-action to register                                            │
│                                                                             │
│  4. ENHANCED ERROR HANDLING                                                 │
│     • Custom error pages (400, 404, 500)                                    │
│     • Form error display with field highlighting                            │
│     • Flash messages for user feedback                                      │
│                                                                             │
│  5. ADMIN ENHANCEMENTS                                                      │
│     • Sortable attendee list                                                │
│     • Data export (CSV download)                                            │
│     • Registration statistics                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Additive Development** - Never delete Phase 2 code; add new functionality alongside
2. **Layer-by-Layer** - Build from data layer up (Model → Service → Forms → Routes → Templates)
3. **Test-Driven** - Add tests with each step; all tests must pass before proceeding
4. **Git Commits** - One commit per phase step for clear history
5. **PRD Alignment** - Each step traces to specific PRD requirements

### PRD Requirements Addressed

| PRD Reference | Requirement | Phase 3 Step |
|---------------|-------------|--------------|
| FR-001 | Webinar Information Display | 3.4 |
| FR-003 | Data Validation | 3.1, 3.2 |
| US-003 | Form Validation Feedback | 3.1, 3.3 |
| US-004 | Duplicate Prevention | 3.2 |
| US-005 | View Registered Invitees (enhanced) | 3.5, 3.6 |

---

## Execution Framework

### Status Tracking

**Status File:** `.phase3-status.json` (in project root)

```json
{
  "phase": "3",
  "current_step": "3.X",
  "steps": {
    "3.0": { "status": "pending|in_progress|completed", "exercise": "path", "commit": "sha" },
    "3.1": { "status": "pending", "exercise": null, "commit": null },
    "3.2": { "status": "pending", "exercise": null, "commit": null },
    "3.3": { "status": "pending", "exercise": null, "commit": null },
    "3.4": { "status": "pending", "exercise": null, "commit": null },
    "3.5": { "status": "pending", "exercise": null, "commit": null },
    "3.6": { "status": "pending", "exercise": null, "commit": null },
    "3.7": { "status": "pending", "exercise": null, "commit": null }
  },
  "started_at": null,
  "completed_at": null,
  "last_updated": null
}
```

### Exercise Files Location

All exercise markdown files go in: `docs/exercises/`

### Per-Step Workflow

For each step (3.0 through 3.7):

```
1. READ STATUS    → cat .phase3-status.json
2. READ GIT LOG   → git log --oneline -5
3. CREATE EXERCISE → Write docs/exercises/phase-3.X-[name].md
4. IMPLEMENT CODE → Create/modify files as specified
5. RUN TESTS      → cd application && pytest tests/ -v
6. UPDATE STATUS  → Edit .phase3-status.json
7. GIT COMMIT     → git add . && git commit -m "Phase 3.X: [Message]"
8. PROCEED        → Move to next step
```

### Resumption Protocol

When starting/resuming:

1. Read `.phase3-status.json` to find current step
2. Read `git log --oneline -10` for context
3. If current step is "in_progress" → continue it
4. If current step is "completed" → proceed to next
5. If current step is "pending" → start it

### Pre-Implementation Verification

Before starting Phase 3, verify Phase 2 is complete:

```bash
cd application
source .venv/bin/activate
pytest tests/ -v
# Expected: 39 tests passing
```

---

## Phase 3.0: Setup and Dependencies

**Goal:** Add WTForms and update dependencies for Phase 3 features

### Files to Modify

| Action | File |
|--------|------|
| MODIFY | `application/requirements.txt` |
| CREATE | `.phase3-status.json` |
| CREATE | `docs/exercises/phase-3.0-setup-dependencies.md` |

### requirements.txt Additions

Add these lines to `application/requirements.txt`:

```
# Form handling and validation
Flask-WTF==1.2.1
WTForms==3.1.2
email-validator==2.1.0
```

### Install Dependencies

```bash
cd application
source .venv/bin/activate
pip install -r requirements.txt
```

### Create Status File

Create `.phase3-status.json` in project root:

```json
{
  "phase": "3",
  "current_step": "3.0",
  "steps": {
    "3.0": { "status": "in_progress", "exercise": "docs/exercises/phase-3.0-setup-dependencies.md", "commit": null },
    "3.1": { "status": "pending", "exercise": null, "commit": null },
    "3.2": { "status": "pending", "exercise": null, "commit": null },
    "3.3": { "status": "pending", "exercise": null, "commit": null },
    "3.4": { "status": "pending", "exercise": null, "commit": null },
    "3.5": { "status": "pending", "exercise": null, "commit": null },
    "3.6": { "status": "pending", "exercise": null, "commit": null },
    "3.7": { "status": "pending", "exercise": null, "commit": null }
  },
  "started_at": "2026-01-08T00:00:00Z",
  "completed_at": null,
  "last_updated": "2026-01-08T00:00:00Z"
}
```

### Verification

```bash
pytest tests/ -v
# Expected: 39 tests still passing (no functional changes)

python -c "import flask_wtf; import wtforms; print('WTForms installed successfully')"
```

**Exercise File:** `docs/exercises/phase-3.0-setup-dependencies.md`
**Commit Message:** `Phase 3.0: Add WTForms dependencies for form validation`

---

## Phase 3.1: Registration Form with WTForms

**Goal:** Replace HTML form handling with WTForms for server-side validation

### Files to Create/Modify

| Action | File |
|--------|------|
| CREATE | `application/app/forms/__init__.py` |
| CREATE | `application/app/forms/registration.py` |
| MODIFY | `application/app/routes/main.py` |
| MODIFY | `application/app/templates/register.html` |
| MODIFY | `application/app/__init__.py` |
| MODIFY | `application/config.py` |
| MODIFY | `application/tests/test_routes.py` |

### forms/__init__.py Content

```python
"""Form classes for the application."""
from app.forms.registration import RegistrationForm
```

### forms/registration.py Content

```python
"""Registration form with validation."""
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired, Email, Length


class RegistrationForm(FlaskForm):
    """Form for webinar registration with validation.

    Validates:
    - name: 2-100 characters, required
    - email: valid email format, required
    - company: 2-100 characters, required
    - job_title: 2-100 characters, required
    """

    name = StringField('Full Name', validators=[
        DataRequired(message='Name is required.'),
        Length(min=2, max=100, message='Name must be between 2 and 100 characters.')
    ])

    email = StringField('Email Address', validators=[
        DataRequired(message='Email is required.'),
        Email(message='Please enter a valid email address.'),
        Length(max=120, message='Email must be less than 120 characters.')
    ])

    company = StringField('Company', validators=[
        DataRequired(message='Company is required.'),
        Length(min=2, max=100, message='Company must be between 2 and 100 characters.')
    ])

    job_title = StringField('Job Title', validators=[
        DataRequired(message='Job title is required.'),
        Length(min=2, max=100, message='Job title must be between 2 and 100 characters.')
    ])

    submit = SubmitField('Complete Registration')
```

### config.py Update

Add SECRET_KEY configuration to each config class. Update `application/config.py`:

```python
"""Application configuration."""
import os


class Config:
    """Base configuration shared by all environments."""
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
    WTF_CSRF_ENABLED = True


class DevelopmentConfig(Config):
    """Development configuration with SQLite."""
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///local.db'


class ProductionConfig(Config):
    """Production configuration with PostgreSQL."""
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SECRET_KEY = os.environ.get('SECRET_KEY')  # Must be set in production


class TestingConfig(Config):
    """Testing configuration with in-memory SQLite."""
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    WTF_CSRF_ENABLED = False  # Disable CSRF for testing


config_map = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig
}
```

### main.py Content (Full Replacement)

```python
"""Main blueprint for the landing page and registration.

This blueprint serves the application landing page and registration
form for the webinar signup feature.
"""
from flask import Blueprint, render_template, redirect, url_for, flash
from app.forms.registration import RegistrationForm
from app.services.registration_service import RegistrationService

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
        RegistrationService.create_registration(
            name=form.name.data,
            email=form.email.data,
            company=form.company.data,
            job_title=form.job_title.data
        )
        flash('Registration successful!', 'success')
        return redirect(url_for('main.thank_you'))

    return render_template('register.html', form=form)


@main_bp.route('/thank-you')
def thank_you():
    """Display registration confirmation."""
    return render_template('thank_you.html')
```

### register.html Content (Full Replacement)

```html
{% extends "base.html" %}

{% block title %}Register for Webinar{% endblock %}

{% block content %}
<div class="register-page">
    <h1>Register for Our Webinar</h1>
    <p>Fill out the form below to reserve your spot.</p>

    <form method="POST" action="{{ url_for('main.register') }}" class="registration-form" novalidate>
        {{ form.hidden_tag() }}

        <div class="form-group {% if form.name.errors %}has-error{% endif %}">
            {{ form.name.label }}
            {{ form.name(placeholder='John Doe', class='form-control') }}
            {% if form.name.errors %}
                <ul class="errors">
                {% for error in form.name.errors %}
                    <li class="error-message">{{ error }}</li>
                {% endfor %}
                </ul>
            {% endif %}
        </div>

        <div class="form-group {% if form.email.errors %}has-error{% endif %}">
            {{ form.email.label }}
            {{ form.email(placeholder='john@example.com', class='form-control') }}
            {% if form.email.errors %}
                <ul class="errors">
                {% for error in form.email.errors %}
                    <li class="error-message">{{ error }}</li>
                {% endfor %}
                </ul>
            {% endif %}
        </div>

        <div class="form-group {% if form.company.errors %}has-error{% endif %}">
            {{ form.company.label }}
            {{ form.company(placeholder='Acme Corp', class='form-control') }}
            {% if form.company.errors %}
                <ul class="errors">
                {% for error in form.company.errors %}
                    <li class="error-message">{{ error }}</li>
                {% endfor %}
                </ul>
            {% endif %}
        </div>

        <div class="form-group {% if form.job_title.errors %}has-error{% endif %}">
            {{ form.job_title.label }}
            {{ form.job_title(placeholder='Software Developer', class='form-control') }}
            {% if form.job_title.errors %}
                <ul class="errors">
                {% for error in form.job_title.errors %}
                    <li class="error-message">{{ error }}</li>
                {% endfor %}
                </ul>
            {% endif %}
        </div>

        <div class="form-actions">
            {{ form.submit(class='btn btn-primary') }}
        </div>
    </form>

    <p class="back-link"><a href="{{ url_for('main.index') }}">← Back to home</a></p>
</div>
{% endblock %}
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestFormValidation:
    """Tests for WTForms validation on registration."""

    def test_register_rejects_empty_name(self, client):
        """Test that empty name is rejected with error message."""
        response = client.post('/register', data={
            'name': '',
            'email': 'test@example.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        })
        assert response.status_code == 200  # Returns form with errors
        assert b'Name is required' in response.data

    def test_register_rejects_short_name(self, client):
        """Test that name shorter than 2 chars is rejected."""
        response = client.post('/register', data={
            'name': 'A',
            'email': 'test@example.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        })
        assert response.status_code == 200
        assert b'must be between 2 and 100 characters' in response.data

    def test_register_rejects_invalid_email(self, client):
        """Test that invalid email format is rejected."""
        response = client.post('/register', data={
            'name': 'Test User',
            'email': 'not-an-email',
            'company': 'Test Corp',
            'job_title': 'Developer'
        })
        assert response.status_code == 200
        assert b'valid email address' in response.data

    def test_register_rejects_empty_company(self, client):
        """Test that empty company is rejected."""
        response = client.post('/register', data={
            'name': 'Test User',
            'email': 'test@example.com',
            'company': '',
            'job_title': 'Developer'
        })
        assert response.status_code == 200
        assert b'Company is required' in response.data

    def test_register_rejects_empty_job_title(self, client):
        """Test that empty job title is rejected."""
        response = client.post('/register', data={
            'name': 'Test User',
            'email': 'test@example.com',
            'company': 'Test Corp',
            'job_title': ''
        })
        assert response.status_code == 200
        assert b'Job title is required' in response.data

    def test_register_accepts_valid_data(self, client):
        """Test that valid data is accepted and redirects."""
        response = client.post('/register', data={
            'name': 'Valid User',
            'email': 'valid@example.com',
            'company': 'Valid Corp',
            'job_title': 'Developer'
        }, follow_redirects=False)
        assert response.status_code == 302
        assert '/thank-you' in response.location

    def test_register_shows_multiple_errors(self, client):
        """Test that multiple validation errors are shown."""
        response = client.post('/register', data={
            'name': '',
            'email': 'invalid',
            'company': '',
            'job_title': ''
        })
        assert response.status_code == 200
        assert b'Name is required' in response.data
        assert b'valid email address' in response.data
        assert b'Company is required' in response.data
        assert b'Job title is required' in response.data
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 39 + 7 = 46 tests passing
```

**Exercise File:** `docs/exercises/phase-3.1-wtforms-validation.md`
**Commit Message:** `Phase 3.1: Add WTForms validation for registration`

---

## Phase 3.2: Duplicate Email Prevention

**Goal:** Add unique constraint on email and handle duplicate registration attempts

### Files to Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/models/registration.py` |
| MODIFY | `application/app/services/registration_service.py` |
| MODIFY | `application/app/routes/main.py` |
| CREATE | `application/migrations/versions/*_add_email_unique.py` |
| MODIFY | `application/tests/test_routes.py` |

### registration.py Model Update

Update `application/app/models/registration.py`:

```python
"""Registration model for webinar signups."""
from datetime import datetime, timezone
from app.extensions import db


class Registration(db.Model):
    """Webinar registration with attendee information."""

    __tablename__ = 'registrations'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False, unique=True, index=True)
    company = db.Column(db.String(100), nullable=False)
    job_title = db.Column(db.String(100), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    def __repr__(self):
        return f'<Registration {self.email}>'

    def to_dict(self):
        """Convert registration to dictionary for JSON serialization."""
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'company': self.company,
            'job_title': self.job_title,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
```

### registration_service.py Update

Update `application/app/services/registration_service.py`:

```python
"""Business logic for webinar registrations."""
from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.registration import Registration


class DuplicateEmailError(Exception):
    """Raised when attempting to register with an existing email."""
    pass


class RegistrationService:
    """Service layer for registration operations."""

    @staticmethod
    def create_registration(name, email, company, job_title):
        """Create a new webinar registration.

        Args:
            name: Attendee's full name
            email: Attendee's email address (must be unique)
            company: Attendee's company name
            job_title: Attendee's job title

        Returns:
            Registration: The created registration object

        Raises:
            DuplicateEmailError: If email is already registered
        """
        registration = Registration(
            name=name,
            email=email.lower().strip(),  # Normalize email
            company=company,
            job_title=job_title
        )
        try:
            db.session.add(registration)
            db.session.commit()
            return registration
        except IntegrityError:
            db.session.rollback()
            raise DuplicateEmailError(f"Email '{email}' is already registered.")

    @staticmethod
    def get_all_registrations():
        """Get all registrations ordered by creation date."""
        return Registration.query.order_by(Registration.created_at.desc()).all()

    @staticmethod
    def get_registration_count():
        """Get total count of registrations."""
        return Registration.query.count()

    @staticmethod
    def email_exists(email):
        """Check if an email is already registered.

        Args:
            email: Email address to check

        Returns:
            bool: True if email exists, False otherwise
        """
        normalized_email = email.lower().strip()
        return Registration.query.filter_by(email=normalized_email).first() is not None
```

### main.py Update (register function only)

Update the `register` function in `application/app/routes/main.py`:

```python
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
```

Also add the import at the top of main.py:

```python
from app.services.registration_service import RegistrationService, DuplicateEmailError
```

### Generate Migration

```bash
cd application
source .venv/bin/activate
flask db migrate -m "Add unique constraint to registration email"
flask db upgrade
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestDuplicateEmailPrevention:
    """Tests for duplicate email prevention."""

    def test_duplicate_email_rejected(self, app, client):
        """Test that duplicate email registration is rejected."""
        # First registration
        client.post('/register', data={
            'name': 'First User',
            'email': 'duplicate@test.com',
            'company': 'First Corp',
            'job_title': 'Developer'
        })

        # Second registration with same email
        response = client.post('/register', data={
            'name': 'Second User',
            'email': 'duplicate@test.com',
            'company': 'Second Corp',
            'job_title': 'Manager'
        })

        assert response.status_code == 200  # Returns form with error
        assert b'already registered' in response.data

    def test_duplicate_email_case_insensitive(self, app, client):
        """Test that email uniqueness is case-insensitive."""
        # First registration with lowercase
        client.post('/register', data={
            'name': 'First User',
            'email': 'test@example.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        })

        # Second registration with uppercase
        response = client.post('/register', data={
            'name': 'Second User',
            'email': 'TEST@EXAMPLE.COM',
            'company': 'Test Corp',
            'job_title': 'Developer'
        })

        assert response.status_code == 200
        assert b'already registered' in response.data

    def test_different_emails_allowed(self, app, client):
        """Test that different emails can register."""
        # First registration
        response1 = client.post('/register', data={
            'name': 'First User',
            'email': 'first@test.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        }, follow_redirects=False)
        assert response1.status_code == 302

        # Second registration with different email
        response2 = client.post('/register', data={
            'name': 'Second User',
            'email': 'second@test.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        }, follow_redirects=False)
        assert response2.status_code == 302

    def test_email_exists_service_method(self, app):
        """Test the email_exists service method."""
        with app.app_context():
            from app.services.registration_service import RegistrationService

            # Initially no email exists
            assert not RegistrationService.email_exists('new@test.com')

            # Create registration
            RegistrationService.create_registration(
                name='Test', email='exists@test.com',
                company='Corp', job_title='Dev'
            )

            # Now email exists
            assert RegistrationService.email_exists('exists@test.com')
            assert RegistrationService.email_exists('EXISTS@TEST.COM')  # Case-insensitive
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 46 + 4 = 50 tests passing
```

**Exercise File:** `docs/exercises/phase-3.2-duplicate-email-prevention.md`
**Commit Message:** `Phase 3.2: Add duplicate email prevention with unique constraint`

---

## Phase 3.3: Enhanced Error Styling and Flash Messages

**Goal:** Add CSS styling for form errors and flash message support

### Files to Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/templates/base.html` |
| MODIFY | `application/app/static/css/style.css` |
| MODIFY | `application/tests/test_routes.py` |

### base.html Update

Update `application/app/templates/base.html` to include flash message display:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}Flask App{% endblock %}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
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
        </div>
    </nav>

    <main class="container">
        {% with messages = get_flashed_messages(with_categories=true) %}
            {% if messages %}
                <div class="flash-messages">
                    {% for category, message in messages %}
                        <div class="flash flash-{{ category }}">
                            {{ message }}
                            <button type="button" class="flash-close" onclick="this.parentElement.remove()">×</button>
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
</body>
</html>
```

### style.css Additions

Add to `application/app/static/css/style.css`:

```css
/* ===== Flash Messages ===== */
.flash-messages {
    margin-bottom: 1.5rem;
}

.flash {
    padding: 1rem 2.5rem 1rem 1rem;
    border-radius: 4px;
    margin-bottom: 0.5rem;
    position: relative;
    border: 1px solid transparent;
}

.flash-success {
    background-color: #d4edda;
    border-color: #c3e6cb;
    color: #155724;
}

.flash-error {
    background-color: #f8d7da;
    border-color: #f5c6cb;
    color: #721c24;
}

.flash-warning {
    background-color: #fff3cd;
    border-color: #ffeeba;
    color: #856404;
}

.flash-info {
    background-color: #d1ecf1;
    border-color: #bee5eb;
    color: #0c5460;
}

.flash-close {
    position: absolute;
    top: 0.5rem;
    right: 0.75rem;
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    opacity: 0.5;
    line-height: 1;
}

.flash-close:hover {
    opacity: 1;
}

/* ===== Form Error Styling ===== */
.form-group {
    margin-bottom: 1.25rem;
}

.form-group.has-error input,
.form-group.has-error select,
.form-group.has-error textarea {
    border-color: #dc3545;
    background-color: #fff8f8;
}

.form-group.has-error label {
    color: #dc3545;
}

.errors {
    list-style: none;
    padding: 0;
    margin: 0.25rem 0 0 0;
}

.error-message {
    color: #dc3545;
    font-size: 0.875rem;
    margin-top: 0.25rem;
}

/* ===== Form Controls ===== */
.form-control {
    width: 100%;
    padding: 0.5rem 0.75rem;
    font-size: 1rem;
    line-height: 1.5;
    border: 1px solid #ced4da;
    border-radius: 4px;
    transition: border-color 0.15s ease-in-out;
}

.form-control:focus {
    border-color: #80bdff;
    outline: 0;
    box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

/* ===== Navigation ===== */
.navbar {
    background-color: #343a40;
    padding: 1rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.nav-brand a {
    color: white;
    text-decoration: none;
    font-size: 1.25rem;
    font-weight: bold;
}

.nav-links a {
    color: rgba(255, 255, 255, 0.8);
    text-decoration: none;
    margin-left: 1.5rem;
}

.nav-links a:hover {
    color: white;
}

/* ===== Footer ===== */
.footer {
    background-color: #f8f9fa;
    padding: 1.5rem;
    text-align: center;
    margin-top: 3rem;
    border-top: 1px solid #e9ecef;
}

/* ===== Container ===== */
.container {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem 1rem;
}
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestFlashMessages:
    """Tests for flash message display."""

    def test_success_flash_on_registration(self, client):
        """Test that success flash appears after registration."""
        response = client.post('/register', data={
            'name': 'Flash Test User',
            'email': 'flash@test.com',
            'company': 'Flash Corp',
            'job_title': 'Developer'
        }, follow_redirects=True)

        assert response.status_code == 200
        assert b'Registration successful' in response.data

    def test_form_preserves_input_on_error(self, client):
        """Test that form preserves input when validation fails."""
        response = client.post('/register', data={
            'name': 'Preserved Name',
            'email': 'invalid-email',
            'company': 'Preserved Company',
            'job_title': 'Preserved Title'
        })

        assert response.status_code == 200
        assert b'Preserved Name' in response.data
        assert b'Preserved Company' in response.data
        assert b'Preserved Title' in response.data
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 50 + 2 = 52 tests passing
```

**Exercise File:** `docs/exercises/phase-3.3-error-styling-flash-messages.md`
**Commit Message:** `Phase 3.3: Add error styling and flash message support`

---

## Phase 3.4: Webinar Information Page (FR-001)

**Goal:** Create dedicated webinar information page per PRD FR-001

### Files to Create/Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/routes/main.py` |
| CREATE | `application/app/templates/webinar_info.html` |
| MODIFY | `application/app/templates/landing.html` |
| MODIFY | `application/tests/test_routes.py` |

### main.py Addition

Add new route to `application/app/routes/main.py`:

```python
@main_bp.route('/webinar')
def webinar_info():
    """Display webinar information page.

    Shows event details including topic, date, time, agenda,
    and speaker information as required by FR-001.
    """
    return render_template('webinar_info.html')
```

### webinar_info.html Content

Create `application/app/templates/webinar_info.html`:

```html
{% extends "base.html" %}

{% block title %}About the Webinar{% endblock %}

{% block content %}
<div class="webinar-info-page">
    <header class="webinar-header">
        <h1>Cloud Infrastructure Fundamentals</h1>
        <p class="subtitle">A hands-on introduction to modern deployment practices</p>
    </header>

    <section class="event-details">
        <h2>Event Details</h2>
        <div class="details-grid">
            <div class="detail-item">
                <span class="detail-label">Date</span>
                <span class="detail-value">February 15, 2026</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Time</span>
                <span class="detail-value">10:00 AM - 12:00 PM CET</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Platform</span>
                <span class="detail-value">Microsoft Teams (link sent after registration)</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Cost</span>
                <span class="detail-value">Free</span>
            </div>
        </div>
    </section>

    <section class="agenda">
        <h2>Agenda</h2>
        <ol class="agenda-list">
            <li>
                <strong>Introduction to Cloud Infrastructure</strong>
                <span class="duration">(20 min)</span>
                <p>Understanding the fundamentals of cloud computing and Azure services.</p>
            </li>
            <li>
                <strong>Infrastructure as Code with Bicep</strong>
                <span class="duration">(30 min)</span>
                <p>Learn how to define and deploy infrastructure using declarative templates.</p>
            </li>
            <li>
                <strong>Flask Application Deployment</strong>
                <span class="duration">(30 min)</span>
                <p>Hands-on demonstration of deploying a Python web application to Azure.</p>
            </li>
            <li>
                <strong>Best Practices & Q&A</strong>
                <span class="duration">(40 min)</span>
                <p>Security considerations, monitoring, and audience questions.</p>
            </li>
        </ol>
    </section>

    <section class="speakers">
        <h2>Speakers</h2>
        <div class="speaker-cards">
            <div class="speaker-card">
                <div class="speaker-info">
                    <h3>Dr. Sarah Chen</h3>
                    <p class="speaker-title">Cloud Solutions Architect</p>
                    <p class="speaker-bio">
                        Sarah has 15 years of experience in cloud infrastructure and has helped
                        hundreds of organizations migrate to Azure. She holds multiple Azure
                        certifications and is a frequent speaker at tech conferences.
                    </p>
                </div>
            </div>
            <div class="speaker-card">
                <div class="speaker-info">
                    <h3>Marcus Johnson</h3>
                    <p class="speaker-title">Senior DevOps Engineer</p>
                    <p class="speaker-bio">
                        Marcus specializes in CI/CD pipelines and infrastructure automation.
                        He has authored several open-source tools for Azure deployment and
                        teaches DevOps practices at technical universities.
                    </p>
                </div>
            </div>
        </div>
    </section>

    <section class="what-youll-learn">
        <h2>What You'll Learn</h2>
        <ul class="learning-outcomes">
            <li>How to provision cloud resources using Infrastructure as Code</li>
            <li>Best practices for Flask application deployment</li>
            <li>Security fundamentals for web applications</li>
            <li>Monitoring and observability strategies</li>
            <li>Cost optimization techniques for cloud infrastructure</li>
        </ul>
    </section>

    <section class="cta-section">
        <h2>Ready to Join?</h2>
        <p>Reserve your spot now and take the first step towards mastering cloud infrastructure.</p>
        <a href="{{ url_for('main.register') }}" class="btn btn-primary btn-lg">Register Now</a>
    </section>

    <p class="back-link"><a href="{{ url_for('main.index') }}">← Back to home</a></p>
</div>
{% endblock %}
```

### landing.html Update

Update `application/app/templates/landing.html` to link to webinar info:

```html
{% extends "base.html" %}

{% block title %}Webinar Registration - Welcome{% endblock %}

{% block content %}
<div class="hero">
    <h1>Join Our Upcoming Webinar</h1>
    <p class="lead">Learn about cloud infrastructure and modern deployment practices from industry experts.</p>
    <div class="cta-section">
        <a href="{{ url_for('main.register') }}" class="btn btn-primary btn-lg">Register Now</a>
        <a href="{{ url_for('main.webinar_info') }}" class="btn btn-secondary btn-lg">Learn More</a>
    </div>
</div>

<div class="features">
    <h2>What You'll Learn</h2>
    <ul>
        <li>Modern infrastructure as code practices</li>
        <li>Azure deployment strategies</li>
        <li>Best practices for Flask applications</li>
    </ul>
</div>

<div class="demo-link">
    <p><small>Looking for the Phase 1 demo? <a href="{{ url_for('demo.index') }}">Visit the demo page</a></small></p>
</div>
{% endblock %}
```

### Additional CSS

Add to `application/app/static/css/style.css`:

```css
/* ===== Webinar Info Page ===== */
.webinar-info-page {
    max-width: 900px;
    margin: 0 auto;
}

.webinar-header {
    text-align: center;
    margin-bottom: 2.5rem;
    padding-bottom: 1.5rem;
    border-bottom: 2px solid #e9ecef;
}

.webinar-header h1 {
    font-size: 2.5rem;
    margin-bottom: 0.5rem;
}

.subtitle {
    font-size: 1.25rem;
    color: #6c757d;
}

.event-details {
    margin-bottom: 2.5rem;
}

.details-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    background: #f8f9fa;
    padding: 1.5rem;
    border-radius: 8px;
}

.detail-item {
    display: flex;
    flex-direction: column;
}

.detail-label {
    font-weight: bold;
    color: #495057;
    font-size: 0.875rem;
    text-transform: uppercase;
    margin-bottom: 0.25rem;
}

.detail-value {
    font-size: 1.1rem;
}

.agenda {
    margin-bottom: 2.5rem;
}

.agenda-list {
    list-style: none;
    padding: 0;
    counter-reset: agenda-counter;
}

.agenda-list li {
    padding: 1.25rem;
    margin-bottom: 1rem;
    background: #fff;
    border-left: 4px solid #007bff;
    border-radius: 0 8px 8px 0;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.agenda-list li strong {
    display: block;
    font-size: 1.1rem;
    margin-bottom: 0.25rem;
}

.duration {
    color: #6c757d;
    font-size: 0.875rem;
}

.agenda-list li p {
    margin: 0.5rem 0 0 0;
    color: #495057;
}

.speakers {
    margin-bottom: 2.5rem;
}

.speaker-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 1.5rem;
}

.speaker-card {
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    overflow: hidden;
}

.speaker-info {
    padding: 1.5rem;
}

.speaker-info h3 {
    margin: 0 0 0.25rem 0;
}

.speaker-title {
    color: #007bff;
    font-weight: 500;
    margin-bottom: 0.75rem;
}

.speaker-bio {
    color: #495057;
    font-size: 0.95rem;
    line-height: 1.6;
}

.what-youll-learn {
    margin-bottom: 2.5rem;
}

.learning-outcomes {
    display: grid;
    gap: 0.75rem;
}

.learning-outcomes li {
    padding: 0.75rem 1rem;
    background: #e7f3ff;
    border-radius: 4px;
    color: #004085;
}

.cta-section {
    text-align: center;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 3rem 2rem;
    border-radius: 12px;
    margin: 2rem 0;
}

.cta-section h2 {
    color: white;
    margin-bottom: 0.5rem;
}

.cta-section p {
    margin-bottom: 1.5rem;
    opacity: 0.9;
}

/* ===== Buttons ===== */
.btn {
    display: inline-block;
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
    font-weight: 500;
    text-decoration: none;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.15s ease-in-out;
    border: none;
}

.btn-primary {
    background-color: #007bff;
    color: white;
}

.btn-primary:hover {
    background-color: #0056b3;
}

.btn-secondary {
    background-color: #6c757d;
    color: white;
}

.btn-secondary:hover {
    background-color: #545b62;
}

.btn-lg {
    padding: 1rem 2rem;
    font-size: 1.1rem;
}

.hero .cta-section {
    display: flex;
    gap: 1rem;
    justify-content: center;
    flex-wrap: wrap;
}
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestWebinarInfoPage:
    """Tests for the webinar information page (FR-001)."""

    def test_webinar_info_page_loads(self, client):
        """Test that webinar info page loads successfully."""
        response = client.get('/webinar')
        assert response.status_code == 200

    def test_webinar_info_has_title(self, client):
        """Test that webinar info page has event title."""
        response = client.get('/webinar')
        assert b'Cloud Infrastructure Fundamentals' in response.data

    def test_webinar_info_has_date_time(self, client):
        """Test that webinar info page shows date and time."""
        response = client.get('/webinar')
        assert b'February 15, 2026' in response.data
        assert b'10:00 AM' in response.data

    def test_webinar_info_has_agenda(self, client):
        """Test that webinar info page includes agenda."""
        response = client.get('/webinar')
        assert b'Agenda' in response.data
        assert b'Infrastructure as Code' in response.data

    def test_webinar_info_has_speakers(self, client):
        """Test that webinar info page shows speakers."""
        response = client.get('/webinar')
        assert b'Speakers' in response.data
        assert b'Sarah Chen' in response.data
        assert b'Marcus Johnson' in response.data

    def test_webinar_info_has_register_link(self, client):
        """Test that webinar info page links to registration."""
        response = client.get('/webinar')
        assert b'/register' in response.data
        assert b'Register Now' in response.data

    def test_landing_page_links_to_webinar_info(self, client):
        """Test that landing page links to webinar info."""
        response = client.get('/')
        assert b'/webinar' in response.data
        assert b'Learn More' in response.data
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 52 + 7 = 59 tests passing
```

**Exercise File:** `docs/exercises/phase-3.4-webinar-info-page.md`
**Commit Message:** `Phase 3.4: Add webinar information page (FR-001)`

---

## Phase 3.5: Admin Enhancements - Sorting and Statistics

**Goal:** Enhance admin dashboard with sorting and statistics

### Files to Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/services/registration_service.py` |
| MODIFY | `application/app/routes/admin.py` |
| MODIFY | `application/app/templates/admin/attendees.html` |
| MODIFY | `application/tests/test_routes.py` |

### registration_service.py Additions

Add to `application/app/services/registration_service.py`:

```python
    @staticmethod
    def get_registrations_sorted(sort_by='created_at', order='desc'):
        """Get registrations with sorting options.

        Args:
            sort_by: Field to sort by (name, email, company, job_title, created_at)
            order: Sort order ('asc' or 'desc')

        Returns:
            List of Registration objects
        """
        valid_columns = ['name', 'email', 'company', 'job_title', 'created_at']
        if sort_by not in valid_columns:
            sort_by = 'created_at'

        column = getattr(Registration, sort_by)
        if order == 'asc':
            return Registration.query.order_by(column.asc()).all()
        return Registration.query.order_by(column.desc()).all()

    @staticmethod
    def get_registration_stats():
        """Get registration statistics.

        Returns:
            dict: Statistics including total count and registrations by date
        """
        from sqlalchemy import func

        total = Registration.query.count()

        # Registrations grouped by date
        by_date = db.session.query(
            func.date(Registration.created_at).label('date'),
            func.count(Registration.id).label('count')
        ).group_by(func.date(Registration.created_at)).order_by(
            func.date(Registration.created_at).desc()
        ).limit(7).all()

        return {
            'total': total,
            'by_date': [{'date': str(d.date), 'count': d.count} for d in by_date]
        }
```

### admin.py Update

Update `application/app/routes/admin.py`:

```python
"""Admin blueprint for managing registrations.

Note: No authentication in Phase 3. Routes are publicly accessible.
Authentication will be added in Phase 4.
"""
from flask import Blueprint, render_template, request
from app.services.registration_service import RegistrationService

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')


@admin_bp.route('/attendees')
def attendees():
    """Display list of all webinar registrations with sorting.

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
```

### admin/attendees.html Update

Update `application/app/templates/admin/attendees.html`:

```html
{% extends "base.html" %}

{% block title %}Admin - Attendees{% endblock %}

{% block content %}
<div class="admin-page">
    <h1>Webinar Attendees</h1>

    <div class="stats-panel">
        <div class="stat-card stat-primary">
            <span class="stat-value">{{ stats.total }}</span>
            <span class="stat-label">Total Registrations</span>
        </div>
        {% if stats.by_date %}
        <div class="stat-card">
            <span class="stat-value">{{ stats.by_date[0].count if stats.by_date else 0 }}</span>
            <span class="stat-label">Today</span>
        </div>
        {% endif %}
    </div>

    {% if registrations %}
    <div class="table-controls">
        <p class="result-count">Showing {{ registrations|length }} registrations</p>
        <a href="{{ url_for('admin.export_csv') }}" class="btn btn-secondary btn-sm">Export CSV</a>
    </div>

    <table class="attendees-table sortable">
        <thead>
            <tr>
                <th>
                    <a href="?sort=name&order={{ next_order if current_sort == 'name' else 'asc' }}"
                       class="sort-link {% if current_sort == 'name' %}active {{ current_order }}{% endif %}">
                        Name
                        <span class="sort-indicator"></span>
                    </a>
                </th>
                <th>
                    <a href="?sort=email&order={{ next_order if current_sort == 'email' else 'asc' }}"
                       class="sort-link {% if current_sort == 'email' %}active {{ current_order }}{% endif %}">
                        Email
                        <span class="sort-indicator"></span>
                    </a>
                </th>
                <th>
                    <a href="?sort=company&order={{ next_order if current_sort == 'company' else 'asc' }}"
                       class="sort-link {% if current_sort == 'company' %}active {{ current_order }}{% endif %}">
                        Company
                        <span class="sort-indicator"></span>
                    </a>
                </th>
                <th>
                    <a href="?sort=job_title&order={{ next_order if current_sort == 'job_title' else 'asc' }}"
                       class="sort-link {% if current_sort == 'job_title' %}active {{ current_order }}{% endif %}">
                        Job Title
                        <span class="sort-indicator"></span>
                    </a>
                </th>
                <th>
                    <a href="?sort=created_at&order={{ next_order if current_sort == 'created_at' else 'desc' }}"
                       class="sort-link {% if current_sort == 'created_at' %}active {{ current_order }}{% endif %}">
                        Registered
                        <span class="sort-indicator"></span>
                    </a>
                </th>
            </tr>
        </thead>
        <tbody>
            {% for reg in registrations %}
            <tr>
                <td>{{ reg.name }}</td>
                <td>{{ reg.email }}</td>
                <td>{{ reg.company }}</td>
                <td>{{ reg.job_title }}</td>
                <td>{{ reg.created_at.strftime('%Y-%m-%d %H:%M') }}</td>
            </tr>
            {% endfor %}
        </tbody>
    </table>
    {% else %}
    <div class="empty-state">
        <p>No registrations yet.</p>
        <p><a href="{{ url_for('main.index') }}">Share the registration link</a> to get attendees.</p>
    </div>
    {% endif %}

    <div class="admin-nav">
        <a href="{{ url_for('main.index') }}">← Back to Home</a>
    </div>
</div>
{% endblock %}
```

### Additional CSS

Add to `application/app/static/css/style.css`:

```css
/* ===== Admin Stats Panel ===== */
.stats-panel {
    display: flex;
    gap: 1rem;
    margin-bottom: 1.5rem;
    flex-wrap: wrap;
}

.stat-card {
    background: #fff;
    border: 1px solid #e9ecef;
    border-radius: 8px;
    padding: 1.25rem 1.5rem;
    min-width: 150px;
    text-align: center;
}

.stat-card.stat-primary {
    background: #007bff;
    color: white;
    border-color: #007bff;
}

.stat-value {
    display: block;
    font-size: 2rem;
    font-weight: bold;
    line-height: 1.2;
}

.stat-label {
    display: block;
    font-size: 0.875rem;
    opacity: 0.8;
    margin-top: 0.25rem;
}

/* ===== Sortable Table ===== */
.table-controls {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
}

.result-count {
    color: #6c757d;
    margin: 0;
}

.btn-sm {
    padding: 0.375rem 0.75rem;
    font-size: 0.875rem;
}

.attendees-table {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.attendees-table th,
.attendees-table td {
    padding: 0.75rem 1rem;
    text-align: left;
    border-bottom: 1px solid #e9ecef;
}

.attendees-table th {
    background: #f8f9fa;
    font-weight: 600;
}

.attendees-table tbody tr:hover {
    background: #f8f9fa;
}

.sort-link {
    color: inherit;
    text-decoration: none;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.sort-link:hover {
    color: #007bff;
}

.sort-indicator::after {
    content: '⇅';
    opacity: 0.3;
}

.sort-link.active .sort-indicator::after {
    opacity: 1;
}

.sort-link.active.asc .sort-indicator::after {
    content: '↑';
}

.sort-link.active.desc .sort-indicator::after {
    content: '↓';
}

/* ===== Empty State ===== */
.empty-state {
    text-align: center;
    padding: 3rem;
    background: #f8f9fa;
    border-radius: 8px;
    color: #6c757d;
}
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestAdminSorting:
    """Tests for admin attendee list sorting."""

    def test_admin_default_sort_by_date_desc(self, app, client):
        """Test default sort is by created_at descending."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            import time

            RegistrationService.create_registration(
                name='First User', email='first@test.com',
                company='Corp', job_title='Dev'
            )
            time.sleep(0.1)  # Ensure different timestamps
            RegistrationService.create_registration(
                name='Second User', email='second@test.com',
                company='Corp', job_title='Dev'
            )

        response = client.get('/admin/attendees')
        # Second should appear before First (desc order)
        second_pos = response.data.find(b'Second User')
        first_pos = response.data.find(b'First User')
        assert second_pos < first_pos

    def test_admin_sort_by_name_asc(self, app, client):
        """Test sorting by name ascending."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            RegistrationService.create_registration(
                name='Zoe', email='zoe@test.com',
                company='Corp', job_title='Dev'
            )
            RegistrationService.create_registration(
                name='Alice', email='alice@test.com',
                company='Corp', job_title='Dev'
            )

        response = client.get('/admin/attendees?sort=name&order=asc')
        alice_pos = response.data.find(b'Alice')
        zoe_pos = response.data.find(b'Zoe')
        assert alice_pos < zoe_pos

    def test_admin_shows_stats(self, app, client):
        """Test that admin page shows statistics."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            for i in range(3):
                RegistrationService.create_registration(
                    name=f'User {i}', email=f'user{i}@test.com',
                    company='Corp', job_title='Dev'
                )

        response = client.get('/admin/attendees')
        assert b'Total Registrations' in response.data

    def test_admin_has_export_link(self, client, app):
        """Test that admin page has export CSV link when registrations exist."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            RegistrationService.create_registration(
                name='Export Test', email='export@test.com',
                company='Corp', job_title='Dev'
            )

        response = client.get('/admin/attendees')
        assert b'Export CSV' in response.data
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 59 + 4 = 63 tests passing
```

**Exercise File:** `docs/exercises/phase-3.5-admin-sorting-stats.md`
**Commit Message:** `Phase 3.5: Add admin sorting and statistics`

---

## Phase 3.6: Data Export - CSV Download

**Goal:** Add CSV export functionality for registration data

### Files to Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/routes/admin.py` |
| MODIFY | `application/tests/test_routes.py` |

### admin.py Addition

Add export route to `application/app/routes/admin.py`:

```python
from flask import Blueprint, render_template, request, Response
from datetime import datetime
import csv
import io
from app.services.registration_service import RegistrationService

# ... existing code ...

@admin_bp.route('/export/csv')
def export_csv():
    """Export all registrations as CSV file.

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

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestCSVExport:
    """Tests for CSV export functionality."""

    def test_export_csv_returns_csv_content_type(self, client):
        """Test that export returns CSV content type."""
        response = client.get('/admin/export/csv')
        assert response.status_code == 200
        assert 'text/csv' in response.content_type

    def test_export_csv_has_attachment_header(self, client):
        """Test that export has attachment filename header."""
        response = client.get('/admin/export/csv')
        assert 'attachment' in response.headers.get('Content-Disposition', '')
        assert 'webinar-registrations' in response.headers.get('Content-Disposition', '')
        assert '.csv' in response.headers.get('Content-Disposition', '')

    def test_export_csv_contains_headers(self, client):
        """Test that CSV contains column headers."""
        response = client.get('/admin/export/csv')
        csv_content = response.data.decode('utf-8')
        assert 'ID' in csv_content
        assert 'Name' in csv_content
        assert 'Email' in csv_content
        assert 'Company' in csv_content
        assert 'Job Title' in csv_content
        assert 'Registered At' in csv_content

    def test_export_csv_contains_data(self, app, client):
        """Test that CSV contains registration data."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            RegistrationService.create_registration(
                name='CSV Export Test',
                email='csvtest@example.com',
                company='Export Corp',
                job_title='Exporter'
            )

        response = client.get('/admin/export/csv')
        csv_content = response.data.decode('utf-8')
        assert 'CSV Export Test' in csv_content
        assert 'csvtest@example.com' in csv_content
        assert 'Export Corp' in csv_content
        assert 'Exporter' in csv_content

    def test_export_csv_empty_returns_headers_only(self, client):
        """Test that empty export still returns headers."""
        response = client.get('/admin/export/csv')
        csv_content = response.data.decode('utf-8')
        lines = csv_content.strip().split('\n')
        assert len(lines) == 1  # Just the header row
        assert 'Name' in lines[0]
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 63 + 5 = 68 tests passing
```

**Exercise File:** `docs/exercises/phase-3.6-csv-export.md`
**Commit Message:** `Phase 3.6: Add CSV export for registration data`

---

## Phase 3.7: Custom Error Pages

**Goal:** Add custom error pages for 400, 404, and 500 errors

### Files to Create/Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/__init__.py` |
| CREATE | `application/app/templates/errors/400.html` |
| CREATE | `application/app/templates/errors/404.html` |
| CREATE | `application/app/templates/errors/500.html` |
| MODIFY | `application/tests/test_routes.py` |

### __init__.py Update

Update `application/app/__init__.py` to register error handlers:

```python
"""Application factory for the Flask application."""
from flask import Flask, render_template
from config import config_map
from app.extensions import db, migrate
from app.routes import register_blueprints


def create_app(config_name='development'):
    """Create and configure the Flask application.

    Args:
        config_name: Configuration environment ('development', 'production', 'testing')

    Returns:
        Flask: Configured Flask application instance
    """
    app = Flask(__name__)
    app.config.from_object(config_map.get(config_name, config_map['development']))

    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)

    # Register blueprints
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

### errors/400.html Content

Create `application/app/templates/errors/400.html`:

```html
{% extends "base.html" %}

{% block title %}Bad Request{% endblock %}

{% block content %}
<div class="error-page">
    <div class="error-code">400</div>
    <h1>Bad Request</h1>
    <p class="error-message">The server could not understand your request. Please check your input and try again.</p>
    <div class="error-actions">
        <a href="{{ url_for('main.index') }}" class="btn btn-primary">Go to Home</a>
        <a href="javascript:history.back()" class="btn btn-secondary">Go Back</a>
    </div>
</div>
{% endblock %}
```

### errors/404.html Content

Create `application/app/templates/errors/404.html`:

```html
{% extends "base.html" %}

{% block title %}Page Not Found{% endblock %}

{% block content %}
<div class="error-page">
    <div class="error-code">404</div>
    <h1>Page Not Found</h1>
    <p class="error-message">The page you're looking for doesn't exist or has been moved.</p>
    <div class="error-actions">
        <a href="{{ url_for('main.index') }}" class="btn btn-primary">Go to Home</a>
        <a href="{{ url_for('main.register') }}" class="btn btn-secondary">Register for Webinar</a>
    </div>
</div>
{% endblock %}
```

### errors/500.html Content

Create `application/app/templates/errors/500.html`:

```html
{% extends "base.html" %}

{% block title %}Server Error{% endblock %}

{% block content %}
<div class="error-page">
    <div class="error-code">500</div>
    <h1>Something Went Wrong</h1>
    <p class="error-message">We're experiencing technical difficulties. Please try again later.</p>
    <div class="error-actions">
        <a href="{{ url_for('main.index') }}" class="btn btn-primary">Go to Home</a>
        <a href="javascript:location.reload()" class="btn btn-secondary">Try Again</a>
    </div>
</div>
{% endblock %}
```

### Additional CSS

Add to `application/app/static/css/style.css`:

```css
/* ===== Error Pages ===== */
.error-page {
    text-align: center;
    padding: 4rem 2rem;
    max-width: 600px;
    margin: 0 auto;
}

.error-code {
    font-size: 8rem;
    font-weight: bold;
    color: #dee2e6;
    line-height: 1;
    margin-bottom: 1rem;
}

.error-page h1 {
    font-size: 2rem;
    margin-bottom: 1rem;
    color: #343a40;
}

.error-message {
    font-size: 1.1rem;
    color: #6c757d;
    margin-bottom: 2rem;
}

.error-actions {
    display: flex;
    gap: 1rem;
    justify-content: center;
    flex-wrap: wrap;
}
```

### Tests to Add

Add to `application/tests/test_routes.py`:

```python
class TestErrorPages:
    """Tests for custom error pages."""

    def test_404_page_for_nonexistent_route(self, client):
        """Test that 404 page is shown for nonexistent routes."""
        response = client.get('/nonexistent-page-xyz')
        assert response.status_code == 404
        assert b'404' in response.data
        assert b'Page Not Found' in response.data

    def test_404_page_has_home_link(self, client):
        """Test that 404 page has link to home."""
        response = client.get('/nonexistent-page')
        assert b'Go to Home' in response.data

    def test_404_page_has_register_link(self, client):
        """Test that 404 page has link to registration."""
        response = client.get('/nonexistent-page')
        assert b'/register' in response.data
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 68 + 3 = 71 tests passing
```

**Exercise File:** `docs/exercises/phase-3.7-custom-error-pages.md`
**Commit Message:** `Phase 3.7: Add custom error pages (400, 404, 500)`

---

## Final Phase 3 Verification

### Documentation Updates

Update `docs/IMPLEMENTATION-PLAN.md`:
- Change Phase 2 status from `🔲 PLANNED` to `✅ COMPLETE`
- Change Phase 3 status from `🔲 FUTURE` to `✅ COMPLETE`

Update `CLAUDE.md` to reflect new routes:

```markdown
| Route | Response |
|-------|----------|
| `GET /` | Landing page with CTA |
| `GET /webinar` | Webinar information (FR-001) |
| `GET /register` | Registration form with validation |
| `POST /register` | Validate and create registration |
| `GET /thank-you` | Confirmation page |
| `GET /admin/attendees` | Sortable attendee list with stats |
| `GET /admin/export/csv` | CSV download of registrations |
| `GET /demo` | Demo form with entries (Phase 1) |
| `POST /demo` | Create entry (redirects) |
| `GET /api/health` | `{"status": "ok"}` |
| `GET /api/entries` | JSON array of entries |
```

### Test Count Progression

| Phase | New Tests | Total |
|-------|-----------|-------|
| Start (Phase 2 complete) | 0 | 39 |
| 3.0 | 0 | 39 |
| 3.1 | +7 | 46 |
| 3.2 | +4 | 50 |
| 3.3 | +2 | 52 |
| 3.4 | +7 | 59 |
| 3.5 | +4 | 63 |
| 3.6 | +5 | 68 |
| 3.7 | +3 | 71 |

### Git Commit Messages

| Phase | Message |
|-------|---------|
| 3.0 | `Phase 3.0: Add WTForms dependencies for form validation` |
| 3.1 | `Phase 3.1: Add WTForms validation for registration` |
| 3.2 | `Phase 3.2: Add duplicate email prevention with unique constraint` |
| 3.3 | `Phase 3.3: Add error styling and flash message support` |
| 3.4 | `Phase 3.4: Add webinar information page (FR-001)` |
| 3.5 | `Phase 3.5: Add admin sorting and statistics` |
| 3.6 | `Phase 3.6: Add CSV export for registration data` |
| 3.7 | `Phase 3.7: Add custom error pages (400, 404, 500)` |

### Final Completion Checklist

After all phases complete:

- [ ] All 71 tests pass
- [ ] 8 exercise files in `docs/exercises/` (phase-3.0 through phase-3.7)
- [ ] 8 git commits (one per phase step)
- [ ] `.phase3-status.json` shows all completed
- [ ] `docs/IMPLEMENTATION-PLAN.md` Phase 3 marked complete
- [ ] `CLAUDE.md` endpoints updated
- [ ] Phase 1 and 2 functionality preserved

### Files Created in Phase 3

```
application/
├── app/
│   ├── forms/
│   │   ├── __init__.py           (3.1)
│   │   └── registration.py        (3.1)
│   └── templates/
│       ├── errors/
│       │   ├── 400.html          (3.7)
│       │   ├── 404.html          (3.7)
│       │   └── 500.html          (3.7)
│       └── webinar_info.html     (3.4)
├── migrations/versions/
│   └── *_add_email_unique.py     (3.2)
└── .phase3-status.json           (3.0)

docs/exercises/
├── phase-3.0-setup-dependencies.md
├── phase-3.1-wtforms-validation.md
├── phase-3.2-duplicate-email-prevention.md
├── phase-3.3-error-styling-flash-messages.md
├── phase-3.4-webinar-info-page.md
├── phase-3.5-admin-sorting-stats.md
├── phase-3.6-csv-export.md
└── phase-3.7-custom-error-pages.md
```

### PRD Requirements Completed

| PRD Reference | Requirement | Status |
|---------------|-------------|--------|
| FR-001 | Webinar Information Display | ✅ Complete (3.4) |
| FR-002 | Signup Form Integration | ✅ Complete (Phase 2 + 3.1) |
| FR-003 | Data Validation | ✅ Complete (3.1, 3.2) |
| US-001 | View Webinar Information | ✅ Complete (3.4) |
| US-002 | Register for Webinar | ✅ Complete (Phase 2) |
| US-003 | Form Validation Feedback | ✅ Complete (3.1, 3.3) |
| US-004 | Duplicate Prevention | ✅ Complete (3.2) |
| US-005 | View Registered Invitees | ✅ Complete (Phase 2 + 3.5, 3.6) |

---

## Preserved Components

These remain unchanged from Phase 2:

- `app/models/entry.py` - Entry model
- `app/services/entry_service.py` - Entry service
- `app/routes/demo.py` - Demo blueprint at `/demo`
- `app/templates/demo.html` - Demo page template
- `app/routes/api.py` - API blueprint
- All Phase 1 and Phase 2 tests

---

## Deployment Considerations

After completing Phase 3, the deployment should be updated:

1. **Install new dependencies** on the server:
   ```bash
   pip install -r requirements.txt
   ```

2. **Run database migrations** for the unique email constraint:
   ```bash
   flask db upgrade
   ```

3. **Set SECRET_KEY** in production environment:
   ```bash
   export SECRET_KEY='your-secure-random-key-here'
   ```

4. **Restart the Flask application** to apply changes.

The verification tests in `deploy/scripts/verification-tests.sh` should still pass as they test the basic endpoints which remain functional.
