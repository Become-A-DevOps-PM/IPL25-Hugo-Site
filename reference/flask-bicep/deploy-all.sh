#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RG="rg-flask-bicep-dev"
LOCATION="swedencentral"

echo "=== Flask Bicep Deployment ==="

# Prerequisites check
echo "Checking prerequisites..."

# Check Azure CLI is installed and logged in
if ! command -v az &> /dev/null; then
    echo "ERROR: Azure CLI is not installed. Run: brew install azure-cli"
    exit 1
fi

if ! az account show &> /dev/null; then
    echo "ERROR: Not logged into Azure. Run: az login"
    exit 1
fi

# Check jq is installed (needed for JSON parsing)
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is not installed. Run: brew install jq"
    exit 1
fi

# Check SSH key exists
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "ERROR: SSH key not found at ~/.ssh/id_rsa.pub"
    echo "Generate one with: ssh-keygen -t rsa -b 4096"
    exit 1
fi

echo "Prerequisites OK."

# Step 0: Initialize secrets (if not already done)
if [ ! -f infrastructure/parameters.json ]; then
    echo "Initializing secrets..."
    ./scripts/init-secrets.sh
fi

# Validate password format
./scripts/validate-password.sh

# Step 1: Create resource group
echo "Creating resource group..."
az group create --name $RG --location $LOCATION --output none

# Step 2: Read SSH public key
echo "Reading SSH public key..."
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)

# Step 3: Deploy infrastructure (Bicep + cloud-init)
echo "Deploying infrastructure (this takes 10-15 minutes)..."
az deployment group create \
  --resource-group $RG \
  --template-file infrastructure/main.bicep \
  --parameters infrastructure/parameters.json \
  --parameters sshPublicKey="$SSH_KEY" \
  --output none

# Step 4: Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
./scripts/wait-for-postgres.sh

# Step 5: Wait for cloud-init to complete on all VMs
echo "Waiting for VMs to be configured..."
./scripts/wait-for-cloud-init.sh

# Step 6: Deploy application
echo "Deploying application..."
./deploy/deploy.sh

# Step 7: Verify application is healthy
echo "Verifying application health..."
./scripts/wait-for-app.sh

# Step 8: Show access information
PROXY_IP=$(az vm show -g $RG -n vm-proxy --show-details -o tsv --query publicIps)
echo ""
echo "=== Deployment Complete ==="
echo "Application URL: https://$PROXY_IP/"
echo "(Accept the self-signed certificate warning)"
