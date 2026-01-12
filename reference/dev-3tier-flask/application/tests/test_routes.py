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

    def test_admin_attendees_loads(self, authenticated_client):
        """Test that admin attendees page loads."""
        response = authenticated_client.get('/admin/attendees')
        assert response.status_code == 200

    def test_admin_attendees_shows_count(self, authenticated_client):
        """Test that admin page shows registration count."""
        response = authenticated_client.get('/admin/attendees')
        assert b'Total Registrations' in response.data

    def test_admin_attendees_empty_state(self, authenticated_client):
        """Test that admin page shows empty state when no registrations."""
        response = authenticated_client.get('/admin/attendees')
        assert b'No registrations yet' in response.data

    def test_admin_attendees_shows_registrations(self, app, authenticated_client):
        """Test that admin page displays registrations."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            RegistrationService.create_registration(
                name='Admin Test',
                email='admin@test.com',
                company='Admin Corp',
                job_title='Admin'
            )

        response = authenticated_client.get('/admin/attendees')
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

    def test_complete_registration_journey(self, app, authenticated_client):
        """Test the full registration journey from landing to admin."""
        # 1. Start at landing page
        landing = authenticated_client.get('/')
        assert b'Register Now' in landing.data

        # 2. Go to registration form
        register_page = authenticated_client.get('/register')
        assert register_page.status_code == 200

        # 3. Submit registration
        submit = authenticated_client.post('/register', data={
            'name': 'E2E Test User',
            'email': 'e2e@test.com',
            'company': 'E2E Corp',
            'job_title': 'Tester'
        }, follow_redirects=True)
        assert submit.status_code == 200
        assert b'Thank You' in submit.data

        # 4. Verify in admin (authenticated)
        admin = authenticated_client.get('/admin/attendees')
        assert admin.status_code == 200
        assert b'E2E Test User' in admin.data
        assert b'e2e@test.com' in admin.data

    def test_multiple_registrations_in_admin(self, app, authenticated_client):
        """Test that multiple registrations appear in admin."""
        # Create multiple registrations
        for i in range(3):
            authenticated_client.post('/register', data={
                'name': f'User {i}',
                'email': f'user{i}@test.com',
                'company': f'Company {i}',
                'job_title': 'Developer'
            })

        # Verify all appear in admin (authenticated)
        admin = authenticated_client.get('/admin/attendees')
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


# ========== Phase 3 Tests ==========

class TestFormValidation:
    """Tests for WTForms validation on registration."""

    def test_register_rejects_empty_name(self, client):
        """Test that empty name is rejected with error message."""
        response = client.post('/register', data={
            'name': '',
            'email': 'test@example.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        })
        assert response.status_code == 200  # Returns form with errors
        assert b'Name is required' in response.data

    def test_register_rejects_short_name(self, client):
        """Test that name shorter than 2 chars is rejected."""
        response = client.post('/register', data={
            'name': 'A',
            'email': 'test@example.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        })
        assert response.status_code == 200
        assert b'must be between 2 and 100 characters' in response.data

    def test_register_rejects_invalid_email(self, client):
        """Test that invalid email format is rejected."""
        response = client.post('/register', data={
            'name': 'Test User',
            'email': 'not-an-email',
            'company': 'Test Corp',
            'job_title': 'Developer'
        })
        assert response.status_code == 200
        assert b'valid email address' in response.data

    def test_register_rejects_empty_company(self, client):
        """Test that empty company is rejected."""
        response = client.post('/register', data={
            'name': 'Test User',
            'email': 'test@example.com',
            'company': '',
            'job_title': 'Developer'
        })
        assert response.status_code == 200
        assert b'Company is required' in response.data

    def test_register_rejects_empty_job_title(self, client):
        """Test that empty job title is rejected."""
        response = client.post('/register', data={
            'name': 'Test User',
            'email': 'test@example.com',
            'company': 'Test Corp',
            'job_title': ''
        })
        assert response.status_code == 200
        assert b'Job title is required' in response.data

    def test_register_accepts_valid_data(self, client):
        """Test that valid data is accepted and redirects."""
        response = client.post('/register', data={
            'name': 'Valid User',
            'email': 'valid@example.com',
            'company': 'Valid Corp',
            'job_title': 'Developer'
        }, follow_redirects=False)
        assert response.status_code == 302
        assert '/thank-you' in response.location

    def test_register_shows_multiple_errors(self, client):
        """Test that multiple validation errors are shown."""
        response = client.post('/register', data={
            'name': '',
            'email': 'invalid',
            'company': '',
            'job_title': ''
        })
        assert response.status_code == 200
        assert b'Name is required' in response.data
        assert b'valid email address' in response.data
        assert b'Company is required' in response.data
        assert b'Job title is required' in response.data


class TestDuplicateEmailPrevention:
    """Tests for duplicate email prevention."""

    def test_duplicate_email_rejected(self, app, client):
        """Test that duplicate email registration is rejected."""
        # First registration
        client.post('/register', data={
            'name': 'First User',
            'email': 'duplicate@test.com',
            'company': 'First Corp',
            'job_title': 'Developer'
        })

        # Second registration with same email
        response = client.post('/register', data={
            'name': 'Second User',
            'email': 'duplicate@test.com',
            'company': 'Second Corp',
            'job_title': 'Manager'
        })

        assert response.status_code == 200  # Returns form with error
        assert b'already registered' in response.data

    def test_duplicate_email_case_insensitive(self, app, client):
        """Test that email uniqueness is case-insensitive."""
        # First registration with lowercase
        client.post('/register', data={
            'name': 'First User',
            'email': 'casetest@example.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        })

        # Second registration with uppercase
        response = client.post('/register', data={
            'name': 'Second User',
            'email': 'CASETEST@EXAMPLE.COM',
            'company': 'Test Corp',
            'job_title': 'Developer'
        })

        assert response.status_code == 200
        assert b'already registered' in response.data

    def test_different_emails_allowed(self, app, client):
        """Test that different emails can register."""
        # First registration
        response1 = client.post('/register', data={
            'name': 'First User',
            'email': 'first@test.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        }, follow_redirects=False)
        assert response1.status_code == 302

        # Second registration with different email
        response2 = client.post('/register', data={
            'name': 'Second User',
            'email': 'second@test.com',
            'company': 'Test Corp',
            'job_title': 'Developer'
        }, follow_redirects=False)
        assert response2.status_code == 302

    def test_email_exists_service_method(self, app):
        """Test the email_exists service method."""
        with app.app_context():
            from app.services.registration_service import RegistrationService

            # Initially no email exists
            assert not RegistrationService.email_exists('new@test.com')

            # Create registration
            RegistrationService.create_registration(
                name='Test', email='exists@test.com',
                company='Corp', job_title='Dev'
            )

            # Now email exists
            assert RegistrationService.email_exists('exists@test.com')
            assert RegistrationService.email_exists('EXISTS@TEST.COM')  # Case-insensitive


class TestFlashMessages:
    """Tests for flash message display."""

    def test_success_flash_on_registration(self, client):
        """Test that success flash appears after registration."""
        response = client.post('/register', data={
            'name': 'Flash Test User',
            'email': 'flash@test.com',
            'company': 'Flash Corp',
            'job_title': 'Developer'
        }, follow_redirects=True)

        assert response.status_code == 200
        assert b'Registration successful' in response.data

    def test_form_preserves_input_on_error(self, client):
        """Test that form preserves input when validation fails."""
        response = client.post('/register', data={
            'name': 'Preserved Name',
            'email': 'invalid-email',
            'company': 'Preserved Company',
            'job_title': 'Preserved Title'
        })

        assert response.status_code == 200
        assert b'Preserved Name' in response.data
        assert b'Preserved Company' in response.data
        assert b'Preserved Title' in response.data


class TestWebinarInfoPage:
    """Tests for the webinar information page (FR-001)."""

    def test_webinar_info_page_loads(self, client):
        """Test that webinar info page loads successfully."""
        response = client.get('/webinar')
        assert response.status_code == 200

    def test_webinar_info_has_title(self, client):
        """Test that webinar info page has event title."""
        response = client.get('/webinar')
        assert b'Cloud Infrastructure Fundamentals' in response.data

    def test_webinar_info_has_date_time(self, client):
        """Test that webinar info page shows date and time."""
        response = client.get('/webinar')
        assert b'February 15, 2026' in response.data
        assert b'10:00 AM' in response.data

    def test_webinar_info_has_agenda(self, client):
        """Test that webinar info page includes agenda."""
        response = client.get('/webinar')
        assert b'Agenda' in response.data
        assert b'Infrastructure as Code' in response.data

    def test_webinar_info_has_speakers(self, client):
        """Test that webinar info page shows speakers."""
        response = client.get('/webinar')
        assert b'Speakers' in response.data
        assert b'Sarah Chen' in response.data
        assert b'Marcus Johnson' in response.data

    def test_webinar_info_has_register_link(self, client):
        """Test that webinar info page links to registration."""
        response = client.get('/webinar')
        assert b'/register' in response.data
        assert b'Register Now' in response.data

    def test_landing_page_links_to_webinar_info(self, client):
        """Test that landing page links to webinar info."""
        response = client.get('/')
        assert b'/webinar' in response.data
        assert b'Learn More' in response.data


class TestAdminSorting:
    """Tests for admin attendee list sorting."""

    def test_admin_default_sort_by_date_desc(self, app, authenticated_client):
        """Test default sort is by created_at descending."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            import time

            RegistrationService.create_registration(
                name='First User', email='first@test.com',
                company='Corp', job_title='Dev'
            )
            time.sleep(0.1)  # Ensure different timestamps
            RegistrationService.create_registration(
                name='Second User', email='second@test.com',
                company='Corp', job_title='Dev'
            )

        response = authenticated_client.get('/admin/attendees')
        # Second should appear before First (desc order)
        second_pos = response.data.find(b'Second User')
        first_pos = response.data.find(b'First User')
        assert second_pos < first_pos

    def test_admin_sort_by_name_asc(self, app, authenticated_client):
        """Test sorting by name ascending."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            RegistrationService.create_registration(
                name='Zoe', email='zoe@test.com',
                company='Corp', job_title='Dev'
            )
            RegistrationService.create_registration(
                name='Alice', email='alice@test.com',
                company='Corp', job_title='Dev'
            )

        response = authenticated_client.get('/admin/attendees?sort=name&order=asc')
        alice_pos = response.data.find(b'Alice')
        zoe_pos = response.data.find(b'Zoe')
        assert alice_pos < zoe_pos

    def test_admin_shows_stats(self, app, authenticated_client):
        """Test that admin page shows statistics."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            for i in range(3):
                RegistrationService.create_registration(
                    name=f'User {i}', email=f'statsuser{i}@test.com',
                    company='Corp', job_title='Dev'
                )

        response = authenticated_client.get('/admin/attendees')
        assert b'Total Registrations' in response.data

    def test_admin_has_export_link(self, authenticated_client, app):
        """Test that admin page has export CSV link when registrations exist."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            RegistrationService.create_registration(
                name='Export Test', email='export@test.com',
                company='Corp', job_title='Dev'
            )

        response = authenticated_client.get('/admin/attendees')
        assert b'Export CSV' in response.data


class TestCSVExport:
    """Tests for CSV export functionality."""

    def test_export_csv_returns_csv_content_type(self, authenticated_client):
        """Test that export returns CSV content type."""
        response = authenticated_client.get('/admin/export/csv')
        assert response.status_code == 200
        assert 'text/csv' in response.content_type

    def test_export_csv_has_attachment_header(self, authenticated_client):
        """Test that export has attachment filename header."""
        response = authenticated_client.get('/admin/export/csv')
        assert 'attachment' in response.headers.get('Content-Disposition', '')
        assert 'webinar-registrations' in response.headers.get('Content-Disposition', '')
        assert '.csv' in response.headers.get('Content-Disposition', '')

    def test_export_csv_contains_headers(self, authenticated_client):
        """Test that CSV contains column headers."""
        response = authenticated_client.get('/admin/export/csv')
        csv_content = response.data.decode('utf-8')
        assert 'ID' in csv_content
        assert 'Name' in csv_content
        assert 'Email' in csv_content
        assert 'Company' in csv_content
        assert 'Job Title' in csv_content
        assert 'Registered At' in csv_content

    def test_export_csv_contains_data(self, app, authenticated_client):
        """Test that CSV contains registration data."""
        with app.app_context():
            from app.services.registration_service import RegistrationService
            RegistrationService.create_registration(
                name='CSV Export Test',
                email='csvtest@example.com',
                company='Export Corp',
                job_title='Exporter'
            )

        response = authenticated_client.get('/admin/export/csv')
        csv_content = response.data.decode('utf-8')
        assert 'CSV Export Test' in csv_content
        assert 'csvtest@example.com' in csv_content
        assert 'Export Corp' in csv_content
        assert 'Exporter' in csv_content

    def test_export_csv_empty_returns_headers_only(self, authenticated_client):
        """Test that empty export still returns headers."""
        response = authenticated_client.get('/admin/export/csv')
        csv_content = response.data.decode('utf-8')
        lines = csv_content.strip().split('\n')
        assert len(lines) == 1  # Just the header row
        assert 'Name' in lines[0]


class TestErrorPages:
    """Tests for custom error pages."""

    def test_404_page_for_nonexistent_route(self, client):
        """Test that 404 page is shown for nonexistent routes."""
        response = client.get('/nonexistent-page-xyz')
        assert response.status_code == 404
        assert b'404' in response.data
        assert b'Page Not Found' in response.data

    def test_404_page_has_home_link(self, client):
        """Test that 404 page has link to home."""
        response = client.get('/nonexistent-page')
        assert b'Go to Home' in response.data

    def test_404_page_has_register_link(self, client):
        """Test that 404 page has link to registration."""
        response = client.get('/nonexistent-page')
        assert b'/register' in response.data


class TestUserModel:
    """Tests for the User model."""

    def test_user_repr(self, app):
        """Test User string representation."""
        with app.app_context():
            from app.models.user import User
            user = User(username='testadmin')
            user.set_password('testpass123')
            assert '<User testadmin>' in repr(user)

    def test_user_set_password_hashes(self, app):
        """Test that set_password creates a hash, not plain text."""
        with app.app_context():
            from app.models.user import User
            user = User(username='hashtest')
            user.set_password('mypassword')
            assert user.password_hash != 'mypassword'
            assert len(user.password_hash) > 50  # Hashes are long

    def test_user_check_password_correct(self, app):
        """Test password verification with correct password."""
        with app.app_context():
            from app.models.user import User
            user = User(username='verifytest')
            user.set_password('correctpass')
            assert user.check_password('correctpass') is True

    def test_user_check_password_incorrect(self, app):
        """Test password verification with incorrect password."""
        with app.app_context():
            from app.models.user import User
            user = User(username='verifytest2')
            user.set_password('correctpass')
            assert user.check_password('wrongpass') is False

    def test_user_is_active_default(self, app):
        """Test that is_active defaults to True when persisted."""
        with app.app_context():
            from app.models.user import User
            from app.extensions import db
            user = User(username='activetest')
            user.set_password('password')
            db.session.add(user)
            db.session.commit()
            # Reload from database to check default was applied
            db.session.refresh(user)
            assert user.is_active is True


class TestAuthService:
    """Tests for the AuthService."""

    def test_create_user(self, app):
        """Test creating a user via AuthService."""
        with app.app_context():
            from app.services.auth_service import AuthService
            user = AuthService.create_user('newadmin', 'password123')
            assert user.id is not None
            assert user.username == 'newadmin'
            assert user.check_password('password123')

    def test_create_user_duplicate_raises(self, app):
        """Test that creating duplicate username raises error."""
        with app.app_context():
            from app.services.auth_service import AuthService, DuplicateUsernameError
            AuthService.create_user('duplicateuser', 'password123')
            import pytest
            with pytest.raises(DuplicateUsernameError):
                AuthService.create_user('duplicateuser', 'differentpass')

    def test_authenticate_success(self, app):
        """Test successful authentication."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('authuser', 'correctpassword')
            user = AuthService.authenticate('authuser', 'correctpassword')
            assert user is not None
            assert user.username == 'authuser'

    def test_authenticate_wrong_password(self, app):
        """Test authentication fails with wrong password."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('wrongpassuser', 'rightpassword')
            user = AuthService.authenticate('wrongpassuser', 'wrongpassword')
            assert user is None

    def test_authenticate_nonexistent_user(self, app):
        """Test authentication fails for nonexistent user."""
        with app.app_context():
            from app.services.auth_service import AuthService
            user = AuthService.authenticate('ghostuser', 'anypassword')
            assert user is None

    def test_authenticate_inactive_user(self, app):
        """Test authentication fails for inactive user."""
        with app.app_context():
            from app.services.auth_service import AuthService
            from app.extensions import db
            user = AuthService.create_user('inactiveuser', 'password123')
            user.is_active = False
            db.session.commit()
            result = AuthService.authenticate('inactiveuser', 'password123')
            assert result is None

    def test_get_user_by_id(self, app):
        """Test getting user by ID."""
        with app.app_context():
            from app.services.auth_service import AuthService
            created = AuthService.create_user('idlookup', 'password123')
            found = AuthService.get_user_by_id(created.id)
            assert found is not None
            assert found.username == 'idlookup'

    def test_get_user_by_username(self, app):
        """Test getting user by username."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('namelookup', 'password123')
            found = AuthService.get_user_by_username('namelookup')
            assert found is not None
            assert found.username == 'namelookup'


