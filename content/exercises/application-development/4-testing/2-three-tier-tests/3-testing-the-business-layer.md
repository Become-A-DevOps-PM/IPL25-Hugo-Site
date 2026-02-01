+++
title = "Testing the Business Layer"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Test the SubscriptionService validation and normalization methods"
weight = 3
+++

# Testing the Business Layer

## Goal

Write focused unit tests for the SubscriptionService to verify that validation and normalization logic works correctly, independent of HTTP requests and database operations.

> **What you'll learn:**
>
> - How to test business layer methods in isolation
> - How to structure test classes around behavior
> - How to test both success and error paths
> - How to use `pytest.raises` for exception testing

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ pytest installed and configured (`python -m pytest` runs without errors)
> - ✓ `conftest.py` with `app` and `client` fixtures
> - ✓ `SubscriptionService` implemented in `app/business/services/subscription_service.py`
> - ✓ Understanding of Python classes and assert statements

## Exercise Steps

### Overview

1. **Test Email Validation**
2. **Test Email Normalization**
3. **Test Name Normalization**
4. **Test process_subscription**
5. **Run and Analyze**

### **Step 1:** Test Email Validation

The business layer's `validate_email` method is pure logic -- it takes a string and returns a tuple indicating whether the email is valid and an error message if not. Testing pure logic is straightforward because there are no side effects, no database calls, and no HTTP context to set up. We test both valid inputs (to confirm they pass) and invalid inputs (to confirm they are rejected with appropriate messages).

1. **Create a new file** named `test_subscription_service.py` in the `tests/` directory

2. **Add the following code:**

   > `tests/test_subscription_service.py`

   ```python
   """Tests for the SubscriptionService business logic."""

   import pytest

   from app.business.services.subscription_service import SubscriptionService


   class TestEmailValidation:
       """Test email validation rules."""

       def test_valid_email(self, app):
           """Standard email format is accepted."""
           service = SubscriptionService()
           is_valid, error = service.validate_email("user@example.com")
           assert is_valid is True
           assert error == ""

       def test_valid_email_with_dots(self, app):
           """Email with dots in local part is accepted."""
           service = SubscriptionService()
           is_valid, error = service.validate_email("first.last@example.com")
           assert is_valid is True

       def test_valid_email_with_plus(self, app):
           """Email with plus sign is accepted."""
           service = SubscriptionService()
           is_valid, error = service.validate_email("user+tag@example.com")
           assert is_valid is True

       def test_empty_email(self, app):
           """Empty string is rejected."""
           service = SubscriptionService()
           is_valid, error = service.validate_email("")
           assert is_valid is False
           assert "required" in error.lower()

       def test_whitespace_only_email(self, app):
           """Whitespace-only string is rejected."""
           service = SubscriptionService()
           is_valid, error = service.validate_email("   ")
           assert is_valid is False

       def test_no_at_sign(self, app):
           """Email without @ is rejected."""
           service = SubscriptionService()
           is_valid, error = service.validate_email("userexample.com")
           assert is_valid is False
           assert "invalid" in error.lower()

       def test_no_tld(self, app):
           """Email without TLD is rejected."""
           service = SubscriptionService()
           is_valid, error = service.validate_email("user@example")
           assert is_valid is False

       def test_double_at(self, app):
           """Email with double @ is rejected."""
           service = SubscriptionService()
           is_valid, error = service.validate_email("user@@example.com")
           assert is_valid is False
   ```

> ℹ **Concept Deep Dive**
>
> These tests exercise the business layer without touching HTTP or databases. The `validate_email()` method is pure logic -- it takes a string and returns a result. This makes tests fast and reliable because there is no I/O to slow things down or cause flaky failures.
>
> Each test method has a descriptive docstring that explains what it verifies. When a test fails, pytest displays this docstring, making it immediately clear what behavior broke.
>
> We use the `app` fixture even though `validate_email` is pure logic because the `SubscriptionService.__init__` creates a `SubscriberRepository` that needs Flask's application context. The fixture provides this context so the service can be instantiated.
>
> ⚠ **Common Mistakes**
>
> - Creating `SubscriptionService()` outside the `app` fixture scope causes "Working outside of application context" errors
> - Testing only valid inputs and skipping invalid cases -- both paths matter
> - Using `assert is_valid == True` instead of `assert is_valid is True` (works but less Pythonic)
>
> ✓ **Quick check:** File created at `tests/test_subscription_service.py` with 8 test methods

### **Step 2:** Test Email Normalization

The `normalize_email` method ensures consistency in stored email addresses by converting to lowercase and stripping whitespace. These tests verify that normalization produces predictable output regardless of how users format their input.

1. **Open** the file `tests/test_subscription_service.py`

