+++
title = "Deploy with GitHub Actions"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Create a GitHub Actions workflow for automated build and deploy using managed identity, OIDC federation, and az acr build"
weight = 3
+++

# Deploy with GitHub Actions

## Goal

Create a GitHub Actions workflow that automatically builds, pushes, and deploys the News Flash application on every push to main. Uses a managed identity with OIDC federation for passwordless authentication, `az acr build` for cloud-native image building, and a 7-digit git commit hash as the Docker image tag for traceability.

> **What you'll learn:**
>
> - How to create a managed identity with role-based access control
> - How OIDC federation enables passwordless CI/CD between GitHub and Azure
> - How `az acr build` builds Docker images in the cloud without local Docker
> - How to write a GitHub Actions workflow for container deployment
> - Best practices for immutable Docker tags and path-filtered triggers

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Azure infrastructure provisioned (resource group, ACR, Container Apps Environment, Azure SQL)
> - ✓ Container App running the nginx placeholder with ACR credentials registered
> - ✓ Environment variables configured on the Container App (`FLASK_ENV`, `SECRET_KEY`, `DATABASE_URL`)
> - ✓ `.azure-config` file with all resource names
> - ✓ GitHub repository with the News Flash application code pushed
> - ✓ Azure CLI authenticated (`az login`)

## Exercise Steps

### Overview

1. **Create Managed Identity and Assign Roles**
2. **Configure OIDC Federation for GitHub**
3. **Create the GitHub Actions Workflow**
4. **Test the Complete Pipeline**

### **Step 1:** Create Managed Identity and Assign Roles

