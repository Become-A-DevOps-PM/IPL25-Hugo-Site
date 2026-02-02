+++
title = "Provision Azure Infrastructure"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Create Azure resource group, container registry, Container Apps environment, Azure SQL database, and configure environment variables"
weight = 2
+++

# Provision Azure Infrastructure

## Goal

Create the Azure infrastructure needed to host the News Flash application: a resource group, container registry, Container Apps environment, and Azure SQL database. Configure environment variables on the Container App so it is ready to receive the application image from the CI/CD pipeline.

> **What you'll learn:**
>
> - How to provision Azure resources using the Azure CLI
> - When to use Container Apps vs other Azure compute services
> - How Azure Container Registry stores private Docker images
> - How to configure environment variables following the 12-Factor App methodology
> - Best practices for organizing Azure resources with configuration files

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Container-ready application with Dockerfile, wsgi.py, and production config
> - ✓ Azure CLI installed and authenticated (`az login`)
> - ✓ An active Azure subscription
> - ✓ GitHub repository for your application

## Exercise Steps

### Overview

1. **Create Resource Group and Container Registry**
2. **Create Container Apps Environment and Container App**
3. **Provision Azure SQL Database**
4. **Configure Environment Variables**
5. **Verify Resources and Create Cleanup Script**

### **Step 1:** Create Resource Group and Container Registry

Every Azure deployment starts with a resource group — a logical container that holds all related resources for a project. Grouping resources together makes it easy to manage, monitor, and delete everything at once. The container registry stores your Docker images privately, so only your Container Apps can pull them.

1. **Create** the resource group:

   ```bash
   az group create --name rg-news-flash --location swedencentral
   ```

2. **Generate** a globally unique name for the container registry. ACR names must be lowercase, alphanumeric, and globally unique across all of Azure:

   ```bash
   ACR_NAME="acrnewsflash$(openssl rand -hex 4)"
   echo "Your ACR name: $ACR_NAME"
   ```

3. **Create** the container registry:

   ```bash
   az acr create \
     --name $ACR_NAME \
     --resource-group rg-news-flash \
     --sku Basic \
     --admin-enabled true
   ```

4. **Save** the configuration to a file named `.azure-config` in your project root. This file stores resource names so you do not have to remember or retype them:

   > `.azure-config`

   ```bash
   RESOURCE_GROUP="rg-news-flash"
   ACR_NAME="<your-actual-acr-name>"
   LOCATION="swedencentral"
   ```

   Replace `<your-actual-acr-name>` with the value from step 2, or create the file programmatically:

   ```bash
   cat > .azure-config << EOF
   RESOURCE_GROUP="rg-news-flash"
   ACR_NAME="$ACR_NAME"
   LOCATION="swedencentral"
   EOF
   ```

5. **Add** `.azure-config` to your `.gitignore` file to prevent committing environment-specific values:

   ```bash
   echo ".azure-config" >> .gitignore
   ```

> ℹ **Concept Deep Dive**
>
> A **resource group** is Azure's organizational unit. It is not a billing boundary or a security boundary — it is a logical grouping. When you delete a resource group, Azure deletes every resource inside it. This makes cleanup straightforward: one command removes everything.
>
> **Azure Container Registry (ACR)** is a private Docker registry hosted in Azure. The `--admin-enabled true` flag enables simple username/password authentication, which Container Apps uses to pull images. The Basic SKU costs approximately $5/month and provides 10 GB of storage — more than enough for a student project.
>
> ACR names cannot contain hyphens and must be globally unique because the registry URL becomes `<name>.azurecr.io`. The random suffix ensures uniqueness.
>
> ⚠ **Common Mistakes**
>
> - Using hyphens in the ACR name — only lowercase letters and numbers are allowed
> - Forgetting `--admin-enabled true` — Container Apps needs credentials to pull images
> - Not saving the ACR name — you will need it in every subsequent step
>
> ✓ **Quick check:** `az acr show --name $ACR_NAME --resource-group rg-news-flash` returns registry details without errors

