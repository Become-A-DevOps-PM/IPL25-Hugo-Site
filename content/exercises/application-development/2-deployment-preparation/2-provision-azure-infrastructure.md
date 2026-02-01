+++
title = "Provision Azure Infrastructure"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Create Azure resource group, container registry, Container Apps environment, and SQL database for the News Flash application"
weight = 2
+++

# Provision Azure Infrastructure

## Goal

Create the Azure infrastructure needed to host the News Flash application: a resource group, container registry, Container Apps environment, and Azure SQL database. Verify everything works by deploying an nginx container before introducing application complexity.

> **What you'll learn:**
>
> - How to provision Azure resources using the Azure CLI
> - When to use Container Apps vs other Azure compute services
> - How Azure Container Registry stores private Docker images
> - Best practices for verifying infrastructure before deploying application code

## Prerequisites

> **Before starting, ensure you have:**
>
> - Container-ready application with Dockerfile, wsgi.py, and production config
> - Azure CLI installed and authenticated (`az login`)
> - Docker installed on your development machine
> - An active Azure subscription

## Exercise Steps

### Overview

1. **Create Resource Group and Container Registry**
2. **Create Container Apps Environment**
3. **Deploy nginx to Verify Infrastructure**
4. **Provision Azure SQL Database**
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

> **Concept Deep Dive**
>
> A **resource group** is Azure's organizational unit. It is not a billing boundary or a security boundary — it is a logical grouping. When you delete a resource group, Azure deletes every resource inside it. This makes cleanup straightforward: one command removes everything.
>
> **Azure Container Registry (ACR)** is a private Docker registry hosted in Azure. The `--admin-enabled true` flag enables simple username/password authentication, which Container Apps uses to pull images. The Basic SKU costs approximately $5/month and provides 10 GB of storage — more than enough for a student project.
>
> ACR names cannot contain hyphens and must be globally unique because the registry URL becomes `<name>.azurecr.io`. The random suffix ensures uniqueness.
>
> **Common Mistakes**
>
> - Using hyphens in the ACR name — only lowercase letters and numbers are allowed
> - Forgetting `--admin-enabled true` — Container Apps needs credentials to pull images
> - Not saving the ACR name — you will need it in every subsequent step
>
> **Quick check:** `az acr show --name $ACR_NAME --resource-group rg-news-flash` returns registry details without errors

### **Step 2:** Create Container Apps Environment

The Container Apps Environment is the hosting platform where your containers run. It provides shared networking, logging (via Log Analytics), and managed infrastructure. Think of it as the "server room" that Azure manages for you — you deploy containers into it without worrying about VMs, operating systems, or patching.

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

3. **Append** the environment and app names to your configuration file:

   ```bash
   cat >> .azure-config << EOF
   CAE_NAME="cae-news-flash"
   CA_NAME="ca-news-flash"
   EOF
   ```

> **Concept Deep Dive**
>
> A **Container Apps Environment** is a shared boundary for one or more Container Apps. It provides:
>
> - **Networking isolation** — apps in the same environment can communicate internally
> - **Log Analytics integration** — all container logs are collected automatically
> - **Managed infrastructure** — Azure handles scaling, load balancing, and TLS certificates
>
> You can run multiple Container Apps in the same environment. They share the networking and logging infrastructure but run as independent containers with separate scaling rules.
>
> **Common Mistakes**
>
> - Creating the environment in a different location than the resource group — keep everything in `swedencentral`
> - Not waiting for the command to complete — it provisions infrastructure and takes a couple of minutes
>
> **Quick check:** `az containerapp env show --name cae-news-flash --resource-group rg-news-flash` returns environment details

### **Step 3:** Deploy nginx to Verify Infrastructure

Before deploying your application, verify that the infrastructure works by deploying a simple nginx container. This proves that the Container Apps Environment, networking, and ingress are all configured correctly. If nginx works, you know the infrastructure is solid and any future issues are application-specific.

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ```

2. **Create** a Container App running nginx:

   ```bash
   az containerapp create \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --environment $CAE_NAME \
     --image nginx:alpine \
     --target-port 80 \
     --ingress external \
     --min-replicas 1 \
     --max-replicas 1
   ```

3. **Get** the application URL:

   ```bash
   az containerapp show \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --query "properties.configuration.ingress.fqdn" \
     -o tsv
   ```

4. **Open** `https://<fqdn>` in your browser — you should see the "Welcome to nginx!" page

