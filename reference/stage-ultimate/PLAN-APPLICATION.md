# Application Plan: Stage Ultimate

## Overview

This document describes the Flask contact form application with Key Vault integration, transparent secret loading, and SQLite/PostgreSQL switching with visual indicators.

## Application Architecture

```
application/
├── app.py                    # Application factory
├── config.py                 # Configuration with Key Vault integration
├── models.py                 # SQLAlchemy models
├── routes.py                 # Route handlers (Blueprint)
├── validators.py             # Input validation
├── keyvault.py              # Key Vault SDK integration
├── wsgi.py                  # Gunicorn entry point
├── requirements.txt         # Production dependencies
├── requirements-dev.txt     # Development dependencies
├── .env.example             # Template for local development
│
├── templates/
│   ├── base.html            # Base template with database indicator
│   ├── home.html            # Home page
│   ├── contact.html         # Contact form
│   ├── thank_you.html       # Form submission confirmation
│   ├── messages.html        # Message list
│   └── error.html           # Error page
│
└── static/
    └── style.css            # Styles including test mode banner
```

## Key Features

### 1. Transparent Key Vault Integration

The application seamlessly loads secrets from Azure Key Vault when running in production (with managed identity) or falls back to environment variables for local development.

**Priority order:**
1. Environment variable (for local override)
2. Azure Key Vault (production with managed identity)
3. Default value (SQLite for database)

### 2. Database Mode Indicator

When running with SQLite (test mode), the UI displays a prominent banner:

```
⚠️ TEST MODE - Using SQLite database. Configure DATABASE_URL for production.
```

This ensures students know the application isn't properly configured for production.

### 3. Feature Flag for Database

```python
# config.py
USE_SQLITE = os.environ.get('USE_SQLITE', 'false').lower() == 'true'
```

Even in production, you can force SQLite for testing by setting `USE_SQLITE=true`.

---

## File Specifications

### requirements.txt

```
# Core Flask
flask==3.0.*
gunicorn==21.*

# Database
flask-sqlalchemy==3.1.*
psycopg2-binary==2.9.*

# Azure Key Vault
azure-identity==1.15.*
azure-keyvault-secrets==4.8.*

# Security
flask-wtf==1.2.*
```

### requirements-dev.txt

```
-r requirements.txt

# Development tools
pytest==8.*
pytest-cov==4.*
black==24.*
flake8==7.*
```

### .env.example

```bash
# Flask Configuration
FLASK_ENV=development
SECRET_KEY=dev-secret-change-in-production

# Database Configuration
# Leave empty for SQLite (default for local development)
# DATABASE_URL=postgresql://user:pass@localhost:5432/contactform

# Azure Key Vault (optional for local development)
# AZURE_KEYVAULT_URL=https://flask-ultimate-kv-xxx.vault.azure.net/

# Force SQLite even when DATABASE_URL is set (for testing)
# USE_SQLITE=true
```

---

## Module Specifications

### keyvault.py

```python
"""
Azure Key Vault integration for transparent secret loading.

Usage:
    from keyvault import get_secret

    # Gets from env var, then Key Vault, then default
    database_url = get_secret('database-url', 'sqlite:///messages.db')
"""

import os
import logging

logger = logging.getLogger(__name__)

# Lazy-loaded clients
_credential = None
_secret_client = None


def _get_client():
    """Get or create Key Vault client."""
    global _credential, _secret_client

    vault_url = os.environ.get('AZURE_KEYVAULT_URL')
    if not vault_url:
        return None

    if _secret_client is None:
        try:
            from azure.identity import DefaultAzureCredential
            from azure.keyvault.secrets import SecretClient

            _credential = DefaultAzureCredential()
            _secret_client = SecretClient(vault_url=vault_url, credential=_credential)
            logger.info(f"Key Vault client initialized for {vault_url}")
        except Exception as e:
            logger.warning(f"Failed to initialize Key Vault client: {e}")
            return None

    return _secret_client


def get_secret(secret_name: str, default: str = None) -> str:
    """
    Get secret value with fallback chain.

    Priority:
    1. Environment variable (secret_name with - replaced by _ and uppercased)
    2. Azure Key Vault
    3. Default value

    Args:
        secret_name: Name of the secret (e.g., 'database-url')
        default: Default value if not found anywhere

    Returns:
        Secret value or default
    """
    # Convert secret name to env var format: database-url -> DATABASE_URL
    env_name = secret_name.upper().replace('-', '_')

    # 1. Check environment variable first
    env_value = os.environ.get(env_name)
    if env_value:
        logger.debug(f"Secret '{secret_name}' loaded from environment variable")
        return env_value

    # 2. Try Key Vault
    client = _get_client()
    if client:
        try:
            secret = client.get_secret(secret_name)
            logger.debug(f"Secret '{secret_name}' loaded from Key Vault")
            return secret.value
        except Exception as e:
            logger.warning(f"Failed to get secret '{secret_name}' from Key Vault: {e}")

    # 3. Return default
    if default is not None:
        logger.debug(f"Secret '{secret_name}' using default value")
    return default
```

