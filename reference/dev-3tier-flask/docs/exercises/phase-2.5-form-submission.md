# Handling Form Submission with POST

## Goal

Handle form submission to create registrations in the database, using the Post-Redirect-Get (PRG) pattern.

> **What you'll learn:**
>
> - Handling POST requests in Flask
> - Using services to persist data
> - The Post-Redirect-Get pattern to prevent duplicate submissions

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 2.4 (Registration Form GET)
> - ✓ Understanding of HTTP methods (GET vs POST)
> - ✓ 28 tests passing

## Exercise Steps

### Overview

1. **Update /register Route to Handle POST**
2. **Add Thank-You Route Stub**
3. **Add Form Submission Tests**
4. **Verify with pytest**

### **Step 1:** Update /register Route to Handle POST

1. **Open** `application/app/routes/main.py`

2. **Replace** the entire file with:

   ```python
   """Main blueprint for the landing page and registration.

   This blueprint serves the application landing page and registration
   form for the webinar signup feature (Phase 2).
   """

   from flask import Blueprint, render_template, request, redirect, url_for
   from app.services.registration_service import RegistrationService

   main_bp = Blueprint('main', __name__)


   @main_bp.route('/')
   def index():
       """Render the landing page."""
       return render_template('landing.html')


   @main_bp.route('/register', methods=['GET', 'POST'])
   def register():
       """Display and handle the registration form.

       GET: Display the registration form.
       POST: Process form submission and redirect to thank-you page.
       """
       if request.method == 'POST':
           RegistrationService.create_registration(
               name=request.form.get('name'),
               email=request.form.get('email'),
               company=request.form.get('company'),
               job_title=request.form.get('job_title')
           )
           return redirect(url_for('main.thank_you'))
       return render_template('register.html')


   @main_bp.route('/thank-you')
   def thank_you():
       """Display registration confirmation.

       Note: This is a placeholder that will be fully implemented in Phase 2.6.
       """
       return '<h1>Thank you!</h1><p>Registration received.</p>'
   ```

> ℹ **Concept Deep Dive**
>
> **Post-Redirect-Get (PRG) Pattern:**
>
> 1. User submits form (POST)
> 2. Server processes data and redirects (302)
> 3. Browser follows redirect with GET
> 4. User sees confirmation page
>
> **Why PRG matters:**
>
> - Prevents duplicate submissions on browser refresh
> - Creates clean browser history
> - Standard web application pattern
>
> ⚠ **Common Mistakes**
>
> - Returning a template directly after POST (allows resubmission on refresh)
> - Forgetting to import `request`, `redirect`, `url_for`
> - Using `request.form['key']` instead of `request.form.get('key')`
>
> ✓ **Quick check:** POST creates registration, redirects to /thank-you

### **Step 2:** Understanding the Flow

The registration flow is now:

```
Landing Page → Click "Register Now" → Registration Form
                                             ↓
                                      Fill out form
                                             ↓
                                      Submit (POST)
                                             ↓
                                 RegistrationService.create_registration()
                                             ↓
                                      Redirect (302)
                                             ↓
                                    Thank You Page (GET)
```

### **Step 3:** Add Form Submission Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** a new test class:

   ```python
   class TestRegisterSubmission:
       """Tests for registration form submission."""

       def test_register_post_redirects(self, client):
           """Test that POST to /register redirects to thank-you."""
           response = client.post('/register', data={
               'name': 'Test User',
               'email': 'test@example.com',
               'company': 'Test Corp',
               'job_title': 'Developer'
           }, follow_redirects=False)
           assert response.status_code == 302
           assert '/thank-you' in response.location

       def test_register_post_creates_registration(self, app, client):
           """Test that POST creates a registration in database."""
           with app.app_context():
               from app.services.registration_service import RegistrationService
               initial_count = RegistrationService.get_registration_count()

               client.post('/register', data={
                   'name': 'Test User',
                   'email': 'test@example.com',
                   'company': 'Test Corp',
                   'job_title': 'Developer'
               })

               final_count = RegistrationService.get_registration_count()
               assert final_count == initial_count + 1

       def test_register_post_with_follow_redirect(self, client):
           """Test complete POST flow with redirect following."""
           response = client.post('/register', data={
               'name': 'Test User',
               'email': 'test@example.com',
               'company': 'Test Corp',
               'job_title': 'Developer'
           }, follow_redirects=True)
           assert response.status_code == 200
           assert b'Thank you' in response.data
   ```

> ✓ **Quick check:** Three new tests for POST behavior

### **Step 4:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** all tests pass (28 existing + 3 new = 31 tests)

> ✓ **Success indicators:**
>
> - All 31 tests pass
> - POST creates registration in database
> - Redirect to /thank-you works

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `/register` route accepts both GET and POST
> - ☐ POST creates registration via RegistrationService
> - ☐ POST redirects to `/thank-you` (Post-Redirect-Get pattern)
> - ☐ Temporary thank-you response works
> - ☐ `pytest tests/test_routes.py -v` passes (31 tests)

## Common Issues

> **If you encounter problems:**
>
> **ImportError:** Check imports at top of main.py
>
> **KeyError on form data:** Use `request.form.get('key')` not `request.form['key']`
>
> **Redirect not working:** Ensure you return the redirect, not just call it
>
> **Still stuck?** Check that methods=['GET', 'POST'] is set on the route

## Summary

You've implemented form submission with:

- ✓ POST handling in /register route
- ✓ Registration creation via service layer
- ✓ Post-Redirect-Get pattern
- ✓ Placeholder thank-you response
- ✓ Three tests verifying submission behavior

> **Key takeaway:** The PRG pattern prevents duplicate form submissions and creates a better user experience. Always redirect after successful form processing.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add form validation before creating registration
> - Add flash messages for user feedback
> - Handle form errors gracefully

## Done!

Form submission is working. Next phase will create a proper thank-you page template.