2. **Add** the following test class after `TestEmailValidation`:

   > `tests/test_subscription_service.py`

   ```python
   class TestEmailNormalization:
       """Test email normalization."""

       def test_lowercase_conversion(self, app):
           """Uppercase email is converted to lowercase."""
           service = SubscriptionService()
           assert service.normalize_email("USER@EXAMPLE.COM") == "user@example.com"

       def test_whitespace_stripped(self, app):
           """Leading and trailing whitespace is removed."""
           service = SubscriptionService()
           assert service.normalize_email("  user@example.com  ") == "user@example.com"

       def test_already_normalized(self, app):
           """Already-normalized email passes through unchanged."""
           service = SubscriptionService()
           assert service.normalize_email("user@example.com") == "user@example.com"
   ```

> ℹ **Concept Deep Dive**
>
> Normalization tests verify idempotency -- applying the function once should produce the same result as applying it twice. The `test_already_normalized` test confirms this property. If `normalize_email("user@example.com")` returns anything other than `"user@example.com"`, something is wrong.
>
> ✓ **Quick check:** Three normalization tests covering uppercase, whitespace, and already-clean input

### **Step 3:** Test Name Normalization

The `normalize_name` method handles edge cases in user-provided names: trimming whitespace and providing a default value when the name is empty or missing. This protects downstream code from dealing with `None` or blank strings.

1. **Open** the file `tests/test_subscription_service.py`

2. **Add** the following test class after `TestEmailNormalization`:

   > `tests/test_subscription_service.py`

   ```python
   class TestNameNormalization:
       """Test name normalization."""

       def test_normal_name_trimmed(self, app):
           """Whitespace around name is stripped."""
           service = SubscriptionService()
           assert service.normalize_name("  John  ") == "John"

       def test_empty_name_defaults(self, app):
           """Empty string defaults to 'Subscriber'."""
           service = SubscriptionService()
           assert service.normalize_name("") == "Subscriber"

       def test_none_name_defaults(self, app):
           """None defaults to 'Subscriber'."""
           service = SubscriptionService()
           assert service.normalize_name(None) == "Subscriber"

       def test_whitespace_only_defaults(self, app):
           """Whitespace-only string defaults to 'Subscriber'."""
           service = SubscriptionService()
           assert service.normalize_name("   ") == "Subscriber"
   ```

> ℹ **Concept Deep Dive**
>
> Testing `None` handling is critical. HTML forms submit empty fields as empty strings, but API calls or internal code might pass `None`. The business layer must handle both gracefully. These four tests cover the full spectrum: valid input, empty string, `None`, and whitespace-only.
>
> ⚠ **Common Mistakes**
>
> - Assuming the default value is "Subscriber" without checking the implementation -- always verify against the actual service code
> - Forgetting to test `None` separately from empty string -- they are different types in Python
>
> ✓ **Quick check:** Four name normalization tests covering trim, empty, None, and whitespace

### **Step 4:** Test process_subscription

The `process_subscription` method combines validation and normalization into a single operation. It returns a dictionary on success and raises a `ValueError` on invalid input. Testing this method verifies the integration between validation and normalization within the business layer.

1. **Open** the file `tests/test_subscription_service.py`

2. **Add** the following test class after `TestNameNormalization`:

   > `tests/test_subscription_service.py`

   ```python
   class TestProcessSubscription:
       """Test the process_subscription method."""

       def test_valid_data_returns_dict(self, app):
           """Valid input returns a dictionary with processed data."""
           service = SubscriptionService()
           result = service.process_subscription("user@example.com", "John")
           assert isinstance(result, dict)
           assert result["email"] == "user@example.com"
           assert result["name"] == "John"

       def test_normalizes_email(self, app):
           """Email is normalized in the returned dictionary."""
           service = SubscriptionService()
           result = service.process_subscription("  USER@EXAMPLE.COM  ", "John")
           assert result["email"] == "user@example.com"

       def test_invalid_email_raises(self, app):
           """Invalid email raises ValueError."""
           service = SubscriptionService()
           with pytest.raises(ValueError):
               service.process_subscription("invalid", "John")

       def test_dict_has_expected_keys(self, app):
           """Returned dictionary contains all expected keys."""
           service = SubscriptionService()
           result = service.process_subscription("user@example.com", "John")
           assert "email" in result
           assert "name" in result
           assert "subscribed_at" in result
   ```

> ℹ **Concept Deep Dive**
>
> `pytest.raises(ValueError)` is a context manager that asserts the code inside raises that specific exception. If the code completes without raising, the test fails. If it raises a different exception type, the test also fails. This tests error handling paths -- equally important as testing success paths.
>
> The `test_dict_has_expected_keys` test verifies the contract of the method: callers depend on specific keys being present. If someone changes the return structure, this test catches it immediately.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to import `pytest` at the top of the file when using `pytest.raises`
> - Testing only the success path and ignoring error handling
> - Checking exact timestamp values instead of just verifying the key exists (timestamps change every run)
>
> ✓ **Quick check:** Four tests covering valid output, normalization, error handling, and dictionary structure

### **Step 5:** Run and Analyze

Run the complete test suite to verify all business layer tests pass. Analyze the output to understand which tests ran and how fast they executed.

1. **Run the business layer tests:**

   ```bash
   python -m pytest tests/test_subscription_service.py -v
   ```

