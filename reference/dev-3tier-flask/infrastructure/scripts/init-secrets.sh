#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"
PARAMS_EXAMPLE="$INFRA_DIR/parameters.example.json"
PARAMS_FILE="$INFRA_DIR/parameters.json"

# Parse arguments
PASSWORD=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --password)
            PASSWORD="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if parameters.json already exists
if [ -f "$PARAMS_FILE" ]; then
    echo "parameters.json already exists. Delete it first to reinitialize."
    exit 0
fi

# Copy template
echo "Creating parameters.json from template..."
cp "$PARAMS_EXAMPLE" "$PARAMS_FILE"

# Generate password if not provided
if [ -z "$PASSWORD" ]; then
    echo "Generating secure password..."
    # Generate 32-char password with alphanumeric chars only
    # Avoids special characters that need URL encoding in DATABASE_URL
    PASSWORD=$(openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | head -c 32)
fi

# Validate password meets Azure requirements
"$SCRIPT_DIR/validate-password.sh" "$PASSWORD"

# Update parameters.json with password (SSH key is passed separately at deploy time)
echo "Updating parameters.json..."
jq --arg pass "$PASSWORD" '.parameters.dbAdminPassword.value = $pass' "$PARAMS_FILE" > "$PARAMS_FILE.tmp"
mv "$PARAMS_FILE.tmp" "$PARAMS_FILE"

echo "Secrets initialized successfully."
echo "  Password: [hidden - stored in parameters.json]"
echo ""
echo "IMPORTANT: parameters.json contains secrets and should NOT be committed to git."
