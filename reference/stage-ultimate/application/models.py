"""
Database models.
"""

from datetime import datetime
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class Message(db.Model):
    """Contact form submission."""

    __tablename__ = 'messages'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False, index=True)
    message = db.Column(db.Text, nullable=False)
    ip_address = db.Column(db.String(45))  # IPv6 max length
    user_agent = db.Column(db.String(256))
    created_at = db.Column(db.DateTime, default=datetime.utcnow, index=True)

    def __repr__(self):
        return f'<Message {self.id} from {self.email}>'

    def to_dict(self):
        """Serialize for API responses."""
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'message': self.message,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
