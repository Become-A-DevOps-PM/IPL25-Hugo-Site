"""Registration model for webinar signups."""
from datetime import datetime, timezone
from app.extensions import db


class Registration(db.Model):
    """Webinar registration with attendee information."""

    __tablename__ = 'registrations'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False, unique=True, index=True)
    company = db.Column(db.String(100), nullable=False)
    job_title = db.Column(db.String(100), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    def __repr__(self):
        return f'<Registration {self.email}>'

    def to_dict(self):
        """Convert registration to dictionary for JSON serialization."""
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'company': self.company,
            'job_title': self.job_title,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
