"""
WSGI entry point for Gunicorn.

Usage:
    gunicorn --workers 2 --bind 0.0.0.0:5001 wsgi:application
"""

from app import create_app

application = create_app()

if __name__ == '__main__':
    application.run()
