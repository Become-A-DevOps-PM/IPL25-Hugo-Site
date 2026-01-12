#!/bin/bash
# =============================================================================
# DEPLOY CONTAINER APP
# =============================================================================
# Creates or updates the Container App with the Flask application.
# Must be run after infrastructure provisioning and image push.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Source central configuration
source "$PROJECT_DIR/config-containerapp.sh"

PARAMS_FILE="$PROJECT_DIR/infrastructure/parameters-containerapp.json"

echo "=== Deploy Container App ==="
echo ""

# -----------------------------------------------------------------------------
# Prerequisites check
# -----------------------------------------------------------------------------
if [ ! -f "$PARAMS_FILE" ]; then
    echo "ERROR: $PARAMS_FILE not found. Run ./infrastructure/provision-containerapp.sh first."
    exit 1
fi

# Get ACR credentials
ACR_LOGIN_SERVER=$(get_acr_login_server)
if [ -z "$ACR_LOGIN_SERVER" ]; then
    echo "ERROR: Could not get ACR login server. Is the infrastructure deployed?"
    exit 1
fi

# Get SQL password from parameters file
SQL_PASSWORD=$(jq -r '.parameters.sqlAdminPassword.value' "$PARAMS_FILE")

# Build connection string
DATABASE_URL=$(build_database_url "$SQL_PASSWORD")

# Get Container Apps Environment ID
CONTAINER_APP_ENV_ID=$(az containerapp env show \
    --name "$CONTAINER_APP_ENV" \
    --resource-group "$RESOURCE_GROUP" \
    --query "id" \
    -o tsv)

if [ -z "$CONTAINER_APP_ENV_ID" ]; then
    echo "ERROR: Could not get Container Apps Environment ID."
    exit 1
fi

# ACR credentials
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query "username" -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)

FULL_IMAGE_NAME="${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "Configuration:"
echo "  Container App:      $CONTAINER_APP"
echo "  Image:              $FULL_IMAGE_NAME"
echo "  SQL Server:         $(get_sql_server_fqdn)"
echo ""

# -----------------------------------------------------------------------------
# Create or Update Container App
# -----------------------------------------------------------------------------
if container_app_exists; then
    echo "Updating existing Container App..."

    az containerapp update \
        --name "$CONTAINER_APP" \
        --resource-group "$RESOURCE_GROUP" \
        --image "$FULL_IMAGE_NAME" \
        --set-env-vars \
            "DATABASE_URL=$DATABASE_URL" \
            "FLASK_ENV=production" \
        --output none

    echo "  Container App updated."
else
    echo "Creating new Container App..."

    az containerapp create \
        --name "$CONTAINER_APP" \
        --resource-group "$RESOURCE_GROUP" \
        --environment "$CONTAINER_APP_ENV" \
        --image "$FULL_IMAGE_NAME" \
        --registry-server "$ACR_LOGIN_SERVER" \
        --registry-username "$ACR_USERNAME" \
        --registry-password "$ACR_PASSWORD" \
        --target-port 5001 \
        --ingress external \
        --min-replicas 0 \
        --max-replicas 3 \
        --cpu 0.5 \
        --memory 1Gi \
        --env-vars \
            "DATABASE_URL=$DATABASE_URL" \
            "FLASK_ENV=production" \
            "SECRET_KEY=$(openssl rand -hex 32)" \
        --output none

    echo "  Container App created."
fi

echo ""

# -----------------------------------------------------------------------------
# Initialize database tables
# -----------------------------------------------------------------------------
echo "Initializing database tables..."

# Wait a moment for the container to start
sleep 10

# Execute database initialization via az containerapp exec
az containerapp exec \
    --name "$CONTAINER_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --command "python" -- -c "
from app import create_app
from app.extensions import db
app = create_app()
with app.app_context():
    db.create_all()
    print('Database tables initialized')
" 2>/dev/null || echo "  Note: Database init may need manual execution if container is scaling up."

echo ""

# -----------------------------------------------------------------------------
# Get application URL
# -----------------------------------------------------------------------------
APP_FQDN=$(get_container_app_fqdn)

echo "=== Deployment Complete ==="
echo ""
echo "Application URL: https://${APP_FQDN}/"
echo "Health check:    https://${APP_FQDN}/api/health"
echo ""
echo "Next steps:"
echo "  1. Wait for app to respond:  ./deploy/scripts/wait-for-containerapp.sh"
echo "  2. Create admin user:        See OPERATIONS-RUNBOOK-containerapp.md"
echo "  3. Run verification tests:   ./deploy/scripts/verification-tests-containerapp.sh"
echo ""
