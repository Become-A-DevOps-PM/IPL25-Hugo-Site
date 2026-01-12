# Starter Flask - Implementation Plan

## Overview

This project demonstrates the simplest possible deployment of a Flask application to Azure Container Apps using the `az containerapp up` command with **Oryx++ auto-detection** (no Dockerfile).

## Architecture

```
Internet ──HTTPS──→ Azure Container Apps ──→ Flask App (Gunicorn)
                    (managed ingress)         Port 5000
```

Azure Container Apps provides:
- Managed HTTPS with automatic certificates
- Auto-scaling (including scale to zero)
- Built-in load balancing

## How `az containerapp up` Works

The single command handles the entire deployment:

```bash
az containerapp up \
    --name "starter-flask-app" \
    --resource-group "rg-starter-flask" \
    --location "swedencentral" \
    --source "./application" \
    --ingress external \
    --target-port 5000
```

### What Gets Created

1. **Resource Group** (`rg-starter-flask`)
2. **Azure Container Registry** (auto-named, e.g., `ca<random>acr`)
3. **Container Apps Environment** (with Log Analytics workspace)
4. **Container App** (`starter-flask-app`)

### Oryx++ Build Process

Since no Dockerfile is provided, Azure uses **Oryx++** (Cloud Native Buildpacks):

1. Detects Python from `requirements.txt`
2. Determines Flask framework
3. Sets up Gunicorn as WSGI server
4. Builds runnable container image
5. Pushes to auto-created ACR

## Directory Structure

```
starter-flask/
├── PLAN.md                 # This file
├── TEST-REPORT.md          # Deployment verification and issues
├── README.md               # Quick-start guide
├── application/
│   ├── app.py              # Flask application (17 lines)
│   └── requirements.txt    # Dependencies (2 lines)
└── deploy/
    ├── deploy.sh           # Deploy to Azure
    └── delete.sh           # Cleanup resources
```

## Design Decisions

### 1. No Dockerfile
Let Oryx++ handle the build to demonstrate the simplest possible deployment path.

### 2. Minimal Dependencies
Only `flask` and `gunicorn` - no database, forms, or authentication.

### 3. Port 5000
Standard Flask development port, specified via `--target-port`.

### 4. External Ingress
Makes the app publicly accessible with automatic HTTPS.

## Verification

After deployment:
1. Access the root URL → "Hello from Azure Container Apps!"
2. Access `/health` → `{"status": "ok"}`

## Cost

Approximately $5-10/month with Container Apps consumption pricing.
Scales to zero when idle, so cost can be minimal for learning.

## Comparison with Other Approaches

| Aspect | This Approach | With Dockerfile | VM-based |
|--------|---------------|-----------------|----------|
| Complexity | Minimal | Low | High |
| Control | Limited | Full | Full |
| Build time | ~2-3 min | ~2-3 min | N/A |
| Deploy time | ~3-5 min total | ~3-5 min total | ~15-20 min |
| Infrastructure | Auto-managed | Auto-managed | Manual |
