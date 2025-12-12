#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

RG="rg-flask-bicep-dev"
PARAMS_FILE="$PROJECT_DIR/infrastructure/parameters.json"
APP_DIR="$PROJECT_DIR/application"

# Common SSH options to avoid interactive prompts
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

echo "Starting application deployment..."

# 1. Validate parameters.json exists
if [ ! -f "$PARAMS_FILE" ]; then
    echo "ERROR: $PARAMS_FILE not found. Run ./scripts/init-secrets.sh first."
    exit 1
fi

# 2. Validate password
"$PROJECT_DIR/scripts/validate-password.sh"

# 3. Get bastion public IP
echo "Getting bastion IP..."
BASTION_IP=$(az vm show -g $RG -n vm-bastion --show-details -o tsv --query publicIps)
if [ -z "$BASTION_IP" ]; then
    echo "ERROR: Could not get bastion public IP. Is the infrastructure deployed?"
    exit 1
fi

# 4. Extract credentials from parameters.json (using jq)
DB_USER=$(jq -r '.parameters.dbAdminUsername.value' "$PARAMS_FILE")
DB_PASS=$(jq -r '.parameters.dbAdminPassword.value' "$PARAMS_FILE")

# 5. Build connection string
DB_HOST="psql-flask-bicep-dev.postgres.database.azure.com"
DATABASE_URL="postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:5432/flask?sslmode=require"

# 6. Copy application files via SSH jump (using internal hostname)
echo "Copying application files..."
scp $SSH_OPTS -J azureuser@$BASTION_IP \
    "$APP_DIR/app.py" \
    "$APP_DIR/wsgi.py" \
    "$APP_DIR/requirements.txt" \
    azureuser@vm-app:/opt/flask-app/

# 7. Install dependencies (via SSH)
echo "Installing Python dependencies..."
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app \
  "/opt/flask-app/venv/bin/pip install -q -r /opt/flask-app/requirements.txt"

# 8. Create database config (with proper permissions)
echo "Configuring database connection..."
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app \
  "echo 'DATABASE_URL=$DATABASE_URL' | sudo tee /etc/flask-app/database.env > /dev/null && \
   sudo chmod 640 /etc/flask-app/database.env && \
   sudo chown root:flask-app /etc/flask-app/database.env"

# 9. Enable and start the service (SQLAlchemy creates tables on first connection)
echo "Starting Flask service..."
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app \
  "sudo systemctl enable flask-app && sudo systemctl restart flask-app"

echo "Application deployed successfully."