A managed identity is Azure's way to grant permissions without passwords or stored secrets. Instead of creating a username and password for your CI/CD pipeline, you create an identity object in Azure and assign it specific roles. The identity can only do what its roles allow — nothing more.

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ```

2. **Create** the managed identity:

   ```bash
   az identity create \
     --name id-news-flash-deploy \
     --resource-group $RESOURCE_GROUP \
     --location $LOCATION
   ```

3. **Get** the identity's principal ID and the resource IDs for role assignment:

   ```bash
   PRINCIPAL_ID=$(az identity show \
     --name id-news-flash-deploy \
     --resource-group $RESOURCE_GROUP \
     --query principalId -o tsv)

   ACR_ID=$(az acr show \
     --name $ACR_NAME \
     --resource-group $RESOURCE_GROUP \
     --query id -o tsv)

   RG_ID=$(az group show \
     --name $RESOURCE_GROUP \
     --query id -o tsv)
   ```

4. **Assign** the AcrPush role to allow pushing Docker images to ACR:

   ```bash
   az role assignment create \
     --assignee $PRINCIPAL_ID \
     --role AcrPush \
     --scope $ACR_ID
   ```

5. **Assign** the Contributor role on the resource group to allow updating Container Apps:

   ```bash
   az role assignment create \
     --assignee $PRINCIPAL_ID \
     --role Contributor \
     --scope $RG_ID
   ```

> ℹ **Concept Deep Dive**
>
> A **managed identity** is an Azure Active Directory object that represents a non-human actor (like a CI/CD pipeline). Unlike a service principal with a client secret, a managed identity has no password to rotate or leak. Azure manages the credentials internally.
>
> **Role-Based Access Control (RBAC)** follows the principle of least privilege:
>
> - `AcrPush` allows pushing (and pulling) images to the container registry — but not deleting images or managing registry settings
> - `Contributor` on the resource group allows creating and updating resources — but not managing access control or deleting the resource group
>
> Each role is scoped to a specific resource. The `AcrPush` role is scoped to the ACR (not the entire subscription), and `Contributor` is scoped to the resource group (not other resource groups). This limits the blast radius if the identity is compromised.
>
> ⚠ **Common Mistakes**
>
> - Assigning roles to the `clientId` instead of `principalId` — role assignments require the principal (object) ID
> - Using `Owner` instead of `Contributor` — Owner can manage access control, which the pipeline does not need
> - Forgetting the `AcrPush` role — the pipeline will fail at the `docker push` step
>
> ✓ **Quick check:** `az role assignment list --assignee $PRINCIPAL_ID -o table` shows both role assignments

### **Step 2:** Configure OIDC Federation for GitHub

OIDC (OpenID Connect) federation creates a trust relationship between GitHub and Azure. When GitHub Actions runs your workflow, it requests a short-lived token from GitHub's identity provider. Azure verifies this token and grants access — no passwords or secrets are stored in GitHub.

1. **Get** the identity details needed for federation:

   ```bash
   CLIENT_ID=$(az identity show \
     --name id-news-flash-deploy \
     --resource-group $RESOURCE_GROUP \
     --query clientId -o tsv)

   TENANT_ID=$(az account show --query tenantId -o tsv)
   SUBSCRIPTION_ID=$(az account show --query id -o tsv)
   ```

2. **Create** the federated credential. Replace `<owner>/<repo>` with your GitHub username and repository name (e.g., `johndoe/news-flash`):

   ```bash
   az identity federated-credential create \
     --name github-deploy \
     --identity-name id-news-flash-deploy \
     --resource-group $RESOURCE_GROUP \
     --issuer "https://token.actions.githubusercontent.com" \
     --subject "repo:<owner>/<repo>:ref:refs/heads/main" \
     --audiences "api://AzureADTokenExchange"
   ```

3. **Print** the values you need to add to GitHub:

   ```bash
   echo "AZURE_CLIENT_ID:       $CLIENT_ID"
   echo "AZURE_TENANT_ID:       $TENANT_ID"
   echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
   echo "ACR_NAME:              $ACR_NAME"
   ```

4. **Navigate** to your GitHub repository in the browser

5. **Open** Settings > Secrets and variables > Actions > Variables tab

6. **Add** four repository variables (click "New repository variable" for each):

   | Variable name | Value |
   |---------------|-------|
   | `AZURE_CLIENT_ID` | The client ID printed above |
   | `AZURE_TENANT_ID` | The tenant ID printed above |
   | `AZURE_SUBSCRIPTION_ID` | The subscription ID printed above |
   | `ACR_NAME` | Your ACR name (e.g., `acrnewsflash1a2b3c4d`) |

> ℹ **Concept Deep Dive**
>
> **OIDC federation** eliminates stored secrets entirely. The flow works like this:
>
> 1. GitHub Actions requests a JWT (JSON Web Token) from GitHub's identity provider
> 2. The workflow presents this token to Azure Active Directory
> 3. Azure verifies the token signature against GitHub's public keys
> 4. Azure checks the `subject` claim matches the federated credential configuration
> 5. Azure issues a short-lived access token for the managed identity
>
> The `--subject` field is critical for security. It restricts which repository and branch can authenticate as this identity. The format `repo:<owner>/<repo>:ref:refs/heads/main` means only the `main` branch of your specific repository can use this identity. A different repository — or even a different branch in your repository — cannot authenticate.
>
> **Repository variables** (not secrets) are used here because none of these values are sensitive. The client ID, tenant ID, and subscription ID are identifiers — not credentials. They identify which Azure identity to use, but without the OIDC token from the correct GitHub repository, they are useless.
>
> ⚠ **Common Mistakes**
>
> - Using `repo:owner/repo:ref:refs/heads/*` (wildcard) — this allows any branch to deploy, defeating branch protection
> - Putting values in GitHub Secrets instead of Variables — the workflow uses `vars.` prefix, not `secrets.`
> - Forgetting to replace `<owner>/<repo>` with actual values — the federated credential will not match
> - Adding extra spaces around the values when pasting into GitHub — trim whitespace carefully
>
> ✓ **Quick check:** `az identity federated-credential show --name github-deploy --identity-name id-news-flash-deploy --resource-group rg-news-flash` returns the credential details

### **Step 3:** Create the GitHub Actions Workflow

The workflow file defines what happens when code is pushed to the main branch. It authenticates with Azure using OIDC, builds the Docker image in the cloud using `az acr build`, pushes it to ACR with a commit-hash tag, updates the Container App, and verifies the deployment with a health check. The path filter ensures the workflow only runs when application code changes — not for README edits or documentation.

1. **Create** the workflow directory:

   ```bash
   mkdir -p .github/workflows
   ```

2. **Create** the workflow file:

   > `.github/workflows/deploy.yml`

   ```yaml
   name: Build and Deploy

   on:
     push:
       branches: [main]
       paths:
         - 'application/**'
         - 'Dockerfile'
         - '.github/workflows/deploy.yml'

   permissions:
     id-token: write
     contents: read

   env:
     CONTAINER_APP: ca-news-flash
     RESOURCE_GROUP: rg-news-flash

   jobs:
     build-and-deploy:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4

         - uses: azure/login@v2
           with:
             client-id: ${{ vars.AZURE_CLIENT_ID }}
             tenant-id: ${{ vars.AZURE_TENANT_ID }}
             subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

         - name: Set image tag
           run: echo "IMAGE_TAG=$(echo ${{ github.sha }} | cut -c1-7)" >> $GITHUB_ENV

         - name: Build and push with ACR
           run: |
             az acr build --registry ${{ vars.ACR_NAME }} \
               --image news-flash:${{ env.IMAGE_TAG }} .

         - name: Deploy to Container Apps
           run: |
             ACR_SERVER=$(az acr show --name ${{ vars.ACR_NAME }} --query loginServer -o tsv)
             az containerapp update \
               --name ${{ env.CONTAINER_APP }} \
               --resource-group ${{ env.RESOURCE_GROUP }} \
               --image $ACR_SERVER/news-flash:${{ env.IMAGE_TAG }}
             az containerapp ingress update \
               --name ${{ env.CONTAINER_APP }} \
               --resource-group ${{ env.RESOURCE_GROUP }} \
               --target-port 5000

         # Migrations run automatically at container startup via entrypoint.sh

         - name: Health check
           run: |
             FQDN=$(az containerapp show \
               --name ${{ env.CONTAINER_APP }} \
               --resource-group ${{ env.RESOURCE_GROUP }} \
               --query "properties.configuration.ingress.fqdn" -o tsv)
             for i in 1 2 3 4 5; do
               if curl -sf "https://$FQDN/" > /dev/null; then
                 echo "Health check passed on attempt $i"
                 exit 0
               fi
               echo "Attempt $i/5 failed, waiting 15s..."
               sleep 15
             done
             echo "Health check failed after 5 attempts!"
             exit 1
   ```

> ℹ **Concept Deep Dive**
>
> **`az acr build`** is an ACR Task that builds Docker images in the cloud. Instead of building locally and pushing separately, ACR Tasks upload your source code (respecting `.dockerignore`), build the image on Azure's infrastructure, and store the result directly in the registry.
>
> This approach has three advantages over local `docker build` + `docker push`:
>
> - **No architecture mismatch** — ACR builds on AMD64 (linux/amd64), which is what Container Apps expects. Building locally on an Apple Silicon Mac produces ARM images that crash on Azure.
> - **No local Docker needed** — you do not need Docker installed on your machine or on the GitHub Actions runner. The Azure CLI authenticates directly with ACR Tasks.
> - **Consistent builds** — every team member and every CI/CD run gets the same build environment regardless of the local operating system.
>
> **The 7-digit commit hash** (`${{ github.sha }} | cut -c1-7`) creates immutable, traceable image tags. Instead of overwriting `:latest` on every deploy, each build gets a unique tag like `:a1b2c3d`. This provides:
>
> - **Traceability** — every running container maps to an exact git commit
> - **Rollback** — deploy a previous tag to revert to a known-good version
> - **Auditability** — you can see which commit is running in production at any time
>
> The **target-port update** (`az containerapp ingress update --target-port 5000`) switches the Container App from the nginx placeholder (port 80) to the Flask application (port 5000). This command is idempotent — on the first deploy it changes 80 to 5000, and on subsequent deploys it is a no-op since the port is already 5000.
>
> The **`permissions`** block is required for OIDC. `id-token: write` allows the workflow to request a JWT from GitHub's identity provider. `contents: read` allows checking out the repository code. These are the minimum permissions needed.
>
> The **`paths`** filter prevents unnecessary deployments. If you edit only the README, no deployment runs. The workflow only triggers when files that affect the running application change: anything under `application/` (source code, dependencies, startup scripts, migrations), the `Dockerfile`, or the workflow itself.
>
> **Migrations run automatically** at container startup via `entrypoint.sh`. The workflow does not need a separate migration step — when Container Apps restarts the container with the new image, `entrypoint.sh` runs `flask db upgrade` before starting Gunicorn. Alembic tracks which migrations have already been applied and skips them, making this idempotent.
>
> The **health check** uses `curl -sf` where `-s` is silent mode (no progress bar) and `-f` fails on HTTP errors (4xx, 5xx). The retry loop (5 attempts, 15 seconds apart) accounts for container startup time — the new container may need up to 75 seconds to become ready. If the application does not respond with a 200 status code after all attempts, the workflow step fails. The health check implicitly verifies that migrations succeeded — if they had failed, the container would not have started, and the health check would fail.
>
> ⚠ **Common Mistakes**
>
> - Forgetting the `permissions` block — OIDC login fails with "AADSTS700024" error
> - Using `secrets.` instead of `vars.` — the values were stored as variables, not secrets
> - Hardcoding the ACR name in the workflow — use variables for portability
> - Missing `paths` filter — every push (including documentation changes) triggers a deployment
> - Adding a manual migration step with `az containerapp exec` — this requires an interactive terminal and fails in GitHub Actions
> - Using `http://` in the health check URL — Container Apps only serves HTTPS, and `curl` will get a redirect
> - Not including `entrypoint.sh` in the `paths` filter — changes to the startup script should trigger a deployment
>
> ✓ **Quick check:** `.github/workflows/deploy.yml` exists with all 6 steps and correct syntax (no YAML indentation errors)

### **Step 4:** Test the Complete Pipeline

This is the first time your application goes live. You will make a small change to the application, push it to GitHub, and watch the workflow build, deploy, and verify the change automatically. The CI/CD pipeline handles everything: building the Docker image, pushing it to ACR, updating the Container App, running migrations, and switching from the nginx placeholder to your Flask application.

1. **Make** a visible change to the application. For example, update a heading in one of the templates:

   ```bash
   # Edit any file in the app/ directory to make a visible change
   ```

2. **Commit** and **push** the change:

   ```bash
   git add -A
   git commit -m "Test CI/CD pipeline"
   git push
   ```

3. **Open** your GitHub repository in the browser and **navigate** to the Actions tab. You should see the "Build and Deploy" workflow running.

4. **Watch** the workflow progress through each step. A successful run shows green checkmarks on all steps.

5. **Verify** the image tag in ACR matches the commit hash:

   ```bash
   source .azure-config
   az acr repository show-tags \
     --name $ACR_NAME \
     --repository news-flash \
     -o table
   ```

6. **Verify** the Container App is running the new image:

   ```bash
   az containerapp show \
     --name ca-news-flash \
     --resource-group rg-news-flash \
     --query "properties.template.containers[0].image" \
     -o tsv
   ```

   The image tag should match the first 7 characters of your latest commit hash.

7. **Check** container logs to verify migrations ran at startup:

   ```bash
   az containerapp logs show \
     --name ca-news-flash \
     --resource-group rg-news-flash \
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

8. **Test** the application end-to-end:

   - **Visit** the landing page — it should load without errors
   - **Navigate** to the subscribe page
   - **Submit** a test subscription with your name and email
   - **Verify** the thank you page appears

9. **Verify** the subscription was persisted in the database:

   ```bash
   source .azure-config
   sqlcmd -S $SQL_SERVER.database.windows.net -d newsflash -U sqladmin -P "$SQL_PASSWORD" \
     -Q "SELECT id, CAST(name AS VARCHAR(30)) AS name, CAST(email AS VARCHAR(40)) AS email, CONVERT(VARCHAR(19), subscribed_at, 120) AS subscribed_at FROM subscribers;"
   ```

   You should see the test subscription you just submitted.

   > ℹ **Installing sqlcmd**
   >
   > **macOS:**
   >
   > ```bash
   > brew tap microsoft/mssql-release
   > brew install mssql-tools18
   > ```
   >
   > **Windows (PowerShell):**
   >
   > ```powershell
   > winget install Microsoft.Sqlcmd
   > ```
   >
   > After installation, restart your terminal so `sqlcmd` is available on your PATH.

> ℹ **Concept Deep Dive**
>
> The complete pipeline flow is:
>
> 1. Developer pushes code to `main` branch
> 2. GitHub detects the push matches the `paths` filter
> 3. GitHub Actions starts the workflow on an `ubuntu-latest` runner
> 4. The runner authenticates with Azure using OIDC (no stored secrets)
> 5. `az acr build` builds the image on Azure and tags it with the 7-digit commit hash
> 6. Container Apps pulls the new image and restarts the container
> 7. `entrypoint.sh` runs database migrations at container startup
> 8. A health check verifies the application responds
>
> This entire process runs automatically on every qualifying push. The developer's workflow becomes: write code, commit, push, done. The pipeline handles building, deploying, migrating, and verifying.
>
> You can check any commit hash against the running container image to answer: "which version of the code is currently in production?" This traceability is essential for debugging production issues.
>
> ⚠ **Common Mistakes**
>
> - Pushing changes to files not in the `paths` filter — the workflow will not trigger (this is by design)
> - The workflow fails at Azure login — verify the four GitHub variables match the values from Step 2
> - The workflow fails at `az acr build` — verify the `AcrPush` role assignment from Step 1
> - Health check fails — the application may need a few seconds to start; check the workflow logs for details
> - Excluding `migrations/` from `.dockerignore` — the container needs migration scripts to run `flask db upgrade`
>
> ✓ **Quick check:** GitHub Actions shows a green checkmark, and the application reflects your change

> ✓ **Success indicators:**
>
> - Managed identity created with AcrPush and Contributor roles
> - OIDC federation configured for your GitHub repository
> - GitHub Actions workflow triggers on push to main
> - Docker image tagged with 7-digit commit hash appears in ACR (built via `az acr build`)
> - Container App automatically updated with new image
> - Target port updated from 80 (nginx) to 5000 (Flask)
> - Database migrations run automatically at container startup
> - Health check passes
> - Subscribe form works end-to-end (submit, thank you page)
>
> ✓ **Final verification checklist:**
>
> - ☐ Managed identity `id-news-flash-deploy` exists with correct role assignments
> - ☐ Federated credential links your GitHub repository to the managed identity
> - ☐ Four repository variables set in GitHub (CLIENT_ID, TENANT_ID, SUBSCRIPTION_ID, ACR_NAME)
> - ☐ `.github/workflows/deploy.yml` created with all 6 steps
> - ☐ Pushing to main triggers the workflow
> - ☐ Docker image in ACR has a 7-digit commit hash tag
> - ☐ Container App runs the image matching the latest commit
> - ☐ Container logs show successful database migrations
> - ☐ Subscribe form submits and shows thank you page

## Common Issues

> **If you encounter problems:**
>
> **"AADSTS700024: Client assertion is not within its valid time range":** The OIDC token has expired. This usually means the `permissions: id-token: write` block is missing from the workflow.
>
> **"Error: federated identity credential not found":** The `--subject` in the federated credential does not match the repository and branch. Verify `repo:<owner>/<repo>:ref:refs/heads/main` matches exactly.
>
> **Workflow does not trigger on push:** Check that the changed files match the `paths` filter. Editing only the README will not trigger deployment (by design).
>
> **"AcrPush" permission denied during build:** Role assignments can take a few minutes to propagate. Wait 5 minutes and re-run the workflow.
>
> **Container App shows "Revision failed":** Check the container logs with `az containerapp logs show --name ca-news-flash --resource-group rg-news-flash --follow`. Common causes are missing environment variables or incorrect port configuration.
>
> **Migration fails with "could not connect to server":** The Azure SQL firewall may not include the Container Apps outbound IP. Verify the `AllowAzureServices` firewall rule exists on the SQL Server.
>
> **Health check fails with "Connection refused":** The container may still be starting. Add a `sleep 30` before the health check step as a temporary workaround.
>
> **Workflow succeeds but application shows old content:** The browser may be caching the previous version. Try a hard refresh (Ctrl+Shift+R) or open the URL in a private/incognito window.
>
> **Still stuck?** Check the detailed logs for the failing step in GitHub Actions. Click the step name to expand its output and look for the specific error message.

## Summary

You've successfully automated the News Flash deployment with GitHub Actions:

- ✓ Created a managed identity with least-privilege role assignments for ACR and Container Apps
- ✓ Configured OIDC federation for passwordless authentication between GitHub and Azure
- ✓ Built a GitHub Actions workflow that builds, deploys, and verifies on every push (migrations run at container startup)
- ✓ Used `az acr build` for cloud-native image building — no local Docker required
- ✓ Used 7-digit commit hash tags for immutable, traceable Docker images
- ✓ Verified the full application works end-to-end: subscribe form and database persistence

> **Key takeaway:** Modern CI/CD pipelines use identity federation instead of stored secrets. OIDC means no passwords in GitHub, no secrets to rotate, and no credentials to leak. Combined with `az acr build` for cloud-native image building, immutable commit-hash image tags, automatic migrations via `entrypoint.sh`, and health checks, this pipeline provides a reliable, traceable deployment process that runs on every push to main. There is no manual deploy script — CI/CD is the deployment mechanism.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add a staging environment that deploys on pull request merges before promoting to production
> - Implement rollback by deploying a previous commit hash tag
> - Add build caching to speed up Docker builds in GitHub Actions
> - Configure branch protection rules to require the workflow to pass before merging
> - Add a `/api/health` endpoint that returns application version and database status

## Done! 🎉

Your deployment pipeline is fully automated. Push code to main and the pipeline handles the rest — build, push, deploy, migrate, and verify. Every deployment is traceable to an exact commit, and no passwords are stored anywhere.

## TL;DR — Single CI/CD Setup Script

If you understand the concepts above and want to configure CI/CD in one run, create this script:

```text
repo-root/
├── application/
├── infrastructure/
│   ├── provision.sh
│   └── setup-cicd.sh
├── .github/
│   └── workflows/
│       └── deploy.yml        ← created by script
├── Dockerfile
```

> `infrastructure/setup-cicd.sh`

```bash
#!/bin/bash
# Configure CI/CD: managed identity, OIDC federation, GitHub variables, and workflow
set -e

# ── Load Configuration ──────────────────────────────────────────────
if [ ! -f .azure-config ]; then
  echo "ERROR: .azure-config not found. Run provision.sh first."
  exit 1
fi
source .azure-config

# ── Create Managed Identity ─────────────────────────────────────────
echo "Creating managed identity..."
az identity create \
  --name id-news-flash-deploy \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# ── Get IDs for Role Assignment ─────────────────────────────────────
echo "Retrieving identity and resource IDs..."
PRINCIPAL_ID=$(az identity show \
  --name id-news-flash-deploy \
  --resource-group $RESOURCE_GROUP \
  --query principalId -o tsv)

ACR_ID=$(az acr show \
  --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP \
  --query id -o tsv)

RG_ID=$(az group show \
  --name $RESOURCE_GROUP \
  --query id -o tsv)

# ── Assign Roles ────────────────────────────────────────────────────
echo "Assigning AcrPush role (waiting for identity to propagate)..."
for i in 1 2 3 4 5; do
  if az role assignment create \
    --assignee $PRINCIPAL_ID \
    --role AcrPush \
    --scope $ACR_ID 2>/dev/null; then
    break
  fi
  echo "  Attempt $i/5 failed, waiting 10s..."
  sleep 10
done

echo "Assigning Contributor role..."
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role Contributor \
  --scope $RG_ID

# ── Get OIDC Values ─────────────────────────────────────────────────
CLIENT_ID=$(az identity show \
  --name id-news-flash-deploy \
  --resource-group $RESOURCE_GROUP \
  --query clientId -o tsv)

TENANT_ID=$(az account show --query tenantId -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# ── Ensure GitHub Repository ────────────────────────────────────────
REPO_ROOT=$(git rev-parse --show-toplevel)
if git -C "$REPO_ROOT" remote get-url origin &>/dev/null; then
  echo "Git remote 'origin' already exists."
else
  REPO_NAME=$(basename "$REPO_ROOT")
  echo "Creating GitHub repository: $REPO_NAME"
  gh repo create "$REPO_NAME" --public --source="$REPO_ROOT" --remote=origin
fi
GITHUB_REPO=$(cd "$REPO_ROOT" && gh repo view --json nameWithOwner -q .nameWithOwner)

# ── Create Federated Credential ─────────────────────────────────────
echo "Creating OIDC federated credential for $GITHUB_REPO..."
az identity federated-credential create \
  --name github-deploy \
  --identity-name id-news-flash-deploy \
  --resource-group $RESOURCE_GROUP \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:${GITHUB_REPO}:ref:refs/heads/main" \
  --audiences "api://AzureADTokenExchange"

# ── Set GitHub Variables ─────────────────────────────────────────────
echo "Setting GitHub repository variables..."
gh variable set AZURE_CLIENT_ID --body "$CLIENT_ID"
gh variable set AZURE_TENANT_ID --body "$TENANT_ID"
gh variable set AZURE_SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID"
gh variable set ACR_NAME --body "$ACR_NAME"

# ── Write Workflow File ──────────────────────────────────────────────
echo "Writing .github/workflows/deploy.yml..."
mkdir -p "$REPO_ROOT/.github/workflows"
cat > "$REPO_ROOT/.github/workflows/deploy.yml" << 'WORKFLOW'
name: Build and Deploy

on:
  push:
    branches: [main]
    paths:
      - 'application/**'
      - 'Dockerfile'
      - '.github/workflows/deploy.yml'

permissions:
  id-token: write
  contents: read

env:
  CONTAINER_APP: ca-news-flash
  RESOURCE_GROUP: rg-news-flash

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

      - name: Set image tag
        run: echo "IMAGE_TAG=$(echo ${{ github.sha }} | cut -c1-7)" >> $GITHUB_ENV

      - name: Build and push with ACR
        run: |
          az acr build --registry ${{ vars.ACR_NAME }} \
            --image news-flash:${{ env.IMAGE_TAG }} .

      - name: Deploy to Container Apps
        run: |
          ACR_SERVER=$(az acr show --name ${{ vars.ACR_NAME }} --query loginServer -o tsv)
          az containerapp update \
            --name ${{ env.CONTAINER_APP }} \
            --resource-group ${{ env.RESOURCE_GROUP }} \
            --image $ACR_SERVER/news-flash:${{ env.IMAGE_TAG }}
          az containerapp ingress update \
            --name ${{ env.CONTAINER_APP }} \
            --resource-group ${{ env.RESOURCE_GROUP }} \
            --target-port 5000

      # Migrations run automatically at container startup via entrypoint.sh

      - name: Health check
        run: |
          FQDN=$(az containerapp show \
            --name ${{ env.CONTAINER_APP }} \
            --resource-group ${{ env.RESOURCE_GROUP }} \
            --query "properties.configuration.ingress.fqdn" -o tsv)
          for i in 1 2 3 4 5; do
            if curl -sf "https://$FQDN/" > /dev/null; then
              echo "Health check passed on attempt $i"
              exit 0
            fi
            echo "Attempt $i/5 failed, waiting 15s..."
            sleep 15
          done
          echo "Health check failed after 5 attempts!"
          exit 1
WORKFLOW

# ── Summary ──────────────────────────────────────────────────────────
echo ""
echo "=== CI/CD Setup Complete ==="
echo "Managed Identity: id-news-flash-deploy"
echo "Federated Repo:   $GITHUB_REPO"
echo "Client ID:        $CLIENT_ID"
echo "Tenant ID:        $TENANT_ID"
echo "Subscription ID:  $SUBSCRIPTION_ID"
echo "ACR Name:         $ACR_NAME"
echo ""
echo "Workflow written to: .github/workflows/deploy.yml"
echo "Push to main to trigger the first deployment."
```

Make the script executable and run it:

```bash
chmod +x infrastructure/setup-cicd.sh
./infrastructure/setup-cicd.sh
```

The script sources `.azure-config` (created by `provision.sh`) for resource names, then runs all commands from Steps 1–4 in sequence. GitHub variables replace the manual browser steps from Step 2, and the health check with retry (5 attempts, 15 seconds apart) is already included in the workflow. After running the script, commit and push to trigger the first deployment.
