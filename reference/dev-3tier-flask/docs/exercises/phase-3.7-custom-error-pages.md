# Custom Error Pages

## Goal

Create custom error pages for 400 (Bad Request), 404 (Not Found), and 500 (Server Error) HTTP errors.

> **What you'll learn:**
>
> - Registering custom error handlers in Flask
> - Creating user-friendly error page templates
> - Handling different error types appropriately
> - Database session management during errors

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 3.6 (CSV export)
> - ✓ All 68 tests passing
> - ✓ Understanding of HTTP status codes

## Exercise Steps

### Overview

1. **Register Error Handlers**
2. **Create 400 Error Template**
3. **Create 404 Error Template**
4. **Create 500 Error Template**
5. **Add Error Page CSS**
6. **Add Error Page Tests**
7. **Verify with pytest**

### **Step 1:** Register Error Handlers

Add error handler registration to the application factory.

1. **Open** `application/app/__init__.py`

2. **Ensure** the file has the following structure with error handlers:

   ```python
   """Application factory for the Flask application."""
   from flask import Flask, render_template
   from config import config_map
   from app.extensions import db, migrate


   def create_app(config_name='development'):
       """Create and configure the Flask application.

       Args:
           config_name: Configuration environment ('development', 'production', 'testing')

       Returns:
           Flask: Configured Flask application instance
       """
       app = Flask(__name__)
       app.config.from_object(config_map.get(config_name, config_map['development']))

       # Initialize extensions
       db.init_app(app)
       migrate.init_app(app, db)

       # Import models so they are registered with SQLAlchemy
       from app import models  # noqa: F401

       # Register blueprints
       from app.routes import register_blueprints
       register_blueprints(app)

       # Register error handlers
       register_error_handlers(app)

       return app


   def register_error_handlers(app):
       """Register custom error handlers for the application."""

       @app.errorhandler(400)
       def bad_request_error(error):
           return render_template('errors/400.html'), 400

       @app.errorhandler(404)
       def not_found_error(error):
           return render_template('errors/404.html'), 404

       @app.errorhandler(500)
       def internal_error(error):
           db.session.rollback()
           return render_template('errors/500.html'), 500
   ```

> ℹ **Concept Deep Dive**
>
> - **@app.errorhandler(code)** registers a function to handle specific HTTP errors
> - Error handlers return a tuple of (response, status_code)
> - **db.session.rollback()** on 500 errors prevents partial commits
> - Handlers are registered via a separate function for clean organization
>
> ⚠ **Common Mistakes**
>
> - Forgetting to return the status code (just returning template)
> - Not rolling back the database session on 500 errors
>
> ✓ **Quick check:** Three error handlers registered (400, 404, 500)

### **Step 2:** Create 400 Error Template

1. **Create** the directory `application/app/templates/errors/`

2. **Create** `application/app/templates/errors/400.html`:

   ```html
   {% extends "base.html" %}

   {% block title %}Bad Request{% endblock %}

   {% block content %}
   <div class="error-page">
       <div class="error-code">400</div>
       <h1>Bad Request</h1>
       <p class="error-message">The server could not understand your request. Please check your input and try again.</p>
       <div class="error-actions">
           <a href="{{ url_for('main.index') }}" class="btn btn-primary">Go to Home</a>
           <a href="javascript:history.back()" class="btn btn-secondary">Go Back</a>
       </div>
   </div>
   {% endblock %}
   ```

> ✓ **Quick check:** 400 template with error code, message, and action buttons

### **Step 3:** Create 404 Error Template

1. **Create** `application/app/templates/errors/404.html`:

   ```html
   {% extends "base.html" %}

   {% block title %}Page Not Found{% endblock %}

   {% block content %}
   <div class="error-page">
       <div class="error-code">404</div>
       <h1>Page Not Found</h1>
       <p class="error-message">The page you're looking for doesn't exist or has been moved.</p>
       <div class="error-actions">
           <a href="{{ url_for('main.index') }}" class="btn btn-primary">Go to Home</a>
           <a href="{{ url_for('main.register') }}" class="btn btn-secondary">Register for Webinar</a>
       </div>
   </div>
   {% endblock %}
   ```

> ✓ **Quick check:** 404 template with helpful navigation options

### **Step 4:** Create 500 Error Template

