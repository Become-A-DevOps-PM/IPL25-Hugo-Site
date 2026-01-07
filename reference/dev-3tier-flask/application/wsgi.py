"""WSGI entry point for the Flask application.

This module creates the application instance for use by WSGI servers
like Gunicorn. The configuration is determined by the FLASK_ENV
environment variable.

Usage:
    gunicorn wsgi:app
    python wsgi.py  (for development)

Database setup:
    flask db upgrade  (preferred - uses migrations)
    flask db-init     (alternative - creates tables directly)
"""

import os
import click
from app import create_app
from app.extensions import db

# Determine configuration from environment
config = os.environ.get('FLASK_ENV', 'development')
app = create_app(config)


@app.cli.command('db-init')
def db_init():
    """Initialize database tables directly (alternative to migrations)."""
    db.create_all()
    click.echo('Database tables created.')


if __name__ == '__main__':
    # For direct execution, create tables for convenience
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5001, debug=True)
