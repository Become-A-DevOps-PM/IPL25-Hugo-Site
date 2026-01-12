"""
Tests for Note model.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from models import db, Note


class TestNoteModel:
    """Tests for Note model."""

    def test_create_note(self, app):
        """Should create note with content."""
        with app.app_context():
            note = Note(content='test content')
            db.session.add(note)
            db.session.commit()

            assert note.id is not None
            assert note.content == 'test content'

    def test_note_has_created_at(self, app):
        """Note should have created_at timestamp."""
        with app.app_context():
            note = Note(content='test')
            db.session.add(note)
            db.session.commit()

            assert note.created_at is not None

    def test_note_to_dict(self, app):
        """Note to_dict should return serializable dict."""
        with app.app_context():
            note = Note(content='test content')
            db.session.add(note)
            db.session.commit()

            d = note.to_dict()
            assert d['content'] == 'test content'
            assert 'id' in d
            assert 'created_at' in d

    def test_note_repr(self, app):
        """Note repr should show id and truncated content."""
        with app.app_context():
            note = Note(content='this is a test note with some content')
            db.session.add(note)
            db.session.commit()

            repr_str = repr(note)
            assert 'Note' in repr_str
            assert str(note.id) in repr_str

    def test_multiple_notes(self, app):
        """Should be able to create multiple notes."""
        with app.app_context():
            note1 = Note(content='first note')
            note2 = Note(content='second note')
            db.session.add(note1)
            db.session.add(note2)
            db.session.commit()

            notes = Note.query.all()
            assert len(notes) == 2

    def test_note_content_max_length(self, app):
        """Note content should handle max length."""
        with app.app_context():
            long_content = 'x' * 500  # Max is 500
            note = Note(content=long_content)
            db.session.add(note)
            db.session.commit()

            assert len(note.content) == 500
