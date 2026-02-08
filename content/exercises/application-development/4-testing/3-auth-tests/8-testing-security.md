+++
title = "Testing Security"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Test security headers, CSRF protection, the admin CLI command, and custom error pages"
weight = 8
+++

# Testing Security

## Goal

Test security headers, CSRF protection, the admin CLI command, and custom error pages to verify that your application's defensive measures are in place and working correctly.

> **What you'll learn:**
>
> - How to test OWASP-recommended security headers on HTTP responses
> - How CSRF protection behaves differently in testing vs production
> - How to test Flask CLI commands with the test runner
> - How to verify custom error pages render with site styling

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Working `conftest.py` with `app`, `client`, `runner`, and `authenticated_client` fixtures
> - ✓ Security headers set in `@app.after_request` inside `create_app()`
> - ✓ CLI command `create-admin` registered with `app.cli.add_command()`
> - ✓ Custom error templates at `app/presentation/templates/errors/404.html` and `errors/500.html`

## Exercise Steps

### Overview

1. **Test Security Headers**
2. **Test CSRF Protection**
3. **Test CLI Command**
4. **Test Error Pages**
5. **Run Complete Test Suite**

### **Step 1:** Test Security Headers

Security headers instruct the browser to enable built-in protections against common attacks like MIME sniffing, clickjacking, and cross-site scripting. The `@app.after_request` hook in your application adds these headers to every response. These tests verify that each header is present and set to the correct value.

1. **Create** a new test file:

   > `tests/test_security.py`

   ```python
   """Tests for security features."""


   class TestSecurityHeaders:
       """Test OWASP-recommended security headers."""

       def test_content_type_options(self, client):
           """X-Content-Type-Options header prevents MIME sniffing."""
           response = client.get("/")
           assert response.headers.get("X-Content-Type-Options") == "nosniff"

       def test_frame_options(self, client):
           """X-Frame-Options header prevents clickjacking."""
           response = client.get("/")
           assert response.headers.get("X-Frame-Options") == "SAMEORIGIN"

       def test_xss_protection(self, client):
           """X-XSS-Protection header enables browser XSS filter."""
           response = client.get("/")
           assert "1" in response.headers.get("X-XSS-Protection", "")

       def test_referrer_policy(self, client):
           """Referrer-Policy header is set."""
           response = client.get("/")
           assert response.headers.get("Referrer-Policy") is not None

       def test_no_hsts_in_testing(self, client):
           """HSTS header is NOT present in testing mode."""
           response = client.get("/")
           assert response.headers.get("Strict-Transport-Security") is None
   ```

> ℹ **Concept Deep Dive**
>
> Testing mode should NOT have HSTS (HTTP Strict Transport Security) because tests run over HTTP, not HTTPS. If HSTS were present in development or testing, the browser would refuse to connect over plain HTTP, breaking local development entirely. The `test_no_hsts_in_testing` test verifies this safety check works correctly.
>
> Each test method makes a simple GET request and inspects the response headers. This pattern works because `@app.after_request` adds headers to every response regardless of the route. Testing against the home page (`/`) is sufficient since the headers are applied globally.
>
> ✓ **Quick check:** Five test methods covering X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Referrer-Policy, and HSTS absence

### **Step 2:** Test CSRF Protection

CSRF (Cross-Site Request Forgery) protection prevents malicious websites from submitting forms on behalf of your users. Flask-WTF provides this protection by requiring a hidden token in every form submission. These tests document how CSRF behaves differently in testing versus production.

1. **Add** the following test class to the same file:

   > `tests/test_security.py`

   ```python
   class TestCSRFProtection:
       """Test CSRF token handling.

       Note: TestingConfig has WTF_CSRF_ENABLED = False for convenience.
       These tests document the CSRF behavior and explain the trade-off.
       """

       def test_csrf_disabled_in_testing(self, app):
           """CSRF is disabled in test configuration for convenience."""
           assert app.config.get("WTF_CSRF_ENABLED") is False

       def test_form_post_works_without_csrf_in_testing(self, client):
           """Form POST succeeds without CSRF token in testing mode."""
           response = client.post("/subscribe/confirm", data={
               "email": "test@example.com",
               "name": "Test User",
           })
           # Should succeed (200 or 302), not 400 (CSRF rejection)
           assert response.status_code in [200, 302]
   ```

