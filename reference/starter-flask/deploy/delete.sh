#!/bin/bash
# Delete all Azure resources and clean up local config files
set -e

RESOURCE_GROUP="rg-starter-flask"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Deleting Azure Resources ==="
echo ""
echo "This will delete:"
echo "  - Resource group: $RESOURCE_GROUP"
echo "  - All resources in the group:"
echo "    - Container App"
echo "    - Container Registry"
echo "    - Container Apps Environment"
echo "    - SQL Server and Database (if provisioned)"
echo "    - Log Analytics workspace"
echo ""

# Check if SQL was provisioned
if [ -f "$SCRIPT_DIR/.sql-server-name" ]; then
    SQL_SERVER=$(cat "$SCRIPT_DIR/.sql-server-name")
    echo "  - SQL Server: $SQL_SERVER"
fi
echo ""

read -p "Are you sure? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting resource group: $RESOURCE_GROUP"
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait

    # Clean up local files
    echo "Cleaning up local configuration files..."
    rm -f "$SCRIPT_DIR/.database-url"
    rm -f "$SCRIPT_DIR/.sql-server-name"

    echo ""
    echo "Deletion initiated (running in background)."
    echo "Use 'az group show -n $RESOURCE_GROUP' to check status."
    echo ""
    echo "Local configuration files have been removed."
else
    echo "Cancelled."
fi
