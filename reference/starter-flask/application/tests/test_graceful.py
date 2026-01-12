"""
Tests for graceful degradation without database.

These tests verify that the application can start and serve
basic pages even when no database is configured.
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))


class TestGracefulDegradation:
    """Tests for graceful degradation when database is not configured."""

    def test_app_starts_without_database(self):
        """App should start even without DATABASE_URL."""
        # Clear any existing database configuration
        os.environ.pop('DATABASE_URL', None)
        os.environ['USE_SQLITE'] = 'false'
        os.environ['FLASK_ENV'] = 'production'

        from app import create_app
        app = create_app('production')

        assert app is not None

        # Cleanup
        os.environ.pop('USE_SQLITE', None)
        os.environ.pop('FLASK_ENV', None)

    def test_home_works_without_database(self):
        """Home page should work without database."""
        os.environ.pop('DATABASE_URL', None)
        os.environ['USE_SQLITE'] = 'false'

        from app import create_app
        app = create_app('production')

        with app.test_client() as client:
            response = client.get('/')
            assert response.status_code == 200
            assert b'Starter Flask' in response.data

        # Cleanup
        os.environ.pop('USE_SQLITE', None)

    def test_health_works_without_database(self):
        """Health endpoint should work without database."""
        os.environ.pop('DATABASE_URL', None)
        os.environ['USE_SQLITE'] = 'false'

        from app import create_app
        app = create_app('production')

        with app.test_client() as client:
            response = client.get('/health')
            assert response.status_code == 200
            data = response.get_json()
            assert data['status'] == 'ok'
            assert data['database'] == 'not_configured'

        # Cleanup
        os.environ.pop('USE_SQLITE', None)

    def test_form_get_works_without_database(self):
        """Form GET should work without database."""
        os.environ.pop('DATABASE_URL', None)
        os.environ['USE_SQLITE'] = 'false'

        from app import create_app
        app = create_app('production')

        with app.test_client() as client:
            response = client.get('/form')
            assert response.status_code == 200
            assert b'<textarea' in response.data

        # Cleanup
        os.environ.pop('USE_SQLITE', None)

    def test_form_post_fails_gracefully_without_database(self):
        """Form POST should fail gracefully without database."""
        os.environ.pop('DATABASE_URL', None)
        os.environ['USE_SQLITE'] = 'false'

        from app import create_app
        app = create_app('production')

        with app.test_client() as client:
            response = client.post('/form', data={'content': 'test note'})
            # Should return 200 with error message, not crash
            assert response.status_code == 200
            # Should show error message
            assert b'Failed to save' in response.data or b'not configured' in response.data.lower()

        # Cleanup
        os.environ.pop('USE_SQLITE', None)
