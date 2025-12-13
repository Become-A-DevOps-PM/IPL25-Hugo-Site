#!/bin/bash
# =============================================================================
# WAIT FOR ALL VMS CLOUD-INIT COMPLETION
# =============================================================================
# Waits for cloud-init to complete on all three VMs: bastion, proxy, and app.
#
# Why this is needed:
#   - VMs boot quickly but cloud-init runs in the background
#   - cloud-init installs packages, writes config files, runs setup commands
#   - Services won't be ready until cloud-init completes
#
# Order of operations:
#   1. Wait for bastion (direct SSH - it has a public IP)
#   2. Wait for proxy (via bastion jump)
#   3. Wait for app (via bastion jump)
#
# The "cloud-init status --wait" command:
#   - Blocks until cloud-init reaches a terminal state (done or error)
#   - Returns exit code 0 on success, non-zero on failure
#   - Typically takes 2-5 minutes per VM depending on packages
#
# SSH access pattern:
#   - Bastion: Direct SSH (has public IP)
#   - Proxy/App: SSH through bastion using ProxyCommand
# =============================================================================

set -e

# Source central configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
source "$PROJECT_DIR/config.sh"

# Get bastion public IP for SSH access
BASTION_IP=$(get_vm_public_ip "$VM_BASTION")

# -----------------------------------------------------------------------------
# Wait for Bastion VM (direct SSH)
# -----------------------------------------------------------------------------
echo "Waiting for bastion cloud-init..."
until ssh $SSH_OPTS "${VM_ADMIN_USER}@${BASTION_IP}" "cloud-init status --wait" 2>/dev/null; do
    echo "  Bastion not ready yet, retrying..."
    sleep 10
done
echo "  Bastion cloud-init complete."

# -----------------------------------------------------------------------------
# Wait for Proxy and App VMs (via bastion jump)
# -----------------------------------------------------------------------------
for VM in "$VM_PROXY" "$VM_APP"; do
    echo "Waiting for $VM cloud-init..."
    ssh_via_bastion "$VM" "cloud-init status --wait"
    echo "  $VM cloud-init complete."
done

echo "All VMs configured."