### **Step 2:** Create Container Apps Environment and Container App

The Container Apps Environment is the hosting platform where your containers run. It provides shared networking, logging (via Log Analytics), and managed infrastructure. You will create the environment, deploy an nginx placeholder container, and register ACR credentials so the CI/CD pipeline can update the image later.

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ```

2. **Create** the Container Apps Environment:

   ```bash
   az containerapp env create \
     --name cae-news-flash \
     --resource-group $RESOURCE_GROUP \
     --location $LOCATION
   ```

   This command takes a couple of minutes because Azure provisions a Log Analytics workspace and networking infrastructure behind the scenes.

3. **Create** a Container App running an nginx placeholder:

   ```bash
   az containerapp create \
     --name ca-news-flash \
     --resource-group $RESOURCE_GROUP \
     --environment cae-news-flash \
     --image nginx:alpine \
     --target-port 80 \
     --ingress external \
     --min-replicas 1 \
     --max-replicas 1
   ```

   > **Note:** This nginx placeholder will be replaced by the CI/CD pipeline in the next exercise. It starts the Container App with a known-good image so the infrastructure is ready to receive your application.

4. **Register** ACR credentials on the Container App so it can pull images from your private registry:

   ```bash
   ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
   ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
   ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)

   az containerapp registry set \
     --name ca-news-flash \
     --resource-group $RESOURCE_GROUP \
     --server $ACR_LOGIN_SERVER \
     --username $ACR_USERNAME \
     --password $ACR_PASSWORD
   ```

5. **Append** the environment and app names to your configuration file:

   ```bash
   cat >> .azure-config << EOF
   CAE_NAME="cae-news-flash"
   CA_NAME="ca-news-flash"
   EOF
   ```

> ℹ **Concept Deep Dive**
>
> A **Container Apps Environment** is a shared boundary for one or more Container Apps. It provides:
>
> - **Networking isolation** — apps in the same environment can communicate internally
> - **Log Analytics integration** — all container logs are collected automatically
> - **Managed infrastructure** — Azure handles scaling, load balancing, and TLS certificates
>
> **External ingress** exposes the Container App to the internet via Azure's managed HTTPS endpoint. Azure automatically provisions a TLS certificate and terminates HTTPS at the edge — you do not need to configure SSL certificates, nginx reverse proxy, or load balancers. The URL follows the pattern `<app-name>.<random-hash>.<region>.azurecontainerapps.io`.
>
> The **ACR credentials** are registered once during provisioning. Container Apps stores them and reuses them for all future image pulls — including during restarts, scaling events, and CI/CD deployments. This means the GitHub Actions workflow only needs to run `az containerapp update --image ...` without managing registry authentication.
>
> The `--min-replicas 1 --max-replicas 1` flags ensure exactly one container instance runs at all times. Container Apps can scale to zero by default (saving costs when idle), but for this project you want the container always available.
>
> ⚠ **Common Mistakes**
>
> - Creating the environment in a different location than the resource group — keep everything in `swedencentral`
> - Not waiting for the environment creation to complete — it provisions infrastructure and takes a couple of minutes
> - Forgetting `--ingress external` — without it, the Container App has no public URL
> - Forgetting to register ACR credentials — the CI/CD pipeline cannot pull images without them
>
> ✓ **Quick check:** `az containerapp show --name ca-news-flash --resource-group rg-news-flash --query "properties.configuration.registries[0].server"` returns your ACR login server

### **Step 3:** Provision Azure SQL Database

The application needs a database to persist subscriber data. Azure SQL Database is a managed relational database service — Azure handles backups, patching, and availability. The Basic tier costs approximately $5/month, which is suitable for a learning environment.

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ```

