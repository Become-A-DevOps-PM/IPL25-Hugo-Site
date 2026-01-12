"""Configuration classes for different environments."""

import os


class Config:
    """Base configuration."""
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-change-in-production')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    @classmethod
    def get_database_url(cls):
        if os.environ.get('USE_SQLITE', '').lower() == 'true':
            return 'sqlite:///notes.db'
        return os.environ.get('DATABASE_URL')


class LocalConfig(Config):
    """Local development on your machine. Uses SQLite."""
    DEBUG = True

    @classmethod
    def get_database_url(cls):
        return 'sqlite:///notes.db'


class AzureConfig(Config):
    """Deployed to Azure. Requires DATABASE_URL environment variable."""
    DEBUG = False


class TestSuiteConfig(Config):
    """Automated test suite (pytest). Uses in-memory SQLite."""
    TESTING = True

    @classmethod
    def get_database_url(cls):
        return 'sqlite:///:memory:'


config_by_name = {
    'local': LocalConfig,
    'azure': AzureConfig,
    'testing': TestSuiteConfig,
    # Aliases for compatibility
    'development': LocalConfig,
    'production': AzureConfig,
    'default': LocalConfig
}