1. **Create** `application/app/templates/errors/500.html`:

   ```html
   {% extends "base.html" %}

   {% block title %}Server Error{% endblock %}

   {% block content %}
   <div class="error-page">
       <div class="error-code">500</div>
       <h1>Something Went Wrong</h1>
       <p class="error-message">We're experiencing technical difficulties. Please try again later.</p>
       <div class="error-actions">
           <a href="{{ url_for('main.index') }}" class="btn btn-primary">Go to Home</a>
           <a href="javascript:location.reload()" class="btn btn-secondary">Try Again</a>
       </div>
   </div>
   {% endblock %}
   ```

> ℹ **Concept Deep Dive**
>
> Each error page provides:
>
> - Clear visual indication of the error (large error code)
> - User-friendly explanation (not technical jargon)
> - Actionable next steps (navigation buttons)
> - Consistent styling with the rest of the application
>
> ✓ **Quick check:** 500 template with retry option

### **Step 5:** Add Error Page CSS

1. **Open** `application/app/static/css/style.css`

2. **Add** the following CSS:

   ```css
   /* ===== Error Pages ===== */
   .error-page {
       text-align: center;
       padding: 4rem 2rem;
       max-width: 600px;
       margin: 0 auto;
   }

   .error-code {
       font-size: 8rem;
       font-weight: bold;
       color: #dee2e6;
       line-height: 1;
       margin-bottom: 1rem;
   }

   .error-page h1 {
       font-size: 2rem;
       margin-bottom: 1rem;
       color: #343a40;
   }

   .error-message {
       font-size: 1.1rem;
       color: #6c757d;
       margin-bottom: 2rem;
   }

   .error-actions {
       display: flex;
       gap: 1rem;
       justify-content: center;
       flex-wrap: wrap;
   }
   ```

> ✓ **Quick check:** CSS centers error content and styles the large error code

### **Step 6:** Add Error Page Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

   ```python
   class TestErrorPages:
       """Tests for custom error pages."""

       def test_404_page_for_nonexistent_route(self, client):
           """Test that 404 page is shown for nonexistent routes."""
           response = client.get('/nonexistent-page-xyz')
           assert response.status_code == 404
           assert b'404' in response.data
           assert b'Page Not Found' in response.data

       def test_404_page_has_home_link(self, client):
           """Test that 404 page has link to home."""
           response = client.get('/nonexistent-page')
           assert b'Go to Home' in response.data

       def test_404_page_has_register_link(self, client):
           """Test that 404 page has link to registration."""
           response = client.get('/nonexistent-page')
           assert b'/register' in response.data
   ```

> ℹ **Concept Deep Dive**
>
> - Testing 404 is straightforward - request any nonexistent URL
> - Testing 500 would require triggering an actual error (more complex)
> - Tests verify both the status code and page content
>
> ✓ **Quick check:** 3 new tests for error page functionality

### **Step 7:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 68 + 3 = 71 tests passing

> ✓ **Success indicators:**
>
> - All 71 tests pass
> - 404 pages show for nonexistent routes
> - Error pages have navigation options

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `__init__.py` has `register_error_handlers()` function
> - ☐ Error handlers registered for 400, 404, and 500
> - ☐ `errors/400.html` template exists
> - ☐ `errors/404.html` template exists
> - ☐ `errors/500.html` template exists
> - ☐ `style.css` has error page styling
> - ☐ `pytest tests/test_routes.py -v` passes (71 tests)

## Common Issues

> **If you encounter problems:**
>
> **Templates not found:** Check directory is `templates/errors/` not `templates/error/`
>
> **Status code not returned:** Ensure handlers return tuple `(template, code)`
>
> **Default error pages showing:** Verify error handlers are registered in create_app()
>
> **500 handler not triggering:** Add `app.config['PROPAGATE_EXCEPTIONS'] = False` in testing config

## Summary

You've implemented custom error pages:

- ✓ Error handlers for 400, 404, and 500 status codes
- ✓ User-friendly error templates with navigation
- ✓ Consistent styling matching application design
- ✓ Database rollback on server errors
- ✓ 3 new tests verify error page display

> **Key takeaway:** Custom error pages improve user experience by providing helpful guidance instead of generic browser errors. The 500 handler's database rollback prevents data corruption from partial transactions.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add error logging to capture 500 errors for debugging
> - Implement error-specific suggestions (e.g., search on 404)
> - Add error reporting via email for production

## Done!

Custom error pages are complete. Phase 3 is finished! Next phase will add authentication.