2. **Generate** a secure password and a globally unique server name:

   ```bash
   SQL_PASSWORD="$(openssl rand -base64 16)Aa1!"
   SQL_SERVER="sql-news-flash-$(openssl rand -hex 4)"
   echo "SQL Server: $SQL_SERVER"
   echo "SQL Password: $SQL_PASSWORD"
   ```

   **Save both values immediately.** You will need the password later and cannot retrieve it from Azure after creation.

3. **Save** the SQL password and server name to `.azure-config` so you can retrieve them later:

   ```bash
   cat >> .azure-config << EOF
   SQL_SERVER="$SQL_SERVER"
   SQL_PASSWORD="$SQL_PASSWORD"
   EOF
   ```

4. **Create** the SQL Server:

   ```bash
   az sql server create \
     --name $SQL_SERVER \
     --resource-group $RESOURCE_GROUP \
     --location $LOCATION \
     --admin-user sqladmin \
     --admin-password "$SQL_PASSWORD"
   ```

5. **Configure** firewall rules to allow connections:

   ```bash
   # Allow Azure services (required for Container Apps)
   az sql server firewall-rule create \
     --server $SQL_SERVER \
     --resource-group $RESOURCE_GROUP \
     --name AllowAzureServices \
     --start-ip-address 0.0.0.0 \
     --end-ip-address 0.0.0.0

   # Allow all IPs (learning environment only - NOT for production!)
   az sql server firewall-rule create \
     --server $SQL_SERVER \
     --resource-group $RESOURCE_GROUP \
     --name AllowAll \
     --start-ip-address 0.0.0.0 \
     --end-ip-address 255.255.255.255
   ```

6. **Create** the database:

   ```bash
   az sql db create \
     --name newsflash \
     --server $SQL_SERVER \
     --resource-group $RESOURCE_GROUP \
     --edition Basic \
     --capacity 5
   ```

7. **Build** the connection string and save it to `.database-url`:

   ```bash
   echo "mssql+pyodbc://sqladmin:${SQL_PASSWORD}@${SQL_SERVER}.database.windows.net/newsflash?driver=ODBC+Driver+18+for+SQL+Server" > .database-url
   chmod 600 .database-url
   ```

8. **Add** `.database-url` to your `.gitignore`:

   ```bash
   echo ".database-url" >> .gitignore
   ```

> ℹ **Concept Deep Dive**
>
> **Azure SQL Database** is a fully managed relational database. The Basic tier provides 5 DTUs (Database Transaction Units) — a blended measure of CPU, memory, and I/O. This is sufficient for a learning environment with light traffic.
>
> The connection string uses the `mssql+pyodbc://` scheme. SQLAlchemy reads this scheme to select the pyodbc driver, which connects via ODBC Driver 18 (installed in the Dockerfile from the previous exercise). The full chain is: SQLAlchemy → pyodbc → ODBC Driver 18 → Azure SQL Database.
>
> **Two firewall rules** are needed:
>
> - `AllowAzureServices` (0.0.0.0 to 0.0.0.0) lets Container Apps connect to the database — this is a special Azure-internal rule
> - `AllowAll` (0.0.0.0 to 255.255.255.255) allows connections from any IP, including your development machine — this is acceptable for a learning environment but should never be used in production
>
> The password includes `Aa1!` appended to the random string to guarantee Azure SQL's complexity requirements (uppercase, lowercase, number, special character).
>
> ⚠ **Common Mistakes**
>
> - Not saving the password — Azure does not store or display it after creation
> - Forgetting the `AllowAzureServices` firewall rule — Container Apps cannot connect without it
> - Using the wrong connection string format — `mssql+pyodbc://` is required, not `mssql://` or `sqlserver://`
> - Forgetting `chmod 600` on `.database-url` — the file contains a password and should not be world-readable
>
> ✓ **Quick check:** `az sql db show --name newsflash --server $SQL_SERVER --resource-group rg-news-flash` returns database details

### **Step 4:** Configure Environment Variables

