# Stage IaaS Flask

A complete Flask application deployment on Azure using pure IaaS components and Bicep infrastructure-as-code.

> See [../README.md](../README.md) for the stage naming convention.

**This implementation (`stage-iaas-flask`)** represents the pure IaaS baseline:

- All compute runs on self-managed VMs
- Networking uses NSGs and ASGs (no Azure Firewall or WAF)
- Database uses Azure PostgreSQL Flexible Server (the one PaaS exception for practicality)
- No Key Vault, no managed identities, no Azure Bastion service
- Traditional Linux administration (systemd, nginx config files)

## Table of Contents

- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Naming Conventions](#naming-conventions)
- [Configuration](#configuration)
- [Script Dependencies](#script-dependencies)
- [Deployment Flow](#deployment-flow)
- [Prerequisites](#prerequisites)
- [Resources Created](#resources-created)
- [Cost Estimate](#cost-estimate)
- [Manual Deployment](#manual-deployment)
- [Troubleshooting](#troubleshooting)

## Architecture

```
Internet
    │
    ├── SSH (22) ────→ Bastion VM ─── SSH ───→ Internal VMs
    │                  (10.0.1.x)
    │
    └── HTTPS (443) ─→ Proxy VM ─── HTTP (5001) ──→ App VM
                       (10.0.2.x)                   (10.0.3.x)
                       nginx                        Flask/Gunicorn
                                                        │
                                                        └──→ PostgreSQL (Azure PaaS)
```

## Quick Start

```bash
# Deploy everything (15-25 minutes)
./deploy-all.sh

# Tear down all resources
./delete-all.sh
```

## Project Structure

```
stage-iaas-flask/
├── deploy-all.sh              # One-command full deployment
├── delete-all.sh              # Tear down all resources
│
├── infrastructure/            # Azure resource provisioning
│   ├── provision.sh          # Main provisioning script
│   ├── main.bicep            # Bicep entry point
│   ├── parameters.json       # Generated secrets (gitignored)
│   ├── modules/              # Bicep modules (network, VMs, database)
│   ├── cloud-init/           # VM configuration (YAML)
│   └── scripts/              # Provisioning helpers
│
├── application/               # Flask application source
│   ├── app.py                # Application factory
│   ├── models.py             # SQLAlchemy models
│   ├── requirements.txt      # Python dependencies
│   └── templates/            # Jinja2 templates
│
├── deploy/                    # Application deployment
│   └── deploy.sh             # Copy code, configure, start service
│
├── scripts/                   # Deployment monitoring
│   ├── wait-for-postgresql.sh
│   ├── wait-for-vms-cloud-init.sh
│   ├── wait-for-flask-app.sh
│   └── verification-tests.sh
│
├── config.sh                  # Central configuration (all shared variables)
└── LESSONS-LEARNED.md         # Issues encountered and solutions
```

## Naming Conventions

This project follows consistent naming conventions across all components. All configuration is centralized in `config.sh`.

### Azure Resource Naming

Resources follow the [Azure Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) naming conventions:

| Resource Type | Pattern | Example | Variable |
|---------------|---------|---------|----------|
| Resource Group | `rg-{project}-{env}` | `rg-flask-bicep-dev` | `$RESOURCE_GROUP` |
| Virtual Network | `vnet-{project}-{env}` | `vnet-flask-bicep-dev` | `$VNET_NAME` |
| Subnet | `snet-{tier}` | `snet-bastion`, `snet-web`, `snet-app`, `snet-data` | — |
| Network Security Group | `nsg-{tier}` | `nsg-bastion`, `nsg-web`, `nsg-app`, `nsg-data` | — |
| Application Security Group | `asg-{role}` | `asg-bastion`, `asg-proxy`, `asg-app` | — |
| Virtual Machine | `vm-{role}` | `vm-bastion`, `vm-proxy`, `vm-app` | `$VM_BASTION`, `$VM_PROXY`, `$VM_APP` |
| Public IP | `pip-{role}` | `pip-bastion`, `pip-proxy` | — |
| Network Interface | `nic-{role}` | `nic-bastion`, `nic-proxy`, `nic-app` | — |
| PostgreSQL Server | `psql-{project}-{env}` | `psql-flask-bicep-dev` | `$POSTGRES_SERVER` |

**Prefix Reference:**
- `rg-` = Resource Group
- `vnet-` = Virtual Network
- `snet-` = Subnet
- `nsg-` = Network Security Group
- `asg-` = Application Security Group
- `vm-` = Virtual Machine
- `pip-` = Public IP
- `nic-` = Network Interface Card
- `psql-` = PostgreSQL Flexible Server

### Network Tier Architecture

The project uses a 4-tier network architecture with consistent naming across subnets, NSGs, and ASGs:

| Tier | Subnet | CIDR | NSG | ASG | VM | Purpose |
|------|--------|------|-----|-----|-----|---------|
| **Bastion** | `snet-bastion` | 10.0.1.0/24 | `nsg-bastion` | `asg-bastion` | `vm-bastion` | SSH jump host (public) |
| **Web** | `snet-web` | 10.0.2.0/24 | `nsg-web` | `asg-proxy` | `vm-proxy` | nginx reverse proxy (public) |
| **App** | `snet-app` | 10.0.3.0/24 | `nsg-app` | `asg-app` | `vm-app` | Flask application (internal) |
| **Data** | `snet-data` | 10.0.4.0/24 | `nsg-data` | — | — | PostgreSQL (PaaS) |

### Shell Script Variables

All shell scripts use `UPPERCASE_SNAKE_CASE` for variables:

```bash
# Project identity (from config.sh)
PROJECT="flask-bicep"
ENVIRONMENT="dev"
LOCATION="swedencentral"

# Derived resource names
RESOURCE_GROUP="rg-${PROJECT}-${ENVIRONMENT}"
POSTGRES_SERVER="psql-${PROJECT}-${ENVIRONMENT}"

# VM names
VM_BASTION="vm-bastion"
VM_PROXY="vm-proxy"
VM_APP="vm-app"
```

### Bicep Variables

Bicep templates use `camelCase` for parameters and variables:

```bicep
// Parameters
param location string
param environment string = 'dev'
param project string = 'flask-bicep'

// Variables
var baseName = '${project}-${environment}'
var vnetName = 'vnet-${baseName}'
var postgresServerName = 'psql-${baseName}'
```

### File Naming

| Category | Pattern | Examples |
|----------|---------|----------|
| Shell scripts | `{action}-{target}.sh` or `{phase}.sh` | `deploy-all.sh`, `provision.sh`, `wait-for-postgresql.sh` |
| Bicep modules | `{resource-type}.bicep` | `network.bicep`, `bastion.bicep`, `database.bicep` |
| Cloud-init | `{vm-role}.yaml` | `bastion.yaml`, `proxy.yaml`, `app.yaml` |
| Python files | `{purpose}.py` | `app.py`, `wsgi.py` |

### System Paths (Cloud-init)

| Path | Purpose | Convention |
|------|---------|------------|
| `/opt/flask-app/` | Application directory | Standard `/opt/` for add-on software |
| `/etc/flask-app/app.env` | Environment variables | App-specific config under `/etc/` |
| `/etc/systemd/system/flask-app.service` | Systemd unit | Matches application name |
| `/etc/nginx/sites-available/flask-app` | nginx site config | Matches application name |

## Configuration

All shared configuration is centralized in `config.sh` at the project root. Scripts source this file to access common variables and helper functions.

### Using config.sh

```bash
# From project root
source "./config.sh"

# From subdirectory (e.g., scripts/)
source "$(dirname "${BASH_SOURCE[0]}")/../config.sh"
```

### Available Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `$PROJECT` | `flask-bicep` | Project name |
| `$ENVIRONMENT` | `dev` | Environment name |
| `$LOCATION` | `swedencentral` | Azure region |
| `$RESOURCE_GROUP` | `rg-flask-bicep-dev` | Resource group name |
| `$POSTGRES_SERVER` | `psql-flask-bicep-dev` | PostgreSQL server name |
| `$POSTGRES_HOST` | `psql-flask-bicep-dev.postgres.database.azure.com` | PostgreSQL FQDN |
| `$DATABASE_NAME` | `flask` | Database name |
| `$VM_BASTION` | `vm-bastion` | Bastion VM name |
| `$VM_PROXY` | `vm-proxy` | Proxy VM name |
| `$VM_APP` | `vm-app` | App VM name |
| `$VM_ADMIN_USER` | `azureuser` | VM admin username |
| `$SSH_OPTS` | (see config.sh) | SSH connection options |

### Helper Functions

```bash
# Get public IP of any VM
get_vm_public_ip "vm-bastion"

# SSH to internal VM through bastion
ssh_via_bastion "vm-app" "command to run"

# SCP to internal VM through bastion
scp_via_bastion "/local/path" "vm-app:/remote/path"
```

## Script Dependencies

The scripts are organized to minimize cross-directory dependencies:

| Directory | Scripts | Dependencies |
|-----------|---------|--------------|
| `infrastructure/` | `provision.sh` | Self-contained |
| `infrastructure/scripts/` | `init-secrets.sh`, `validate-password.sh` | Within `infrastructure/` only |
| `scripts/` | `wait-for-*.sh`, `verification-tests.sh` | Self-contained (Azure CLI) |
| `deploy/` | `deploy.sh` | `infrastructure/parameters.json`, `application/` |
| Root | `deploy-all.sh` | Orchestrates all directories |
| Root | `delete-all.sh` | Self-contained (Azure CLI) |

**Design principle:** Each directory is self-contained except for necessary data dependencies:
- `deploy/deploy.sh` needs database credentials from `infrastructure/parameters.json`
- `deploy/deploy.sh` needs source code from `application/`

## Deployment Flow

```
deploy-all.sh
    │
    ├─→ infrastructure/provision.sh
    │       ├─→ scripts/init-secrets.sh (if needed)
    │       ├─→ scripts/validate-password.sh
    │       └─→ az deployment (main.bicep)
    │
    ├─→ scripts/wait-for-postgresql.sh
    │
    ├─→ scripts/wait-for-vms-cloud-init.sh
    │
    ├─→ deploy/deploy.sh
    │       └─→ SCP files, pip install, configure, start service
    │
    ├─→ scripts/wait-for-flask-app.sh
    │
    └─→ scripts/verification-tests.sh
```

## Prerequisites

- Azure CLI installed and logged in (`az login`)
- jq installed (`brew install jq`)
- SSH key at `~/.ssh/id_rsa.pub` or `~/.ssh/id_ed25519.pub`

## Resources Created

| Resource | Name | Purpose |
|----------|------|---------|
| Resource Group | `rg-flask-bicep-dev` | Container for all resources |
| Virtual Network | `vnet-flask-bicep-dev` | Network isolation |
| Bastion VM | `vm-bastion` | SSH jump host |
| Proxy VM | `vm-proxy` | nginx reverse proxy |
| App VM | `vm-app` | Flask application |
| PostgreSQL | `psql-flask-bicep-dev` | Database (Flexible Server) |

## Cost Estimate

~$40-50/month (all resources use lowest-cost tiers)

## Manual Deployment

If you prefer to run steps individually:

```bash
# 1. Provision infrastructure
./infrastructure/provision.sh

# 2. Wait for PostgreSQL (5-15 minutes)
./scripts/wait-for-postgresql.sh

# 3. Wait for VMs to configure (2-5 minutes)
./scripts/wait-for-vms-cloud-init.sh

# 4. Deploy application
./deploy/deploy.sh

# 5. Verify health
./scripts/wait-for-flask-app.sh

# 6. Run tests (optional)
./scripts/verification-tests.sh
```

## Troubleshooting

See [LESSONS-LEARNED.md](LESSONS-LEARNED.md) for common issues and solutions:

1. Cloud-init `users:` directive replacing default users
2. SSH ProxyJump host key verification failures
3. Database not created automatically
4. Bicep linter warnings
5. Cloud-init embedded in Bicep files
6. Environment file naming
7. Script naming and organization
8. Hardcoded file lists in deployment
