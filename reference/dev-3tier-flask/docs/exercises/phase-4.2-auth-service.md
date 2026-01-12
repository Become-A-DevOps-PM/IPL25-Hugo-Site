# Authentication Service

## Goal

Create an AuthService with methods for authenticating users and creating admin accounts.

> **What you'll learn:**
>
> - Service layer pattern for authentication
> - User lookup and password verification
> - Handling duplicate username errors
> - Database transaction management with rollback

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 4.1 (User model)
> - ✓ All 79 tests passing
> - ✓ Understanding of service layer pattern

## Exercise Steps

### Overview

1. **Create Auth Service**
2. **Export Service from Package**
3. **Add Auth Service Tests**
4. **Verify with pytest**

### **Step 1:** Create Auth Service

The AuthService encapsulates all authentication business logic, keeping routes thin.

1. **Create** `application/app/services/auth_service.py`:

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

> ℹ **Concept Deep Dive**
>
> - **authenticate()** checks username, is_active flag, and password in one call
> - **create_user()** catches IntegrityError to handle database-level uniqueness
> - **db.session.rollback()** ensures failed transactions don't corrupt the session
> - **get_user_by_id()** uses `db.session.get()` for efficient primary key lookup
> - Returns None instead of raising exceptions for failed lookups (cleaner flow)
>
> ⚠ **Common Mistakes**
>
> - Forgetting to check is_active before allowing authentication
> - Not rolling back the session after IntegrityError
> - Using `User.query.get()` instead of `db.session.get()` (deprecated in SQLAlchemy 2.0)
>
> ✓ **Quick check:** AuthService has authenticate, create_user, get_user_by_id, get_user_by_username

### **Step 2:** Export Service from Package

1. **Open** `application/app/services/__init__.py`

2. **Update** to include AuthService:

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

> ✓ **Quick check:** AuthService and DuplicateUsernameError are exported

### **Step 3:** Add Auth Service Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

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

> ✓ **Quick check:** 8 new tests for AuthService functionality

### **Step 4:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 79 + 8 = 87 tests passing

> ✓ **Success indicators:**
>
> - All 87 tests pass
> - User creation works with proper hashing
> - Authentication validates correctly
> - Inactive users cannot authenticate

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `services/auth_service.py` exists with AuthService class
> - ☐ DuplicateUsernameError exception defined
> - ☐ authenticate() checks username, is_active, and password
> - ☐ create_user() handles IntegrityError with rollback
> - ☐ `services/__init__.py` exports AuthService and DuplicateUsernameError
> - ☐ `pytest tests/test_routes.py -v` passes (87 tests)

## Common Issues

> **If you encounter problems:**
>
> **IntegrityError not caught:** Ensure unique constraint exists on username column
>
> **ImportError for db:** Import from app.extensions, not flask_sqlalchemy
>
> **Session rollback issues:** Always rollback in the except block before raising
>
> **User.query.get() deprecated:** Use db.session.get(User, id) instead

## Summary

You've created the authentication service:

- ✓ AuthService with authenticate, create_user, and lookup methods
- ✓ DuplicateUsernameError for unique username violations
- ✓ Database transaction handling with rollback
- ✓ Inactive user checking in authenticate flow
- ✓ 8 new tests verify service behavior

> **Key takeaway:** The service layer isolates business logic from routes. Authentication checks happen in one place, making the code easier to test, maintain, and secure.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add password strength validation in create_user
> - Implement account lockout after failed attempts
> - Add login attempt logging for security auditing

## Done!

Authentication service is complete. Next phase will configure Flask-Login integration.
