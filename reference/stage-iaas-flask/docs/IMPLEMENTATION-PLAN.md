# Flask Application on Azure - Implementation Plan

This document outlines the implementation plan for deploying a minimal Flask application on Azure using Infrastructure as Code (Bicep) and cloud-init configuration.

---

## Quick Reference

| Topic | Location |
|-------|----------|
| **Central configuration** | `config.sh` |
| **Bicep templates** | `infrastructure/` |
| **Cloud-init files** | `infrastructure/cloud-init/` |
| **Deployment scripts** | `scripts/`, `deploy/` |
| **Flask application** | `application/` |

---

## Prerequisites

Before running the deployment, ensure you have:

| Requirement | Command to Check | Installation |
|-------------|------------------|--------------|
| Azure CLI | `az --version` | `brew install azure-cli` |
| Azure Login | `az account show` | `az login` |
| jq (JSON processor) | `jq --version` | `brew install jq` |
| SSH Key | `ls ~/.ssh/id_rsa.pub` | `ssh-keygen -t rsa -b 4096` |

**Azure Subscription:** An active Azure subscription with permissions to create Resource Groups, Virtual Networks, Virtual Machines (Standard_B1s), PostgreSQL Flexible Server, and Network Security Groups.

**Estimated cost:** ~$44/month (see Technology Stack section for breakdown)

---

## Overview

### Purpose

Deploy a simple Flask application in a **three-tier infrastructure architecture** on Azure:

1. **Web Tier** - Reverse proxy (nginx) for SSL termination and request routing
2. **Application Tier** - Flask application server (Gunicorn)
3. **Data Tier** - Managed PostgreSQL database

Additional infrastructure:
- Bastion host for secure SSH management access
- Network segmentation with dedicated subnets per tier
- Private connectivity to database (no public endpoint)

### Deployment Strategy

The deployment follows a **two-stage approach**:

1. **Infrastructure Provisioning (Bicep + cloud-init)**
   - Bicep templates create all Azure resources (including the `flask` database)
   - Cloud-init configures VMs with required software and services
   - Cloud-init does **NOT** deploy application code

2. **Application Deployment (Bash script via SSH jump)**
   - Separate `deploy/deploy.sh` script copies application files to the app server
   - Uses SSH ProxyCommand through the bastion host
   - Runs from the local development machine

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ Azure (Resource Group: rg-flask-bicep-dev)                                      │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │ Virtual Network: vnet-flask-bicep-dev (10.0.0.0/16)                       │  │
│  │                                                                           │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐           │  │
│  │  │ snet-bastion    │  │ snet-web        │  │ snet-app        │           │  │
│  │  │ 10.0.1.0/24     │  │ 10.0.2.0/24     │  │ 10.0.3.0/24     │           │  │
│  │  │                 │  │                 │  │                 │           │  │
│  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │           │  │
│  │  │  │ vm-bastion│  │  │  │ vm-proxy  │  │  │  │ vm-app    │  │           │  │
│  │  │  │ fail2ban  │──┼──┼─▶│ nginx     │──┼──┼─▶│ Gunicorn  │  │           │  │
│  │  │  └───────────┘  │  │  │ :80/:443  │  │  │  │ Flask     │  │           │  │
│  │  │       │         │  │  └───────────┘  │  │  │ :5001     │  │           │  │
│  │  │       │ SSH:22  │  │       ▲         │  │  └─────┬─────┘  │           │  │
│  │  └───────┼─────────┘  └───────┼─────────┘  └────────┼────────┘           │  │
│  │          │                    │                     │                    │  │
│  │          │              ┌─────┴─────┐               │                    │  │
│  │          │              │ pip-proxy │               │                    │  │
│  │          │              │ Public IP │               │                    │  │
│  │          │              └───────────┘               │                    │  │
│  │    ┌─────┴─────┐                              ┌─────┴─────────────────┐  │  │
│  │    │pip-bastion│                              │ snet-data             │  │  │
│  │    │ Public IP │                              │ 10.0.4.0/24           │  │  │
│  │    └───────────┘                              │                       │  │  │
│  │                                               │  ┌─────────────────┐  │  │  │
│  │                                               │  │ psql-flask-bicep│  │  │  │
│  │                                               │  │ PostgreSQL      │  │  │  │
│  │                                               │  │ Flexible Server │  │  │  │
│  │                                               │  │ :5432           │  │  │  │
│  │                                               │  │ (VNet Integr.)  │  │  │  │
│  │                                               │  └─────────────────┘  │  │  │
│  │                                               └───────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘

