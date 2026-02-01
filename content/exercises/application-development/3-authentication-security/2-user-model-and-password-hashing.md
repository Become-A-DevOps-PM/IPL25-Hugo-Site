+++
title = "User Model and Password Hashing"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Create a User model with secure password storage using Werkzeug's PBKDF2 hashing"
weight = 2
+++

# User Model and Password Hashing

## Goal

Create a User model with secure password storage using Werkzeug's PBKDF2 hashing, generate a database migration, and verify that password hashing and verification work correctly.

> **What you'll learn:**
>
> - How to create a SQLAlchemy model for user authentication
> - How Werkzeug's PBKDF2 password hashing works
> - How to generate and apply database migrations for new models
> - How to verify password hashing and unique constraints

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Flask application running with `flask run`
> - ✓ Flask-Migrate set up with an existing `migrations/` directory
> - ✓ Subscriber model working in `app/data/models/subscriber.py`
> - ✓ Understanding of SQLAlchemy models and database migrations

## Exercise Steps

### Overview

1. **Create the User Model**
2. **Update Model Imports**
3. **Run Database Migration**
4. **Test in Flask Shell**
5. **Verify and Explore**

### **Step 1:** Create the User Model

Authentication requires storing user credentials securely. The most important rule of password storage: **never store passwords in plain text**. Werkzeug, which is already installed as a Flask dependency, provides `generate_password_hash()` and `check_password_hash()` using the PBKDF2 algorithm.

The User model encapsulates all password operations so the rest of the application never touches raw passwords.

1. **Create** a new file `app/data/models/user.py`

2. **Add** the following code:

   > `app/data/models/user.py`

   ```python
   """User model for admin authentication."""

   from werkzeug.security import generate_password_hash, check_password_hash
   from app import db


   class User(db.Model):
       """Admin user with secure password storage.

       Passwords are hashed using Werkzeug's PBKDF2 implementation.
       Never stores plain text passwords.
       """

       __tablename__ = "users"

       id = db.Column(db.Integer, primary_key=True)
       username = db.Column(db.String(80), unique=True, nullable=False, index=True)
       password_hash = db.Column(db.String(256), nullable=False)
       is_active = db.Column(db.Boolean, default=True)

       def __repr__(self):
           return f"<User {self.username}>"

       def set_password(self, password):
           """Hash and store a password.

           Args:
               password: Plain text password to hash
           """
           self.password_hash = generate_password_hash(password)

       def check_password(self, password):
           """Verify a password against the stored hash.

           Args:
               password: Plain text password to verify

           Returns:
               True if password matches, False otherwise
           """
           return check_password_hash(self.password_hash, password)
   ```

> ℹ **Concept Deep Dive**
>
> **PBKDF2** (Password-Based Key Derivation Function 2) adds a random salt and runs the hash through thousands of iterations. This provides three layers of protection:
>
> 1. **Salt** - Same password produces different hashes each time, defeating precomputed lookup tables
> 2. **Iterations** - Brute-force attacks are computationally expensive and slow
> 3. **Rainbow table resistance** - The random salt makes precomputed tables useless
>
> The `password_hash` column stores the algorithm, salt, and hash together in a single string. Werkzeug handles parsing this string automatically when verifying passwords.
>
> ⚠ **Common Mistakes**
>
> - Storing passwords in plain text or using reversible encryption
> - Using fast hash algorithms like MD5 or SHA256 without salt and iterations
> - Comparing password hashes with `==` instead of using `check_password_hash()` (timing attacks)
>
> ✓ **Quick check:** The User model has `set_password()` and `check_password()` methods but no plain text password field

### **Step 2:** Update Model Imports

Flask-Migrate needs to discover the User model to generate a migration. This requires updating the models package and ensuring the model is imported during application startup.

1. **Open** `app/data/models/__init__.py` and **add** the User export:

   > `app/data/models/__init__.py`

   ```python
   """Data models package."""

   from .subscriber import Subscriber
   from .user import User

   __all__ = ["Subscriber", "User"]
   ```

2. **Open** `app/__init__.py` and **add** the User import after existing model imports so Flask-Migrate's `autogenerate` detects the new model:

   > `app/__init__.py`

   ```python
   from app.data.models.user import User  # noqa: F401
   ```

   This import is needed for Flask-Migrate to detect the User model and create the migration. Without it, `flask db migrate` will report "No changes detected."

> ⚠ **Common Mistakes**
>
> - Forgetting to import User in `__init__.py` causes Flask-Migrate to generate an empty migration
> - Not updating `__all__` makes the model harder to discover for other developers
>
> ✓ **Quick check:** Both `Subscriber` and `User` appear in `app/data/models/__init__.py`

### **Step 3:** Run Database Migration

Generate and apply a migration to create the `users` table in the database.

1. **Generate** the migration:

   ```bash
   flask db migrate -m "Add user model"
   ```

   This compares the current database schema against your models and generates a migration script in `migrations/versions/`.

