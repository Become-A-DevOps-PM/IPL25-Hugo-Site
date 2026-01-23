"""
Subscription service - handles validation and business logic for subscriptions.

This service sits between the presentation layer (routes) and the data layer
(repositories). It validates input, applies business rules, and prepares data
for storage.
"""

import re
from datetime import datetime, timezone


class SubscriptionService:
    """Service for handling subscription-related business logic."""

    # Email regex pattern for validation
    EMAIL_PATTERN = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

    def validate_email(self, email: str) -> tuple[bool, str]:
        """
        Validate email format.

        Args:
            email: The email address to validate

        Returns:
            Tuple of (is_valid, error_message)
            If valid, error_message is empty string
        """
        if not email:
            return False, "Email is required"

        if not email.strip():
            return False, "Email is required"

        if not re.match(self.EMAIL_PATTERN, email.strip()):
            return False, "Invalid email format"

        return True, ""

    def normalize_email(self, email: str) -> str:
        """
        Normalize email address.

        - Converts to lowercase
        - Strips leading/trailing whitespace

        Args:
            email: The email address to normalize

        Returns:
            Normalized email address
        """
        return email.lower().strip()

    def normalize_name(self, name: str | None) -> str:
        """
        Normalize name field.

        - Strips leading/trailing whitespace
        - Returns 'Subscriber' if empty or None

        Args:
            name: The name to normalize

        Returns:
            Normalized name or default value
        """
        if not name or not name.strip():
            return "Subscriber"
        return name.strip()

    def process_subscription(self, email: str, name: str | None) -> dict:
        """
        Process and prepare subscription data.

        Validates, normalizes, and packages data for storage.

        Args:
            email: The subscriber's email address
            name: The subscriber's name (optional)

        Returns:
            Dictionary with processed subscription data

        Raises:
            ValueError: If email validation fails
        """
        # Validate first
        is_valid, error = self.validate_email(email)
        if not is_valid:
            raise ValueError(error)

        # Normalize and package
        return {
            "email": self.normalize_email(email),
            "name": self.normalize_name(name),
            "subscribed_at": datetime.now(timezone.utc).isoformat(),
        }