> ℹ **Concept Deep Dive**
>
> In production, `WTF_CSRF_ENABLED` is `True` (the default). Flask-WTF rejects any POST request that does not include a valid CSRF token, returning a 400 Bad Request response. In `TestingConfig`, CSRF is disabled (`WTF_CSRF_ENABLED = False`) to simplify test setup. Without this, every test that submits a form would need to first fetch the page, extract the CSRF token from the HTML, and include it in the POST data.
>
> This is a standard practice in Flask testing. CSRF protection is a browser-level defense -- it relies on the browser's same-origin policy to prevent cross-site requests. In automated tests, there is no browser and no cross-site risk, so disabling CSRF is both safe and practical.
>
> ⚠ **Common Mistakes**
>
> - Assuming CSRF is enabled in tests and wondering why form submissions succeed without tokens
> - Forgetting to set `WTF_CSRF_ENABLED = False` in `TestingConfig`, causing all form POST tests to fail with 400
>
> ✓ **Quick check:** Two test methods covering CSRF configuration and form submission behavior

### **Step 3:** Test CLI Command

The `create-admin` CLI command creates administrator accounts from the terminal. These tests verify that the command creates users successfully, handles duplicate usernames idempotently, and enforces the minimum password length.

1. **Add** the following test class to the same file:

   > `tests/test_security.py`

   ```python
   class TestCreateAdminCLI:
       """Test the create-admin CLI command."""

       def test_create_admin_success(self, runner):
           """CLI creates admin user successfully."""
           result = runner.invoke(args=["create-admin", "admin", "-p", "SecurePass1"])
           assert "created successfully" in result.output
           assert result.exit_code == 0

       def test_duplicate_username_idempotent(self, runner):
           """CLI handles existing username gracefully (idempotent)."""
           runner.invoke(args=["create-admin", "admin", "-p", "SecurePass1"])
           result = runner.invoke(args=["create-admin", "admin", "-p", "AnotherPass"])
           assert "already exists" in result.output
           assert result.exit_code == 0

       def test_short_password_rejected(self, runner):
           """CLI rejects password shorter than 8 characters."""
           result = runner.invoke(args=["create-admin", "admin", "-p", "short"])
           assert "8 characters" in result.output
           assert result.exit_code == 1
   ```

> ℹ **Concept Deep Dive**
>
> The `runner` fixture (from `conftest.py`) is Flask's CLI test runner. It wraps Flask's `app.test_cli_runner()` method, which creates a runner that can invoke CLI commands without actually running them in a shell. `runner.invoke()` captures both the output text and the exit code, making assertions straightforward.
>
> Exit codes follow Unix conventions: `0` means success, any non-zero value means failure. The `create-admin` command is designed to be **idempotent** — it exits with code 0 even when the username already exists. This is intentional: in production, the command runs at every container startup via `entrypoint.sh`. If the admin already exists, the command prints a message and exits successfully so the container continues to start. Only genuine errors (like a password that is too short) cause a non-zero exit code.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to register the command with `app.cli.add_command()` in `create_app()`, causing a "No such command" error
> - Testing password validation without checking the exit code -- the command might print a warning but still exit successfully
>
> ✓ **Quick check:** Three test methods covering successful creation, idempotent duplicate handling, and password validation

### **Step 4:** Test Error Pages

Custom error pages provide a consistent user experience when something goes wrong. Instead of Flask's default plain-text error messages, your application renders styled HTML pages that include site navigation. These tests verify that custom error handlers are registered and render correctly.

1. **Add** the following test class to the same file:

   > `tests/test_security.py`

   ```python
   class TestErrorPages:
       """Test custom error page rendering."""

       def test_404_returns_custom_page(self, client):
           """Non-existent route shows custom 404 page."""
           response = client.get("/this-page-does-not-exist")
           assert response.status_code == 404
           html = response.data.decode()
           assert "not found" in html.lower() or "404" in html

       def test_404_extends_base_template(self, client):
           """Custom 404 page uses the base template."""
           response = client.get("/this-page-does-not-exist")
           html = response.data.decode()
           # Should contain navigation from base.html
           assert "Home" in html or "News Flash" in html or "<nav" in html
   ```

