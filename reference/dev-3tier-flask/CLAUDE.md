# Dev Three-Tier Flask - Reference Implementation

## Purpose

This reference implementation provides a **simplified Flask deployment on Azure** designed to help students focus on **application development** rather than infrastructure complexity.

### Why Simplified Infrastructure?

The original stage-ultimate reference implementation features production-grade security:
- 3 VMs (bastion jump host, reverse proxy, application server)
- 4 subnets with network segmentation
- Private DNS for database access
- SSH access only through bastion host

While this architecture teaches important security concepts, it creates barriers for students learning Flask application development:
- 20-40 minute deployment times
- Complex SSH jump patterns for debugging
- Multiple points of failure obscuring application issues
- ~$44/month cost

**This simplified version prioritizes:**
- Understanding application request flow (browser → nginx → Flask → PostgreSQL)
- Rapid iteration on application code
- Clear debugging with direct SSH access
- Lower cost (~$20/month) for learning environments

### When to Use Each Approach

| Use Case | Recommendation |
|----------|----------------|
| Learning Flask/Python | This simplified version |
| Understanding nginx reverse proxy | This simplified version |
| Learning network segmentation | stage-ultimate |
| Production deployment patterns | stage-ultimate |
| Security hardening concepts | stage-ultimate |

## Architecture

```
Internet
    │
    ├──SSH (22)─────────→ vm-app ──────────→ PostgreSQL
    │                     (10.0.0.x)          (Azure PaaS)
    │                     snet-default        Public Access
    │
    └──HTTP/HTTPS (80/443)──┘
```

### Key Design Decisions

1. **Single VM** - nginx and Flask run on the same Ubuntu VM
2. **Direct SSH** - No bastion/jump host; SSH directly to the application VM
3. **Public PostgreSQL** - Azure PostgreSQL with public access enabled (no private DNS)
4. **Single Subnet** - No network segmentation; simple flat network
5. **Self-signed SSL** - HTTPS enabled but with self-signed certificates

## Tech Stack

```
IaC:       Bicep (declarative)      VM:  1x Standard_B1s (~$7/mo)
App:       Flask 3.0 + Gunicorn     DB:  PostgreSQL 16 Flexible Server (~$12/mo)
OS:        Ubuntu 24.04 LTS         Cost: ~$20/month total
Proxy:     nginx (same VM)
```

## Directory Structure

```
├── config.sh                 # Central config (PROJECT, LOCATION, SSH opts)
├── deploy-all.sh             # One-command full deployment
├── delete-all.sh             # Resource cleanup
│
├── infrastructure/
│   ├── provision.sh          # Main provisioning orchestrator
│   ├── main.bicep            # Bicep orchestration (calls modules)
│   ├── modules/
│   │   ├── network.bicep     # VNet, 1 subnet, 1 NSG
│   │   ├── vm.bicep          # Single VM with public IP
│   │   └── database.bicep    # PostgreSQL with public access
│   ├── cloud-init/
│   │   └── app-server.yaml   # Combined nginx + Flask setup
│   └── scripts/
│       ├── init-secrets.sh   # Generate database password
│       └── validate-password.sh
│
├── application/              # Flask application (see Application section)
│   ├── app/                  # Flask app package (factory pattern)
│   ├── config.py             # Environment configurations
│   ├── wsgi.py               # Gunicorn entry point
│   └── requirements.txt
│
├── deploy/
│   ├── deploy.sh             # App deployment via direct SSH
│   └── scripts/
│       ├── wait-for-postgresql.sh
│       ├── wait-for-cloud-init.sh
│       ├── wait-for-flask-app.sh
│       └── verification-tests.sh
│
└── docs/
    ├── BRD.md                # Business requirements
    ├── PRD.md                # Product requirements
    └── INFRASTRUCTURE-PLAN.md # Infrastructure implementation guide
```

## Quick Start

```bash
# One-command deployment (10-15 minutes)
./deploy-all.sh

# Or step by step:
./infrastructure/provision.sh      # Create Azure resources
./deploy/scripts/wait-for-postgresql.sh
./deploy/scripts/wait-for-cloud-init.sh
./deploy/deploy.sh                 # Deploy Flask application

# Access the application
VM_IP=$(az vm show -g rg-flask-dev -n vm-app --show-details -o tsv --query publicIps)
echo "https://$VM_IP/"
```

