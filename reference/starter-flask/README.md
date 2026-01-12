# Starter Flask - Azure Container Apps

The simplest possible Flask deployment to Azure Container Apps using `az containerapp up` with automatic source-to-container build (Oryx++).

## Prerequisites

- Azure CLI installed and logged in (`az login`)
- Active Azure subscription

## Quick Start

```bash
# Deploy (creates everything automatically)
./deploy/deploy.sh

# Test
curl https://<your-app-url>/
curl https://<your-app-url>/health

# Cleanup
./deploy/delete.sh
```

## What Gets Created

The single `az containerapp up` command creates:

| Resource | Purpose |
|----------|---------|
| Resource Group | Container for all resources |
| Container Registry | Stores the built container image |
| Container Apps Environment | Managed Kubernetes infrastructure |
| Log Analytics Workspace | Logging and monitoring |
| Container App | Your running Flask application |

## Directory Structure

```
starter-flask/
├── README.md           # This file
├── PLAN.md             # Implementation design
├── TEST-REPORT.md      # Deployment verification and issues
├── application/
│   ├── app.py          # Flask application (17 lines)
│   └── requirements.txt # Dependencies (Flask + Gunicorn)
└── deploy/
    ├── deploy.sh       # Deploy to Azure
    └── delete.sh       # Remove all resources
```

## How It Works

### The Magic Command

```bash
az containerapp up \
    --name "starter-flask-app" \
    --resource-group "rg-starter-flask" \
    --location "swedencentral" \
    --source "./application" \
    --ingress external \
    --target-port 5000
```

### Oryx++ Build Process

Since there's no Dockerfile, Azure uses **Oryx++** to automatically:

1. Detect Python from `requirements.txt`
2. Install dependencies
3. Build a container image
4. Push to Azure Container Registry
5. Deploy to Container Apps

## Application Endpoints

| Route | Response |
|-------|----------|
| `GET /` | "Hello from Azure Container Apps!" |
| `GET /health` | `{"status": "ok"}` |

## Estimated Cost

- **Container Apps:** ~$5-10/month (scales to zero when idle)
- **Container Registry:** ~$5/month (Basic tier)

## Troubleshooting

### View Logs

```bash
az containerapp logs show \
    --name "starter-flask-app" \
    --resource-group "rg-starter-flask" \
    --follow
```

### Check Status

```bash
az containerapp show \
    --name "starter-flask-app" \
    --resource-group "rg-starter-flask" \
    --query "{name:name, url:properties.configuration.ingress.fqdn, status:properties.runningStatus}"
```

### Redeploy After Changes

```bash
# Just run deploy again - it will update the existing app
./deploy/deploy.sh
```

## Customization Options

### Specify Python Version

Create `application/runtime.txt`:

```
python-3.11
```

### Explicit Startup Command

Create `application/startup.txt`:

```
gunicorn --bind 0.0.0.0:5000 --workers 2 app:app
```

### Use a Dockerfile Instead

If you need more control, add a `Dockerfile` to the application directory. The `az containerapp up` command will use it automatically.

## Comparison with Other Approaches

| Aspect | This (Oryx++) | With Dockerfile | VM-based |
|--------|---------------|-----------------|----------|
| Complexity | Minimal | Low | High |
| Control | Limited | Full | Full |
| Deploy time | ~5 min | ~5 min | ~20 min |
| Cost | ~$10/month | ~$10/month | ~$20/month |
| Scaling | Automatic | Automatic | Manual |
| HTTPS | Automatic | Automatic | Manual |

## Learn More

- [Azure Container Apps Documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
- [az containerapp up Reference](https://learn.microsoft.com/en-us/azure/container-apps/containerapp-up)
- [Oryx Build System](https://github.com/microsoft/Oryx)
