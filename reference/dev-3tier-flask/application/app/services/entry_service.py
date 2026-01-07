"""Entry service for business logic and database operations."""

from app.extensions import db
from app.models.entry import Entry


class EntryService:
    """Service class for Entry CRUD operations."""

    @staticmethod
    def create_entry(value):
        """Create a new entry with the given value.

        Args:
            value: The text value for the entry.

        Returns:
            The created Entry instance.
        """
        entry = Entry(value=value)
        db.session.add(entry)
        db.session.commit()
        return entry

    @staticmethod
    def get_all_entries():
        """Get all entries ordered by creation date (newest first).

        Returns:
            List of all Entry instances.
        """
        return Entry.query.order_by(Entry.created_at.desc()).all()

    @staticmethod
    def get_recent_entries(limit=10):
        """Get recent entries with a limit.

        Args:
            limit: Maximum number of entries to return.

        Returns:
            List of Entry instances.
        """
        return Entry.query.order_by(Entry.created_at.desc()).limit(limit).all()

    @staticmethod
    def get_entry_count():
        """Get the total count of entries.

        Returns:
            Integer count of entries.
        """
        return Entry.query.count()
