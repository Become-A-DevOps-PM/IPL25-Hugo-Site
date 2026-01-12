# Security Headers Middleware

## Goal

Add OWASP-recommended security headers to all HTTP responses to protect against common web vulnerabilities.

> **What you'll learn:**
>
> - Flask's @after_request hook for response modification
> - OWASP security headers and their purpose
> - Conditional headers for production vs development
> - Defense-in-depth security principles

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 4.6 (Protected Routes)
> - ✓ All 108 tests passing
> - ✓ Understanding of HTTP headers

## Exercise Steps

### Overview

1. **Add Security Headers Middleware**
2. **Add Security Header Tests**
3. **Verify with pytest**

### **Step 1:** Add Security Headers Middleware

Register an after_request handler to add security headers to all responses.

1. **Open** `application/app/__init__.py`

2. **Update** to include security headers registration:

   ```python
   """Application factory for the Flask application.

   The factory pattern allows creating multiple app instances with different
   configurations, which is useful for testing and running multiple instances.
   """
   from flask import Flask, render_template
   from app.extensions import db, migrate, login_manager


   def create_app(config_name='development'):
       """Create and configure the Flask application.

       Args:
           config_name: Configuration to use ('development', 'production', 'testing').

       Returns:
           Configured Flask application instance.
       """
       app = Flask(__name__)

       # Load configuration
       config_map = {
           'development': 'config.DevelopmentConfig',
           'production': 'config.ProductionConfig',
           'testing': 'config.TestingConfig'
       }
       app.config.from_object(config_map.get(config_name, 'config.DevelopmentConfig'))

       # Initialize extensions
       db.init_app(app)
       migrate.init_app(app, db)
       login_manager.init_app(app)

       # Configure user loader for Flask-Login
       from app.services.auth_service import AuthService

       @login_manager.user_loader
       def load_user(user_id):
           return AuthService.get_user_by_id(user_id)

       # Import models so they are registered with SQLAlchemy
       from app import models  # noqa: F401

       # Register blueprints
       from app.routes import register_blueprints
       register_blueprints(app)

       # Register error handlers
       register_error_handlers(app)

       # Register security headers
       register_security_headers(app)

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


   def register_security_headers(app):
       """Register security headers middleware.

       Adds security headers to all responses to protect against
       common web vulnerabilities.
       """

       @app.after_request
       def add_security_headers(response):
           # Prevent MIME type sniffing
           response.headers['X-Content-Type-Options'] = 'nosniff'

           # Prevent clickjacking
           response.headers['X-Frame-Options'] = 'SAMEORIGIN'

           # Enable XSS filter in browsers
           response.headers['X-XSS-Protection'] = '1; mode=block'

           # Referrer policy
           response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'

           # Only add HSTS in production (when not debug)
           if not app.debug:
               response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'

           return response
   ```

> ℹ **Concept Deep Dive**
>
> Each header serves a specific security purpose:
>
> | Header | Purpose |
> |--------|---------|
> | **X-Content-Type-Options: nosniff** | Prevents browsers from MIME-sniffing, reducing drive-by download attacks |
> | **X-Frame-Options: SAMEORIGIN** | Prevents clickjacking by disallowing framing from other domains |
> | **X-XSS-Protection: 1; mode=block** | Enables browser's XSS filter and blocks the page if attack detected |
> | **Referrer-Policy** | Controls how much referrer info is sent with requests |
> | **Strict-Transport-Security** | Forces HTTPS connections (only in production) |
>
> **HSTS Considerations:**
> - Only added when `app.debug` is False (production)
> - max-age=31536000 means 1 year
> - includeSubDomains applies to all subdomains
> - Don't add in development (localhost uses HTTP)
>
> ⚠ **Common Mistakes**
>
> - Adding HSTS in development (breaks localhost HTTP)
> - Forgetting to return the response from after_request
> - Setting conflicting frame options for embeddable content
>
> ✓ **Quick check:** Five security headers registered, HSTS only in production

### **Step 2:** Add Security Header Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

   ```python
   class TestSecurityHeaders:
       """Tests for security headers middleware."""

       def test_x_content_type_options(self, client):
           """Test that X-Content-Type-Options header is set."""
           response = client.get('/')
           assert response.headers.get('X-Content-Type-Options') == 'nosniff'

       def test_x_frame_options(self, client):
           """Test that X-Frame-Options header is set."""
           response = client.get('/')
           assert response.headers.get('X-Frame-Options') == 'SAMEORIGIN'

       def test_x_xss_protection(self, client):
           """Test that X-XSS-Protection header is set."""
           response = client.get('/')
           assert response.headers.get('X-XSS-Protection') == '1; mode=block'

       def test_referrer_policy(self, client):
           """Test that Referrer-Policy header is set."""
           response = client.get('/')
           assert response.headers.get('Referrer-Policy') == 'strict-origin-when-cross-origin'

       def test_security_headers_on_all_routes(self, client):
           """Test that security headers are set on various routes."""
           routes = ['/', '/register', '/webinar', '/auth/login']
           for route in routes:
               response = client.get(route)
               assert response.headers.get('X-Content-Type-Options') == 'nosniff', f"Missing header on {route}"
   ```

> ℹ **Concept Deep Dive**
>
> - Headers are tested via `response.headers.get()`
> - Multiple routes tested to ensure middleware applies everywhere
> - HSTS is not tested because test config has DEBUG=True
>
> Note: The testing config uses DEBUG=True, so HSTS won't be set. In production
> with DEBUG=False, HSTS would be included.
>
> ✓ **Quick check:** 5 new tests for security headers

### **Step 3:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 108 + 5 = 113 tests passing

> ✓ **Success indicators:**
>
> - All 113 tests pass
> - Security headers present on all responses
> - Headers verified across multiple routes

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `__init__.py` has `register_security_headers()` function
> - ☐ @app.after_request decorator registers the handler
> - ☐ X-Content-Type-Options set to 'nosniff'
> - ☐ X-Frame-Options set to 'SAMEORIGIN'
> - ☐ X-XSS-Protection set to '1; mode=block'
> - ☐ Referrer-Policy set to 'strict-origin-when-cross-origin'
> - ☐ HSTS only added when not in debug mode
> - ☐ `pytest tests/test_routes.py -v` passes (113 tests)

## Common Issues

> **If you encounter problems:**
>
> **Headers not appearing:** Ensure after_request returns the response object
>
> **HSTS in development:** Check that debug mode check is correct (`if not app.debug`)
>
> **Tests failing for HSTS:** Test config has DEBUG=True, so HSTS won't be set
>
> **Conflicting headers:** Remove any duplicate header settings from nginx

## Summary

You've implemented security headers middleware:

- ✓ Five OWASP-recommended security headers
- ✓ Protection against MIME sniffing, clickjacking, and XSS
- ✓ Conditional HSTS for production environments
- ✓ Headers applied to all responses via middleware
- ✓ 5 new tests verify header presence

> **Key takeaway:** Security headers are a defense-in-depth measure. They don't replace secure coding practices but add an extra layer of protection. The @after_request hook ensures headers are added consistently to every response.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add Content-Security-Policy (CSP) header for script control
> - Implement Permissions-Policy for browser feature restrictions
> - Add Cross-Origin headers (CORP, COEP, COOP) for isolation

## Done!

Security headers are complete. Next phase will add the CLI command for admin creation.
