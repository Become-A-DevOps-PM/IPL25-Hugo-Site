#!/bin/bash
# =============================================================================
# DEPLOY FLASK APP TO AZURE CONTAINER APPS
# =============================================================================
# Uses `az containerapp up` with Oryx++ for automatic build from source.
# No Dockerfile required - Oryx++ auto-detects Python/Flask.
# =============================================================================

set -e

RESOURCE_GROUP="rg-starter-flask"
APP_NAME="starter-flask-app"
LOCATION="swedencentral"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/../application"

echo "=== Deploying Flask app to Azure Container Apps ==="
echo ""
echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  App Name:       $APP_NAME"
echo "  Location:       $LOCATION"
echo "  Source:         $APP_DIR"
echo ""
echo "This command will automatically:"
echo "  1. Create resource group (if needed)"
echo "  2. Create Azure Container Registry"
echo "  3. Build container image using Oryx++ (no Dockerfile)"
echo "  4. Create Container Apps environment"
echo "  5. Deploy the application"
echo ""

az containerapp up \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --source "$APP_DIR" \
    --ingress external \
    --target-port 5000

echo ""
echo "=== Retrieving Application URL ==="

APP_URL=$(az containerapp show \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "properties.configuration.ingress.fqdn" \
    -o tsv)

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Application URL: https://$APP_URL"
echo "Health check:    https://$APP_URL/health"
echo ""
echo "To delete all resources:"
echo "  ./deploy/delete.sh"
echo ""
