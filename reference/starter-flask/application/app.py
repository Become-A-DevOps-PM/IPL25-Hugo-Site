"""Flask application factory with lazy database initialization."""

import os
import logging
from flask import Flask
from flask_migrate import Migrate
from config import config_by_name
from models import db
from routes import bp

migrate = Migrate()


def create_app(config_name: str = None) -> Flask:
    """Create and configure the Flask application."""
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'development')

    config_class = config_by_name.get(config_name, config_by_name['default'])

    app = Flask(__name__)
    app.config.from_object(config_class)

    # Configure database
    db_url = config_class.get_database_url()
    app.config['SQLALCHEMY_DATABASE_URI'] = db_url

    # Setup logging
    logging.basicConfig(
        level=logging.DEBUG if app.config.get('DEBUG') else logging.INFO,
        format='%(asctime)s %(levelname)s %(name)s: %(message)s'
    )
    logger = logging.getLogger(__name__)

    if db_url:
        db.init_app(app)
        migrate.init_app(app, db)
        db_type = 'SQLite' if 'sqlite' in db_url else 'Azure SQL'
        logger.info(f"Database: {db_type}")
    else:
        logger.warning("No database configured")

    app.register_blueprint(bp)
    return app


app = create_app()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
