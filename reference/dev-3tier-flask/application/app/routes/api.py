"""API blueprint for JSON endpoints."""

from flask import Blueprint, jsonify
from app.services.entry_service import EntryService

api_bp = Blueprint('api', __name__, url_prefix='/api')


@api_bp.route('/entries')
def get_entries():
    """Get all entries as JSON.

    Returns:
        JSON array of entry objects with id, value, and created_at fields.
    """
    entries = EntryService.get_all_entries()
    return jsonify([entry.to_dict() for entry in entries])


@api_bp.route('/health')
def health():
    """Health check endpoint.

    Returns:
        JSON object with status field.
    """
    return jsonify({'status': 'healthy'})
