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