2. **Review the output:** Each test should show `PASSED` with the full test path:

   ```text
   tests/test_subscription_service.py::TestEmailValidation::test_valid_email PASSED
   tests/test_subscription_service.py::TestEmailValidation::test_valid_email_with_dots PASSED
   tests/test_subscription_service.py::TestEmailValidation::test_valid_email_with_plus PASSED
   tests/test_subscription_service.py::TestEmailValidation::test_empty_email PASSED
   tests/test_subscription_service.py::TestEmailValidation::test_whitespace_only_email PASSED
   tests/test_subscription_service.py::TestEmailValidation::test_no_at_sign PASSED
   tests/test_subscription_service.py::TestEmailValidation::test_no_tld PASSED
   tests/test_subscription_service.py::TestEmailValidation::test_double_at PASSED
   tests/test_subscription_service.py::TestEmailNormalization::test_lowercase_conversion PASSED
   tests/test_subscription_service.py::TestEmailNormalization::test_whitespace_stripped PASSED
   tests/test_subscription_service.py::TestEmailNormalization::test_already_normalized PASSED
   tests/test_subscription_service.py::TestNameNormalization::test_normal_name_trimmed PASSED
   tests/test_subscription_service.py::TestNameNormalization::test_empty_name_defaults PASSED
   tests/test_subscription_service.py::TestNameNormalization::test_none_name_defaults PASSED
   tests/test_subscription_service.py::TestNameNormalization::test_whitespace_only_defaults PASSED
   tests/test_subscription_service.py::TestProcessSubscription::test_valid_data_returns_dict PASSED
   tests/test_subscription_service.py::TestProcessSubscription::test_normalizes_email PASSED
   tests/test_subscription_service.py::TestProcessSubscription::test_invalid_email_raises PASSED
   tests/test_subscription_service.py::TestProcessSubscription::test_dict_has_expected_keys PASSED
   ```

3. **Note the execution time:** These tests should complete in under a second. Business layer tests are fast because they exercise pure logic without database I/O or HTTP overhead.

4. **Run with a short summary:**

   ```bash
   python -m pytest tests/test_subscription_service.py -v --tb=short
   ```

   The `--tb=short` flag shows shorter tracebacks if any test fails, making it easier to identify the problem quickly.

> ✓ **Success indicators:**
>
> - All 19 tests pass (8 validation + 3 email normalization + 4 name normalization + 4 process_subscription)
> - Execution time is under one second
> - No database-related warnings or errors in output
> - Each test class groups related behavior together
>
> ✓ **Final verification checklist:**
>
> - [ ] `tests/test_subscription_service.py` created with all four test classes
> - [ ] `TestEmailValidation` covers valid and invalid email formats
> - [ ] `TestEmailNormalization` covers lowercase, whitespace, and idempotency
> - [ ] `TestNameNormalization` covers trim, empty, None, and whitespace
> - [ ] `TestProcessSubscription` covers success, normalization, error handling, and dict structure
> - [ ] All tests pass with `python -m pytest tests/test_subscription_service.py -v`

## Common Issues

> **If you encounter problems:**
>
> **"Working outside of application context":** Use the `app` fixture even for pure logic tests. The `SubscriptionService.__init__` creates a `SubscriberRepository` that requires Flask's application context to access the database configuration.
>
> **Tests pass but are slow:** Validation and normalization tests should not need database setup or teardown for the actual assertions. If tests are slow, check whether unnecessary fixtures or database operations are involved.
>
> **"ModuleNotFoundError: No module named 'app'":** Run pytest from the project root directory, or use `python -m pytest` which adds the current directory to the Python path.
>
> **normalize_name returns wrong default:** Check the `SubscriptionService` implementation for the exact default value. The tests expect `"Subscriber"`.
>
> **pytest.raises not catching the exception:** Verify that `process_subscription` actually raises `ValueError` for invalid input. Check the service implementation to confirm the exception type.
>
> **Still stuck?** Run a single test in isolation to narrow down the issue:
>
> ```bash
> python -m pytest tests/test_subscription_service.py::TestEmailValidation::test_valid_email -v
> ```

## Summary

You've successfully tested the business layer's core logic which:

- ✓ Tested email validation with both valid and invalid inputs
- ✓ Verified normalization produces consistent, predictable data
- ✓ Tested error handling with `pytest.raises` for invalid input
- ✓ Confirmed the `process_subscription` method returns the correct structure

> **Key takeaway:** Business layer tests verify logic independently of HTTP and database. These are the fastest, most reliable tests in your suite because they exercise pure functions -- given the same input, they always produce the same output. When validation rules change, these tests immediately tell you whether the new behavior is correct.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add parametrized tests with `@pytest.mark.parametrize` to test many email variants in a single test method
> - Test edge cases like very long emails, special characters, and internationalized domain names
> - Add tests for email domains with hyphens and numbers (e.g., `user@my-domain123.co.uk`)
> - Research property-based testing with the Hypothesis library for automated edge case discovery

## Done! 🎉

You've tested the business layer's validation and normalization logic. These tests ensure data quality regardless of how users submit information -- through the web form, an API, or any future interface.
