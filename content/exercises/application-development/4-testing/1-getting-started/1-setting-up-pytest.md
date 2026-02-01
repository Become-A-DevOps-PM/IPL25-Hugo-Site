+++
title = "Setting Up pytest"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Set up pytest with fixtures for the News Flash application and write your first tests"
weight = 1
+++

# Setting Up pytest

## Goal

Set up pytest with fixtures for the News Flash application and write your first tests to establish a reliable testing foundation.

> **What you'll learn:**
>
> - How to configure pytest for a Flask application
> - When to use fixtures for reusable test setup
> - Best practices for isolating tests with in-memory databases
> - Why the red-green testing cycle matters for development confidence

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ A working News Flash application with `create_app()` factory
> - ✓ Configuration classes including `TestingConfig` in `app/config.py`
> - ✓ Virtual environment activated with Flask installed

## Exercise Steps

### Overview

1. **Install pytest and Create Test Structure**
2. **Write Your First Test**
3. **Run pytest and Understand Output**
4. **Add a Failing Test to Understand Red-Green Flow**
5. **Verify Your Setup**

### **Step 1:** Install pytest and Create Test Structure

Automated testing is one of the most valuable practices in software development. Tests catch bugs before users encounter them, document expected behavior in executable form, and enable confident refactoring. Without tests, every change to your codebase carries risk. With tests, you can modify code knowing that any regression will be caught immediately.

In this step you will install pytest, create the test directory structure, and build reusable fixtures that every future test will depend on.

1. **Add** pytest to your project dependencies:

   > `requirements.txt`

   ```text
   pytest==8.3.4
   ```

2. **Install** the updated dependencies:

   ```bash
   pip install -r requirements.txt
   ```

3. **Create** the test directory structure at your project root (sibling to `app/`):

   ```bash
   mkdir tests
   ```

4. **Create** the package marker file:

   > `tests/__init__.py`

   ```python
   ```

5. **Create** the shared fixtures file:

   > `tests/conftest.py`

   ```python
   """Pytest fixtures for the News Flash application tests."""

   import pytest
   from app import create_app, db as _db


   @pytest.fixture
   def app():
       """Create application instance for testing.

       Uses in-memory SQLite database that is created fresh for each test.
       """
       app = create_app("testing")

       with app.app_context():
           _db.create_all()
           yield app
           _db.session.remove()
           _db.drop_all()


   @pytest.fixture
   def client(app):
       """Create test client for making HTTP requests.

       The test client simulates a browser without running a real server.
       """
       return app.test_client()
   ```

> ℹ **Concept Deep Dive**
>
> Fixtures are reusable test setup functions. The `@pytest.fixture` decorator marks a function as a fixture that pytest can inject into any test that requests it by name.
>
> The `app` fixture creates a fresh application instance configured for testing. It opens an application context, creates all database tables, then `yield`s the app to the test. After the test completes, cleanup code runs: the session is removed and tables are dropped. This ensures every test starts with a completely clean state.
>
> The `client` fixture depends on `app` — notice `app` appears as its parameter. pytest resolves this dependency chain automatically, creating the app first, then passing it to create the test client.
>
> ✓ **Quick check:** `tests/` directory exists with `__init__.py` and `conftest.py`

> ℹ **Concept Deep Dive**
>
> `create_app("testing")` loads `TestingConfig` which uses `sqlite:///:memory:` — a database that exists only in RAM and is destroyed when the connection closes. This means every test starts with a clean, empty database. No leftover data from previous tests can cause unexpected failures, and no test database files accumulate on disk.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `__init__.py` in `tests/` can cause import issues
> - Placing `conftest.py` outside `tests/` means fixtures won't be discovered
> - Using a file-based database instead of `:memory:` leaves test artifacts behind

### **Step 2:** Write Your First Test

Now that the test infrastructure is in place, write a small set of smoke tests that verify the application starts correctly and responds to requests. Smoke tests are the first line of defense — they confirm that the basic wiring of your application is functional before you test any specific feature.

1. **Create** a new test file:

   > `tests/test_smoke.py`

   ```python
   """Smoke tests to verify basic application setup."""


   def test_app_exists(app):
       """Verify the application instance is created."""
       assert app is not None


   def test_app_is_testing(app):
       """Verify the app is using the testing configuration."""
       assert app.config["TESTING"] is True


   def test_index_page_loads(client):
       """Verify the home page returns HTTP 200."""
       response = client.get("/")
       assert response.status_code == 200
   ```

> ℹ **Concept Deep Dive**
>
> pytest discovers test files automatically by looking for files that start with `test_` and functions that start with `test_`. When a test function has a parameter name that matches a fixture (like `app` or `client`), pytest automatically injects the fixture value. No manual setup or teardown code is needed in the test itself.
>
> The `assert` statement is all you need for verification. Unlike other test frameworks that require special assertion methods (`assertEqual`, `assertTrue`), pytest introspects plain `assert` statements and provides detailed failure messages showing exactly what went wrong.
>
> ⚠ **Common Mistakes**
>
> - Naming test files without the `test_` prefix means pytest will not discover them
> - Misspelling a fixture name in the function parameter causes a "fixture not found" error
> - Forgetting to use `assert` means the test always passes regardless of the result
>
> ✓ **Quick check:** Three test functions created in `tests/test_smoke.py`

### **Step 3:** Run pytest and Understand Output

Running your tests and understanding the output is essential for an efficient development workflow. The pytest output tells you exactly what passed, what failed, and why.

