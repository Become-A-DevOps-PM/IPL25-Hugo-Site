# Deployment

## Simplified Azure Deployment Architecture

This document shows how the Flask Three-Tier Application is deployed on Azure using a simplified IaaS approach designed for learning environments.

### Deployment Diagram

![](embed:Deployment)

### Infrastructure Overview

#### Network Topology

| Subnet | CIDR | NSG | Purpose |
|--------|------|-----|---------|
| `snet-default` | 10.0.0.0/24 | `nsg-default` | Application server (public access) |

#### Virtual Machine

| VM | Subnet | Public IP | Size | Purpose |
|----|--------|-----------|------|---------|
| `vm-app` | snet-default | Yes (`pip-app`) | Standard_B1s | Combined nginx + Flask |

#### Managed Services

| Service | SKU | Purpose |
|---------|-----|---------|
| PostgreSQL Flexible Server | Burstable B1ms | Database (public access) |

### Security Architecture

#### Network Security Group (nsg-default)

Single NSG with simplified rules for learning environment:

| Priority | Name | Direction | Port | Source | Action |
|----------|------|-----------|------|--------|--------|
| 100 | AllowSSH | Inbound | 22 | Internet | Allow |
| 110 | AllowHTTP | Inbound | 80 | Internet | Allow |
| 120 | AllowHTTPS | Inbound | 443 | Internet | Allow |
| 65000 | DenyAllInbound | Inbound | * | * | Deny |

#### PostgreSQL Firewall

| Rule | Start IP | End IP | Purpose |
|------|----------|--------|---------|
| AllowAll | 0.0.0.0 | 255.255.255.255 | Learning environment only |

> **Warning**: Public PostgreSQL access is for learning only. Production environments must use private endpoints.

### Deployment Process

#### One-Command Deployment

```bash
# Deploy everything (10-15 minutes)
./deploy-all.sh
```

#### Step-by-Step Deployment

```bash
# 1. Provision Azure infrastructure
./infrastructure/provision.sh

# 2. Wait for PostgreSQL to be ready
./deploy/scripts/wait-for-postgresql.sh

# 3. Wait for VM cloud-init to complete
./deploy/scripts/wait-for-cloud-init.sh

# 4. Deploy the Flask application
./deploy/deploy.sh

# 5. Wait for application to be healthy
./deploy/scripts/wait-for-flask-app.sh

# 6. Run verification tests
./deploy/scripts/verification-tests.sh
```

#### Cloud-init Configuration

The VM is automatically configured via cloud-init (`app-server.yaml`):

| Component | Configuration |
|-----------|---------------|
| nginx | Reverse proxy with self-signed SSL |
| Python | Python 3, pip, virtual environment |
| fail2ban | SSH brute-force protection |
| flask-app user | System user for running application |
| systemd | flask-app.service unit |

#### Application Deployment

The Flask application is deployed via direct SSH/SCP:

```
1. SCP application files to /opt/flask-app/
2. Install Python dependencies in virtualenv
3. Configure DATABASE_URL in /etc/flask-app/app.env
4. Initialize database tables (db.create_all())
5. Restart flask-app systemd service
```

### Cost Estimate

| Resource | SKU | Monthly Cost |
|----------|-----|--------------|
| 1x VM | Standard_B1s | ~$7 |
| PostgreSQL | Burstable B1ms | ~$12 |
| Public IP | 1x Static | ~$4 |
| Storage | 30GB | ~$1 |
| **Total** | | **~$24/month** |

### Naming Conventions

Following Azure Cloud Adoption Framework (CAF):

| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Resource Group | `rg-{project}-{env}` | `rg-flask-dev` |
| Virtual Network | `vnet-{project}-{env}` | `vnet-flask-dev` |
| Subnet | `snet-{purpose}` | `snet-default` |
| NSG | `nsg-{purpose}` | `nsg-default` |
| VM | `vm-{role}` | `vm-app` |
| Public IP | `pip-{role}` | `pip-app` |
| PostgreSQL | `psql-{project}-{env}` | `psql-flask-dev` |

### Infrastructure as Code

All infrastructure is defined in Bicep:

```
infrastructure/
├── provision.sh              # Deployment orchestrator
├── main.bicep                # Entry point
├── modules/
│   ├── network.bicep         # VNet, subnet, NSG
│   ├── vm.bicep              # Application server VM
│   └── database.bicep        # PostgreSQL
├── cloud-init/
│   └── app-server.yaml       # VM configuration
├── scripts/
│   ├── init-secrets.sh       # Generate parameters.json
│   └── validate-password.sh  # Password validation
└── parameters.json           # GITIGNORED - secrets
```

### Verification Tests

The deployment runs 6 verification tests:

| Test | Endpoint | Expected |
|------|----------|----------|
| E1 | `/api/health` | `{"status": "ok"}` |
| E2 | `/` | Landing page HTML |
| E3 | `/demo` | Demo form HTML |
| E4 | `/api/entries` | JSON array |
| E5 | Database | `SELECT 1` succeeds |
| E6 | Schema | `entries` table exists |

### Troubleshooting

#### Check Service Status

```bash
VM_IP=$(az vm show -g rg-flask-dev -n vm-app --show-details -o tsv --query publicIps)
ssh azureuser@$VM_IP "sudo systemctl status flask-app"
ssh azureuser@$VM_IP "sudo systemctl status nginx"
```

#### View Logs

```bash
# Flask/Gunicorn logs
ssh azureuser@$VM_IP "sudo journalctl -u flask-app -n 50"

# nginx access log
ssh azureuser@$VM_IP "sudo tail -f /var/log/nginx/access.log"

# Cloud-init log
ssh azureuser@$VM_IP "sudo cat /var/log/cloud-init-output.log"
```

#### Database Connection

```bash
# Check environment variable
ssh azureuser@$VM_IP "sudo cat /etc/flask-app/app.env"

# Test connection
ssh azureuser@$VM_IP 'eval $(sudo cat /etc/flask-app/app.env) && psql "$DATABASE_URL" -c "SELECT 1;"'
```

### Related Documentation

- [Overview](01-overview.md) - Project overview
- [System Context](02-context.md) - C1 diagram
- [Containers](03-containers.md) - C2 diagram
- [Components](04-components.md) - C3 diagram
