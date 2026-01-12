# Operations Runbook: Container Apps Deployment

## Goal

Deploy the dev-3tier-flask application to Azure using Container Apps and SQL Database, providing a cost-effective, auto-scaling solution.

> **What this runbook covers:**
>
> - Provisioning Azure infrastructure using Bicep (Container Registry, Container Apps Environment, SQL Database)
> - Building and pushing a Docker image to Azure Container Registry
> - Deploying the Flask application as a Container App
> - Creating the initial admin user
> - Verifying the complete deployment end-to-end

## Prerequisites

> **Before starting, ensure you have:**
>
> - Azure subscription with Contributor access
> - Azure CLI 2.50+ installed and configured
> - Docker Desktop installed and running
> - `jq` JSON processor installed
> - Git installed
> - Bash shell (macOS Terminal, Linux, or WSL on Windows)

## Architecture Overview

This deployment uses Azure Container Apps with SQL Database:

```
Internet ──HTTPS──→ Azure Container Apps ──→ Azure SQL Database Basic
                    (Flask + Gunicorn)       (Always on, ~$5/month)
                    Auto-scale 0-N
                    Cold start: 2-5 sec
                         │
                         ↓
                    Azure Container Registry
                    (Store Docker images)
```

> **Infrastructure Components:**
>
> | Component | Azure Resource | Specification |
> |-----------|----------------|---------------|
> | Container Registry | ACR Basic | Store Docker images |
> | Container Environment | Container Apps Environment | Shared execution environment |
> | Application | Container App | Auto-scaling 0-3 replicas |
> | Database | SQL Database Basic | 5 DTUs, always on |
> | Monitoring | Log Analytics Workspace | Container logs |
>
> **Estimated Costs:** ~$5-7/month
>
> - Container Apps free tier: 180,000 vCPU-sec/month
> - SQL Database Basic: ~$5/month
> - Container Registry Basic: ~$0.17/day (~$5/month)
>
> **Deployment Time:** 8-12 minutes total

## Deployment Steps

### Overview

1. **Prepare Local Environment**
2. **Configure Secrets**
3. **Provision Azure Infrastructure**
4. **Build and Push Docker Image**
5. **Deploy Container App and Create Admin User**
6. **Verify Deployment**

### **Step 1:** Prepare Local Environment

Before deploying, verify that all required tools are installed and properly configured.

1. **Verify Azure CLI installation:**

   ```bash
   az --version
   ```

   > Expected output: `azure-cli 2.50.0` or higher

2. **Log in to Azure:**

   ```bash
   az login
   ```

3. **Verify Docker is installed and running:**

   ```bash
   docker --version
   docker info
   ```

   > If Docker is not running, start Docker Desktop.

4. **Verify jq is installed:**

   ```bash
   jq --version
   ```

   > If not installed:
   >
   > - macOS: `brew install jq`
   > - Ubuntu/Debian: `sudo apt install jq`

5. **Navigate to the project directory:**

   ```bash
   cd reference/dev-3tier-flask
   ```

> **Quick check:** All commands return valid output without errors

### **Step 2:** Configure Secrets

The deployment requires a secure password for SQL Database. This is stored locally in `parameters-containerapp.json`.

1. **The secrets file is auto-generated** during provisioning if it doesn't exist:

   ```bash
   ls infrastructure/parameters-containerapp.json 2>/dev/null || echo "Will be created during provisioning"
   ```

2. **Or manually create it** using the example file:

   ```bash
   cp infrastructure/parameters-containerapp.example.json infrastructure/parameters-containerapp.json
   ```

   Then edit to add a secure password (must meet SQL Server complexity requirements).

> **Security Warning**
>
> - **NEVER** commit `parameters-containerapp.json` to version control
> - The file is already in `.gitignore`
> - Password must be 8+ characters with uppercase, lowercase, numbers, and symbols

### **Step 3:** Provision Azure Infrastructure

This step creates the Azure resources: Resource Group, Container Registry, Container Apps Environment, and SQL Database.

1. **Run the infrastructure provisioning script:**

   ```bash
   ./infrastructure/provision-containerapp.sh
   ```

   > The script will:
   >
   > 1. Check prerequisites (Azure CLI, Docker, jq)
   > 2. Create `parameters-containerapp.json` with a secure password if needed
   > 3. Create resource group `rg-flask-dev-aca` in `swedencentral`
   > 4. Deploy Bicep templates (ACR, Container Apps Environment, SQL Database)