The application needs three environment variables to run in production: `FLASK_ENV` to select the production configuration class, `SECRET_KEY` for session encryption, and `DATABASE_URL` to connect to Azure SQL. Setting these during provisioning means they persist across image updates — the CI/CD pipeline does not need to manage environment variables.

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ```

2. **Read** the database connection string:

   ```bash
   DATABASE_URL=$(cat .database-url)
   ```

3. **Generate** a secure secret key and save it for reuse:

   ```bash
   if [ -f .secret-key ]; then
     SECRET_KEY=$(cat .secret-key)
     echo "Reusing existing SECRET_KEY"
   else
     SECRET_KEY=$(openssl rand -hex 32)
     echo "$SECRET_KEY" > .secret-key
     chmod 600 .secret-key
     echo "Generated new SECRET_KEY (saved to .secret-key)"
   fi
   ```

   > **Why save the key?** If `SECRET_KEY` changes between deployments, all existing user sessions are invalidated. Saving it to a file ensures consistency across deployments. The `.secret-key` file should be in `.gitignore`.

4. **Add** `.secret-key` to your `.gitignore`:

   ```bash
   echo ".secret-key" >> .gitignore
   ```

5. **Set** the environment variables on the Container App:

   ```bash
   az containerapp update \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --set-env-vars \
       "FLASK_ENV=production" \
       "SECRET_KEY=$SECRET_KEY" \
       "DATABASE_URL=$DATABASE_URL"
   ```

6. **Verify** the environment variables are configured:

   ```bash
   az containerapp show \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --query "properties.template.containers[0].env[].name" \
     -o tsv
   ```

   You should see `FLASK_ENV`, `SECRET_KEY`, and `DATABASE_URL` in the output.

> ℹ **Concept Deep Dive**
>
> This step implements Factor III of the **12-Factor App** methodology: configuration is stored in the environment, not in code. The same Docker image runs in development (with `FLASK_ENV=development` and a SQLite `DATABASE_URL`) and in production (with `FLASK_ENV=production` and an Azure SQL `DATABASE_URL`). The image never changes — only the environment variables change.
>
> **Environment variables persist across image updates.** When the CI/CD pipeline runs `az containerapp update --image ...`, it changes the container image but the environment variables remain. This means you configure them once during provisioning, and every future deployment inherits the same configuration. The workflow does not need to know about `DATABASE_URL` or `SECRET_KEY`.
>
> `SECRET_KEY` is used by Flask to sign session cookies and CSRF tokens. It must be a strong random value in production. If it changes, all existing user sessions are invalidated (users must log in again).
>
> Container Apps stores environment variables as part of the container configuration. They are encrypted at rest and injected into the container at startup. When you update environment variables, Container Apps creates a new revision and restarts the container with the new values.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to set `FLASK_ENV=production` — the application defaults to development config with SQLite
> - Baking `DATABASE_URL` into the Docker image — this is a security risk and prevents environment portability
> - Using a weak or predictable `SECRET_KEY` in production — always use `openssl rand -hex 32` or equivalent
> - Setting env vars in the CI/CD workflow instead of during provisioning — they persist across image updates, so set them once
>
> ✓ **Quick check:** `az containerapp show` lists all three environment variable names

### **Step 5:** Verify Resources and Create Cleanup Script

Before moving on, verify that all resources are provisioned correctly and create a cleanup script for when you are done with the project. Azure resources cost money — even at the Basic tier, forgetting to delete resources adds up over time.

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ```

2. **List** all resources in the resource group:

   ```bash
   az resource list --resource-group $RESOURCE_GROUP -o table
   ```

   You should see the container registry, Container Apps Environment, Container App, SQL Server, and SQL Database.