class TestFlaskLoginIntegration:
    """Tests for Flask-Login integration."""

    def test_login_manager_configured(self, app):
        """Test that login_manager is configured on the app."""
        from flask_login import LoginManager
        assert hasattr(app, 'login_manager')
        assert isinstance(app.login_manager, LoginManager)

    def test_user_loader_returns_user(self, app):
        """Test that user_loader returns user by ID."""
        with app.app_context():
            from app.services.auth_service import AuthService
            from app.extensions import login_manager
            user = AuthService.create_user('loadertest', 'password123')

            # Get the user_loader callback and test it
            loaded = login_manager._user_callback(str(user.id))
            assert loaded is not None
            assert loaded.username == 'loadertest'

    def test_user_loader_returns_none_for_invalid_id(self, app):
        """Test that user_loader returns None for nonexistent ID."""
        with app.app_context():
            from app.extensions import login_manager
            loaded = login_manager._user_callback('99999')
            assert loaded is None


class TestLoginForm:
    """Tests for the LoginForm."""

    def test_login_form_has_fields(self, app):
        """Test that LoginForm has required fields."""
        with app.app_context():
            from app.forms.login import LoginForm
            form = LoginForm()
            assert hasattr(form, 'username')
            assert hasattr(form, 'password')
            assert hasattr(form, 'submit')

    def test_login_form_validates_username_required(self, app):
        """Test that empty username fails validation."""
        with app.app_context():
            from app.forms.login import LoginForm
            form = LoginForm(data={'username': '', 'password': 'somepass'})
            assert not form.validate()
            assert 'username' in form.errors

    def test_login_form_validates_password_required(self, app):
        """Test that empty password fails validation."""
        with app.app_context():
            from app.forms.login import LoginForm
            form = LoginForm(data={'username': 'someuser', 'password': ''})
            assert not form.validate()
            assert 'password' in form.errors

    def test_login_form_accepts_valid_data(self, app):
        """Test that valid username and password passes validation."""
        with app.app_context():
            from app.forms.login import LoginForm
            form = LoginForm(data={'username': 'admin', 'password': 'password123'})
            assert form.validate()

    def test_login_form_has_remember_me(self, app):
        """Test that LoginForm has remember_me checkbox."""
        with app.app_context():
            from app.forms.login import LoginForm
            form = LoginForm()
            assert hasattr(form, 'remember_me')


