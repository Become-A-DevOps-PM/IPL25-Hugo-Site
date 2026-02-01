+++
title = "Testing Protected Routes"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Test that admin routes require authentication and the login flow works correctly"
weight = 7
+++

# Testing Protected Routes

## Goal

Test the complete authentication flow -- unauthenticated redirects, login form validation, authenticated access to admin routes, and logout behavior -- ensuring that Flask-Login protection works correctly across the application.

> **What you'll learn:**
>
> - How to create a reusable `authenticated_client` fixture for testing protected routes
> - How to verify that unauthenticated users are redirected to the login page
> - How to test the login flow with valid and invalid credentials
> - How to confirm that logout clears the session and revokes access

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Working `conftest.py` with `app` and `client` fixtures
> - ✓ Flask-Login configured with `login_view = "auth.login"`
> - ✓ Admin routes decorated with `@login_required` (`/admin/subscribers`, `/admin/export/csv`)
> - ✓ Auth routes registered (`/auth/login`, `/auth/logout`)
> - ✓ `AuthService` with a `create_user` method

## Exercise Steps

### Overview

1. **Create authenticated_client Fixture**
2. **Test Unauthenticated Access**
3. **Test Login Flow**
4. **Test Authenticated Access**
5. **Test Logout**

### **Step 1:** Create authenticated_client Fixture

Testing protected routes requires a client that has already logged in. Instead of repeating the login steps in every test, a fixture encapsulates the entire login process and returns a pre-authenticated client. This keeps individual tests focused on what they are verifying rather than on setup boilerplate.

1. **Open** the shared test configuration file:

   > `tests/conftest.py`

2. **Add** the `authenticated_client` fixture:

   > `tests/conftest.py`

   ```python
   @pytest.fixture
   def authenticated_client(app, client):
       """Create a test client with an authenticated admin session.

       Creates an admin user and logs them in, returning a client
       that can access protected routes.
       """
       from app.business.services.auth_service import AuthService
       AuthService.create_user("testadmin", "testpassword123")

       client.post("/auth/login", data={
           "username": "testadmin",
           "password": "testpassword123",
       })
       return client
   ```

3. **Add** a `runner` fixture if not already present:

   > `tests/conftest.py`

   ```python
   @pytest.fixture
   def runner(app):
       """Create CLI test runner."""
       return app.test_cli_runner()
   ```

> ℹ **Concept Deep Dive**
>
> The `authenticated_client` fixture simulates a complete login by POSTing credentials to the login endpoint. Flask's test client maintains cookies between requests, so subsequent requests from this client will have the session cookie -- just like a real browser. Because `conftest.py` fixtures are available to all test files in the same directory, any test module can use `authenticated_client` without importing anything.
>
> ✓ **Quick check:** The `authenticated_client` fixture is defined in `conftest.py` with `app` and `client` as dependencies

### **Step 2:** Test Unauthenticated Access

Before testing what authenticated users can do, verify that unauthenticated users cannot access protected routes. Flask-Login should redirect them to the login page with a `?next` parameter so the application can return them to their original destination after login.

1. **Create** a new test file:

   > `tests/test_protected_routes.py`

   ```python
   """Tests for protected routes and authentication flow."""


   class TestUnauthenticatedAccess:
       """Test that protected routes redirect unauthenticated users."""

       def test_admin_subscribers_redirects(self, client):
           """Unauthenticated access to admin redirects to login."""
           response = client.get("/admin/subscribers")
           assert response.status_code == 302
           assert "/auth/login" in response.headers["Location"]

       def test_admin_csv_redirects(self, client):
           """Unauthenticated access to CSV export redirects to login."""
           response = client.get("/admin/export/csv")
           assert response.status_code == 302
           assert "/auth/login" in response.headers["Location"]

       def test_redirect_includes_next(self, client):
           """Redirect URL includes ?next parameter."""
           response = client.get("/admin/subscribers")
           assert "next" in response.headers["Location"]
   ```

> ℹ **Concept Deep Dive**
>
> When Flask-Login's `@login_required` decorator intercepts an unauthenticated request, it issues a 302 redirect to the configured `login_view`. The redirect URL includes a `?next` query parameter containing the originally requested path. This mechanism allows the login handler to redirect users back to where they were trying to go after successful authentication.
>
> These tests use the regular `client` fixture (not `authenticated_client`) because the goal is to verify behavior for users who have not logged in.
>
> ✓ **Quick check:** Three test methods covering admin redirect, CSV redirect, and the `?next` parameter

