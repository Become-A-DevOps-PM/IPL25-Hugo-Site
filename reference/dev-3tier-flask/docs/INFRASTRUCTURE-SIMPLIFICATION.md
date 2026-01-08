# Infrastructure Simplification Plan

This document describes the infrastructure simplification from a complex 3-VM architecture to a simplified single-VM deployment, designed to help students focus on application development.

## Table of Contents

1. [Motivation](#motivation)
2. [Architecture Comparison](#architecture-comparison)
3. [Implementation Steps](#implementation-steps)
4. [File Changes](#file-changes)
5. [Resource Specifications](#resource-specifications)

---

## Motivation

### Problem Statement

The original infrastructure (based on stage-ultimate patterns) provides production-grade security but creates barriers for learning Flask application development:

| Challenge | Impact on Learning |
|-----------|-------------------|
| 3 VMs to manage | Confusion about where problems occur |
| SSH via bastion jump host | Complex debugging workflow |
| 4 subnets with NSGs | Networking issues mask application bugs |
| 20-40 minute deployments | Slow iteration cycles |
| ~$44/month cost | Budget constraints for students |

### Solution

Simplify the infrastructure to a single-VM architecture that:
- Provides a real Azure deployment target
- Enables direct debugging with SSH
- Reduces deployment time to 10-15 minutes
- Lowers cost to ~$20/month
- Clearly shows the request flow: Browser → nginx → Flask → PostgreSQL

---

## Architecture Comparison

### Before: Complex 3-VM Architecture

```
Internet
    │
    ├──SSH (22)────→ vm-bastion ──SSH──→ Internal VMs
    │                (10.0.1.x)           snet-bastion
    │                │
    │                └──SSH──→ vm-proxy (10.0.2.x)
    │                └──SSH──→ vm-app (10.0.3.x)
    │
    └──HTTPS (443)─→ vm-proxy ──HTTP (5001)──→ vm-app
                     (10.0.2.x)                (10.0.3.x)
                     snet-web                  snet-app
                                                   │
                                                   └──→ PostgreSQL
                                                        (10.0.4.x)
                                                        snet-data
                                                        Private DNS

Resources: 3 VMs, 4 subnets, 4 NSGs, 3 ASGs, Private DNS Zone
Bicep Modules: 5 (network, bastion, proxy, app, database)
Cloud-init Scripts: 3 (bastion.yaml, proxy.yaml, app.yaml)
```

### After: Simplified Single-VM Architecture

```
Internet
    │
    ├──SSH (22)─────────→ vm-app ──────────→ PostgreSQL
    │                     (10.0.0.x)          (Azure PaaS)
    │                     snet-default        Public Access
    │
    └──HTTP/HTTPS (80/443)──┘

Resources: 1 VM, 1 subnet, 1 NSG, Public PostgreSQL
Bicep Modules: 3 (network, vm, database)
Cloud-init Scripts: 1 (app-server.yaml)
```

### Key Differences

| Aspect | Complex | Simplified |
|--------|---------|------------|
| Virtual Machines | 3 (bastion, proxy, app) | 1 (combined) |
| Subnets | 4 (bastion, web, app, data) | 1 (default) |
| Network Security Groups | 4 | 1 |
| Application Security Groups | 3 | 0 |
| SSH Access Pattern | Via bastion jump host | Direct to VM |
| PostgreSQL Access | Private DNS + VNet integration | Public access |
| nginx Location | Separate VM (vm-proxy) | Same VM as Flask |
| Cloud-init Scripts | 3 files | 1 file |
| Bicep Modules | 5 | 3 |
| Estimated Deploy Time | 20-40 minutes | 10-15 minutes |
| Monthly Cost | ~$44 | ~$20 |

---

## Implementation Steps

### Phase 1: Delete Old Infrastructure Files

Delete the following files that are no longer needed:

```bash
# Bicep modules
rm infrastructure/modules/bastion.bicep
rm infrastructure/modules/proxy.bicep
rm infrastructure/modules/app.bicep
rm infrastructure/modules/network.bicep
rm infrastructure/modules/database.bicep

# Cloud-init scripts
rm infrastructure/cloud-init/bastion.yaml
rm infrastructure/cloud-init/proxy.yaml
rm infrastructure/cloud-init/app.yaml
```

### Phase 2: Create New Bicep Modules

#### 2.1 Network Module (`modules/network.bicep`)

Creates simplified networking:
- Virtual Network: `vnet-flask-dev` (10.0.0.0/16)
- Single Subnet: `snet-default` (10.0.0.0/24)
- Single NSG: `nsg-default` with rules:
  - Priority 100: Allow SSH (22) from Internet
  - Priority 110: Allow HTTP (80) from Internet
  - Priority 120: Allow HTTPS (443) from Internet

#### 2.2 VM Module (`modules/vm.bicep`)

Creates single application VM:
- VM Name: `vm-app`
- Size: Standard_B1s (1 vCPU, 1 GB RAM)
- OS: Ubuntu 24.04 LTS
- Public IP: `pip-app` (Static)
- NIC: `nic-app`
- Cloud-init: app-server.yaml
- Authentication: SSH key only

#### 2.3 Database Module (`modules/database.bicep`)

Creates PostgreSQL with public access:
- Server: `psql-flask-dev`
- SKU: Standard_B1ms (Burstable)
- Version: PostgreSQL 16
- Storage: 32 GB
- Public Access: Enabled
- Firewall: Allow all connections (0.0.0.0 - 255.255.255.255)
- Database: `flask`

### Phase 3: Create Combined Cloud-Init

Create `cloud-init/app-server.yaml` that installs and configures:

1. **System packages:**
   - nginx
   - python3, python3-pip, python3-venv
   - postgresql-client
   - fail2ban

2. **nginx configuration:**
   - HTTP server (port 80) → redirect to HTTPS
   - HTTPS server (port 443) → reverse proxy to localhost:5001
   - Self-signed SSL certificate

3. **Flask application setup:**
   - Create `flask-app` system user
   - Create `/opt/flask-app/` directory
   - Create Python virtual environment
   - Create systemd service unit

4. **Security hardening:**
   - fail2ban for SSH brute-force protection
   - SSH key-only authentication

### Phase 4: Update Main Bicep

Rewrite `main.bicep` to call simplified modules:

```bicep
module network 'modules/network.bicep' = { ... }
module vm 'modules/vm.bicep' = { ... }
module database 'modules/database.bicep' = { ... }
```

### Phase 5: Update Scripts

#### 5.1 Update `config.sh`

Remove:
- `VM_BASTION`, `VM_PROXY` variables
- `ssh_via_bastion()`, `scp_via_bastion()` functions
- Multiple subnet CIDR variables

Add:
- `VM_APP` variable
- Direct SSH helper function

#### 5.2 Update `provision.sh`

Simplify to:
- Call simplified Bicep deployment
- Output single VM public IP
- Remove bastion/proxy IP retrieval

#### 5.3 Update `deploy/deploy.sh`

Change from:
```bash
scp_via_bastion app.py vm-app:/opt/flask-app/
ssh_via_bastion vm-app "systemctl restart flask-app"
```

To:
```bash
scp -i ~/.ssh/id_rsa app.py azureuser@$VM_IP:/opt/flask-app/
ssh azureuser@$VM_IP "sudo systemctl restart flask-app"
```

---

## File Changes

### Files to DELETE

| File | Reason |
|------|--------|
| `infrastructure/modules/bastion.bicep` | No bastion VM |
| `infrastructure/modules/proxy.bicep` | nginx on same VM |
| `infrastructure/modules/app.bicep` | Replaced by vm.bicep |
| `infrastructure/modules/network.bicep` | Replaced with simplified version |
| `infrastructure/modules/database.bicep` | Replaced with public access version |
| `infrastructure/cloud-init/bastion.yaml` | No bastion VM |
| `infrastructure/cloud-init/proxy.yaml` | nginx config in app-server.yaml |
| `infrastructure/cloud-init/app.yaml` | Merged into app-server.yaml |

### Files to CREATE

| File | Purpose |
|------|---------|
| `infrastructure/modules/network.bicep` | Simplified network (1 subnet, 1 NSG) |
| `infrastructure/modules/vm.bicep` | Single VM with nginx + Flask |
| `infrastructure/modules/database.bicep` | PostgreSQL with public access |
| `infrastructure/cloud-init/app-server.yaml` | Combined nginx + Flask + fail2ban |

### Files to UPDATE

| File | Changes |
|------|---------|
| `infrastructure/main.bicep` | Call new simplified modules |
| `infrastructure/provision.sh` | Remove bastion/proxy logic |
| `config.sh` | Remove bastion/proxy variables |
| `deploy/deploy.sh` | Direct SSH instead of jump host |
| `deploy/scripts/wait-for-cloud-init.sh` | Single VM instead of 3 |

### Files to KEEP (unchanged)

| File | Reason |
|------|--------|
| `infrastructure/scripts/init-secrets.sh` | Still need password generation |
| `infrastructure/scripts/validate-password.sh` | Still need validation |
| `infrastructure/parameters.example.json` | Template for users |
| `deploy/scripts/wait-for-postgresql.sh` | PostgreSQL still slow to provision |

---

## Resource Specifications

### Virtual Machine

| Property | Value |
|----------|-------|
| Name | `vm-app` |
| Size | Standard_B1s |
| vCPUs | 1 |
| RAM | 1 GB |
| OS | Ubuntu 24.04 LTS (Gen2) |
| OS Disk | 30 GB Standard_LRS |
| Public IP | Static |
| Admin User | `azureuser` |
| Auth | SSH key only |

### Network

| Property | Value |
|----------|-------|
| VNet Name | `vnet-flask-dev` |
| VNet CIDR | 10.0.0.0/16 |
| Subnet Name | `snet-default` |
| Subnet CIDR | 10.0.0.0/24 |
| NSG Name | `nsg-default` |

### NSG Rules

| Priority | Name | Port | Source | Action |
|----------|------|------|--------|--------|
| 100 | AllowSSH | 22 | Internet | Allow |
| 110 | AllowHTTP | 80 | Internet | Allow |
| 120 | AllowHTTPS | 443 | Internet | Allow |
| 65000 | DenyAllInbound | * | * | Deny |

### PostgreSQL

| Property | Value |
|----------|-------|
| Server Name | `psql-flask-dev` |
| SKU | Standard_B1ms |
| vCores | 1 |
| RAM | 2 GB |
| Storage | 32 GB |
| Version | 16 |
| Public Access | Enabled |
| Firewall | 0.0.0.0 - 255.255.255.255 |
| Database | `flask` |
| Admin User | `adminuser` |

### Cost Estimate

| Resource | Monthly Cost |
|----------|-------------|
| VM (Standard_B1s) | ~$7 |
| PostgreSQL (B1ms) | ~$12 |
| Public IP | ~$3 |
| Storage | ~$1 |
| **Total** | **~$23** |

---

## Verification Checklist

After implementation, verify:

- [ ] `./deploy-all.sh` completes in under 15 minutes
- [ ] Can SSH directly to VM: `ssh azureuser@<VM_IP>`
- [ ] nginx responds on HTTP (redirects to HTTPS)
- [ ] nginx responds on HTTPS (self-signed cert warning)
- [ ] Flask application accessible via browser
- [ ] Database connection works (create entry via /demo)
- [ ] Health check returns 200: `curl https://<VM_IP>/api/health -k`
- [ ] `./delete-all.sh` removes all resources
