#!/bin/bash
# =============================================================================
# CONTAINER APPS CENTRAL CONFIGURATION
# =============================================================================
# This file contains all shared configuration variables for the Container Apps
# variant of the Flask reference implementation.
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/config-containerapp.sh"
#
# Architecture:
#   Internet ──→ Container App (Flask) ──→ SQL Database Basic
#                Auto-scale 0-N            Always on (~$5/month)
# =============================================================================

# -----------------------------------------------------------------------------
# Project Identity
# -----------------------------------------------------------------------------
PROJECT="flask"
ENVIRONMENT="dev"
LOCATION="swedencentral"

# -----------------------------------------------------------------------------
# Derived Names (Azure Resource Naming Convention)
# -----------------------------------------------------------------------------
BASE_NAME="${PROJECT}-${ENVIRONMENT}"

# Resource Group (separate from VM-based deployment)
RESOURCE_GROUP="rg-${BASE_NAME}-aca"

# Container Registry (must be globally unique, alphanumeric only)
ACR_NAME="acr${PROJECT}${ENVIRONMENT}"

# Container Apps
CONTAINER_APP_ENV="cae-${BASE_NAME}"
CONTAINER_APP="ca-${BASE_NAME}"

# SQL Database
SQL_SERVER="sql-${BASE_NAME}"
SQL_DATABASE="flask"
SQL_ADMIN_USER="sqladmin"

# Container image
IMAGE_NAME="flask-app"
IMAGE_TAG="latest"

# -----------------------------------------------------------------------------
# Timing Configuration
# -----------------------------------------------------------------------------
# SQL Database availability check
SQL_POLL_INTERVAL=15          # Seconds between state checks
SQL_MAX_ATTEMPTS=40           # 40 x 15s = 10 minutes maximum

# Container App health check
APP_POLL_INTERVAL=10          # Seconds between health checks
APP_MAX_ATTEMPTS=30           # 30 x 10s = 5 minutes maximum

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

# Get ACR login server
get_acr_login_server() {
    az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query loginServer -o tsv 2>/dev/null
}

# Get Container App FQDN
get_container_app_fqdn() {
    az containerapp show \
        --name "$CONTAINER_APP" \
        --resource-group "$RESOURCE_GROUP" \
        --query "properties.configuration.ingress.fqdn" \
        -o tsv 2>/dev/null
}

# Get SQL Server FQDN
get_sql_server_fqdn() {
    az sql server show \
        --name "$SQL_SERVER" \
        --resource-group "$RESOURCE_GROUP" \
        --query "fullyQualifiedDomainName" \
        -o tsv 2>/dev/null
}

# Build DATABASE_URL for SQL Server
# Usage: DATABASE_URL=$(build_database_url "password")
build_database_url() {
    local password="$1"
    local server_fqdn
    server_fqdn=$(get_sql_server_fqdn)
    echo "mssql+pyodbc://${SQL_ADMIN_USER}:${password}@${server_fqdn}/${SQL_DATABASE}?driver=ODBC+Driver+18+for+SQL+Server"
}

# Check if resource group exists
resource_group_exists() {
    az group show --name "$RESOURCE_GROUP" &>/dev/null
}

# Check if container app exists
container_app_exists() {
    az containerapp show \
        --name "$CONTAINER_APP" \
        --resource-group "$RESOURCE_GROUP" &>/dev/null
}

# Print configuration summary
print_config() {
    echo "=== Container Apps Configuration ==="
    echo ""
    echo "Project:           $PROJECT"
    echo "Environment:       $ENVIRONMENT"
    echo "Location:          $LOCATION"
    echo "Resource Group:    $RESOURCE_GROUP"
    echo ""
    echo "Container Registry: $ACR_NAME"
    echo "Container App Env:  $CONTAINER_APP_ENV"
    echo "Container App:      $CONTAINER_APP"
    echo ""
    echo "SQL Server:        $SQL_SERVER"
    echo "SQL Database:      $SQL_DATABASE"
    echo ""
}
