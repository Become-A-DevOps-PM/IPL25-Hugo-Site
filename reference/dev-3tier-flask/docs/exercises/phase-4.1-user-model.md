# User Model with Password Hashing

## Goal

Create a User model with secure password hashing using Werkzeug for admin authentication.

> **What you'll learn:**
>
> - Creating SQLAlchemy models with Flask-Login integration
> - Secure password hashing with Werkzeug (PBKDF2)
> - The UserMixin class and its methods
> - Why passwords should never be stored in plain text

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 4.0 (Flask-Login installed)
> - ✓ All 71 tests passing
> - ✓ Understanding of SQLAlchemy models

## Exercise Steps

### Overview

1. **Create User Model**
2. **Export Model from Package**
3. **Generate Database Migration**
4. **Add User Model Tests**
5. **Verify with pytest**

### **Step 1:** Create User Model

The User model stores authentication credentials with securely hashed passwords.

1. **Create** `application/app/models/user.py`:

   ```python
   """User model for admin authentication."""
   from flask_login import UserMixin
   from werkzeug.security import generate_password_hash, check_password_hash
   from app.extensions import db


   class User(UserMixin, db.Model):
       """Admin user with password authentication.

       Uses Werkzeug's security functions for password hashing.
       Passwords are never stored in plain text.
       """

       __tablename__ = 'users'

       id = db.Column(db.Integer, primary_key=True)
       username = db.Column(db.String(80), unique=True, nullable=False, index=True)
       password_hash = db.Column(db.String(256), nullable=False)
       is_active = db.Column(db.Boolean, default=True)

       def __repr__(self):
           return f'<User {self.username}>'

       def set_password(self, password):
           """Hash and store password.

           Args:
               password: Plain text password to hash
           """
           self.password_hash = generate_password_hash(password)

       def check_password(self, password):
           """Verify password against stored hash.

           Args:
               password: Plain text password to verify

           Returns:
               bool: True if password matches, False otherwise
           """
           return check_password_hash(self.password_hash, password)
   ```

> ℹ **Concept Deep Dive**
>
> - **UserMixin** provides default implementations for Flask-Login required methods
> - **generate_password_hash()** uses PBKDF2 with 260,000 iterations by default
> - **password_hash** column stores the hash, salt, and algorithm info
> - **check_password()** securely compares without timing attacks
> - **is_active** allows disabling users without deleting them
>
> UserMixin provides these methods automatically:
>
> - `is_authenticated`: Returns True if logged in
> - `is_active`: Checks if user is enabled
> - `is_anonymous`: Returns False for actual users
> - `get_id()`: Returns the user ID as a string
>
> ⚠ **Common Mistakes**
>
> - Storing plain text passwords (NEVER do this!)
> - Using MD5 or SHA1 for passwords (use PBKDF2, bcrypt, or argon2)
> - Not inheriting from UserMixin
>
> ✓ **Quick check:** User model has set_password() and check_password() methods

### **Step 2:** Export Model from Package

1. **Open** `application/app/models/__init__.py`

2. **Update** to include User:

   ```python
   """Data layer models.

   All SQLAlchemy models are exported from this package.
   """

   from app.models.entry import Entry
   from app.models.registration import Registration
   from app.models.user import User

   __all__ = ['Entry', 'Registration', 'User']
   ```

> ✓ **Quick check:** User is exported alongside Entry and Registration

### **Step 3:** Generate Database Migration

1. **Run** migration commands:

   ```bash
   cd application
   source .venv/bin/activate
   flask db migrate -m "Add user model for authentication"
   flask db upgrade
   ```

> ℹ **Concept Deep Dive**
>
> The migration creates a `users` table with:
>
> - `id`: Primary key
> - `username`: Unique, indexed for fast lookups
> - `password_hash`: Stores the secure hash (not plain text!)
> - `is_active`: Boolean for user status
>
> ✓ **Quick check:** Migration file created in `migrations/versions/`

### **Step 4:** Add User Model Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

   ```python
   class TestUserModel:
       """Tests for the User model."""

       def test_user_repr(self, app):
           """Test User string representation."""
           with app.app_context():
               from app.models.user import User
               user = User(username='testadmin')
               user.set_password('testpass123')
               assert '<User testadmin>' in repr(user)

       def test_user_set_password_hashes(self, app):
           """Test that set_password creates a hash, not plain text."""
           with app.app_context():
               from app.models.user import User
               user = User(username='hashtest')
               user.set_password('mypassword')
               assert user.password_hash != 'mypassword'
               assert len(user.password_hash) > 50  # Hashes are long

       def test_user_check_password_correct(self, app):
           """Test password verification with correct password."""
           with app.app_context():
               from app.models.user import User
               user = User(username='verifytest')
               user.set_password('correctpass')
               assert user.check_password('correctpass') is True

       def test_user_check_password_incorrect(self, app):
           """Test password verification with incorrect password."""
           with app.app_context():
               from app.models.user import User
               user = User(username='verifytest2')
               user.set_password('correctpass')
               assert user.check_password('wrongpass') is False

       def test_user_is_active_default(self, app):
           """Test that is_active defaults to True."""
           with app.app_context():
               from app.models.user import User
               user = User(username='activetest')
               user.set_password('password')
               assert user.is_active is True
   ```

> ✓ **Quick check:** 5 new tests for User model functionality

### **Step 5:** Verify with pytest

1. **Run** the tests:

   ```bash
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 71 + 5 = 76 tests passing

> ✓ **Success indicators:**
>
> - All 76 tests pass
> - Password hashing produces different output than input
> - Password verification works correctly

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `models/user.py` exists with User class
> - ☐ User inherits from UserMixin and db.Model
> - ☐ `set_password()` hashes the password
> - ☐ `check_password()` verifies against hash
> - ☐ `models/__init__.py` exports User
> - ☐ Migration created and applied
> - ☐ `pytest tests/test_routes.py -v` passes (76 tests)

## Common Issues

> **If you encounter problems:**
>
> **ImportError for UserMixin:** Ensure Flask-Login is installed
>
> **Migration fails:** Delete local.db and run `flask db upgrade` fresh
>
> **Hash too short:** Verify using generate_password_hash from werkzeug.security
>
> **check_password always False:** Ensure same password hash comparison method

## Summary

You've created the User model:

- ✓ SQLAlchemy model with Flask-Login integration
- ✓ Secure password hashing with PBKDF2
- ✓ Password verification without timing attacks
- ✓ is_active flag for user management
- ✓ 5 new tests verify authentication behavior

> **Key takeaway:** Never store plain text passwords. Werkzeug's PBKDF2 implementation provides secure, salted password hashing that protects user credentials even if the database is compromised.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Compare PBKDF2, bcrypt, and argon2 algorithms
> - Add email field for password reset functionality
> - Implement password complexity requirements

## Done!

User model is complete. Next phase will create the authentication service.
