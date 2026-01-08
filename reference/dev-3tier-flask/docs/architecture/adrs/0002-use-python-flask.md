# 2. Use Python Flask for Web Application

Date: 2025-12-15

## Status

Accepted

## Context

We need to select a web framework for the registration application.

Options considered:
1. Python Flask
2. Python Django
3. Node.js Express
4. Go with Gin

## Decision

We will use Python Flask with:
- Jinja2 for server-side templating
- SQLAlchemy for database ORM
- Gunicorn as WSGI production server

## Consequences

**Positive:**
- Lightweight and simple to understand
- Excellent documentation and community
- Easy to deploy on Linux VMs
- Good integration with PostgreSQL via psycopg2

**Negative:**
- Synchronous by default (acceptable for expected load)
- Less built-in features than Django (acceptable for simple app)