class TestAuthBlueprint:
    """Tests for the auth blueprint login/logout routes."""

    def test_login_page_loads(self, client):
        """Test that login page loads successfully."""
        response = client.get('/auth/login')
        assert response.status_code == 200

    def test_login_page_has_form(self, client):
        """Test that login page contains a form."""
        response = client.get('/auth/login')
        assert b'<form' in response.data
        assert b'method="POST"' in response.data
        assert b'Username' in response.data
        assert b'Password' in response.data

    def test_login_success_redirects(self, app, client):
        """Test that successful login redirects to admin."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('logintest', 'password123')

        response = client.post('/auth/login', data={
            'username': 'logintest',
            'password': 'password123'
        }, follow_redirects=False)
        assert response.status_code == 302
        assert '/admin/attendees' in response.location

    def test_login_invalid_credentials(self, client):
        """Test that invalid credentials show error."""
        response = client.post('/auth/login', data={
            'username': 'nouser',
            'password': 'wrongpass'
        })
        assert response.status_code == 200
        assert b'Invalid username or password' in response.data

    def test_logout_redirects_to_home(self, app, client):
        """Test that logout redirects to home page."""
        # First log in
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('logouttest', 'password123')

        client.post('/auth/login', data={
            'username': 'logouttest',
            'password': 'password123'
        })

        # Then log out
        response = client.get('/auth/logout', follow_redirects=False)
        assert response.status_code == 302
        assert response.location == '/'

    def test_login_redirects_authenticated_user(self, app, client):
        """Test that authenticated user is redirected from login page."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('alreadyloggedin', 'password123')

        # Log in first
        client.post('/auth/login', data={
            'username': 'alreadyloggedin',
            'password': 'password123'
        })

        # Try to access login page again
        response = client.get('/auth/login', follow_redirects=False)
        assert response.status_code == 302
        assert '/admin/attendees' in response.location

    def test_login_redirects_to_next(self, app, client):
        """Test that login redirects to 'next' parameter."""
        with app.app_context():
            from app.services.auth_service import AuthService
            AuthService.create_user('nexttest', 'password123')

        response = client.post('/auth/login?next=/admin/attendees', data={
            'username': 'nexttest',
            'password': 'password123'
        }, follow_redirects=False)
        assert response.status_code == 302
        assert '/admin/attendees' in response.location