> **Concept Deep Dive**
>
> **External ingress** exposes the Container App to the internet via Azure's managed HTTPS endpoint. Azure automatically provisions a TLS certificate and terminates HTTPS at the edge — you do not need to configure SSL certificates, nginx reverse proxy, or load balancers. The URL follows the pattern `<app-name>.<random-hash>.<region>.azurecontainerapps.io`.
>
> The `--min-replicas 1 --max-replicas 1` flags ensure exactly one container instance runs at all times. Container Apps can scale to zero by default (saving costs when idle), but for verification you want the container always available.
>
> This "deploy nginx first" strategy is a common infrastructure verification pattern. It isolates infrastructure problems from application problems — if nginx does not work, the issue is with Azure configuration, not your code.
>
> **Common Mistakes**
>
> - Forgetting `--ingress external` — without it, the Container App has no public URL
> - Using `http://` instead of `https://` — Container Apps only serves HTTPS
> - Not seeing the nginx page — wait a minute for the container to start, then refresh
>
> **Quick check:** Browser shows "Welcome to nginx!" at the HTTPS URL

### **Step 4:** Provision Azure SQL Database

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

   Save both values — you will need the password later and cannot retrieve it from Azure.

3. **Create** the SQL Server:

   ```bash
   az sql server create \
     --name $SQL_SERVER \
     --resource-group $RESOURCE_GROUP \
     --location $LOCATION \
     --admin-user sqladmin \
     --admin-password "$SQL_PASSWORD"
   ```

4. **Configure** firewall rules to allow connections:

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

5. **Create** the database:

   ```bash
   az sql db create \
     --name newsflash \
     --server $SQL_SERVER \
     --resource-group $RESOURCE_GROUP \
     --edition Basic \
     --capacity 5
   ```

6. **Build** the connection string and save it to `.database-url`:

   ```bash
   echo "mssql+pyodbc://sqladmin:${SQL_PASSWORD}@${SQL_SERVER}.database.windows.net/newsflash?driver=ODBC+Driver+18+for+SQL+Server" > .database-url
   chmod 600 .database-url
   ```

7. **Add** `.database-url` to your `.gitignore`:

   ```bash
   echo ".database-url" >> .gitignore
   ```

> **Concept Deep Dive**
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
> **Common Mistakes**
>
> - Not saving the password — Azure does not store or display it after creation
> - Forgetting the `AllowAzureServices` firewall rule — Container Apps cannot connect without it
> - Using the wrong connection string format — `mssql+pyodbc://` is required, not `mssql://` or `sqlserver://`
> - Forgetting `chmod 600` on `.database-url` — the file contains a password and should not be world-readable
>
> **Quick check:** `az sql db show --name newsflash --server $SQL_SERVER --resource-group rg-news-flash` returns database details

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

3. **Append** the SQL Server name to your configuration file:

   ```bash
   echo "SQL_SERVER=\"$SQL_SERVER\"" >> .azure-config
   ```

4. **Create** a `deploy` directory and a cleanup script:

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
     rm -f "$PROJECT_DIR/.azure-config" "$PROJECT_DIR/.database-url"
     echo "Local config files removed."
   else
     echo "Cancelled."
   fi
   ```

5. **Make** the script executable:

   ```bash
   chmod +x deploy/delete.sh
   ```

6. **Verify** the final state of `.azure-config` contains all resource names:

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
   ```

> **Concept Deep Dive**
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
> **Quick check:** `.azure-config` contains all six values, `deploy/delete.sh` exists and is executable

> **Success indicators:**
>
> - Resource group `rg-news-flash` exists in `swedencentral`
> - Container registry responds to `az acr show` commands
> - Container Apps Environment is provisioned
> - nginx Container App shows "Welcome to nginx!" in browser
> - Azure SQL Database is accessible
> - `.azure-config` contains all resource names
> - `.database-url` contains the connection string
> - `deploy/delete.sh` exists and is executable
>
> **Final verification checklist:**
>
> - [ ] Resource group created in `swedencentral`
> - [ ] Container registry created with admin access enabled
> - [ ] Container Apps Environment provisioned
> - [ ] nginx container deployed and accessible via HTTPS
> - [ ] Azure SQL Server and database created with firewall rules
> - [ ] Connection string saved to `.database-url`
> - [ ] All resource names saved to `.azure-config`
> - [ ] Both config files added to `.gitignore`
> - [ ] Cleanup script created at `deploy/delete.sh`

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

- Created a resource group to organize all project resources
- Provisioned a private container registry for Docker images
- Set up a Container Apps Environment as the hosting platform
- Verified infrastructure by deploying an nginx container
- Provisioned Azure SQL Database with firewall rules for connectivity
- Created a cleanup script to manage costs

> **Key takeaway:** Always verify infrastructure with a simple deployment (like nginx) before introducing application complexity. This isolates infrastructure issues from application issues and saves significant debugging time. When nginx works, you know the network, ingress, and Container Apps Environment are correctly configured.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Research Azure Container Apps scaling rules and how `--min-replicas 0` saves costs
> - Explore Azure SQL firewall rules and virtual network service endpoints for production security
> - Investigate Azure Monitor and Log Analytics for container log analysis
> - Compare Container Apps with other Azure compute options (App Service, AKS, Container Instances)

## Done!

Your Azure infrastructure is ready. The resource group, container registry, Container Apps Environment, and SQL database are all provisioned and verified. The nginx container proves everything works — now it is time to deploy the actual application.
