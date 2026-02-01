+++
title = "Build and Deploy Application"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Build the News Flash Docker image, push to Azure Container Registry, deploy to Container Apps, and configure environment variables"
weight = 3
+++

# Build and Deploy Application

## Goal

Build the News Flash Docker image, push it to Azure Container Registry, deploy it as a Container App replacing the nginx verification container, configure environment variables for production, and run database migrations.

> **What you'll learn:**
>
> - How to build and push Docker images to a private registry
> - How to update a Container App with a new image from ACR
> - How to inject configuration via environment variables (12-Factor App)
> - Best practices for running database migrations in containers

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Azure infrastructure provisioned (resource group, ACR, Container Apps Environment, Azure SQL)
> - ✓ nginx container deployed and accessible via HTTPS
> - ✓ `.azure-config` file with all resource names
> - ✓ `.database-url` file with the Azure SQL connection string
> - ✓ Docker running on your development machine

## Exercise Steps

### Overview

1. **Build and Push Docker Image to ACR**
2. **Update Container App with News Flash Image**
3. **Configure Environment Variables**
4. **Run Database Migrations**
5. **Create Deployment Script**

### **Step 1:** Build and Push Docker Image to ACR

The Dockerfile created in the container-ready exercise packages the application into a container image. Now you need to build that image, tag it with the ACR registry address, and push it to your private registry. Once the image is in ACR, Container Apps can pull and run it.

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ```

2. **Get** the ACR login server address:

   ```bash
   ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
   echo "ACR Login Server: $ACR_LOGIN_SERVER"
   ```

3. **Authenticate** Docker with your container registry:

   ```bash
   az acr login --name $ACR_NAME
   ```

4. **Build** the Docker image with the ACR tag:

   ```bash
   docker build --tag $ACR_LOGIN_SERVER/news-flash:latest .
   ```

5. **Push** the image to ACR:

   ```bash
   docker push $ACR_LOGIN_SERVER/news-flash:latest
   ```

6. **Verify** the image appears in the registry:

   ```bash
   az acr repository list --name $ACR_NAME -o table
   ```

   You should see `news-flash` in the output.

> ℹ **Concept Deep Dive**
>
> The `az acr login` command configures Docker's credential helper to authenticate with your private registry. Without this step, `docker push` would be rejected with an authentication error.
>
> The image tag format is `<registry>.azurecr.io/<repository>:<tag>`. The registry address tells Docker where to push the image. The repository name (`news-flash`) is the logical name for your application. The tag (`:latest`) identifies a specific version — here it means "most recent build."
>
> The build happens locally on your machine using the Dockerfile in the project root. Docker reads the Dockerfile, executes each instruction (install ODBC driver, copy requirements, install dependencies, copy application code), and produces a container image. The push uploads this image to ACR where Container Apps can access it.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `az acr login` before pushing — Docker cannot authenticate with ACR without it
> - Building without the ACR prefix — `docker build -t news-flash .` creates a local-only image that cannot be pushed
> - Running `docker push` before the build completes — the tagged image must exist locally first
>
> ✓ **Quick check:** `az acr repository list --name $ACR_NAME` shows `news-flash`

### **Step 2:** Update Container App with News Flash Image

The Container App currently runs nginx. Now you will update it to pull and run your Flask application image from ACR. This requires providing ACR credentials so Container Apps can authenticate with your private registry.

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
   ```

2. **Get** the ACR admin credentials:

   ```bash
   ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
   ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)
   ```

3. **Update** the Container App to use the News Flash image:

   ```bash
   az containerapp update \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --image $ACR_LOGIN_SERVER/news-flash:latest \
     --registry-server $ACR_LOGIN_SERVER \
     --registry-username $ACR_USERNAME \
     --registry-password $ACR_PASSWORD \
     --target-port 5000
   ```

4. **Get** the application URL:

   ```bash
   az containerapp show \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --query "properties.configuration.ingress.fqdn" \
     -o tsv
   ```

5. **Open** the URL in your browser — you will likely see an error page. This is expected because the database connection is not configured yet.

