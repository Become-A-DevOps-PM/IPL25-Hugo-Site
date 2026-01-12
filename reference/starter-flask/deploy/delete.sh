#!/bin/bash
# =============================================================================
# DELETE ALL AZURE RESOURCES
# =============================================================================
# Removes the entire resource group and all contained resources.
# =============================================================================

set -e

RESOURCE_GROUP="rg-starter-flask"

echo "=== Deleting Azure Resources ==="
echo ""
echo "This will delete:"
echo "  - Resource group: $RESOURCE_GROUP"
echo "  - All resources in the group (ACR, Container App, Environment, etc.)"
echo ""

read -p "Are you sure? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting resource group: $RESOURCE_GROUP"
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait
    echo ""
    echo "Deletion initiated (running in background)."
    echo "Use 'az group show -n $RESOURCE_GROUP' to check status."
else
    echo "Cancelled."
fi
