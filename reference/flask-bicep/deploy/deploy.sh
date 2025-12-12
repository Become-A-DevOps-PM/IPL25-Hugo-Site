#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Source central configuration
source "$PROJECT_DIR/config.sh"

# Local configuration
PARAMS_FILE="$PROJECT_DIR/infrastructure/parameters.json"
APP_DIR="$PROJECT_DIR/application"

echo "Starting application deployment..."

# 1. Validate parameters.json exists (created by infrastructure/provision.sh)
if [ ! -f "$PARAMS_FILE" ]; then
    echo "ERROR: $PARAMS_FILE not found. Run ./infrastructure/provision.sh first."
    exit 1
fi

# 2. Get bastion public IP
echo "Getting bastion IP..."
BASTION_IP=$(get_vm_public_ip "$VM_BASTION")
if [ -z "$BASTION_IP" ]; then
    echo "ERROR: Could not get bastion public IP. Is the infrastructure deployed?"
    exit 1
fi

# Build proxy command for SSH/SCP
PROXY_CMD="ssh $SSH_OPTS -W %h:%p ${VM_ADMIN_USER}@${BASTION_IP}"

# 3. Extract credentials from parameters.json (using jq)
DB_USER=$(jq -r '.parameters.dbAdminUsername.value' "$PARAMS_FILE")
DB_PASS=$(jq -r '.parameters.dbAdminPassword.value' "$PARAMS_FILE")

# 4. Build connection string (uses POSTGRES_HOST and DATABASE_NAME from config.sh)
DATABASE_URL="postgresql://${DB_USER}:${DB_PASS}@${POSTGRES_HOST}:5432/${DATABASE_NAME}?sslmode=require"

# 5. Copy all application files recursively via SSH jump (using internal hostname)
echo "Copying application files..."
scp -r $SSH_OPTS -o "ProxyCommand=$PROXY_CMD" "$APP_DIR"/* "${VM_ADMIN_USER}@${VM_APP}:/opt/flask-app/"

# 5b. Fix file permissions so flask-app group can read the files
# SCP preserves local file permissions which may be too restrictive (600)
# The flask-app service user needs read access to run the application
echo "Setting file permissions..."
ssh_via_bastion "$VM_APP" "chown ${VM_ADMIN_USER}:flask-app /opt/flask-app/*.py /opt/flask-app/*.txt 2>/dev/null; chmod 640 /opt/flask-app/*.py /opt/flask-app/*.txt 2>/dev/null"

# 6. Install dependencies (via SSH)
echo "Installing Python dependencies..."
ssh_via_bastion "$VM_APP" "/opt/flask-app/venv/bin/pip install -q -r /opt/flask-app/requirements.txt"

# 7. Create database config (with proper permissions)
echo "Configuring database connection..."
ssh_via_bastion "$VM_APP" "echo 'DATABASE_URL=$DATABASE_URL' | sudo tee /etc/flask-app/app.env > /dev/null && \
   sudo chmod 640 /etc/flask-app/app.env && \
   sudo chown root:flask-app /etc/flask-app/app.env"

# 8. Enable and start the service (SQLAlchemy creates tables on first connection)
echo "Starting Flask service..."
ssh_via_bastion "$VM_APP" "sudo systemctl enable flask-app && sudo systemctl restart flask-app"

echo "Application deployed successfully."
