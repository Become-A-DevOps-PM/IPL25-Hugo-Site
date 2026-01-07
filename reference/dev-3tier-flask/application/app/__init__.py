"""Application factory for the Flask application.

The factory pattern allows creating multiple app instances with different
configurations, which is useful for testing and running multiple instances.
"""

from flask import Flask
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

    return app
