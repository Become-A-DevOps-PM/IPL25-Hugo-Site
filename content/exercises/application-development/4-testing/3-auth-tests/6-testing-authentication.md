+++
title = "Testing Authentication"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Test the AuthService and User model for user creation, authentication, and password hashing"
weight = 6
+++

# Testing Authentication

## Goal

Test the AuthService and User model to verify that user creation, credential authentication, and password hashing all work correctly.

> **What you'll learn:**
>
> - How to test service-layer authentication logic
> - How to verify password hashing produces secure, salted hashes
> - How to test both positive and negative authentication paths
> - Why testing inactive user behavior matters for security

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed the Authentication and Security exercise suite
> - ✓ Working `AuthService` at `app/business/services/auth_service.py` with `authenticate()`, `create_user()`, and `get_user_by_id()`
> - ✓ `DuplicateUsernameError` exception defined in the auth service module
> - ✓ `User` model at `app/data/models/user.py` with `set_password()`, `check_password()`, and `is_active`
> - ✓ Working `conftest.py` with the `app` fixture (in-memory SQLite)

## Exercise Steps

### Overview

1. **Test User Creation**
2. **Test Authentication**
3. **Test Inactive Users**
4. **Test Password Hashing**
5. **Run and Verify**

### **Step 1:** Test User Creation

Authentication is security-critical code. A bug in user creation or password storage can compromise the entire application. These tests verify that `AuthService.create_user()` correctly creates users, hashes passwords, and rejects duplicate usernames.

1. **Create** a new test file:

   > `tests/test_auth_service.py`

   ```python
   """Tests for the AuthService authentication logic."""

   import pytest
   from app.business.services.auth_service import AuthService, DuplicateUsernameError


   class TestCreateUser:
       """Test user creation through AuthService."""

       def test_create_user_returns_user(self, app):
           """create_user() returns a User instance."""
           user = AuthService.create_user("admin", "password123")
           assert user is not None
           assert user.username == "admin"

       def test_password_is_hashed(self, app):
           """Stored password is not plain text."""
           user = AuthService.create_user("admin", "password123")
           assert user.password_hash != "password123"
           assert len(user.password_hash) > 50

       def test_duplicate_username_raises_error(self, app):
           """Creating user with existing username raises DuplicateUsernameError."""
           AuthService.create_user("admin", "password123")
           with pytest.raises(DuplicateUsernameError):
               AuthService.create_user("admin", "different_password")
   ```

> ℹ **Concept Deep Dive**
>
> The `test_password_is_hashed` test checks two things: the stored hash is not the plain text password, and the hash is long enough to be a real cryptographic hash. Werkzeug's `generate_password_hash` produces hashes well over 50 characters, so a short value would indicate something went wrong.
>
> The duplicate username test verifies that `AuthService` raises a custom `DuplicateUsernameError` rather than letting a raw database error propagate. Custom exceptions give the presentation layer meaningful error messages to display to users.
>
> ✓ **Quick check:** Three test methods covering user creation, password hashing, and duplicate prevention

### **Step 2:** Test Authentication

The `authenticate()` method is the gateway to the application. It must return a `User` for valid credentials and `None` for invalid ones. Testing both paths ensures the method behaves correctly in all scenarios.

1. **Add** the following test class to the same file:

   > `tests/test_auth_service.py`

   ```python
   class TestAuthenticate:
       """Test credential verification."""

       def test_correct_credentials(self, app):
           """Valid credentials return User."""
           AuthService.create_user("admin", "password123")
           user = AuthService.authenticate("admin", "password123")
           assert user is not None
           assert user.username == "admin"

       def test_wrong_password(self, app):
           """Wrong password returns None."""
           AuthService.create_user("admin", "password123")
           result = AuthService.authenticate("admin", "wrongpassword")
           assert result is None

       def test_nonexistent_username(self, app):
           """Non-existent username returns None."""
           result = AuthService.authenticate("nobody", "password123")
           assert result is None
   ```

> ℹ **Concept Deep Dive**
>
> `authenticate()` returns `None` for both wrong password and non-existent user. This is a security best practice -- attackers cannot determine whether a username exists by observing different error responses. This defense is called preventing **username enumeration attacks**. If the method returned different errors for "user not found" vs "wrong password," an attacker could first discover valid usernames, then focus on brute-forcing passwords for those accounts.
>
> Testing both the wrong-password and nonexistent-username cases confirms that the method returns the same result (`None`) for both, making the authentication response indistinguishable to an attacker.
>
> ✓ **Quick check:** Three test methods covering valid login, wrong password, and nonexistent user

### **Step 3:** Test Inactive Users

Applications need the ability to disable user accounts without deleting them. The `is_active` flag on the `User` model controls this. An inactive user must not be able to authenticate, even with the correct password.

1. **Add** the following test class to the same file:

   > `tests/test_auth_service.py`

   ```python
   class TestInactiveUsers:
       """Test that inactive users cannot authenticate."""

       def test_inactive_user_returns_none(self, app):
           """Inactive user cannot authenticate even with correct password."""
           from app import db
           user = AuthService.create_user("admin", "password123")
           user.is_active = False
           db.session.commit()
           result = AuthService.authenticate("admin", "password123")
           assert result is None
   ```