### config.py

```python
"""
Application configuration with Key Vault integration.
"""

import os
from keyvault import get_secret


class Config:
    """Base configuration."""

    # Flask
    SECRET_KEY = get_secret('secret-key', 'dev-secret-change-in-production')

    # SQLAlchemy
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Feature flag: force SQLite
    USE_SQLITE = os.environ.get('USE_SQLITE', 'false').lower() == 'true'

    @classmethod
    def get_database_url(cls):
        """Get database URL with fallback to SQLite."""
        if cls.USE_SQLITE:
            return 'sqlite:///messages.db'

        url = get_secret('database-url')
        if url:
            return url

        # Default to SQLite if no database configured
        return 'sqlite:///messages.db'

    @classmethod
    def is_sqlite(cls):
        """Check if using SQLite database."""
        url = cls.get_database_url()
        return url.startswith('sqlite:')


class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True
    TESTING = False


class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False
    TESTING = False


class TestingConfig(Config):
    """Testing configuration."""
    DEBUG = True
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    USE_SQLITE = True


# Configuration mapping
config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}
```

### models.py

```python
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
```

### validators.py

```python
"""
Input validation functions.
"""

import re
from typing import Tuple, Optional

# Validation constants
MAX_NAME_LENGTH = 100
MAX_EMAIL_LENGTH = 120
MAX_MESSAGE_LENGTH = 5000
EMAIL_PATTERN = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')


def validate_contact_form(
    name: str,
    email: str,
    message: str
) -> Tuple[bool, Optional[str]]:
    """
    Validate contact form input.

    Args:
        name: Sender's name
        email: Sender's email
        message: Message content

    Returns:
        Tuple of (is_valid, error_message)
        error_message is None if valid
    """
    # Name validation
    if not name or not name.strip():
        return False, "Name is required"
    name = name.strip()
    if len(name) > MAX_NAME_LENGTH:
        return False, f"Name must be {MAX_NAME_LENGTH} characters or less"

    # Email validation
    if not email or not email.strip():
        return False, "Email is required"
    email = email.strip()
    if len(email) > MAX_EMAIL_LENGTH:
        return False, f"Email must be {MAX_EMAIL_LENGTH} characters or less"
    if not EMAIL_PATTERN.match(email):
        return False, "Please enter a valid email address"

    # Message validation
    if not message or not message.strip():
        return False, "Message is required"
    message = message.strip()
    if len(message) > MAX_MESSAGE_LENGTH:
        return False, f"Message must be {MAX_MESSAGE_LENGTH} characters or less"

    return True, None
```

### routes.py

```python
"""
Route handlers using Flask Blueprint.
"""

import logging
from flask import Blueprint, render_template, request, redirect, url_for, flash, current_app
from .models import db, Message
from .validators import validate_contact_form

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
    from .config import Config

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
```

### app.py

```python
"""
Flask application factory.
"""

import os
import logging
from flask import Flask
from config import config_by_name, Config
from models import db
from routes import bp


def create_app(config_name: str = None) -> Flask:
    """
    Create and configure the Flask application.

    Args:
        config_name: Configuration name ('development', 'production', 'testing')

    Returns:
        Configured Flask application
    """
    # Determine configuration
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'development')

    config_class = config_by_name.get(config_name, config_by_name['default'])

    # Create app
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Set database URL
    app.config['SQLALCHEMY_DATABASE_URI'] = config_class.get_database_url()

    # Store database type for templates
    app.config['IS_SQLITE'] = config_class.is_sqlite()

    # Configure logging
    logging.basicConfig(
        level=logging.DEBUG if app.config['DEBUG'] else logging.INFO,
        format='%(asctime)s %(levelname)s %(name)s: %(message)s'
    )

    logger = logging.getLogger(__name__)
    logger.info(f"Starting application with {config_name} configuration")
    logger.info(f"Database type: {'SQLite' if app.config['IS_SQLITE'] else 'PostgreSQL'}")

    # Initialize extensions
    db.init_app(app)

    # Register blueprints
    app.register_blueprint(bp)

    # Create database tables
    with app.app_context():
        db.create_all()
        logger.info("Database tables created/verified")

    # Context processor for templates
    @app.context_processor
    def inject_database_info():
        return {
            'is_sqlite': app.config['IS_SQLITE'],
            'database_type': 'SQLite' if app.config['IS_SQLITE'] else 'PostgreSQL'
        }

    return app


# For direct running: python -m app
if __name__ == '__main__':
    application = create_app()
    application.run(host='0.0.0.0', port=5001, debug=True)
```

