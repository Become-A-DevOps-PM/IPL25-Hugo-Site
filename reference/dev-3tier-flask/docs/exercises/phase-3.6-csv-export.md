# CSV Data Export

## Goal

Add functionality to export registration data as a downloadable CSV file.

> **What you'll learn:**
>
> - Creating file downloads in Flask
> - Generating CSV data in Python
> - Setting HTTP headers for file downloads
> - Testing file download responses

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Completed Phase 3.5 (Admin sorting and statistics)
> - ✓ All 63 tests passing
> - ✓ Understanding of HTTP headers and MIME types

## Exercise Steps

### Overview

1. **Add CSV Export Route**
2. **Add Export Tests**
3. **Verify with pytest**

### **Step 1:** Add CSV Export Route

Create a route that generates and returns a CSV file as a download.

1. **Open** `application/app/routes/admin.py`

2. **Update** the imports at the top:

   ```python
   from datetime import datetime
   import csv
   import io
   from flask import Blueprint, render_template, request, Response
   from app.services.registration_service import RegistrationService
   ```

3. **Add** the following route at the end of the file:

   ```python
   @admin_bp.route('/export/csv')
   def export_csv():
       """Export all registrations as CSV file.

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
> - **io.StringIO()** creates an in-memory file-like object for the CSV
> - **csv.writer()** handles proper CSV formatting including escaping
> - **output.seek(0)** resets the position to read from the beginning
> - **mimetype='text/csv'** tells the browser this is CSV data
> - **Content-Disposition: attachment** triggers a file download instead of display
> - Filename includes date for organizing multiple exports
>
> ⚠ **Common Mistakes**
>
> - Forgetting `output.seek(0)` results in empty response
> - Using `io.BytesIO` instead of `StringIO` for text CSV
> - Not handling None values in datetime formatting
>
> ✓ **Quick check:** Route returns Response with CSV MIME type and attachment header

### **Step 2:** Add Export Tests

1. **Open** `application/tests/test_routes.py`

2. **Add** the following test class:

   ```python
   class TestCSVExport:
       """Tests for CSV export functionality."""

       def test_export_csv_returns_csv_content_type(self, client):
           """Test that export returns CSV content type."""
           response = client.get('/admin/export/csv')
           assert response.status_code == 200
           assert 'text/csv' in response.content_type

       def test_export_csv_has_attachment_header(self, client):
           """Test that export has attachment filename header."""
           response = client.get('/admin/export/csv')
           assert 'attachment' in response.headers.get('Content-Disposition', '')
           assert 'webinar-registrations' in response.headers.get('Content-Disposition', '')
           assert '.csv' in response.headers.get('Content-Disposition', '')

       def test_export_csv_contains_headers(self, client):
           """Test that CSV contains column headers."""
           response = client.get('/admin/export/csv')
           csv_content = response.data.decode('utf-8')
           assert 'ID' in csv_content
           assert 'Name' in csv_content
           assert 'Email' in csv_content
           assert 'Company' in csv_content
           assert 'Job Title' in csv_content
           assert 'Registered At' in csv_content

       def test_export_csv_contains_data(self, app, client):
           """Test that CSV contains registration data."""
           with app.app_context():
               from app.services.registration_service import RegistrationService
               RegistrationService.create_registration(
                   name='CSV Export Test',
                   email='csvtest@example.com',
                   company='Export Corp',
                   job_title='Exporter'
               )

           response = client.get('/admin/export/csv')
           csv_content = response.data.decode('utf-8')
           assert 'CSV Export Test' in csv_content
           assert 'csvtest@example.com' in csv_content
           assert 'Export Corp' in csv_content
           assert 'Exporter' in csv_content

       def test_export_csv_empty_returns_headers_only(self, client):
           """Test that empty export still returns headers."""
           response = client.get('/admin/export/csv')
           csv_content = response.data.decode('utf-8')
           lines = csv_content.strip().split('\n')
           assert len(lines) == 1  # Just the header row
           assert 'Name' in lines[0]
   ```

> ℹ **Concept Deep Dive**
>
> - **response.data.decode('utf-8')** converts bytes to string for assertions
> - Testing both structure (headers, MIME type) and content
> - Empty export test ensures graceful handling of no data
>
> ✓ **Quick check:** 5 new tests cover CSV export functionality

### **Step 3:** Verify with pytest

1. **Run** the tests:

   ```bash
   cd application
   source .venv/bin/activate
   pytest tests/test_routes.py -v
   ```

2. **Verify** test count: 63 + 5 = 68 tests passing

> ✓ **Success indicators:**
>
> - All 68 tests pass
> - CSV downloads with correct filename
> - Data exports correctly

## Verification Checklist

> **Before marking this phase complete:**
>
> - ☐ `/admin/export/csv` route returns CSV file
> - ☐ Content-Disposition header includes date-based filename
> - ☐ CSV has header row and data rows
> - ☐ Admin page has "Export CSV" button linking to route
> - ☐ `pytest tests/test_routes.py -v` passes (68 tests)

## Common Issues

> **If you encounter problems:**
>
> **Empty CSV file:** Ensure `output.seek(0)` is called before `output.getvalue()`
>
> **Encoding errors:** Use `StringIO` for text, `BytesIO` for binary
>
> **Browser displays instead of downloads:** Verify Content-Disposition header has `attachment`
>
> **Missing datetime import:** Add `from datetime import datetime` at top

## Summary

You've implemented CSV export:

- ✓ Route generates CSV from registration data
- ✓ Proper HTTP headers trigger file download
- ✓ Filename includes date for organization
- ✓ Handles empty data gracefully
- ✓ 5 new tests verify export functionality

> **Key takeaway:** In-memory file generation with `io.StringIO` avoids temporary files on disk while providing standard file-like interfaces for CSV writing.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add Excel export using openpyxl library
> - Implement date range filtering for exports
> - Add column selection for custom exports

## Done!

CSV export is complete. Next phase will add custom error pages.
