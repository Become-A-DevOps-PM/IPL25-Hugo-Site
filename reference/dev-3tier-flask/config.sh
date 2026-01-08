#!/bin/bash
# =============================================================================
# DEV-3TIER-FLASK CENTRAL CONFIGURATION
# =============================================================================
# This file contains all shared configuration variables for the simplified
# Flask reference implementation. All scripts source this file for consistency.
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
#   # or for scripts in subdirectories:
#   source "$(dirname "${BASH_SOURCE[0]}")/../config.sh"
#
# Architecture:
#   Single VM (nginx + Flask) → PostgreSQL (public access)
#   Direct SSH access (no bastion/jump host)
# =============================================================================

# -----------------------------------------------------------------------------
# Project Identity
# -----------------------------------------------------------------------------
# These values match the Bicep parameters in infrastructure/main.bicep
PROJECT="flask"
ENVIRONMENT="dev"
LOCATION="swedencentral"

# -----------------------------------------------------------------------------
# Derived Names (Azure Resource Naming Convention)
# -----------------------------------------------------------------------------
# Pattern: {prefix}-{project}-{environment}
# Prefixes follow Azure Cloud Adoption Framework:
#   rg-   = Resource Group
#   vnet- = Virtual Network
#   psql- = PostgreSQL Flexible Server

BASE_NAME="${PROJECT}-${ENVIRONMENT}"
RESOURCE_GROUP="rg-${BASE_NAME}"
VNET_NAME="vnet-${BASE_NAME}"
POSTGRES_SERVER="psql-${BASE_NAME}"
POSTGRES_HOST="${POSTGRES_SERVER}.postgres.database.azure.com"
DATABASE_NAME="flask"

# -----------------------------------------------------------------------------
# VM Configuration
# -----------------------------------------------------------------------------
# Single VM with nginx + Flask
VM_APP="vm-app"

# Default admin username for VM
VM_ADMIN_USER="azureuser"

# Default admin username for PostgreSQL
DB_ADMIN_USER="adminuser"

# -----------------------------------------------------------------------------
# SSH Configuration
# -----------------------------------------------------------------------------
# These options are used consistently across all scripts for SSH/SCP operations
# - StrictHostKeyChecking=no: Auto-accept host keys (acceptable for ephemeral VMs)
# - UserKnownHostsFile=/dev/null: Don't persist host keys
# - LogLevel=ERROR: Suppress warnings (cleaner output)
# - ConnectTimeout=10: Fail fast if connection hangs
SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

# -----------------------------------------------------------------------------
# Timing Configuration
# -----------------------------------------------------------------------------
# PostgreSQL provisioning wait (server takes 5-15 minutes)
POSTGRES_POLL_INTERVAL=30     # Seconds between state checks
POSTGRES_MAX_ATTEMPTS=40      # 40 x 30s = 20 minutes maximum

# Cloud-init completion wait
CLOUD_INIT_POLL_INTERVAL=10   # Seconds between checks
CLOUD_INIT_MAX_ATTEMPTS=30    # 30 x 10s = 5 minutes maximum

# Flask application health check wait
APP_POLL_INTERVAL=10          # Seconds between health checks
APP_MAX_ATTEMPTS=30           # 30 x 10s = 5 minutes maximum

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------
# These functions are available to all scripts that source config.sh

# Get public IP of the application VM
# Usage: VM_IP=$(get_vm_public_ip)
get_vm_public_ip() {
    az vm show -g "$RESOURCE_GROUP" -n "$VM_APP" --show-details -o tsv --query publicIps
}

# SSH to the application VM
# Usage: ssh_to_vm "command to run"
ssh_to_vm() {
    local vm_ip
    vm_ip=$(get_vm_public_ip)
    ssh $SSH_OPTS "${VM_ADMIN_USER}@${vm_ip}" "$@"
}

# SCP to the application VM
# Usage: scp_to_vm "/local/path" "/remote/path"
scp_to_vm() {
    local local_path="$1"
    local remote_path="$2"
    local vm_ip
    vm_ip=$(get_vm_public_ip)
    scp $SSH_OPTS "$local_path" "${VM_ADMIN_USER}@${vm_ip}:${remote_path}"
}