2. **Wait for SQL Database to be ready:**

   ```bash
   ./deploy/scripts/wait-for-sql.sh
   ```

   > SQL Database Basic tier is usually ready within 1-2 minutes.

3. **Verify resources were created:**

   ```bash
   az resource list -g rg-flask-dev-aca -o table
   ```

   > Expected resources:
   >
   > - `acrflaskdev` (Container Registry)
   > - `cae-flask-dev` (Container Apps Environment)
   > - `sql-flask-dev` (SQL Server)
   > - `flask` (SQL Database)
   > - `log-flask-dev` (Log Analytics Workspace)

> **Quick check:** All resources show in the resource list, SQL Database status is "Online"

### **Step 4:** Build and Push Docker Image

Build the Flask application Docker image and push it to Azure Container Registry.

1. **Run the build and push script:**

   ```bash
   ./deploy/build-and-push.sh
   ```

   > The script will:
   >
   > 1. Log in to Azure Container Registry
   > 2. Build the Docker image with SQL Server ODBC driver
   > 3. Push the image to ACR

2. **Verify the image was pushed:**

   ```bash
   az acr repository list --name acrflaskdev -o table
   ```

   > Expected output: `flask-app`

> **Quick check:** Image `flask-app:latest` exists in ACR

### **Step 5:** Deploy Container App and Create Admin User

Deploy the Container App with the Flask application and create the admin user.

1. **Deploy the Container App:**

   ```bash
   ./deploy/deploy-containerapp.sh
   ```

   > The script will:
   >
   > 1. Create the Container App with the image from ACR
   > 2. Configure DATABASE_URL environment variable
   > 3. Set up auto-scaling (0-3 replicas)
   > 4. Initialize database tables

2. **Wait for the application to respond:**

   ```bash
   ./deploy/scripts/wait-for-containerapp.sh
   ```

   > The first request may trigger a cold start (2-5 seconds).

3. **Get the application URL:**

   ```bash
   source config-containerapp.sh
   APP_FQDN=$(get_container_app_fqdn)
   echo "Application URL: https://$APP_FQDN/"
   ```

4. **Create the admin user:**

   ```bash
   az containerapp exec \
       --name ca-flask-dev \
       --resource-group rg-flask-dev-aca \
       --command flask -- create-admin admin
   ```

   > You will be prompted to enter and confirm a password (minimum 8 characters).

5. **Test the admin login:**

   - Navigate to `https://<APP_FQDN>/auth/login`
   - Enter username: `admin`
   - Enter the password you created
   - You should be redirected to `/admin/attendees`

> **Quick check:** Can log in at `/auth/login` and access `/admin/attendees`

### **Step 6:** Verify Deployment

Run the comprehensive verification test suite.

1. **Run the verification tests:**

   ```bash
   ./deploy/scripts/verification-tests-containerapp.sh
   ```

   > This runs 6 tests:
   >
   > | Test | Endpoint | Verification |
   > |------|----------|--------------|
   > | E1 | `/api/health` | Returns `{"status": "ok"}` |
   > | E2 | `/` | Landing page loads |
   > | E3 | `/demo` | Demo page loads |
   > | E4 | `/api/entries` | Returns JSON array |
   > | E5 | `/register` | Registration form loads |
   > | E6 | HTTPS | Valid managed certificate |

2. **Review the test results:**

   > Expected output:
   >
   > ```
   > Total: 6 | Passed: 6 | Failed: 0
   > Classification: PASS
   > ```

3. **Perform manual verification:**

   - Open `https://<APP_FQDN>/` - landing page displays
   - Open `https://<APP_FQDN>/demo` - demo form works
   - Open `https://<APP_FQDN>/register` - submit a registration
   - Log in as admin and view attendees

> **Success Indicators:**
>
> - All 6 verification tests pass
> - HTTPS works without certificate warnings (managed cert)
> - Application auto-scales (check Azure Portal)

## One-Command Deployment

For convenience, you can run the entire deployment with a single command:

```bash
./deploy-all-containerapp.sh
```

This orchestrates all steps automatically.

## Common Issues

