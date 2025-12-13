#!/bin/bash
# =============================================================================
# HTTPS Self-Signed Certificate Tutorial - VM Provisioning Script
# =============================================================================
# Creates an Azure VM with nginx configured for HTTPS using a self-signed
# certificate. The VM runs a simple Hello World site on port 8080, with
# nginx as a reverse proxy on ports 80 and 443.
#
# Usage: ./provision.sh
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------

RESOURCE_GROUP="https-tutorial-rg"
VM_NAME="https-vm"
LOCATION="swedencentral"
VM_SIZE="Standard_B1s"
ADMIN_USER="azureuser"
IMAGE="Ubuntu2404"

# -----------------------------------------------------------------------------
# MAIN SCRIPT
# -----------------------------------------------------------------------------

echo "=============================================="
echo "HTTPS Self-Signed Certificate Tutorial"
echo "=============================================="
echo ""

# Step 1: Create resource group
echo "[1/4] Creating resource group..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

echo "      Done: Resource group '$RESOURCE_GROUP' created"

# Step 2: Create VM with cloud-init
echo "[2/4] Creating VM with cloud-init configuration..."
echo "      (This takes 2-3 minutes...)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLOUD_INIT_FILE="$SCRIPT_DIR/cloud-init.yaml"

if [ ! -f "$CLOUD_INIT_FILE" ]; then
    echo "ERROR: cloud-init.yaml not found at $CLOUD_INIT_FILE"
    exit 1
fi

az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image "$IMAGE" \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --custom-data "$CLOUD_INIT_FILE" \
  --output none

echo "      Done: VM '$VM_NAME' created"

# Step 3: Open ports 80 and 443
echo "[3/4] Opening ports 80 (HTTP) and 443 (HTTPS)..."

az vm open-port \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --port 80 \
  --priority 1001 \
  --output none

az vm open-port \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --port 443 \
  --priority 1002 \
  --output none

echo "      Done: Ports 80 and 443 opened"

# Step 4: Get public IP
echo "[4/4] Retrieving public IP address..."

PUBLIC_IP=$(az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --show-details \
  --query publicIps \
  --output tsv)

echo ""
echo "=============================================="
echo "DEPLOYMENT COMPLETE"
echo "=============================================="
echo ""
echo "Public IP: $PUBLIC_IP"
echo ""
echo "Wait 2-3 minutes for cloud-init to complete, then:"
echo ""
echo "  HTTP:   http://$PUBLIC_IP"
echo "  HTTPS:  https://$PUBLIC_IP"
echo ""
echo "SSH:      ssh $ADMIN_USER@$PUBLIC_IP"
echo ""
echo "To check cloud-init progress:"
echo "  ssh $ADMIN_USER@$PUBLIC_IP 'sudo tail -f /var/log/cloud-init-output.log'"
echo ""
echo "To delete all resources when done:"
echo "  az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo ""
