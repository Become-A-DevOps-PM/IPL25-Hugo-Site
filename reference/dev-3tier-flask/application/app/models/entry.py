"""Entry model for storing user-submitted values."""

from datetime import datetime
from app.extensions import db


class Entry(db.Model):
    """A simple entry with a text value and timestamp."""

    __tablename__ = 'entries'

    id = db.Column(db.Integer, primary_key=True)
    value = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        """Convert entry to dictionary for JSON serialization."""
        return {
            'id': self.id,
            'value': self.value,
            'created_at': self.created_at.isoformat()
        }

    def __repr__(self):
        return f'<Entry {self.id}: {self.value[:20]}...>'
