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
        assert b'Join Our Upcoming Webinar' in response.data

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


class TestRegistrationService:
    """Tests for the RegistrationService."""

    def test_create_registration(self, app):
        """Test creating a registration via service."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            reg = RegistrationService.create_registration(
                name='Test User',
                email='test@example.com',
                company='Test Corp',
                job_title='Developer'
            )
            assert reg.id is not None
            assert reg.email == 'test@example.com'

    def test_get_all_registrations_empty(self, app):
        """Test getting registrations when none exist."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            regs = RegistrationService.get_all_registrations()
            assert regs == []

    def test_get_all_registrations_with_data(self, app):
        """Test getting registrations when data exists."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            RegistrationService.create_registration(
                name='User 1', email='u1@test.com', company='C1', job_title='Dev'
            )
            RegistrationService.create_registration(
                name='User 2', email='u2@test.com', company='C2', job_title='PM'
            )
            regs = RegistrationService.get_all_registrations()
            assert len(regs) == 2

    def test_get_registration_count(self, app):
        """Test counting registrations."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            assert RegistrationService.get_registration_count() == 0
            RegistrationService.create_registration(
                name='User', email='u@test.com', company='C', job_title='Dev'
            )
            assert RegistrationService.get_registration_count() == 1


class TestLandingPageEnhanced:
    """Tests for enhanced landing page with CTA."""

    def test_landing_page_has_register_link(self, client):
        """Test that landing page contains register link."""
        response = client.get('/')
        assert response.status_code == 200
        assert b'/register' in response.data
        assert b'Register Now' in response.data

    def test_landing_page_has_hero_section(self, client):
        """Test that landing page has hero content."""
        response = client.get('/')
        assert b'Join Our Upcoming Webinar' in response.data

    def test_landing_page_links_to_demo(self, client):
        """Test that landing page still links to demo."""
        response = client.get('/')
        assert b'/demo' in response.data


class TestRegisterPage:
    """Tests for the registration form page."""

    def test_register_page_loads(self, client):
        """Test that register page loads successfully."""
        response = client.get('/register')
        assert response.status_code == 200

    def test_register_page_has_form(self, client):
        """Test that register page contains a form."""
        response = client.get('/register')
        assert b'<form' in response.data
        assert b'method="POST"' in response.data

    def test_register_page_has_required_fields(self, client):
        """Test that register page has all required form fields."""
        response = client.get('/register')
        assert b'name="name"' in response.data
        assert b'name="email"' in response.data
        assert b'name="company"' in response.data
        assert b'name="job_title"' in response.data

    def test_register_page_has_submit_button(self, client):
        """Test that register page has submit button."""
        response = client.get('/register')
        assert b'type="submit"' in response.data


class TestRegisterSubmission:
    """Tests for registration form submission."""

    def test_register_post_redirects(self, client):
        """Test that POST to /register redirects to thank-you."""
        response = client.post('/register', data={
            'name': 'Test User',
            'email': 'test@example.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        }, follow_redirects=False)
        assert response.status_code == 302
        assert '/thank-you' in response.location

    def test_register_post_creates_registration(self, app, client):
        """Test that POST creates a registration in database."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            initial_count = RegistrationService.get_registration_count()

            client.post('/register', data={
                'name': 'Test User',
                'email': 'test@example.com',
                'company': 'Test Corp',
                'job_title': 'Developer'
            })

            final_count = RegistrationService.get_registration_count()
            assert final_count == initial_count + 1

    def test_register_post_with_follow_redirect(self, client):
        """Test complete POST flow with redirect following."""
        response = client.post('/register', data={
            'name': 'Test User',
            'email': 'test@example.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        }, follow_redirects=True)
        assert response.status_code == 200
        assert b'Thank You' in response.data


class TestThankYouPage:
    """Tests for the thank-you confirmation page."""

    def test_thank_you_page_loads(self, client):
        """Test that thank-you page loads successfully."""
        response = client.get('/thank-you')
        assert response.status_code == 200

    def test_thank_you_page_has_success_message(self, client):
        """Test that thank-you page shows success message."""
        response = client.get('/thank-you')
        assert b'Thank You' in response.data
        assert b'registration' in response.data.lower()

    def test_thank_you_page_has_home_link(self, client):
        """Test that thank-you page links back to home."""
        response = client.get('/thank-you')
        assert b'href="/"' in response.data


class TestAdminAttendees:
    """Tests for the admin attendees page."""

    def test_admin_attendees_loads(self, client):
        """Test that admin attendees page loads."""
        response = client.get('/admin/attendees')
        assert response.status_code == 200

    def test_admin_attendees_shows_count(self, client):
        """Test that admin page shows registration count."""
        response = client.get('/admin/attendees')
        assert b'Total registrations' in response.data

    def test_admin_attendees_empty_state(self, client):
        """Test that admin page shows empty state when no registrations."""
        response = client.get('/admin/attendees')
        assert b'No registrations yet' in response.data

    def test_admin_attendees_shows_registrations(self, app, client):
        """Test that admin page displays registrations."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            RegistrationService.create_registration(
                name='Admin Test',
                email='admin@test.com',
                company='Admin Corp',
                job_title='Admin'
            )

        response = client.get('/admin/attendees')
        assert b'Admin Test' in response.data
        assert b'admin@test.com' in response.data


class TestRegistrationFlow:
    """End-to-end tests for the complete registration journey."""

    def test_landing_to_register_flow(self, client):
        """Test navigation from landing page to registration."""
        # 1. Get landing page
        landing = client.get('/')
        assert landing.status_code == 200
        assert b'/register' in landing.data

        # 2. Navigate to register page
        register = client.get('/register')
        assert register.status_code == 200
        assert b'<form' in register.data

    def test_complete_registration_journey(self, app, client):
        """Test the full registration journey from landing to admin."""
        # 1. Start at landing page
        landing = client.get('/')
        assert b'Register Now' in landing.data

        # 2. Go to registration form
        register_page = client.get('/register')
        assert register_page.status_code == 200

        # 3. Submit registration
        submit = client.post('/register', data={
            'name': 'E2E Test User',
            'email': 'e2e@test.com',
            'company': 'E2E Corp',
            'job_title': 'Tester'
        }, follow_redirects=True)
        assert submit.status_code == 200
        assert b'Thank You' in submit.data

        # 4. Verify in admin
        admin = client.get('/admin/attendees')
        assert admin.status_code == 200
        assert b'E2E Test User' in admin.data
        assert b'e2e@test.com' in admin.data

    def test_multiple_registrations_in_admin(self, app, client):
        """Test that multiple registrations appear in admin."""
        # Create multiple registrations
        for i in range(3):
            client.post('/register', data={
                'name': f'User {i}',
                'email': f'user{i}@test.com',
                'company': f'Company {i}',
                'job_title': 'Developer'
            })

        # Verify all appear in admin
        admin = client.get('/admin/attendees')
        assert b'User 0' in admin.data
        assert b'User 1' in admin.data
        assert b'User 2' in admin.data

    def test_demo_still_works(self, client):
        """Test that Phase 1 demo functionality still works."""
        # Demo page loads
        demo = client.get('/demo/')
        assert demo.status_code == 200
        assert b'demo' in demo.data.lower()

        # Demo form submission works
        post_demo = client.post('/demo/', data={'value': 'E2E Demo Test'})
        assert post_demo.status_code == 302  # Redirect after POST

        # API still works
        api = client.get('/api/health')
        assert api.status_code == 200
