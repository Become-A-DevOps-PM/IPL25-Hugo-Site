# Registration Form with WTForms

## Goal

Replace HTML form handling with WTForms for server-side validation with field-specific error messages.

> **What you'll learn:**
>
> - How to create WTForms form classes with validators
> - Integrating WTForms with Flask routes
> - Displaying validation errors in Jinja2 templates
> - Configuring SECRET_KEY for CSRF protection

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 3.0 (WTForms dependencies installed)
> - ✓ All 39 tests passing
> - ✓ Understanding of Python classes and Flask routing

## Exercise Steps

### Overview

1. **Create Forms Package**
2. **Create RegistrationForm Class**
3. **Update Configuration for CSRF**
4. **Update Main Routes**
5. **Update Registration Template**
6. **Add Validation Tests**
7. **Verify with pytest**

### **Step 1:** Create Forms Package

WTForms classes are organized in a `forms` package, keeping form definitions separate from routes.

1. **Create** the directory `application/app/forms/`

2. **Create** `application/app/forms/__init__.py`:

   ```python
   """Form classes for the application."""
   from app.forms.registration import RegistrationForm
   ```

> ✓ **Quick check:** forms directory exists with __init__.py

### **Step 2:** Create RegistrationForm Class

The RegistrationForm defines all fields with their validators. Each field gets specific validation rules and custom error messages.

1. **Create** `application/app/forms/registration.py`:

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

> ℹ **Concept Deep Dive**
>
> - **FlaskForm** is the base class that adds CSRF protection automatically
> - **StringField** creates text input fields
> - **validators** is a list of validation rules applied in order
> - **DataRequired** ensures the field is not empty
> - **Length** validates character count min/max
> - **Email** validates proper email format using email-validator
>
> Custom error messages make debugging easier for users.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to inherit from FlaskForm (not Form)
> - Not providing custom error messages (defaults are less helpful)
>
> ✓ **Quick check:** RegistrationForm has 4 StringField fields and 1 SubmitField

### **Step 3:** Update Configuration for CSRF

WTForms CSRF protection requires a SECRET_KEY. Update the configuration to include this.

1. **Open** `application/config.py`

2. **Replace** with the following content:

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

> ℹ **Concept Deep Dive**
>
> - **SECRET_KEY** signs session cookies and CSRF tokens
> - **WTF_CSRF_ENABLED = False** in testing prevents test failures from missing CSRF tokens
> - In production, SECRET_KEY must be set via environment variable
>
> ✓ **Quick check:** Config classes include SECRET_KEY and WTF_CSRF settings

### **Step 4:** Update Main Routes

The register route now uses the form object for both GET (display) and POST (validation).

1. **Open** `application/app/routes/main.py`

2. **Replace** with the following content:

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

> ℹ **Concept Deep Dive**
>
> - **form.validate_on_submit()** returns True only if POST and all validators pass
> - **form.name.data** accesses the cleaned/validated field data
> - **flash()** stores a message in the session for display on the next page
> - Invalid submissions re-render the form with errors populated
>
> ⚠ **Common Mistakes**
>
> - Using `request.form` instead of form field data
> - Forgetting to pass form to the template
>
> ✓ **Quick check:** Route imports RegistrationForm and creates form object

### **Step 5:** Update Registration Template

The template now uses WTForms macros for rendering fields and displaying errors.

1. **Open** `application/app/templates/register.html`

2. **Replace** with the following content:

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

> ℹ **Concept Deep Dive**
>
> - **{{ form.hidden_tag() }}** renders the CSRF token as a hidden field
> - **{{ form.name() }}** renders the input element with attributes
> - **form.name.errors** is a list of validation error messages
> - **has-error** class enables CSS styling for invalid fields
> - **novalidate** on form disables browser validation (we use server-side)
>
> ✓ **Quick check:** Template uses form object and displays errors for each field

### **Step 6:** Add Validation Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class at the end:

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

> ✓ **Quick check:** 7 new tests for form validation scenarios

### **Step 7:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 39 + 7 = 46 tests passing

> ✓ **Success indicators:**
>
> - All 46 tests pass
> - Validation error messages appear in responses
> - Valid submissions redirect to /thank-you

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `forms/__init__.py` exports RegistrationForm
> - ☐ `forms/registration.py` defines form with 4 fields
> - ☐ `config.py` includes SECRET_KEY and CSRF settings
> - ☐ `routes/main.py` uses RegistrationForm
> - ☐ `register.html` displays form fields and errors
> - ☐ `pytest tests/test_routes.py -v` passes (46 tests)

## Common Issues

> **If you encounter problems:**
>
> **RuntimeError: Working outside of application context:** Ensure tests use app fixture
>
> **CSRF token missing:** Check that form.hidden_tag() is in template
>
> **Import error for RegistrationForm:** Check __init__.py exports it correctly
>
> **Validation not triggering:** Ensure POST method and form data keys match field names

## Summary

You've implemented WTForms validation:

- ✓ Created RegistrationForm with field validators
- ✓ Configured SECRET_KEY for CSRF protection
- ✓ Updated routes to use form object
- ✓ Template displays field-specific error messages
- ✓ 7 new tests verify validation behavior

> **Key takeaway:** WTForms provides a clean separation between validation logic (form class) and display (template), making forms more maintainable and testable.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add custom validators for specific business rules
> - Explore client-side validation integration
> - Learn about form inheritance for shared field patterns

## Done!

Form validation is complete. Next phase will add duplicate email prevention.
