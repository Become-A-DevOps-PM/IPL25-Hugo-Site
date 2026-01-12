"""Tests for application routes."""


class TestHomeRoute:
    """Tests for GET /."""

    def test_home_returns_200(self, client):
        response = client.get('/')
        assert response.status_code == 200

    def test_home_contains_title(self, client):
        response = client.get('/')
        assert b'Starter Flask' in response.data

    def test_home_contains_link_to_new_note(self, client):
        response = client.get('/')
        assert b'/notes/new' in response.data


class TestNotesNewRoute:
    """Tests for /notes/new."""

    def test_notes_new_get_returns_200(self, client):
        response = client.get('/notes/new')
        assert response.status_code == 200

    def test_notes_new_contains_textarea(self, client):
        response = client.get('/notes/new')
        assert b'<textarea' in response.data

    def test_notes_new_contains_submit_button(self, client):
        response = client.get('/notes/new')
        assert b'<button' in response.data

    def test_notes_new_post_saves_note(self, client):
        response = client.post('/notes/new', data={'content': 'test note'}, follow_redirects=True)
        assert response.status_code == 200
        assert b'Note saved' in response.data

    def test_notes_new_post_empty_shows_error(self, client):
        response = client.post('/notes/new', data={'content': ''})
        assert response.status_code == 200
        assert b'enter some text' in response.data.lower()

    def test_notes_new_post_whitespace_shows_error(self, client):
        response = client.post('/notes/new', data={'content': '   '})
        assert response.status_code == 200
        assert b'enter some text' in response.data.lower()


class TestNotesRoute:
    """Tests for GET /notes."""

    def test_notes_returns_200(self, client):
        response = client.get('/notes')
        assert response.status_code == 200

    def test_notes_contains_title(self, client):
        response = client.get('/notes')
        assert b'List Notes' in response.data

    def test_notes_shows_empty_message(self, client):
        response = client.get('/notes')
        assert b'No notes saved' in response.data

    def test_notes_shows_saved_notes(self, client, app):
        from models import db, Note
        with app.app_context():
            note = Note(content='Test note for list')
            db.session.add(note)
            db.session.commit()

        response = client.get('/notes')
        assert b'Test note for list' in response.data
