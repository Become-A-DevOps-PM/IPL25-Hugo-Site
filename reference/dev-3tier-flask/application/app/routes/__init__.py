"""Blueprint registration for the application.

All blueprints are registered here to keep the application factory clean.
"""

from app.routes.main import main_bp
from app.routes.api import api_bp
from app.routes.demo import demo_bp
from app.routes.admin import admin_bp
from app.routes.auth import auth_bp


def register_blueprints(app):
    """Register all blueprints with the Flask application.

    Args:
        app: The Flask application instance.
    """
    app.register_blueprint(main_bp)
    app.register_blueprint(api_bp)
    app.register_blueprint(demo_bp)
    app.register_blueprint(admin_bp)
    app.register_blueprint(auth_bp)
