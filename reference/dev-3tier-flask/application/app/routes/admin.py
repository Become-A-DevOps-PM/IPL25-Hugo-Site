"""Admin blueprint for managing registrations.

Protected by @login_required - requires admin authentication.
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
