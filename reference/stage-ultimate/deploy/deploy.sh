#!/bin/bash
set -euo pipefail

#
# Deploy Flask Contact Form Application
#
# Usage:
#   ./deploy.sh                    # Deploy to existing infrastructure
#   ./deploy.sh --provision        # Provision infrastructure first
#   ./deploy.sh --help             # Show help
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
INFRA_DIR="$ROOT_DIR/infrastructure"
APP_DIR="$ROOT_DIR/application"

# Configuration
RESOURCE_GROUP="flask-ultimate-rg"
BASTION_VM="flask-ultimate-bastion"
PROXY_VM="flask-ultimate-proxy"
APP_VM="flask-ultimate-app"
VM_USER="azureuser"
APP_DEST="/opt/flask-contact-form"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
Deploy Flask Contact Form Application

Usage: $0 [OPTIONS]

Options:
    --provision     Run infrastructure provisioning before deployment
    --skip-sync     Skip application file sync (for config-only updates)
    --help          Show this help message

Examples:
    $0                     # Deploy to existing infrastructure
    $0 --provision         # Provision infrastructure and deploy
    $0 --skip-sync         # Update config without syncing files

Environment:
    Resource Group: $RESOURCE_GROUP
    VMs: $BASTION_VM, $PROXY_VM, $APP_VM
EOF
}

get_vm_ip() {
    local vm_name="$1"
    local ip_type="${2:-publicIps}"
    az vm show --resource-group "$RESOURCE_GROUP" --name "$vm_name" \
        --show-details --query "$ip_type" -o tsv 2>/dev/null
}

wait_for_cloud_init() {
    local vm_ip="$1"
    local vm_name="$2"
    local jump_host="${3:-}"

    log_info "Waiting for cloud-init on $vm_name..."

    local ssh_cmd="ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10"
    if [[ -n "$jump_host" ]]; then
        ssh_cmd="ssh -o StrictHostKeyChecking=no -J $VM_USER@$jump_host"
    fi

    local max_attempts=30
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        if $ssh_cmd "$VM_USER@$vm_ip" "cloud-init status --wait" 2>/dev/null | grep -q "done"; then
            log_info "Cloud-init completed on $vm_name"
            return 0
        fi
        log_warn "Attempt $attempt/$max_attempts - waiting for cloud-init..."
        sleep 10
        ((attempt++))
    done

    log_error "Cloud-init did not complete on $vm_name"
    return 1
}

provision_infrastructure() {
    log_info "Running infrastructure provisioning..."

    if [[ -f "$INFRA_DIR/provision.sh" ]]; then
        bash "$INFRA_DIR/provision.sh"
    else
        log_error "provision.sh not found in $INFRA_DIR"
        exit 1
    fi
}

sync_application() {
    local bastion_ip="$1"
    local app_private_ip="$2"

    log_info "Syncing application files to app server..."

    rsync -avz --delete \
        -e "ssh -o StrictHostKeyChecking=no -J $VM_USER@$bastion_ip" \
        --exclude 'venv/' \
        --exclude '__pycache__/' \
        --exclude '*.pyc' \
        --exclude '.env' \
        --exclude 'messages.db' \
        --exclude '.git/' \
        "$APP_DIR/" "$VM_USER@$app_private_ip:$APP_DEST/"

    log_info "Application files synced"
}

setup_app_server() {
    local bastion_ip="$1"
    local app_private_ip="$2"
    local keyvault_name="$3"

    log_info "Setting up application server..."

    ssh -o StrictHostKeyChecking=no -J "$VM_USER@$bastion_ip" "$VM_USER@$app_private_ip" << EOF
        set -e

        cd $APP_DEST

        # Create virtual environment if not exists
        if [[ ! -d venv ]]; then
            python3 -m venv venv
        fi

        # Activate and install dependencies
        source venv/bin/activate
        pip install --upgrade pip
        pip install -r requirements.txt

        # Create environment file with Key Vault URL
        echo "AZURE_KEYVAULT_URL=https://${keyvault_name}.vault.azure.net/" | sudo tee /etc/flask-contact-form/environment > /dev/null
        sudo chmod 644 /etc/flask-contact-form/environment

        echo "App server setup complete"
EOF

    log_info "App server setup complete"
}

install_systemd_service() {
    local bastion_ip="$1"
    local app_private_ip="$2"

    log_info "Installing systemd service..."

    # Copy service file
    scp -o StrictHostKeyChecking=no \
        -o ProxyJump="$VM_USER@$bastion_ip" \
        "$SCRIPT_DIR/systemd/flask-contact-form.service" \
        "$VM_USER@$app_private_ip:/tmp/"

    # Install and enable service
    ssh -o StrictHostKeyChecking=no -J "$VM_USER@$bastion_ip" "$VM_USER@$app_private_ip" << 'EOF'
        sudo mv /tmp/flask-contact-form.service /etc/systemd/system/
        sudo systemctl daemon-reload
        sudo systemctl enable flask-contact-form
        sudo systemctl restart flask-contact-form
        sleep 3
        sudo systemctl status flask-contact-form --no-pager || true
EOF

    log_info "Systemd service installed"
}