### **Step 3:** Test Login Flow

The login flow has multiple paths: the form must render, valid credentials must grant access, and invalid credentials must show an error. Testing each path confirms that the authentication system handles all scenarios correctly.

1. **Add** the following class to the same file:

   > `tests/test_protected_routes.py`

   ```python
   class TestLoginFlow:
       """Test the login process."""

       def test_login_page_loads(self, client):
           """Login page renders successfully."""
           response = client.get("/auth/login")
           assert response.status_code == 200
           html = response.data.decode()
           assert "login" in html.lower() or "username" in html.lower()

       def test_login_page_has_form(self, client):
           """Login page contains a form."""
           response = client.get("/auth/login")
           html = response.data.decode()
           assert "<form" in html
           assert 'name="username"' in html
           assert 'name="password"' in html

       def test_valid_login_redirects(self, app, client):
           """Valid credentials redirect to admin."""
           from app.business.services.auth_service import AuthService
           AuthService.create_user("admin", "password123")
           response = client.post("/auth/login", data={
               "username": "admin",
               "password": "password123",
           })
           assert response.status_code == 302

       def test_invalid_login_stays_on_page(self, client):
           """Invalid credentials stay on login page."""
           response = client.post("/auth/login", data={
               "username": "wrong",
               "password": "wrong",
           })
           assert response.status_code == 200
           html = response.data.decode()
           assert "invalid" in html.lower() or "error" in html.lower()
   ```

> ℹ **Concept Deep Dive**
>
> The `test_valid_login_redirects` test creates a user within the test itself using `AuthService.create_user`. This is necessary because each test starts with an empty database. After posting valid credentials, the server responds with a 302 redirect -- typically to the admin dashboard or the `?next` URL. The `test_invalid_login_stays_on_page` test verifies that failed login attempts re-render the login page (200) with an error message rather than redirecting.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to create a user before testing valid login -- there are no users in the test database by default
> - Expecting a 200 for successful login -- Flask convention is to redirect (302) after a successful POST
>
> ✓ **Quick check:** Four test methods covering page load, form structure, valid login, and invalid login

### **Step 4:** Test Authenticated Access

With the `authenticated_client` fixture handling the login process, these tests focus entirely on verifying that authenticated users can access protected admin routes and receive the expected content.

1. **Add** the following class to the same file:

   > `tests/test_protected_routes.py`

   ```python
   class TestAuthenticatedAccess:
       """Test that authenticated users can access protected routes."""

       def test_admin_subscribers_accessible(self, authenticated_client):
           """Authenticated user can view subscribers."""
           response = authenticated_client.get("/admin/subscribers")
           assert response.status_code == 200

       def test_admin_subscribers_content(self, authenticated_client):
           """Subscribers page has expected content."""
           response = authenticated_client.get("/admin/subscribers")
           html = response.data.decode()
           assert "subscriber" in html.lower()

       def test_csv_export_accessible(self, authenticated_client):
           """Authenticated user can export CSV."""
           response = authenticated_client.get("/admin/export/csv")
           assert response.status_code == 200
           assert response.content_type == "text/csv; charset=utf-8" or "text/csv" in response.content_type
   ```

> ℹ **Concept Deep Dive**
>
> Notice how each test method receives `authenticated_client` instead of `client`. The fixture creates a fresh user and performs the login before each test method runs. This means every test starts with a clean, authenticated session -- no state leaks between tests. The CSV export test checks both the status code and the `Content-Type` header to ensure the response is actually a CSV file, not an HTML error page.
>
> ✓ **Quick check:** Three test methods covering subscriber page access, page content, and CSV export

### **Step 5:** Test Logout

Logout must clear the session so that previously authenticated clients can no longer access protected routes. These tests verify both the logout response and the post-logout access restriction.

