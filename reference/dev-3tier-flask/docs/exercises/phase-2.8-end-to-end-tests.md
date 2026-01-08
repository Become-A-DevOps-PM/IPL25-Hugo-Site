# Testing the Complete Registration Flow

## Goal

Add integration tests that verify the complete user journey from landing page through registration to admin view.

> **What you'll learn:**
>
> - End-to-end testing patterns
> - Testing complete user workflows
> - Ensuring Phase 1 functionality remains intact

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 2.7 (Admin Blueprint)
> - ✓ Understanding of pytest testing patterns
> - ✓ 38 tests passing

## Exercise Steps

### Overview

1. **Add Registration Flow Integration Tests**
2. **Verify Phase 1 Demo Still Works**
3. **Update Documentation**
4. **Run Complete Test Suite**

### **Step 1:** Add Registration Flow Integration Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** a new test class for end-to-end tests:

   ```python
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
   ```

> ℹ **Concept Deep Dive**
>
> End-to-end tests verify:
>
> - **Complete workflows**: Not just individual components
> - **Data persistence**: Registration appears in admin
> - **Backward compatibility**: Phase 1 demo still works
>
> These tests catch integration issues that unit tests miss.
>
> ✓ **Quick check:** Four tests covering complete user journeys

### **Step 2:** Verify the Tests Pass

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** all tests pass (38 existing + 4 new = 42 tests)

### **Step 3:** Update Documentation

Update the CLAUDE.md endpoints table to include Phase 2 routes:

| Route | Response |
|-------|----------|
| `GET /` | Landing page with CTA |
| `GET /register` | Registration form |
| `POST /register` | Create registration (redirects) |
| `GET /thank-you` | Confirmation page |
| `GET /admin/attendees` | Attendee list |
| `GET /demo` | Demo form with entries (Phase 1) |
| `POST /demo` | Create entry (redirects) |
| `GET /api/health` | `{"status": "ok"}` |
| `GET /api/entries` | JSON array of entries |

> ✓ **Quick check:** 9 endpoints documented

### **Step 4:** Final Verification

1. **Run** the complete test suite:

   ```bash
   pytest tests/test_routes.py -v
   # Expected: 42 passed
   ```

2. **Check** all Phase 2 functionality manually if desired:
   - Visit landing page
   - Click "Register Now"
   - Fill out and submit form
   - View thank-you page
   - Check admin/attendees

> ✓ **Success indicators:**
>
> - All 42 tests pass
> - Complete registration flow works
> - Phase 1 demo still functional

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ All E2E tests pass
> - ☐ `pytest tests/test_routes.py -v` passes (42 tests)
> - ☐ Full test suite passes (`pytest tests/ -v`)
> - ☐ Phase 1 demo still works
> - ☐ Documentation updated

## Common Issues

> **If you encounter problems:**
>
> **Test isolation issues:** Each test should start with fresh database
>
> **Redirect not followed:** Use `follow_redirects=True` for POST tests
>
> **Data from other tests:** Check conftest.py creates new db per test
>
> **Still stuck?** Run tests individually to isolate failures

## Summary

You've completed Phase 2 with:

- ✓ End-to-end tests for registration flow
- ✓ Multiple registration test
- ✓ Phase 1 compatibility verification
- ✓ Updated documentation
- ✓ 42 total tests passing

> **Key takeaway:** End-to-end tests validate the entire user journey, ensuring all components work together correctly.

## Phase 2 Complete!

Congratulations! The Walking Skeleton is now complete with:

- Landing page with call-to-action
- Registration form
- Database persistence
- Thank-you confirmation
- Admin attendees list
- 42 comprehensive tests

The application now has a functional vertical slice from presentation layer through to data layer.

## Going Deeper (Optional)

> **For Phase 3 and beyond:**
>
> - Add input validation and error handling
> - Implement user authentication for admin
> - Add email confirmation
> - Deploy to Azure with database

## Done!

Phase 2: Walking Skeleton is complete!
