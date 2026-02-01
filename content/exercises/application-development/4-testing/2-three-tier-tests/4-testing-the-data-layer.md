+++
title = "Testing the Data Layer"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Test the SubscriberRepository database operations with the test database"
weight = 4
+++

# Testing the Data Layer

## Goal

Test the SubscriberRepository database operations using an in-memory SQLite test database, verifying that CRUD operations, queries, and database constraints work correctly.

> **What you'll learn:**
>
> - How to test database operations with an in-memory test database
> - How to verify CRUD operations in the repository
> - How to test database-level constraints like unique email
> - How test isolation works with per-test database fixtures

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed the business layer testing exercise
> - ✓ Working `conftest.py` with the `app` fixture (in-memory SQLite)
> - ✓ `SubscriberRepository` with `find_by_email`, `exists`, `create`, and `get_all` methods
> - ✓ `Subscriber` model with `id`, `email` (unique), `name`, and `subscribed_at` columns

## Exercise Steps

### Overview

1. **Test Creating Subscribers**
2. **Test Querying Subscribers**
3. **Test Duplicate Detection**
4. **Test get_all**
5. **Run with Database Isolation**

### **Step 1:** Test Creating Subscribers

Data layer tests verify actual database operations: inserts, queries, and constraints. Unlike business layer tests that use mocks, these tests need a real database. The `app` fixture in `conftest.py` provides an in-memory SQLite database that is created before each test and destroyed after, ensuring complete isolation.

1. **Create** a new test file:

   > `tests/test_subscriber_repository.py`

   ```python
   """Tests for the SubscriberRepository data access layer."""

   from app.data.repositories.subscriber_repository import SubscriberRepository
   from app.data.models.subscriber import Subscriber


   class TestCreateSubscriber:
       """Test creating new subscribers."""

       def test_create_returns_subscriber(self, app):
           """create() returns a Subscriber instance."""
           repo = SubscriberRepository()
           subscriber = repo.create(email="test@example.com", name="Test User")
           assert isinstance(subscriber, Subscriber)

       def test_create_sets_fields(self, app):
           """Created subscriber has correct field values."""
           repo = SubscriberRepository()
           subscriber = repo.create(email="test@example.com", name="Test User")
           assert subscriber.email == "test@example.com"
           assert subscriber.name == "Test User"

       def test_create_sets_id(self, app):
           """Created subscriber gets an auto-generated ID."""
           repo = SubscriberRepository()
           subscriber = repo.create(email="test@example.com", name="Test User")
           assert subscriber.id is not None
           assert subscriber.id > 0

       def test_create_sets_timestamp(self, app):
           """Created subscriber gets an automatic timestamp."""
           repo = SubscriberRepository()
           subscriber = repo.create(email="test@example.com", name="Test User")
           assert subscriber.subscribed_at is not None
   ```

> ℹ **Concept Deep Dive**
>
> Data layer tests require a real database (in-memory SQLite via the `app` fixture). Unlike business layer tests, these verify actual database operations -- inserts, queries, constraints. The fixture creates all tables before each test and drops them after, ensuring isolation.
>
> Each test method receives the `app` fixture, which pushes an application context. Inside that context, the repository can call `db.session` methods without errors.
>
> ✓ **Quick check:** Four test methods covering return type, field values, auto-ID, and auto-timestamp

### **Step 2:** Test Querying Subscribers

The repository's `find_by_email` method is the primary query operation. Tests must cover both the "found" and "not found" cases, plus verify that email matching works case-insensitively.

1. **Add** the following test class to the same file:

   > `tests/test_subscriber_repository.py`

   ```python
   class TestFindSubscriber:
       """Test querying for subscribers."""

       def test_find_by_email_existing(self, app):
           """find_by_email() returns subscriber when email exists."""
           repo = SubscriberRepository()
           repo.create(email="test@example.com", name="Test User")
           found = repo.find_by_email("test@example.com")
           assert found is not None
           assert found.email == "test@example.com"

       def test_find_by_email_nonexistent(self, app):
           """find_by_email() returns None for unknown email."""
           repo = SubscriberRepository()
           found = repo.find_by_email("nobody@example.com")
           assert found is None

       def test_find_by_email_case_insensitive(self, app):
           """find_by_email() matches case-insensitively."""
           repo = SubscriberRepository()
           repo.create(email="test@example.com", name="Test User")
           found = repo.find_by_email("TEST@EXAMPLE.COM")
           assert found is not None
   ```