### wsgi.py

```python
"""
WSGI entry point for Gunicorn.

Usage:
    gunicorn --workers 2 --bind 0.0.0.0:5001 wsgi:application
"""

from app import create_app

application = create_app()

if __name__ == '__main__':
    application.run()
```

---

## Templates

### templates/base.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}Flask Contact Form{% endblock %}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    {% if is_sqlite %}
    <div class="test-mode-banner">
        ⚠️ TEST MODE - Using SQLite database. Configure DATABASE_URL for production.
    </div>
    {% endif %}

    <nav class="navbar">
        <div class="nav-container">
            <a href="{{ url_for('main.home') }}" class="nav-brand">Flask Contact Form</a>
            <div class="nav-links">
                <a href="{{ url_for('main.home') }}">Home</a>
                <a href="{{ url_for('main.contact') }}">Contact</a>
                <a href="{{ url_for('main.messages') }}">Messages</a>
            </div>
        </div>
    </nav>

    <main class="container">
        {% with messages = get_flashed_messages(with_categories=true) %}
            {% if messages %}
                {% for category, message in messages %}
                    <div class="alert alert-{{ category }}">{{ message }}</div>
                {% endfor %}
            {% endif %}
        {% endwith %}

        {% block content %}{% endblock %}
    </main>

    <footer class="footer">
        <div class="container">
            <p>Database: {{ database_type }} |
               <a href="{{ url_for('main.health') }}">Health Check</a></p>
        </div>
    </footer>
</body>
</html>
```

### templates/home.html

```html
{% extends "base.html" %}

{% block title %}Welcome - Flask Contact Form{% endblock %}

{% block content %}
<div class="hero">
    <h1>Welcome</h1>
    <p>This is a Flask application demonstrating database persistence with Key Vault integration.</p>

    <div class="hero-actions">
        <a href="{{ url_for('main.contact') }}" class="btn btn-primary">Contact Us</a>
        <a href="{{ url_for('main.messages') }}" class="btn btn-secondary">View Messages</a>
    </div>
</div>

<div class="features">
    <div class="feature">
        <h3>📝 Contact Form</h3>
        <p>Submit messages through a validated contact form.</p>
    </div>
    <div class="feature">
        <h3>💾 Database Persistence</h3>
        <p>Messages are stored in {{ database_type }}.</p>
    </div>
    <div class="feature">
        <h3>🔐 Secure Configuration</h3>
        <p>Secrets managed via Azure Key Vault in production.</p>
    </div>
</div>
{% endblock %}
```

### templates/contact.html

```html
{% extends "base.html" %}

{% block title %}Contact Us - Flask Contact Form{% endblock %}

{% block content %}
<div class="form-container">
    <h1>Contact Us</h1>
    <p>Fill out the form below to send us a message.</p>

    <form method="POST" action="{{ url_for('main.contact') }}" class="contact-form">
        <div class="form-group">
            <label for="name">Name <span class="required">*</span></label>
            <input type="text" id="name" name="name"
                   value="{{ name|default('', true) }}"
                   required maxlength="100"
                   placeholder="Your name">
        </div>

        <div class="form-group">
            <label for="email">Email <span class="required">*</span></label>
            <input type="email" id="email" name="email"
                   value="{{ email|default('', true) }}"
                   required maxlength="120"
                   placeholder="your.email@example.com">
        </div>

        <div class="form-group">
            <label for="message">Message <span class="required">*</span></label>
            <textarea id="message" name="message"
                      required maxlength="5000" rows="6"
                      placeholder="Your message...">{{ message|default('', true) }}</textarea>
        </div>

        <button type="submit" class="btn btn-primary">Send Message</button>
    </form>
</div>
{% endblock %}
```

### templates/thank_you.html

```html
{% extends "base.html" %}

{% block title %}Thank You - Flask Contact Form{% endblock %}

