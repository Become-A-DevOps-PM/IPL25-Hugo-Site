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
