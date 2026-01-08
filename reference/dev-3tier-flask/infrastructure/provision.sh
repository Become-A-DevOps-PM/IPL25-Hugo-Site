#!/bin/bash
# =============================================================================
# INFRASTRUCTURE PROVISIONING SCRIPT
# =============================================================================
# Provisions simplified Azure infrastructure using Bicep templates
# Creates: Resource Group, VNet, Single VM (nginx + Flask), PostgreSQL
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Source central configuration
source "$PROJECT_DIR/config.sh"

# Local configuration
PARAMS_FILE="$SCRIPT_DIR/parameters.json"

echo "=== Infrastructure Provisioning ==="
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

# Check Azure login
if ! az account show &> /dev/null; then
    echo "ERROR: Not logged in to Azure. Run: az login"
    exit 1
fi

echo "  Prerequisites OK."
echo ""

# -----------------------------------------------------------------------------
# Initialize secrets if needed
# -----------------------------------------------------------------------------
if [ ! -f "$PARAMS_FILE" ]; then
    echo "Initializing secrets..."
    "$SCRIPT_DIR/scripts/init-secrets.sh"
    echo ""
fi

# Validate password
"$SCRIPT_DIR/scripts/validate-password.sh"
echo ""

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
echo "Deploying infrastructure (this takes 10-15 minutes)..."

# Read SSH public key
SSH_KEY=$(cat ~/.ssh/id_rsa.pub 2>/dev/null || cat ~/.ssh/id_ed25519.pub 2>/dev/null)
if [ -z "$SSH_KEY" ]; then
    echo "ERROR: No SSH public key found at ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub"
    exit 1
fi

# Deploy
az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "$SCRIPT_DIR/main.bicep" \
    --parameters "$PARAMS_FILE" \
    --parameters sshPublicKey="$SSH_KEY" \
    --output none

echo "  Bicep deployment complete."
echo ""

# -----------------------------------------------------------------------------
# Get deployment outputs
# -----------------------------------------------------------------------------
echo "Retrieving deployment outputs..."

VM_IP=$(get_vm_public_ip)
POSTGRES_FQDN=$(az postgres flexible-server show -g "$RESOURCE_GROUP" -n "$POSTGRES_SERVER" --query fullyQualifiedDomainName -o tsv)

echo ""
echo "=== Infrastructure Provisioned ==="
echo ""
echo "Resources created in resource group: $RESOURCE_GROUP"
echo ""
echo "  VM Public IP:   $VM_IP"
echo "  PostgreSQL:     $POSTGRES_FQDN"
echo ""
echo "Access:"
echo "  SSH:            ssh ${VM_ADMIN_USER}@${VM_IP}"
echo "  HTTPS:          https://${VM_IP}/"
echo ""
echo "Next steps:"
echo "  1. Wait for PostgreSQL:    ./deploy/scripts/wait-for-postgresql.sh"
echo "  2. Wait for cloud-init:    ./deploy/scripts/wait-for-cloud-init.sh"
echo "  3. Deploy application:     ./deploy/deploy.sh"
echo ""
echo "Or run everything with:      ./deploy-all.sh"
echo ""
