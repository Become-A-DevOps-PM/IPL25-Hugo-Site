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
        db.session.remove()
        db.drop_all()
        db.engine.dispose()


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


@pytest.fixture
def authenticated_client(app, client):
    """Create test client with authenticated admin user.

    Creates an admin user and logs them in, returning a client
    that can access protected routes.

    Args:
        app: Flask application fixture.
        client: Flask test client fixture.

    Returns:
        Flask test client with authenticated session.
    """
    with app.app_context():
        from app.services.auth_service import AuthService
        AuthService.create_user('testadmin', 'testpassword123')

    client.post('/auth/login', data={
        'username': 'testadmin',
        'password': 'testpassword123'
    })
    return client
