# Phase 2: Walking Skeleton - Implementation Guide

**Project:** dev-3tier-flask Reference Implementation
**Purpose:** Complete implementation guide for unattended execution of Phase 2
**Created:** 2026-01-08

---

## Overview

This document provides a complete, self-contained guide for implementing Phase 2 (Walking Skeleton) of the dev-3tier-flask reference project. It is designed to enable **unattended execution** with the ability to resume from any point.

### What Phase 2 Delivers

A minimal end-to-end webinar registration flow:

```
Landing Page → Registration Form → Thank You Page
                                         ↓
                              Admin Attendees List
```

### Key Principles

1. **Additive Development** - Never delete Phase 1 code; add new functionality alongside
2. **Layer-by-Layer** - Build from data layer up (Model → Service → Routes → Templates)
3. **Test-Driven** - Add tests with each step; all tests must pass before proceeding
4. **Git Commits** - One commit per phase step for clear history

---

## Execution Framework

### Status Tracking

**Status File:** `.phase2-status.json` (in project root)

```json
{
  "phase": "2",
  "current_step": "2.X",
  "steps": {
    "2.0": { "status": "pending|in_progress|completed", "exercise": "path", "commit": "sha" },
    ...
  },
  "started_at": "ISO timestamp",
  "completed_at": null,
  "last_updated": "ISO timestamp"
}
```

### Exercise Files Location

All exercise markdown files go in: `docs/exercises/`

### Per-Step Workflow

For each step (2.0 through 2.8):

```
1. READ STATUS    → cat .phase2-status.json
2. READ GIT LOG   → git log --oneline -5
3. CREATE EXERCISE → Write docs/exercises/phase-2.X-[name].md
4. IMPLEMENT CODE → Create/modify files as specified
5. RUN TESTS      → cd application && pytest tests/ -v
6. UPDATE STATUS  → Edit .phase2-status.json
7. GIT COMMIT     → git add . && git commit -m "Phase 2.X: [Message]"
8. PROCEED        → Move to next step
```

### Resumption Protocol

When starting/resuming:

1. Read `.phase2-status.json` to find current step
2. Read `git log --oneline -10` for context
3. If current step is "in_progress" → continue it
4. If current step is "completed" → proceed to next
5. If current step is "pending" → start it

---

## Phase 2.0: Infrastructure Fixes

**Status:** ✅ ALREADY COMPLETE (verified 2026-01-08)

The fixes recommended in DEPLOYMENT-TEST-REPORT.md were already implemented:

| Fix | Location | Current State |
|-----|----------|---------------|
| Alphanumeric passwords | `infrastructure/scripts/init-secrets.sh:39` | Uses `tr -dc 'A-Za-z0-9'` |
| Database table init | `deploy/deploy.sh:64-68` | Step 9 creates tables |

**Exercise File:** `docs/exercises/phase-2.0-infrastructure-fixes.md`
**Commit Message:** `Phase 2.0: Document infrastructure fixes (already implemented)`

---

## Phase 2.1: Registration Model

**Goal:** Add Registration model alongside existing Entry model

### Files to Create/Modify

| Action | File |
|--------|------|
| CREATE | `application/app/models/registration.py` |
| MODIFY | `application/app/models/__init__.py` |
| GENERATE | `application/migrations/versions/*_add_registration.py` |
| MODIFY | `application/tests/test_routes.py` |

### registration.py Content

```python
"""Registration model for webinar signups."""
from datetime import datetime, timezone
from app.extensions import db


class Registration(db.Model):
    """Webinar registration with attendee information."""
    __tablename__ = 'registrations'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    company = db.Column(db.String(100), nullable=False)
    job_title = db.Column(db.String(100), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    def __repr__(self):
        return f'<Registration {self.email}>'

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'company': self.company,
            'job_title': self.job_title,
            'created_at': self.created_at.isoformat()
        }
```

### __init__.py Addition

Add to `application/app/models/__init__.py`:
```python
from .registration import Registration
```

### Generate Migration

```bash
cd application
source .venv/bin/activate
flask db migrate -m "Add registration model"
flask db upgrade
```

### Tests to Add

```python
class TestRegistrationModel:
    """Tests for the Registration model."""

    def test_registration_repr(self, app):
        """Test Registration string representation."""
        with app.app_context():
            from app.models.registration import Registration
            reg = Registration(
                name='Test User',
                email='test@example.com',
                company='Test Corp',
                job_title='Developer'
            )
            assert '<Registration test@example.com>' in repr(reg)

    def test_registration_to_dict(self, app):
        """Test Registration to_dict method."""
        with app.app_context():
            from app.models.registration import Registration
            reg = Registration(
                name='Test User',
                email='test@example.com',
                company='Test Corp',
                job_title='Developer'
            )
            d = reg.to_dict()
            assert d['name'] == 'Test User'
            assert d['email'] == 'test@example.com'
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 15 + 2 = 17 tests passing
```

