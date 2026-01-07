"""Pytest fixtures for the Flask application tests."""

import pytest
from app import create_app
from app.extensions import db


@pytest.fixture
def app():
    """Create application instance for testing.

    Uses in-memory SQLite database that is created fresh for each test.

    Yields:
        Flask application instance configured for testing.
    """
    app = create_app('testing')

    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()


@pytest.fixture
def client(app):
    """Create test client for making requests.

    Args:
        app: Flask application fixture.

    Returns:
        Flask test client.
    """
    return app.test_client()


@pytest.fixture
def runner(app):
    """Create CLI runner for testing Flask commands.

    Args:
        app: Flask application fixture.

    Returns:
        Flask CLI test runner.
    """
    return app.test_cli_runner()
