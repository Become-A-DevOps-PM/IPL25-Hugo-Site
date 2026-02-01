# Stage Ultimate - Reference Implementation

Production-grade Flask Contact Form on Azure. Demonstrates defense-in-depth with network segmentation, bastion host, reverse proxy, and managed secrets.

## Architecture

```
Internet
    |
    +--SSH (22)-----> Bastion VM --SSH--> Internal VMs
    |                (10.0.1.x)
    |
    +--HTTPS (443)--> Reverse Proxy VM --HTTP (5001)--> App Server VM
                     (10.0.2.x)                        (10.0.3.x)
                                                           |
                                                           +---> PostgreSQL (Azure PaaS)
                                                           +---> Key Vault (Azure PaaS)
```

## Components

| Component | Technology | Purpose |
|-----------|------------|---------|
| VMs (3x) | Standard_B1s | Bastion, Proxy, App Server |
| Database | PostgreSQL Flexible Server (B1ms) | Production data storage |
| Secrets | Azure Key Vault + RBAC | Secure credential management |
| Identity | System-assigned Managed Identity | No stored credentials |
| Networking | 5 subnets + NSGs | Network segmentation |
| SSL | Self-signed certificates | HTTPS termination |

**Cost:** ~$40-50/month (all lowest cost tiers)

## Directory Structure

```
reference/stage-ultimate/
+-- README.md                    # Quick-start guide (6 steps)
+-- ARCHITECTURE.md              # 10 mermaid diagrams
+-- PLAN-INFRASTRUCTURE.md       # Detailed infrastructure spec
+-- PLAN-APPLICATION.md          # Detailed application spec
|
+-- infrastructure/              # Azure provisioning
|   +-- provision.sh            # Main script (~600 lines)
|   +-- cloud-init-bastion.yaml # SSH hardening, fail2ban
|   +-- cloud-init-proxy.yaml   # nginx, SSL, fail2ban
|   +-- cloud-init-app-server.yaml # Python, Azure CLI
|
+-- application/                 # Flask application
|   +-- app.py                  # Application factory
|   +-- config.py               # Configuration with Key Vault fallback
|   +-- models.py               # SQLAlchemy models
|   +-- routes.py               # Blueprint with all routes
|   +-- validators.py           # Input validation
|   +-- keyvault.py             # Azure Key Vault integration
|   +-- wsgi.py                 # Gunicorn entry point
|   +-- requirements.txt        # Production dependencies
|   +-- templates/              # Jinja2 templates (6 files)
|   +-- static/style.css        # Application styling
|
+-- deploy/                      # Deployment automation
    +-- deploy.sh               # Main deployment script
    +-- nginx/                  # Reverse proxy config
    +-- systemd/                # Service unit file
```

## Quick Start

```bash
# 1. Provision infrastructure
cd reference/stage-ultimate/infrastructure
./provision.sh

# 2. Wait for cloud-init

# 3. Deploy application
cd ../deploy
./deploy.sh

# 4. Access application
PROXY_IP=$(az vm show -g flask-ultimate-rg -n flask-ultimate-proxy --show-details -o tsv --query publicIps)
echo "https://$PROXY_IP/"
```

## Documentation Files

- **README.md** - Quick-start with prerequisites, steps, troubleshooting
- **ARCHITECTURE.md** - 10 visual diagrams (network topology, request flow, SSH management, NSG rules, trust boundaries, deployment pipeline)
- **PLAN-INFRASTRUCTURE.md** - Complete infrastructure specification
- **PLAN-APPLICATION.md** - Complete application specification