> ℹ **Concept Deep Dive**
>
> This test creates a user, deactivates the account by setting `is_active = False`, commits the change to the database, and then attempts to authenticate. The expected result is `None` -- the correct password alone is not sufficient if the account is disabled.
>
> This behavior is important for security operations: when an employee leaves, an account is compromised, or suspicious activity is detected, administrators can immediately disable the account without deleting it. The user's data is preserved for auditing purposes, but access is revoked.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to call `db.session.commit()` after setting `is_active = False` -- the change only exists in Python memory until committed
> - Not importing `db` from the app package -- the test needs the session to persist the change
>
> ✓ **Quick check:** One test method verifying that inactive users are blocked from authentication

### **Step 4:** Test Password Hashing

Password hashing is the foundation of authentication security. These tests verify that `check_password()` works correctly and that the hashing algorithm uses unique salts per user.

1. **Add** the following test class to the same file:

   > `tests/test_auth_service.py`

   ```python
   class TestPasswordHashing:
       """Test password hash behavior."""

       def test_check_password_correct(self, app):
           """check_password() returns True for correct password."""
           user = AuthService.create_user("admin", "password123")
           assert user.check_password("password123") is True

       def test_check_password_wrong(self, app):
           """check_password() returns False for wrong password."""
           user = AuthService.create_user("admin", "password123")
           assert user.check_password("wrongpassword") is False

       def test_different_users_different_hashes(self, app):
           """Same password produces different hashes for different users."""
           user1 = AuthService.create_user("admin1", "samepassword")
           user2 = AuthService.create_user("admin2", "samepassword")
           assert user1.password_hash != user2.password_hash
   ```

> ℹ **Concept Deep Dive**
>
> The last test proves that PBKDF2 uses a random salt per hash. Even identical passwords produce different hashes, which prevents attackers from comparing hashes across users. Without salting, an attacker who obtains the database could immediately see which users share the same password, dramatically reducing the effort needed to crack accounts.
>
> Werkzeug's `generate_password_hash` handles salting automatically. Each call generates a new random salt, combines it with the password, and runs the PBKDF2 key derivation function. The salt is stored as part of the hash string, so `check_password_hash` can extract it during verification.
>
> ✓ **Quick check:** Three test methods covering correct password, wrong password, and unique salt verification

### **Step 5:** Run and Verify

Each test starts with an empty database because the `app` fixture drops all tables after each test. This isolation means data created in one test never leaks into another.

1. **Run** the authentication tests:

   ```bash
   python -m pytest tests/test_auth_service.py -v
   ```

2. **Verify** all tests pass with output similar to:

   ```text
   tests/test_auth_service.py::TestCreateUser::test_create_user_returns_user PASSED
   tests/test_auth_service.py::TestCreateUser::test_password_is_hashed PASSED
   tests/test_auth_service.py::TestCreateUser::test_duplicate_username_raises_error PASSED
   tests/test_auth_service.py::TestAuthenticate::test_correct_credentials PASSED
   tests/test_auth_service.py::TestAuthenticate::test_wrong_password PASSED
   tests/test_auth_service.py::TestAuthenticate::test_nonexistent_username PASSED
   tests/test_auth_service.py::TestInactiveUsers::test_inactive_user_returns_none PASSED
   tests/test_auth_service.py::TestPasswordHashing::test_check_password_correct PASSED
   tests/test_auth_service.py::TestPasswordHashing::test_check_password_wrong PASSED
   tests/test_auth_service.py::TestPasswordHashing::test_different_users_different_hashes PASSED
   ```

3. **Confirm** the following success indicators:
   - User creation works with hashed password
   - Authentication succeeds with correct credentials
   - Authentication fails with wrong password, non-existent user, or inactive user
   - Duplicate usernames are caught with `DuplicateUsernameError`
   - Same password produces different hashes for different users

> ✓ **Quick check:** All 10 tests pass and each test is isolated with a fresh database

## Common Issues

> **If you encounter problems:**
>
> **"DuplicateUsernameError not raised":** Check that the username column has `unique=True` in the User model and that `AuthService.create_user()` checks for existing usernames before inserting.
>
> **Inactive user test fails:** Verify that `authenticate()` checks `user.is_active` before returning the user. The method should return `None` if the user exists but is inactive.
>
> **Different hashes test fails:** This would mean the hashing is not using salts, which is very unlikely with Werkzeug's `generate_password_hash`. Verify you are using Werkzeug's built-in hashing and not a custom implementation.
>
> **"Table 'users' doesn't exist":** Ensure the `User` model is imported somewhere that triggers `db.create_all()` to include the users table. Check that your `conftest.py` fixture calls `db.create_all()` inside the application context.
>
> **Still stuck?** Run a single test with `python -m pytest tests/test_auth_service.py::TestCreateUser::test_create_user_returns_user -v` to isolate the failure.

## Summary

You have successfully tested the authentication service:

- ✓ Tested user creation with hashed passwords
- ✓ Verified authentication with correct and incorrect credentials
- ✓ Confirmed inactive users are blocked from authenticating
- ✓ Proved password hashing uses unique salts per user
- ✓ Validated duplicate username detection with custom exceptions

> **Key takeaway:** Auth tests verify security-critical code works correctly. Testing both positive cases (valid login) and negative cases (wrong password, inactive user) ensures the authentication service is robust. These tests form a safety net that catches regressions whenever authentication logic is modified.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add tests for very long passwords to verify no truncation occurs
> - Test concurrent user creation to check for race conditions
> - Add tests for `get_user_by_id()` edge cases (nonexistent ID, deleted user)
> - Research security testing tools like `bandit` (static analysis) and `safety` (dependency vulnerabilities)

## Done! 🎉

You have tested the authentication service and password hashing. These tests ensure the security foundation of your application is solid.
