# Infrastructure Plan: Stage Ultimate

## Overview

This document describes the complete infrastructure for the "ultimate" reference implementation. The architecture consists of 3 VMs, 5 subnets, managed PostgreSQL, and Azure Key Vault for secrets management.

## Architecture Summary

```
Internet
    │
    ├──SSH (22)────→ Bastion VM (10.0.1.x) ──SSH──→ All internal VMs
    │
    └──HTTPS (443)─→ Reverse Proxy VM (10.0.2.x) ──HTTP (5001)──→ App Server VM (10.0.3.x)
                                                                        │
                                                                        ├──→ PostgreSQL (Azure PaaS)
                                                                        └──→ Key Vault (Azure PaaS)
```

## Cost Optimization

All resources use the lowest cost tiers suitable for learning:

| Resource | SKU/Tier | Estimated Cost |
|----------|----------|----------------|
| VMs (3x) | Standard_B1s (1 vCPU, 1 GB) | ~$7/month each |
| PostgreSQL | Burstable B1ms | ~$12/month |
| Key Vault | Standard | ~$0.03/10k operations |
| Public IPs (2x) | Basic, Dynamic | ~$3/month each |
| Storage | Standard LRS (VM disks) | Included |

**Total estimated cost: ~$40-50/month**

---

## Phase 1: Network Foundation

### 1.1 Resource Group

```
Name: flask-ultimate-rg
Location: swedencentral
```

### 1.2 Virtual Network

```
Name: flask-ultimate-vnet
Address Space: 10.0.0.0/16
Location: swedencentral
```

### 1.3 Subnets (5)

| Subnet Name | CIDR | Purpose | NSG |
|-------------|------|---------|-----|
| bastion-subnet | 10.0.1.0/24 | Bastion VM | bastion-nsg |
| proxy-subnet | 10.0.2.0/24 | Reverse Proxy VM | proxy-nsg |
| app-subnet | 10.0.3.0/24 | App Server VM | app-nsg |
| db-subnet | 10.0.4.0/24 | Reserved for future private endpoint | db-nsg |
| keyvault-subnet | 10.0.5.0/24 | Reserved for future private endpoint | keyvault-nsg |

### 1.4 Network Security Groups (5)

NSG rules use subnet CIDR ranges for simplicity (no ASGs required).

#### bastion-nsg (attached to bastion-subnet)

| Priority | Name | Direction | Port | Source | Destination | Action |
|----------|------|-----------|------|--------|-------------|--------|
| 100 | AllowSSHFromInternet | Inbound | 22 | Internet | * | Allow |

#### proxy-nsg (attached to proxy-subnet)

| Priority | Name | Direction | Port | Source | Destination | Action |
|----------|------|-----------|------|--------|-------------|--------|
| 100 | AllowHTTPFromInternet | Inbound | 80 | Internet | * | Allow |
| 110 | AllowHTTPSFromInternet | Inbound | 443 | Internet | * | Allow |
| 120 | AllowSSHFromBastion | Inbound | 22 | 10.0.1.0/24 | * | Allow |

#### app-nsg (attached to app-subnet)

| Priority | Name | Direction | Port | Source | Destination | Action |
|----------|------|-----------|------|--------|-------------|--------|
| 100 | AllowAppFromProxy | Inbound | 5001 | 10.0.2.0/24 | * | Allow |
| 110 | AllowSSHFromBastion | Inbound | 22 | 10.0.1.0/24 | * | Allow |

#### db-nsg (attached to db-subnet)

| Priority | Name | Direction | Port | Source | Destination | Action |
|----------|------|-----------|------|--------|-------------|--------|
| 100 | AllowPostgresFromApp | Inbound | 5432 | 10.0.3.0/24 | * | Allow |

#### keyvault-nsg (attached to keyvault-subnet)

| Priority | Name | Direction | Port | Source | Destination | Action |
|----------|------|-----------|------|--------|-------------|--------|
| 100 | AllowHTTPSFromApp | Inbound | 443 | 10.0.3.0/24 | * | Allow |

### 1.5 Verification Commands

```bash
# Verify resource group
az group show --name flask-ultimate-rg --query "properties.provisioningState"

# Verify VNet and subnets
az network vnet subnet list --resource-group flask-ultimate-rg --vnet-name flask-ultimate-vnet \
  --query "[].{Name:name, Prefix:addressPrefix}" -o table

# Verify NSGs attached to subnets
az network vnet subnet list --resource-group flask-ultimate-rg --vnet-name flask-ultimate-vnet \
  --query "[].{Subnet:name, NSG:networkSecurityGroup.id}" -o table
```