> ℹ **Concept Deep Dive**
>
> The `az containerapp update` command replaces the running container image. Container Apps pulls the new image from ACR using the provided credentials, stops the old container (nginx), and starts a new container with the Flask application.
>
> The `--target-port 5000` flag tells Container Apps which port the application listens on. This must match the Gunicorn `--bind` port in the Dockerfile (`0.0.0.0:5000`). Container Apps routes incoming HTTPS traffic from port 443 to this internal port.
>
> The `--registry-server`, `--registry-username`, and `--registry-password` flags configure ACR authentication. Container Apps stores these credentials and uses them whenever it needs to pull the image — including during restarts and scaling events.
>
> ⚠ **Common Mistakes**
>
> - Using `--target-port 80` (the nginx port) instead of `--target-port 5000` — Flask/Gunicorn listens on 5000
> - Forgetting the registry credentials — Container Apps cannot pull from a private registry without authentication
> - Panicking at the error page — the application needs environment variables before it can connect to the database
>
> ✓ **Quick check:** `az containerapp show --name $CA_NAME --resource-group $RESOURCE_GROUP --query "properties.template.containers[0].image"` shows your ACR image

### **Step 3:** Configure Environment Variables

The application needs three environment variables to run in production: `FLASK_ENV` to select the production configuration class, `SECRET_KEY` for session encryption, and `DATABASE_URL` to connect to Azure SQL. These values are injected at runtime — they are never baked into the Docker image.

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ```

2. **Read** the database connection string:

   ```bash
   DATABASE_URL=$(cat .database-url)
   ```

3. **Generate** a secure secret key:

   ```bash
   SECRET_KEY=$(openssl rand -hex 32)
   ```

4. **Set** the environment variables on the Container App:

   ```bash
   az containerapp update \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --set-env-vars \
       "FLASK_ENV=production" \
       "SECRET_KEY=$SECRET_KEY" \
       "DATABASE_URL=$DATABASE_URL"
   ```

5. **Wait** for the container to restart (Container Apps automatically restarts when environment variables change), then **refresh** the application URL in your browser. The landing page should now load without errors.

> ℹ **Concept Deep Dive**
>
> This step implements Factor III of the 12-Factor App methodology: configuration is stored in the environment, not in code. The same Docker image runs in development (with `FLASK_ENV=development` and a SQLite `DATABASE_URL`) and in production (with `FLASK_ENV=production` and an Azure SQL `DATABASE_URL`). The image never changes — only the environment variables change.
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
> - Not waiting for the restart — the old container may still be running for a few seconds after the update
>
> ✓ **Quick check:** The application landing page loads without database errors

### **Step 4:** Run Database Migrations

The application code is running and connected to Azure SQL, but the database has no tables yet. Flask-Migrate (Alembic) manages the database schema — the `flask db upgrade` command reads the migration files and creates all necessary tables.

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ```

2. **Run** the database migration inside the running container:

   ```bash
   az containerapp exec \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --command "flask" -- db upgrade
   ```

   You should see output indicating that migrations are being applied.

3. **Test** the application end-to-end by visiting the application URL:

   - **Visit** the landing page — it should load without errors
   - **Navigate** to the subscribe page
   - **Submit** a test subscription with your name and email
   - **Verify** the thank you page appears

4. **Confirm** data persisted by checking the subscription count or revisiting the admin page (if available)

> ℹ **Concept Deep Dive**
>
> `az containerapp exec` opens a shell session inside the running container, similar to `docker exec`. The `--command "flask" -- db upgrade` runs the Flask CLI command `flask db upgrade` which applies all pending Alembic migrations.
>
> Migrations must run after the `DATABASE_URL` environment variable is configured, because `flask db upgrade` needs to connect to the database. The migration files in the `migrations/` directory define the schema changes — Alembic compares the current database state to the desired state and applies only the missing changes.
>
> In a production pipeline, migrations typically run as a one-time step after each deployment. If a migration fails, the database transaction is rolled back automatically, leaving the database in its previous state.
>
> ⚠ **Common Mistakes**
>
> - Running migrations before setting `DATABASE_URL` — the command fails because it cannot connect to the database
> - Forgetting the `--` separator before `db upgrade` — the CLI parser may misinterpret the arguments
> - Not testing the application after migration — always verify that the schema changes work correctly
>
> ✓ **Quick check:** The subscribe form works end-to-end (submit → thank you page)

