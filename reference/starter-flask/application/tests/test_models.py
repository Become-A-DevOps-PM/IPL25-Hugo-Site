"""Tests for Note model."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from models import db, Note


class TestNoteModel:
    """Tests for Note model."""

    def test_create_note(self, app):
        with app.app_context():
            note = Note(content='test content')
            db.session.add(note)
            db.session.commit()

            assert note.id is not None
            assert note.content == 'test content'

    def test_note_has_created_at(self, app):
        with app.app_context():
            note = Note(content='test')
            db.session.add(note)
            db.session.commit()

            assert note.created_at is not None

    def test_multiple_notes(self, app):
        with app.app_context():
            note1 = Note(content='first note')
            note2 = Note(content='second note')
            db.session.add(note1)
            db.session.add(note2)
            db.session.commit()

            notes = Note.query.all()
            assert len(notes) == 2

    def test_note_content_max_length(self, app):
        with app.app_context():
            long_content = 'x' * 500
            note = Note(content=long_content)
            db.session.add(note)
            db.session.commit()

            assert len(note.content) == 500
