# Stage IaaS Flask - Reference Implementation

## Purpose

Pure IaaS baseline for Flask on Azure using Bicep. First stage in progression:
**stage-iaas-flask** → stage-ultimate (+ Key Vault) → stage-managed (+ Azure Bastion)

Educational focus: Traditional Linux admin, Bicep IaC, network segmentation.

## Tech Stack

```
IaC:       Bicep (declarative)      VMs: 3x Standard_B1s (~$7/mo each)
App:       Flask 3.0 + Gunicorn     DB:  PostgreSQL 16 Flexible Server (~$12/mo)
OS:        Ubuntu 24.04 LTS         Cost: ~$44/month total
```

## Architecture

```
Internet
    │
    ├──SSH (22)────→ vm-bastion ──SSH──→ Internal VMs
    │                (10.0.1.x)           snet-bastion
    │
    └──HTTPS (443)─→ vm-proxy ──HTTP (5001)──→ vm-app
                     (10.0.2.x)                (10.0.3.x)
                     snet-web                  snet-app
                                                   │
                                                   └──→ PostgreSQL
                                                        (10.0.4.x)
                                                        snet-data
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
│   ├── modules/              # network, bastion, proxy, app, database
│   ├── cloud-init/           # bastion.yaml, proxy.yaml, app.yaml
│   └── scripts/              # init-secrets.sh, validate-password.sh
│
├── application/
│   ├── app.py                # Flask app (111 lines, SQLAlchemy)
│   ├── wsgi.py               # Gunicorn entry point
│   └── requirements.txt      # Flask, SQLAlchemy, Gunicorn, psycopg2
│
├── deploy/
│   ├── deploy.sh             # App deployment via SSH jump
│   └── scripts/              # wait-for-*.sh, verification-tests.sh
│
└── docs/
    ├── BRD.md, PRD.md        # Business/Product requirements
    ├── IMPLEMENTATION-PLAN.md
    └── architecture/         # C4 model documentation (Structurizr)
        ├── workspace.dsl     # Source of truth for architecture model
        ├── workspace.json    # Manual layout positions
        ├── build-site.sh     # One-command static site build
        ├── docs/             # C1-C4 markdown documentation
        └── adrs/             # Architecture Decision Records
```

## Key Scripts

| Script | Purpose |
|--------|---------|
| `deploy-all.sh` | Full deployment (provision → wait → deploy → verify) |
| `infrastructure/provision.sh` | Create Azure resources via Bicep |
| `deploy/deploy.sh` | Copy app, install deps, start service |
| `delete-all.sh` | Delete resource group and cleanup |

## Deployment Workflow

```bash
# Option 1: One command
./deploy-all.sh

# Option 2: Step by step
./infrastructure/provision.sh          # 15-20 min (PostgreSQL slow)
./deploy/scripts/wait-for-postgresql.sh
./deploy/scripts/wait-for-vms-cloud-init.sh
./deploy/deploy.sh
./deploy/scripts/verification-tests.sh
```

## Naming Convention (CAF)

- Resource Group: `rg-flask-bicep-dev`
- VNet: `vnet-flask-bicep-dev`
- Subnets: `snet-bastion`, `snet-web`, `snet-app`, `snet-data`
- NSGs: `nsg-bastion`, `nsg-web`, `nsg-app`, `nsg-data`
- VMs: `vm-bastion`, `vm-proxy`, `vm-app`
- PostgreSQL: `psql-flask-bicep-dev`

## Bicep Module Structure

```
main.bicep
├── modules/network.bicep   → VNet, 4 subnets, 4 NSGs, 3 ASGs
├── modules/bastion.bicep   → Jump host with public IP
├── modules/proxy.bicep     → nginx reverse proxy with SSL
├── modules/app.bicep       → Flask app server (no public IP)
└── modules/database.bicep  → PostgreSQL + private DNS
```

## Secrets Handling

- `infrastructure/scripts/init-secrets.sh` generates `parameters.json`
- Random 32-char passwords via `/dev/urandom`
- `parameters.json` is gitignored (never commit)
- Template: `parameters.example.json`

## SSH Jump Pattern

All internal access goes through bastion:
```bash
# Helper functions in config.sh
ssh_via_bastion vm-app "command"
scp_via_bastion local-file vm-app:/remote/path
```

## Flask Application

- Single file: `app.py` (111 lines)
- Dual DB: PostgreSQL (prod) / SQLite (local dev)
- Health endpoint: `/health` → `{"status": "ok"}`
- Runs as `flask-app` user via systemd
- Directory: `/opt/flask-app/` with virtualenv

## vs stage-ultimate

| Aspect | This (iaas-flask) | stage-ultimate |
|--------|-------------------|----------------|
| IaC | Bicep | Azure CLI scripts |
| Secrets | parameters.json | Azure Key Vault |
| Identity | SSH keys only | Managed Identity |
| Subnets | 4 | 5 (+ Key Vault) |
| Complexity | Simpler | More complex |

## Critical Rules

1. **Never commit parameters.json** - contains database passwords
2. **All internal access via bastion** - app/db have no public IPs
3. **Source config.sh** before running individual scripts
4. **PostgreSQL takes 10-15 min** - be patient during provisioning
5. **Cloud-init runs async** - wait scripts ensure completion

## Documentation

- `README.md` - Quick start and architecture overview
- `docs/IMPLEMENTATION-PLAN.md` - 8-phase deployment guide
- `docs/BRD.md` / `docs/PRD.md` - Business/Product requirements
- `docs/architecture/` - C4 model diagrams (see below)

## Architecture Documentation

The `docs/architecture/` folder contains C4 model documentation built with Structurizr.

### Quick Commands

```bash
cd docs/architecture

# Build static site (preserves manual diagram layouts)
./build-site.sh

# View generated site
cd build && python3 -m http.server 8000

# Interactive editing with live preview
docker run -it --rm -p 8080:8080 \
  -v "$(pwd):/usr/local/structurizr" structurizr/lite
```

### C4 Diagram Views

| View | Key | Description |
|------|-----|-------------|
| System Context | `C1-Context` | Actors and system boundary |
| Containers | `C2-Containers-Full` | VMs, database, network topology |
| Components (App) | `C3-Components` | Flask application internals |
| Components (Proxy) | `C3-Components-Proxy` | nginx reverse proxy internals |
| Deployment | `Deployment` | Azure infrastructure layout |

### Build Pipeline

The build script (`build-site.sh`) orchestrates:
1. Structurizr Site Generatr → static HTML (auto-layout)
2. Puppeteer export from Structurizr Lite → SVGs (manual layout)
3. Post-processing → applies manual layouts to build

Prerequisites: Docker, Node.js (Puppeteer auto-installs on first run)
