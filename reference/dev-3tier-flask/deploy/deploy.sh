#!/bin/bash
# =============================================================================
# APPLICATION DEPLOYMENT SCRIPT
# =============================================================================
# Deploys Flask application to the VM via direct SSH
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Source central configuration
source "$PROJECT_DIR/config.sh"

# Local configuration
PARAMS_FILE="$PROJECT_DIR/infrastructure/parameters.json"
APP_DIR="$PROJECT_DIR/application"

echo "=== Application Deployment ==="
echo ""

# 1. Validate parameters.json exists
if [ ! -f "$PARAMS_FILE" ]; then
    echo "ERROR: $PARAMS_FILE not found. Run ./infrastructure/provision.sh first."
    exit 1
fi

# 2. Get VM public IP
echo "Getting VM public IP..."
VM_IP=$(get_vm_public_ip)
if [ -z "$VM_IP" ]; then
    echo "ERROR: Could not get VM public IP. Is the infrastructure deployed?"
    exit 1
fi
echo "  VM IP: $VM_IP"

# 3. Extract credentials from parameters.json
DB_USER=$(jq -r '.parameters.dbAdminUsername.value' "$PARAMS_FILE")
DB_PASS=$(jq -r '.parameters.dbAdminPassword.value' "$PARAMS_FILE")

# 4. Build connection string
DATABASE_URL="postgresql://${DB_USER}:${DB_PASS}@${POSTGRES_HOST}:5432/${DATABASE_NAME}?sslmode=require"

# 5. Copy application files via direct SCP
echo "Copying application files..."
scp -r $SSH_OPTS "$APP_DIR"/* "${VM_ADMIN_USER}@${VM_IP}:/opt/flask-app/"

# 6. Fix file permissions
echo "Setting file permissions..."
ssh $SSH_OPTS "${VM_ADMIN_USER}@${VM_IP}" "sudo chown -R ${VM_ADMIN_USER}:flask-app /opt/flask-app && sudo chmod -R 750 /opt/flask-app"

# 7. Install dependencies
echo "Installing Python dependencies..."
ssh $SSH_OPTS "${VM_ADMIN_USER}@${VM_IP}" "/opt/flask-app/venv/bin/pip install -q -r /opt/flask-app/requirements.txt"

# 8. Configure database connection
echo "Configuring database connection..."
ssh $SSH_OPTS "${VM_ADMIN_USER}@${VM_IP}" "echo 'DATABASE_URL=$DATABASE_URL' | sudo tee /etc/flask-app/app.env > /dev/null && \
   echo 'FLASK_ENV=production' | sudo tee -a /etc/flask-app/app.env > /dev/null && \
   sudo chmod 640 /etc/flask-app/app.env && \
   sudo chown root:flask-app /etc/flask-app/app.env"

# 9. Initialize database tables
echo "Initializing database tables..."
ssh $SSH_OPTS "${VM_ADMIN_USER}@${VM_IP}" "cd /opt/flask-app && source venv/bin/activate && \
    eval \$(sudo cat /etc/flask-app/app.env) && \
    python3 -c 'from app import create_app; from app.extensions import db; app=create_app(); ctx=app.app_context(); ctx.push(); db.create_all(); print(\"Database tables initialized\")'"

# 10. Enable and start the service
echo "Starting Flask service..."
ssh $SSH_OPTS "${VM_ADMIN_USER}@${VM_IP}" "sudo systemctl enable flask-app && sudo systemctl restart flask-app"

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Application URL: https://${VM_IP}/"
echo "Health check:    https://${VM_IP}/api/health"
echo ""
echo "Note: Browser will show security warning due to self-signed certificate."
echo ""
