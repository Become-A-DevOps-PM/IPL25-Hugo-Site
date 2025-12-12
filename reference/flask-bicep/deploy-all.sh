#!/bin/bash
# =============================================================================
# COMPLETE FLASK-BICEP DEPLOYMENT ORCHESTRATOR
# =============================================================================
# One-command deployment of the entire Flask application on Azure.
#
# This script orchestrates the full deployment by calling specialized scripts:
#   1. provision.sh         - Create Azure resources (VMs, PostgreSQL, networking)
#   2. wait-for-postgresql  - Wait for database to be ready
#   3. wait-for-vms-cloud-init - Wait for VM configuration to complete
#   4. deploy.sh            - Copy application code and start services
#   5. wait-for-flask-app   - Verify application is responding
#   6. verification-tests   - Run end-to-end test suite
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - jq installed (for JSON parsing)
#   - SSH key at ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub
#
# Timing:
#   - Total deployment: 15-25 minutes
#   - Infrastructure provisioning: 10-15 minutes (PostgreSQL is slowest)
#   - Cloud-init completion: 2-5 minutes per VM
#   - Application deployment: 1-2 minutes
#
# Usage:
#   ./deploy-all.sh
#
# To tear down:
#   ./delete-all.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Source central configuration
source "$SCRIPT_DIR/config.sh"

echo "=== Flask Bicep Deployment ==="
echo ""

# -----------------------------------------------------------------------------
# Step 1: Provision Infrastructure
# -----------------------------------------------------------------------------
# Creates resource group, VNet, VMs, PostgreSQL, and security groups
# Also handles prerequisites check, secrets initialization, and password validation
echo "Step 1/6: Provisioning infrastructure..."
./infrastructure/provision.sh

# -----------------------------------------------------------------------------
# Step 2: Wait for PostgreSQL
# -----------------------------------------------------------------------------
# PostgreSQL Flexible Server takes 5-15 minutes to reach "Ready" state
# The Bicep deployment returns before the server is fully operational
echo ""
echo "Step 2/6: Waiting for PostgreSQL to be ready..."
./scripts/wait-for-postgresql.sh

# -----------------------------------------------------------------------------
# Step 3: Wait for Cloud-init
# -----------------------------------------------------------------------------
# VMs boot quickly but cloud-init runs in the background
# Waits for all three VMs: bastion, proxy, app
echo ""
echo "Step 3/6: Waiting for VMs to be configured..."
./scripts/wait-for-vms-cloud-init.sh

# -----------------------------------------------------------------------------
# Step 4: Deploy Application
# -----------------------------------------------------------------------------
# Copies Flask application code to app server via bastion
# Installs dependencies, configures database connection, starts service
echo ""
echo "Step 4/6: Deploying application..."
./deploy/deploy.sh

# -----------------------------------------------------------------------------
# Step 5: Verify Application Health
# -----------------------------------------------------------------------------
# Polls the /health endpoint until the application responds
# Verifies the full request path: nginx -> Gunicorn -> Flask
echo ""
echo "Step 5/6: Verifying application health..."
./scripts/wait-for-flask-app.sh

# -----------------------------------------------------------------------------
# Step 6: Run Verification Tests
# -----------------------------------------------------------------------------
# Comprehensive end-to-end tests: endpoints, security, database
echo ""
echo "Step 6/6: Running verification tests..."
./scripts/verification-tests.sh

# -----------------------------------------------------------------------------
# Deployment Complete
# -----------------------------------------------------------------------------
PROXY_IP=$(get_vm_public_ip "$VM_PROXY")

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Application URL: https://$PROXY_IP/"
echo "(Accept the self-signed certificate warning)"
echo ""
echo "To tear down all resources:"
echo "  ./delete-all.sh"
echo ""
