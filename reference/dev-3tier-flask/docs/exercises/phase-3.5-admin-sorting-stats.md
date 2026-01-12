# Admin Sorting and Statistics

## Goal

Enhance the admin dashboard with sortable columns and registration statistics.

> **What you'll learn:**
>
> - Implementing query parameter-based sorting
> - Creating statistics queries with SQLAlchemy
> - Building sortable table headers in templates
> - CSS styling for admin dashboards

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 3.4 (Webinar information page)
> - ✓ All 59 tests passing
> - ✓ Understanding of SQLAlchemy queries and Flask request args

## Exercise Steps

### Overview

1. **Add Sorting Methods to Service**
2. **Add Statistics Method to Service**
3. **Update Admin Route**
4. **Update Admin Template**
5. **Add CSS for Admin Page**
6. **Add Sorting Tests**
7. **Verify with pytest**

### **Step 1:** Add Sorting Methods to Service

Add methods for fetching sorted registrations and generating statistics.

1. **Open** `application/app/services/registration_service.py`

2. **Add** the following methods to the `RegistrationService` class:

   ```python
       @staticmethod
       def get_registrations_sorted(sort_by='created_at', order='desc'):
           """Get registrations with sorting options.

           Args:
               sort_by: Field to sort by (name, email, company, job_title, created_at)
               order: Sort order ('asc' or 'desc')

           Returns:
               List of Registration objects
           """
           valid_columns = ['name', 'email', 'company', 'job_title', 'created_at']
           if sort_by not in valid_columns:
               sort_by = 'created_at'

           column = getattr(Registration, sort_by)
           if order == 'asc':
               return Registration.query.order_by(column.asc()).all()
           return Registration.query.order_by(column.desc()).all()

       @staticmethod
       def get_registration_stats():
           """Get registration statistics.

           Returns:
               dict: Statistics including total count and registrations by date
           """
           from sqlalchemy import func

           total = Registration.query.count()

           # Registrations grouped by date
           by_date = db.session.query(
               func.date(Registration.created_at).label('date'),
               func.count(Registration.id).label('count')
           ).group_by(func.date(Registration.created_at)).order_by(
               func.date(Registration.created_at).desc()
           ).limit(7).all()

           return {
               'total': total,
               'by_date': [{'date': str(d.date), 'count': d.count} for d in by_date]
           }
   ```

> ℹ **Concept Deep Dive**
>
> - **valid_columns** whitelist prevents SQL injection via sort parameter
> - **getattr(Registration, sort_by)** dynamically gets the column object
> - **func.date()** extracts date part for grouping
> - Statistics are limited to last 7 days for dashboard display
>
> ⚠ **Common Mistakes**
>
> - Not validating sort_by allows arbitrary column injection
> - Forgetting to import func from sqlalchemy
>
> ✓ **Quick check:** Service has get_registrations_sorted() and get_registration_stats()

### **Step 2:** Update Admin Route

Modify the attendees route to handle sorting parameters and pass statistics to the template.

1. **Open** `application/app/routes/admin.py`

2. **Replace** with the following content:

   ```python
   """Admin blueprint for managing registrations.

   Note: No authentication in Phase 3. Routes are publicly accessible.
   Authentication will be added in Phase 4.
   """
   from flask import Blueprint, render_template, request
   from app.services.registration_service import RegistrationService

   admin_bp = Blueprint('admin', __name__, url_prefix='/admin')


   @admin_bp.route('/attendees')
   def attendees():
       """Display list of all webinar registrations with sorting.

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
   ```

> ℹ **Concept Deep Dive**
>
> - **request.args.get()** safely retrieves query parameters with defaults
> - **next_order** toggles between asc/desc for each click
> - Template receives all needed state for rendering sortable headers
>
> ✓ **Quick check:** Route reads sort/order params and passes stats to template

### **Step 3:** Update Admin Template

Create an enhanced template with sortable headers and a statistics panel.

1. **Open** `application/app/templates/admin/attendees.html`

