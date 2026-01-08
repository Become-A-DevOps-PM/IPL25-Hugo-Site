# Deployment

## Azure IaaS Deployment Architecture

This document shows how the Webinar Registration Website is deployed on Azure infrastructure using a pure IaaS approach.

### Deployment Diagram

![](embed:Deployment)

### Infrastructure Overview

#### Network Topology

| Subnet | CIDR | NSG | Purpose |
|--------|------|-----|---------|
| `snet-bastion` | 10.0.1.0/24 | `nsg-bastion` | SSH jump host (public access) |
| `snet-web` | 10.0.2.0/24 | `nsg-web` | Reverse proxy (public access) |
| `snet-app` | 10.0.3.0/24 | `nsg-app` | Application server (internal only) |
| `snet-data` | 10.0.4.0/24 | `nsg-data` | PostgreSQL database (internal only) |

#### Virtual Machines

| VM | Subnet | Public IP | Size | Purpose |
|----|--------|-----------|------|---------|
| `vm-bastion` | snet-bastion | Yes | Standard_B1s | SSH jump server |
| `vm-proxy` | snet-web | Yes | Standard_B1s | nginx reverse proxy |
| `vm-app` | snet-app | No | Standard_B1s | Flask application |

#### Managed Services

| Service | SKU | Purpose |
|---------|-----|---------|
| PostgreSQL Flexible Server | Burstable B1ms | Database (the only PaaS component) |

### Security Architecture

#### Network Security Groups (NSGs)

Each subnet has an NSG controlling inbound/outbound traffic:

**nsg-bastion**:
- Allow SSH (22) from Internet
- Deny all other inbound

**nsg-web**:
- Allow HTTP (80) from Internet
- Allow HTTPS (443) from Internet
- Allow SSH (22) from asg-bastion
- Deny all other inbound

**nsg-app**:
- Allow HTTP (5001) from asg-proxy
- Allow SSH (22) from asg-bastion
- Deny all other inbound

**nsg-data**:
- Allow PostgreSQL (5432) from snet-app
- Deny all other inbound

#### Application Security Groups (ASGs)

ASGs provide role-based security rules:

| ASG | Members | Purpose |
|-----|---------|---------|
| `asg-bastion` | vm-bastion | Source for SSH to internal VMs |
| `asg-proxy` | vm-proxy | Source for HTTP to app server |
| `asg-app` | vm-app | Target for application traffic |

### Deployment Process

#### Infrastructure Provisioning

```bash
# One-command deployment
./deploy-all.sh

# Or step-by-step:
./infrastructure/provision.sh      # Deploy Bicep (15-20 min)
./scripts/wait-for-postgresql.sh   # Wait for DB ready
./scripts/wait-for-vms-cloud-init.sh  # Wait for VMs configured
./deploy/deploy.sh                 # Deploy application
./scripts/verification-tests.sh    # Run tests
```

#### Cloud-init Configuration

Each VM is configured automatically via cloud-init:

| VM | Cloud-init | Key Configuration |
|----|------------|-------------------|
| vm-bastion | `bastion.yaml` | fail2ban, SSH hardening |
| vm-proxy | `proxy.yaml` | nginx, self-signed SSL cert |
| vm-app | `app.yaml` | Python venv, systemd service, flask-app user |

#### Application Deployment

The Flask application is deployed via SSH through the bastion:

```
1. SCP files to vm-app via bastion jump
2. Install Python dependencies in virtualenv
3. Configure DATABASE_URL in /etc/flask-app/app.env
4. Start flask-app systemd service
```

### Cost Estimate

| Resource | SKU | Monthly Cost |
|----------|-----|--------------|
| 3x VMs | Standard_B1s | ~$21 ($7 each) |
| PostgreSQL | Burstable B1ms | ~$12 |
| Public IPs | 2x Static | ~$8 |
| Storage | 3x 30GB | ~$3 |
| **Total** | | **~$44/month** |

### Naming Conventions

Following Azure Cloud Adoption Framework (CAF):

| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Resource Group | `rg-{project}-{env}` | `rg-flask-bicep-dev` |
| Virtual Network | `vnet-{project}-{env}` | `vnet-flask-bicep-dev` |
| Subnet | `snet-{tier}` | `snet-bastion` |
| NSG | `nsg-{tier}` | `nsg-web` |
| VM | `vm-{role}` | `vm-proxy` |
| PostgreSQL | `psql-{project}-{env}` | `psql-flask-bicep-dev` |

### Infrastructure as Code

All infrastructure is defined in Bicep:

```
infrastructure/
├── main.bicep              # Entry point
└── modules/
    ├── network.bicep       # VNet, subnets, NSGs, ASGs
    ├── bastion.bicep       # Jump host VM
    ├── proxy.bicep         # Reverse proxy VM
    ├── app.bicep           # Application VM
    └── database.bicep      # PostgreSQL + private DNS
```

### Related Documentation

- [Overview](01-overview.md) - Project overview
- [System Context](02-context.md) - C1 diagram
- [Containers](03-containers.md) - C2 diagram
- [Components](04-components.md) - C3 diagram