---

## Phase 2: Key Vault

### 2.1 Key Vault Configuration

```
Name: flask-kv-{unique-suffix}
Location: swedencentral
SKU: Standard
Soft Delete: Enabled (7 days retention)
RBAC Authorization: Enabled (default)
Public Network Access: Enabled
```

Note: Private endpoints are not used in this implementation for simplicity. Key Vault uses RBAC for access control.

### 2.2 Secrets to Store

| Secret Name | Value | Description |
|-------------|-------|-------------|
| postgresql-admin-password | FlaskDB-{suffix}! | Database admin password (auto-generated) |
| secret-key | (openssl rand -hex 32) | Flask application secret key |
| database-url | postgresql://flaskadmin:{password}@{host}:5432/contactform | Full connection string |

### 2.3 Verification Commands

```bash
# Verify Key Vault
az keyvault show --name flask-kv-xxx --query "properties.provisioningState"

# Verify secrets exist (not values)
az keyvault secret list --vault-name flask-kv-xxx --query "[].name" -o tsv
```

---

## Phase 3: PostgreSQL

### 3.1 PostgreSQL Flexible Server

```
Name: flask-db-{unique-suffix}
Location: swedencentral
Version: 17
SKU: Standard_B1ms (Burstable, 1 vCore, 2 GB RAM)
Storage: 32 GB
Admin Username: flaskadmin
Admin Password: (from Key Vault)
Public Network Access: Enabled (with firewall rules)
```

Note: Private endpoints are not used. PostgreSQL uses public access with Azure Services firewall rule.

### 3.2 Database

```
Name: contactform
Charset: UTF8
```

### 3.3 Firewall Rules

| Rule Name | Start IP | End IP | Purpose |
|-----------|----------|--------|---------|
| AllowAzureServices | 0.0.0.0 | 0.0.0.0 | Allow Azure internal services |

### 3.4 Verification Commands

```bash
# Verify server
az postgres flexible-server show --resource-group flask-ultimate-rg \
  --name flask-db-xxx --query "state"

# Verify database
az postgres flexible-server db show --resource-group flask-ultimate-rg \
  --server-name flask-db-xxx --database-name contactform
```

---

## Phase 4: Bastion VM

### 4.1 Public IP

```
Name: flask-ultimate-bastion-pip
SKU: Basic
Allocation: Dynamic
```

### 4.2 Network Interface

```
Name: flask-ultimate-bastion-nic
Subnet: bastion-subnet
Public IP: flask-ultimate-bastion-pip
Private IP: Dynamic (10.0.1.x)
```

### 4.3 Virtual Machine

```
Name: flask-ultimate-bastion
Size: Standard_B1s
Image: Ubuntu Server 24.04 LTS
Admin Username: azureuser
Authentication: SSH Public Key
OS Disk: Standard LRS, 30 GB
```

### 4.4 Cloud-Init Configuration

See `infrastructure/cloud-init-bastion.yaml`:
- fail2ban for SSH brute-force protection
- SSH hardening (disable password auth, root login)
- UFW firewall

### 4.5 Verification Commands

```bash
# Get public IP
BASTION_IP=$(az vm show --resource-group flask-ultimate-rg --name flask-ultimate-bastion \
  --show-details --query "publicIps" -o tsv)

# Test SSH
ssh azureuser@$BASTION_IP "echo 'Bastion SSH works'"

# Verify cloud-init
ssh azureuser@$BASTION_IP "cloud-init status"

# Verify fail2ban
ssh azureuser@$BASTION_IP "sudo fail2ban-client status sshd"
```

---

## Phase 5: Reverse Proxy VM

### 5.1 Public IP

```
Name: flask-ultimate-proxy-pip
SKU: Basic
Allocation: Dynamic
```

### 5.2 Network Interface

```
Name: flask-ultimate-proxy-nic
Subnet: proxy-subnet
Public IP: flask-ultimate-proxy-pip
Private IP: Dynamic (10.0.2.x)
```

### 5.3 Virtual Machine

```
Name: flask-ultimate-proxy
Size: Standard_B1s
Image: Ubuntu Server 24.04 LTS
Admin Username: azureuser
Authentication: SSH Public Key
OS Disk: Standard LRS, 30 GB
```

### 5.4 Cloud-Init Configuration

See `infrastructure/cloud-init-proxy.yaml`:
- nginx installation
- fail2ban for SSH and HTTP protection
- Self-signed SSL certificate generation
- DH parameters for SSL
- SSH hardening
- SSL parameters snippet

### 5.5 nginx Configuration

