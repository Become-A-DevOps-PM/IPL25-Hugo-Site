#!/bin/bash
# =============================================================================
# FLASK-BICEP CENTRAL CONFIGURATION
# =============================================================================
# This file contains all shared configuration variables for the Flask-Bicep
# reference implementation. All scripts source this file to ensure consistency.
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
#   # or for scripts in subdirectories:
#   source "$(dirname "${BASH_SOURCE[0]}")/../config.sh"
#
# Naming Conventions:
#   - All variables use UPPERCASE_SNAKE_CASE (shell convention)
#   - Resource names follow Azure Cloud Adoption Framework patterns
#   - See README.md for complete naming convention documentation
# =============================================================================

# -----------------------------------------------------------------------------
# Project Identity
# -----------------------------------------------------------------------------
# These values match the Bicep parameters in infrastructure/main.bicep
PROJECT="flask-bicep"
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
# VM Names (Simple Role-Based Naming)
# -----------------------------------------------------------------------------
# Pattern: vm-{role}
# These are internal names, not globally unique, so they can be simple
VM_BASTION="vm-bastion"
VM_PROXY="vm-proxy"
VM_APP="vm-app"

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------
# Subnet CIDR allocations (defined in infrastructure/modules/network.bicep)
# 10.0.1.0/24 - Bastion subnet (snet-bastion)
# 10.0.2.0/24 - Web/Proxy subnet (snet-web)
# 10.0.3.0/24 - App subnet (snet-app)
# 10.0.4.0/24 - Data subnet (snet-data)

# Default admin username for all VMs
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

# Flask application health check wait
APP_POLL_INTERVAL=10          # Seconds between health checks
APP_MAX_ATTEMPTS=30           # 30 x 10s = 5 minutes maximum

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------
# These functions are available to all scripts that source config.sh

# Get public IP of a VM by name
# Usage: get_vm_public_ip "vm-bastion"
get_vm_public_ip() {
    local vm_name="$1"
    az vm show -g "$RESOURCE_GROUP" -n "$vm_name" --show-details -o tsv --query publicIps
}

# SSH to a VM through bastion
# Usage: ssh_via_bastion "vm-app" "command to run"
ssh_via_bastion() {
    local target="$1"
    shift
    local bastion_ip
    bastion_ip=$(get_vm_public_ip "$VM_BASTION")
    local proxy_cmd="ssh $SSH_OPTS -W %h:%p ${VM_ADMIN_USER}@${bastion_ip}"
    ssh $SSH_OPTS -o "ProxyCommand=$proxy_cmd" "${VM_ADMIN_USER}@${target}" "$@"
}

# SCP to a VM through bastion
# Usage: scp_via_bastion "/local/path" "vm-app:/remote/path"
scp_via_bastion() {
    local bastion_ip
    bastion_ip=$(get_vm_public_ip "$VM_BASTION")
    local proxy_cmd="ssh $SSH_OPTS -W %h:%p ${VM_ADMIN_USER}@${bastion_ip}"
    scp $SSH_OPTS -o "ProxyCommand=$proxy_cmd" "$@"
}