2. **Apply** the migration:

   ```bash
   flask db upgrade
   ```

   This executes the migration and creates the `users` table in the database.

> ℹ **Concept Deep Dive**
>
> Flask-Migrate uses Alembic under the hood to version database schema changes. The workflow is:
>
> - `flask db migrate` - Generates a Python script describing the schema change
> - `flask db upgrade` - Applies the migration to the database
> - `flask db downgrade` - Reverts the most recent migration (rollback)
>
> Each migration is a versioned Python file. This ensures database changes are tracked in version control and reproducible across all environments (development, staging, production).
>
> ✓ **Quick check:** Run `ls migrations/versions/` to confirm the new migration file exists

### **Step 4:** Test in Flask Shell

Verify that password hashing works correctly by creating a test user in the interactive Flask shell.

1. **Open** Flask shell:

   ```bash
   flask shell
   ```

2. **Create** a user and test password hashing:

   ```python
   from app.data.models.user import User
   from app import db

   # Create a user
   user = User(username="testadmin")
   user.set_password("password123")

   # Verify the hash
   print(user.password_hash)  # Long hash string, NOT "password123"
   print(len(user.password_hash))  # ~160+ characters

   # Test password verification
   print(user.check_password("password123"))  # True
   print(user.check_password("wrongpassword"))  # False

   # Save to database
   db.session.add(user)
   db.session.commit()

   # Verify is_active default
   print(user.is_active)  # True
   ```

> ℹ **Concept Deep Dive**
>
> Notice that `set_password()` stores a long hash string, not the original password. Even if someone gains access to the database, they cannot reverse the hash to recover the original password.
>
> The `check_password()` method extracts the salt from the stored hash, applies the same hashing process to the candidate password, and compares the results using a constant-time comparison function that prevents timing attacks.
>
> ✓ **Quick check:** `check_password("password123")` returns `True` and `check_password("wrongpassword")` returns `False`

### **Step 5:** Verify and Explore

Confirm the database schema is correct and explore the security properties of the implementation.

1. **Check** the database schema:

   ```bash
   sqlite3 instance/news_flash.db ".schema users"
   ```

   You should see columns for `id`, `username`, `password_hash`, and `is_active`.

2. **Verify** the password hash is stored, not the plain password:

   ```bash
   sqlite3 instance/news_flash.db "SELECT username, password_hash FROM users;"
   ```

   The `password_hash` column should contain a long hash string starting with a method identifier (e.g., `scrypt:` or `pbkdf2:`).

3. **Try** creating a duplicate username in Flask shell to test the unique constraint:

   ```python
   from app.data.models.user import User
   from app import db

   duplicate = User(username="testadmin")
   duplicate.set_password("different")
   db.session.add(duplicate)
   db.session.commit()  # IntegrityError!
   ```

   This raises an `IntegrityError`, demonstrating that the unique constraint on `username` prevents duplicate accounts.

4. **Clean up** the test user:

   ```bash
   sqlite3 instance/news_flash.db "DELETE FROM users;"
   ```

> ✓ **Success indicators:**
>
> - Migration runs without errors
> - User table has columns: `id`, `username`, `password_hash`, `is_active`
> - `password_hash` is a long hash string (not plain text)
> - `check_password()` correctly verifies matching and non-matching passwords
> - Duplicate username raises `IntegrityError`
> - `is_active` defaults to `True`

## Common Issues

> **If you encounter problems:**
>
> **"Target database is not up to date":** Run `flask db upgrade` before `flask db migrate`
>
> **"No changes detected" during migrate:** Ensure User is imported in `app/__init__.py` so Flask-Migrate can discover the model
>
> **IntegrityError when testing:** This is expected behavior for duplicate usernames -- the unique constraint is working correctly
>
> **"Table 'users' already exists":** Delete the migration file and the users table, then re-run `flask db migrate` and `flask db upgrade`
>
> **Still stuck?** Check that `app/data/models/__init__.py` exports User and that the import exists in `app/__init__.py`

## Summary

You've created a User model with secure password storage:

- ✓ Created a User model with PBKDF2 password hashing via Werkzeug
- ✓ Used `set_password()` and `check_password()` to encapsulate all password operations
- ✓ Generated and applied a database migration for the users table
- ✓ Verified password hashing, verification, and unique constraints

> **Key takeaway:** Never store passwords in plain text. Werkzeug's hashing functions handle salting, iteration, and secure comparison automatically. The User model encapsulates all password operations so the rest of the application never touches raw passwords.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Research bcrypt and argon2 as alternative hashing algorithms
> - Add an `email` field to User for password reset capability
> - Add `created_at` and `last_login` timestamp columns
> - Explore password complexity requirements and validation

## Done! 🎉

You've created a User model with secure password storage using Werkzeug's PBKDF2 hashing.