> ℹ **Concept Deep Dive**
>
> The case-insensitive test depends on the repository calling `.lower()` on the email parameter. If this test fails, it reveals that the repository does not normalize its input -- a valuable discovery. This is exactly why we test: to verify assumptions about behavior.
>
> Testing both "found" and "not found" paths ensures the query handles empty results gracefully by returning `None` instead of raising an exception.
>
> ✓ **Quick check:** Three test methods covering found, not-found, and case-insensitive matching

### **Step 3:** Test Duplicate Detection

The `exists` method and the database's unique constraint on the email column work together to prevent duplicate subscriptions. These tests verify both the application-level check and the database-level enforcement.

1. **Add** the following test class to the same file:

   > `tests/test_subscriber_repository.py`

   ```python
   class TestDuplicateDetection:
       """Test duplicate subscriber prevention."""

       def test_exists_false_for_new_email(self, app):
           """exists() returns False for unknown email."""
           repo = SubscriberRepository()
           assert repo.exists("new@example.com") is False

       def test_exists_true_for_existing_email(self, app):
           """exists() returns True after subscriber is created."""
           repo = SubscriberRepository()
           repo.create(email="test@example.com", name="Test User")
           assert repo.exists("test@example.com") is True

       def test_create_duplicate_raises_error(self, app):
           """Creating subscriber with existing email raises IntegrityError."""
           from sqlalchemy.exc import IntegrityError
           import pytest

           repo = SubscriberRepository()
           repo.create(email="test@example.com", name="Test User")
           with pytest.raises(IntegrityError):
               repo.create(email="test@example.com", name="Another User")
   ```

> ℹ **Concept Deep Dive**
>
> The `unique=True` constraint on the email column enforces uniqueness at the database level. SQLAlchemy raises `IntegrityError` when a duplicate insert is attempted. This is a defense-in-depth approach -- even if the business layer's duplicate check fails, the database prevents corruption.
>
> Testing the `IntegrityError` confirms that the model's unique constraint is correctly defined. Without this test, a missing constraint could go unnoticed until production data gets corrupted.
>
> ⚠ **Common Mistakes**
>
> - Importing `IntegrityError` from the wrong package (use `sqlalchemy.exc`, not `sqlite3`)
> - Forgetting that `pytest.raises` requires the error to actually be raised inside the `with` block
>
> ✓ **Quick check:** Three test methods covering exists-false, exists-true, and duplicate IntegrityError

### **Step 4:** Test get_all

The `get_all` method retrieves all subscribers, ordered with the newest first. These tests verify empty results, correct counts, and ordering.

1. **Add** the following test class to the same file:

   > `tests/test_subscriber_repository.py`

   ```python
   class TestGetAll:
       """Test retrieving all subscribers."""

       def test_empty_database_returns_empty_list(self, app):
           """get_all() returns empty list when no subscribers exist."""
           repo = SubscriberRepository()
           result = repo.get_all()
           assert result == []

       def test_returns_all_subscribers(self, app):
           """get_all() returns all created subscribers."""
           repo = SubscriberRepository()
           repo.create(email="first@example.com", name="First")
           repo.create(email="second@example.com", name="Second")
           result = repo.get_all()
           assert len(result) == 2

       def test_ordered_newest_first(self, app):
           """get_all() returns subscribers with newest first."""
           repo = SubscriberRepository()
           repo.create(email="first@example.com", name="First")
           repo.create(email="second@example.com", name="Second")
           result = repo.get_all()
           # Second subscriber was created last, should be first in list
           assert result[0].email == "second@example.com"
           assert result[1].email == "first@example.com"
   ```

> ℹ **Concept Deep Dive**
>
> The ordering test verifies that `get_all` returns subscribers with the newest first. This ordering is important for the admin dashboard where recent subscribers should appear at the top. If the repository does not implement ordering, this test will catch it.
>
> Testing with an empty database is equally important -- it confirms the method returns an empty list instead of `None` or raising an exception.
>
> ✓ **Quick check:** Three test methods covering empty list, correct count, and newest-first ordering

### **Step 5:** Run with Database Isolation

