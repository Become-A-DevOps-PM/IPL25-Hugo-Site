# Flask-Login Integration

## Goal

Configure Flask-Login with LoginManager and create the user_loader callback for session management.

> **What you'll learn:**
>
> - Initializing Flask-Login with the application
> - Creating the user_loader callback
> - Configuring login view and messages
> - How Flask-Login manages user sessions

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 4.2 (Auth Service)
> - ✓ All 87 tests passing
> - ✓ Understanding of Flask extensions pattern

## Exercise Steps

### Overview

1. **Add LoginManager to Extensions**
2. **Initialize in Application Factory**
3. **Add Flask-Login Tests**
4. **Verify with pytest**

### **Step 1:** Add LoginManager to Extensions

The LoginManager handles user session management and configuration.

1. **Open** `application/app/extensions.py`

2. **Update** with Flask-Login configuration:

   ```python
   """Flask extensions initialization.

   Extensions are instantiated here without being bound to an application.
   They are initialized with the app in the application factory.
   """

   from flask_sqlalchemy import SQLAlchemy
   from flask_migrate import Migrate
   from flask_login import LoginManager

   # Database ORM
   db = SQLAlchemy()

   # Database migrations
   migrate = Migrate()

   # User session management
   login_manager = LoginManager()
   login_manager.login_view = 'auth.login'
   login_manager.login_message = 'Please log in to access this page.'
   login_manager.login_message_category = 'info'
   ```

> ℹ **Concept Deep Dive**
>
> - **LoginManager()** creates the extension instance without binding to an app
> - **login_view** specifies where to redirect unauthenticated users
> - **login_message** is shown when users are redirected to login
> - **login_message_category** controls the flash message category
>
> The format `'auth.login'` is `blueprint_name.function_name`.
>
> ✓ **Quick check:** LoginManager configured with login_view set to 'auth.login'

### **Step 2:** Initialize in Application Factory

Connect Flask-Login to the application and register the user_loader callback.

1. **Open** `application/app/__init__.py`

2. **Update** to include Flask-Login initialization:

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
> - **login_manager.init_app(app)** binds the extension to the Flask app
> - **@login_manager.user_loader** decorator registers the callback
> - **user_loader** is called on every request to load the current user from session
> - The callback receives a user_id (string) and must return a User or None
>
> Flask-Login stores only the user ID in the session for security. The user_loader
> reconstructs the full User object on each request.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to import login_manager from extensions
> - Not initializing with init_app()
> - user_loader not returning None for invalid IDs
>
> ✓ **Quick check:** user_loader uses AuthService.get_user_by_id()

### **Step 3:** Add Flask-Login Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

   ```python
   class TestFlaskLoginSetup:
       """Tests for Flask-Login configuration."""

       def test_login_manager_configured(self, app):
           """Test that login manager is configured on the app."""
           assert hasattr(app, 'login_manager')

       def test_login_view_set(self, app):
           """Test that login view is configured."""
           from app.extensions import login_manager
           assert login_manager.login_view == 'auth.login'

       def test_user_loader_works(self, app):
           """Test that user loader can load a user."""
           with app.app_context():
               from app.services.auth_service import AuthService
               from app.extensions import login_manager

               created = AuthService.create_user('loadertest', 'password123')
               loaded = login_manager._user_callback(str(created.id))
               assert loaded.username == 'loadertest'
   ```

> ℹ **Concept Deep Dive**
>
> - **hasattr(app, 'login_manager')** verifies Flask-Login is initialized
> - **_user_callback** is the internal callback reference used by Flask-Login
> - Testing with actual user creation ensures end-to-end integration
>
> ✓ **Quick check:** 3 new tests for Flask-Login configuration

### **Step 4:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 87 + 3 = 90 tests passing

> ✓ **Success indicators:**
>
> - All 90 tests pass
> - LoginManager properly initialized
> - user_loader correctly loads users by ID

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `extensions.py` has LoginManager with login_view configured
> - ☐ `__init__.py` initializes login_manager with init_app()
> - ☐ user_loader callback registered in application factory
> - ☐ user_loader uses AuthService.get_user_by_id()
> - ☐ `pytest tests/test_routes.py -v` passes (90 tests)

## Common Issues

> **If you encounter problems:**
>
> **ImportError for LoginManager:** Verify Flask-Login is installed in requirements.txt
>
> **user_loader not called:** Ensure login_manager.init_app(app) is called
>
> **Login redirect not working:** login_view must match actual blueprint route (auth.login)
>
> **Session not persisting:** Check SECRET_KEY is set in configuration

## Summary

You've integrated Flask-Login with the application:

- ✓ LoginManager extension configured with login_view
- ✓ Extension initialized in application factory
- ✓ user_loader callback retrieves users from database
- ✓ Ready for @login_required protection
- ✓ 3 new tests verify configuration

> **Key takeaway:** Flask-Login handles session management automatically once configured. The user_loader callback is the bridge between the session (containing just user_id) and the full User object from the database.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Customize the login_message for different scenarios
> - Implement fresh login requirement for sensitive operations
> - Add session timeout configuration

## Done!

Flask-Login integration is complete. Next phase will create the login form.
