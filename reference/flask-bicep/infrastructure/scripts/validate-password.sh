#!/bin/bash
# Validates password meets Azure PostgreSQL requirements
# Can be called with password as argument, or reads from parameters.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"
PARAMS_FILE="$INFRA_DIR/parameters.json"

# Get password from argument or parameters.json
if [ -n "$1" ]; then
    PASSWORD="$1"
elif [ -f "$PARAMS_FILE" ]; then
    PASSWORD=$(jq -r '.parameters.dbAdminPassword.value' "$PARAMS_FILE")
else
    echo "ERROR: No password provided and parameters.json not found"
    exit 1
fi

# Check length (8-128 characters)
LENGTH=${#PASSWORD}
if [ $LENGTH -lt 8 ] || [ $LENGTH -gt 128 ]; then
    echo "ERROR: Password must be 8-128 characters (got $LENGTH)"
    exit 1
fi

# Count character categories present
CATEGORIES=0

# Check for uppercase
if [[ "$PASSWORD" =~ [A-Z] ]]; then
    CATEGORIES=$((CATEGORIES + 1))
fi

# Check for lowercase
if [[ "$PASSWORD" =~ [a-z] ]]; then
    CATEGORIES=$((CATEGORIES + 1))
fi

# Check for numbers
if [[ "$PASSWORD" =~ [0-9] ]]; then
    CATEGORIES=$((CATEGORIES + 1))
fi

# Check for special characters
if [[ "$PASSWORD" =~ [^A-Za-z0-9] ]]; then
    CATEGORIES=$((CATEGORIES + 1))
fi

# Must have at least 3 of 4 categories
if [ $CATEGORIES -lt 3 ]; then
    echo "ERROR: Password must contain characters from at least 3 of these categories:"
    echo "  - Uppercase letters (A-Z)"
    echo "  - Lowercase letters (a-z)"
    echo "  - Numbers (0-9)"
    echo "  - Special characters (!@#\$%^&* etc.)"
    echo "  Current password has only $CATEGORIES categories"
    exit 1
fi

echo "Password validation: OK"
exit 0