### **Step 5:** Create Deployment Script

Manually running four steps every time you deploy is error-prone. A deployment script automates the entire process: build, push, update, configure, and migrate. This ensures consistent deployments and serves as documentation for how the application is deployed.

1. **Create** the deployment script:

   > `deploy/deploy.sh`

   ```bash
   #!/bin/bash
   # Deploy News Flash application to Azure Container Apps
   set -euo pipefail

   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

   # Load configuration
   if [ ! -f "$PROJECT_DIR/.azure-config" ]; then
     echo "ERROR: .azure-config not found. Provision infrastructure first."
     exit 1
   fi
   source "$PROJECT_DIR/.azure-config"

   if [ ! -f "$PROJECT_DIR/.database-url" ]; then
     echo "ERROR: .database-url not found. Provision database first."
     exit 1
   fi
   DATABASE_URL=$(cat "$PROJECT_DIR/.database-url")

   echo "=== Deploying News Flash to Azure Container Apps ==="
   echo ""
   echo "  Resource Group: $RESOURCE_GROUP"
   echo "  Container App:  $CA_NAME"
   echo "  ACR:            $ACR_NAME"
   echo ""

   # Step 1: Build and push
   ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
   echo "Logging in to ACR..."
   az acr login --name "$ACR_NAME"

   echo "Building Docker image..."
   docker build --tag "$ACR_LOGIN_SERVER/news-flash:latest" "$PROJECT_DIR"

   echo "Pushing image to ACR..."
   docker push "$ACR_LOGIN_SERVER/news-flash:latest"

   # Step 2: Update Container App
   ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
   ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)

   echo "Updating Container App..."
   az containerapp update \
     --name "$CA_NAME" \
     --resource-group "$RESOURCE_GROUP" \
     --image "$ACR_LOGIN_SERVER/news-flash:latest" \
     --registry-server "$ACR_LOGIN_SERVER" \
     --registry-username "$ACR_USERNAME" \
     --registry-password "$ACR_PASSWORD" \
     --target-port 5000 \
     --output none

   # Step 3: Configure environment variables
   SECRET_KEY=$(openssl rand -hex 32)

   az containerapp update \
     --name "$CA_NAME" \
     --resource-group "$RESOURCE_GROUP" \
     --set-env-vars \
       "FLASK_ENV=production" \
       "SECRET_KEY=$SECRET_KEY" \
       "DATABASE_URL=$DATABASE_URL" \
     --output none

   # Step 4: Run migrations
   echo "Waiting for container to start..."
   sleep 15

   echo "Running database migrations..."
   az containerapp exec \
     --name "$CA_NAME" \
     --resource-group "$RESOURCE_GROUP" \
     --command "flask" -- db upgrade

   # Get application URL
   APP_FQDN=$(az containerapp show \
     --name "$CA_NAME" \
     --resource-group "$RESOURCE_GROUP" \
     --query "properties.configuration.ingress.fqdn" \
     -o tsv)

   echo ""
   echo "=== Deployment Complete ==="
   echo ""
   echo "Application URL: https://$APP_FQDN"
   echo ""
   ```

2. **Make** the script executable:

   ```bash
   chmod +x deploy/deploy.sh
   ```

3. **Test** the deployment script by running it:

   ```bash
   ./deploy/deploy.sh
   ```

4. **Verify** the application works by visiting the URL printed at the end of the script output

