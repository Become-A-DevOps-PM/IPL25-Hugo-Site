+++
title = "Testing Routes and Templates"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Write route tests that verify page content, HTTP status codes, and form elements"
weight = 2
+++

# Testing Routes and Templates

## Goal

Write route tests that verify HTTP status codes, page content, and form elements, building a comprehensive test suite for the presentation layer.

> **What you'll learn:**
>
> - How to test HTTP status codes for Flask routes
> - How to verify rendered page content and structure
> - How to check form elements and their configuration
> - Best practices for organizing tests into logical classes

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ A working `tests/conftest.py` with `app` and `client` fixtures
> - ✓ pytest installed and smoke tests passing
> - ✓ Flask application running with public routes (`/`, `/subscribe`, `/subscribe/confirm`)

## Exercise Steps

### Overview

1. **Test Page Loading (Status Codes)**
2. **Test Page Content**
3. **Test Form Display**
4. **Organize with Test Classes**
5. **Run and Verify**

### **Step 1:** Test Page Loading (Status Codes)

The most fundamental route test checks whether pages load at all. HTTP status codes tell us the result of a request: 200 means success, 404 means not found, and so on. Starting with status code tests gives us a quick safety net that catches broken routes, missing templates, and import errors.

1. **Navigate to** the `tests/` directory

2. **Create a new file** named `test_routes.py`

3. **Add the following code:**

   > `tests/test_routes.py`

   ```python
   """Tests for public routes and page content."""


   class TestPublicRoutes:
       """Test that public pages load correctly."""

       def test_index_returns_200(self, client):
           """Home page loads successfully."""
           response = client.get("/")
           assert response.status_code == 200

       def test_subscribe_returns_200(self, client):
           """Subscribe page loads successfully."""
           response = client.get("/subscribe")
           assert response.status_code == 200

       def test_unknown_route_returns_404(self, client):
           """Non-existent routes return 404."""
           response = client.get("/does-not-exist")
           assert response.status_code == 404
   ```

> ℹ **Concept Deep Dive**
>
> Test classes group related tests together. pytest discovers classes starting with `Test` and methods starting with `test_`. Fixtures like `client` are passed as method parameters, exactly as they are for standalone functions. Grouping tests by feature makes the output easier to scan when your test suite grows.
>
> ⚠ **Common Mistakes**
>
> - Forgetting the `self` parameter in class methods causes a `TypeError`
> - Class names must start with `Test` or pytest will not discover them
>
> ✓ **Quick check:** Run `python -m pytest tests/test_routes.py -v` and confirm all three tests pass

### **Step 2:** Test Page Content

Status codes confirm that a route responds, but they do not tell us what was rendered. Content tests verify that the templates produce the expected HTML. These tests catch issues like broken template inheritance, missing variables, and accidental content removal.

1. **Open** the file `tests/test_routes.py`

2. **Add** the following class after `TestPublicRoutes`:

   > `tests/test_routes.py`

   ```python
   class TestPageContent:
       """Test that pages contain expected content."""

       def test_index_contains_title(self, client):
           """Home page shows the application name."""
           response = client.get("/")
           html = response.data.decode()
           assert "News Flash" in html

       def test_subscribe_contains_heading(self, client):
           """Subscribe page has a heading."""
           response = client.get("/subscribe")
           html = response.data.decode()
           assert "Subscribe" in html

       def test_subscribe_contains_email_input(self, client):
           """Subscribe page has an email input field."""
           response = client.get("/subscribe")
           html = response.data.decode()
           assert 'name="email"' in html
   ```

> ℹ **Concept Deep Dive**
>
> The `response.data` attribute returns the response body as bytes. Calling `.decode()` converts it to a Python string so we can use standard string operations like `in` for assertions. We check for expected text, HTML attributes, and element names. These tests verify that the template renders correctly without needing a browser.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `.decode()` means comparing a string against bytes, which always fails
> - String matching is case-sensitive: `"subscribe"` does not match `"Subscribe"`
>
> ✓ **Quick check:** All three content tests should pass

### **Step 3:** Test Form Display

The subscription form is a critical part of the user interface. If the form tag is missing, the action URL is wrong, or the submit button disappears, users cannot subscribe. Form element tests catch structural problems in the HTML before real users encounter them.

1. **Open** the file `tests/test_routes.py`

2. **Add** the following class after `TestPageContent`:

   > `tests/test_routes.py`

   ```python
   class TestSubscribeForm:
       """Test the subscription form elements."""

       def test_form_has_action(self, client):
           """Form posts to the confirm endpoint."""
           response = client.get("/subscribe")
           html = response.data.decode()
           assert "<form" in html
           assert "/subscribe/confirm" in html

       def test_form_has_email_field(self, client):
           """Form includes email input."""
           response = client.get("/subscribe")
           html = response.data.decode()
           assert 'name="email"' in html

       def test_form_has_submit_button(self, client):
           """Form has a submit button."""
           response = client.get("/subscribe")
           html = response.data.decode()
           assert "type=\"submit\"" in html or "Submit" in html or "Subscribe" in html

       def test_form_method_is_post(self, client):
           """Form uses POST method."""
           response = client.get("/subscribe")
           html = response.data.decode()
           assert 'method="POST"' in html or 'method="post"' in html
   ```

