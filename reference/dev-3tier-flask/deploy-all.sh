#!/bin/bash
# =============================================================================
# COMPLETE FLASK DEPLOYMENT ORCHESTRATOR
# =============================================================================
# One-command deployment of the Flask application on Azure.
#
# This script orchestrates the full deployment by calling specialized scripts:
#   1. provision.sh         - Create Azure resources (VM, PostgreSQL, networking)
#   2. wait-for-postgresql  - Wait for database to be ready
#   3. wait-for-cloud-init  - Wait for VM configuration to complete
#   4. deploy.sh            - Copy application code and start services
#   5. wait-for-flask-app   - Verify application is responding
#   6. verification-tests   - Run end-to-end test suite
#
# Architecture:
#   Single VM (nginx + Flask) → PostgreSQL (public access)
#   Direct SSH access (no bastion/jump host)
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - jq installed (for JSON parsing)
#   - SSH key at ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub
#
# Timing:
#   - Total deployment: 10-15 minutes
#   - Infrastructure provisioning: 8-12 minutes (PostgreSQL is slowest)
#   - Cloud-init completion: 2-3 minutes
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

echo "=== Flask Simplified Deployment ==="
echo ""

# -----------------------------------------------------------------------------
# Step 1: Provision Infrastructure
# -----------------------------------------------------------------------------
# Creates resource group, VNet, VM, PostgreSQL, and security groups
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
./deploy/scripts/wait-for-postgresql.sh

# -----------------------------------------------------------------------------
# Step 3: Wait for Cloud-init
# -----------------------------------------------------------------------------
# VM boots quickly but cloud-init runs in the background
# Installs nginx, Python, creates directories, configures services
echo ""
echo "Step 3/6: Waiting for VM to be configured..."
./deploy/scripts/wait-for-cloud-init.sh

# -----------------------------------------------------------------------------
# Step 4: Deploy Application
# -----------------------------------------------------------------------------
# Copies Flask application code to VM via direct SSH
# Installs dependencies, configures database connection, starts service
echo ""
echo "Step 4/6: Deploying application..."
./deploy/deploy.sh

# -----------------------------------------------------------------------------
# Step 5: Verify Application Health
# -----------------------------------------------------------------------------
# Polls the /api/health endpoint until the application responds
# Verifies the full request path: nginx -> Gunicorn -> Flask
echo ""
echo "Step 5/6: Verifying application health..."
./deploy/scripts/wait-for-flask-app.sh

# -----------------------------------------------------------------------------
# Step 6: Run Verification Tests
# -----------------------------------------------------------------------------
# End-to-end tests: endpoints and database connectivity
echo ""
echo "Step 6/6: Running verification tests..."
./deploy/scripts/verification-tests.sh

# -----------------------------------------------------------------------------
# Deployment Complete
# -----------------------------------------------------------------------------
VM_IP=$(get_vm_public_ip)

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Application URL: https://$VM_IP/"
echo "(Accept the self-signed certificate warning)"
echo ""
echo "SSH access: ssh ${VM_ADMIN_USER}@${VM_IP}"
echo ""
echo "To tear down all resources:"
echo "  ./delete-all.sh"
echo ""
