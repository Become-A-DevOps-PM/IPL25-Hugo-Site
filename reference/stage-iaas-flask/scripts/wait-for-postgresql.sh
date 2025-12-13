#!/bin/bash
# =============================================================================
# WAIT FOR POSTGRESQL FLEXIBLE SERVER
# =============================================================================
# Waits for the Azure PostgreSQL Flexible Server to reach "Ready" state.
#
# Why this is needed:
#   - PostgreSQL Flexible Server takes 5-15 minutes to provision
#   - The Bicep deployment returns before the server is fully operational
#   - Database connections will fail until state becomes "Ready"
#
# Polling strategy:
#   - Checks every 30 seconds (PostgreSQL provisioning is slow)
#   - Maximum wait time: 20 minutes (40 attempts x 30 seconds)
#   - Uses Azure CLI to query the server's provisioning state
#
# Possible server states:
#   - Creating: Server is being provisioned
#   - Ready: Server is operational and accepting connections
#   - Updating: Server configuration is being modified
#   - Deleting: Server is being removed
#   - Disabled: Server is stopped
# =============================================================================

set -e

# Source central configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
source "$PROJECT_DIR/config.sh"

# Local configuration (uses values from config.sh)
POLL_INTERVAL=$POSTGRES_POLL_INTERVAL
MAX_ATTEMPTS=$POSTGRES_MAX_ATTEMPTS
ATTEMPT=0

echo "Waiting for PostgreSQL Flexible Server..."

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # Query the server state via Azure CLI
    STATE=$(az postgres flexible-server show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$POSTGRES_SERVER" \
        --query state --output tsv 2>/dev/null || echo "NotFound")

    if [ "$STATE" = "Ready" ]; then
        echo "PostgreSQL is ready."
        exit 0
    fi

    ATTEMPT=$((ATTEMPT + 1))
    echo "  Attempt $ATTEMPT/$MAX_ATTEMPTS - Current state: $STATE (waiting...)"
    sleep $POLL_INTERVAL
done

echo "ERROR: PostgreSQL did not become ready within 20 minutes"
exit 1