1. **Run** the test suite from your project root:

   ```bash
   python -m pytest tests/ -v
   ```

2. **Read** the output carefully. With the `-v` (verbose) flag, pytest shows each test name and its result:

   ```text
   tests/test_smoke.py::test_app_exists PASSED
   tests/test_smoke.py::test_app_is_testing PASSED
   tests/test_smoke.py::test_index_page_loads PASSED

   ========================= 3 passed in 0.15s =========================
   ```

3. **Understand** the result indicators:
   - `.` or `PASSED` — test passed
   - `F` or `FAILED` — test assertion failed
   - `E` or `ERROR` — error during test setup or teardown
   - Exit code `0` — all tests passed
   - Exit code `1` — one or more tests failed

> ℹ **Concept Deep Dive**
>
> Running pytest with `python -m pytest` instead of just `pytest` ensures that the current directory is added to the Python path. This prevents `ModuleNotFoundError` when importing your application package.
>
> The `-v` flag switches from compact output (dots) to verbose output (full test names and results). During development, verbose output helps you see exactly which tests are running. In CI/CD pipelines, compact output keeps logs concise.
>
> ✓ **Quick check:** All three tests show `PASSED` in the output

### **Step 4:** Add a Failing Test to Understand Red-Green Flow

Understanding how tests fail is just as important as making them pass. The red-green cycle is fundamental to test-driven development: write a failing test (red), make it pass (green), then improve the code (refactor). This step walks you through a deliberate failure so you can recognize what pytest failure output looks like.

1. **Add** a deliberately failing test to `tests/test_smoke.py`:

   ```python
   def test_intentional_failure(client):
       """This test will fail - that is the point."""
       response = client.get("/nonexistent-page")
       assert response.status_code == 200  # Will be 404!
   ```

2. **Run** the tests:

   ```bash
   python -m pytest tests/ -v
   ```

3. **Observe** the failure output. pytest shows the exact line that failed, the expected value, and the actual value. This detailed output makes diagnosing problems straightforward.

4. **Fix** the test by updating the assertion to match the correct behavior:

   ```python
   def test_nonexistent_page_returns_404(client):
       """Verify unknown routes return 404."""
       response = client.get("/nonexistent-page")
       assert response.status_code == 404
   ```

5. **Run** the tests again:

   ```bash
   python -m pytest tests/ -v
   ```

   All tests should now pass. This is the red-green cycle in action: you wrote a failing test, observed the failure, and corrected it to match the actual behavior.

> ℹ **Concept Deep Dive**
>
> The red-green cycle builds confidence in your test suite. When you see a test fail with a clear error message, you know the test is actually checking something meaningful. A test that never fails provides no value — it might be testing nothing at all.
>
> In practice, you will use this cycle when building new features: write a test for the behavior you want (it fails because the feature does not exist yet), implement the feature (the test passes), then clean up the code knowing the test protects you from breaking it.
>
> ✓ **Quick check:** All tests pass after fixing the assertion

### **Step 5:** Verify Your Setup

Run the complete test suite one final time to confirm everything is working together.

1. **Run** the full suite:

   ```bash
   python -m pytest tests/ -v
   ```

2. **Confirm** the following success indicators:
   - All tests pass (3 or 4 depending on whether you kept the 404 test)
   - Each test gets a fresh database (in-memory SQLite)
   - No test data leaks between tests
   - pytest output is clean and readable

> ✓ **Final verification checklist:**
>
> - [ ] pytest installed and listed in `requirements.txt`
> - [ ] `tests/` directory with `__init__.py` and `conftest.py`
> - [ ] `app` fixture creates testing app with in-memory database
> - [ ] `client` fixture provides test HTTP client
> - [ ] Smoke tests verify app creation and page loading
> - [ ] `python -m pytest tests/ -v` runs without errors

## Common Issues

> **If you encounter problems:**
>
> **ModuleNotFoundError: No module named 'app':** Run pytest from the project root directory where `app/` is located. Use `python -m pytest` instead of `pytest` to ensure the path is set correctly.
>
> **fixture 'app' not found:** Ensure `conftest.py` is inside the `tests/` directory and that the fixture function is decorated with `@pytest.fixture`.
>
> **Database errors in tests:** Verify that `TestingConfig` uses `sqlite:///:memory:` as the database URI. Check that `_db.create_all()` is called inside the application context.
>
> **Tests pass but with warnings:** Warnings about SQLAlchemy or deprecation are usually safe to ignore at this stage. They do not affect test correctness.
>
> **Still stuck?** Double-check the directory structure: `tests/` should be a sibling of `app/`, not inside it.

## Summary

You have successfully set up a testing foundation for the News Flash application:

- ✓ Installed pytest and created a test directory structure
- ✓ Built fixtures for application and test client with automatic cleanup
- ✓ Wrote smoke tests for basic application functionality
- ✓ Learned the red-green testing cycle through deliberate failure

> **Key takeaway:** Fixtures provide reusable test setup that keeps individual tests clean and focused. Each test gets a fresh application and database, ensuring tests are independent and repeatable. pytest's automatic fixture injection means you declare what you need as function parameters and the framework handles the rest.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Explore pytest markers (`@pytest.mark.slow`) for categorizing tests
> - Learn about `@pytest.mark.parametrize` for testing multiple inputs with a single test function
> - Research coverage reporting with `pytest-cov` to see which code paths your tests exercise
> - Try running tests in parallel with `pytest-xdist` to speed up large test suites

## Done!

You have set up a testing foundation for the News Flash application with reusable fixtures and your first passing tests.