> ℹ **Concept Deep Dive**
>
> Testing form elements verifies the HTML structure, not business logic. If someone accidentally removes the form tag or changes the action URL, these tests catch it before users encounter the problem. The `test_form_has_submit_button` test uses `or` to accept multiple valid implementations: a literal `type="submit"` attribute or button text containing "Submit" or "Subscribe".
>
> ⚠ **Common Mistakes**
>
> - HTML attribute quoting varies: templates may use single quotes, double quotes, or no quotes. Test for the pattern your templates actually produce.
> - Testing for exact HTML strings is brittle. Prefer testing for key attributes (`name=`, `method=`, `action=`) rather than entire element strings.
>
> ✓ **Quick check:** All four form tests should pass

### **Step 4:** Organize with Test Classes

With three test classes in place, the file is well organized. Each class groups a related set of assertions: status codes, page content, and form elements. This structure becomes increasingly valuable as the test suite grows. Run the tests with verbose output to see how pytest displays the class grouping.

1. **Verify** the complete file contains all three classes:
   - `TestPublicRoutes` (3 tests)
   - `TestPageContent` (3 tests)
   - `TestSubscribeForm` (4 tests)

2. **Run** the route tests with verbose output:

   ```bash
   python -m pytest tests/test_routes.py -v
   ```

3. **Examine** the output format:

   ```text
   tests/test_routes.py::TestPublicRoutes::test_index_returns_200 PASSED
   tests/test_routes.py::TestPublicRoutes::test_subscribe_returns_200 PASSED
   tests/test_routes.py::TestPublicRoutes::test_unknown_route_returns_404 PASSED
   tests/test_routes.py::TestPageContent::test_index_contains_title PASSED
   tests/test_routes.py::TestPageContent::test_subscribe_contains_heading PASSED
   tests/test_routes.py::TestPageContent::test_subscribe_contains_email_input PASSED
   tests/test_routes.py::TestSubscribeForm::test_form_has_action PASSED
   tests/test_routes.py::TestSubscribeForm::test_form_has_email_field PASSED
   tests/test_routes.py::TestSubscribeForm::test_form_has_submit_button PASSED
   tests/test_routes.py::TestSubscribeForm::test_form_method_is_post PASSED
   ```

> ℹ **Concept Deep Dive**
>
> The `::ClassName::method_name` format in the output makes it easy to identify which group a test belongs to. When a test fails, this hierarchical naming tells you immediately whether it is a routing problem, a content problem, or a form structure problem. pytest discovers both standalone functions and class methods, so you can mix both styles in the same project.
>
> ✓ **Quick check:** Output shows 10 tests organized under three class headings

### **Step 5:** Run and Verify

Run the complete test suite across all test files to see the total test count grow. Each new test file adds to the safety net protecting your application.

1. **Run** the full test suite:

   ```bash
   python -m pytest tests/ -v
   ```

2. **Count** the total tests. Your suite should now include tests from both `test_smoke.py` (or your initial test file) and the new `test_routes.py`.

3. **Confirm** that every test passes:

   ```bash
   python -m pytest tests/ -v --tb=short
   ```

   The `--tb=short` flag shows a shorter traceback for any failures, making it easier to diagnose problems.

> ✓ **Success indicators:**
>
> - All public routes return correct status codes
> - Page content assertions pass
> - Form elements are present and correctly configured
> - Test output is organized by class
> - Total test count includes both test files
>
> ✓ **Final verification checklist:**
>
> - ☐ `tests/test_routes.py` created with three test classes
> - ☐ `TestPublicRoutes` verifies status codes for `/`, `/subscribe`, and a 404 route
> - ☐ `TestPageContent` checks for page text and HTML elements
> - ☐ `TestSubscribeForm` validates form structure and configuration
> - ☐ All tests pass with `python -m pytest tests/ -v`

## Common Issues

> **If you encounter problems:**
>
> **"assert 'Subscribe' in html" fails:** Check the exact text in your template. String matching is case-sensitive, so `"subscribe"` will not match `"Subscribe"`.
>
> **response.data is bytes, not string:** Always call `.decode()` before performing string operations on response data.
>
> **Tests pass locally but HTML differs:** Templates may render differently with or without data. Test only structural elements that are always present, not dynamic content that depends on application state.
>
> **"fixture 'client' not found":** Ensure `conftest.py` exists in the `tests/` directory and defines the `client` fixture.
>
> **Still stuck?** Run a single test with `python -m pytest tests/test_routes.py::TestPublicRoutes::test_index_returns_200 -v` to isolate the problem.

## Summary

You've successfully built a comprehensive route and template test suite which:

- ✓ Tested HTTP status codes for all public routes
- ✓ Verified page content and structure through string assertions
- ✓ Checked form elements and their configuration
- ✓ Organized tests into logical classes for readable output

> **Key takeaway:** Route tests verify the presentation layer works correctly. They catch broken templates, missing pages, and form configuration errors. Using test classes groups related assertions so that when a test fails, the class name immediately tells you what category of problem to investigate.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Test response headers such as `Content-Type` and `Cache-Control`
> - Add parametrized tests to check multiple URLs in a single test function
> - Test that CSS and JavaScript files load with correct status codes
> - Research Selenium or Playwright for browser-level testing that executes JavaScript

## Done! 🎉

You've built a comprehensive set of route and template tests that verify the presentation layer works correctly.