**Exercise File:** `docs/exercises/phase-2.1-registration-model.md`
**Commit Message:** `Phase 2.1: Add Registration model with migration`

---

## Phase 2.2: Registration Service

**Goal:** Create business logic layer for registration operations

### Files to Create/Modify

| Action | File |
|--------|------|
| CREATE | `application/app/services/registration_service.py` |
| MODIFY | `application/app/services/__init__.py` |
| MODIFY | `application/tests/test_routes.py` |

### registration_service.py Content

```python
"""Business logic for webinar registrations."""
from app.extensions import db
from app.models.registration import Registration


class RegistrationService:
    """Service layer for registration operations."""

    @staticmethod
    def create_registration(name, email, company, job_title):
        """Create a new webinar registration."""
        registration = Registration(
            name=name,
            email=email,
            company=company,
            job_title=job_title
        )
        db.session.add(registration)
        db.session.commit()
        return registration

    @staticmethod
    def get_all_registrations():
        """Get all registrations ordered by creation date."""
        return Registration.query.order_by(Registration.created_at.desc()).all()

    @staticmethod
    def get_registration_count():
        """Get total count of registrations."""
        return Registration.query.count()
```

### __init__.py Addition

Add to `application/app/services/__init__.py`:
```python
from .registration_service import RegistrationService
```

### Tests to Add

```python
class TestRegistrationService:
    """Tests for the RegistrationService."""

    def test_create_registration(self, app):
        with app.app_context():
            from app.services.registration_service import RegistrationService
            reg = RegistrationService.create_registration(
                name='Test User',
                email='test@example.com',
                company='Test Corp',
                job_title='Developer'
            )
            assert reg.id is not None
            assert reg.email == 'test@example.com'

    def test_get_all_registrations_empty(self, app):
        with app.app_context():
            from app.services.registration_service import RegistrationService
            regs = RegistrationService.get_all_registrations()
            assert regs == []

    def test_get_all_registrations_with_data(self, app):
        with app.app_context():
            from app.services.registration_service import RegistrationService
            RegistrationService.create_registration(
                name='User 1', email='u1@test.com', company='C1', job_title='Dev'
            )
            RegistrationService.create_registration(
                name='User 2', email='u2@test.com', company='C2', job_title='PM'
            )
            regs = RegistrationService.get_all_registrations()
            assert len(regs) == 2

    def test_get_registration_count(self, app):
        with app.app_context():
            from app.services.registration_service import RegistrationService
            assert RegistrationService.get_registration_count() == 0
            RegistrationService.create_registration(
                name='User', email='u@test.com', company='C', job_title='Dev'
            )
            assert RegistrationService.get_registration_count() == 1
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 17 + 4 = 21 tests passing
```

**Exercise File:** `docs/exercises/phase-2.2-registration-service.md`
**Commit Message:** `Phase 2.2: Add RegistrationService for business logic`

---

## Phase 2.3: Landing Page Enhancement

**Goal:** Add hero section with "Register Now" call-to-action

### Files to Modify

| Action | File |
|--------|------|
| REPLACE | `application/app/templates/landing.html` |
| MODIFY | `application/tests/test_routes.py` |

### landing.html Content

```html
{% extends "base.html" %}

{% block title %}Webinar Registration - Welcome{% endblock %}

{% block content %}
<div class="hero">
    <h1>Join Our Upcoming Webinar</h1>
    <p class="lead">Learn about cloud infrastructure and modern deployment practices from industry experts.</p>
    <div class="cta-section">
        <a href="{{ url_for('main.register') }}" class="btn btn-primary btn-lg">Register Now</a>
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

### Tests to Add

```python
class TestLandingPageEnhanced:
    """Tests for enhanced landing page with CTA."""

    def test_landing_page_has_register_link(self, client):
        response = client.get('/')
        assert response.status_code == 200
        assert b'/register' in response.data
        assert b'Register Now' in response.data

    def test_landing_page_has_hero_section(self, client):
        response = client.get('/')
        assert b'Join Our Upcoming Webinar' in response.data

    def test_landing_page_links_to_demo(self, client):
        response = client.get('/')
        assert b'/demo' in response.data
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 21 + 3 = 24 tests passing
```

**Exercise File:** `docs/exercises/phase-2.3-landing-page-enhancement.md`
**Commit Message:** `Phase 2.3: Add hero section and CTA to landing page`

---

## Phase 2.4: Registration Form (GET)

**Goal:** Display the registration form

### Files to Create/Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/routes/main.py` |
| CREATE | `application/app/templates/register.html` |
| MODIFY | `application/tests/test_routes.py` |

