# Flask Three-Tier Application

## Overview

The Flask Three-Tier Application is a demonstration of classic three-tier architecture deployed on Azure. It separates concerns into presentation, application, and data tiers for clarity and maintainability.

This documentation follows the [C4 model](https://c4model.com/) and provides detailed explanations at each architectural level.

### Three-Tier Architecture

| Tier | Location | Technology | Responsibility |
|------|----------|------------|----------------|
| **Presentation** | Web Browser | HTML, CSS, Forms | User interface, interaction |
| **Application** | Azure VM | Flask, nginx, Gunicorn | Business logic, routing |
| **Data** | Azure PostgreSQL | PostgreSQL 16 | Persistent storage |

```
┌─────────────────────────────────────────────────────────────────┐
│  TIER 1: PRESENTATION (Browser)                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ HTML Pages  │  │ CSS Styles  │  │ HTML Forms  │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  TIER 2: APPLICATION (Flask Server)                              │
│  ┌───────┐  ┌──────────┐  ┌───────────┐  ┌──────────┐          │
│  │ nginx │──│ Gunicorn │──│ Flask App │──│ Services │          │
│  └───────┘  └──────────┘  └───────────┘  └──────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ PostgreSQL
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  TIER 3: DATA (PostgreSQL)                                       │
│  ┌─────────────────────────────────────────────────┐            │
│  │ entries table (id, value, created_at)           │            │
│  └─────────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

### Key Features

- **Landing Page**: Welcome page with navigation (`/`)
- **Demo Application**: Form-based entry management (`/demo`)
- **API Endpoints**: JSON API for entries and health (`/api/*`)

### Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Server-side rendered HTML (Jinja2), CSS3 |
| Backend | Python Flask 3.0+ with Gunicorn WSGI |
| Database | PostgreSQL 16 (Azure Flexible Server) |
| Web Server | nginx reverse proxy with self-signed SSL |
| Infrastructure | Azure IaaS (Single VM + PaaS Database) |
| IaC | Bicep (declarative) |

### Architecture Levels (C4 Model)

| Level | View | Description |
|-------|------|-------------|
| **C1** | System Context | Actors and the system boundary |
| **C2** | Containers | The three tiers as containers |
| **C3** | Components | Internals of each tier |
| **Deployment** | Infrastructure | Azure deployment topology |

### Quick Links

- [System Context (C1)](02-context.md) - Who uses the system?
- [Containers (C2)](03-containers.md) - What are the three tiers?
- [Components (C3)](04-components.md) - How do components work within each tier?
- [Deployment](05-deployment.md) - How is it deployed on Azure?

### Architecture Decisions

Key architectural decisions are documented in the ADRs:

- **ADR-0001**: Use Pure IaaS Approach
- **ADR-0002**: Use Python Flask for Web Application
- **ADR-0003**: Use Bastion Host for SSH Access (Superseded)
- **ADR-0004**: Use Direct SSH for Simplified Learning Environment

### Source Code Structure

```
application/
├── app/
│   ├── __init__.py           # Application factory
│   ├── extensions.py         # Flask extensions (db, migrate)
│   ├── routes/
│   │   ├── main.py           # Tier 2: Landing page blueprint
│   │   ├── demo.py           # Tier 2: Demo form blueprint
│   │   └── api.py            # Tier 2: API blueprint
│   ├── models/
│   │   └── entry.py          # Tier 3: ORM model
│   ├── services/
│   │   └── entry_service.py  # Tier 2: Business logic
│   ├── templates/            # Tier 1: HTML templates
│   │   ├── base.html
│   │   ├── landing.html
│   │   └── demo.html
│   └── static/css/           # Tier 1: Stylesheets
│       └── style.css
├── config.py                 # Configuration classes
└── wsgi.py                   # Gunicorn entry point
```
