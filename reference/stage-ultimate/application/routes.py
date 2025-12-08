"""
Route handlers using Flask Blueprint.
"""

import logging
from flask import Blueprint, render_template, request, redirect, url_for, flash, current_app
from models import db, Message
from validators import validate_contact_form

logger = logging.getLogger(__name__)
bp = Blueprint('main', __name__)


@bp.route('/')
def home():
    """Home page."""
    return render_template('home.html')


@bp.route('/contact', methods=['GET', 'POST'])
def contact():
    """Contact form."""
    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        email = request.form.get('email', '').strip()
        message_text = request.form.get('message', '').strip()

        # Validate input
        is_valid, error = validate_contact_form(name, email, message_text)
        if not is_valid:
            flash(error, 'error')
            return render_template(
                'contact.html',
                name=name,
                email=email,
                message=message_text
            )

        # Save to database
        try:
            new_message = Message(
                name=name,
                email=email,
                message=message_text,
                ip_address=request.remote_addr,
                user_agent=str(request.user_agent)[:256] if request.user_agent else None
            )
            db.session.add(new_message)
            db.session.commit()

            logger.info(f"New message from {email} (IP: {request.remote_addr})")
            return render_template('thank_you.html', name=name)

        except Exception as e:
            db.session.rollback()
            logger.error(f"Database error saving message: {e}")
            flash("An error occurred. Please try again.", 'error')
            return render_template(
                'contact.html',
                name=name,
                email=email,
                message=message_text
            )

    return render_template('contact.html')


@bp.route('/messages')
def messages():
    """Display all messages."""
    try:
        all_messages = Message.query.order_by(Message.created_at.desc()).all()
        return render_template('messages.html', messages=all_messages)
    except Exception as e:
        logger.error(f"Error fetching messages: {e}")
        flash("Error loading messages.", 'error')
        return render_template('messages.html', messages=[])


@bp.route('/health')
def health():
    """Health check endpoint for monitoring."""
    from config import Config

    health_status = {
        'status': 'healthy',
        'database': 'unknown',
        'database_type': 'sqlite' if Config.is_sqlite() else 'postgresql'
    }

    try:
        # Verify database connectivity
        db.session.execute(db.text('SELECT 1'))
        health_status['database'] = 'connected'
        return health_status, 200
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        health_status['status'] = 'unhealthy'
        health_status['database'] = 'disconnected'
        health_status['error'] = str(e)
        return health_status, 503
