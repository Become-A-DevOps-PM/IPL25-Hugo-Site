"""Configuration classes for different environments."""

import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SQLITE_PATH = f"sqlite:///{os.path.join(BASE_DIR, 'notes.db')}"


class Config:
    """Base configuration."""
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-change-in-production')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    @classmethod
    def get_database_url(cls):
        if os.environ.get('USE_SQLITE', '').lower() == 'true':
            return SQLITE_PATH
        return os.environ.get('DATABASE_URL')


class LocalConfig(Config):
    """Local development on your machine. Uses SQLite."""
    DEBUG = True

    @classmethod
    def get_database_url(cls):
        return SQLITE_PATH


class AzureConfig(Config):
    """Deployed to Azure. Requires DATABASE_URL for Azure SQL Database."""
    DEBUG = False


class PytestConfig(Config):
    """Automated test suite (pytest). Uses in-memory SQLite."""
    TESTING = True

    @classmethod
    def get_database_url(cls):
        return 'sqlite:///:memory:'


config_by_name = {
    'local': LocalConfig,
    'azure': AzureConfig,
    'pytest': PytestConfig,
    'default': LocalConfig
}
