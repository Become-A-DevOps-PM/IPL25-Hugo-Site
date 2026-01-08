# Creating the Admin Blueprint and Attendees List

## Goal

Create an admin section for viewing webinar registrations, using a new blueprint with its own URL prefix.

> **What you'll learn:**
>
> - Creating new Flask blueprints with URL prefixes
> - Displaying database data in templates
> - Blueprint organization patterns

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 2.6 (Thank You Page)
> - ✓ Understanding of Flask blueprints
> - ✓ 34 tests passing

## Exercise Steps

### Overview

1. **Create the Admin Blueprint**
2. **Register Blueprint in Application**
3. **Create Admin Templates Directory**
4. **Create Attendees Template**
5. **Add Tests for Admin Pages**
6. **Verify with pytest**

### **Step 1:** Create the Admin Blueprint

1. **Create** a new file at `application/app/routes/admin.py`

2. **Add** the following code:

   ```python
   """Admin blueprint for managing registrations.

   Note: No authentication in Phase 2. Routes are publicly accessible.
   Authentication will be added in Phase 4.
   """
   from flask import Blueprint, render_template
   from app.services.registration_service import RegistrationService

   admin_bp = Blueprint('admin', __name__, url_prefix='/admin')


   @admin_bp.route('/attendees')
   def attendees():
       """Display list of all webinar registrations."""
       registrations = RegistrationService.get_all_registrations()
       count = RegistrationService.get_registration_count()
       return render_template('admin/attendees.html',
                             registrations=registrations,
                             count=count)
   ```

> ℹ **Concept Deep Dive**
>
> **URL Prefix**: The `url_prefix='/admin'` means:
>
> - Route `/attendees` becomes `/admin/attendees`
> - All routes in this blueprint share the prefix
> - Organizes admin URLs under a common path
>
> **No Authentication**: We note this is Phase 2 - authentication comes later.
> This is intentional for learning progression.
>
> ⚠ **Common Mistakes**
>
> - Forgetting url_prefix (routes appear at root level)
> - Not importing RegistrationService
> - Using wrong template path
>
> ✓ **Quick check:** Blueprint registered with /admin prefix

### **Step 2:** Register Blueprint in Application

1. **Open** `application/app/routes/__init__.py`

2. **Update** the imports and registration function:

   ```python
   """Blueprint registration for the application.

   All blueprints are registered here to keep the application factory clean.
   """

   from app.routes.main import main_bp
   from app.routes.api import api_bp
   from app.routes.demo import demo_bp
   from app.routes.admin import admin_bp


   def register_blueprints(app):
       """Register all blueprints with the Flask application.

       Args:
           app: The Flask application instance.
       """
       app.register_blueprint(main_bp)
       app.register_blueprint(api_bp)
       app.register_blueprint(demo_bp)
       app.register_blueprint(admin_bp)
   ```

> ✓ **Quick check:** Four blueprints imported and registered

### **Step 3:** Create Admin Templates Directory

1. **Create** the directory `application/app/templates/admin/`

2. **Note**: This keeps admin templates organized separately from main templates

### **Step 4:** Create Attendees Template

1. **Create** a new file at `application/app/templates/admin/attendees.html`

2. **Add** the following content:

   ```html
   {% extends "base.html" %}

   {% block title %}Admin - Attendees{% endblock %}

   {% block content %}
   <div class="admin-page">
       <h1>Webinar Attendees</h1>
       <p class="lead">Total registrations: <strong>{{ count }}</strong></p>

       {% if registrations %}
       <table class="attendees-table">
           <thead>
               <tr>
                   <th>Name</th>
                   <th>Email</th>
                   <th>Company</th>
                   <th>Job Title</th>
                   <th>Registered</th>
               </tr>
           </thead>
           <tbody>
               {% for reg in registrations %}
               <tr>
                   <td>{{ reg.name }}</td>
                   <td>{{ reg.email }}</td>
                   <td>{{ reg.company }}</td>
                   <td>{{ reg.job_title }}</td>
                   <td>{{ reg.created_at.strftime('%Y-%m-%d %H:%M') }}</td>
               </tr>
               {% endfor %}
           </tbody>
       </table>
       {% else %}
       <div class="empty-state">
           <p>No registrations yet.</p>
           <p><a href="{{ url_for('main.index') }}">Share the registration link</a> to get attendees.</p>
       </div>
       {% endif %}

       <div class="admin-nav">
           <a href="{{ url_for('main.index') }}">← Back to Home</a>
       </div>
   </div>
   {% endblock %}
   ```

> ℹ **Concept Deep Dive**
>
> The template handles two states:
>
> - **With registrations**: Displays a table with all data
> - **Empty state**: Shows a helpful message when no data exists
>
> The `{% if registrations %}` block provides conditional rendering.
>
> Date formatting uses `strftime('%Y-%m-%d %H:%M')` for readable timestamps.
>
> ✓ **Quick check:** Table with 5 columns, empty state fallback

### **Step 5:** Add Tests for Admin Pages

1. **Open** `application/tests/test_routes.py`

2. **Add** a new test class:

   ```python
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
   ```

> ✓ **Quick check:** Four new tests for admin functionality

### **Step 6:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** all tests pass (34 existing + 4 new = 38 tests)

> ✓ **Success indicators:**
>
> - All 38 tests pass
> - Admin page accessible at /admin/attendees
> - Table displays registrations correctly

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `admin.py` file exists with admin_bp blueprint
> - ☐ `__init__.py` registers admin_bp
> - ☐ `admin/` directory exists in templates
> - ☐ `admin/attendees.html` displays registrations table
> - ☐ Page shows empty state when no registrations
> - ☐ Page shows data when registrations exist
> - ☐ `pytest tests/test_routes.py -v` passes (38 tests)

## Common Issues

> **If you encounter problems:**
>
> **404 on /admin/attendees:** Check blueprint is registered with url_prefix
>
> **TemplateNotFound:** Ensure admin/ subdirectory exists in templates/
>
> **Empty table when data exists:** Verify registrations variable passed to template
>
> **Still stuck?** Compare with demo.py for blueprint structure

## Summary

You've created the admin section with:

- ✓ New admin blueprint with /admin URL prefix
- ✓ Attendees page showing registration table
- ✓ Empty state handling
- ✓ Registration count display
- ✓ Four tests verifying functionality

> **Key takeaway:** Blueprints with URL prefixes organize related routes. The admin section provides visibility into registrations.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add CSV export functionality
> - Add pagination for large lists
> - Add search/filter capability

## Done!

The admin section is complete. Next phase will add end-to-end tests for the full registration flow.
