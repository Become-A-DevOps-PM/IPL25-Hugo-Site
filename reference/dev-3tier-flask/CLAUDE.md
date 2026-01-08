# Dev Three-Tier Flask

Simplified Flask deployment on Azure for learning application development.

## Critical Rules

1. **Never commit `parameters.json`** - Contains database password
2. **Source `config.sh` first** - Before running any script individually
3. **PostgreSQL is public** - Learning environment only, not production
4. **Self-signed SSL** - Browser will show security warning

## Quick Reference

```bash
# Full deployment
./deploy-all.sh

# Get VM IP
VM_IP=$(az vm show -g rg-flask-dev -n vm-app --show-details -o tsv --query publicIps)

# SSH to VM
ssh azureuser@$VM_IP

# View logs
ssh azureuser@$VM_IP "sudo journalctl -u flask-app -f"

# Cleanup
./delete-all.sh
```

## Architecture

```
Internet ──→ VM (nginx:443 → Flask:5001) ──→ PostgreSQL
             Ubuntu 24.04                     Azure PaaS
             snet-default (10.0.0.0/24)       Public access
```

Single VM running nginx (reverse proxy) and Flask/Gunicorn on the same host.

| Component | Details |
|-----------|---------|
| VM | Standard_B1s, Ubuntu 24.04 LTS |
| Web Server | nginx with self-signed SSL |
| App Server | Gunicorn (2 workers) on port 5001 |
| Database | PostgreSQL 16 Flexible Server |
| Cost | ~$20/month |

## Application Endpoints

| Route | Response |
|-------|----------|
| `GET /` | Landing page |
| `GET /demo` | Demo form with entries |
| `POST /demo` | Create entry (redirects) |
| `GET /api/health` | `{"status": "ok"}` |
| `GET /api/entries` | JSON array of entries |

## Directory Structure

```
dev-3tier-flask/
├── deploy-all.sh              # One-command deployment
├── delete-all.sh              # Cleanup with progress bar
├── config.sh                  # Central configuration
│
├── infrastructure/
│   ├── provision.sh           # Azure provisioning
│   ├── main.bicep             # Bicep orchestrator
│   ├── modules/
│   │   ├── network.bicep      # VNet, subnet, NSG
│   │   ├── vm.bicep           # Ubuntu VM with cloud-init
│   │   └── database.bicep     # PostgreSQL Flexible Server
│   ├── cloud-init/
│   │   └── app-server.yaml    # nginx + Flask + fail2ban
│   ├── scripts/
│   │   ├── init-secrets.sh    # Generate parameters.json
│   │   └── validate-password.sh
│   ├── parameters.json        # GITIGNORED - secrets
│   └── parameters.example.json
│
├── application/
│   ├── app/
│   │   ├── __init__.py        # create_app() factory
│   │   ├── extensions.py      # Flask extensions (db)
│   │   ├── routes/
│   │   │   ├── main.py        # Landing page (/)
│   │   │   ├── demo.py        # Demo app (/demo)
│   │   │   └── api.py         # API endpoints (/api/*)
│   │   ├── models/
│   │   │   └── entry.py       # Entry model
│   │   ├── services/
│   │   │   └── entry_service.py
│   │   ├── templates/
│   │   │   ├── base.html
│   │   │   ├── landing.html
│   │   │   └── demo.html
│   │   └── static/
│   ├── tests/
│   │   ├── conftest.py        # pytest fixtures
│   │   └── test_routes.py     # 15 tests
│   ├── config.py              # Dev/Prod/Test configs
│   ├── wsgi.py                # Gunicorn entry point
│   └── requirements.txt
│
├── deploy/
│   ├── deploy.sh              # SCP + configure + start
│   └── scripts/
│       ├── wait-for-postgresql.sh
│       ├── wait-for-cloud-init.sh
│       ├── wait-for-flask-app.sh
│       └── verification-tests.sh
│
└── docs/
    ├── DEPLOYMENT-TEST-REPORT.md
    ├── INFRASTRUCTURE-SIMPLIFICATION.md
    ├── BRD.md
    └── PRD.md
```

## Flask Application Details

### Factory Pattern

```python
# app/__init__.py
def create_app(config_class=None):
    app = Flask(__name__)
    app.config.from_object(config_class or Config)
    db.init_app(app)
    # Register blueprints
    return app
```

### Blueprints

| Blueprint | Prefix | Routes |
|-----------|--------|--------|
| `main_bp` | `/` | Landing page |
| `demo_bp` | `/demo` | Demo form + entries |
| `api_bp` | `/api` | Health, entries API |

### Models

```python
# app/models/entry.py
class Entry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    value = db.Column(db.String(500), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
```

### Configuration

| Class | DATABASE_URL | Use |
|-------|--------------|-----|
| `DevelopmentConfig` | SQLite (`local.db`) | Local dev |
| `ProductionConfig` | From `DATABASE_URL` env | Azure |
| `TestingConfig` | SQLite in-memory | pytest |

## Infrastructure Details

### Bicep Modules