Traffic Flows:
─────────────
Browser ──HTTP/HTTPS──▶ pip-proxy ──▶ vm-proxy:80/443 ──▶ vm-app:5001 ──▶ psql:5432
SSH     ──────────────▶ pip-bastion ──▶ vm-bastion:22 ──▶ (internal VMs):22
```

---

## Technology Stack

| Layer | Technology | Version | Notes |
|-------|------------|---------|-------|
| **Infrastructure** |
| IaC | Bicep | Latest | Azure-native, type-safe |
| VM Config | cloud-init | cloud-config | Declarative YAML |
| Region | Sweden Central | - | `swedencentral` |
| **Compute** |
| VM Size | Standard_B1s | - | 1 vCPU, 1 GiB RAM (~$7/month) |
| OS | Ubuntu | 24.04 LTS | Per course standards |
| **Application** |
| Language | Python | 3.12+ | Ubuntu 24.04 default |
| Framework | Flask | 3.0+ | Minimal application |
| WSGI | Gunicorn | Latest | Production server |
| **Web** |
| Reverse Proxy | nginx | 1.24+ | SSL termination |
| SSL | Self-signed | - | For learning environment |
| **Database** |
| Service | PostgreSQL Flexible Server | 16 | Azure managed |
| Tier | Burstable B1ms | - | 1 vCore, 2 GiB (~$12/month) |

### Estimated Monthly Cost

| Resource | Cost |
|----------|------|
| 3x Standard_B1s VMs | ~$21 |
| PostgreSQL B1ms | ~$12 |
| Storage (32 GiB) | ~$4 |
| Public IPs (2x) | ~$7 |
| **Total** | **~$44/month** |

---

## Network Design

### Address Space

| Network | CIDR | Purpose |
|---------|------|---------|
| Virtual Network | 10.0.0.0/16 | 65,536 addresses |
| snet-bastion | 10.0.1.0/24 | Bastion host |
| snet-web | 10.0.2.0/24 | Reverse proxy |
| snet-app | 10.0.3.0/24 | Application server |
| snet-data | 10.0.4.0/24 | PostgreSQL (delegated) |

### Network Security Groups

#### nsg-bastion (Bastion Subnet)

| Priority | Name | Direction | Source | Destination | Port | Action |
|----------|------|-----------|--------|-------------|------|--------|
| 100 | AllowSSHInbound | Inbound | Internet | asg-bastion | 22 | Allow |
| 1000 | DenyAllInbound | Inbound | * | * | * | Deny |

#### nsg-web (Web Subnet)

| Priority | Name | Direction | Source | Destination | Port | Action |
|----------|------|-----------|--------|-------------|------|--------|
| 100 | AllowHTTPInbound | Inbound | Internet | asg-proxy | 80 | Allow |
| 110 | AllowHTTPSInbound | Inbound | Internet | asg-proxy | 443 | Allow |
| 120 | AllowSSHFromBastion | Inbound | asg-bastion | asg-proxy | 22 | Allow |
| 1000 | DenyAllInbound | Inbound | * | * | * | Deny |

#### nsg-app (App Subnet)

| Priority | Name | Direction | Source | Destination | Port | Action |
|----------|------|-----------|--------|-------------|------|--------|
| 100 | AllowAppFromProxy | Inbound | asg-proxy | asg-app | 5001 | Allow |
| 110 | AllowSSHFromBastion | Inbound | asg-bastion | asg-app | 22 | Allow |
| 1000 | DenyAllInbound | Inbound | * | * | * | Deny |

#### nsg-data (Data Subnet)

| Priority | Name | Direction | Source | Destination | Port | Action |
|----------|------|-----------|--------|-------------|------|--------|
| 100 | AllowPostgresFromApp | Inbound | 10.0.3.0/24 | * | 5432 | Allow |
| 1000 | DenyAllInbound | Inbound | * | * | * | Deny |

> **Note:** PostgreSQL Flexible Server is a PaaS service - uses CIDR range instead of ASG.

---

## Implementation Phases

### Phase 1: Network Foundation

**Objective:** Deploy the virtual network with all subnets and security groups.

**Resources created:**
- Virtual Network (10.0.0.0/16)
- 4 Subnets (bastion, web, app, data)
- 4 Network Security Groups
- 3 Application Security Groups

**Files:** `infrastructure/modules/network.bicep`

**Verification:**
```bash
az network vnet show -g rg-flask-bicep-dev -n vnet-flask-bicep-dev -o table
az network vnet subnet list -g rg-flask-bicep-dev --vnet-name vnet-flask-bicep-dev -o table
```

---

### Phase 2: Bastion Host

**Objective:** Deploy the bastion host with public IP and SSH hardening.

**Resources created:**
- Public IP (pip-bastion)
- Network Interface (nic-bastion)
- Virtual Machine (vm-bastion) with cloud-init

**Cloud-init configuration:** `infrastructure/cloud-init/bastion.yaml`
- fail2ban for brute-force protection
- SSH hardening (key-only, no root login)

**Files:** `infrastructure/modules/bastion.bicep`

---

### Phase 3: Reverse Proxy

**Objective:** Deploy the nginx reverse proxy with SSL termination.

**Resources created:**
- Public IP (pip-proxy)
- Network Interface (nic-proxy)
- Virtual Machine (vm-proxy) with cloud-init

**Cloud-init configuration:** `infrastructure/cloud-init/proxy.yaml`
- nginx installation and configuration
- Self-signed SSL certificate generation
- HTTP to HTTPS redirect

**Files:** `infrastructure/modules/proxy.bicep`

---

### Phase 4: Database

**Objective:** Deploy PostgreSQL Flexible Server with VNet integration.

**Resources created:**
- Private DNS Zone
- Virtual Network Link
- PostgreSQL Flexible Server (psql-flask-bicep-dev)
- Database (flask)

**Key configuration:**
- VNet integration (no public endpoint)
- Subnet delegation to PostgreSQL
- Private DNS for internal resolution

**Files:** `infrastructure/modules/database.bicep`

---

### Phase 5: Application Server

**Objective:** Deploy the Flask application server VM.

**Resources created:**
- Network Interface (nic-app) - no public IP
- Virtual Machine (vm-app) with cloud-init

**Cloud-init configuration:** `infrastructure/cloud-init/app.yaml`
- Python 3 and pip installation
- Virtual environment creation
- systemd service unit for Flask
- Directory structure and permissions

**Files:** `infrastructure/modules/app.bicep`

---

### Phase 6: Flask Application

**Objective:** Develop the minimal Flask application.

**Components:**
- `app.py` - Flask application with SQLAlchemy
- `wsgi.py` - Gunicorn entry point
- `requirements.txt` - Python dependencies
- `templates/` - Jinja2 HTML templates

**Features:**
- Health endpoint (`/health`)
- CRUD operations for entries
- PostgreSQL connectivity with SQLite fallback

**Files:** `application/`

---

### Phase 7: Application Deployment

**Objective:** Deploy Flask application code to vm-app via SSH jump.

**Process:**
1. Copy application files via SCP through bastion
2. Install Python dependencies in virtual environment
3. Configure database connection string
4. Enable and start systemd service

**Files:** `deploy/deploy.sh`

---

### Phase 8: End-to-End Verification

**Objective:** Verify the complete deployment works correctly.

**Tests:**
1. Health endpoint returns `{"status": "ok"}`
2. Homepage loads with correct content
3. Can create new entries (POST)
4. Entries persist in database
5. HTTPS works with certificate
6. App server has no public IP
7. Database has public access disabled

---

## File Structure

| File | Purpose |
|------|---------|
| `deploy-all.sh` | One-click deployment (provisions + deploys) |
| `config.sh` | Central configuration (resource names, locations) |
| `infrastructure/` | Bicep templates and cloud-init files |
| `scripts/` | Wait/polling scripts |
| `deploy/` | Application deployment script |
| `application/` | Flask application code |

---

## Central Configuration (config.sh)

All scripts source a central `config.sh` file to ensure consistency across the project. This pattern eliminates hardcoded values and makes the deployment easily customizable.

### Purpose

The central configuration file provides:

| Category | Contents |
|----------|----------|
| **Project identity** | Project name, environment, Azure region |
| **Derived resource names** | Resource group, VNet, PostgreSQL server names (using CAF conventions) |
| **VM names** | Bastion, proxy, and app server VM names |
| **Credentials** | VM admin username, database admin username |
| **SSH configuration** | Standard SSH options for non-interactive scripts |
| **Timing configuration** | Poll intervals and max attempts for wait scripts |
| **Helper functions** | `get_vm_public_ip()`, `ssh_via_bastion()`, `scp_via_bastion()` |

### Benefits

- **Single source of truth** - Change project name or environment in one place
- **Consistency** - All scripts use identical resource names
- **Reusability** - Helper functions eliminate duplicated SSH logic
- **Customization** - Fork project and modify only config.sh

---

## Deployment Commands

### One-Click Deployment

```bash
# From project root
./deploy-all.sh
```

This script:
1. Validates prerequisites (Azure CLI, jq, SSH key)
2. Creates resource group
3. Generates parameters.json from example
4. Deploys Bicep templates
5. Waits for PostgreSQL to be ready
6. Waits for cloud-init on all VMs
7. Deploys Flask application

### Manual Deployment

```bash
# 1. Create resource group
az group create -n rg-flask-bicep-dev -l swedencentral

# 2. Deploy infrastructure
az deployment group create \
  -g rg-flask-bicep-dev \
  -f infrastructure/main.bicep \
  -p infrastructure/parameters.json

# 3. Wait for resources
./scripts/wait-for-postgresql.sh
./scripts/wait-for-cloud-init.sh

# 4. Deploy application
./deploy/deploy.sh
```

---

## Cleanup

```bash
# Delete all resources
az group delete --name rg-flask-bicep-dev --yes --no-wait
```

