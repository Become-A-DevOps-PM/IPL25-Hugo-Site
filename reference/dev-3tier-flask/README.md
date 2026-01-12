# Dev Three-Tier Flask

A simplified Flask application deployment on Azure for learning application development.

## Quick Start

```bash
# Deploy everything (10-15 minutes)
./deploy-all.sh

# Access your application
VM_IP=$(az vm show -g rg-flask-dev -n vm-app --show-details -o tsv --query publicIps)
open "https://$VM_IP/"

# Tear down when done
./delete-all.sh
```

## Default Credentials

**This is an educational project. Credentials are documented here for convenience.**

| Service | Username | Password |
|---------|----------|----------|
| **Admin Login** (`/auth/login`) | `admin` | `Admin123!` |
| **SSH Access** | `azureuser` | SSH key (no password) |
| **Database** | `adminuser` | See `parameters.json` |

The admin user is created automatically during deployment.

## What This Is

A single-VM deployment running:
- **nginx** - Reverse proxy with HTTPS (self-signed certificate)
- **Flask** - Python web application with Gunicorn
- **PostgreSQL** - Azure managed database (public access)

```
Internet ──→ VM (nginx + Flask) ──→ PostgreSQL
             Ubuntu 24.04            Azure PaaS
             10.0.0.0/24
```

**Cost:** ~$20/month | **Deploy time:** 10-15 minutes

## Prerequisites

- Azure CLI installed and logged in (`az login`)
- jq installed (`brew install jq` on macOS)
- SSH key at `~/.ssh/id_rsa.pub` or `~/.ssh/id_ed25519.pub`

## Application Endpoints

| URL | Description |
|-----|-------------|
| `https://<IP>/` | Landing page |
| `https://<IP>/register` | Webinar registration form |
| `https://<IP>/webinar` | Webinar information |
| `https://<IP>/auth/login` | Admin login |
| `https://<IP>/admin/attendees` | Attendee list (login required) |
| `https://<IP>/admin/export/csv` | Export CSV (login required) |
| `https://<IP>/demo` | Demo app with database entries |
| `https://<IP>/api/health` | Health check (`{"status": "ok"}`) |

## SSH Access

```bash
# Get the VM IP
VM_IP=$(az vm show -g rg-flask-dev -n vm-app --show-details -o tsv --query publicIps)

# SSH to the VM
ssh azureuser@$VM_IP

# View application logs
ssh azureuser@$VM_IP "sudo journalctl -u flask-app -f"

# View nginx logs
ssh azureuser@$VM_IP "sudo tail -f /var/log/nginx/access.log"
```

## Local Development

```bash
cd application
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
flask db upgrade          # Initialize database
flask create-admin admin  # Create admin user (prompts for password)
flask run
```

The app uses SQLite locally and PostgreSQL in production.

### Create Admin User

Admin access requires creating a user first:

```bash
flask create-admin USERNAME
# Password: ********  (minimum 8 characters)
# Repeat for confirmation: ********
# Admin user 'USERNAME' created successfully.
```

Then log in at `/auth/login` to access protected routes.

## Manual Deployment Steps

If you prefer running steps individually:

```bash
# 1. Provision Azure infrastructure
./infrastructure/provision.sh

# 2. Wait for PostgreSQL to be ready (5-10 minutes)
./deploy/scripts/wait-for-postgresql.sh

# 3. Wait for VM cloud-init to complete
./deploy/scripts/wait-for-cloud-init.sh

# 4. Deploy the Flask application
./deploy/deploy.sh

# 5. Verify the application is healthy
./deploy/scripts/wait-for-flask-app.sh

# 6. Run verification tests (optional)
./deploy/scripts/verification-tests.sh
```

## Project Structure

```
dev-3tier-flask/
├── deploy-all.sh                 # One-command deployment
├── delete-all.sh                 # Resource cleanup
├── config.sh                     # Shared configuration
│
├── infrastructure/               # Azure provisioning
│   ├── provision.sh             # Main script
│   ├── main.bicep               # Bicep orchestrator
│   ├── modules/                 # network, vm, database
│   ├── cloud-init/              # VM configuration
│   └── scripts/                 # Password generation
│
├── application/                  # Flask application
│   ├── app/                     # Application package
│   │   ├── routes/              # Blueprints (main, demo, api)
│   │   ├── models/              # SQLAlchemy models
│   │   └── services/            # Business logic
│   ├── tests/                   # pytest tests
│   ├── config.py                # Environment configs
│   ├── wsgi.py                  # Gunicorn entry point
│   └── requirements.txt
│
└── deploy/                       # Deployment scripts
    ├── deploy.sh                # Application deployment
    └── scripts/                 # Wait and verification scripts
```

## Azure Resources Created

| Resource | Name | Purpose |
|----------|------|---------|
| Resource Group | `rg-flask-dev` | Container |
| Virtual Network | `vnet-flask-dev` | Networking |
| Subnet | `snet-default` | VM subnet |
| NSG | `nsg-default` | Firewall rules |
| VM | `vm-app` | Application server |
| Public IP | `pip-app` | External access |
| PostgreSQL | `psql-flask-dev` | Database |

## Troubleshooting

**Application not responding:**
```bash
ssh azureuser@$VM_IP "sudo systemctl status flask-app"
ssh azureuser@$VM_IP "sudo journalctl -u flask-app -n 50"
```

**Database connection issues:**
```bash
ssh azureuser@$VM_IP "sudo cat /etc/flask-app/app.env"
```

**nginx issues:**
```bash
ssh azureuser@$VM_IP "sudo systemctl status nginx"
ssh azureuser@$VM_IP "sudo nginx -t"
```

## Security Notes

This deployment is designed for **learning environments only**:

- PostgreSQL has public access enabled
- SSL certificate is self-signed (browser warning expected)
- No network segmentation
- Direct SSH access to application server

**Security features implemented:**
- Admin routes protected by session-based authentication
- Password hashing with Werkzeug (PBKDF2)
- OWASP security headers (X-Frame-Options, X-Content-Type-Options, etc.)
- CSRF protection on all forms

For production patterns, see `reference/stage-ultimate/`.