configure_proxy() {
    local bastion_ip="$1"
    local proxy_private_ip="$2"
    local app_private_ip="$3"

    log_info "Configuring nginx reverse proxy..."

    # Create nginx config with app server IP
    local nginx_config=$(cat "$SCRIPT_DIR/nginx/flask-contact-form.conf" | sed "s/APP_SERVER_PRIVATE_IP/$app_private_ip/g")

    # Copy configs to proxy server
    echo "$nginx_config" | ssh -o StrictHostKeyChecking=no -J "$VM_USER@$bastion_ip" "$VM_USER@$proxy_private_ip" \
        "sudo tee /etc/nginx/sites-available/flask-contact-form.conf > /dev/null"

    scp -o StrictHostKeyChecking=no \
        -o ProxyJump="$VM_USER@$bastion_ip" \
        "$SCRIPT_DIR/nginx/ssl-params.conf" \
        "$VM_USER@$proxy_private_ip:/tmp/"

    ssh -o StrictHostKeyChecking=no -J "$VM_USER@$bastion_ip" "$VM_USER@$proxy_private_ip" << 'EOF'
        sudo mv /tmp/ssl-params.conf /etc/nginx/snippets/ssl-params.conf

        # Enable site
        sudo ln -sf /etc/nginx/sites-available/flask-contact-form.conf /etc/nginx/sites-enabled/
        sudo rm -f /etc/nginx/sites-enabled/default

        # Test and reload
        sudo nginx -t
        sudo systemctl reload nginx
EOF

    log_info "Nginx configured"
}

run_migrations() {
    local bastion_ip="$1"
    local app_private_ip="$2"

    log_info "Running database migrations..."

    ssh -o StrictHostKeyChecking=no -J "$VM_USER@$bastion_ip" "$VM_USER@$app_private_ip" << 'EOF'
        cd /opt/flask-contact-form
        source venv/bin/activate

        # Initialize database tables
        python -c "
from app import create_app
from models import db

app = create_app()
with app.app_context():
    db.create_all()
    print('Database tables created/verified')
"
EOF

    log_info "Migrations complete"
}

verify_deployment() {
    local proxy_ip="$1"

    log_info "Verifying deployment..."

    # Test health endpoint
    local health_response
    health_response=$(curl -sk "https://$proxy_ip/health" 2>/dev/null || echo '{"status":"error"}')

    if echo "$health_response" | grep -q '"status".*"healthy"'; then
        log_info "Health check: PASSED"
        echo "$health_response" | python3 -m json.tool 2>/dev/null || echo "$health_response"
    else
        log_warn "Health check: FAILED"
        echo "$health_response"
    fi

    # Test HTTPS
    local https_status
    https_status=$(curl -sk -o /dev/null -w "%{http_code}" "https://$proxy_ip/" 2>/dev/null)

    if [[ "$https_status" == "200" ]]; then
        log_info "HTTPS test: PASSED (status $https_status)"
    else
        log_warn "HTTPS test: Status $https_status"
    fi

    # Test HTTP redirect
    local http_status
    http_status=$(curl -s -o /dev/null -w "%{http_code}" "http://$proxy_ip/" 2>/dev/null)

    if [[ "$http_status" == "301" ]]; then
        log_info "HTTP redirect: PASSED (status $http_status)"
    else
        log_warn "HTTP redirect: Status $http_status"
    fi

    echo ""
    log_info "Deployment URLs:"
    echo "  HTTPS: https://$proxy_ip/"
    echo "  Health: https://$proxy_ip/health"
}

# Main execution
main() {
    local provision=false
    local skip_sync=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --provision)
                provision=true
                shift
                ;;
            --skip-sync)
                skip_sync=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    echo "=========================================="
    echo "  Flask Contact Form Deployment"
    echo "=========================================="
    echo ""

    # Run provisioning if requested
    if [[ "$provision" == true ]]; then
        provision_infrastructure
    fi

    # Get VM IPs
    log_info "Getting VM IP addresses..."

    BASTION_IP=$(get_vm_ip "$BASTION_VM" "publicIps")
    PROXY_IP=$(get_vm_ip "$PROXY_VM" "publicIps")
    PROXY_PRIVATE_IP=$(get_vm_ip "$PROXY_VM" "privateIps")
    APP_PRIVATE_IP=$(get_vm_ip "$APP_VM" "privateIps")

    if [[ -z "$BASTION_IP" ]] || [[ -z "$PROXY_IP" ]] || [[ -z "$APP_PRIVATE_IP" ]]; then
        log_error "Could not get VM IP addresses. Is infrastructure provisioned?"
        exit 1
    fi

    log_info "Bastion: $BASTION_IP"
    log_info "Proxy: $PROXY_IP (private: $PROXY_PRIVATE_IP)"
    log_info "App Server: $APP_PRIVATE_IP (no public IP)"

    # Get Key Vault name
    KEYVAULT_NAME=$(az keyvault list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null)
    log_info "Key Vault: $KEYVAULT_NAME"

    # Wait for cloud-init
    wait_for_cloud_init "$BASTION_IP" "$BASTION_VM"
    wait_for_cloud_init "$PROXY_PRIVATE_IP" "$PROXY_VM" "$BASTION_IP"
    wait_for_cloud_init "$APP_PRIVATE_IP" "$APP_VM" "$BASTION_IP"

    # Sync application files
    if [[ "$skip_sync" != true ]]; then
        sync_application "$BASTION_IP" "$APP_PRIVATE_IP"
    fi

    # Setup app server
    setup_app_server "$BASTION_IP" "$APP_PRIVATE_IP" "$KEYVAULT_NAME"

    # Install systemd service
    install_systemd_service "$BASTION_IP" "$APP_PRIVATE_IP"

    # Configure nginx
    configure_proxy "$BASTION_IP" "$PROXY_PRIVATE_IP" "$APP_PRIVATE_IP"

    # Run migrations
    run_migrations "$BASTION_IP" "$APP_PRIVATE_IP"

    # Verify
    echo ""
    verify_deployment "$PROXY_IP"

    echo ""
    log_info "Deployment complete!"
}

main "$@"
