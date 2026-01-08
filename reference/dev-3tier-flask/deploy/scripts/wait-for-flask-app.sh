#!/bin/bash
# =============================================================================
# WAIT FOR FLASK APPLICATION HEALTH
# =============================================================================
# Waits for the Flask application to respond to health checks.
#
# Why this is needed:
#   - After deployment, Gunicorn needs time to start
#   - The app connects to PostgreSQL and creates tables on first request
#   - nginx may need to establish the upstream connection
#
# Health check details:
#   - Endpoint: https://<vm-ip>/api/health
#   - Expected response: {"status": "ok"}
#   - Request goes through: Internet -> nginx (443) -> Gunicorn (5001)
#
# Polling strategy:
#   - Checks every 10 seconds
#   - Maximum wait time: 5 minutes (30 attempts x 10 seconds)
#   - Uses curl with SSL verification disabled (self-signed cert)
#
# Traffic flow being tested:
#   curl -> HTTPS:443 -> nginx -> HTTP:5001 -> Gunicorn/Flask
# =============================================================================

set -e

# Source central configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "$PROJECT_DIR/config.sh"

# Local configuration (uses values from config.sh)
POLL_INTERVAL=$APP_POLL_INTERVAL
MAX_ATTEMPTS=$APP_MAX_ATTEMPTS
ATTEMPT=0

# Get VM public IP
VM_IP=$(get_vm_public_ip)

if [ -z "$VM_IP" ]; then
    echo "ERROR: Could not get VM public IP. Is the infrastructure deployed?"
    exit 1
fi

echo "Waiting for Flask application to respond..."

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # Health endpoint returns: {"status": "ok"}
    # -s: Silent mode (no progress bar)
    # -k: Ignore SSL certificate errors (self-signed cert)
    # --max-time 5: Timeout after 5 seconds per request
    if curl -sk --max-time 5 "https://$VM_IP/api/health" | grep -q '"status"'; then
        echo "Application is healthy."
        exit 0
    fi

    ATTEMPT=$((ATTEMPT + 1))
    echo "  Attempt $ATTEMPT/$MAX_ATTEMPTS - Application not ready yet..."
    sleep $POLL_INTERVAL
done

echo "ERROR: Application did not become healthy within 5 minutes"
exit 1
