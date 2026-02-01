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

The Dockerfile created in the container-ready exercise packages the application into a container image. Azure Container Registry can build images directly in the cloud using `az acr build` — this eliminates local Docker authentication and avoids CPU architecture mismatches (e.g., building on an Apple Silicon Mac produces ARM images, but Container Apps requires AMD64).

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ```

2. **Build** the image on Azure and push it to ACR in one command:

   ```bash
   az acr build --registry $ACR_NAME --image news-flash:latest .
   ```

   This uploads your source code to Azure, builds the Docker image on an AMD64 build server, and stores it in your registry — all in one step.

3. **Verify** the image appears in the registry:

   ```bash
   az acr repository list --name $ACR_NAME -o table
   ```

   You should see `news-flash` in the output.

> ℹ **Concept Deep Dive**
>
> `az acr build` is an **ACR Task** that builds Docker images in the cloud. Instead of building locally and pushing separately, ACR Tasks upload your source code (respecting `.dockerignore`), build the image on Azure's infrastructure, and store the result directly in the registry.
>
> This approach has three advantages over local `docker build` + `docker push`:
>
> - **No architecture mismatch** — ACR builds on AMD64 (linux/amd64), which is what Container Apps expects. Building locally on an Apple Silicon Mac produces ARM images that crash on Azure.
> - **No local authentication needed** — you do not need `az acr login` or Docker credential helpers. The Azure CLI authenticates directly.
> - **Consistent builds** — every team member gets the same build environment regardless of their local operating system.
>
> The image tag format is `<repository>:<tag>`. The registry address is inferred from the `--registry` flag. The repository name (`news-flash`) is the logical name for your application. The tag (`:latest`) identifies a specific version.
>
> ⚠ **Common Mistakes**
>
> - Using `docker build` locally on Apple Silicon Macs — produces ARM images that fail on Azure (AMD64)
> - Forgetting the `.` at the end — this specifies the build context (current directory)
> - Including large files that should be in `.dockerignore` — everything not excluded gets uploaded to Azure
>
> ✓ **Quick check:** `az acr repository list --name $ACR_NAME` shows `news-flash`

### **Step 2:** Update Container App with News Flash Image

The Container App currently runs nginx. Now you will update it to pull and run your Flask application image from ACR. This requires two steps: first register ACR credentials so Container Apps can authenticate with your private registry, then update the container image.

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

3. **Register** the ACR credentials on the Container App:

   ```bash
   az containerapp registry set \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --server $ACR_LOGIN_SERVER \
     --username $ACR_USERNAME \
     --password $ACR_PASSWORD
   ```

4. **Update** the Container App to use the News Flash image:

   ```bash
   az containerapp update \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --image $ACR_LOGIN_SERVER/news-flash:latest
   ```

5. **Update** the ingress target port from 80 (nginx) to 5000 (Flask/Gunicorn):

   ```bash
   az containerapp ingress update \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --target-port 5000
   ```

6. **Get** the application URL:

   ```bash
   az containerapp show \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --query "properties.configuration.ingress.fqdn" \
     -o tsv
   ```

7. **Open** the URL in your browser — you will likely see an error page. This is expected because the database connection is not configured yet.

> ℹ **Concept Deep Dive**
>
> Updating a Container App from one image to another requires two separate configurations:
>
> - **Registry credentials** (`az containerapp registry set`) tell Container Apps how to authenticate with your private ACR. These credentials are stored once and reused for all future image pulls — including during restarts and scaling events.
> - **Image update** (`az containerapp update`) tells Container Apps which image to run. Container Apps pulls the new image from ACR, stops the old container (nginx), and starts a new container with the Flask application.
>
> The **target port** must be updated separately because the ingress configuration is distinct from the container configuration. The original nginx container used port 80, but Flask/Gunicorn listens on port 5000. Container Apps routes incoming HTTPS traffic from port 443 to this internal port.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to update the target port from 80 to 5000 — the app runs but is unreachable
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

### **Step 4:** Verify Database Migrations

The `entrypoint.sh` created in the container-ready exercise runs `flask db upgrade` automatically every time the container starts. This means migrations run when you first deploy, and again whenever you deploy a new version with schema changes. You do not need to run migrations manually.

1. **Check** the container logs to verify migrations ran at startup:

   ```bash
   source .azure-config
   az containerapp logs show \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --tail 15
   ```

   You should see output like:

   ```text
   Running database migrations...
   INFO  [alembic.runtime.migration] Context impl MSSQLImpl.
   INFO  [alembic.runtime.migration] Will assume transactional DDL.
   INFO  [alembic.runtime.migration] Running upgrade  -> 679fad3d6210, Add subscribers table
   INFO  [alembic.runtime.migration] Running upgrade 679fad3d6210 -> 56de8aa8fc6c, Add user model
   Starting application...
   [INFO] Starting gunicorn 22.0.0
   ```

2. **Create** an admin user so you can access the admin panel. The `create-admin` CLI command runs inside the container via `az containerapp exec`:

   ```bash
   az containerapp exec \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --command "flask create-admin admin -p Admin1234"
   ```

   You should see: `Admin user 'admin' created successfully.`

   > **Note:** `az containerapp exec` requires an interactive terminal. If you get a TTY error, try wrapping the command with `script -q /dev/null bash -c '...'`.

3. **Test** the application end-to-end by visiting the application URL:

   - **Visit** the landing page — it should load without errors
   - **Navigate** to the subscribe page
   - **Submit** a test subscription with your name and email
   - **Verify** the thank you page appears

4. **Log in** to the admin panel to verify the admin user works:

   - **Navigate** to `/login` on the application URL
   - **Enter** username `admin` and password `Admin1234`
   - **Verify** the admin subscribers page loads and shows your test subscription

5. **Confirm** data persisted by checking the subscriber list in the admin panel

> ℹ **Concept Deep Dive**
>
> Running migrations at container startup (via `entrypoint.sh`) is the standard pattern for containerized applications. The alternative — running `az containerapp exec` to execute commands inside a running container — requires an interactive terminal and fails in CI/CD pipelines like GitHub Actions.
>
> The `entrypoint.sh` pattern is reliable because:
>
> - **Automatic** — migrations run on every deployment without manual intervention
> - **Idempotent** — Alembic tracks which migrations have already been applied and skips them
> - **Fail-safe** — if migrations fail, the container does not start (thanks to `set -e`), preventing the application from running against an outdated schema
>
> Alembic compares the current database state to the desired state and applies only the missing changes. If the database is already up to date, `flask db upgrade` completes instantly with no changes.
>
> ⚠ **Common Mistakes**
>
> - Excluding `migrations/` from `.dockerignore` — the container needs migration scripts to run `flask db upgrade`
> - Not checking logs after first deploy — always verify that migrations ran successfully
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

   # Step 1: Build on Azure (avoids ARM/AMD64 mismatch on Apple Silicon)
   ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)

   echo "Building image on Azure Container Registry..."
   az acr build --registry "$ACR_NAME" --image news-flash:latest "$PROJECT_DIR"

   # Step 2: Update Container App
   ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
   ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)

   # Step 3: Reuse or generate SECRET_KEY
   SECRET_KEY_FILE="$PROJECT_DIR/.secret-key"
   if [ -f "$SECRET_KEY_FILE" ]; then
     SECRET_KEY=$(cat "$SECRET_KEY_FILE")
     echo "Reusing existing SECRET_KEY from .secret-key"
   else
     SECRET_KEY=$(openssl rand -hex 32)
     echo "$SECRET_KEY" > "$SECRET_KEY_FILE"
     chmod 600 "$SECRET_KEY_FILE"
     echo "Generated new SECRET_KEY (saved to .secret-key)"
   fi

   echo "Updating Container App..."
   az containerapp update \
     --name "$CA_NAME" \
     --resource-group "$RESOURCE_GROUP" \
     --image "$ACR_LOGIN_SERVER/news-flash:latest" \
     --set-env-vars \
       "FLASK_ENV=production" \
       "SECRET_KEY=$SECRET_KEY" \
       "DATABASE_URL=$DATABASE_URL" \
     --output none

   # Migrations run automatically at container startup via entrypoint.sh

   # Wait for new revision to become ready
   echo "Waiting for deployment to complete..."
   sleep 15

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
> The `SECRET_KEY` is saved to `.secret-key` on the first run and reused on subsequent deployments. This prevents invalidating user sessions every time you deploy. The `.secret-key` file should be in `.gitignore` alongside `.azure-config` and `.database-url`.
>
> The `sleep 15` gives the new container time to start and run migrations (via `entrypoint.sh`). In a production environment, you would use a readiness probe instead, but for a learning environment a fixed delay is sufficient.
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

- ✓ Built and pushed the Docker image to Azure Container Registry using `az acr build`
- ✓ Updated the Container App from nginx to the Flask application
- ✓ Configured environment variables following the 12-Factor App methodology
- ✓ Verified database migrations ran automatically at container startup
- ✓ Created a deployment script to automate the entire process

> **Key takeaway:** Deployment is a sequence of well-defined steps: build, push, update, configure. Migrations run automatically at container startup via `entrypoint.sh`, eliminating a manual step. Automating these steps in a script ensures consistency and prevents human error. The 12-Factor App principle of environment-driven configuration means the same Docker image works in every environment — only the environment variables change.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add a health check endpoint (`/api/health`) and configure Container Apps to use it as a readiness probe
> - Research blue-green deployments with Container Apps revisions
> - Explore Azure Container Registry tasks for building images in the cloud (no local Docker needed)
> - Investigate Container Apps secrets for sensitive environment variables instead of plain `--set-env-vars`

## Done! 🎉

Your News Flash application is live on Azure. The deployment script makes future deployments repeatable — change your code, run the script, and the updated application is live within minutes.
