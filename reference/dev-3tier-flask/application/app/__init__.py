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
        """Load user by ID for Flask-Login session management."""
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

    # Register CLI commands
    from app.cli import register_commands
    register_commands(app)

    # Auto-create database tables in production (safe for container deployments)
    if config_name == 'production':
        with app.app_context():
            db.create_all()
            # Auto-create admin user if none exists and ADMIN_PASSWORD is set
            import os
            admin_password = os.environ.get('ADMIN_PASSWORD')
            if admin_password:
                from app.models import User
                if not User.query.filter_by(username='admin').first():
                    try:
                        AuthService.create_user('admin', admin_password)
                        app.logger.info('Default admin user created')
                    except Exception as e:
                        app.logger.warning(f'Could not create admin user: {e}')

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

    Adds OWASP-recommended security headers to all responses:
    - X-Content-Type-Options: Prevents MIME type sniffing
    - X-Frame-Options: Prevents clickjacking
    - X-XSS-Protection: Enables browser XSS filter
    - Referrer-Policy: Controls referrer information
    - Strict-Transport-Security: HTTPS only (production)
    """

    @app.after_request
    def add_security_headers(response):
        """Add security headers to every response."""
        # Prevent MIME type sniffing
        response.headers['X-Content-Type-Options'] = 'nosniff'

        # Prevent clickjacking
        response.headers['X-Frame-Options'] = 'SAMEORIGIN'

        # Enable XSS filter (legacy, but still useful)
        response.headers['X-XSS-Protection'] = '1; mode=block'

        # Control referrer information
        response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'

        # HSTS only in production (when not testing or development)
        if not app.debug and not app.testing:
            response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'

        return response