2. **Replace** with the following content:

   ```html
   {% extends "base.html" %}

   {% block title %}Admin - Attendees{% endblock %}

   {% block content %}
   <div class="admin-page">
       <h1>Webinar Attendees</h1>

       <div class="stats-panel">
           <div class="stat-card stat-primary">
               <span class="stat-value">{{ stats.total }}</span>
               <span class="stat-label">Total Registrations</span>
           </div>
           {% if stats.by_date %}
           <div class="stat-card">
               <span class="stat-value">{{ stats.by_date[0].count if stats.by_date else 0 }}</span>
               <span class="stat-label">Today</span>
           </div>
           {% endif %}
       </div>

       {% if registrations %}
       <div class="table-controls">
           <p class="result-count">Showing {{ registrations|length }} registrations</p>
           <a href="{{ url_for('admin.export_csv') }}" class="btn btn-secondary btn-sm">Export CSV</a>
       </div>

       <table class="attendees-table sortable">
           <thead>
               <tr>
                   <th>
                       <a href="?sort=name&order={{ next_order if current_sort == 'name' else 'asc' }}"
                          class="sort-link {% if current_sort == 'name' %}active {{ current_order }}{% endif %}">
                           Name
                           <span class="sort-indicator"></span>
                       </a>
                   </th>
                   <th>
                       <a href="?sort=email&order={{ next_order if current_sort == 'email' else 'asc' }}"
                          class="sort-link {% if current_sort == 'email' %}active {{ current_order }}{% endif %}">
                           Email
                           <span class="sort-indicator"></span>
                       </a>
                   </th>
                   <th>
                       <a href="?sort=company&order={{ next_order if current_sort == 'company' else 'asc' }}"
                          class="sort-link {% if current_sort == 'company' %}active {{ current_order }}{% endif %}">
                           Company
                           <span class="sort-indicator"></span>
                       </a>
                   </th>
                   <th>
                       <a href="?sort=job_title&order={{ next_order if current_sort == 'job_title' else 'asc' }}"
                          class="sort-link {% if current_sort == 'job_title' %}active {{ current_order }}{% endif %}">
                           Job Title
                           <span class="sort-indicator"></span>
                       </a>
                   </th>
                   <th>
                       <a href="?sort=created_at&order={{ next_order if current_sort == 'created_at' else 'desc' }}"
                          class="sort-link {% if current_sort == 'created_at' %}active {{ current_order }}{% endif %}">
                           Registered
                           <span class="sort-indicator"></span>
                       </a>
                   </th>
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
> - Sortable headers use query parameters to maintain URL-based state
> - **next_order** logic toggles between asc/desc on each column click
> - **active** class highlights the currently sorted column
> - Empty state provides guidance when no registrations exist
>
> ✓ **Quick check:** Template has stats panel, sortable headers, and export link

### **Step 4:** Add CSS for Admin Page

1. **Open** `application/app/static/css/style.css`

2. **Add** the following CSS:

   ```css
   /* ===== Admin Stats Panel ===== */
   .stats-panel {
       display: flex;
       gap: 1rem;
       margin-bottom: 1.5rem;
       flex-wrap: wrap;
   }

   .stat-card {
       background: #fff;
       border: 1px solid #e9ecef;
       border-radius: 8px;
       padding: 1.25rem 1.5rem;
       min-width: 150px;
       text-align: center;
   }

   .stat-card.stat-primary {
       background: #007bff;
       color: white;
       border-color: #007bff;
   }

   .stat-value {
       display: block;
       font-size: 2rem;
       font-weight: bold;
       line-height: 1.2;
   }

   .stat-label {
       display: block;
       font-size: 0.875rem;
       opacity: 0.8;
       margin-top: 0.25rem;
   }

   /* ===== Sortable Table ===== */
   .table-controls {
       display: flex;
       justify-content: space-between;
       align-items: center;
       margin-bottom: 1rem;
   }

   .result-count {
       color: #6c757d;
       margin: 0;
   }

   .btn-sm {
       padding: 0.375rem 0.75rem;
       font-size: 0.875rem;
   }

   .attendees-table {
       width: 100%;
       border-collapse: collapse;
       background: #fff;
       box-shadow: 0 1px 3px rgba(0,0,0,0.1);
   }

   .attendees-table th,
   .attendees-table td {
       padding: 0.75rem 1rem;
       text-align: left;
       border-bottom: 1px solid #e9ecef;
   }

   .attendees-table th {
       background: #f8f9fa;
       font-weight: 600;
   }

   .attendees-table tbody tr:hover {
       background: #f8f9fa;
   }

   .sort-link {
       color: inherit;
       text-decoration: none;
       display: flex;
       align-items: center;
       gap: 0.5rem;
   }

   .sort-link:hover {
       color: #007bff;
   }

   .sort-indicator::after {
       content: '⇅';
       opacity: 0.3;
   }

   .sort-link.active .sort-indicator::after {
       opacity: 1;
   }

   .sort-link.active.asc .sort-indicator::after {
       content: '↑';
   }

   .sort-link.active.desc .sort-indicator::after {
       content: '↓';
   }

   /* ===== Empty State ===== */
   .empty-state {
       text-align: center;
       padding: 3rem;
       background: #f8f9fa;
       border-radius: 8px;
       color: #6c757d;
   }
   ```

> ✓ **Quick check:** CSS includes stats panel, table, and sort indicator styles

### **Step 5:** Add Sorting Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

   ```python
   class TestAdminSorting:
       """Tests for admin attendee list sorting."""

       def test_admin_default_sort_by_date_desc(self, app, client):
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

           response = client.get('/admin/attendees')
           # Second should appear before First (desc order)
           second_pos = response.data.find(b'Second User')
           first_pos = response.data.find(b'First User')
           assert second_pos < first_pos

       def test_admin_sort_by_name_asc(self, app, client):
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

           response = client.get('/admin/attendees?sort=name&order=asc')
           alice_pos = response.data.find(b'Alice')
           zoe_pos = response.data.find(b'Zoe')
           assert alice_pos < zoe_pos

       def test_admin_shows_stats(self, app, client):
           """Test that admin page shows statistics."""
           with app.app_context():
               from app.services.registration_service import RegistrationService
               for i in range(3):
                   RegistrationService.create_registration(
                       name=f'User {i}', email=f'user{i}@test.com',
                       company='Corp', job_title='Dev'
                   )

           response = client.get('/admin/attendees')
           assert b'Total Registrations' in response.data

       def test_admin_has_export_link(self, client, app):
           """Test that admin page has export CSV link when registrations exist."""
           with app.app_context():
               from app.services.registration_service import RegistrationService
               RegistrationService.create_registration(
                   name='Export Test', email='export@test.com',
                   company='Corp', job_title='Dev'
               )

           response = client.get('/admin/attendees')
           assert b'Export CSV' in response.data
   ```

> ✓ **Quick check:** 4 new tests for sorting and statistics

### **Step 6:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 59 + 4 = 63 tests passing

> ✓ **Success indicators:**
>
> - All 63 tests pass
> - Sorting works on all columns
> - Statistics display correctly

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ Service has `get_registrations_sorted()` and `get_registration_stats()`
> - ☐ Admin route reads sort/order query parameters
> - ☐ Template has sortable column headers
> - ☐ Statistics panel shows total and today's count
> - ☐ Export CSV link present in template
> - ☐ `pytest tests/test_routes.py -v` passes (63 tests)

## Common Issues

> **If you encounter problems:**
>
> **Sort not working:** Check column name matches model attribute exactly
>
> **Statistics empty:** Ensure registrations exist in database
>
> **sort-indicator not showing:** Verify CSS class names match template
>
> **Import error for func:** Add `from sqlalchemy import func` in service

## Summary

You've enhanced the admin dashboard:

- ✓ Sortable columns with asc/desc toggle
- ✓ Statistics panel with total and daily counts
- ✓ Visual sort indicators on column headers
- ✓ Empty state messaging for no registrations
- ✓ 4 new tests verify sorting behavior

> **Key takeaway:** Query parameter-based sorting maintains state in URLs, making pages shareable and bookmarkable while keeping the backend stateless.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add pagination for large datasets
> - Implement search/filter functionality
> - Add date range filters for statistics

## Done!

Admin sorting and statistics are complete. Next phase will add CSV export functionality.
