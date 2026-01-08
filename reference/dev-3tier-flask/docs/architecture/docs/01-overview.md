# Flask Three-Tier Application

## Overview

The Flask Three-Tier Application is a simplified demo application deployed on Azure, designed for learning application development patterns without infrastructure complexity.

This documentation accompanies the C4 architecture model and provides detailed explanations of each architectural level.

### Key Features

- **Landing Page**: Welcome page with navigation to demo
- **Demo Application**: Form-based entry management with database persistence
- **API Endpoints**: JSON API for entries and health checks
- **Health Endpoint**: System monitoring capability (`/api/health`)

### Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Server-side rendered HTML (Jinja2) |
| Backend | Python Flask 3.0+ with Gunicorn WSGI |
| Database | PostgreSQL 16 (Azure Flexible Server) |
| Web Server | nginx reverse proxy with self-signed SSL |
| Infrastructure | Azure IaaS (Single VM) |
| IaC | Bicep (declarative) |

### Architecture Levels

This documentation follows the [C4 model](https://c4model.com/) for visualizing software architecture:

| Level | View | Description |
|-------|------|-------------|
| **C1** | System Context | Actors and the system boundary |
| **C2** | Containers | Technical building blocks (VM, database) |
| **C3** | Components | Internal structure of the Flask application |
| **Deployment** | Infrastructure | Simplified Azure deployment topology |

### Quick Links

- [System Context (C1)](02-context.md) - Who uses the system?
- [Containers (C2)](03-containers.md) - What are the main technical components?
- [Components (C3)](04-components.md) - How does the Flask app work internally?
- [Deployment](05-deployment.md) - How is it deployed on Azure?

### Architecture Decisions

Key architectural decisions are documented in the ADRs (Architecture Decision Records):

- **ADR-0001**: Use Pure IaaS Approach
- **ADR-0002**: Use Python Flask for Web Application
- **ADR-0003**: Use Bastion Host for SSH Access (Superseded by ADR-0004)
- **ADR-0004**: Use Direct SSH Access for Simplified Learning Environment

### Application Structure

| Component | Location |
|-----------|----------|
| Infrastructure (Bicep) | `infrastructure/` |
| Flask Application | `application/` |
| Deployment Scripts | `deploy/` |
| Cloud-init config | `infrastructure/cloud-init/` |

### Flask Application Layout

```
application/
├── app/
│   ├── __init__.py         # Application factory (create_app)
│   ├── extensions.py       # Flask extensions (db)
│   ├── routes/
│   │   ├── main.py         # Landing page (/)
│   │   ├── demo.py         # Demo form (/demo)
│   │   └── api.py          # API endpoints (/api/*)
│   ├── models/
│   │   └── entry.py        # Entry model
│   ├── services/
│   │   └── entry_service.py
│   └── templates/
├── tests/
├── config.py               # Dev/Prod/Test configs
└── wsgi.py                 # Gunicorn entry point
```
