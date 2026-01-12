#!/bin/bash
# =============================================================================
# DEPLOY FLASK APP TO AZURE CONTAINER APPS
# =============================================================================
# Uses `az containerapp up` with Dockerfile for ODBC driver support.
# Optionally connects to Azure SQL Database if provision-sql.sh was run.
# =============================================================================

set -e

RESOURCE_GROUP="rg-starter-flask"
APP_NAME="starter-flask-app"
LOCATION="swedencentral"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/../application"

echo "=== Deploying Flask app to Azure Container Apps ==="
echo ""

# Check for database URL
DATABASE_URL=""
if [ -f "$SCRIPT_DIR/.database-url" ]; then
    DATABASE_URL=$(cat "$SCRIPT_DIR/.database-url")
    echo "Database: Azure SQL (configured)"
else
    echo "Database: Not configured (form submissions will fail gracefully)"
    echo "          Run ./deploy/provision-sql.sh first to enable database"
fi
echo ""

echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  App Name:       $APP_NAME"
echo "  Location:       $LOCATION"
echo "  Source:         $APP_DIR"
echo ""
echo "This command will:"
echo "  1. Create resource group (if needed)"
echo "  2. Create Azure Container Registry"
echo "  3. Build container image using Dockerfile"
echo "  4. Create Container Apps environment"
echo "  5. Deploy the application"
if [ -n "$DATABASE_URL" ]; then
    echo "  6. Configure DATABASE_URL environment variable"
fi
echo ""

# Generate secret key for Flask
SECRET_KEY=$(openssl rand -hex 32)

# Deploy using az containerapp up (will detect Dockerfile)
echo "Building and deploying (this may take 5-10 minutes)..."
az containerapp up \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --source "$APP_DIR" \
    --ingress external \
    --target-port 5000

# Set environment variables
echo ""
echo "Configuring environment variables..."

if [ -n "$DATABASE_URL" ]; then
    # With database
    az containerapp update \
        --name "$APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --set-env-vars \
            "DATABASE_URL=$DATABASE_URL" \
            "SECRET_KEY=$SECRET_KEY" \
            "FLASK_ENV=production" \
        --output none
else
    # Without database (graceful degradation mode)
    az containerapp update \
        --name "$APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --set-env-vars \
            "SECRET_KEY=$SECRET_KEY" \
            "FLASK_ENV=production" \
        --output none
fi

# Get application URL
APP_URL=$(az containerapp show \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "properties.configuration.ingress.fqdn" \
    -o tsv)

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Application URL: https://$APP_URL"
echo "Form page:       https://$APP_URL/form"
echo "Health check:    https://$APP_URL/health"
echo ""

if [ -z "$DATABASE_URL" ]; then
    echo "Note: Database not configured. Form submissions will show an error."
    echo "      Run ./deploy/provision-sql.sh then redeploy to enable database."
    echo ""
fi

echo "To delete all resources:"
echo "  ./deploy/delete.sh"
echo ""
