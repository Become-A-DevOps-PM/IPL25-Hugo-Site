"""Business logic for webinar registrations."""

from app.extensions import db
from app.models.registration import Registration


class RegistrationService:
    """Service layer for registration operations."""

    @staticmethod
    def create_registration(name, email, company, job_title):
        """Create a new webinar registration."""
        registration = Registration(
            name=name,
            email=email,
            company=company,
            job_title=job_title
        )
        db.session.add(registration)
        db.session.commit()
        return registration

    @staticmethod
    def get_all_registrations():
        """Get all registrations ordered by creation date."""
        return Registration.query.order_by(Registration.created_at.desc()).all()

    @staticmethod
    def get_registration_count():
        """Get total count of registrations."""
        return Registration.query.count()
