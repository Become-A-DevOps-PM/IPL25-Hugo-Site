+++
title = "Authentication Service"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Create a service that handles user authentication and creation in the business layer"
weight = 3
+++

# Authentication Service

## Goal

Create an authentication service in the business layer that handles user credential verification and account creation, following the three-tier architecture pattern established in earlier exercises.

> **What you'll learn:**
>
> - How to create a service that encapsulates authentication logic in the business layer
> - When to use static methods vs. instance methods in service classes
> - How to handle database errors with domain-specific exceptions
> - Best practices for secure authentication checks

## Prerequisites

> **Before starting, ensure you have:**
>
> - Completed the User Model exercise with password hashing
> - User model at `app/data/models/user.py` with `set_password()`, `check_password()`, and `is_active`
> - Flask application running with database migrations applied
> - `app/business/services/__init__.py` exists

## Exercise Steps

### Overview

1. **Create the Authentication Service**
2. **Understand the Custom Exception**
3. **Update Service Package Exports**
4. **Test in Flask Shell**
5. **Verify Three-Tier Adherence**

### **Step 1:** Create the Authentication Service

Following three-tier architecture, authentication logic lives in the business layer as a service. The service coordinates between the User model and the rest of the application. It handles credential verification, user creation, and encapsulates all auth-related business rules. Just like the `SubscriptionService` validates and processes subscription data, the `AuthService` validates credentials and manages user accounts.

1. **Navigate to** the `app/business/services` directory

2. **Create a new file** named `auth_service.py`

3. **Add the following code:**

   > `app/business/services/auth_service.py`

   ```python
   """
   Authentication service - handles user authentication and management.

   This service sits in the business layer, coordinating between the
   presentation layer (routes) and the data layer (User model).
   """

   from sqlalchemy.exc import IntegrityError
   from app import db
   from app.data.models.user import User


   class DuplicateUsernameError(Exception):
       """Raised when attempting to create a user with an existing username."""
       pass


   class AuthService:
       """Service for authentication-related business logic."""

       @staticmethod
       def authenticate(username, password):
           """
           Authenticate a user by username and password.

           Checks that the user exists, is active, and the password matches.

           Args:
               username: The username to authenticate
               password: The plain text password to verify

           Returns:
               User instance if authentication succeeds, None otherwise
           """
           user = User.query.filter_by(username=username).first()
           if user and user.is_active and user.check_password(password):
               return user
           return None

       @staticmethod
       def create_user(username, password):
           """
           Create a new user with hashed password.

           Args:
               username: Unique username for the new user
               password: Plain text password (will be hashed)

           Returns:
               The newly created User instance

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
           """
           Get a user by their database ID.

           Used by Flask-Login's user_loader callback.

           Args:
               user_id: The user's database ID (as string or int)

           Returns:
               User instance if found, None otherwise
           """
           return db.session.get(User, int(user_id))
   ```

> ℹ **Concept Deep Dive**
>
> The service uses `@staticmethod` because it doesn't need instance state -- all methods operate on the database directly. This is different from `SubscriptionService`, which uses instance methods because it holds a repository reference. Since `AuthService` queries the `User` model directly, static methods keep the interface simple.
>
> The `authenticate()` method checks three things: user exists, user is active, and password matches. If ANY of these checks fail, it returns `None` without revealing which check failed. This is a security best practice -- an attacker cannot determine whether a username exists or a password is wrong.
>
> The `create_user()` method catches `IntegrityError` from SQLAlchemy and re-raises it as `DuplicateUsernameError`, a domain-specific exception. This translates a database-level error into a meaningful business-layer error that routes can handle clearly.
>
> ⚠ **Common Mistakes**
>
> - Importing `IntegrityError` from Flask instead of `sqlalchemy.exc` -- Flask does not export this exception
> - Forgetting `db.session.rollback()` after catching `IntegrityError` leaves the session in a broken state
> - Returning different error messages for "user not found" vs. "wrong password" leaks information to attackers
>
> ✓ **Quick check:** File created at `app/business/services/auth_service.py` with three static methods and one custom exception

### **Step 2:** Understand the Custom Exception