> **If you encounter problems:**
>
> **Docker build fails:**
>
> - Ensure Docker Desktop is running
> - Check available disk space
> - Try `docker system prune` to clean up
>
> **Container App not responding:**
>
> - Check container logs: `az containerapp logs show --name ca-flask-dev --resource-group rg-flask-dev-aca`
> - Check revision status: `az containerapp revision list --name ca-flask-dev --resource-group rg-flask-dev-aca -o table`
>
> **Database connection errors:**
>
> - Verify DATABASE_URL: `az containerapp show --name ca-flask-dev --resource-group rg-flask-dev-aca --query "properties.template.containers[0].env"`
> - Check SQL firewall allows Azure services
>
> **Image push fails:**
>
> - Re-authenticate: `az acr login --name acrflaskdev`
> - Check ACR exists: `az acr show --name acrflaskdev`

## Cleanup

Remove all Azure resources to stop incurring costs.

1. **Run the cleanup script:**

   ```bash
   ./delete-all-containerapp.sh
   ```

   > This will:
   >
   > - Prompt for confirmation
   > - Delete the entire resource group and all resources
   > - Show progress during deletion

2. **Verify resources are deleted:**

   ```bash
   az group show -n rg-flask-dev-aca 2>/dev/null || echo "Resource group deleted"
   ```

3. **Clean up local secrets (optional):**

   ```bash
   rm infrastructure/parameters-containerapp.json
   ```

> **Deletion Time:** 3-5 minutes

## Operational Commands Reference

> **View Container Logs:**
>
> ```bash
> az containerapp logs show --name ca-flask-dev --resource-group rg-flask-dev-aca --follow
> ```
>
> **Execute Command in Container:**
>
> ```bash
> az containerapp exec --name ca-flask-dev --resource-group rg-flask-dev-aca --command bash
> ```
>
> **Scale Container App:**
>
> ```bash
> # Scale to always have at least 1 replica (no cold starts)
> az containerapp update --name ca-flask-dev --resource-group rg-flask-dev-aca --min-replicas 1
>
> # Scale back to 0 minimum (cost-saving)
> az containerapp update --name ca-flask-dev --resource-group rg-flask-dev-aca --min-replicas 0
> ```
>
> **Update Container Image:**
>
> ```bash
> # After code changes, rebuild and push
> ./deploy/build-and-push.sh
>
> # Update the container app
> az containerapp update --name ca-flask-dev --resource-group rg-flask-dev-aca \
>     --image acrflaskdev.azurecr.io/flask-app:latest
> ```
>
> **View Revision History:**
>
> ```bash
> az containerapp revision list --name ca-flask-dev --resource-group rg-flask-dev-aca -o table
> ```

## Summary

You have successfully deployed the dev-3tier-flask application using Container Apps:

- Provisioned Azure infrastructure using Bicep IaC
- Built and pushed a Docker image to ACR
- Deployed a Flask application with auto-scaling
- Configured SQL Database with secure credentials
- Created an admin user for protected routes
- Verified all components work end-to-end

> **Key Resources Created:**
>
> | Resource | Name | Purpose |
> |----------|------|---------|
> | Resource Group | `rg-flask-dev-aca` | Container for all resources |
> | Container Registry | `acrflaskdev` | Store Docker images |
> | Container Apps Env | `cae-flask-dev` | Shared execution environment |
> | Container App | `ca-flask-dev` | Flask application |
> | SQL Server | `sql-flask-dev` | Database server |
> | SQL Database | `flask` | Application database |
>
> **Endpoints:**
>
> | URL | Purpose |
> |-----|---------|
> | `https://<FQDN>/` | Application landing page |
> | `https://<FQDN>/admin/attendees` | Admin dashboard |
> | `https://<FQDN>/api/health` | Health check endpoint |

## Comparison with VM-Based Deployment

| Aspect | VM-Based | Container Apps |
|--------|----------|----------------|
| Compute Cost | ~$5/month (always on) | ~$0-2/month (scales to zero) |
| Database Cost | ~$16/month (PostgreSQL) | ~$5/month (SQL Basic) |
| **Total Cost** | **~$20/month** | **~$5-7/month** |
| Cold Start | None (always running) | 2-5 seconds |
| SSL Certificate | Self-signed (warning) | Managed (no warning) |
| SSH Access | Yes | No (use `az containerapp exec`) |
| Auto-scaling | Manual | Automatic (0-N) |

## Done!

The deployment is complete. Your application is running on Azure Container Apps with auto-scaling and managed TLS certificates.
