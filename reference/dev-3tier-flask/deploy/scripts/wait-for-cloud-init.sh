#!/bin/bash
# =============================================================================
# WAIT FOR VM CLOUD-INIT COMPLETION
# =============================================================================
# Waits for cloud-init to complete on the application VM.
#
# Why this is needed:
#   - VMs boot quickly but cloud-init runs in the background
#   - cloud-init installs packages, writes config files, runs setup commands
#   - Services won't be ready until cloud-init completes
#
# Cloud-init status values:
#   - running: Still executing
#   - done: Completed successfully
#   - error: Completed with errors (may still be usable)
#   - disabled: Cloud-init is disabled
#
# SSH access:
#   - Direct SSH to VM (has public IP)
# =============================================================================

set -e

# Source central configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "$PROJECT_DIR/config.sh"

# Get VM public IP for SSH access
VM_IP=$(get_vm_public_ip)

if [ -z "$VM_IP" ]; then
    echo "ERROR: Could not get VM public IP. Is the infrastructure deployed?"
    exit 1
fi

echo "Waiting for cloud-init on vm-app ($VM_IP)..."

ATTEMPT=0
MAX_ATTEMPTS=$CLOUD_INIT_MAX_ATTEMPTS

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # Get cloud-init status
    STATUS=$(ssh $SSH_OPTS "${VM_ADMIN_USER}@${VM_IP}" "cloud-init status 2>/dev/null | head -1 | awk '{print \$2}'" 2>/dev/null || echo "unreachable")

    case "$STATUS" in
        done)
            echo "Cloud-init completed successfully."
            exit 0
            ;;
        error)
            echo "Cloud-init completed with errors (continuing anyway)."
            echo "  Check /var/log/cloud-init-output.log on VM for details."
            exit 0
            ;;
        running)
            ATTEMPT=$((ATTEMPT + 1))
            echo "  Attempt $ATTEMPT/$MAX_ATTEMPTS - cloud-init still running..."
            sleep $CLOUD_INIT_POLL_INTERVAL
            ;;
        *)
            ATTEMPT=$((ATTEMPT + 1))
            echo "  Attempt $ATTEMPT/$MAX_ATTEMPTS - Status: $STATUS, waiting..."
            sleep $CLOUD_INIT_POLL_INTERVAL
            ;;
    esac
done

echo "ERROR: Cloud-init did not complete within expected time"
exit 1
