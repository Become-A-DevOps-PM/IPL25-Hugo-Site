# Containers (C2)

## Three-Tier Container Architecture

This document shows the three tiers of the application as C4 containers - the high-level building blocks that make up the system.

> **C4 "Container"** = A separately deployable/runnable unit, NOT a Docker container.

### Container Diagram

![](embed:C2-Containers)

### The Three Tiers

| Tier | Container | Technology | Deployment |
|------|-----------|------------|------------|
| **Presentation** | Web Browser | HTML5, CSS3 | User's device |
| **Application** | Application Server | Flask, nginx, Gunicorn | Azure VM |
| **Data** | PostgreSQL Database | PostgreSQL 16 | Azure PaaS |

### Tier 1: Presentation (Web Browser)

The presentation tier runs entirely in the user's web browser.

| Component | Technology | Purpose |
|-----------|------------|---------|
| HTML Pages | HTML5 | Rendered documents from Jinja2 templates |
| CSS Styles | CSS3 | Visual styling (style.css) |
| HTML Forms | HTML Form Elements | User input for data entry |
| Navigation | HTML Anchors | Page navigation and links |

**Key Characteristics:**
- Server-side rendering (no JavaScript framework)
- Forms use standard HTML POST submissions
- CSS provides responsive layout
- Browser handles all presentation logic

### Tier 2: Application (Flask Server)

The application tier handles all business logic and page rendering.

| Layer | Components | Purpose |
|-------|------------|---------|
| **Infrastructure** | nginx, Gunicorn | HTTP handling, SSL, process management |
| **Routing** | Flask Blueprints | URL routing to handlers |
| **Business Logic** | EntryService | CRUD operations |
| **Data Access** | Entry Model | ORM mapping |
| **Templates** | Jinja2 | HTML generation |

**Key Characteristics:**
- Single VM running nginx + Gunicorn + Flask
- Blueprint-based route organization
- Service layer for business logic
- SQLAlchemy ORM for data access

### Tier 3: Data (PostgreSQL)

The data tier provides persistent storage.

| Table | Columns | Purpose |
|-------|---------|---------|
| `entries` | id, value, created_at | Stores demo entries |

**Key Characteristics:**
- Azure PostgreSQL Flexible Server (PaaS)
- Public access enabled for learning environment
- SSL required for connections
- Schema managed by SQLAlchemy

### Data Flow Between Tiers

#### User Submits Form (Tier 1 → Tier 2 → Tier 3)

```
Browser                    Application Server                  Database
   │                              │                               │
   │  POST /demo (form data)      │                               │
   │─────────────────────────────>│                               │
   │                              │  INSERT INTO entries          │
   │                              │──────────────────────────────>│
   │                              │              OK               │
   │                              │<──────────────────────────────│
   │  302 Redirect                │                               │
   │<─────────────────────────────│                               │
   │                              │                               │
```

#### User Views Page (Tier 1 ← Tier 2 ← Tier 3)

```
Browser                    Application Server                  Database
   │                              │                               │
   │  GET /demo                   │                               │
   │─────────────────────────────>│                               │
   │                              │  SELECT * FROM entries        │
   │                              │──────────────────────────────>│
   │                              │       [entry rows]            │
   │                              │<──────────────────────────────│
   │  HTML (rendered page)        │                               │
   │<─────────────────────────────│                               │
   │                              │                               │
```

### Network Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  USER DEVICE (Presentation Tier)                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Web Browser                                             │    │
│  │  - Renders HTML/CSS                                      │    │
│  │  - Handles forms                                         │    │
│  │  - Manages navigation                                    │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS/443
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  AZURE VM (Application Tier) - 10.0.0.x                          │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  nginx (:443) → Gunicorn (:5001) → Flask                │    │
│  │  - SSL termination                                       │    │
│  │  - Reverse proxy                                         │    │
│  │  - Static file serving                                   │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ PostgreSQL/5432 (SSL)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  AZURE POSTGRESQL (Data Tier) - psql-flask-dev                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  PostgreSQL Flexible Server                              │    │
│  │  - Database: flask                                       │    │
│  │  - Table: entries                                        │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### Technology Choices by Tier

| Tier | Choice | Rationale |
|------|--------|-----------|
| **Presentation** | Server-side HTML | Simple, no JS framework needed |
| **Presentation** | CSS3 | Standard styling, responsive |
| **Application** | Flask | Lightweight, blueprint support |
| **Application** | nginx | Industry standard reverse proxy |
| **Application** | Gunicorn | Production-grade WSGI server |
| **Application** | SQLAlchemy | Powerful ORM, migration support |
| **Data** | PostgreSQL | Robust, Azure PaaS available |

### Next Level

See [Components (C3)](04-components.md) for the internal structure of each tier.
