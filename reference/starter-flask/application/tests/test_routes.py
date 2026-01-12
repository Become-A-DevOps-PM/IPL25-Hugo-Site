"""
Tests for application routes.
"""


class TestHomeRoute:
    """Tests for GET /."""

    def test_home_returns_200(self, client):
        """Home page should return 200."""
        response = client.get('/')
        assert response.status_code == 200

    def test_home_contains_title(self, client):
        """Home page should contain title."""
        response = client.get('/')
        assert b'Starter Flask' in response.data

    def test_home_contains_link_to_form(self, client):
        """Home page should contain link to form."""
        response = client.get('/')
        assert b'/form' in response.data


class TestFormRoute:
    """Tests for /form."""

    def test_form_get_returns_200(self, client):
        """GET /form should return 200."""
        response = client.get('/form')
        assert response.status_code == 200

    def test_form_contains_textarea(self, client):
        """Form page should contain textarea."""
        response = client.get('/form')
        assert b'<textarea' in response.data

    def test_form_contains_submit_button(self, client):
        """Form page should contain submit button."""
        response = client.get('/form')
        assert b'<button' in response.data

    def test_form_post_saves_note(self, client):
        """POST /form with valid data should save note."""
        response = client.post('/form', data={'content': 'test note'})
        assert response.status_code == 200
        assert b'Saved' in response.data or b'Note Saved' in response.data

    def test_form_post_empty_shows_error(self, client):
        """POST /form with empty content should show error."""
        response = client.post('/form', data={'content': ''})
        assert response.status_code == 200
        assert b'enter some text' in response.data.lower()

    def test_form_post_whitespace_shows_error(self, client):
        """POST /form with whitespace-only content should show error."""
        response = client.post('/form', data={'content': '   '})
        assert response.status_code == 200
        assert b'enter some text' in response.data.lower()


class TestHealthRoute:
    """Tests for GET /health."""

    def test_health_returns_200(self, client):
        """Health check should return 200."""
        response = client.get('/health')
        assert response.status_code == 200

    def test_health_returns_json(self, client):
        """Health check should return JSON."""
        response = client.get('/health')
        assert response.content_type == 'application/json'

    def test_health_returns_ok_status(self, client):
        """Health check should return ok status."""
        response = client.get('/health')
        data = response.get_json()
        assert data['status'] == 'ok'

    def test_health_shows_database_status(self, client):
        """Health check should show database status."""
        response = client.get('/health')
        data = response.get_json()
        assert 'database' in data
        # In testing mode with SQLite, should be connected
        assert data['database'] == 'connected'


class TestNotesRoute:
    """Tests for GET /notes."""

    def test_notes_returns_200(self, client):
        """Notes page should return 200."""
        response = client.get('/notes')
        assert response.status_code == 200

    def test_notes_contains_title(self, client):
        """Notes page should contain title."""
        response = client.get('/notes')
        assert b'Saved Notes' in response.data

    def test_notes_shows_empty_message(self, client):
        """Notes page should show empty message when no notes."""
        response = client.get('/notes')
        assert b'No notes saved' in response.data

    def test_notes_shows_saved_notes(self, client, app):
        """Notes page should display saved notes."""
        from models import db, Note
        with app.app_context():
            note = Note(content='Test note for list')
            db.session.add(note)
            db.session.commit()

        response = client.get('/notes')
        assert b'Test note for list' in response.data
