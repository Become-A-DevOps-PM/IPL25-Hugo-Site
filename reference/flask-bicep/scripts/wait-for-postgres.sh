#!/bin/bash
set -e
RG="rg-flask-bicep-dev"
SERVER_NAME="psql-flask-bicep-dev"
MAX_ATTEMPTS=40  # 40 * 30s = 20 minutes
ATTEMPT=0

echo "Waiting for PostgreSQL Flexible Server..."
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    STATE=$(az postgres flexible-server show \
        --resource-group $RG \
        --name $SERVER_NAME \
        --query state --output tsv 2>/dev/null || echo "NotFound")

    if [ "$STATE" = "Ready" ]; then
        echo "PostgreSQL is ready."
        exit 0
    fi

    ATTEMPT=$((ATTEMPT + 1))
    echo "  Attempt $ATTEMPT/$MAX_ATTEMPTS - Current state: $STATE (waiting...)"
    sleep 30
done

echo "ERROR: PostgreSQL did not become ready within 20 minutes"
exit 1
