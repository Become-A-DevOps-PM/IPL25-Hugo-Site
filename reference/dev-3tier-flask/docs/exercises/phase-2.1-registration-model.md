# Adding the Registration Model

## Goal

Create a new SQLAlchemy model for webinar registrations alongside the existing Entry model.

> **What you'll learn:**
>
> - How to create SQLAlchemy models with Flask
> - Best practices for model structure and methods
> - Working with Flask-Migrate for database schema changes

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 1 (Architectural Foundation)
> - ✓ Completed Phase 2.0 (Infrastructure Fixes)
> - ✓ Understanding of Python classes and SQLAlchemy basics

## Exercise Steps

### Overview

1. **Create the Registration Model**
2. **Export Model from Package**
3. **Add Model Unit Tests**
4. **Verify with pytest**

### **Step 1:** Create the Registration Model

The Registration model stores webinar signup information with attendee details.

1. **Create** a new file at `application/app/models/registration.py`

2. **Add** the following code:

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
               'created_at': self.created_at.isoformat() if self.created_at else None
           }
   ```

> ℹ **Concept Deep Dive**
>
> The Registration model includes:
>
> - **`__tablename__`**: Explicit table name for clarity
> - **`nullable=False`**: All fields required for complete registrations
> - **`created_at`**: Automatic timestamp using timezone-aware datetime
> - **`__repr__`**: Debug-friendly string representation
> - **`to_dict`**: Serialization for API responses
>
> ⚠ **Common Mistakes**
>
> - Forgetting timezone-aware datetime (use `timezone.utc`)
> - Not handling `None` values in `to_dict()` (the `if self.created_at else None`)
>
> ✓ **Quick check:** Model has all 5 data fields plus id and created_at

### **Step 2:** Export Model from Package

1. **Open** `application/app/models/__init__.py`

2. **Add** the import for Registration:

   ```python
   from .registration import Registration
   ```

> ℹ **Concept Deep Dive**
>
> Exporting from `__init__.py` allows clean imports like:
>
> ```python
> from app.models import Registration
> ```
>
> Instead of:
>
> ```python
> from app.models.registration import Registration
> ```
>
> ✓ **Quick check:** Both Entry and Registration are exported

### **Step 3:** Add Model Unit Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** a new test class at the end of the file:

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
               assert d['company'] == 'Test Corp'
               assert d['job_title'] == 'Developer'
   ```

> ✓ **Quick check:** Two new tests added for `__repr__` and `to_dict`

### **Step 4:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** all tests pass (15 existing + 2 new = 17 tests)

> ✓ **Success indicators:**
>
> - All 17 tests pass
> - No import errors
> - Registration model properly instantiates

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `registration.py` file exists with Registration class
> - ☐ `__init__.py` exports Registration
> - ☐ `pytest tests/test_routes.py -v` passes (17 tests)
> - ☐ Entry model still works (existing tests pass)

## Common Issues

> **If you encounter problems:**
>
> **ImportError: cannot import Registration:** Check that `__init__.py` has the import
>
> **AttributeError on db.Column:** Ensure you imported db from app.extensions
>
> **Datetime issues:** Use `datetime.now(timezone.utc)` not `datetime.utcnow()`
>
> **Still stuck?** Compare with the Entry model in `app/models/entry.py`

## Summary

You've created the Registration model with:

- ✓ Five data fields (name, email, company, job_title, created_at)
- ✓ String representation for debugging
- ✓ Dictionary serialization for API responses
- ✓ Two unit tests confirming model behavior

> **Key takeaway:** Models define your data structure. The Registration model follows the same patterns as Entry, demonstrating consistent Flask-SQLAlchemy usage.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add email validation at the model level
> - Add a unique constraint on email
> - Create a `from_dict()` classmethod for deserialization

## Done!

The Registration model is ready. Next phase will add the service layer for business logic.
