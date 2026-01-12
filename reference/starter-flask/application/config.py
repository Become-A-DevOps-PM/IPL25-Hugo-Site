"""
Configuration with lazy database initialization.
Supports graceful degradation when database is unavailable.
"""

import os


class Config:
    """Base configuration with environment variable fallback."""

    # Flask settings
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-change-in-production')

    # SQLAlchemy settings
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Feature flag for testing/development
    USE_SQLITE = os.environ.get('USE_SQLITE', 'false').lower() == 'true'

    @classmethod
    def get_database_url(cls):
        """
        Get database URL with graceful degradation.

        Priority:
        1. USE_SQLITE=true -> SQLite
        2. DATABASE_URL environment variable -> Azure SQL
        3. No DATABASE_URL -> None (graceful degradation)
        """
        if cls.USE_SQLITE:
            return 'sqlite:///notes.db'

        url = os.environ.get('DATABASE_URL')
        if url:
            return url

        # No database configured - return None for graceful degradation
        return None


class DevelopmentConfig(Config):
    """Development with SQLite fallback."""

    DEBUG = True
    USE_SQLITE = True  # Always use SQLite in development


class ProductionConfig(Config):
    """Production requires DATABASE_URL."""

    DEBUG = False


class TestingConfig(Config):
    """Testing with in-memory SQLite."""

    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    USE_SQLITE = True


config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}
