# Stage Ultimate - Reference Implementation

This is the "ultimate" reference implementation for the Flask Contact Form application. It represents a production-grade deployment that demonstrates best practices for:

- Infrastructure as Code (Azure CLI scripts)
- Network segmentation with proper security groups
- Bastion host for secure SSH access
- Reverse proxy with SSL termination
- Azure Key Vault for secrets management
- Managed identity for secure credential access

## Architecture

```
Internet
    │
    ├──SSH (22)────→ Bastion VM ──SSH──→ Internal VMs
    │                (10.0.1.x)
    │
    └──HTTPS (443)─→ Reverse Proxy VM ──HTTP (5001)──→ App Server VM
                     (10.0.2.x)                        (10.0.3.x)
                                                           │
                                                           ├──→ PostgreSQL (10.0.4.x)
                                                           └──→ Key Vault (10.0.5.x)
```

## Components

| Component | Purpose | Public Access |
|-----------|---------|---------------|
| Bastion VM | SSH jump host, fail2ban | SSH only |
| Reverse Proxy VM | nginx, SSL termination | HTTP/HTTPS |
| App Server VM | Flask + Gunicorn | None (private) |
| PostgreSQL | Database | None (private) |
| Key Vault | Secrets | None (private) |

## Cost Estimate

All resources use cost-effective tiers:

| Resource | SKU | ~Monthly Cost |
|----------|-----|---------------|
| VMs (3x) | Standard_B1s | $7 each |
| PostgreSQL | Burstable B1ms | $12 |
| Key Vault | Standard | <$1 |
| Public IPs (2x) | Basic | $3 each |

**Total: ~$40-50/month**

## Quick Start

### Prerequisites

- Azure CLI installed and authenticated (`az login`)
- SSH key pair in `~/.ssh/` (either `id_rsa.pub` or `id_ed25519.pub`)
- Bash shell (macOS, Linux, or WSL on Windows)
- rsync installed (for file synchronization)

### Step 1: Navigate to the Reference Directory

```bash
# From the repository root, navigate to stage-ultimate
cd reference/stage-ultimate
```

### Step 2: Provision Infrastructure

```bash
# Run from the infrastructure directory
cd infrastructure
chmod +x provision.sh
./provision.sh
```

**What this creates:**
- Resource group: `flask-ultimate-rg` in Sweden Central
- Virtual Network with 5 subnets (bastion, proxy, app, db, keyvault)
- Network Security Groups with proper traffic rules
- Key Vault with secrets (database password, Flask secret key, database URL)
- PostgreSQL Flexible Server (Burstable B1ms)
- 3 Virtual Machines:
  - `flask-ultimate-bastion` - SSH jump host with fail2ban
  - `flask-ultimate-proxy` - nginx reverse proxy with SSL
  - `flask-ultimate-app` - Flask application with managed identity

**Expected duration:** 15-20 minutes (PostgreSQL creation is slow)

The script outputs the IP addresses at completion. Note them for the next step.

### Step 3: Wait for Cloud-Init

After VMs are created, cloud-init runs automatically to configure them. Wait 2-3 minutes for this to complete before deploying.

You can verify cloud-init status:
```bash
# Get bastion IP from the provision.sh output, then:
BASTION_IP="<bastion-public-ip>"
ssh -o StrictHostKeyChecking=no azureuser@$BASTION_IP "cloud-init status"
# Should output: status: done
```

### Step 4: Deploy Application

```bash
# Run from the deploy directory
cd ../deploy
chmod +x deploy.sh
./deploy.sh
```

**What this does:**
1. Waits for cloud-init completion on all VMs
2. Syncs application files from `application/` to app server via bastion
3. Creates Python virtual environment and installs dependencies
4. Configures environment with Key Vault URL
5. Installs and starts systemd service
6. Configures nginx reverse proxy with the app server's private IP
7. Runs database migrations
8. Verifies deployment with health check

**Expected duration:** 3-5 minutes

### Step 5: Access the Application

After deployment completes successfully:

```bash
# Get proxy public IP
PROXY_IP=$(az vm show -g flask-ultimate-rg -n flask-ultimate-proxy --show-details -o tsv --query publicIps)

# Open in browser
echo "https://$PROXY_IP/"
```

**Note:** Accept the self-signed certificate warning in your browser.

### Step 6: Verify Health

```bash
# Test health endpoint
curl -sk "https://$PROXY_IP/health"
# Expected: {"database": "connected", "database_type": "postgresql", "status": "healthy"}
```

## Directory Structure

```
stage-ultimate/
├── README.md                    # This file
├── PLAN-INFRASTRUCTURE.md       # Detailed infrastructure specification
├── PLAN-APPLICATION.md          # Detailed application specification
│
├── infrastructure/              # Azure provisioning
│   ├── provision.sh            # Main provisioning script
│   ├── cloud-init-bastion.yaml # Bastion VM configuration
│   ├── cloud-init-proxy.yaml   # Proxy VM configuration
│   └── cloud-init-app-server.yaml # App server configuration
│
├── application/                 # Flask application
│   ├── app.py                  # Application factory
│   ├── config.py               # Configuration
│   ├── models.py               # Database models
│   ├── routes.py               # Route handlers
│   ├── validators.py           # Input validation
│   ├── keyvault.py            # Key Vault integration
│   ├── wsgi.py                # Gunicorn entry point
│   ├── requirements.txt        # Dependencies
│   ├── templates/              # Jinja2 templates
│   └── static/                 # CSS, images
│
└── deploy/                      # Deployment scripts
    ├── deploy.sh               # Main deployment script
    ├── systemd/                # Service configuration
    └── nginx/                  # Reverse proxy configuration
```

