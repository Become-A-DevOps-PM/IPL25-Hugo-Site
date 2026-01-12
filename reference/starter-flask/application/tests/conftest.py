"""
Pytest fixtures for testing.

Uses in-memory SQLite for fast, isolated tests.
"""

import os
import sys
import pytest

# Add application directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))


@pytest.fixture
def app():
    """Create test application with in-memory SQLite."""
    from app import create_app
    from models import db

    app = create_app('testing')

    with app.app_context():
        db.create_all()
        yield app
        db.session.remove()
        db.drop_all()


@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()


@pytest.fixture
def runner(app):
    """Create CLI test runner."""
    return app.test_cli_runner()