3. **Create** a `deploy` directory and a cleanup script:

   ```bash
   mkdir -p deploy
   ```

   > `deploy/delete.sh`

   ```bash
   #!/bin/bash
   # Delete all Azure resources for the News Flash application
   set -e

   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

   if [ ! -f "$PROJECT_DIR/.azure-config" ]; then
     echo "ERROR: .azure-config not found. Nothing to delete."
     exit 1
   fi

   source "$PROJECT_DIR/.azure-config"

   echo "This will delete ALL resources in: $RESOURCE_GROUP"
   echo ""
   read -p "Are you sure? (y/N) " confirm

   if [[ "$confirm" == "y" ]]; then
     echo "Deleting resource group $RESOURCE_GROUP..."
     az group delete --name "$RESOURCE_GROUP" --yes --no-wait
     echo "Deletion started (runs in background)."
     rm -f "$PROJECT_DIR/.azure-config" "$PROJECT_DIR/.database-url" "$PROJECT_DIR/.secret-key"
     echo "Local config files removed."
   else
     echo "Cancelled."
   fi
   ```

4. **Make** the script executable:

   ```bash
   chmod +x deploy/delete.sh
   ```

5. **Verify** the final state of `.azure-config` contains all resource names:

   ```bash
   cat .azure-config
   ```

   It should contain:

   ```text
   RESOURCE_GROUP="rg-news-flash"
   ACR_NAME="acrnewsflash..."
   LOCATION="swedencentral"
   CAE_NAME="cae-news-flash"
   CA_NAME="ca-news-flash"
   SQL_SERVER="sql-news-flash-..."
   SQL_PASSWORD="..."
   ```

   > **Important:** `.azure-config` now contains the SQL password. Keep this file in `.gitignore` and never commit it. You can use the password to connect to the database directly via the Azure Portal Query editor or `sqlcmd` for troubleshooting.

> ℹ **Concept Deep Dive**
>
> The `--no-wait` flag on `az group delete` starts the deletion in the background and returns immediately. Resource group deletion can take several minutes because Azure must deprovision every resource inside it. The `--yes` flag skips Azure CLI's own confirmation prompt since the script already asks for confirmation.
>
> **Cost awareness** is essential when working with cloud resources. The resources created in this exercise cost approximately $15-20/month:
>
> - Container Registry (Basic): ~$5/month
> - Container Apps: ~$5-10/month (depends on usage)
> - Azure SQL (Basic): ~$5/month
>
> Always run `deploy/delete.sh` when you are done working for the day, or when you have completed the deployment exercises.
>
> ✓ **Quick check:** `.azure-config` contains all seven values (including `SQL_PASSWORD`), `deploy/delete.sh` exists and is executable

> ✓ **Success indicators:**
>
> - Resource group `rg-news-flash` exists in `swedencentral`
> - Container registry responds to `az acr show` commands
> - Container Apps Environment is provisioned
> - Container App created with nginx placeholder and ACR credentials registered
> - Azure SQL Database is accessible
> - Environment variables configured (`FLASK_ENV`, `SECRET_KEY`, `DATABASE_URL`)
> - `.azure-config` contains all resource names
> - `.database-url` contains the connection string
> - `deploy/delete.sh` exists and is executable
>
> ✓ **Final verification checklist:**
>
> - ☐ Resource group created in `swedencentral`
> - ☐ Container registry created with admin access enabled
> - ☐ Container Apps Environment provisioned
> - ☐ Container App created with nginx placeholder
> - ☐ ACR credentials registered on the Container App
> - ☐ Azure SQL Server and database created with firewall rules
> - ☐ Connection string saved to `.database-url`
> - ☐ Environment variables configured on Container App
> - ☐ All resource names saved to `.azure-config`
> - ☐ All config files added to `.gitignore` (`.azure-config`, `.database-url`, `.secret-key`)
> - ☐ Cleanup script created at `deploy/delete.sh`

## Common Issues

