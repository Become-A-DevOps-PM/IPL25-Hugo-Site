#!/bin/bash
# =============================================================================
# COMPLETE CONTAINER APPS DEPLOYMENT ORCHESTRATOR
# =============================================================================
# One-command deployment of the Flask application using Container Apps.
#
# This script orchestrates the full deployment by calling specialized scripts:
#   1. provision-containerapp.sh  - Create Azure resources
#   2. wait-for-sql.sh            - Wait for SQL Database to be ready
#   3. build-and-push.sh          - Build Docker image and push to ACR
#   4. deploy-containerapp.sh     - Deploy/update Container App
#   5. wait-for-containerapp.sh   - Verify application is responding
#   6. verification-tests-containerapp.sh - Run end-to-end tests
#
# Architecture:
#   Internet ──→ Container App (Flask) ──→ SQL Database Basic
#                Auto-scale 0-N            Always on (~$5/month)
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Docker installed and running
#   - jq installed (for JSON parsing)
#
# Timing:
#   - Total deployment: 8-12 minutes
#   - Infrastructure provisioning: 3-5 minutes
#   - Docker build and push: 2-3 minutes
#   - Container App deployment: 1-2 minutes
#
# Usage:
#   ./deploy-all-containerapp.sh
#
# To tear down:
#   ./delete-all-containerapp.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Source central configuration
source "$SCRIPT_DIR/config-containerapp.sh"

echo "=== Container Apps Deployment ==="
echo ""
print_config

# -----------------------------------------------------------------------------
# Step 1: Provision Infrastructure
# -----------------------------------------------------------------------------
echo "Step 1/6: Provisioning infrastructure..."
./infrastructure/provision-containerapp.sh

# -----------------------------------------------------------------------------
# Step 2: Wait for SQL Database
# -----------------------------------------------------------------------------
echo ""
echo "Step 2/6: Waiting for SQL Database to be ready..."
./deploy/scripts/wait-for-sql.sh

# -----------------------------------------------------------------------------
# Step 3: Build and Push Docker Image
# -----------------------------------------------------------------------------
echo ""
echo "Step 3/6: Building and pushing Docker image..."
./deploy/build-and-push.sh

# -----------------------------------------------------------------------------
# Step 4: Deploy Container App
# -----------------------------------------------------------------------------
echo ""
echo "Step 4/6: Deploying Container App..."
./deploy/deploy-containerapp.sh

# -----------------------------------------------------------------------------
# Step 5: Wait for Application
# -----------------------------------------------------------------------------
echo ""
echo "Step 5/6: Waiting for application to respond..."
./deploy/scripts/wait-for-containerapp.sh

# -----------------------------------------------------------------------------
# Step 6: Run Verification Tests
# -----------------------------------------------------------------------------
echo ""
echo "Step 6/6: Running verification tests..."
./deploy/scripts/verification-tests-containerapp.sh

# -----------------------------------------------------------------------------
# Deployment Complete
# -----------------------------------------------------------------------------
APP_FQDN=$(get_container_app_fqdn)

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Application URL: https://$APP_FQDN/"
echo ""
echo "To create admin user, run:"
echo "  az containerapp exec --name $CONTAINER_APP --resource-group $RESOURCE_GROUP --command flask -- create-admin admin"
echo ""
echo "To tear down all resources:"
echo "  ./delete-all-containerapp.sh"
echo ""
