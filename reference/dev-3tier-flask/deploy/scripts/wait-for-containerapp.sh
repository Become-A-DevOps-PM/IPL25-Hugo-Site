#!/bin/bash
# =============================================================================
# WAIT FOR CONTAINER APP TO BE READY
# =============================================================================
# Polls the Container App health endpoint until it responds.
# Handles cold starts (container scaling from 0 to 1).
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Source central configuration
source "$PROJECT_DIR/config-containerapp.sh"

echo "=== Waiting for Container App ==="
echo ""

# Get Container App FQDN
APP_FQDN=$(get_container_app_fqdn)

if [ -z "$APP_FQDN" ]; then
    echo "ERROR: Could not get Container App FQDN. Is the app deployed?"
    echo "Run ./deploy/deploy-containerapp.sh first."
    exit 1
fi

HEALTH_URL="https://${APP_FQDN}/api/health"

echo "Container App: $CONTAINER_APP"
echo "Health URL:    $HEALTH_URL"
echo ""
echo "Note: First request may trigger cold start (2-5 seconds)."
echo ""

ATTEMPT=1
while [ $ATTEMPT -le $APP_MAX_ATTEMPTS ]; do
    echo -n "Checking health (attempt $ATTEMPT/$APP_MAX_ATTEMPTS)... "

    # Try to get health status
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$HEALTH_URL" 2>/dev/null || echo "000")

    if [ "$HTTP_CODE" = "200" ]; then
        # Verify the response content
        RESPONSE=$(curl -s --max-time 10 "$HEALTH_URL" 2>/dev/null)
        STATUS=$(echo "$RESPONSE" | jq -r '.status' 2>/dev/null || echo "unknown")

        if [ "$STATUS" = "ok" ]; then
            echo "OK!"
            echo ""
            echo "Container App is healthy."
            echo "Response: $RESPONSE"
            exit 0
        fi
    fi

    echo "HTTP $HTTP_CODE"

    if [ $ATTEMPT -lt $APP_MAX_ATTEMPTS ]; then
        echo "Waiting ${APP_POLL_INTERVAL} seconds..."
        sleep $APP_POLL_INTERVAL
    fi

    ATTEMPT=$((ATTEMPT + 1))
done

echo ""
echo "ERROR: Container App did not become healthy within the timeout period."
echo ""
echo "Troubleshooting:"
echo "  1. Check container logs:"
echo "     az containerapp logs show --name $CONTAINER_APP --resource-group $RESOURCE_GROUP"
echo ""
echo "  2. Check revision status:"
echo "     az containerapp revision list --name $CONTAINER_APP --resource-group $RESOURCE_GROUP -o table"
echo ""
exit 1