### main.py Content (Full Replacement)

```python
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
```

### register.html Content

```html
{% extends "base.html" %}

{% block title %}Register for Webinar{% endblock %}

{% block content %}
<div class="register-page">
    <h1>Register for Our Webinar</h1>
    <p>Fill out the form below to reserve your spot.</p>

    <form method="POST" action="{{ url_for('main.register') }}" class="registration-form">
        <div class="form-group">
            <label for="name">Full Name</label>
            <input type="text" id="name" name="name" required placeholder="John Doe">
        </div>

        <div class="form-group">
            <label for="email">Email Address</label>
            <input type="email" id="email" name="email" required placeholder="john@example.com">
        </div>

        <div class="form-group">
            <label for="company">Company</label>
            <input type="text" id="company" name="company" required placeholder="Acme Corp">
        </div>

        <div class="form-group">
            <label for="job_title">Job Title</label>
            <input type="text" id="job_title" name="job_title" required placeholder="Software Developer">
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Complete Registration</button>
        </div>
    </form>

    <p class="back-link"><a href="{{ url_for('main.index') }}">← Back to home</a></p>
</div>
{% endblock %}
```

### Tests to Add

```python
class TestRegisterPage:
    """Tests for the registration form page."""

    def test_register_page_loads(self, client):
        response = client.get('/register')
        assert response.status_code == 200

    def test_register_page_has_form(self, client):
        response = client.get('/register')
        assert b'<form' in response.data
        assert b'method="POST"' in response.data

    def test_register_page_has_required_fields(self, client):
        response = client.get('/register')
        assert b'name="name"' in response.data
        assert b'name="email"' in response.data
        assert b'name="company"' in response.data
        assert b'name="job_title"' in response.data

    def test_register_page_has_submit_button(self, client):
        response = client.get('/register')
        assert b'type="submit"' in response.data
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 24 + 4 = 28 tests passing
```

**Exercise File:** `docs/exercises/phase-2.4-registration-form-get.md`
**Commit Message:** `Phase 2.4: Add registration form page (GET)`

---

## Phase 2.5: Form Submission (POST)

**Goal:** Handle form POST and create registration in database

### Files to Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/routes/main.py` |
| MODIFY | `application/tests/test_routes.py` |

### main.py Content (Full Replacement)

```python
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
```

### Tests to Add

```python
class TestRegisterSubmission:
    """Tests for registration form submission."""

    def test_register_post_redirects(self, client):
        response = client.post('/register', data={
            'name': 'Test User',
            'email': 'test@example.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        }, follow_redirects=False)
        assert response.status_code == 302
        assert '/thank-you' in response.location

    def test_register_post_creates_registration(self, app, client):
        with app.app_context():
            from app.services.registration_service import RegistrationService
            initial_count = RegistrationService.get_registration_count()

            client.post('/register', data={
                'name': 'Test User',
                'email': 'test@example.com',
                'company': 'Test Corp',
                'job_title': 'Developer'
            })

            final_count = RegistrationService.get_registration_count()
            assert final_count == initial_count + 1

    def test_register_post_with_follow_redirect(self, client):
        response = client.post('/register', data={
            'name': 'Test User',
            'email': 'test@example.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        }, follow_redirects=True)
        assert response.status_code == 200
        assert b'Thank you' in response.data
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 28 + 3 = 31 tests passing
```

**Exercise File:** `docs/exercises/phase-2.5-form-submission.md`
**Commit Message:** `Phase 2.5: Handle registration form submission (POST)`

---

## Phase 2.6: Thank You Page

**Goal:** Create user-friendly confirmation page

### Files to Create/Modify

| Action | File |
|--------|------|
| MODIFY | `application/app/routes/main.py` (update thank_you function) |
| CREATE | `application/app/templates/thank_you.html` |
| MODIFY | `application/tests/test_routes.py` |

### main.py Update (thank_you function only)

```python
@main_bp.route('/thank-you')
def thank_you():
    """Display registration confirmation."""
    return render_template('thank_you.html')
```

### thank_you.html Content

