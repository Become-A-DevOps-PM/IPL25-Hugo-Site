+++
title = "Automated Deployment with GitHub Actions"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Create a GitHub Actions workflow for automated build, push, and deploy on every push to main using managed identity and OIDC"
weight = 4
+++

# Automated Deployment with GitHub Actions

## Goal

Create a GitHub Actions workflow that automatically builds, pushes, and deploys the News Flash application on every push to main. Uses a managed identity with OIDC federation for passwordless authentication and a 7-digit git commit hash as the Docker image tag for traceability.

> **What you'll learn:**
>
> - How to create a managed identity with role-based access control
> - How OIDC federation enables passwordless CI/CD between GitHub and Azure
> - How to write a GitHub Actions workflow for container deployment
> - Best practices for immutable Docker tags and path-filtered triggers

## Prerequisites

> **Before starting, ensure you have:**
>
> - Application deployed manually and accessible via HTTPS
> - `.azure-config` file with all resource names
> - GitHub repository with the News Flash application code pushed
> - Azure CLI authenticated (`az login`)

## Exercise Steps

### Overview

1. **Create Managed Identity and Assign Roles**
2. **Configure OIDC Federation for GitHub**
3. **Create the GitHub Actions Workflow**
4. **Add Database Migration and Health Check**
5. **Test the Complete Pipeline**

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

> **Concept Deep Dive**
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
> **Common Mistakes**
>
> - Assigning roles to the `clientId` instead of `principalId` — role assignments require the principal (object) ID
> - Using `Owner` instead of `Contributor` — Owner can manage access control, which the pipeline does not need
> - Forgetting the `AcrPush` role — the pipeline will fail at the `docker push` step
>
> **Quick check:** `az role assignment list --assignee $PRINCIPAL_ID -o table` shows both role assignments

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

> **Concept Deep Dive**
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
> **Common Mistakes**
>
> - Using `repo:owner/repo:ref:refs/heads/*` (wildcard) — this allows any branch to deploy, defeating branch protection
> - Putting values in GitHub Secrets instead of Variables — the workflow uses `vars.` prefix, not `secrets.`
> - Forgetting to replace `<owner>/<repo>` with actual values — the federated credential will not match
> - Adding extra spaces around the values when pasting into GitHub — trim whitespace carefully
>
> **Quick check:** `az identity federated-credential show --name github-deploy --identity-name id-news-flash-deploy --resource-group rg-news-flash` returns the credential details

### **Step 3:** Create the GitHub Actions Workflow

