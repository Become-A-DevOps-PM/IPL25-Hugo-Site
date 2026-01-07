"""Tests for application routes."""


class TestHealthEndpoint:
    """Tests for the /api/health endpoint."""

    def test_health_returns_200(self, client):
        """Health check should return 200 OK."""
        response = client.get('/api/health')
        assert response.status_code == 200

    def test_health_returns_healthy_status(self, client):
        """Health check should return healthy status."""
        response = client.get('/api/health')
        assert response.json['status'] == 'healthy'


class TestIndexPage:
    """Tests for the main index page."""

    def test_index_get_returns_200(self, client):
        """GET / should return 200 OK."""
        response = client.get('/')
        assert response.status_code == 200

    def test_index_contains_form(self, client):
        """Index page should contain the entry form."""
        response = client.get('/')
        assert b'<form' in response.data
        assert b'Add Entry' in response.data

    def test_index_shows_no_entries_initially(self, client):
        """Index page should show no entries message when empty."""
        response = client.get('/')
        assert b'No entries yet' in response.data


class TestCreateEntry:
    """Tests for creating entries via POST."""

    def test_create_entry_redirects(self, client):
        """POST / should redirect to avoid form resubmission."""
        response = client.post('/', data={'value': 'test entry'})
        assert response.status_code == 302

    def test_create_entry_appears_on_page(self, client):
        """Created entry should appear on the index page."""
        client.post('/', data={'value': 'my test value'})
        response = client.get('/')
        assert b'my test value' in response.data

    def test_empty_value_not_created(self, client):
        """POST with empty value should not create entry."""
        client.post('/', data={'value': ''})
        response = client.get('/')
        assert b'No entries yet' in response.data


class TestEntriesAPI:
    """Tests for the /api/entries endpoint."""

    def test_entries_returns_200(self, client):
        """GET /api/entries should return 200 OK."""
        response = client.get('/api/entries')
        assert response.status_code == 200

    def test_entries_returns_empty_list_initially(self, client):
        """GET /api/entries should return empty list when no entries."""
        response = client.get('/api/entries')
        assert response.json == []

    def test_entries_returns_created_entries(self, client):
        """GET /api/entries should include created entries."""
        client.post('/', data={'value': 'api test'})
        response = client.get('/api/entries')

        assert len(response.json) == 1
        assert response.json[0]['value'] == 'api test'
        assert 'id' in response.json[0]
        assert 'created_at' in response.json[0]
