#!/bin/bash
# =============================================================================
# DELETE ALL CONTAINER APPS RESOURCES
# =============================================================================
# Safely removes all Azure resources created for the Container Apps deployment.
# Prompts for confirmation before deletion.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source central configuration
source "$SCRIPT_DIR/config-containerapp.sh"

echo "=== Delete Container Apps Resources ==="
echo ""
echo "This will delete the following resource group and ALL resources within it:"
echo ""
echo "  Resource Group: $RESOURCE_GROUP"
echo ""
echo "  Resources to be deleted:"
echo "    - Container Registry: $ACR_NAME"
echo "    - Container Apps Environment: $CONTAINER_APP_ENV"
echo "    - Container App: $CONTAINER_APP"
echo "    - SQL Server: $SQL_SERVER"
echo "    - SQL Database: $SQL_DATABASE"
echo "    - Log Analytics Workspace"
echo ""

# Check if resource group exists
if ! resource_group_exists; then
    echo "Resource group '$RESOURCE_GROUP' does not exist. Nothing to delete."
    exit 0
fi

# Confirm deletion
read -p "Are you sure you want to delete all these resources? (yes/no): " CONFIRM
echo ""

if [ "$CONFIRM" != "yes" ]; then
    echo "Deletion cancelled."
    exit 0
fi

# -----------------------------------------------------------------------------
# Delete resource group
# -----------------------------------------------------------------------------
echo "Deleting resource group '$RESOURCE_GROUP'..."
echo "This may take 3-8 minutes..."
echo ""

# Start deletion with progress indicator
az group delete \
    --name "$RESOURCE_GROUP" \
    --yes \
    --no-wait

# Wait for deletion with progress indicator
echo -n "Deleting"
while resource_group_exists; do
    echo -n "."
    sleep 5
done
echo " Done!"

echo ""
echo "=== Cleanup Complete ==="
echo ""
echo "All resources in '$RESOURCE_GROUP' have been deleted."
echo ""
echo "Optional: Clean up local secrets file:"
echo "  rm infrastructure/parameters-containerapp.json"
echo ""