class TestProtectedRoutes:
    """Tests for protected routes and authentication flow."""

    def test_admin_attendees_redirects_unauthenticated(self, client):
        """Test that unauthenticated users are redirected from admin."""
        response = client.get('/admin/attendees', follow_redirects=False)
        assert response.status_code == 302
        assert '/auth/login' in response.location

    def test_admin_export_redirects_unauthenticated(self, client):
        """Test that unauthenticated users are redirected from CSV export."""
        response = client.get('/admin/export/csv', follow_redirects=False)
        assert response.status_code == 302
        assert '/auth/login' in response.location

    def test_navbar_shows_login_when_unauthenticated(self, client):
        """Test that navbar shows Login link when not authenticated."""
        response = client.get('/')
        assert b'>Login<' in response.data
        assert b'>Logout<' not in response.data

    def test_navbar_shows_logout_when_authenticated(self, authenticated_client):
        """Test that navbar shows Logout link when authenticated."""
        response = authenticated_client.get('/')
        assert b'>Logout<' in response.data
        assert b'>Login<' not in response.data

    def test_protected_route_sets_next_parameter(self, client):
        """Test that accessing protected route sets 'next' for redirect."""
        response = client.get('/admin/attendees', follow_redirects=True)
        # Should end up on login page with form
        assert b'<form' in response.data
        assert b'Username' in response.data

    def test_navbar_shows_admin_link_when_authenticated(self, authenticated_client):
        """Test that navbar shows Admin link when authenticated."""
        response = authenticated_client.get('/')
        assert b'>Admin<' in response.data