```html
{% extends "base.html" %}

{% block title %}Registration Complete{% endblock %}

{% block content %}
<div class="thank-you-page">
    <div class="success-icon">✓</div>
    <h1>Thank You for Registering!</h1>
    <p class="lead">Your registration has been received successfully.</p>

    <div class="next-steps">
        <h2>What's Next?</h2>
        <ul>
            <li>You will receive a confirmation email shortly</li>
            <li>The webinar link will be sent before the event</li>
            <li>Mark your calendar for the upcoming session</li>
        </ul>
    </div>

    <div class="actions">
        <a href="{{ url_for('main.index') }}" class="btn btn-primary">Return to Home</a>
    </div>
</div>
{% endblock %}
```

### Tests to Add

```python
class TestThankYouPage:
    """Tests for the thank-you confirmation page."""

    def test_thank_you_page_loads(self, client):
        response = client.get('/thank-you')
        assert response.status_code == 200

    def test_thank_you_page_has_success_message(self, client):
        response = client.get('/thank-you')
        assert b'Thank You' in response.data
        assert b'registration' in response.data.lower()

    def test_thank_you_page_has_home_link(self, client):
        response = client.get('/thank-you')
        assert b'href="/"' in response.data or b"url_for('main.index')" in response.data
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 31 + 3 = 34 tests passing
```

**Exercise File:** `docs/exercises/phase-2.6-thank-you-page.md`
**Commit Message:** `Phase 2.6: Add thank-you confirmation page`

---

## Phase 2.7: Admin Blueprint

**Goal:** Create admin section for viewing registrations

### Files to Create/Modify

| Action | File |
|--------|------|
| CREATE | `application/app/routes/admin.py` |
| MODIFY | `application/app/routes/__init__.py` |
| CREATE | `application/app/templates/admin/` (directory) |
| CREATE | `application/app/templates/admin/attendees.html` |
| MODIFY | `application/tests/test_routes.py` |

### admin.py Content

```python
"""Admin blueprint for managing registrations.

Note: No authentication in Phase 2. Routes are publicly accessible.
Authentication will be added in Phase 4.
"""
from flask import Blueprint, render_template
from app.services.registration_service import RegistrationService

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')


@admin_bp.route('/attendees')
def attendees():
    """Display list of all webinar registrations."""
    registrations = RegistrationService.get_all_registrations()
    count = RegistrationService.get_registration_count()
    return render_template('admin/attendees.html',
                          registrations=registrations,
                          count=count)
```

### __init__.py Content (Full Replacement)

```python
"""Blueprint registration for the Flask application."""
from app.routes.main import main_bp
from app.routes.demo import demo_bp
from app.routes.api import api_bp
from app.routes.admin import admin_bp


def register_blueprints(app):
    """Register all blueprints with the Flask application."""
    app.register_blueprint(main_bp)
    app.register_blueprint(demo_bp)
    app.register_blueprint(api_bp)
    app.register_blueprint(admin_bp)
```

### admin/attendees.html Content

```html
{% extends "base.html" %}

{% block title %}Admin - Attendees{% endblock %}

{% block content %}
<div class="admin-page">
    <h1>Webinar Attendees</h1>
    <p class="lead">Total registrations: <strong>{{ count }}</strong></p>

    {% if registrations %}
    <table class="attendees-table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Company</th>
                <th>Job Title</th>
                <th>Registered</th>
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

### Tests to Add

```python
class TestAdminAttendees:
    """Tests for the admin attendees page."""

    def test_admin_attendees_loads(self, client):
        response = client.get('/admin/attendees')
        assert response.status_code == 200

    def test_admin_attendees_shows_count(self, client):
        response = client.get('/admin/attendees')
        assert b'Total registrations' in response.data

    def test_admin_attendees_empty_state(self, client):
        response = client.get('/admin/attendees')
        assert b'No registrations yet' in response.data

    def test_admin_attendees_shows_registrations(self, app, client):
        with app.app_context():
            from app.services.registration_service import RegistrationService
            RegistrationService.create_registration(
                name='Admin Test',
                email='admin@test.com',
                company='Admin Corp',
                job_title='Admin'
            )

        response = client.get('/admin/attendees')
        assert b'Admin Test' in response.data
        assert b'admin@test.com' in response.data
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 34 + 4 = 38 tests passing
```

**Exercise File:** `docs/exercises/phase-2.7-admin-blueprint.md`
**Commit Message:** `Phase 2.7: Add admin blueprint with attendees list`

---

## Phase 2.8: End-to-End Tests

**Goal:** Verify complete user journey works end-to-end

### Files to Modify

| Action | File |
|--------|------|
| MODIFY | `application/tests/test_routes.py` |
| MODIFY | `docs/IMPLEMENTATION-PLAN.md` |
| MODIFY | `CLAUDE.md` |

### Tests to Add

```python
class TestRegistrationFlow:
    """End-to-end tests for the complete registration journey."""

    def test_landing_to_register_flow(self, client):
        landing = client.get('/')
        assert landing.status_code == 200
        assert b'/register' in landing.data

        register = client.get('/register')
        assert register.status_code == 200
        assert b'<form' in register.data

    def test_complete_registration_journey(self, app, client):
        landing = client.get('/')
        assert b'Register Now' in landing.data

        register_page = client.get('/register')
        assert register_page.status_code == 200

        submit = client.post('/register', data={
            'name': 'E2E Test User',
            'email': 'e2e@test.com',
            'company': 'E2E Corp',
            'job_title': 'Tester'
        }, follow_redirects=True)
        assert submit.status_code == 200
        assert b'Thank You' in submit.data

        admin = client.get('/admin/attendees')
        assert admin.status_code == 200
        assert b'E2E Test User' in admin.data
        assert b'e2e@test.com' in admin.data

    def test_multiple_registrations_in_admin(self, app, client):
        for i in range(3):
            client.post('/register', data={
                'name': f'User {i}',
                'email': f'user{i}@test.com',
                'company': f'Company {i}',
                'job_title': 'Developer'
            })

        admin = client.get('/admin/attendees')
        assert b'User 0' in admin.data
        assert b'User 1' in admin.data
        assert b'User 2' in admin.data

    def test_demo_still_works(self, client):
        demo = client.get('/demo/')
        assert demo.status_code == 200
        assert b'demo' in demo.data.lower()

        post_demo = client.post('/demo/', data={'value': 'E2E Demo Test'})
        assert post_demo.status_code == 302

        api = client.get('/api/health')
        assert api.status_code == 200