{% block content %}
<div class="thank-you">
    <h1>Thank You, {{ name }}!</h1>
    <p>Your message has been received and saved to the database.</p>

    <div class="thank-you-actions">
        <a href="{{ url_for('main.messages') }}" class="btn btn-primary">View All Messages</a>
        <a href="{{ url_for('main.contact') }}" class="btn btn-secondary">Send Another</a>
    </div>
</div>
{% endblock %}
```

### templates/messages.html

```html
{% extends "base.html" %}

{% block title %}Messages - Flask Contact Form{% endblock %}

{% block content %}
<div class="messages-container">
    <h1>All Messages</h1>

    {% if messages %}
        <p class="message-count">{{ messages|length }} message(s) found</p>

        {% for msg in messages %}
        <div class="message-card">
            <div class="message-header">
                <h3>{{ msg.name }}</h3>
                <span class="message-date">{{ msg.created_at.strftime('%Y-%m-%d %H:%M') if msg.created_at else 'Unknown' }}</span>
            </div>
            <p class="message-email">{{ msg.email }}</p>
            <p class="message-content">{{ msg.message }}</p>
        </div>
        {% endfor %}
    {% else %}
        <div class="empty-state">
            <p>No messages yet.</p>
            <a href="{{ url_for('main.contact') }}" class="btn btn-primary">Send the first one!</a>
        </div>
    {% endif %}
</div>
{% endblock %}
```

### templates/error.html

```html
{% extends "base.html" %}

{% block title %}Error - Flask Contact Form{% endblock %}

{% block content %}
<div class="error-container">
    <h1>Oops! Something went wrong.</h1>
    <p>{{ error_message|default('An unexpected error occurred.', true) }}</p>

    <div class="error-actions">
        <a href="{{ url_for('main.home') }}" class="btn btn-primary">Go Home</a>
    </div>
</div>
{% endblock %}
```

---

## Static Files

### static/style.css

```css
/* Reset and base styles */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
    line-height: 1.6;
    color: #333;
    background-color: #f5f5f5;
}

/* Test mode banner */
.test-mode-banner {
    background-color: #ff9800;
    color: #000;
    text-align: center;
    padding: 10px;
    font-weight: bold;
    position: sticky;
    top: 0;
    z-index: 1000;
}

/* Navigation */
.navbar {
    background-color: #2c3e50;
    padding: 1rem 0;
}

.nav-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.nav-brand {
    color: #fff;
    font-size: 1.5rem;
    font-weight: bold;
    text-decoration: none;
}

.nav-links a {
    color: #ecf0f1;
    text-decoration: none;
    margin-left: 20px;
    transition: color 0.3s;
}

.nav-links a:hover {
    color: #3498db;
}

/* Container */
.container {
    max-width: 800px;
    margin: 0 auto;
    padding: 40px 20px;
}

/* Alerts */
.alert {
    padding: 15px;
    margin-bottom: 20px;
    border-radius: 4px;
}

.alert-error {
    background-color: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
}

.alert-success {
    background-color: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
}

/* Hero section */
.hero {
    text-align: center;
    padding: 60px 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff;
    border-radius: 8px;
    margin-bottom: 40px;
}

.hero h1 {
    font-size: 2.5rem;
    margin-bottom: 20px;
}

.hero p {
    font-size: 1.2rem;
    margin-bottom: 30px;
    opacity: 0.9;
}

.hero-actions {
    display: flex;
    gap: 15px;
    justify-content: center;
}

/* Features */
.features {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
}

.feature {
    background: #fff;
    padding: 30px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.feature h3 {
    margin-bottom: 10px;
}

/* Buttons */
.btn {
    display: inline-block;
    padding: 12px 24px;
    border-radius: 4px;
    text-decoration: none;
    font-weight: 600;
    cursor: pointer;
    border: none;
    transition: transform 0.2s, box-shadow 0.2s;
}

.btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}

.btn-primary {
    background-color: #3498db;
    color: #fff;
}

.btn-primary:hover {
    background-color: #2980b9;
}

.btn-secondary {
    background-color: #95a5a6;
    color: #fff;
}

.btn-secondary:hover {
    background-color: #7f8c8d;
}

