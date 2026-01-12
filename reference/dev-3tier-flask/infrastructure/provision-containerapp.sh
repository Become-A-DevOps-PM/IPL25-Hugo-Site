#!/bin/bash
# =============================================================================
# CONTAINER APPS INFRASTRUCTURE PROVISIONING
# =============================================================================
# Provisions Azure infrastructure for Container Apps deployment:
# - Resource Group
# - Container Registry
# - Container Apps Environment
# - SQL Database (Basic tier)
#
# The Container App itself is deployed separately after the image is pushed.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Source central configuration
source "$PROJECT_DIR/config-containerapp.sh"

# Local configuration
PARAMS_FILE="$SCRIPT_DIR/parameters-containerapp.json"

echo "=== Container Apps Infrastructure Provisioning ==="
echo ""

# -----------------------------------------------------------------------------
# Prerequisites check
# -----------------------------------------------------------------------------
echo "Checking prerequisites..."

if ! command -v az &> /dev/null; then
    echo "ERROR: Azure CLI not found. Install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "ERROR: jq not found. Install with: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker not found. Install from https://docs.docker.com/get-docker/"
    exit 1
fi

# Check Azure login
if ! az account show &> /dev/null; then
    echo "ERROR: Not logged in to Azure. Run: az login"
    exit 1
fi

echo "  Prerequisites OK."
echo ""

# -----------------------------------------------------------------------------
# Initialize parameters if needed
# -----------------------------------------------------------------------------
if [ ! -f "$PARAMS_FILE" ]; then
    echo "Creating parameters file..."

    # Generate secure password
    SQL_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=' | head -c 20)
    # Ensure password meets SQL Server complexity requirements
    SQL_PASSWORD="${SQL_PASSWORD}Aa1!"

    cat > "$PARAMS_FILE" << EOF
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "sqlAdminUsername": {
      "value": "$SQL_ADMIN_USER"
    },
    "sqlAdminPassword": {
      "value": "$SQL_PASSWORD"
    },
    "databaseName": {
      "value": "$SQL_DATABASE"
    }
  }
}
EOF

    echo "  Created $PARAMS_FILE with generated SQL password."
    echo "  IMPORTANT: This file contains secrets. Never commit to git."
    echo ""
fi

# -----------------------------------------------------------------------------
# Create resource group
# -----------------------------------------------------------------------------
echo "Creating resource group '$RESOURCE_GROUP' in '$LOCATION'..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
echo "  Resource group created."
echo ""

# -----------------------------------------------------------------------------
# Deploy Bicep templates
# -----------------------------------------------------------------------------
echo "Deploying infrastructure (this takes 3-5 minutes)..."

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "$SCRIPT_DIR/main-containerapp.bicep" \
    --parameters "$PARAMS_FILE" \
    --output none

echo "  Bicep deployment complete."
echo ""

# -----------------------------------------------------------------------------
# Get deployment outputs
# -----------------------------------------------------------------------------
echo "Retrieving deployment outputs..."

ACR_LOGIN_SERVER=$(get_acr_login_server)
SQL_FQDN=$(get_sql_server_fqdn)

echo ""
echo "=== Infrastructure Provisioned ==="
echo ""
echo "Resources created in resource group: $RESOURCE_GROUP"
echo ""
echo "  Container Registry:  $ACR_LOGIN_SERVER"
echo "  SQL Server:          $SQL_FQDN"
echo "  SQL Database:        $SQL_DATABASE"
echo ""
echo "Next steps:"
echo "  1. Wait for SQL Database:   ./deploy/scripts/wait-for-sql.sh"
echo "  2. Build and push image:    ./deploy/build-and-push.sh"
echo "  3. Deploy Container App:    ./deploy/deploy-containerapp.sh"
echo ""
echo "Or run everything with:       ./deploy-all-containerapp.sh"
echo ""