1. **Add** the following class to the same file:

   > `tests/test_protected_routes.py`

   ```python
   class TestLogout:
       """Test the logout process."""

       def test_logout_redirects(self, authenticated_client):
           """Logout redirects to home page."""
           response = authenticated_client.get("/auth/logout")
           assert response.status_code == 302

       def test_admin_inaccessible_after_logout(self, authenticated_client):
           """After logout, admin routes redirect to login again."""
           authenticated_client.get("/auth/logout")
           response = authenticated_client.get("/admin/subscribers")
           assert response.status_code == 302
           assert "/auth/login" in response.headers["Location"]
   ```

2. **Run** the protected routes tests:

   ```bash
   python -m pytest tests/test_protected_routes.py -v
   ```

3. **Verify** the output shows all tests passing:

   ```text
   tests/test_protected_routes.py::TestUnauthenticatedAccess::test_admin_subscribers_redirects PASSED
   tests/test_protected_routes.py::TestUnauthenticatedAccess::test_admin_csv_redirects PASSED
   tests/test_protected_routes.py::TestUnauthenticatedAccess::test_redirect_includes_next PASSED
   tests/test_protected_routes.py::TestLoginFlow::test_login_page_loads PASSED
   tests/test_protected_routes.py::TestLoginFlow::test_login_page_has_form PASSED
   tests/test_protected_routes.py::TestLoginFlow::test_valid_login_redirects PASSED
   tests/test_protected_routes.py::TestLoginFlow::test_invalid_login_stays_on_page PASSED
   tests/test_protected_routes.py::TestAuthenticatedAccess::test_admin_subscribers_accessible PASSED
   tests/test_protected_routes.py::TestAuthenticatedAccess::test_admin_subscribers_content PASSED
   tests/test_protected_routes.py::TestAuthenticatedAccess::test_csv_export_accessible PASSED
   tests/test_protected_routes.py::TestLogout::test_logout_redirects PASSED
   tests/test_protected_routes.py::TestLogout::test_admin_inaccessible_after_logout PASSED
   ```

> ℹ **Concept Deep Dive**
>
> The `test_admin_inaccessible_after_logout` test is particularly important. It uses the same `authenticated_client` that was logged in, calls logout, then tries to access a protected route. The 302 redirect to `/auth/login` confirms that the session cookie was invalidated. Without this test, a logout handler that forgets to call `logout_user()` could silently leave sessions active.
>
> ✓ **Quick check:** All 12 tests pass -- unauthenticated redirects, login form, valid/invalid login, authenticated access, and logout

## Common Issues

> **If you encounter problems:**
>
> **"authenticated_client fixture not found":** The fixture must be defined in `conftest.py`, not in the test file. pytest only auto-discovers fixtures from `conftest.py` files.
>
> **Login always fails in tests:** Ensure `TestingConfig` has `WTF_CSRF_ENABLED = False`. CSRF protection blocks form submissions from the test client because no CSRF token is included in the POST data.
>
> **302 instead of 200 on admin pages:** You are using the regular `client` fixture instead of `authenticated_client`. Protected routes redirect unauthenticated users.
>
> **"Location" header missing:** Check that Flask-Login's `login_manager.login_view` is set to `"auth.login"` in the application factory. Without this setting, Flask-Login returns a 401 instead of redirecting.
>
> **Still stuck?** Run a single test with `python -m pytest tests/test_protected_routes.py::TestLoginFlow::test_valid_login_redirects -v` to isolate the failure.

## Summary

You've successfully tested the complete authentication flow which:

- ✓ Created `authenticated_client` fixture for testing protected routes
- ✓ Verified unauthenticated users are redirected to login with `?next` parameter
- ✓ Tested the complete login flow (form rendering, valid/invalid credentials)
- ✓ Confirmed authenticated users can access admin features
- ✓ Verified logout clears the session and revokes access

> **Key takeaway:** Testing protected routes requires simulating the full login flow. The `authenticated_client` fixture encapsulates this, making individual tests clean and focused. By testing from both sides -- unauthenticated and authenticated -- you ensure that Flask-Login's `@login_required` decorator works correctly and that the login/logout cycle behaves as expected.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Test the `?next` redirect after successful login (login should return to the original page)
> - Add tests for remember-me functionality
> - Test session expiry behavior
> - Research mocking Flask-Login for unit tests that skip the full login flow

## Done! 🎉

You've tested the complete authentication flow -- from unauthenticated redirects through login to protected access and logout.
