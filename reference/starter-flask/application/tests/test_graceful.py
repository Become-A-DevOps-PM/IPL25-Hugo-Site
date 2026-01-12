"""Tests for graceful degradation without database."""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))


class TestGracefulDegradation:
    """Tests for graceful degradation when database is not configured."""

    def test_app_starts_without_database(self):
        os.environ.pop('DATABASE_URL', None)
        os.environ['USE_SQLITE'] = 'false'

        from app import create_app
        app = create_app('production')
        assert app is not None

        os.environ.pop('USE_SQLITE', None)

    def test_home_works_without_database(self):
        os.environ.pop('DATABASE_URL', None)
        os.environ['USE_SQLITE'] = 'false'

        from app import create_app
        app = create_app('production')

        with app.test_client() as client:
            response = client.get('/')
            assert response.status_code == 200
            assert b'Starter Flask' in response.data

        os.environ.pop('USE_SQLITE', None)

    def test_notes_new_get_works_without_database(self):
        os.environ.pop('DATABASE_URL', None)
        os.environ['USE_SQLITE'] = 'false'

        from app import create_app
        app = create_app('production')

        with app.test_client() as client:
            response = client.get('/notes/new')
            assert response.status_code == 200
            assert b'<textarea' in response.data

        os.environ.pop('USE_SQLITE', None)

    def test_notes_new_post_fails_gracefully_without_database(self):
        os.environ.pop('DATABASE_URL', None)
        os.environ['USE_SQLITE'] = 'false'

        from app import create_app
        app = create_app('production')

        with app.test_client() as client:
            response = client.post('/notes/new', data={'content': 'test note'})
            assert response.status_code == 200
            assert b'not configured' in response.data.lower()

        os.environ.pop('USE_SQLITE', None)
