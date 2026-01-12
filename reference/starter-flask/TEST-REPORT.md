# Test Report: Starter Flask on Azure Container Apps

**Date:** 2026-01-12
**Status:** SUCCESS

## Deployment Summary

| Item | Value |
|------|-------|
| App Name | starter-flask-app |
| Resource Group | rg-starter-flask |
| Location | swedencentral |
| App URL | https://starter-flask-app.wittydesert-1c125910.swedencentral.azurecontainerapps.io |
| Deploy Method | `az containerapp up` with Oryx++ (no Dockerfile) |
| Total Deploy Time | ~5 minutes |

## Verification Results

| Test | Expected | Actual | Status |
|------|----------|--------|--------|
| Root endpoint (`/`) | "Hello from Azure Container Apps!" | "Hello from Azure Container Apps!" | PASS |
| Health endpoint (`/health`) | `{"status":"ok"}` | `{"status":"ok"}` | PASS |
| HTTPS | Certificate valid | Certificate valid (Azure-managed) | PASS |

## Manual Verification Steps

From your laptop, run these commands:

```bash
# 1. Check the app is deployed
az containerapp show \
    --name "starter-flask-app" \
    --resource-group "rg-starter-flask" \
    --query "properties.configuration.ingress.fqdn" \
    -o tsv

# 2. Test root endpoint
curl https://starter-flask-app.wittydesert-1c125910.swedencentral.azurecontainerapps.io/

# 3. Test health endpoint
curl https://starter-flask-app.wittydesert-1c125910.swedencentral.azurecontainerapps.io/health

# 4. View container logs
az containerapp logs show \
    --name "starter-flask-app" \
    --resource-group "rg-starter-flask" \
    --follow

# 5. Check app status
az containerapp show \
    --name "starter-flask-app" \
    --resource-group "rg-starter-flask" \
    --query "{name:name, status:properties.runningStatus, replicas:properties.template.scale}" \
    -o table
```

## Issues Encountered and Solutions

### Issue 1: Oryx++ Buildpacks Failed Initially

**Problem:** The initial buildpack detection tried to build as a .NET 7 application and failed:

```
===> DETECTING
[detector] Unable to detect .NET 7 application in provided source.
ERROR: No buildpack groups passed detection.
```

**Solution:** This is expected behavior. The `az containerapp up` command automatically falls back to ACR Task with Oryx CLI when buildpacks fail. No manual intervention needed.

**Root Cause:** The Oryx++ builder first tries Cloud Native Buildpacks, which have limited language support. When these fail, it falls back to the more flexible ACR Task approach.

### Issue 2: Python Version Auto-Detection

**Problem:** Oryx detected Python 3.8.20 instead of a newer version:

```
Detected following platforms:
  python: 3.8.20
```

**Impact:** The app still works, but Python 3.8 is older than desired.

**Solution (for future):** Add a `runtime.txt` file to specify Python version:

```
# application/runtime.txt
python-3.11
```

Or use a `.python-version` file:

```
3.11
```

### Issue 3: No Explicit WSGI Configuration

**Problem:** We included `gunicorn` in requirements.txt but Oryx doesn't automatically use it.

**Observation:** The app runs anyway because Oryx has default startup behavior for Flask apps.

**Solution (for production):** Add a `startup.txt` or `Procfile` to explicitly specify the startup command:

```
# application/startup.txt
gunicorn --bind 0.0.0.0:5000 app:app
```

Or use a Procfile:

```
# application/Procfile
web: gunicorn --bind 0.0.0.0:$PORT app:app
```

## Resources Created by `az containerapp up`

The single command created these Azure resources:

1. **Resource Group:** `rg-starter-flask`
2. **Container Apps Environment:** `starter-flask-app-env`
3. **Log Analytics Workspace:** `workspace-rgstarterflaskK6EE`
4. **Azure Container Registry:** `cad14aa8c30bacr`
5. **Container App:** `starter-flask-app`

## Cost Considerations

Container Apps uses consumption pricing:
- **When idle:** Scales to zero (minimal cost)
- **When active:** ~$0.000004/vCPU-second + ~$0.000002/GiB-second
- **Estimated monthly:** $5-10 with light usage

The ACR uses Basic tier:
- **Monthly:** ~$5

## Cleanup

To delete all resources:

```bash
./deploy/delete.sh
# or directly:
az group delete --name rg-starter-flask --yes
```

## Lessons Learned

1. **Oryx++ is resilient:** It automatically tries multiple build strategies (buildpacks → ACR Task)

2. **No Dockerfile works:** The simplest deployment path works, but with less control over Python version and WSGI server

3. **For production:** Consider adding:
   - `runtime.txt` for Python version control
   - `startup.txt` or `Procfile` for explicit startup command
   - Or just use a Dockerfile for full control

4. **Deployment is fast:** ~5 minutes from source to running app

5. **HTTPS is automatic:** Azure manages SSL certificates

## Next Steps (Optional Improvements)

1. Add `runtime.txt` with `python-3.11` for explicit version
2. Add `startup.txt` with gunicorn command for explicit WSGI config
3. Add health check configuration to Container App for better reliability
4. Consider Dockerfile if more control is needed
