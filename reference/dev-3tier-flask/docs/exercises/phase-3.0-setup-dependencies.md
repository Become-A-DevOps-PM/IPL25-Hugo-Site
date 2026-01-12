# Setup WTForms Dependencies

## Goal

Add WTForms and related packages to enable server-side form validation in Phase 3.

> **What you'll learn:**
>
> - How to add Python package dependencies for Flask applications
> - The purpose of WTForms and Flask-WTF for form handling
> - Managing dependencies in requirements.txt

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 2 (Walking Skeleton)
> - ✓ All 39 tests passing
> - ✓ Virtual environment activated

## Exercise Steps

### Overview

1. **Add WTForms Dependencies**
2. **Install the Packages**
3. **Verify Installation**

### **Step 1:** Add WTForms Dependencies

Phase 3 introduces proper form validation using WTForms, the standard form handling library for Flask. We need three packages: Flask-WTF (Flask integration), WTForms (core library), and email-validator (for email validation).

1. **Open** `application/requirements.txt`

2. **Add** the following lines at the end:

   ```text
   # Form handling and validation
   Flask-WTF==1.2.1
   WTForms==3.1.2
   email-validator==2.1.0
   ```

> ℹ **Concept Deep Dive**
>
> - **Flask-WTF** provides Flask integration including CSRF protection
> - **WTForms** is the underlying form library with validators and fields
> - **email-validator** adds proper email format validation beyond simple regex
>
> These packages work together to provide server-side validation, CSRF protection, and clean form handling.
>
> ✓ **Quick check:** requirements.txt now has 3 new lines for form packages

### **Step 2:** Install the Packages

1. **Run** the following commands:

   ```bash
   cd application
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

> ✓ **Quick check:** No installation errors appear

### **Step 3:** Verify Installation

1. **Run** this verification command:

   ```bash
   python -c "import flask_wtf; import wtforms; print('WTForms installed successfully')"
   ```

2. **Run** the existing tests to ensure nothing broke:

   ```bash
   pytest tests/test_routes.py -v
   ```

> ✓ **Success indicators:**
>
> - Python prints "WTForms installed successfully"
> - All 39 tests still pass
> - No import errors

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `requirements.txt` has Flask-WTF, WTForms, and email-validator
> - ☐ `pip install` completed without errors
> - ☐ Import verification command succeeds
> - ☐ All 39 tests pass

## Common Issues

> **If you encounter problems:**
>
> **pip install fails:** Ensure your virtual environment is activated (`source .venv/bin/activate`)
>
> **Import error:** Try `pip install --upgrade flask-wtf wtforms email-validator`
>
> **Version conflicts:** The specific versions listed are tested to work together

## Summary

You've added the WTForms dependencies needed for Phase 3:

- ✓ Flask-WTF for Flask integration and CSRF protection
- ✓ WTForms for form field definitions and validators
- ✓ email-validator for proper email format validation

> **Key takeaway:** Adding dependencies before implementing features ensures a smooth development workflow. These packages will enable proper server-side validation throughout Phase 3.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Read the Flask-WTF documentation: <https://flask-wtf.readthedocs.io/>
> - Explore WTForms validators: <https://wtforms.readthedocs.io/en/stable/validators/>
> - Understand CSRF protection and why it matters

## Done!

Dependencies are installed. Next phase will create the RegistrationForm with proper validation.