> **If you encounter problems:**
>
> **"The subscription is not registered to use namespace Microsoft.App":** Run `az provider register --namespace Microsoft.App` and wait a few minutes for registration to complete.
>
> **ACR name already taken:** The random suffix should prevent this, but if it happens, run the `ACR_NAME=...` command again to generate a new name.
>
> **Container App stuck in "Provisioning":** Wait a couple of minutes. If it does not resolve, check `az containerapp show --name ca-news-flash --resource-group rg-news-flash --query "properties.provisioningState"`.
>
> **SQL password rejected:** Azure SQL requires at least 8 characters with uppercase, lowercase, numbers, and special characters. The `Aa1!` suffix guarantees this.
>
> **"az containerapp: command not found":** Install the Container Apps extension with `az extension add --name containerapp --upgrade`.
>
> **Still stuck?** Run `az resource list --resource-group rg-news-flash -o table` to see which resources exist and which are missing.

## Summary

You've successfully provisioned the Azure infrastructure for the News Flash application:

- ✓ Created a resource group to organize all project resources
- ✓ Provisioned a private container registry for Docker images
- ✓ Set up a Container Apps Environment with an nginx placeholder
- ✓ Registered ACR credentials so the CI/CD pipeline can pull images
- ✓ Provisioned Azure SQL Database with firewall rules for connectivity
- ✓ Configured environment variables following the 12-Factor App methodology
- ✓ Created a cleanup script to manage costs

> **Key takeaway:** Infrastructure provisioning is a one-time setup. Environment variables and ACR credentials persist across image updates, so the CI/CD pipeline only needs to build and deploy — it does not manage configuration. Setting everything up during provisioning keeps the deployment workflow simple and the configuration consistent.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Research Azure Container Apps scaling rules and how `--min-replicas 0` saves costs
> - Explore Azure SQL firewall rules and virtual network service endpoints for production security
> - Investigate Azure Monitor and Log Analytics for container log analysis
> - Compare Container Apps with other Azure compute options (App Service, AKS, Container Instances)
> - Learn about Container Apps secrets for sensitive environment variables instead of plain `--set-env-vars`

## Done! 🎉

Your Azure infrastructure is ready. The resource group, container registry, Container Apps Environment, SQL database, and environment variables are all provisioned and configured. The CI/CD pipeline will handle deploying your application image in the next exercise.

## TL;DR — Single Provision Script

If you understand the concepts above and want to provision everything in one run, create this script:

```text
repo-root/
├── application/
├── infrastructure/
│   └── provision.sh
├── Dockerfile
```

> `infrastructure/provision.sh`

