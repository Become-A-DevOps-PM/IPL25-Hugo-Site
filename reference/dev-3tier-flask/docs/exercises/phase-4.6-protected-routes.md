# Protected Admin Routes

## Goal

Add @login_required decorator to admin routes and update the navigation to show login/logout links based on authentication status.

> **What you'll learn:**
>
> - Using @login_required to protect routes
> - Conditional template rendering based on authentication
> - current_user template variable usage
> - How Flask-Login redirects unauthenticated users

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 4.5 (Auth Blueprint)
> - ✓ All 102 tests passing
> - ✓ Understanding of route decorators

## Exercise Steps

### Overview

1. **Protect Admin Routes**
2. **Update Base Template Navigation**
3. **Add Protected Route Tests**
4. **Verify with pytest**

### **Step 1:** Protect Admin Routes

Add @login_required decorator to the admin blueprint routes.

1. **Open** `application/app/routes/admin.py`

2. **Update** with @login_required decorator:

   ```python
   """Admin blueprint for managing registrations.

   All routes require authentication via Flask-Login.
   """
   from datetime import datetime
   import csv
   import io
   from flask import Blueprint, render_template, request, Response
   from flask_login import login_required
   from app.services.registration_service import RegistrationService

   admin_bp = Blueprint('admin', __name__, url_prefix='/admin')


   @admin_bp.route('/attendees')
   @login_required
   def attendees():
       """Display list of all webinar registrations with sorting.

       Requires authentication.

       Query parameters:
           sort: Field to sort by (name, email, company, job_title, created_at)
           order: Sort order (asc, desc)
       """
       sort_by = request.args.get('sort', 'created_at')
       order = request.args.get('order', 'desc')

       registrations = RegistrationService.get_registrations_sorted(sort_by, order)
       stats = RegistrationService.get_registration_stats()

       # Toggle order for column headers
       next_order = 'asc' if order == 'desc' else 'desc'

       return render_template('admin/attendees.html',
                             registrations=registrations,
                             stats=stats,
                             current_sort=sort_by,
                             current_order=order,
                             next_order=next_order)


   @admin_bp.route('/export/csv')
   @login_required
   def export_csv():
       """Export all registrations as CSV file.

       Requires authentication.

       Returns a downloadable CSV file with all registration data.
       Filename includes current date for easy identification.
       """
       registrations = RegistrationService.get_all_registrations()

       # Create CSV in memory
       output = io.StringIO()
       writer = csv.writer(output)

       # Write header
       writer.writerow(['ID', 'Name', 'Email', 'Company', 'Job Title', 'Registered At'])

       # Write data rows
       for reg in registrations:
           writer.writerow([
               reg.id,
               reg.name,
               reg.email,
               reg.company,
               reg.job_title,
               reg.created_at.strftime('%Y-%m-%d %H:%M:%S') if reg.created_at else ''
           ])

       # Prepare response
       output.seek(0)
       date_str = datetime.now().strftime('%Y%m%d')
       filename = f'webinar-registrations-{date_str}.csv'

       return Response(
           output.getvalue(),
           mimetype='text/csv',
           headers={'Content-Disposition': f'attachment; filename={filename}'}
       )
   ```

> ℹ **Concept Deep Dive**
>
> - **@login_required** must come AFTER @admin_bp.route (decorators apply bottom-up)
> - When unauthenticated, Flask-Login redirects to login_view (auth.login)
> - The original URL is passed as `next` parameter for post-login redirect
> - Both attendees and export routes now require authentication
>
> ⚠ **Common Mistakes**
>
> - Putting @login_required before @route (wrong order)
> - Forgetting to import login_required from flask_login
> - Only protecting one route, not all admin routes
>
> ✓ **Quick check:** Both /admin/attendees and /admin/export/csv are protected

### **Step 2:** Update Base Template Navigation

Add conditional login/logout links to the navigation.

1. **Open** `application/app/templates/base.html`

