# News Flash - Three-Tier Architecture Reference

## Overview

**News Flash** is a newsletter subscription application designed to teach three-tier architecture through explicit folder naming. Each folder name (`presentation/`, `business/`, `data/`) directly maps to an architectural layer.

## Purpose

This reference implementation serves as a teaching tool for the ASD (Agile Software Development and Deployment) course. Students build the application step-by-step, learning:

1. Flask application structure
2. Three-tier architecture concepts
3. Template inheritance with Jinja2
4. Configuration management
5. Blueprint organization

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  app/presentation/                                           │
│  ├── routes/      → URL routing, request handling           │
│  └── templates/   → HTML templates (what users see)         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     BUSINESS LAYER                           │
│  app/business/                                               │
│  └── services/    → Business rules, validation, logic       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  app/data/                                                   │
│  ├── models/      → Database models (SQLAlchemy)            │
│  └── repositories/→ Data access patterns                    │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
reference/news-flask/
├── CLAUDE.md                     # This file
├── README.md                     # Quick start guide
│
├── application/                  # Flask application
│   ├── app/
│   │   ├── __init__.py          # Application factory
│   │   ├── config.py            # Configuration classes
│   │   │
│   │   ├── presentation/        # LAYER 1: User interface
│   │   │   ├── routes/          # URL → handler mapping
│   │   │   └── templates/       # Jinja2 HTML templates
│   │   │
│   │   ├── business/            # LAYER 2: Business logic
│   │   │   └── services/        # Service classes
│   │   │
│   │   └── data/                # LAYER 3: Persistence
│   │       ├── models/          # SQLAlchemy models
│   │       └── repositories/    # Data access
│   │
│   ├── requirements.txt         # Python dependencies
│   ├── .env.example             # Environment template
│   ├── .gitignore
│   └── tests/                   # Test suite
│
├── deploy/                       # Deployment scripts
├── infrastructure/               # Azure provisioning
└── docs/                         # Documentation
    └── planning/                # Curriculum and exercises
```

## Development Milestones

### Milestone 1: Presentation Layer (Steps 1-9)
- Flask application factory
- Jinja2 templates with inheritance
- Landing page with modal interaction
- Subscription form on dedicated page
- Thank you page with echoed form data
- Terminal output for verification (no persistence)
- **Status:** In Progress

### Milestone 2: Business Layer (Steps 10-11)
- Service classes with validation
- Email format validation
- Email normalization
- Business rules separated from routes

### Milestone 3: Data Layer (Steps 12-15)
- SQLAlchemy models
- Database migrations with Flask-Migrate
- Repository pattern for data access
- Full layer integration

### Milestone 4: Deployment (Future)
- Azure Container Apps deployment
- Environment configuration
- CI/CD pipeline

## Quick Start

```bash
cd application
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
flask run
```

Visit http://localhost:5000

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Folder naming | Three-tier (`presentation/`, `business/`, `data/`) | Folder names teach architecture |
| Templates location | Inside `presentation/` | Templates ARE presentation |
| CSS approach | Inline in templates | Self-contained exercises |
| Configuration | Environment variables + dataclasses | Best practice, 12-factor app |

## Technology Stack

- **Framework:** Flask 3.x
- **Templating:** Jinja2
- **Database:** SQLite (development), PostgreSQL (production)
- **ORM:** SQLAlchemy with Flask-SQLAlchemy
- **Migrations:** Flask-Migrate

## Related Documentation

- `docs/planning/curriculum-week1.md` - Step-by-step exercise guide
- `README.md` - Quick start for running the application
