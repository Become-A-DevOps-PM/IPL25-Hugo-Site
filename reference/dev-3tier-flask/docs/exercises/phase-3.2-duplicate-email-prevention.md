# Duplicate Email Prevention

## Goal

Add a unique constraint on email addresses to prevent duplicate registrations with user-friendly error handling.

> **What you'll learn:**
>
> - How to add database-level unique constraints
> - Creating custom exception classes for business logic
> - Handling IntegrityError from SQLAlchemy
> - Case-insensitive email normalization

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 3.1 (WTForms validation)
> - ✓ All 46 tests passing
> - ✓ Understanding of database constraints

## Exercise Steps

### Overview

1. **Update Registration Model**
2. **Update Registration Service**
3. **Update Main Route**
4. **Generate Database Migration**
5. **Add Duplicate Prevention Tests**
6. **Verify with pytest**

### **Step 1:** Update Registration Model

Add a unique constraint and index to the email column for efficient duplicate checking.

1. **Open** `application/app/models/registration.py`

2. **Replace** with the following content:

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

> ℹ **Concept Deep Dive**
>
> - **unique=True** enforces uniqueness at the database level
> - **index=True** creates an index for faster email lookups
> - Database constraints are the last line of defense against duplicates
> - The index also speeds up the `email_exists()` check we'll add
>
> ✓ **Quick check:** email column has both `unique=True` and `index=True`

### **Step 2:** Update Registration Service

Add a custom exception and email normalization to handle duplicate registrations gracefully.

1. **Open** `application/app/services/registration_service.py`

2. **Replace** with the following content:

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

> ℹ **Concept Deep Dive**
>
> - **DuplicateEmailError** is a custom exception for clear error handling
> - **email.lower().strip()** normalizes emails for case-insensitive comparison
> - **IntegrityError** is caught when the database constraint is violated
> - **db.session.rollback()** is required after catching IntegrityError
> - **email_exists()** allows pre-checking before attempting insert
>
> ⚠ **Common Mistakes**
>
> - Forgetting to rollback after IntegrityError causes subsequent operations to fail
> - Not normalizing email makes "Test@Email.com" and "test@email.com" different
>
> ✓ **Quick check:** Service has DuplicateEmailError class and email normalization

### **Step 3:** Update Main Route

Catch the DuplicateEmailError and add it to the form's email field errors.

1. **Open** `application/app/routes/main.py`

2. **Update** the import statement:

   ```python
   from app.services.registration_service import RegistrationService, DuplicateEmailError
   ```

3. **Replace** the `register` function with:

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

> ℹ **Concept Deep Dive**
>
> - **form.email.errors.append()** adds the error to the field's error list
> - This integrates seamlessly with the existing error display in the template
> - The form is re-rendered with all user input preserved plus the error message
>
> ✓ **Quick check:** Route imports DuplicateEmailError and catches it in try/except

### **Step 4:** Generate Database Migration

Create and apply the migration for the unique constraint.

1. **Run** the migration commands:

   ```bash
   cd application
   source .venv/bin/activate
   flask db migrate -m "Add unique constraint to registration email"
   flask db upgrade
   ```

> ℹ **Concept Deep Dive**
>
> Flask-Migrate (Alembic) detects the model changes and generates a migration script. The migration adds both the unique constraint and the index.
>
> ⚠ **Common Mistakes**
>
> - Running migrate without the virtual environment activated
> - Forgetting to run `flask db upgrade` after migrate
>
> ✓ **Quick check:** Migration file created in `migrations/versions/`

### **Step 5:** Add Duplicate Prevention Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

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

> ✓ **Quick check:** 4 new tests for duplicate email scenarios

### **Step 6:** Verify with pytest

1. **Run** the tests:

   ```bash
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 46 + 4 = 50 tests passing

> ✓ **Success indicators:**
>
> - All 50 tests pass
> - Duplicate email shows "already registered" error
> - Case variations are treated as duplicates

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ Registration model has `unique=True` and `index=True` on email
> - ☐ Service has DuplicateEmailError and email normalization
> - ☐ Route catches DuplicateEmailError and adds to form errors
> - ☐ Migration created and applied
> - ☐ `pytest tests/test_routes.py -v` passes (50 tests)

## Common Issues

> **If you encounter problems:**
>
> **IntegrityError not caught:** Import IntegrityError from sqlalchemy.exc
>
> **Migration fails:** Delete local.db and run `flask db upgrade` fresh
>
> **Case sensitivity issues:** Ensure email.lower().strip() is used consistently
>
> **Form errors not showing:** Check DuplicateEmailError is imported in routes

## Summary

You've implemented duplicate email prevention:

- ✓ Added unique constraint at database level
- ✓ Created custom DuplicateEmailError exception
- ✓ Normalized emails to lowercase for case-insensitive matching
- ✓ Integrated error display with existing form validation
- ✓ 4 new tests verify duplicate handling

> **Key takeaway:** Database constraints provide the final guarantee of data integrity, while service layer error handling provides user-friendly feedback.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add a "forgot registration" link for duplicate emails
> - Implement email verification before accepting registrations
> - Add rate limiting to prevent registration spam

## Done!

Duplicate email prevention is complete. Next phase will add error styling and flash messages.
