+++
title = "Week 3 Technical Recap"
program = "IPL"
cohort = "25"
courses = ["SNS"]
type = "slide"
date = 2025-12-15
weight = 3
draft = false
hidden = false

theme = "sky"
[revealOptions]
controls = true
progress = true
history = true
center = true
+++

### Week 3

## Technical Recap

- The Service Trinity
- HTTP and server-side rendering
- Reverse proxy architecture
- Production deployment with systemd
- Infrastructure as Code with Azure CLI

---

## The Service Trinity

Week 3 completes the three pillars of infrastructure:

```text
┌─────────────┬─────────────┬─────────────┐
│   COMPUTE   │   NETWORK   │   STORAGE   │
│   (Week 1)  │   (Week 2)  │   (Week 3)  │
├─────────────┼─────────────┼─────────────┤
│  VM + CPU   │  VNet + IP  │  Database   │
│   Ubuntu    │   Firewall  │  PostgreSQL │
│   nginx     │   Proxy     │  Disk/Blob  │
└─────────────┴─────────────┴─────────────┘
```

Together: a complete application platform

---

## Relational Databases

**PostgreSQL** - structured data in tables

```text
┌────┬─────────┬─────────────────────┐
│ id │  name   │        email        │
├────┼─────────┼─────────────────────┤
│  1 │ Alice   │ alice@example.com   │
│  2 │ Bob     │ bob@example.com     │
└────┴─────────┴─────────────────────┘
```

- **Schema** defines structure (columns, types)
- **Database instance** a running server you connect to
- **SQL** the language to query and manipulate data

---

## HTTP: Request-Response

The web runs on a simple pattern:

```text
  Browser                         Server
     │                               │
     │──── GET /contact ────────────►│
     │                               │
     │◄─── HTML page ────────────────│
     │                               │
     │──── POST /contact ───────────►│
     │     (form data)               │
     │◄─── Thank you page ───────────│
```

- **GET** = retrieve a resource
- **POST** = submit data
- **PUT** / **DELETE** = update or remove data

---

## Server-Side Rendering

The server builds complete HTML before sending:

```python
# Python code on server
name = request.form.get("name")
return render_template("thanks.html", name=name)
```

```html
<!-- Template with placeholder -->
<h1>Thank you, {{ name }}!</h1>
```

```html
<!-- Browser receives finished HTML -->
<h1>Thank you, Alice!</h1>
```

Jinja2 replaces `{{ }}` placeholders with values

---

## Reverse Proxy

```text
         Internet
             │
     ┌───────┴───────┐
     │     nginx     │  ← Reverse proxy
     │     :80       │    Handles connections, SSL, static files
     └───────┬───────┘
             │
     ┌───────┴───────┐
     │   Gunicorn    │  ← App server (WSGI)
     │    :5001      │    Runs Python/Flask code
     └───────────────┘
```

nginx fronts the application; Gunicorn runs Python code

---

## Secrets in Environment Variables

**Never hardcode credentials in source code**

```python
# Bad - secrets in code (ends up in git)
db_url = "postgresql://user:password@host/db"

# Good - read from environment
import os
db_url = os.environ.get("DATABASE_URL")
```

On Linux, store in `/etc/` for security:

```bash
# /etc/guestbook/environment
DATABASE_URL=postgresql://user:pass@host/db
SECRET_KEY=random-string-here
```

---

## systemd

Linux uses **systemd** to run the application as a service:

```ini
# /etc/systemd/system/guestbook.service
[Unit]
Description=Guestbook Flask Application

[Service]
User=guestbook
EnvironmentFile=/etc/guestbook/environment
ExecStart=/opt/guestbook/venv/bin/gunicorn \
    --bind 127.0.0.1:5001 app:app

[Install]
WantedBy=multi-user.target
```

---

## Infrastructure as Code

Provision Azure resources with **Azure CLI**:

```bash
# Create resource group
az group create --name rg-guestbook --location swedencentral

# Create virtual machine
az vm create --name vm-app --resource-group rg-guestbook \
    --image Ubuntu2404 --size Standard_B1s \
    --admin-username azureuser --generate-ssh-keys

# Open port for web traffic
az vm open-port --name vm-app --resource-group rg-guestbook --port 80
```

Repeatable, version-controlled, scriptable

---

## Dev vs Production

| Aspect | Development | Production |
|--------|-------------|------------|
| Server | python | Gunicorn |
| Database | SQLite (file) | PostgreSQL |
| Secrets | `.env` file | `/etc/` + systemd |
| Access | localhost:5000 | Public IP + domain |
| Process | Manual start | systemd service |

**Same Flask code** - different configuration

---

## The Production Stack

```text
┌─────────────────────────────────────────┐
│              Internet                    │
└───────────────────┬─────────────────────┘
                    │
┌───────────────────┴─────────────────────┐
│  nginx (:80/:443)                        │
│  - SSL termination                       │
│  - Reverse proxy to Gunicorn             │
└───────────────────┬─────────────────────┘
                    │
┌───────────────────┴─────────────────────┐
│  Gunicorn (:5001) ← systemd managed      │
│  - Flask application                     │
└───────────────────┬─────────────────────┘
                    │
┌───────────────────┴─────────────────────┐
│  PostgreSQL (:5432)                      │
└─────────────────────────────────────────┘
```

---

## Summary

<small>

**Service Trinity:** Compute + Network + Storage = complete platform

**HTTP:** GET retrieves, POST submits; request-response pattern

**Server-Side Rendering:** Server builds HTML with Jinja2 templates

**Reverse Proxy:** nginx fronts the app, Gunicorn runs Python code

**Secrets:** Environment variables in `/etc/`, never in source code

**systemd:** Manages Gunicorn as a Linux service (start, restart, boot)

**Infrastructure as Code:** Azure CLI makes provisioning repeatable and scriptable

</small>
