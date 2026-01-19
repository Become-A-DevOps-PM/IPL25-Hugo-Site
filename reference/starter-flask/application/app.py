"""Flask application factory."""

import os
from flask import Flask
from flask_migrate import Migrate
from config import config_by_name
from models import db
from routes import bp

migrate = Migrate()


def create_app(config_name=None):
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'local')

    config_class = config_by_name.get(config_name, config_by_name['default'])

    app = Flask(__name__)
    app.config.from_object(config_class)
    app.config['SQLALCHEMY_DATABASE_URI'] = config_class.get_database_url()

    if app.config['SQLALCHEMY_DATABASE_URI']:
        db.init_app(app)
        migrate.init_app(app, db)

    app.register_blueprint(bp)

    def _mask_secret(value):
        """Show only first 4 characters of a secret."""
        if not value:
            return None
        return value[:4] + '...' if len(value) > 4 else value

    @app.context_processor
    def inject_env_info():
        db_uri = app.config.get('SQLALCHEMY_DATABASE_URI') or ''
        if db_uri.startswith('sqlite:'):
            db_type = 'SQLite'
        elif db_uri.startswith('postgresql:'):
            db_type = 'PostgreSQL'
        else:
            db_type = 'None'

        return {
            'env_info': {
                'FLASK_ENV': os.environ.get('FLASK_ENV', 'local'),
                'DB_TYPE': db_type
            },
            'env_table': [
                {
                    'name': 'FLASK_ENV',
                    'env_value': os.environ.get('FLASK_ENV'),
                    'actual_value': config_name
                },
                {
                    'name': 'DATABASE_URL',
                    'env_value': os.environ.get('DATABASE_URL'),
                    'actual_value': db_uri if db_uri else None
                },
                {
                    'name': 'USE_SQLITE',
                    'env_value': os.environ.get('USE_SQLITE'),
                    'actual_value': 'true' if db_uri.startswith('sqlite:') else 'false'
                },
                {
                    'name': 'SECRET_KEY',
                    'env_value': _mask_secret(os.environ.get('SECRET_KEY')),
                    'actual_value': _mask_secret(app.config.get('SECRET_KEY'))
                }
            ]
        }

    return app


app = create_app()
