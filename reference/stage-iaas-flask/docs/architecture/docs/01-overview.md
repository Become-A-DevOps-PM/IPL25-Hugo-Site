# Webinar Registration Website

## Overview

The Webinar Registration Website is a web application that allows event attendees to register for webinars and marketing administrators to view registrations.

This documentation accompanies the C4 architecture model and provides detailed explanations of each architectural level.

## Key Features

- **Registration Form**: Public-facing form for webinar signup
- **Registration List**: Admin view of all registrations
- **Health Endpoint**: System monitoring capability (`/health`)

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Server-side rendered HTML (Jinja2) |
| Backend | Python Flask 3.0+ with Gunicorn WSGI |
| Database | PostgreSQL 16 (Azure Flexible Server) |
| Web Server | nginx reverse proxy with SSL |
| Infrastructure | Azure IaaS (Virtual Machines) |
| IaC | Bicep (declarative) |

## Architecture Levels

This documentation follows the [C4 model](https://c4model.com/) for visualizing software architecture:

| Level | View | Description |
|-------|------|-------------|
| **C1** | System Context | Actors and the system boundary |
| **C2** | Containers | Technical building blocks (VMs, databases) |
| **C3** | Components | Internal structure of the Flask application |
| **Deployment** | Infrastructure | Azure IaaS deployment topology |

## Quick Links

- [System Context (C1)](02-context.md) - Who uses the system?
- [Containers (C2)](03-containers.md) - What are the main technical components?
- [Components (C3)](04-components.md) - How does the Flask app work internally?
- [Deployment](05-deployment.md) - How is it deployed on Azure?

## Architecture Decisions

Key architectural decisions are documented in the ADRs (Architecture Decision Records):

- **ADR-0001**: Use Pure IaaS Approach
- **ADR-0002**: Use Python Flask for Web Application
- **ADR-0003**: Use Bastion Host for SSH Access

## Source Code

| Component | Location |
|-----------|----------|
| Infrastructure (Bicep) | `infrastructure/` |
| Flask Application | `application/` |
| Deployment Scripts | `deploy/` |
| Cloud-init configs | `infrastructure/cloud-init/` |