```bash
#!/bin/bash
# Provision all Azure infrastructure for the News Flash application
set -e

# ── Variables ────────────────────────────────────────────────────────
RESOURCE_GROUP="rg-news-flash"
LOCATION="swedencentral"
CAE_NAME="cae-news-flash"
CA_NAME="ca-news-flash"
SQL_ADMIN_USER="sqladmin"
DB_NAME="newsflash"

# Generated values (unique per run)
ACR_NAME="acrnewsflash$(openssl rand -hex 4)"
SQL_SERVER="sql-news-flash-$(openssl rand -hex 4)"
SQL_PASSWORD="$(openssl rand -base64 16)Aa1!"
SECRET_KEY=$(openssl rand -hex 32)

echo "=== News Flash — Azure Provisioning ==="
echo "ACR Name:   $ACR_NAME"
echo "SQL Server: $SQL_SERVER"
echo ""

# ── Resource Group ───────────────────────────────────────────────────
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# ── Container Registry ──────────────────────────────────────────────
echo "Creating container registry..."
az acr create \
  --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP \
  --sku Basic \
  --admin-enabled true

# ── Container Apps Environment ───────────────────────────────────────
echo "Creating Container Apps Environment (this takes a couple of minutes)..."
az containerapp env create \
  --name $CAE_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# ── Container App (nginx placeholder) ────────────────────────────────
echo "Creating Container App with nginx placeholder..."
az containerapp create \
  --name $CA_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $CAE_NAME \
  --image nginx:alpine \
  --target-port 80 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 1

# ── Register ACR Credentials on Container App ───────────────────────
echo "Registering ACR credentials..."
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)

az containerapp registry set \
  --name $CA_NAME \
  --resource-group $RESOURCE_GROUP \
  --server $ACR_LOGIN_SERVER \
  --username $ACR_USERNAME \
  --password $ACR_PASSWORD

# ── SQL Server ───────────────────────────────────────────────────────
echo "Creating SQL Server..."
az sql server create \
  --name $SQL_SERVER \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --admin-user $SQL_ADMIN_USER \
  --admin-password "$SQL_PASSWORD"

# ── SQL Server Firewall Rules ───────────────────────────────────────
echo "Configuring firewall rules..."
az sql server firewall-rule create \
  --server $SQL_SERVER \
  --resource-group $RESOURCE_GROUP \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

az sql server firewall-rule create \
  --server $SQL_SERVER \
  --resource-group $RESOURCE_GROUP \
  --name AllowAll \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255

# ── SQL Database ─────────────────────────────────────────────────────
echo "Creating SQL Database..."
az sql db create \
  --name $DB_NAME \
  --server $SQL_SERVER \
  --resource-group $RESOURCE_GROUP \
  --edition Basic \
  --capacity 5

# ── Connection String ────────────────────────────────────────────────
DATABASE_URL="mssql+pyodbc://${SQL_ADMIN_USER}:${SQL_PASSWORD}@${SQL_SERVER}.database.windows.net/${DB_NAME}?driver=ODBC+Driver+18+for+SQL+Server"

# ── Secret Key ───────────────────────────────────────────────────────
echo "Generated SECRET_KEY for Flask session encryption."

# ── Set Environment Variables on Container App ──────────────────────
echo "Configuring environment variables..."
az containerapp update \
  --name $CA_NAME \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars \
    "FLASK_ENV=production" \
    "SECRET_KEY=$SECRET_KEY" \
    "DATABASE_URL=$DATABASE_URL"

# ── Save Configuration ──────────────────────────────────────────────
cat > .azure-config << EOF
RESOURCE_GROUP="$RESOURCE_GROUP"
ACR_NAME="$ACR_NAME"
LOCATION="$LOCATION"
CAE_NAME="$CAE_NAME"
CA_NAME="$CA_NAME"
SQL_SERVER="$SQL_SERVER"
SQL_PASSWORD="$SQL_PASSWORD"
EOF

echo "$DATABASE_URL" > .database-url
chmod 600 .database-url

echo "$SECRET_KEY" > .secret-key
chmod 600 .secret-key

# ── Git Ignore ───────────────────────────────────────────────────────
echo "Updating .gitignore..."
for entry in .azure-config .database-url .secret-key; do
  grep -qxF "$entry" .gitignore 2>/dev/null || echo "$entry" >> .gitignore
done

# ── Summary ──────────────────────────────────────────────────────────
echo ""
echo "=== Provisioning Complete ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "ACR Name:       $ACR_NAME"
echo "ACR Login:      $ACR_LOGIN_SERVER"
echo "Container App:  $CA_NAME"
echo "SQL Server:     $SQL_SERVER.database.windows.net"
echo "Database:       $DB_NAME"
echo ""
echo "Config saved to: .azure-config, .database-url, .secret-key"
echo "Added to .gitignore: .azure-config .database-url .secret-key"
```

Make the script executable and run it:

```bash
mkdir -p infrastructure
chmod +x infrastructure/provision.sh
./infrastructure/provision.sh
```

The script runs all commands from Steps 1–4 in sequence. Each `az` command blocks until the operation completes, so no `sleep` or polling is needed. All generated values (ACR name, SQL server name, password, secret key) are saved to `.azure-config` at the end for use by the delete script and CI/CD pipeline.