## Local Development

The application can run locally without Azure:

```bash
cd application
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run with SQLite (default)
python -m flask --app app run --port=5001
```

When running with SQLite, the application displays a warning banner indicating test mode.

## Key Features

### 1. Database Mode Indicator

- Orange banner when using SQLite (test mode)
- Footer shows current database type
- Health endpoint reports database status

### 2. Key Vault Integration

Secrets are loaded transparently:
1. Environment variable (highest priority)
2. Azure Key Vault (production)
3. Default value (development fallback)

### 3. Security

- fail2ban on bastion and proxy
- SSH key authentication only
- Network isolation via NSGs
- No direct internet access to app server
- Managed identity (no stored credentials)

## SSH Access

```bash
# Get bastion IP
BASTION_IP=$(az vm show -g flask-ultimate-rg -n flask-ultimate-bastion --show-details -o tsv --query publicIps)

# SSH to bastion
ssh azureuser@$BASTION_IP

# SSH to app server via bastion
APP_IP=$(az vm show -g flask-ultimate-rg -n flask-ultimate-app --show-details -o tsv --query privateIps)
ssh -J azureuser@$BASTION_IP azureuser@$APP_IP
```

## Cleanup

```bash
# Delete all resources
az group delete --name flask-ultimate-rg --yes

# Purge soft-deleted Key Vault (if needed)
az keyvault purge --name flask-kv-xxxx --location swedencentral
```

## Troubleshooting

### Cloud-init not completing

```bash
# Check cloud-init status
ssh azureuser@$VM_IP "cloud-init status"

# View cloud-init logs
ssh azureuser@$VM_IP "sudo cat /var/log/cloud-init-output.log"
```

### Application not starting

```bash
# Check systemd service
ssh -J azureuser@$BASTION_IP azureuser@$APP_IP "sudo systemctl status flask-contact-form"

# View application logs
ssh -J azureuser@$BASTION_IP azureuser@$APP_IP "sudo journalctl -u flask-contact-form -f"
```

### nginx errors

```bash
# Test nginx config
ssh -J azureuser@$BASTION_IP azureuser@$PROXY_IP "sudo nginx -t"

# View nginx logs
ssh -J azureuser@$BASTION_IP azureuser@$PROXY_IP "sudo tail -f /var/log/nginx/error.log"
```

### Database connection issues

```bash
# Test from app server
ssh -J azureuser@$BASTION_IP azureuser@$APP_IP "
  source /opt/flask-contact-form/venv/bin/activate
  cd /opt/flask-contact-form
  python -c 'from app import create_app; app = create_app(); print(app.config[\"SQLALCHEMY_DATABASE_URI\"][:50])'
"
```

### Key Vault access denied

If the app can't read secrets from Key Vault, verify the managed identity has the correct role:

```bash
# Get app VM's principal ID
PRINCIPAL_ID=$(az vm identity show -g flask-ultimate-rg -n flask-ultimate-app --query principalId -o tsv)

# Get Key Vault name and ID
KV_NAME=$(az keyvault list -g flask-ultimate-rg --query "[0].name" -o tsv)
KV_ID=$(az keyvault show --name $KV_NAME --query id -o tsv)

# Grant Key Vault Secrets User role
az role assignment create \
    --assignee-object-id "$PRINCIPAL_ID" \
    --assignee-principal-type ServicePrincipal \
    --role "Key Vault Secrets User" \
    --scope "$KV_ID"
```

### SSH host key warning

If you see "REMOTE HOST IDENTIFICATION HAS CHANGED" when connecting:

```bash
# Remove old host key entries (replace IP with actual)
ssh-keygen -R 10.0.3.4
ssh-keygen -R 10.0.2.4
```

This happens when VMs are recreated with the same private IPs.

## Re-deploying

To update the application without reprovisioning infrastructure:

```bash
cd deploy
./deploy.sh
```

To update only configuration (skip file sync):

```bash
./deploy.sh --skip-sync
```

## Complete Fresh Start

To destroy and recreate everything from scratch:

```bash
# 1. Delete all resources
az group delete --name flask-ultimate-rg --yes --no-wait

# 2. Wait for deletion (check in Azure Portal or with 'az group show')

# 3. Purge soft-deleted Key Vault if it exists
az keyvault purge --name <kv-name> --location swedencentral 2>/dev/null || true

# 4. Run provisioning
cd infrastructure
./provision.sh

# 5. Wait for cloud-init (2-3 minutes)

# 6. Deploy application
cd ../deploy
./deploy.sh
```