The workflow file defines what happens when code is pushed to the main branch. It authenticates with Azure using OIDC, builds the Docker image, pushes it to ACR with a commit-hash tag, and updates the Container App. The path filter ensures the workflow only runs when application code changes — not for README edits or documentation.

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
         - 'app/**'
         - 'Dockerfile'
         - 'requirements.txt'
         - 'wsgi.py'
         - 'migrations/**'
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

         - name: Login to ACR
           run: az acr login --name ${{ vars.ACR_NAME }}

         - name: Set image tag
           run: echo "IMAGE_TAG=$(echo ${{ github.sha }} | cut -c1-7)" >> $GITHUB_ENV

         - name: Build and push
           run: |
             ACR_SERVER=$(az acr show --name ${{ vars.ACR_NAME }} --query loginServer -o tsv)
             docker build --tag $ACR_SERVER/news-flash:${{ env.IMAGE_TAG }} .
             docker push $ACR_SERVER/news-flash:${{ env.IMAGE_TAG }}

         - name: Deploy to Container Apps
           run: |
             ACR_SERVER=$(az acr show --name ${{ vars.ACR_NAME }} --query loginServer -o tsv)
             az containerapp update \
               --name ${{ env.CONTAINER_APP }} \
               --resource-group ${{ env.RESOURCE_GROUP }} \
               --image $ACR_SERVER/news-flash:${{ env.IMAGE_TAG }}
   ```

> **Concept Deep Dive**
>
> **The 7-digit commit hash** (`${{ github.sha }} | cut -c1-7`) creates immutable, traceable image tags. Instead of overwriting `:latest` on every deploy, each build gets a unique tag like `:a1b2c3d`. This provides:
>
> - **Traceability** — every running container maps to an exact git commit
> - **Rollback** — deploy a previous tag to revert to a known-good version
> - **Auditability** — you can see which commit is running in production at any time
>
> The **`permissions`** block is required for OIDC. `id-token: write` allows the workflow to request a JWT from GitHub's identity provider. `contents: read` allows checking out the repository code. These are the minimum permissions needed.
>
> The **`paths`** filter prevents unnecessary deployments. If you edit only the README, no deployment runs. The workflow only triggers when files that affect the running application change: source code (`app/**`), dependencies (`requirements.txt`), container definition (`Dockerfile`, `wsgi.py`), database schema (`migrations/**`), or the workflow itself.
>
> The **`${{ vars.ACR_NAME }}`** syntax reads from GitHub repository variables (set in Step 2). Using variables instead of hardcoded values makes the workflow portable — a different team can fork the repository and set their own values.
>
> **Common Mistakes**
>
> - Forgetting the `permissions` block — OIDC login fails with "AADSTS700024" error
> - Using `secrets.` instead of `vars.` — the values were stored as variables, not secrets
> - Hardcoding the ACR name in the workflow — use variables for portability
> - Missing `paths` filter — every push (including documentation changes) triggers a deployment
>
> **Quick check:** `.github/workflows/deploy.yml` exists with correct syntax (no YAML indentation errors)

### **Step 4:** Add Database Migration and Health Check

The workflow should also run database migrations after deploying a new image, and verify that the application responds correctly. If either step fails, the workflow fails visibly in GitHub — the team knows immediately that something is wrong.

1. **Open** the workflow file at `.github/workflows/deploy.yml`

2. **Add** the following steps after the "Deploy to Container Apps" step:

   ```yaml
         - name: Run migrations
           run: |
             az containerapp exec \
               --name ${{ env.CONTAINER_APP }} \
               --resource-group ${{ env.RESOURCE_GROUP }} \
               --command "flask" -- db upgrade

         - name: Health check
           run: |
             FQDN=$(az containerapp show \
               --name ${{ env.CONTAINER_APP }} \
               --resource-group ${{ env.RESOURCE_GROUP }} \
               --query "properties.configuration.ingress.fqdn" -o tsv)
             curl -sf "https://$FQDN/" || (echo "Health check failed!" && exit 1)
   ```

3. **Verify** the complete workflow file has all steps in order:

   - Checkout
   - Azure login
   - ACR login
   - Set image tag
   - Build and push
   - Deploy to Container Apps
   - Run migrations
   - Health check

> **Concept Deep Dive**
>
> **Migrations run after deployment** because the new container may include schema changes that the new code depends on. The sequence is: deploy new image → run migrations → verify health. If migrations fail, the database transaction is rolled back automatically, and the workflow fails with a visible error in GitHub Actions.
>
> The **health check** uses `curl -sf` where `-s` is silent mode (no progress bar) and `-f` fails on HTTP errors (4xx, 5xx). If the application does not respond with a 200 status code, `curl` returns a non-zero exit code, the `||` branch runs, and the workflow step fails.
>
> In a more sophisticated pipeline, you would add a wait/retry loop before the health check to account for container startup time. For a learning environment, the container is usually ready by the time migrations complete.
>
> **Common Mistakes**
>
> - Placing migration before deployment — the old container does not have the new migration files
> - Forgetting the `--` separator in `az containerapp exec` — the CLI parser may misinterpret `db upgrade`
> - Using `http://` in the health check URL — Container Apps only serves HTTPS, and `curl` will get a redirect
>
> **Quick check:** The workflow YAML is valid and contains all 8 steps

### **Step 5:** Test the Complete Pipeline

Time to verify the entire automated pipeline works end-to-end. You will make a small change to the application, push it to GitHub, and watch the workflow build, deploy, and verify the change automatically.

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

7. **Browse** the application URL and **confirm** your change is live

> **Concept Deep Dive**
>
> The complete pipeline flow is:
>
> 1. Developer pushes code to `main` branch
> 2. GitHub detects the push matches the `paths` filter
> 3. GitHub Actions starts the workflow on an `ubuntu-latest` runner
> 4. The runner authenticates with Azure using OIDC (no stored secrets)
> 5. Docker builds the image and tags it with the 7-digit commit hash
> 6. The image is pushed to ACR
> 7. Container Apps pulls the new image and restarts the container
> 8. Migrations run inside the new container
> 9. A health check verifies the application responds
>
> This entire process runs automatically on every qualifying push. The developer's workflow becomes: write code → commit → push → done. The pipeline handles building, deploying, migrating, and verifying.
>
> You can check any commit hash against the running container image to answer: "which version of the code is currently in production?" This traceability is essential for debugging production issues.
>
> **Common Mistakes**
>
> - Pushing changes to files not in the `paths` filter — the workflow will not trigger (this is by design)
> - The workflow fails at Azure login — verify the four GitHub variables match the values from Step 2
> - The workflow fails at `az acr login` — verify the `AcrPush` role assignment from Step 1
> - Health check fails — the application may need a few seconds to start; check the workflow logs for details
>
> **Quick check:** GitHub Actions shows a green checkmark, and the application reflects your change

> **Success indicators:**
>
> - Managed identity created with AcrPush and Contributor roles
> - OIDC federation configured for your GitHub repository
> - GitHub Actions workflow triggers on push to main
> - Docker image tagged with 7-digit commit hash appears in ACR
> - Container App automatically updated with new image
> - Database migrations run automatically
> - Health check passes
> - Application reflects the code change
>
> **Final verification checklist:**
>
> - [ ] Managed identity `id-news-flash-deploy` exists with correct role assignments
> - [ ] Federated credential links your GitHub repository to the managed identity
> - [ ] Four repository variables set in GitHub (CLIENT_ID, TENANT_ID, SUBSCRIPTION_ID, ACR_NAME)
> - [ ] `.github/workflows/deploy.yml` created with all 8 steps
> - [ ] Pushing to main triggers the workflow
> - [ ] Docker image in ACR has a 7-digit commit hash tag
> - [ ] Container App runs the image matching the latest commit
> - [ ] Application is accessible and reflects the latest code change

## Common Issues

> **If you encounter problems:**
>
> **"AADSTS700024: Client assertion is not within its valid time range":** The OIDC token has expired. This usually means the `permissions: id-token: write` block is missing from the workflow.
>
> **"Error: federated identity credential not found":** The `--subject` in the federated credential does not match the repository and branch. Verify `repo:<owner>/<repo>:ref:refs/heads/main` matches exactly.
>
> **Workflow does not trigger on push:** Check that the changed files match the `paths` filter. Editing only the README will not trigger deployment (by design).
>
> **"AcrPush" permission denied during docker push:** Role assignments can take a few minutes to propagate. Wait 5 minutes and re-run the workflow.
>
> **Health check fails with "Connection refused":** The container may still be starting. Add a `sleep 30` before the health check step as a temporary workaround.
>
> **Workflow succeeds but application shows old content:** The browser may be caching the previous version. Try a hard refresh (Ctrl+Shift+R) or open the URL in a private/incognito window.
>
> **Still stuck?** Check the detailed logs for the failing step in GitHub Actions. Click the step name to expand its output and look for the specific error message.

## Summary

You've successfully automated the News Flash deployment with GitHub Actions:

- Created a managed identity with least-privilege role assignments for ACR and Container Apps
- Configured OIDC federation for passwordless authentication between GitHub and Azure
- Built a GitHub Actions workflow that builds, pushes, deploys, migrates, and verifies on every push
- Used 7-digit commit hash tags for immutable, traceable Docker images
- Added path filters to avoid unnecessary deployments

> **Key takeaway:** Modern CI/CD pipelines use identity federation instead of stored secrets. OIDC means no passwords in GitHub, no secrets to rotate, and no credentials to leak. Combined with immutable image tags and automated health checks, this pipeline provides a reliable, traceable deployment process that runs on every push to main.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add a staging environment that deploys on pull request merges before promoting to production
> - Implement rollback by deploying a previous commit hash tag
> - Add build caching to speed up Docker builds in GitHub Actions
> - Configure branch protection rules to require the workflow to pass before merging

## Done!

Your deployment pipeline is fully automated. Push code to main and the pipeline handles the rest — build, push, deploy, migrate, and verify. Every deployment is traceable to an exact commit, and no passwords are stored anywhere.