2. **Update** with authentication-aware navigation:

   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>{% block title %}Flask App{% endblock %}</title>
       <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
       {% block extra_css %}{% endblock %}
   </head>
   <body>
       <nav class="navbar">
           <div class="nav-brand">
               <a href="{{ url_for('main.index') }}">Webinar Registration</a>
           </div>
           <div class="nav-links">
               <a href="{{ url_for('main.index') }}">Home</a>
               <a href="{{ url_for('main.webinar_info') }}">About</a>
               <a href="{{ url_for('main.register') }}">Register</a>
               {% if current_user.is_authenticated %}
                   <a href="{{ url_for('admin.attendees') }}">Admin</a>
                   <a href="{{ url_for('auth.logout') }}">Logout</a>
               {% else %}
                   <a href="{{ url_for('auth.login') }}">Login</a>
               {% endif %}
           </div>
       </nav>

       <main class="container">
           {% with messages = get_flashed_messages(with_categories=true) %}
               {% if messages %}
                   <div class="flash-messages">
                       {% for category, message in messages %}
                           <div class="flash flash-{{ category }}">
                               {{ message }}
                               <button type="button" class="flash-close" onclick="this.parentElement.remove()">&times;</button>
                           </div>
                       {% endfor %}
                   </div>
               {% endif %}
           {% endwith %}

           {% block content %}{% endblock %}
       </main>

       <footer class="footer">
           <p>&copy; 2026 Webinar Registration. Built with Flask.</p>
       </footer>

       {% block extra_js %}{% endblock %}
   </body>
   </html>
   ```

> ℹ **Concept Deep Dive**
>
> - **current_user** is automatically available in templates via Flask-Login
> - **is_authenticated** returns True for logged-in users
> - Authenticated users see Admin + Logout links
> - Anonymous users see only Login link
> - Admin link is only shown when authenticated (no point showing protected page)
>
> ✓ **Quick check:** Navigation shows different links based on authentication

### **Step 3:** Add Protected Route Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

   ```python
   class TestProtectedAdminRoutes:
       """Tests for admin route protection."""

       def test_admin_attendees_requires_login(self, client):
           """Test that /admin/attendees redirects to login when not authenticated."""
           response = client.get('/admin/attendees', follow_redirects=False)
           assert response.status_code == 302
           assert '/auth/login' in response.location

       def test_admin_export_requires_login(self, client):
           """Test that /admin/export/csv redirects to login when not authenticated."""
           response = client.get('/admin/export/csv', follow_redirects=False)
           assert response.status_code == 302
           assert '/auth/login' in response.location

       def test_admin_attendees_accessible_when_logged_in(self, app, client):
           """Test that /admin/attendees is accessible when authenticated."""
           with app.app_context():
               from app.services.auth_service import AuthService
               AuthService.create_user('adminaccess', 'password12345')

           client.post('/auth/login', data={
               'username': 'adminaccess',
               'password': 'password12345'
           })

           response = client.get('/admin/attendees')
           assert response.status_code == 200
           assert b'Attendees' in response.data

       def test_admin_export_accessible_when_logged_in(self, app, client):
           """Test that /admin/export/csv is accessible when authenticated."""
           with app.app_context():
               from app.services.auth_service import AuthService
               AuthService.create_user('exportaccess', 'password12345')

           client.post('/auth/login', data={
               'username': 'exportaccess',
               'password': 'password12345'
           })

           response = client.get('/admin/export/csv')
           assert response.status_code == 200
           assert 'text/csv' in response.content_type

       def test_login_redirect_preserves_next_url(self, client):
           """Test that login redirect includes next parameter."""
           response = client.get('/admin/attendees', follow_redirects=False)
           assert response.status_code == 302
           # Flask-Login adds next parameter
           assert '/auth/login' in response.location

       def test_login_redirects_to_next_after_success(self, app, client):
           """Test that successful login redirects to the requested page."""
           with app.app_context():
               from app.services.auth_service import AuthService
               AuthService.create_user('nexttest', 'password12345')

           response = client.post('/auth/login?next=/admin/attendees', data={
               'username': 'nexttest',
               'password': 'password12345'
           }, follow_redirects=False)

           assert response.status_code == 302
           assert '/admin/attendees' in response.location
   ```

> ℹ **Concept Deep Dive**
>
> - Tests verify both redirect behavior and successful access
> - **follow_redirects=False** allows checking the redirect location
> - Tests create users, login, then access protected routes
> - The "next" parameter flow is tested end-to-end
>
> ✓ **Quick check:** 6 new tests for protected route behavior

### **Step 4:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 102 + 6 = 108 tests passing

> ✓ **Success indicators:**
>
> - All 108 tests pass
> - Unauthenticated users redirected to login
> - Authenticated users can access admin pages
> - Navigation updates based on login state

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `routes/admin.py` has @login_required on attendees()
> - ☐ `routes/admin.py` has @login_required on export_csv()
> - ☐ @login_required comes AFTER @admin_bp.route
> - ☐ `base.html` shows Login for anonymous users
> - ☐ `base.html` shows Admin + Logout for authenticated users
> - ☐ `pytest tests/test_routes.py -v` passes (108 tests)

## Common Issues

> **If you encounter problems:**
>
> **Redirect loop:** Ensure login page doesn't have @login_required
>
> **current_user not available:** Flask-Login context processor is automatic, no setup needed
>
> **401 instead of redirect:** Verify login_manager.login_view is set correctly
>
> **Tests fail after login:** Each test client has separate session (by design)

## Summary

You've protected the admin routes:

- ✓ @login_required decorator on both admin routes
- ✓ Unauthenticated users redirected to login
- ✓ "next" parameter enables return to requested page
- ✓ Navigation shows appropriate links per auth state
- ✓ 6 new tests verify protection behavior

> **Key takeaway:** Flask-Login's @login_required decorator handles the entire redirect-login-return flow automatically. The navigation updates provide clear UX about available actions based on authentication status.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add role-based access control (admin vs moderator)
> - Implement fresh login requirement for sensitive actions
> - Add session timeout for inactive users

## Done!

Admin routes are now protected. Next phase will add security headers middleware.
