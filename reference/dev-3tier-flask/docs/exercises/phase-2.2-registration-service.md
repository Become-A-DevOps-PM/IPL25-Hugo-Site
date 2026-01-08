# Creating the Registration Service Layer

## Goal

Create a service layer that encapsulates business logic for registration operations, following the same pattern as EntryService.

> **What you'll learn:**
>
> - How to implement the service layer pattern in Flask
> - Separating business logic from route handlers
> - Writing testable service methods

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 2.1 (Registration Model)
> - ✓ Understanding of the service layer pattern
> - ✓ 17 tests passing

## Exercise Steps

### Overview

1. **Create the Registration Service**
2. **Export Service from Package**
3. **Add Service Unit Tests**
4. **Verify with pytest**

### **Step 1:** Create the Registration Service

The service layer handles all database operations for registrations.

1. **Create** a new file at `application/app/services/registration_service.py`

2. **Add** the following code:

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

> ℹ **Concept Deep Dive**
>
> The service layer pattern provides:
>
> - **Separation of Concerns**: Routes handle HTTP, services handle business logic
> - **Testability**: Services can be tested independently of Flask routes
> - **Reusability**: Same service methods can be used by multiple routes/APIs
>
> The `@staticmethod` decorator is used because these methods don't need instance state.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to call `db.session.commit()` after adding records
> - Not ordering results consistently (always specify order_by)
>
> ✓ **Quick check:** Three methods: create, get_all, get_count

### **Step 2:** Export Service from Package

1. **Open** `application/app/services/__init__.py`

2. **Add** the import for RegistrationService:

   ```python
   from .registration_service import RegistrationService
   ```

> ✓ **Quick check:** Both EntryService and RegistrationService are exported

### **Step 3:** Add Service Unit Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** a new test class at the end of the file:

   ```python
   class TestRegistrationService:
       """Tests for the RegistrationService."""

       def test_create_registration(self, app):
           """Test creating a registration via service."""
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
           """Test getting registrations when none exist."""
           with app.app_context():
               from app.services.registration_service import RegistrationService
               regs = RegistrationService.get_all_registrations()
               assert regs == []

       def test_get_all_registrations_with_data(self, app):
           """Test getting registrations when data exists."""
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
           """Test counting registrations."""
           with app.app_context():
               from app.services.registration_service import RegistrationService
               assert RegistrationService.get_registration_count() == 0
               RegistrationService.create_registration(
                   name='User', email='u@test.com', company='C', job_title='Dev'
               )
               assert RegistrationService.get_registration_count() == 1
   ```

> ✓ **Quick check:** Four new tests added for service methods

### **Step 4:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** all tests pass (17 existing + 4 new = 21 tests)

> ✓ **Success indicators:**
>
> - All 21 tests pass
> - No import errors
> - Service methods work correctly with database

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `registration_service.py` file exists with RegistrationService class
> - ☐ `__init__.py` exports RegistrationService
> - ☐ `pytest tests/test_routes.py -v` passes (21 tests)
> - ☐ EntryService still works (existing tests pass)

## Common Issues

> **If you encounter problems:**
>
> **ImportError: cannot import RegistrationService:** Check that `__init__.py` has the import
>
> **IntegrityError on create:** Ensure all required fields are provided
>
> **Empty results when data exists:** Check that you're in the correct app context
>
> **Still stuck?** Compare with the EntryService in `app/services/entry_service.py`

## Summary

You've created the RegistrationService with:

- ✓ Create registration method with database persistence
- ✓ Get all registrations ordered by date
- ✓ Get registration count for admin dashboard
- ✓ Four unit tests confirming service behavior

> **Key takeaway:** The service layer encapsulates all database operations, making routes cleaner and code more testable.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add a `get_registration_by_email()` method
> - Add pagination to `get_all_registrations()`
> - Add a `delete_registration()` method

## Done!

The Registration service layer is ready. Next phase will enhance the landing page with a call-to-action.
