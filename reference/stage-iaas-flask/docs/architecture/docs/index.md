# Webinar Registration Website

## Overview

The Webinar Registration Website is a web application that allows event attendees to register for webinars and marketing administrators to view registrations.

## Key Features

- **Registration Form**: Public-facing form for webinar signup
- **Registration List**: Admin view of all registrations
- **Health Endpoint**: System monitoring capability

## Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Server-side rendered HTML (Jinja2) |
| Backend | Python Flask with Gunicorn WSGI |
| Database | PostgreSQL (Azure Flexible Server) |
| Web Server | nginx reverse proxy |
| Infrastructure | Azure IaaS (Virtual Machines) |

## Architecture Decisions

Key architectural decisions are documented in the [ADRs](../adrs/) folder.
