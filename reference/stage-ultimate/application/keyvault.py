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
