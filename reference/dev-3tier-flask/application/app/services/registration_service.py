"""Business logic for webinar registrations."""
from sqlalchemy.exc import IntegrityError
from sqlalchemy import func
from app.extensions import db
from app.models.registration import Registration


class DuplicateEmailError(Exception):
    """Raised when attempting to register with an existing email."""
    pass


class RegistrationService:
    """Service layer for registration operations."""

    @staticmethod
    def create_registration(name, email, company, job_title):
        """Create a new webinar registration.

        Args:
            name: Attendee's full name
            email: Attendee's email address (must be unique)
            company: Attendee's company name
            job_title: Attendee's job title

        Returns:
            Registration: The created registration object

        Raises:
            DuplicateEmailError: If email is already registered
        """
        registration = Registration(
            name=name,
            email=email.lower().strip(),  # Normalize email
            company=company,
            job_title=job_title
        )
        try:
            db.session.add(registration)
            db.session.commit()
            return registration
        except IntegrityError:
            db.session.rollback()
            raise DuplicateEmailError(f"Email '{email}' is already registered.")

    @staticmethod
    def get_all_registrations():
        """Get all registrations ordered by creation date."""
        return Registration.query.order_by(Registration.created_at.desc()).all()

    @staticmethod
    def get_registration_count():
        """Get total count of registrations."""
        return Registration.query.count()

    @staticmethod
    def email_exists(email):
        """Check if an email is already registered.

        Args:
            email: Email address to check

        Returns:
            bool: True if email exists, False otherwise
        """
        normalized_email = email.lower().strip()
        return Registration.query.filter_by(email=normalized_email).first() is not None

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
