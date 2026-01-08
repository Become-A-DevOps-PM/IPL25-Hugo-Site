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
