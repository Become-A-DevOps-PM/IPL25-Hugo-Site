"""Tests for application routes."""

from app.models.entry import Entry


class TestEntryModel:
    """Tests for the Entry model."""

    def test_entry_repr(self, client):
        """Entry __repr__ should show id and truncated value."""
        client.post('/demo/', data={'value': 'test repr value'})
        response = client.get('/api/entries')
        entry_id = response.json[0]['id']

        # Get the actual entry from database
        from app.extensions import db
        entry = db.session.get(Entry, entry_id)
        repr_str = repr(entry)

        assert f'<Entry {entry_id}:' in repr_str
        assert 'test repr value' in repr_str


class TestHealthEndpoint:
    """Tests for the /api/health endpoint."""

    def test_health_returns_200(self, client):
        """Health check should return 200 OK."""
        response = client.get('/api/health')
        assert response.status_code == 200

    def test_health_returns_ok_status(self, client):
        """Health check should return ok status."""
        response = client.get('/api/health')
        assert response.json['status'] == 'ok'


class TestLandingPage:
    """Tests for the landing page at /."""

    def test_landing_get_returns_200(self, client):
        """GET / should return 200 OK."""
        response = client.get('/')
        assert response.status_code == 200

    def test_landing_contains_welcome_message(self, client):
        """Landing page should contain welcome message."""
        response = client.get('/')
        assert b'Flask Three-Tier Application' in response.data

    def test_landing_links_to_demo(self, client):
        """Landing page should link to demo application."""
        response = client.get('/')
        assert b'/demo' in response.data


class TestDemoPage:
    """Tests for the demo page at /demo."""

    def test_demo_get_returns_200(self, client):
        """GET /demo should return 200 OK."""
        response = client.get('/demo/')
        assert response.status_code == 200

    def test_demo_contains_form(self, client):
        """Demo page should contain the entry form."""
        response = client.get('/demo/')
        assert b'<form' in response.data
        assert b'Add Entry' in response.data

    def test_demo_shows_no_entries_initially(self, client):
        """Demo page should show no entries message when empty."""
        response = client.get('/demo/')
        assert b'No entries yet' in response.data


class TestCreateEntry:
    """Tests for creating entries via POST to /demo."""

    def test_create_entry_redirects(self, client):
        """POST /demo should redirect to avoid form resubmission."""
        response = client.post('/demo/', data={'value': 'test entry'})
        assert response.status_code == 302

    def test_create_entry_appears_on_page(self, client):
        """Created entry should appear on the demo page."""
        client.post('/demo/', data={'value': 'my test value'})
        response = client.get('/demo/')
        assert b'my test value' in response.data

    def test_empty_value_not_created(self, client):
        """POST with empty value should not create entry."""
        client.post('/demo/', data={'value': ''})
        response = client.get('/demo/')
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
        client.post('/demo/', data={'value': 'api test'})
        response = client.get('/api/entries')

        assert len(response.json) == 1
        assert response.json[0]['value'] == 'api test'
        assert 'id' in response.json[0]
        assert 'created_at' in response.json[0]


class TestRegistrationModel:
    """Tests for the Registration model."""

    def test_registration_repr(self, app):
        """Test Registration string representation."""
        with app.app_context():
            from app.models.registration import Registration
            reg = Registration(
                name='Test User',
                email='test@example.com',
                company='Test Corp',
                job_title='Developer'
            )
            assert '<Registration test@example.com>' in repr(reg)

    def test_registration_to_dict(self, app):
        """Test Registration to_dict method."""
        with app.app_context():
            from app.models.registration import Registration
            reg = Registration(
                name='Test User',
                email='test@example.com',
                company='Test Corp',
                job_title='Developer'
            )
            d = reg.to_dict()
            assert d['name'] == 'Test User'
            assert d['email'] == 'test@example.com'
            assert d['company'] == 'Test Corp'
            assert d['job_title'] == 'Developer'