## Resource Naming

| Resource | Name |
|----------|------|
| Resource Group | `rg-flask-dev` |
| Virtual Network | `vnet-flask-dev` |
| Subnet | `snet-default` |
| NSG | `nsg-default` |
| VM | `vm-app` |
| Public IP | `pip-app` |
| NIC | `nic-app` |
| PostgreSQL | `psql-flask-dev` |

## Bicep Module Structure

```
main.bicep
├── modules/network.bicep   → VNet, 1 subnet, 1 NSG (SSH, HTTP, HTTPS)
├── modules/vm.bicep        → Ubuntu VM with nginx + Flask (cloud-init)
└── modules/database.bicep  → PostgreSQL Flexible Server (public access)
```

## SSH Access

Direct SSH to the application VM:

```bash
# SSH to VM
ssh azureuser@<VM_PUBLIC_IP>

# Check application logs
sudo journalctl -u flask-app -f

# Check nginx logs
sudo tail -f /var/log/nginx/access.log
```

## Flask Application

The application follows Flask best practices:

- **Factory pattern** - `create_app()` in `app/__init__.py`
- **Blueprints** - Modular routes in `app/routes/`
- **Service layer** - Business logic in `app/services/`
- **SQLAlchemy ORM** - Models in `app/models/`
- **Dual database support** - PostgreSQL (production) / SQLite (local dev)

### Key Endpoints

| Route | Purpose |
|-------|---------|
| `/` | Landing page |
| `/demo` | Demo application with database entries |
| `/api/health` | Health check endpoint |
| `/api/entries` | JSON API for entries |

### Local Development

```bash
cd application
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
flask run
```

## Secrets Handling

- `infrastructure/scripts/init-secrets.sh` generates `parameters.json`
- Random 32-character password via `/dev/urandom`
- `parameters.json` is gitignored (never commit)
- Template available: `parameters.example.json`

## Network Security Rules

Single NSG with three inbound rules:

| Priority | Name | Port | Source | Purpose |
|----------|------|------|--------|---------|
| 100 | AllowSSH | 22 | Internet | SSH administration |
| 110 | AllowHTTP | 80 | Internet | HTTP (redirects to HTTPS) |
| 120 | AllowHTTPS | 443 | Internet | HTTPS traffic |

## PostgreSQL Access

PostgreSQL is configured with **public access** for simplicity:

- No private DNS zone
- No VNet integration
- Firewall allows all connections (development only)
- Connection string provided via environment variable

**Note:** This configuration is suitable for learning environments only. Production deployments should use private endpoints.

## vs stage-ultimate

| Aspect | This (dev-3tier) | stage-ultimate |
|--------|------------------|----------------|
| **Focus** | Application development | Infrastructure security |
| **VMs** | 1 (combined) | 3 (bastion, proxy, app) |
| **Subnets** | 1 | 4 (segmented) |
| **SSH Access** | Direct | Via bastion jump host |
| **PostgreSQL** | Public access | Private DNS |
| **Deploy Time** | 10-15 min | 20-40 min |
| **Cost** | ~$20/month | ~$44/month |
| **Complexity** | Low | Moderate-High |

## Critical Rules

1. **Never commit parameters.json** - Contains database password
2. **PostgreSQL is public** - Suitable for learning only, not production
3. **Self-signed SSL** - Browser will show security warning
4. **Source config.sh** - Before running individual scripts

## Troubleshooting

### Application not responding
```bash
# Check if Flask is running
ssh azureuser@<VM_IP> "sudo systemctl status flask-app"

# Check application logs
ssh azureuser@<VM_IP> "sudo journalctl -u flask-app -n 50"
```

### Database connection issues
```bash
# Test database connectivity from VM
ssh azureuser@<VM_IP> "psql -h <POSTGRES_FQDN> -U adminuser -d flask -c 'SELECT 1'"
```

### nginx issues
```bash
# Check nginx status
ssh azureuser@<VM_IP> "sudo systemctl status nginx"

# Check nginx config
ssh azureuser@<VM_IP> "sudo nginx -t"
```
