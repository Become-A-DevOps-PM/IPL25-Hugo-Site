#!/bin/bash
# =============================================================================
# DELETE ALL FLASK-BICEP AZURE RESOURCES
# =============================================================================
# Safely removes the entire Flask-Bicep deployment from Azure.
#
# What gets deleted:
#   - Resource group: rg-flask-bicep-dev
#   - All VMs: vm-bastion, vm-proxy, vm-app
#   - PostgreSQL Flexible Server: psql-flask-bicep-dev
#   - Virtual Network and all subnets
#   - Network Security Groups
#   - All associated disks, NICs, and public IPs
#
# Safety features:
#   - Checks if resource group exists before attempting delete
#   - Requires explicit "yes" confirmation
#   - Shows list of resources before deletion
#   - Monitors deletion progress with visual feedback
#
# Timing:
#   - Total deletion: 3-10 minutes
#   - VMs delete quickly (~1-2 minutes)
#   - PostgreSQL takes longer (~5-8 minutes)
#
# Visual feedback:
#   - Spinner animation (updates every 0.1 seconds for smooth motion)
#   - Pulsing progress bar (visual indication of ongoing work)
#   - Azure status check (every 10 seconds to avoid API throttling)
#   - Elapsed time counter
#
# Usage:
#   ./delete-all.sh
#   # Type "yes" when prompted to confirm
#
# Exit codes:
#   0 - Success (deleted or nothing to delete)
#   1 - User aborted
# =============================================================================

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "⚠️  WARNING: This will permanently delete all resources in $RESOURCE_GROUP"
echo ""

# Check if resource group exists first
if ! az group show -n "$RESOURCE_GROUP" &>/dev/null; then
    echo "Resource group $RESOURCE_GROUP does not exist. Nothing to delete."
    exit 0
fi

echo "Resources to be deleted:"
echo "  - Bastion VM (vm-bastion)"
echo "  - Proxy VM (vm-proxy)"
echo "  - App VM (vm-app)"
echo "  - PostgreSQL Flexible Server"
echo "  - Virtual Network and all subnets"
echo "  - Network Security Groups"
echo "  - All associated disks and NICs"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Deleting resource group $RESOURCE_GROUP..."
az group delete -n "$RESOURCE_GROUP" --yes --no-wait

echo ""
echo "Monitoring deletion progress..."
echo ""

# Progress bar characters
SPINNER=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
BAR_WIDTH=40
ELAPSED=0
SPIN_COUNTER=0
STATUS="Deleting"
CHECK_INTERVAL=10
LAST_CHECK=0

while true; do
    # Check Azure status every CHECK_INTERVAL seconds
    if [[ $((ELAPSED - LAST_CHECK)) -ge $CHECK_INTERVAL ]]; then
        LAST_CHECK=$ELAPSED

        # Check if resource group still exists
        if ! az group show -n "$RESOURCE_GROUP" &>/dev/null; then
            # Clear the line and show completion
            printf "\r%-80s\n" ""
            echo "✅ Resource group $RESOURCE_GROUP has been deleted."
            echo "   Total time: ${ELAPSED} seconds"
            exit 0
        fi

        # Get current status
        STATUS=$(az group show -n "$RESOURCE_GROUP" --query provisioningState -o tsv 2>/dev/null || echo "Deleting")
    fi

    # Calculate spinner frame
    SPIN_IDX=$((SPIN_COUNTER % ${#SPINNER[@]}))
    SPIN_CHAR="${SPINNER[$SPIN_IDX]}"

    # Calculate progress bar (pulsing effect since we don't know exact progress)
    PULSE_POS=$(( (SPIN_COUNTER / 2) % BAR_WIDTH ))
    BAR=""
    for ((i=0; i<BAR_WIDTH; i++)); do
        if [[ $i -eq $PULSE_POS ]] || [[ $i -eq $((PULSE_POS + 1)) ]] || [[ $i -eq $((PULSE_POS + 2)) ]]; then
            BAR+="█"
        else
            BAR+="░"
        fi
    done

    # Display progress
    printf "\r%s [%s] %s - %ds elapsed" "$SPIN_CHAR" "$BAR" "$STATUS" "$ELAPSED"

    # Fast sleep for smooth animation
    sleep 0.1
    SPIN_COUNTER=$((SPIN_COUNTER + 1))

    # Update elapsed time every 10 iterations (1 second)
    if [[ $((SPIN_COUNTER % 10)) -eq 0 ]]; then
        ELAPSED=$((ELAPSED + 1))
    fi
done