> ℹ **Concept Deep Dive**
>
> The first test verifies that a request to a non-existent route returns HTTP 404 and that the response body contains recognizable error content (either the text "not found" or "404"). This confirms that Flask's `@app.errorhandler(404)` decorator is registered and pointing to the custom template at `templates/errors/404.html`.
>
> The second test goes further by checking that the error page extends the base template. A custom error page that does not inherit from `base.html` would show an unstyled page without navigation, leaving users stranded with no way to return to the site. The assertion checks for common elements from the base template like the site name, a "Home" link, or a `<nav>` element.
>
> ✓ **Quick check:** Two test methods covering error page content and base template inheritance

### **Step 5:** Run Complete Test Suite

With security tests in place, your application now has comprehensive test coverage across all layers. **Run** the entire test suite to verify everything works together.

1. **Run** all tests with abbreviated tracebacks:

   ```bash
   python -m pytest tests/ -v --tb=short
   ```

   The `--tb=short` flag shows abbreviated tracebacks for failures, producing cleaner output when running many tests at once.

2. **Review** the output. Your test suite should now include tests across multiple files covering setup, routes, business logic, data access, integration, authentication, and security.

3. **Verify** the success indicators:
   - All security headers are present on responses
   - HSTS is NOT present in testing mode
   - CLI creates users and rejects invalid input
   - Custom 404 page renders with site styling
   - Full test suite passes with zero failures
   - Total test count should be in the range of 40-60+ tests

> ℹ **Concept Deep Dive**
>
> A comprehensive test suite is more than a collection of individual tests — it is a living specification of your application's behavior. Each test file documents a different aspect: smoke tests prove the app starts, route tests verify user-facing pages, service tests cover the business layer, repository tests cover the data layer, integration tests verify end-to-end flows, auth tests verify authentication, and security tests confirm defensive measures.
>
> Running `python -m pytest tests/ -v` at any time gives you instant confidence that nothing is broken. This is the foundation for continuous integration, where every code push triggers the full suite automatically.
>
> ✓ **Quick check:** All tests pass with zero failures across all eight test files

## Common Issues

> **If you encounter problems:**
>
> **Security header tests fail:** Ensure the `@app.after_request` hook is registered inside `create_app()`. If headers are added outside the factory function, they will not be attached to responses created during testing.
>
> **CLI test shows "No such command":** Ensure `create_admin_command` is registered with `app.cli.add_command()` inside `create_app()`. The command must be registered before the app is returned.
>
> **runner fixture not found:** Add the `runner` fixture to `conftest.py`. It should return `app.test_cli_runner()` and depend on the `app` fixture.
>
> **404 test gets default Flask page:** Register error handlers with `@app.errorhandler(404)` inside `create_app()`. Without registered handlers, Flask returns its default plain-text error page which will not contain your custom content.
>
> **Still stuck?** Run a single test class with `python -m pytest tests/test_security.py::TestSecurityHeaders -v` to isolate the failure.

## Summary

You have successfully tested your application's security features:

- ✓ Tested OWASP security headers on all responses
- ✓ Documented CSRF behavior in test vs production configurations
- ✓ Verified CLI command functionality including validation and error handling
- ✓ Confirmed custom error pages render correctly with site styling
- ✓ Ran the complete test suite across all eight test files

> **Key takeaway:** Security testing verifies that protective measures are in place and working. Headers, CSRF, error pages, and CLI tools all contribute to a defense-in-depth strategy where multiple layers of protection guard against different attack vectors. Automated tests ensure these protections are not accidentally removed during future development. A single missing header or unregistered error handler could go unnoticed without tests -- but with this suite, any regression is caught immediately.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add tests for Content-Security-Policy headers
> - Test rate limiting on login attempts
> - Research automated security scanning with OWASP ZAP
> - Add tests that verify password hashing algorithm strength

## Done! 🎉

Congratulations! You have completed the entire testing suite. Your News Flash application now has comprehensive automated tests covering all three tiers, authentication, and security features. Run `python -m pytest tests/ -v` anytime to verify everything still works.