/* Forms */
.form-container {
    background: #fff;
    padding: 40px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.form-container h1 {
    margin-bottom: 10px;
}

.form-container > p {
    color: #666;
    margin-bottom: 30px;
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
}

.required {
    color: #e74c3c;
}

.form-group input,
.form-group textarea {
    width: 100%;
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
    transition: border-color 0.3s;
}

.form-group input:focus,
.form-group textarea:focus {
    outline: none;
    border-color: #3498db;
}

/* Thank you page */
.thank-you {
    text-align: center;
    padding: 60px 20px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.thank-you h1 {
    color: #27ae60;
    margin-bottom: 20px;
}

.thank-you-actions {
    margin-top: 30px;
    display: flex;
    gap: 15px;
    justify-content: center;
}

/* Messages list */
.messages-container h1 {
    margin-bottom: 10px;
}

.message-count {
    color: #666;
    margin-bottom: 20px;
}

.message-card {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    margin-bottom: 15px;
}

.message-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
}

.message-header h3 {
    color: #2c3e50;
}

.message-date {
    color: #999;
    font-size: 0.9rem;
}

.message-email {
    color: #3498db;
    margin-bottom: 10px;
    font-size: 0.95rem;
}

.message-content {
    color: #555;
    line-height: 1.6;
}

/* Empty state */
.empty-state {
    text-align: center;
    padding: 60px 20px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.empty-state p {
    color: #666;
    margin-bottom: 20px;
}

/* Error page */
.error-container {
    text-align: center;
    padding: 60px 20px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.error-container h1 {
    color: #e74c3c;
    margin-bottom: 20px;
}

.error-actions {
    margin-top: 30px;
}

/* Footer */
.footer {
    text-align: center;
    padding: 20px;
    background-color: #2c3e50;
    color: #ecf0f1;
    margin-top: 40px;
}

.footer a {
    color: #3498db;
}

/* Responsive */
@media (max-width: 600px) {
    .hero h1 {
        font-size: 2rem;
    }

    .hero-actions,
    .thank-you-actions {
        flex-direction: column;
    }

    .nav-container {
        flex-direction: column;
        gap: 15px;
    }

    .nav-links a {
        margin-left: 10px;
        margin-right: 10px;
    }
}
```

---

## Local Development Instructions

### Initial Setup

```bash
# Navigate to application directory
cd reference/stage-ultimate/application

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy environment template
cp .env.example .env
```

### Running Locally with SQLite (Default)

```bash
# Simply run the application - SQLite is the default
python -m flask --app app run --host=0.0.0.0 --port=5001

# Or with Gunicorn
gunicorn --workers 2 --bind 0.0.0.0:5001 wsgi:application
```

The application will:
- Create `messages.db` in the application directory
- Display the orange "TEST MODE" banner
- Show "Database: SQLite" in the footer

### Running with Local PostgreSQL

```bash
# Option 1: Docker
docker run --name flask-postgres \
  -e POSTGRES_USER=flaskadmin \
  -e POSTGRES_PASSWORD=localdev \
  -e POSTGRES_DB=contactform \
  -p 5432:5432 \
  -d postgres:17

# Set environment variable and run
DATABASE_URL='postgresql://flaskadmin:localdev@localhost:5432/contactform' \
  python -m flask --app app run --host=0.0.0.0 --port=5001
```

The application will:
- Connect to PostgreSQL
- NOT display the test mode banner
- Show "Database: PostgreSQL" in the footer

### Forcing SQLite in Any Environment

```bash
# Even with DATABASE_URL set, force SQLite
USE_SQLITE=true python -m flask --app app run --port=5001
```

### Testing Key Vault Integration (If Azure CLI Authenticated)

```bash
# Set Key Vault URL
export AZURE_KEYVAULT_URL='https://flask-ultimate-kv-xxx.vault.azure.net/'

# Run application - it will try to fetch secrets from Key Vault
python -m flask --app app run --port=5001
```

---

## Verification Checklist

### Local SQLite Mode
- [ ] Application starts without errors
- [ ] Orange "TEST MODE" banner visible
- [ ] Footer shows "Database: SQLite"
- [ ] Contact form accepts submissions
- [ ] Messages page displays submissions
- [ ] Data persists after restart
- [ ] Health check shows `database_type: sqlite`

### Local PostgreSQL Mode
- [ ] Application connects to PostgreSQL
- [ ] No test mode banner
- [ ] Footer shows "Database: PostgreSQL"
- [ ] All form functionality works
- [ ] Data persists in PostgreSQL
- [ ] Health check shows `database_type: postgresql`

### Input Validation
- [ ] Empty name rejected
- [ ] Invalid email rejected
- [ ] Empty message rejected
- [ ] Long inputs rejected (>100 name, >120 email, >5000 message)
- [ ] Error messages display correctly

### Key Vault Integration (Production)
- [ ] Secrets loaded from Key Vault when AZURE_KEYVAULT_URL set
- [ ] Environment variables override Key Vault
- [ ] Graceful fallback when Key Vault unavailable
