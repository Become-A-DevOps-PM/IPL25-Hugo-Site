# Error Styling and Flash Messages

## Goal

Add CSS styling for form validation errors and implement flash message display for user feedback.

> **What you'll learn:**
>
> - How to style form validation errors with CSS
> - Implementing flash message display in Flask templates
> - Using Jinja2 template inheritance for consistent layouts
> - Creating dismissible alert components

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 3.2 (Duplicate email prevention)
> - ✓ All 50 tests passing
> - ✓ Basic understanding of CSS

## Exercise Steps

### Overview

1. **Update Base Template for Flash Messages**
2. **Add CSS for Flash Messages**
3. **Add CSS for Form Errors**
4. **Add Flash Message Tests**
5. **Verify with pytest**

### **Step 1:** Update Base Template for Flash Messages

Flask's `flash()` function stores messages in the session. The base template displays them on every page.

1. **Open** `application/app/templates/base.html`

2. **Replace** with the following content:

   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>{% block title %}Flask App{% endblock %}</title>
       <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
   </head>
   <body>
       <nav class="navbar">
           <div class="nav-brand">
               <a href="{{ url_for('main.index') }}">Webinar Registration</a>
           </div>
           <div class="nav-links">
               <a href="{{ url_for('main.index') }}">Home</a>
               <a href="{{ url_for('main.register') }}">Register</a>
           </div>
       </nav>

       <main class="container">
           {% with messages = get_flashed_messages(with_categories=true) %}
               {% if messages %}
                   <div class="flash-messages">
                       {% for category, message in messages %}
                           <div class="flash flash-{{ category }}">
                               {{ message }}
                               <button type="button" class="flash-close" onclick="this.parentElement.remove()">&times;</button>
                           </div>
                       {% endfor %}
                   </div>
               {% endif %}
           {% endwith %}

           {% block content %}{% endblock %}
       </main>

       <footer class="footer">
           <p>&copy; 2026 Webinar Registration. Built with Flask.</p>
       </footer>
   </body>
   </html>
   ```

> ℹ **Concept Deep Dive**
>
> - **get_flashed_messages(with_categories=true)** returns tuples of (category, message)
> - **{% with %}** creates a local scope for the messages variable
> - **flash-{{ category }}** creates dynamic CSS classes (flash-success, flash-error, etc.)
> - **onclick="this.parentElement.remove()"** makes the close button dismiss the message
>
> ✓ **Quick check:** Template uses get_flashed_messages with categories

### **Step 2:** Add CSS for Flash Messages

1. **Open** `application/app/static/css/style.css`

2. **Add** the following CSS:

   ```css
   /* ===== Flash Messages ===== */
   .flash-messages {
       margin-bottom: 1.5rem;
   }

   .flash {
       padding: 1rem 2.5rem 1rem 1rem;
       border-radius: 4px;
       margin-bottom: 0.5rem;
       position: relative;
       border: 1px solid transparent;
   }

   .flash-success {
       background-color: #d4edda;
       border-color: #c3e6cb;
       color: #155724;
   }

   .flash-error {
       background-color: #f8d7da;
       border-color: #f5c6cb;
       color: #721c24;
   }

   .flash-warning {
       background-color: #fff3cd;
       border-color: #ffeeba;
       color: #856404;
   }

   .flash-info {
       background-color: #d1ecf1;
       border-color: #bee5eb;
       color: #0c5460;
   }

   .flash-close {
       position: absolute;
       top: 0.5rem;
       right: 0.75rem;
       background: none;
       border: none;
       font-size: 1.5rem;
       cursor: pointer;
       opacity: 0.5;
       line-height: 1;
   }

   .flash-close:hover {
       opacity: 1;
   }
   ```

> ℹ **Concept Deep Dive**
>
> - Each category (success, error, warning, info) has distinct colors following Bootstrap conventions
> - The close button is positioned absolutely within the flash container
> - Opacity change on hover provides visual feedback
>
> ✓ **Quick check:** Four flash color variants defined

### **Step 3:** Add CSS for Form Errors

1. **Continue adding** to `application/app/static/css/style.css`:

   ```css
   /* ===== Form Error Styling ===== */
   .form-group {
       margin-bottom: 1.25rem;
   }

   .form-group.has-error input,
   .form-group.has-error select,
   .form-group.has-error textarea {
       border-color: #dc3545;
       background-color: #fff8f8;
   }

   .form-group.has-error label {
       color: #dc3545;
   }

   .errors {
       list-style: none;
       padding: 0;
       margin: 0.25rem 0 0 0;
   }

   .error-message {
       color: #dc3545;
       font-size: 0.875rem;
       margin-top: 0.25rem;
   }

   /* ===== Form Controls ===== */
   .form-control {
       width: 100%;
       padding: 0.5rem 0.75rem;
       font-size: 1rem;
       line-height: 1.5;
       border: 1px solid #ced4da;
       border-radius: 4px;
       transition: border-color 0.15s ease-in-out;
   }

   .form-control:focus {
       border-color: #80bdff;
       outline: 0;
       box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
   }

   /* ===== Navigation ===== */
   .navbar {
       background-color: #343a40;
       padding: 1rem;
       display: flex;
       justify-content: space-between;
       align-items: center;
   }

   .nav-brand a {
       color: white;
       text-decoration: none;
       font-size: 1.25rem;
       font-weight: bold;
   }

   .nav-links a {
       color: rgba(255, 255, 255, 0.8);
       text-decoration: none;
       margin-left: 1.5rem;
   }

   .nav-links a:hover {
       color: white;
   }

   /* ===== Footer ===== */
   .footer {
       background-color: #f8f9fa;
       padding: 1.5rem;
       text-align: center;
       margin-top: 3rem;
       border-top: 1px solid #e9ecef;
   }

   /* ===== Container ===== */
   .container {
       max-width: 800px;
       margin: 0 auto;
       padding: 2rem 1rem;
   }
   ```

> ℹ **Concept Deep Dive**
>
> - **has-error** class triggers red border and background on inputs
> - **transition** provides smooth color changes on focus
> - **box-shadow** creates a focus ring for accessibility
> - Layout styles (navbar, footer, container) provide consistent page structure
>
> ✓ **Quick check:** Error styling and layout CSS added

### **Step 4:** Add Flash Message Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

   ```python
   class TestFlashMessages:
       """Tests for flash message display."""

       def test_success_flash_on_registration(self, client):
           """Test that success flash appears after registration."""
           response = client.post('/register', data={
               'name': 'Flash Test User',
               'email': 'flash@test.com',
               'company': 'Flash Corp',
               'job_title': 'Developer'
           }, follow_redirects=True)

           assert response.status_code == 200
           assert b'Registration successful' in response.data

       def test_form_preserves_input_on_error(self, client):
           """Test that form preserves input when validation fails."""
           response = client.post('/register', data={
               'name': 'Preserved Name',
               'email': 'invalid-email',
               'company': 'Preserved Company',
               'job_title': 'Preserved Title'
           })

           assert response.status_code == 200
           assert b'Preserved Name' in response.data
           assert b'Preserved Company' in response.data
           assert b'Preserved Title' in response.data
   ```

> ✓ **Quick check:** 2 new tests for flash messages and form preservation

### **Step 5:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 50 + 2 = 52 tests passing

> ✓ **Success indicators:**
>
> - All 52 tests pass
> - Flash messages appear on successful registration
> - Form inputs are preserved when validation fails

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `base.html` displays flash messages with categories
> - ☐ `style.css` has flash message styling (4 variants)
> - ☐ `style.css` has form error styling (red borders)
> - ☐ `style.css` has navigation and layout styles
> - ☐ `pytest tests/test_routes.py -v` passes (52 tests)

## Common Issues

> **If you encounter problems:**
>
> **Flash messages not appearing:** Check get_flashed_messages() is called in base.html
>
> **CSS not loading:** Verify url_for('static', filename=...) path is correct
>
> **Close button not working:** Ensure onclick handler uses correct syntax
>
> **Styles not applying:** Check CSS selectors match HTML class names

## Summary

You've implemented error styling and flash messages:

- ✓ Base template displays categorized flash messages
- ✓ Four flash variants (success, error, warning, info)
- ✓ Dismissible flash messages with close button
- ✓ Form error styling with red borders and labels
- ✓ 2 new tests verify flash message display

> **Key takeaway:** Flash messages provide immediate feedback to users, and proper error styling helps users identify and fix validation issues quickly.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add CSS animations for flash message appearance/dismissal
> - Implement auto-dismiss for success messages after a delay
> - Add icons to flash messages for visual clarity

## Done!

Error styling and flash messages are complete. Next phase will create the webinar information page.