The `DuplicateUsernameError` exception is already included in the `auth_service.py` file from Step 1. This step explains why custom exceptions matter and how the error handling flow works.

Custom exceptions make error handling clearer and more intentional. When a route catches `DuplicateUsernameError`, the intent is immediately obvious. Compare this to catching a generic `IntegrityError` -- which could mean any database constraint violation, not just a duplicate username.

The critical detail in the exception handling is the `db.session.rollback()` call before raising:

   > `app/business/services/auth_service.py`

   ```python
   except IntegrityError:
       db.session.rollback()
       raise DuplicateUsernameError(f"Username '{username}' already exists.")
   ```

Without the rollback, the SQLAlchemy session remains in an invalid state. Any subsequent database operations in the same request would fail with `InvalidRequestError`. The rollback clears the failed transaction so the application can continue operating normally.

> ℹ **Concept Deep Dive**
>
> **Exception hierarchy in this flow:**
>
> 1. SQLAlchemy raises `IntegrityError` (database layer)
> 2. `AuthService` catches it and raises `DuplicateUsernameError` (business layer)
> 3. Route catches `DuplicateUsernameError` and shows an error message (presentation layer)
>
> Each layer translates errors into its own language. The route never sees SQLAlchemy errors. The service never sees HTTP errors. This clean separation means you can change your database from SQLite to PostgreSQL without touching any route code.
>
> ✓ **Quick check:** You understand why `db.session.rollback()` is called before raising the custom exception

### **Step 3:** Update Service Package Exports

**Update** the services package `__init__.py` to export the new authentication service alongside the existing subscription service. This makes imports cleaner throughout the application.

1. **Open** the file `app/business/services/__init__.py`

2. **Replace** the contents with the following:

   > `app/business/services/__init__.py`

   ```python
   """Business services package."""

   from .subscription_service import SubscriptionService
   from .auth_service import AuthService, DuplicateUsernameError

   __all__ = ["SubscriptionService", "AuthService", "DuplicateUsernameError"]
   ```

> ℹ **Concept Deep Dive**
>
> The `__all__` list controls what gets exported when someone writes `from app.business.services import *`. More importantly, it serves as documentation -- anyone looking at this file can immediately see what the services package provides.
>
> Exporting `DuplicateUsernameError` alongside `AuthService` means routes can import both from the same package:
>
> ```python
> from app.business.services import AuthService, DuplicateUsernameError
> ```
>
> This is cleaner than importing from the individual module file.
>
> ✓ **Quick check:** `__init__.py` exports `SubscriptionService`, `AuthService`, and `DuplicateUsernameError`

### **Step 4:** Test in Flask Shell

**Verify** the authentication service works correctly by testing all methods interactively. The Flask shell provides an application context so database operations work properly.

1. **Start the Flask shell:**

   ```bash
   flask shell
   ```

2. **Test user creation and authentication:**

   ```python
   from app.business.services.auth_service import AuthService, DuplicateUsernameError

   # Create a user
   user = AuthService.create_user("admin", "password123")
   print(f"Created: {user}")  # <User admin>

   # Authenticate with correct password
   result = AuthService.authenticate("admin", "password123")
   print(f"Auth result: {result}")  # <User admin>

   # Authenticate with wrong password
   result = AuthService.authenticate("admin", "wrongpassword")
   print(f"Wrong password: {result}")  # None

   # Authenticate with non-existent user
   result = AuthService.authenticate("nobody", "password123")
   print(f"No user: {result}")  # None
   ```

3. **Test duplicate username handling:**

   ```python
   # Try duplicate username
   try:
       AuthService.create_user("admin", "different_password")
   except DuplicateUsernameError as e:
       print(f"Caught: {e}")  # Username 'admin' already exists.
   ```

4. **Test inactive user rejection:**

   ```python
   # Test inactive user
   from app.data.models.user import User
   from app import db
   user.is_active = False
   db.session.commit()
   result = AuthService.authenticate("admin", "password123")
   print(f"Inactive user: {result}")  # None
   ```

