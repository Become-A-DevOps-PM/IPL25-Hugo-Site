"""Application factory for the Flask application.

The factory pattern allows creating multiple app instances with different
configurations, which is useful for testing and running multiple instances.
"""
from flask import Flask, render_template
from app.extensions import db, migrate


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
