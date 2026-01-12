"""
Flask application factory with lazy database initialization.

Key feature: App starts even without database connection.
Database errors only occur when actually accessing database.
"""

import os
import logging
from flask import Flask
from flask_migrate import Migrate
from config import config_by_name

# Global migrate instance for Flask-Migrate
migrate = Migrate()


def create_app(config_name: str = None) -> Flask:
    """
    Create and configure the Flask application.

    Args:
        config_name: Configuration to use ('development', 'production', 'testing')
                    Defaults to FLASK_ENV environment variable or 'development'.

    Returns:
        Configured Flask application instance.
    """
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'development')

    config_class = config_by_name.get(config_name, config_by_name['default'])

    app = Flask(__name__)
    app.config.from_object(config_class)

    # Get database URL (may be None for graceful degradation)
    db_url = config_class.get_database_url()
    app.config['SQLALCHEMY_DATABASE_URI'] = db_url

    # Configure logging
    logging.basicConfig(
        level=logging.DEBUG if app.config.get('DEBUG') else logging.INFO,
        format='%(asctime)s %(levelname)s %(name)s: %(message)s'
    )
    logger = logging.getLogger(__name__)

    if db_url:
        db_type = 'SQLite' if 'sqlite' in db_url else 'Azure SQL'
        logger.info(f"Database configured: {db_type}")

        # Initialize database and migrations
        from models import db
        db.init_app(app)
        migrate.init_app(app, db)
        logger.info("Flask-Migrate initialized - run 'flask db upgrade' to apply migrations")
    else:
        logger.warning("No database configured - form submissions will fail")

    # Register routes
    from routes import bp
    app.register_blueprint(bp)

    return app


# For Gunicorn: gunicorn app:app
app = create_app()


# For direct running: python app.py
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
