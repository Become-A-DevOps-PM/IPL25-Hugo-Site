#!/bin/bash
# =============================================================================
# PROVISION AZURE SQL DATABASE
# =============================================================================
# Creates Azure SQL Database (Basic tier, ~$5/month).
# Run this before deploy.sh when using database.
# =============================================================================

set -e

RESOURCE_GROUP="rg-starter-flask"
LOCATION="swedencentral"
SQL_SERVER="sql-starter-flask-$(openssl rand -hex 4)"
SQL_DATABASE="flask"
SQL_ADMIN_USER="sqladmin"

# Generate secure password (24 chars, alphanumeric)
SQL_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=' | head -c 24)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Provisioning Azure SQL Database ==="
echo ""
echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  SQL Server:     $SQL_SERVER"
echo "  Database:       $SQL_DATABASE"
echo "  Admin User:     $SQL_ADMIN_USER"
echo "  Location:       $LOCATION"
echo ""

# Create resource group if needed
if ! az group show --name "$RESOURCE_GROUP" &>/dev/null; then
    echo "Creating resource group..."
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
fi

# Create SQL Server
echo "Creating SQL Server (this may take a few minutes)..."
az sql server create \
    --name "$SQL_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --admin-user "$SQL_ADMIN_USER" \
    --admin-password "$SQL_PASSWORD" \
    --output none

# Allow Azure services to access (required for Container Apps)
echo "Configuring firewall to allow Azure services..."
az sql server firewall-rule create \
    --name "AllowAzureServices" \
    --server "$SQL_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0 \
    --output none

# Create database (Basic tier - ~$5/month)
echo "Creating database (Basic tier)..."
az sql db create \
    --name "$SQL_DATABASE" \
    --server "$SQL_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    --edition "Basic" \
    --capacity 5 \
    --max-size 2GB \
    --output none

# Get server FQDN
SQL_FQDN=$(az sql server show \
    --name "$SQL_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    --query "fullyQualifiedDomainName" \
    --output tsv)

# Build connection string for SQLAlchemy with pyodbc
DATABASE_URL="mssql+pyodbc://${SQL_ADMIN_USER}:${SQL_PASSWORD}@${SQL_FQDN}/${SQL_DATABASE}?driver=ODBC+Driver+18+for+SQL+Server"

echo ""
echo "=== SQL Database Provisioned ==="
echo ""
echo "Server FQDN: $SQL_FQDN"
echo "Database:    $SQL_DATABASE"
echo "Username:    $SQL_ADMIN_USER"
echo ""
echo "Connection string saved to: $SCRIPT_DIR/.database-url"
echo ""

# Save connection string for deploy.sh to use
echo "$DATABASE_URL" > "$SCRIPT_DIR/.database-url"
chmod 600 "$SCRIPT_DIR/.database-url"

# Also save server name for delete.sh
echo "$SQL_SERVER" > "$SCRIPT_DIR/.sql-server-name"
chmod 600 "$SCRIPT_DIR/.sql-server-name"

echo "Next steps:"
echo "  1. Run ./deploy/deploy.sh to deploy the application"
echo "  2. The DATABASE_URL will be automatically configured"
echo ""
echo "Monthly cost estimate: ~\$5 (Basic tier, 5 DTU)"
echo ""
