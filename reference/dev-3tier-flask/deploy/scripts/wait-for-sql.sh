#!/bin/bash
# =============================================================================
# WAIT FOR SQL DATABASE TO BE READY
# =============================================================================
# Polls Azure SQL Database until it's in the "Online" state.
# SQL Database Basic tier is usually ready within 1-2 minutes.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Source central configuration
source "$PROJECT_DIR/config-containerapp.sh"

echo "=== Waiting for SQL Database ==="
echo ""
echo "SQL Server: $SQL_SERVER"
echo "Database:   $SQL_DATABASE"
echo ""

# Check if SQL server exists
if ! az sql server show --name "$SQL_SERVER" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "ERROR: SQL Server '$SQL_SERVER' not found in resource group '$RESOURCE_GROUP'."
    echo "Run ./infrastructure/provision-containerapp.sh first."
    exit 1
fi

ATTEMPT=1
while [ $ATTEMPT -le $SQL_MAX_ATTEMPTS ]; do
    echo -n "Checking SQL Database status (attempt $ATTEMPT/$SQL_MAX_ATTEMPTS)... "

    # Get database status
    STATUS=$(az sql db show \
        --name "$SQL_DATABASE" \
        --server "$SQL_SERVER" \
        --resource-group "$RESOURCE_GROUP" \
        --query "status" \
        -o tsv 2>/dev/null || echo "NotFound")

    if [ "$STATUS" = "Online" ]; then
        echo "Online!"
        echo ""
        echo "SQL Database is ready."
        exit 0
    fi

    echo "$STATUS"

    if [ $ATTEMPT -lt $SQL_MAX_ATTEMPTS ]; then
        echo "Waiting ${SQL_POLL_INTERVAL} seconds..."
        sleep $SQL_POLL_INTERVAL
    fi

    ATTEMPT=$((ATTEMPT + 1))
done

echo ""
echo "ERROR: SQL Database did not become ready within the timeout period."
echo "Check Azure Portal for status: https://portal.azure.com"
exit 1