class TestSecurityHeaders:
    """Tests for OWASP security headers."""

    def test_x_content_type_options_header(self, client):
        """Test that X-Content-Type-Options header is set."""
        response = client.get('/')
        assert response.headers.get('X-Content-Type-Options') == 'nosniff'

    def test_x_frame_options_header(self, client):
        """Test that X-Frame-Options header is set."""
        response = client.get('/')
        assert response.headers.get('X-Frame-Options') == 'SAMEORIGIN'

    def test_x_xss_protection_header(self, client):
        """Test that X-XSS-Protection header is set."""
        response = client.get('/')
        assert response.headers.get('X-XSS-Protection') == '1; mode=block'

    def test_referrer_policy_header(self, client):
        """Test that Referrer-Policy header is set."""
        response = client.get('/')
        assert response.headers.get('Referrer-Policy') == 'strict-origin-when-cross-origin'

    def test_hsts_not_set_in_testing(self, client):
        """Test that HSTS is not set in testing mode."""
        response = client.get('/')
        # HSTS should not be present in testing mode
        assert response.headers.get('Strict-Transport-Security') is None


class TestCreateAdminCLI:
    """Tests for the flask create-admin CLI command."""

    def test_create_admin_command_works(self, runner):
        """Test that create-admin command creates a user."""
        result = runner.invoke(args=['create-admin', 'clitest'],
                              input='password123\npassword123\n')
        assert result.exit_code == 0
        assert "Admin user 'clitest' created successfully" in result.output

    def test_create_admin_command_duplicate_username(self, app, runner):
        """Test that duplicate username shows error."""
        # Create first user
        runner.invoke(args=['create-admin', 'duplicate'],
                     input='password123\npassword123\n')

        # Try to create second user with same name
        result = runner.invoke(args=['create-admin', 'duplicate'],
                              input='password456\npassword456\n')
        assert result.exit_code == 1
        assert "already exists" in result.output

    def test_create_admin_command_short_password(self, runner):
        """Test that short password shows error."""
        result = runner.invoke(args=['create-admin', 'shortpass'],
                              input='short\nshort\n')
        assert result.exit_code == 1
        assert "at least 8 characters" in result.output

    def test_create_admin_command_help(self, runner):
        """Test that --help shows usage information."""
        result = runner.invoke(args=['create-admin', '--help'])
        assert result.exit_code == 0
        assert 'USERNAME' in result.output
        assert 'password' in result.output.lower()

    def test_create_admin_command_creates_user_in_db(self, app, runner):
        """Test that created user can authenticate."""
        runner.invoke(args=['create-admin', 'dbtest'],
                     input='testpassword123\ntestpassword123\n')

        with app.app_context():
            from app.services.auth_service import AuthService
            user = AuthService.authenticate('dbtest', 'testpassword123')
            assert user is not None
            assert user.username == 'dbtest'