```

### Documentation Updates

Update `docs/IMPLEMENTATION-PLAN.md`:
- Change Phase 2 status from `🔲 PLANNED` to `✅ COMPLETE`

Update `CLAUDE.md` endpoints table:
```markdown
| Route | Response |
|-------|----------|
| `GET /` | Landing page with CTA |
| `GET /register` | Registration form |
| `POST /register` | Create registration (redirects) |
| `GET /thank-you` | Confirmation page |
| `GET /admin/attendees` | Attendee list |
| `GET /demo` | Demo form with entries (Phase 1) |
| `POST /demo` | Create entry (redirects) |
| `GET /api/health` | `{"status": "healthy"}` |
| `GET /api/entries` | JSON array of entries |
```

### Verification

```bash
pytest tests/test_routes.py -v
# Expected: 38 + 4 = 42 tests passing
```

**Exercise File:** `docs/exercises/phase-2.8-end-to-end-tests.md`
**Commit Message:** `Phase 2.8: Add end-to-end registration flow tests`

---

## Test Count Progression

| Phase | New Tests | Total |
|-------|-----------|-------|
| Start | 0 | 15 |
| 2.0 | 0 | 15 |
| 2.1 | +2 | 17 |
| 2.2 | +4 | 21 |
| 2.3 | +3 | 24 |
| 2.4 | +4 | 28 |
| 2.5 | +3 | 31 |
| 2.6 | +3 | 34 |
| 2.7 | +4 | 38 |
| 2.8 | +4 | 42 |

---

## Git Commit Messages

| Phase | Message |
|-------|---------|
| 2.0 | `Phase 2.0: Document infrastructure fixes (already implemented)` |
| 2.1 | `Phase 2.1: Add Registration model with migration` |
| 2.2 | `Phase 2.2: Add RegistrationService for business logic` |
| 2.3 | `Phase 2.3: Add hero section and CTA to landing page` |
| 2.4 | `Phase 2.4: Add registration form page (GET)` |
| 2.5 | `Phase 2.5: Handle registration form submission (POST)` |
| 2.6 | `Phase 2.6: Add thank-you confirmation page` |
| 2.7 | `Phase 2.7: Add admin blueprint with attendees list` |
| 2.8 | `Phase 2.8: Add end-to-end registration flow tests` |

---

## Final Completion Checklist

After all phases complete:

- [ ] All 42 tests pass
- [ ] 9 exercise files in `docs/exercises/`
- [ ] 9 git commits (one per phase)
- [ ] `.phase2-status.json` shows all completed
- [ ] `docs/IMPLEMENTATION-PLAN.md` Phase 2 marked complete
- [ ] `CLAUDE.md` endpoints updated
- [ ] Phase 1 demo functionality preserved

---

## Preserved Phase 1 Components

These remain unchanged:

- `app/models/entry.py` - Entry model
- `app/services/entry_service.py` - Entry service
- `app/routes/demo.py` - Demo blueprint at `/demo`
- `app/templates/demo.html` - Demo page template