Each test starts with an empty database because the `app` fixture drops all tables after each test. This isolation means data created in one test never leaks into another.

1. **Run** the data layer tests:

   ```bash
   python -m pytest tests/test_subscriber_repository.py -v
   ```

2. **Verify** all tests pass with output similar to:

   ```text
   tests/test_subscriber_repository.py::TestCreateSubscriber::test_create_returns_subscriber PASSED
   tests/test_subscriber_repository.py::TestCreateSubscriber::test_create_sets_fields PASSED
   tests/test_subscriber_repository.py::TestCreateSubscriber::test_create_sets_id PASSED
   tests/test_subscriber_repository.py::TestCreateSubscriber::test_create_sets_timestamp PASSED
   tests/test_subscriber_repository.py::TestFindSubscriber::test_find_by_email_existing PASSED
   tests/test_subscriber_repository.py::TestFindSubscriber::test_find_by_email_nonexistent PASSED
   tests/test_subscriber_repository.py::TestFindSubscriber::test_find_by_email_case_insensitive PASSED
   tests/test_subscriber_repository.py::TestDuplicateDetection::test_exists_false_for_new_email PASSED
   tests/test_subscriber_repository.py::TestDuplicateDetection::test_exists_true_for_existing_email PASSED
   tests/test_subscriber_repository.py::TestDuplicateDetection::test_create_duplicate_raises_error PASSED
   tests/test_subscriber_repository.py::TestGetAll::test_empty_database_returns_empty_list PASSED
   tests/test_subscriber_repository.py::TestGetAll::test_returns_all_subscribers PASSED
   tests/test_subscriber_repository.py::TestGetAll::test_ordered_newest_first PASSED
   ```

3. **Prove isolation** by adding a test that checks the database starts empty:

   ```python
   def test_database_starts_empty(self, app):
       """Each test gets a fresh, empty database."""
       repo = SubscriberRepository()
       assert repo.get_all() == []
   ```

   This passes even after other tests created subscribers -- confirming that the `app` fixture provides complete isolation.

> ℹ **Concept Deep Dive**
>
> Database isolation is critical for reliable tests. Without it, tests that create data can cause unrelated tests to fail depending on execution order. The `app` fixture handles this by calling `db.create_all()` before yielding and `db.drop_all()` after, giving each test a completely fresh database.
>
> This approach is different from production databases where data persists. In-memory SQLite is ideal for testing because it is fast (no disk I/O) and automatically destroyed when the connection closes.
>
> ✓ **Quick check:** All 13 tests pass and no test depends on data from another test

## Common Issues

> **If you encounter problems:**
>
> **"OperationalError: no such table: subscribers":** The `app` fixture must call `db.create_all()` before yielding. Check your `conftest.py` to ensure tables are created inside the application context.
>
> **IntegrityError not raised for duplicate:** Check that the email column has `unique=True` in the Subscriber model definition.
>
> **Tests interfere with each other:** Ensure `conftest.py` fixture has proper cleanup with `db.drop_all()` after the yield statement.
>
> **"Working outside of application context":** Repository methods need app context -- always use the `app` fixture parameter in your test methods.
>
> **Still stuck?** Run a single test with `python -m pytest tests/test_subscriber_repository.py::TestCreateSubscriber::test_create_returns_subscriber -v` to isolate the failure.

## Summary

You've successfully tested the data layer which:

- ✓ Tested all repository CRUD operations (create, find, exists, get_all)
- ✓ Verified query behavior for both found and not-found cases
- ✓ Confirmed database-level duplicate prevention with IntegrityError
- ✓ Proved test isolation with fresh databases per test
- ✓ Validated automatic field generation (ID, timestamp)

> **Key takeaway:** Data layer tests verify that database operations work correctly. The in-memory database per test ensures isolation -- no test can pollute another. These tests catch migration errors, constraint issues, and query bugs that unit tests with mocks would miss. Together with business layer tests, you now have comprehensive coverage of the backend.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add tests for edge cases (very long emails, special characters in names)
> - Test database rollback behavior on errors
> - Add performance tests for large datasets
> - Research factory patterns (`factory_boy`) for test data creation

## Done! 🎉

You've tested the data layer's database operations. Together with business layer tests, you now have comprehensive coverage of the backend.
