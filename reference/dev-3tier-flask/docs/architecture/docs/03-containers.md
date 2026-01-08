# Containers (C2)

## Containers (C4 Model Level 2)

This document zooms into the Flask Three-Tier Application to show the high-level technical building blocks (containers) and how they interact.

> **C4 "Container"** = A separately deployable/runnable unit (VM, application, database), NOT a Docker container.

### Container Diagram

![](embed:C2-Containers)

### Container Inventory

#### Compute Container

| Container | Technology | Purpose | Network Location |
|-----------|------------|---------|------------------|
| **Application Server** | Ubuntu 24.04 LTS, nginx, Gunicorn | Combined reverse proxy and Flask application | `snet-default` (10.0.0.0/24), Public IP |

#### Data Container

| Container | Technology | Purpose | Network Location |
|-----------|------------|---------|------------------|
| **PostgreSQL Database** | Azure PostgreSQL Flexible Server | Persistent data storage | Azure PaaS, Public access |

### Network Flow

#### User Traffic

```
Internet -> Public IP (pip-app) -> nginx:443 -> Flask:5001 -> PostgreSQL:5432
```

#### Administrative Access

```
Internet -> Public IP (pip-app) -> SSH:22 -> VM shell
```

#### Architecture Overview

```
+-----------------------------------------------------------------------+
|  INTERNET                                                              |
+------+------------------------------------+---------------------------+
       | SSH:22                              | HTTPS:443
       v                                     v
+-----------------------------------------------------------------------+
|  APPLICATION SERVER (vm-app)                                           |
|  Ubuntu 24.04 LTS                                                      |
|  +-------------------+     +-------------------+                       |
|  | nginx             |---->| Flask/Gunicorn    |                       |
|  | (port 443)        |     | (port 5001)       |                       |
|  +-------------------+     +-------------------+                       |
+-----------------------------------------------------------------------+
       |
       | PostgreSQL:5432
       v
+-----------------------------------------------------------------------+
|  POSTGRESQL FLEXIBLE SERVER (psql-flask-dev)                           |
|  Azure PaaS, Public Access                                             |
+-----------------------------------------------------------------------+
```

### Container Details

#### 1. Application Server (`vm-app`)

**Purpose**: Combined nginx reverse proxy and Flask application on a single VM

| Aspect | Detail |
|--------|--------|
| Image | Ubuntu 24.04 LTS |
| Size | Standard_B1s (1 vCPU, 1GB RAM) |
| Public IP | Yes (`pip-app`) |
| Inbound Rules | SSH (22), HTTP (80), HTTPS (443) |
| Security | Fail2ban (SSH protection) |

**Software Stack**:

| Component | Version | Purpose |
|-----------|---------|---------|
| nginx | Latest | Reverse proxy, SSL termination |
| Python | 3.x | Runtime environment |
| Gunicorn | Latest | WSGI server |
| Flask | 3.0+ | Web framework |

**nginx Configuration**:

- HTTP -> HTTPS redirect (301)
- SSL with self-signed certificate
- Proxy headers (X-Real-IP, X-Forwarded-For, X-Forwarded-Proto)
- Upstream: `http://127.0.0.1:5001`

**Key Files on VM**:

```
/opt/flask-app/                 # Application code
/opt/flask-app/venv/            # Python virtual environment
/etc/flask-app/app.env          # DATABASE_URL (chmod 640, root:flask-app)
/etc/systemd/system/flask-app.service
/etc/nginx/sites-available/flask-app
/etc/nginx/ssl/                 # SSL certificate and key
```

#### 2. PostgreSQL Database

**Purpose**: Persistent storage for application data

| Aspect | Detail |
|--------|--------|
| Service | Azure Database for PostgreSQL Flexible Server |
| SKU | Burstable B1ms (1 vCPU, 2GB) |
| Version | PostgreSQL 16 |
| Access | Public (0.0.0.0 - 255.255.255.255) |
| Database | `flask` |
| SSL | Required (`sslmode=require`) |

> **Note**: Public access is enabled for learning simplicity. Production environments should use private endpoints.

### Technology Choices

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Web Server | nginx | Industry standard, excellent reverse proxy |
| WSGI Server | Gunicorn | Production-grade, simple configuration |
| Database | PostgreSQL | Robust, open source, excellent Python support |
| Process Manager | systemd | Standard on modern Ubuntu, automatic restarts |
| Infrastructure | Azure Bicep | Declarative IaC, native Azure support |

### Deployment Pipeline

```
+-------------+    +-------------+    +-------------+
| provision.sh|--->|cloud-init   |--->| deploy.sh   |
| (Bicep)     |    |(VM boot)    |    |(App code)   |
+-------------+    +-------------+    +-------------+
     |                   |                   |
     v                   v                   v
 - VNet, Subnet      - Install nginx     - Copy app files
 - NSG               - Install Python    - Install deps
 - VM                - Create users      - Configure DB URL
 - PostgreSQL        - Systemd units     - Initialize database
                     - SSL certificate   - Start service
```

### Comparison with Production Architecture

This simplified architecture differs from production patterns:

| Aspect | dev-3tier-flask | Production Pattern |
|--------|-----------------|-------------------|
| VMs | 1 (combined) | 3+ (bastion, proxy, app) |
| Subnets | 1 | 4+ (segmented by tier) |
| SSH Access | Direct | Via bastion jump host |
| PostgreSQL | Public access | Private DNS/endpoints |
| Cost | ~$20/month | ~$44+/month |
| Complexity | Low | Moderate-High |

### Next Level

See [Components (C3)](04-components.md) for the internal structure of the Flask application.
