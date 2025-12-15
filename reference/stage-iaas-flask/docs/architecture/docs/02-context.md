# System Context (C1)

## System Context (C4 Model Level 1)

This document provides the highest level view of the Webinar Registration Website system, showing how it fits into the broader environment of users and external systems.

### System Context Diagram

![](embed:C1-Context)

### Context Description

#### The System

**Webinar Registration Website** is a web application that:

- Provides a public-facing registration form for upcoming webinars
- Stores registration data persistently
- Allows marketing staff to view who has registered
- Runs entirely on Azure infrastructure (IaaS approach)
- Includes the web frontend (HTML/CSS/JS rendered in user's browser)

#### Users (Actors)

| Actor | Description | Interaction |
|-------|-------------|-------------|
| **Event Attendee** | External users (potential customers, partners) who discover the webinar through marketing channels | Register for webinars via browser (HTTPS) |
| **Marketing Administrator** | Internal staff responsible for managing webinar events | View registration lists via browser (HTTPS) |
| **System Administrator** | IT operations staff responsible for infrastructure | Deploy, configure, and maintain via terminal (SSH) |

### Key Architectural Decisions

1. **Pure IaaS Approach**: Traditional infrastructure model using self-managed VMs on Azure
2. **Python Flask**: Lightweight web framework with Jinja2 templating (SSR) and SQLAlchemy ORM
3. **PostgreSQL**: Robust open-source relational database, available as PaaS on Azure (Flexible Server)
4. **SSL/TLS Encryption**: Self-signed certificates for learning environment (Let's Encrypt recommended for production)
5. **No External Identity Provider**: Simple application without authentication requirements for attendee registration

### Quality Attributes

From the PRD, the key non-functional requirements affecting architecture:

| Attribute | Requirement | Impact |
|-----------|-------------|--------|
| **Availability** | >=99% uptime during business hours | Single VM design acceptable for MVP |
| **Response Time** | Pages load < 3 seconds on broadband | Nginx caching, optimized queries |
| **Capacity** | Support 100 concurrent users | Single app server sufficient |
| **Security** | HTTPS only, OWASP guidelines | SSL termination at proxy, bastion host for SSH access, private subnets for app/data tiers, NSGs restricting traffic flow |

### Scope Boundary

#### In Scope

- Registration form and data persistence
- Admin view of registrations
- HTTPS encryption
- Basic health monitoring

#### Out of Scope (for this stage)

- User authentication/authorization
- Email notifications
- Payment processing
- Multi-region deployment
- Auto-scaling

### Next Level

See [Containers (C2)](03-containers.md) for the technical building blocks that make up this system.
