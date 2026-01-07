"""Blueprint registration for the application.

All blueprints are registered here to keep the application factory clean.
"""

from app.routes.main import main_bp
from app.routes.api import api_bp


def register_blueprints(app):
    """Register all blueprints with the Flask application.

    Args:
        app: The Flask application instance.
    """
    app.register_blueprint(main_bp)
    app.register_blueprint(api_bp)
