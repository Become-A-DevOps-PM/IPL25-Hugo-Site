# Creating the Registration Form Page

## Goal

Create the registration form page that displays when users click "Register Now" from the landing page.

> **What you'll learn:**
>
> - Adding routes to Flask blueprints
> - Creating HTML forms with Jinja2 templates
> - Form field structure and accessibility

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 2.3 (Landing Page Enhancement)
> - ✓ Understanding of Flask routes and templates
> - ✓ 24 tests passing

## Exercise Steps

### Overview

1. **Add /register Route to main.py**
2. **Create register.html Template**
3. **Add Tests for Registration Form**
4. **Verify with pytest**

### **Step 1:** Add /register Route to main.py

1. **Open** `application/app/routes/main.py`

2. **Add** the register route:

   ```python
   @main_bp.route('/register')
   def register():
       """Display the registration form."""
       return render_template('register.html')
   ```

3. **Update** the module docstring to reflect Phase 2:

   ```python
   """Main blueprint for the landing page and registration.

   This blueprint serves the application landing page and registration
   form for the webinar signup feature (Phase 2).
   """
   ```

> ℹ **Concept Deep Dive**
>
> This route only handles GET requests (the default). It:
>
> - Renders the registration form template
> - Does not process form submissions (that's Phase 2.5)
> - Uses the same blueprint as the landing page
>
> ⚠ **Common Mistakes**
>
> - Adding methods=['GET', 'POST'] too early (POST is Phase 2.5)
> - Forgetting to import render_template (already imported)
>
> ✓ **Quick check:** Route responds to GET /register

### **Step 2:** Create register.html Template

1. **Create** a new file at `application/app/templates/register.html`

2. **Add** the following content:

   ```html
   {% extends "base.html" %}

   {% block title %}Register for Webinar{% endblock %}

   {% block content %}
   <div class="register-page">
       <h1>Register for Our Webinar</h1>
       <p>Fill out the form below to reserve your spot.</p>

       <form method="POST" action="{{ url_for('main.register') }}" class="registration-form">
           <div class="form-group">
               <label for="name">Full Name</label>
               <input type="text" id="name" name="name" required
                      placeholder="John Doe">
           </div>

           <div class="form-group">
               <label for="email">Email Address</label>
               <input type="email" id="email" name="email" required
                      placeholder="john@example.com">
           </div>

           <div class="form-group">
               <label for="company">Company</label>
               <input type="text" id="company" name="company" required
                      placeholder="Acme Corp">
           </div>

           <div class="form-group">
               <label for="job_title">Job Title</label>
               <input type="text" id="job_title" name="job_title" required
                      placeholder="Software Developer">
           </div>

           <div class="form-actions">
               <button type="submit" class="btn btn-primary">Complete Registration</button>
           </div>
       </form>

       <p class="back-link"><a href="{{ url_for('main.index') }}">← Back to home</a></p>
   </div>
   {% endblock %}
   ```

> ℹ **Concept Deep Dive**
>
> The form includes:
>
> - **Method POST**: Data sent in request body (not URL)
> - **Action**: Points to the same route (Phase 2.5 will handle POST)
> - **Required fields**: All fields are required for complete registration
> - **Labels with for**: Accessibility - clicking label focuses input
> - **Placeholders**: Help users understand expected format
>
> ⚠ **Common Mistakes**
>
> - Mismatched `for` and `id` attributes
> - Forgetting name attributes (needed for form data)
> - Using GET method for form data
>
> ✓ **Quick check:** Four fields: name, email, company, job_title

### **Step 3:** Add Tests for Registration Form

1. **Open** `application/tests/test_routes.py`

2. **Add** a new test class:

   ```python
   class TestRegisterPage:
       """Tests for the registration form page."""

       def test_register_page_loads(self, client):
           """Test that register page loads successfully."""
           response = client.get('/register')
           assert response.status_code == 200

       def test_register_page_has_form(self, client):
           """Test that register page contains a form."""
           response = client.get('/register')
           assert b'<form' in response.data
           assert b'method="POST"' in response.data

       def test_register_page_has_required_fields(self, client):
           """Test that register page has all required form fields."""
           response = client.get('/register')
           assert b'name="name"' in response.data
           assert b'name="email"' in response.data
           assert b'name="company"' in response.data
           assert b'name="job_title"' in response.data

       def test_register_page_has_submit_button(self, client):
           """Test that register page has submit button."""
           response = client.get('/register')
           assert b'type="submit"' in response.data
   ```

> ✓ **Quick check:** Four new tests for form structure

### **Step 4:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** all tests pass (24 existing + 4 new = 28 tests)

> ✓ **Success indicators:**
>
> - All 28 tests pass
> - /register page loads successfully
> - Form displays with all required fields

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `/register` route exists in main.py
> - ☐ `register.html` template created with form
> - ☐ Form has all 4 required fields (name, email, company, job_title)
> - ☐ Form action posts to `/register`
> - ☐ `pytest tests/test_routes.py -v` passes (28 tests)

## Common Issues

> **If you encounter problems:**
>
> **TemplateNotFound:** Check that register.html is in templates/
>
> **Route not found:** Ensure @main_bp.route decorator is correct
>
> **Form field missing:** Verify name attributes match tests exactly
>
> **Still stuck?** Compare with demo.html for form structure patterns

## Summary

You've created the registration form with:

- ✓ New /register route in main blueprint
- ✓ Complete HTML form with 4 required fields
- ✓ Proper form structure (labels, inputs, button)
- ✓ Back link to landing page
- ✓ Four tests verifying form structure

> **Key takeaway:** Forms are the bridge between user input and application logic. Proper structure ensures accessibility and reliable data collection.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add CSS styling for form layout
> - Add client-side validation with HTML5 patterns
> - Add CSRF protection (Flask-WTF)

## Done!

The registration form is ready to display. Next phase will handle form submission.
