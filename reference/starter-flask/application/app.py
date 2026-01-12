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
    return app


app = create_app()
