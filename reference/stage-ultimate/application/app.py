"""
Flask application factory.
"""

import os
import logging
from flask import Flask
from config import config_by_name, Config
from models import db
from routes import bp


def create_app(config_name: str = None) -> Flask:
    """
    Create and configure the Flask application.

    Args:
        config_name: Configuration name ('development', 'production', 'testing')

    Returns:
        Configured Flask application
    """
    # Determine configuration
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'development')

    config_class = config_by_name.get(config_name, config_by_name['default'])

    # Create app
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Set database URL
    app.config['SQLALCHEMY_DATABASE_URI'] = config_class.get_database_url()

    # Store database type for templates
    app.config['IS_SQLITE'] = config_class.is_sqlite()

    # Configure logging
    logging.basicConfig(
        level=logging.DEBUG if app.config['DEBUG'] else logging.INFO,
        format='%(asctime)s %(levelname)s %(name)s: %(message)s'
    )

    logger = logging.getLogger(__name__)
    logger.info(f"Starting application with {config_name} configuration")
    logger.info(f"Database type: {'SQLite' if app.config['IS_SQLITE'] else 'PostgreSQL'}")

    # Initialize extensions
    db.init_app(app)

    # Register blueprints
    app.register_blueprint(bp)

    # Create database tables
    with app.app_context():
        db.create_all()
        logger.info("Database tables created/verified")

    # Context processor for templates
    @app.context_processor
    def inject_database_info():
        return {
            'is_sqlite': app.config['IS_SQLITE'],
            'database_type': 'SQLite' if app.config['IS_SQLITE'] else 'PostgreSQL'
        }

    return app


# For direct running: python -m app
if __name__ == '__main__':
    application = create_app()
    application.run(host='0.0.0.0', port=5001, debug=True)