The nginx site configuration is deployed via `deploy.sh` after the app server IP is known. See `deploy/nginx/flask-contact-form.conf`.

### 5.6 Verification Commands

```bash
# Get proxy public IP
PROXY_IP=$(az vm show --resource-group flask-ultimate-rg --name flask-ultimate-proxy \
  --show-details --query "publicIps" -o tsv)

# Test SSH via bastion
ssh -J azureuser@$BASTION_IP azureuser@10.0.2.4 "echo 'Proxy SSH via bastion works'"

# Verify nginx
ssh -J azureuser@$BASTION_IP azureuser@10.0.2.4 "nginx -v"

# Verify SSL cert
ssh -J azureuser@$BASTION_IP azureuser@10.0.2.4 "sudo ls /etc/ssl/private/flask-selfsigned.key"
```

---

## Phase 6: App Server VM

### 6.1 Network Interface (NO Public IP)

```
Name: flask-ultimate-app-nic
Subnet: app-subnet
Public IP: None
Private IP: Dynamic (10.0.3.x)
```

### 6.2 Virtual Machine

```
Name: flask-ultimate-app
Size: Standard_B1s
Image: Ubuntu Server 24.04 LTS
Admin Username: azureuser
Authentication: SSH Public Key
OS Disk: Standard LRS, 30 GB
Managed Identity: System-assigned (enabled)
```

### 6.3 Key Vault Access (RBAC)

```
Identity: flask-ultimate-app system-assigned managed identity
Role: Key Vault Secrets User
Scope: Key Vault resource
```

### 6.4 Cloud-Init Configuration

See `infrastructure/cloud-init-app-server.yaml`:
- Python 3.12 and venv
- PostgreSQL client
- Azure CLI (for managed identity)
- Application and log directories
- SSH hardening

### 6.5 Verification Commands

```bash
# Get app private IP
APP_PRIVATE_IP=$(az vm show --resource-group flask-ultimate-rg --name flask-ultimate-app \
  --show-details --query "privateIps" -o tsv)

# Verify NO public IP
az vm show --resource-group flask-ultimate-rg --name flask-ultimate-app \
  --show-details --query "publicIps"
# Expected: null or empty

# Test SSH via bastion
ssh -J azureuser@$BASTION_IP azureuser@$APP_PRIVATE_IP "echo 'App server SSH via bastion works'"

# Verify cloud-init
ssh -J azureuser@$BASTION_IP azureuser@$APP_PRIVATE_IP "cloud-init status"

# Verify Python
ssh -J azureuser@$BASTION_IP azureuser@$APP_PRIVATE_IP "python3 --version"

# Verify managed identity can access Key Vault
ssh -J azureuser@$BASTION_IP azureuser@$APP_PRIVATE_IP "
  az login --identity --allow-no-subscriptions
  az keyvault secret list --vault-name flask-kv-xxx --query '[].name' -o tsv
"
```

---

## Deployment Scripts

### provision.sh

Main script that provisions all infrastructure in the correct order:

1. Create resource group
2. Create network (VNet, subnets, NSGs)
3. Create Key Vault and store secrets (database password, secret key)
4. Create PostgreSQL Flexible Server and database
5. Store database URL in Key Vault
6. Create Bastion VM with cloud-init
7. Create Proxy VM with cloud-init
8. Create App Server VM with managed identity and cloud-init
9. Grant Key Vault RBAC access to App Server

### deploy.sh

Main script that deploys the application:

1. Wait for cloud-init completion on all VMs
2. Sync application files to app server via bastion (rsync)
3. Create virtual environment and install dependencies
4. Configure environment file with Key Vault URL
5. Install and start systemd service
6. Configure nginx on proxy VM with app server IP
7. Run database migrations
8. Verify deployment with health check

---

## Complete Provisioning Sequence

```bash
# Navigate to stage-ultimate directory
cd reference/stage-ultimate

# 1. Provision infrastructure (15-20 minutes)
cd infrastructure
chmod +x provision.sh
./provision.sh

# 2. Wait for cloud-init (2-3 minutes after VMs created)

# 3. Deploy application (3-5 minutes)
cd ../deploy
chmod +x deploy.sh
./deploy.sh

# 4. Access application
PROXY_IP=$(az vm show -g flask-ultimate-rg -n flask-ultimate-proxy --show-details -o tsv --query publicIps)
echo "https://$PROXY_IP/"
```

---

## Cleanup

```bash
# Delete everything
az group delete --name flask-ultimate-rg --yes --no-wait

# Wait for deletion, then purge Key Vault (if soft-deleted)
az keyvault purge --name flask-kv-xxx --location swedencentral
```