> ℹ **Concept Deep Dive**
>
> The `set -euo pipefail` flags make the script fail fast on errors:
>
> - `-e` exits immediately if any command fails
> - `-u` treats unset variables as errors (catches typos)
> - `-o pipefail` ensures piped commands propagate failures
>
> The script uses `$PROJECT_DIR` to resolve paths relative to the project root, regardless of where you run the script from. This is a common pattern in deployment scripts.
>
> The `sleep 15` before running migrations gives the new container time to start. In a production environment, you would use a readiness probe instead, but for a learning environment a fixed delay is sufficient.
>
> The `--output none` flag on `az containerapp update` suppresses the verbose JSON output, keeping the deployment log readable.
>
> ⚠ **Common Mistakes**
>
> - Running the script from the wrong directory — the `SCRIPT_DIR` calculation handles this, but `.azure-config` must be in the project root
> - Not making the script executable — `chmod +x` is required before running with `./deploy/deploy.sh`
> - The `sleep 15` may not be long enough on a cold start — if migrations fail, increase the delay and try again
>
> ✓ **Quick check:** `./deploy/deploy.sh` completes without errors and prints the application URL

> ✓ **Success indicators:**
>
> - Docker image built and pushed to ACR
> - Container App running the News Flash image (not nginx)
> - Landing page loads without errors
> - Subscribe form works end-to-end (submit → thank you page)
> - Deployment script automates the full process
>
> ✓ **Final verification checklist:**
>
> - ☐ Docker image appears in ACR repository list
> - ☐ Container App shows the Flask application image (not `nginx:alpine`)
> - ☐ Environment variables set: `FLASK_ENV`, `SECRET_KEY`, `DATABASE_URL`
> - ☐ Database migrations applied successfully
> - ☐ Subscribe form submits and shows thank you page
> - ☐ `deploy/deploy.sh` created and executable
> - ☐ Running `deploy/deploy.sh` deploys the application end-to-end

## Common Issues

> **If you encounter problems:**
>
> **"unauthorized: authentication required" on docker push:** Run `az acr login --name $ACR_NAME` to re-authenticate. ACR login tokens expire after a few hours.
>
> **Container App shows "Revision failed":** Check the container logs with `az containerapp logs show --name ca-news-flash --resource-group rg-news-flash --follow`. Common causes are missing environment variables or incorrect port configuration.
>
> **"Connection refused" or database errors after deploy:** Ensure `DATABASE_URL` is set correctly. Run `az containerapp show --name ca-news-flash --resource-group rg-news-flash --query "properties.template.containers[0].env"` to verify environment variables.
>
> **Migration fails with "could not connect to server":** The Azure SQL firewall may not include the Container Apps outbound IP. Verify the `AllowAzureServices` firewall rule exists on the SQL Server.
>
> **`az containerapp exec` hangs or times out:** The container may still be starting. Wait a minute and try again. If it persists, check that the container is running with `az containerapp show --name ca-news-flash --resource-group rg-news-flash --query "properties.runningStatus"`.
>
> **Still stuck?** Run `az containerapp logs show --name ca-news-flash --resource-group rg-news-flash` to see the application's stdout and stderr output.

## Summary

You've successfully deployed the News Flash application to Azure Container Apps:

- ✓ Built and pushed the Docker image to Azure Container Registry
- ✓ Updated the Container App from nginx to the Flask application
- ✓ Configured environment variables following the 12-Factor App methodology
- ✓ Ran database migrations inside the running container
- ✓ Created a deployment script to automate the entire process

> **Key takeaway:** Deployment is a sequence of well-defined steps: build, push, update, configure, migrate. Automating these steps in a script ensures consistency and prevents human error. The 12-Factor App principle of environment-driven configuration means the same Docker image works in every environment — only the environment variables change.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add a health check endpoint (`/api/health`) and configure Container Apps to use it as a readiness probe
> - Research blue-green deployments with Container Apps revisions
> - Explore Azure Container Registry tasks for building images in the cloud (no local Docker needed)
> - Investigate Container Apps secrets for sensitive environment variables instead of plain `--set-env-vars`

## Done! 🎉

Your News Flash application is live on Azure. The deployment script makes future deployments repeatable — change your code, run the script, and the updated application is live within minutes.