**network.bicep** creates:
- VNet: `vnet-flask-dev` (10.0.0.0/16)
- Subnet: `snet-default` (10.0.0.0/24)
- NSG: `nsg-default` (SSH:22, HTTP:80, HTTPS:443)

**vm.bicep** creates:
- VM: `vm-app` (Standard_B1s)
- Public IP: `pip-app` (Static)
- NIC: `nic-app`
- OS: Ubuntu 24.04 LTS (`Canonical:ubuntu-24_04-lts:server`)

**database.bicep** creates:
- PostgreSQL: `psql-flask-dev` (Burstable B1ms)
- Database: `flask`
- Firewall: Allow all (0.0.0.0 - 255.255.255.255)

### Cloud-Init (app-server.yaml)

Installs and configures:
- nginx with SSL reverse proxy (port 443 → 5001)
- Python 3, pip, venv at `/opt/flask-app/venv`
- fail2ban for SSH protection
- Self-signed certificate at `/etc/nginx/ssl/`
- systemd service `flask-app`
- System user `flask-app` (no login)

### System Paths

| Path | Purpose |
|------|---------|
| `/opt/flask-app/` | Application code |
| `/opt/flask-app/venv/` | Python virtual environment |
| `/etc/flask-app/app.env` | Environment variables (DATABASE_URL) |
| `/etc/systemd/system/flask-app.service` | systemd unit |
| `/etc/nginx/sites-available/flask-app` | nginx config |
| `/etc/nginx/ssl/` | SSL certificate and key |

## Configuration Variables

All scripts source `config.sh`:

```bash
PROJECT="flask"
ENVIRONMENT="dev"
LOCATION="swedencentral"

RESOURCE_GROUP="rg-flask-dev"
POSTGRES_SERVER="psql-flask-dev"
POSTGRES_HOST="psql-flask-dev.postgres.database.azure.com"
DATABASE_NAME="flask"

VM_APP="vm-app"
VM_ADMIN_USER="azureuser"
DB_ADMIN_USER="adminuser"
```

### Helper Functions

```bash
# Get VM public IP
get_vm_public_ip

# SSH to VM with standard options
ssh_to_vm "command"

# SCP to VM
scp_to_vm "/local/path" "/remote/path"
```

## Deployment Flow

```
deploy-all.sh
├── infrastructure/provision.sh
│   ├── init-secrets.sh (if needed)
│   ├── validate-password.sh
│   └── az deployment (main.bicep)
├── deploy/scripts/wait-for-postgresql.sh
├── deploy/scripts/wait-for-cloud-init.sh
├── deploy/deploy.sh
│   ├── SCP application files
│   ├── pip install requirements
│   ├── Configure DATABASE_URL
│   ├── Initialize database tables
│   └── Start flask-app service
├── deploy/scripts/wait-for-flask-app.sh
└── deploy/scripts/verification-tests.sh
```

## Testing

### Local Tests

```bash
cd application
source .venv/bin/activate
pytest tests/ -v              # 15 tests
pytest --cov=app tests/       # Coverage report
```

### Verification Tests

The deployment runs 6 verification tests:
1. Health endpoint returns `{"status": "ok"}`
2. Landing page loads
3. Demo page loads
4. API entries returns JSON array
5. Database connectivity (psql SELECT 1)
6. Entries table exists

## Troubleshooting

### Check Service Status
```bash
ssh azureuser@$VM_IP "sudo systemctl status flask-app"
ssh azureuser@$VM_IP "sudo systemctl status nginx"
```

### View Logs
```bash
# Flask/Gunicorn logs
ssh azureuser@$VM_IP "sudo journalctl -u flask-app -n 100"

# nginx access log
ssh azureuser@$VM_IP "sudo tail -f /var/log/nginx/access.log"

# nginx error log
ssh azureuser@$VM_IP "sudo tail -f /var/log/nginx/error.log"

# Cloud-init log
ssh azureuser@$VM_IP "sudo cat /var/log/cloud-init-output.log"
```

### Database Connection
```bash
# Check environment variable
ssh azureuser@$VM_IP "sudo cat /etc/flask-app/app.env"

# Test connection
ssh azureuser@$VM_IP 'eval $(sudo cat /etc/flask-app/app.env) && psql "$DATABASE_URL" -c "SELECT 1;"'
```

### Restart Services
```bash
ssh azureuser@$VM_IP "sudo systemctl restart flask-app"
ssh azureuser@$VM_IP "sudo systemctl restart nginx"
```

## Comparison with stage-ultimate

| Aspect | dev-3tier-flask | stage-ultimate |
|--------|-----------------|----------------|
| Purpose | Application development | Infrastructure security |
| VMs | 1 (combined) | 3 (bastion, proxy, app) |
| Subnets | 1 | 4 (segmented) |
| SSH | Direct | Via bastion jump host |
| PostgreSQL | Public access | Private DNS |
| Deploy time | 10-15 min | 20-40 min |
| Monthly cost | ~$20 | ~$44 |
| Complexity | Low | Moderate-High |

Use **dev-3tier-flask** when learning Flask, Python, or basic Azure deployment.
Use **stage-ultimate** when learning network security, defense in depth, or production patterns.
