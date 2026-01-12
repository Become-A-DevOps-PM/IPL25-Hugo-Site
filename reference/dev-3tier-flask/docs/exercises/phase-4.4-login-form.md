# Login Form with WTForms

## Goal

Create a login form with username and password fields using WTForms validation.

> **What you'll learn:**
>
> - Creating authentication forms with WTForms
> - Using PasswordField for secure password input
> - Adding BooleanField for "remember me" functionality
> - Form validation with custom error messages

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 4.3 (Flask-Login integration)
> - ✓ All 90 tests passing
> - ✓ Understanding of WTForms (from Phase 3.1)

## Exercise Steps

### Overview

1. **Create Login Form**
2. **Export Form from Package**
3. **Add Login Form Tests**
4. **Verify with pytest**

### **Step 1:** Create Login Form

The LoginForm handles username and password input with validation.

1. **Create** `application/app/forms/login.py`:

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

> ℹ **Concept Deep Dive**
>
> - **PasswordField** renders as `<input type="password">` (dots instead of text)
> - **BooleanField** renders as a checkbox for "remember me" functionality
> - **DataRequired** ensures fields are not empty
> - **Length** validator enforces minimum/maximum character counts
>
> Password minimum length (8 characters) aligns with the User model and AuthService
> requirements for consistency across the application.
>
> ⚠ **Common Mistakes**
>
> - Using StringField instead of PasswordField for passwords
> - Different length requirements between form and model
> - Forgetting CSRF protection (included automatically with FlaskForm)
>
> ✓ **Quick check:** LoginForm has username, password, remember_me, and submit fields

### **Step 2:** Export Form from Package

1. **Open** `application/app/forms/__init__.py`

2. **Update** to include LoginForm:

   ```python
   """Form classes for the application."""
   from app.forms.registration import RegistrationForm
   from app.forms.login import LoginForm

   __all__ = ['RegistrationForm', 'LoginForm']
   ```

> ✓ **Quick check:** LoginForm is exported alongside RegistrationForm

### **Step 3:** Add Login Form Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

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

> ℹ **Concept Deep Dive**
>
> - Form validation tests verify client-side requirements before database checks
> - Testing empty, short, and valid inputs covers common edge cases
> - Form validation happens before authentication (fail fast pattern)
>
> Note: Form validation doesn't check if the user exists - that's AuthService's job.
>
> ✓ **Quick check:** 5 new tests for LoginForm validation

### **Step 4:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 90 + 5 = 95 tests passing

> ✓ **Success indicators:**
>
> - All 95 tests pass
> - Empty and short inputs rejected
> - Valid credentials pass validation

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `forms/login.py` exists with LoginForm class
> - ☐ LoginForm has username, password, remember_me, submit fields
> - ☐ DataRequired validator on username and password
> - ☐ Length validator with min=3 on username, min=8 on password
> - ☐ `forms/__init__.py` exports LoginForm
> - ☐ `pytest tests/test_routes.py -v` passes (95 tests)

## Common Issues

> **If you encounter problems:**
>
> **CSRF validation failing in tests:** Disable in TestingConfig with `WTF_CSRF_ENABLED = False`
>
> **Form not validating:** Ensure test passes `data={}` parameter to form constructor
>
> **Remember me not working:** BooleanField defaults to False if not submitted
>
> **Validation errors not showing:** Check `form.errors` dictionary for field-specific errors

## Summary

You've created the login form:

- ✓ WTForms LoginForm with username and password validation
- ✓ PasswordField for secure password input
- ✓ BooleanField for remember me checkbox
- ✓ Consistent length requirements (matches model/service)
- ✓ 5 new tests verify form validation

> **Key takeaway:** Form validation provides immediate feedback before expensive database operations. The login form validates input format first, then the route handler uses AuthService to verify credentials.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add custom validators for password complexity
> - Implement rate limiting on login attempts
> - Add CAPTCHA after multiple failed attempts

## Done!

Login form is complete. Next phase will create the auth blueprint with routes.
