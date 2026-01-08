# System Context (C1)

## System Context (C4 Model Level 1)

This document provides the highest level view of the Flask Three-Tier Application, showing how it fits into the broader environment of users.

### System Context Diagram

![](embed:C1-Context)

### Context Description

#### The System

**Flask Three-Tier Application** is a demo web application that:

- Provides a landing page with navigation to the demo
- Offers a demo form for creating and viewing entries
- Stores data persistently in PostgreSQL
- Exposes JSON API endpoints for entries and health checks
- Runs on simplified Azure infrastructure (single VM)

#### Users (Actors)

| Actor | Description | Interaction |
|-------|-------------|-------------|
| **Application User** | Anyone accessing the demo application | Uses demo form, views entries via browser (HTTPS) |
| **Developer** | Person deploying and maintaining the application | SSH access for deployment, monitors via browser (HTTPS) |

### Key Architectural Decisions

1. **Simplified IaaS Approach**: Single VM running both nginx and Flask for learning environments
2. **Python Flask**: Lightweight web framework with Jinja2 templating (SSR) and SQLAlchemy ORM
3. **PostgreSQL**: Robust open-source relational database, available as PaaS on Azure (Flexible Server)
4. **Direct SSH Access**: No bastion host - simplified for learning, not production
5. **Public Database Access**: PostgreSQL exposed publicly for simplicity (learning environment only)

### Quality Attributes

Key non-functional requirements affecting architecture:

| Attribute | Requirement | Impact |
|-----------|-------------|--------|
| **Simplicity** | Easy to understand and deploy | Single VM design, minimal network complexity |
| **Cost** | Minimize learning environment costs | ~$20/month with smallest SKUs |
| **Response Time** | Pages load < 3 seconds | nginx caching, optimized queries |
| **Security** | HTTPS only | SSL termination at nginx (self-signed) |

### Scope Boundary

#### In Scope

- Landing page and demo application
- Entry creation and listing
- JSON API for entries
- HTTPS encryption
- Health monitoring endpoint

#### Out of Scope (Learning Environment)

- User authentication/authorization
- Network segmentation (bastion host)
- Private database access
- High availability
- Auto-scaling

### Next Level

See [Containers (C2)](03-containers.md) for the technical building blocks that make up this system.
