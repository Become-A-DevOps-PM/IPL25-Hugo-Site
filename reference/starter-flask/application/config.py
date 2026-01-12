"""Configuration with lazy database initialization."""

import os


class Config:
    """Base configuration."""

    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-change-in-production')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    @classmethod
    def get_database_url(cls):
        """Get database URL. Returns None if not configured."""
        if os.environ.get('USE_SQLITE', '').lower() == 'true':
            return 'sqlite:///notes.db'
        return os.environ.get('DATABASE_URL')


class DevelopmentConfig(Config):
    """Development with SQLite."""

    DEBUG = True

    @classmethod
    def get_database_url(cls):
        return 'sqlite:///notes.db'


class ProductionConfig(Config):
    """Production requires DATABASE_URL."""

    DEBUG = False


class TestingConfig(Config):
    """Testing with in-memory SQLite."""

    TESTING = True

    @classmethod
    def get_database_url(cls):
        return 'sqlite:///:memory:'


config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}