> ℹ **Concept Deep Dive**
>
> Testing in Flask shell proves the business layer works independently of the presentation layer. No HTTP requests are needed -- the service operates purely on business logic and database operations. This independence is the core benefit of three-tier architecture.
>
> ⚠ **Common Mistakes**
>
> - Running these commands outside Flask shell causes `RuntimeError: Working outside of application context`
> - Forgetting that `create_user` was already called -- if you restart the shell and the user exists, you'll get `DuplicateUsernameError`
> - Not resetting `is_active` back to `True` after testing -- the admin user will remain locked out
>
> ✓ **Quick check:** All five test scenarios produce the expected output

### **Step 5:** Verify Three-Tier Adherence

**Review** what each layer does to confirm the authentication service follows proper three-tier architecture. This verification ensures the layers remain independent and focused on their responsibilities.

1. **Check what the service handles (business layer):**
   - Validates credentials (username + password + active status)
   - Creates users with hashed passwords
   - Handles duplicate username conflicts
   - Provides user lookup by ID

2. **Check what the model handles (data layer):**
   - Password hashing (`set_password()`)
   - Password verification (`check_password()`)
   - Database field definitions and constraints

3. **Verify the service does NOT:**
   - Import Flask request objects
   - Render templates
   - Handle HTTP status codes
   - Access `request.form` or `session`

4. **Verify the model does NOT:**
   - Check business rules like duplicate usernames
   - Handle authentication flow logic
   - Make decisions about active/inactive users

5. **Run one final verification** in Flask shell:

   ```python
   import inspect
   from app.business.services.auth_service import AuthService

   source = inspect.getsource(AuthService)
   assert "request" not in source, "Service should not import Flask request"
   assert "render_template" not in source, "Service should not render templates"
   print("Three-tier verification passed!")
   ```

> ✓ **Success indicators:**
>
> - `AuthService.authenticate()` returns User on success, None on failure
> - `AuthService.create_user()` creates and returns User
> - `DuplicateUsernameError` raised for duplicate usernames
> - Inactive users cannot authenticate
> - Service does not import any Flask HTTP modules
>
> ✓ **Final verification checklist:**
>
> - [ ] `auth_service.py` created in `app/business/services/`
> - [ ] `AuthService` has `authenticate`, `create_user`, and `get_user_by_id` methods
> - [ ] `DuplicateUsernameError` defined for clear error handling
> - [ ] `__init__.py` updated to export new service and exception
> - [ ] All Flask shell tests produce expected results
> - [ ] Service contains no Flask HTTP imports

## Common Issues

> **If you encounter problems:**
>
> **"IntegrityError" not caught:** Ensure you import from `sqlalchemy.exc`, not from Flask
>
> **Session broken after IntegrityError:** Must call `db.session.rollback()` before raising the custom exception
>
> **authenticate() always returns None:** Check that the password was hashed with `set_password()`, not stored as plain text
>
> **"AttributeError: 'NoneType' has no attribute 'check_password'":** The user wasn't found -- `filter_by()` returns None for non-existent users. The `authenticate` method handles this with the `user and ...` check
>
> **"ModuleNotFoundError: No module named 'app.business.services.auth_service'":** Verify the file is saved at exactly `app/business/services/auth_service.py`
>
> **Still stuck?** Use Flask shell to test each component individually -- start with `User.query.all()` to verify the model works, then test service methods one at a time

## Summary

You've successfully created an authentication service which:

- ✓ Created `AuthService` with `authenticate`, `create_user`, and `get_user_by_id` methods
- ✓ Added `DuplicateUsernameError` for clear, domain-specific error handling
- ✓ Followed the three-tier pattern: service handles business logic, model handles data
- ✓ Verified layer independence through Flask shell testing

> **Key takeaway:** The authentication service encapsulates all auth-related business logic in the business layer. Routes will call the service (not the model directly), and the service coordinates between the presentation and data layers. By returning `None` for all authentication failures without distinguishing the cause, the service implements a security best practice that protects against user enumeration attacks.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add password strength validation in `create_user()` (minimum length, complexity rules)
> - Implement account lockout after repeated failed authentication attempts
> - Add logging for authentication attempts (successful and failed)
> - Research token-based authentication as an alternative to session-based login

## Done!

You've created an authentication service that handles user management in the business layer. This service provides the `authenticate()`, `create_user()`, and `get_user_by_id()` methods needed for session-based login.
