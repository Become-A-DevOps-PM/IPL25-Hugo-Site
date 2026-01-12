# Setup Flask-Login Dependency

## Goal

Add Flask-Login package to enable session-based authentication in Phase 4.

> **What you'll learn:**
>
> - How Flask-Login provides user session management
> - The relationship between Werkzeug and password hashing
> - Managing authentication dependencies

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 3 (Full Feature Implementation)
> - ✓ All 71 tests passing
> - ✓ Virtual environment activated

## Exercise Steps

### Overview

1. **Add Flask-Login Dependency**
2. **Install the Package**
3. **Verify Installation**

### **Step 1:** Add Flask-Login Dependency

Flask-Login provides user session management. Werkzeug (for password hashing) is already included as a Flask dependency.

1. **Open** `application/requirements.txt`

2. **Add** the following line:

   ```text
   # Authentication
   Flask-Login==0.6.3
   ```

> ℹ **Concept Deep Dive**
>
> - **Flask-Login** handles user session management (login, logout, remember me)
> - **Werkzeug** (already installed with Flask) provides secure password hashing
> - Flask-Login doesn't handle password storage - that's our responsibility
>
> These packages work together:
>
> - Werkzeug hashes passwords securely
> - Flask-Login manages user sessions after authentication
>
> ✓ **Quick check:** requirements.txt has Flask-Login entry

### **Step 2:** Install the Package

1. **Run** the following commands:

   ```bash
   cd application
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

> ✓ **Quick check:** No installation errors appear

### **Step 3:** Verify Installation

1. **Run** verification commands:

   ```bash
   python -c "import flask_login; print('Flask-Login installed successfully')"
   python -c "from werkzeug.security import generate_password_hash; print('Werkzeug available')"
   ```

2. **Run** the existing tests to ensure nothing broke:

   ```bash
   pytest tests/test_routes.py -v
   ```

> ✓ **Success indicators:**
>
> - Both Python commands succeed
> - All 71 tests still pass
> - No import errors

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `requirements.txt` has Flask-Login==0.6.3
> - ☐ `pip install` completed without errors
> - ☐ Flask-Login import verification succeeds
> - ☐ Werkzeug import verification succeeds
> - ☐ All 71 tests pass

## Common Issues

> **If you encounter problems:**
>
> **pip install fails:** Ensure virtual environment is activated
>
> **Import error:** Try `pip install --upgrade flask-login`
>
> **Version conflicts:** The listed version is tested with Flask 3.0+

## Summary

You've added the authentication dependency:

- ✓ Flask-Login for session management
- ✓ Werkzeug already available for password hashing

> **Key takeaway:** Flask-Login and Werkzeug handle different concerns - session management and password security respectively. Together they provide a complete authentication foundation.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Read Flask-Login documentation: <https://flask-login.readthedocs.io/>
> - Understand Werkzeug's password hashing: <https://werkzeug.palletsprojects.com/en/stable/utils/#module-werkzeug.security>
> - Compare PBKDF2 (Werkzeug default) with bcrypt and argon2

## Done!

Dependencies installed. Next phase will create the User model with password hashing.
