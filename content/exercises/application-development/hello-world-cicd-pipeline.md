+++
title = "Hello World CI/CD Pipeline"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Build and deploy a Hello World Flask app to Azure Container Apps with automated CI/CD using GitHub Actions"
weight = 2
+++

# Hello World CI/CD Pipeline

## Goal

Build a minimal Flask application, deploy it to Azure Container Apps, and automate future deployments with a GitHub Actions workflow using passwordless OIDC authentication. This tutorial is self-contained — you start from an empty directory and finish with a working CI/CD pipeline.

> **What you'll learn:**
>
> - How to containerize a Flask application with Docker
> - How to provision Azure Container Apps infrastructure with the CLI
> - How OIDC federation enables passwordless CI/CD between GitHub and Azure
> - How to write a GitHub Actions workflow that builds, deploys, and verifies automatically

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Azure CLI installed and authenticated (`az login`)
> - ✓ GitHub CLI installed and authenticated (`gh auth status`)
> - ✓ Git installed and configured (`git config user.name` and `user.email`)
> - ✓ Python 3.11+ installed (`python3 --version`)

## Tutorial Steps

### Overview

1. **Create the Flask Application**
2. **Create a GitHub Repository**
3. **Provision Azure Infrastructure**
4. **Build and Deploy Manually**
5. **Automate with GitHub Actions**
6. **Test the Pipeline**

### **Step 1:** Create the Flask Application

A Hello World Flask app is the simplest possible web application — one Python file, one dependency, and one route. By keeping the application minimal, you can focus on the deployment pipeline without worrying about database connections, migrations, or complex configuration.

1. **Create** a project directory and navigate into it:

   ```bash
   mkdir hello-cicd && cd hello-cicd
   ```

2. **Create** the Flask application:

   > `app.py`

   ```python
   from flask import Flask

   app = Flask(__name__)


   @app.route('/')
   def hello():
       return 'Hello, World!'


   if __name__ == '__main__':
       app.run(debug=True)
   ```

3. **Create** the dependencies file:

   > `requirements.txt`

   ```text
   flask
   gunicorn
   ```

4. **Create** the Dockerfile:

   > `Dockerfile`

   ```dockerfile
   FROM python:3.11-slim
   WORKDIR /app
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   COPY . .
   EXPOSE 5000
   CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
   ```

5. **Create** a `.gitignore` file:

   > `.gitignore`

   ```text
   .venv/
   __pycache__/
   *.pyc
   .azure-config
   ```

6. **Create** a `.dockerignore` file:

   > `.dockerignore`

   ```text
   .venv/
   __pycache__/
   *.pyc
   .git/
   .gitignore
   .azure-config
   ```

> ℹ **Concept Deep Dive**
>
> The Dockerfile uses `python:3.11-slim` instead of the full `python:3.11` image. The slim variant excludes development tools and documentation, reducing the image size significantly. Gunicorn is a production-grade WSGI server — unlike Flask's built-in development server, it handles multiple concurrent requests and is designed for production use.
>
> The `.dockerignore` file prevents unnecessary files from being sent to the Docker build context. Without it, the `.git/` directory (which can be large) and virtual environment files would be copied into the image unnecessarily.
>
> ⚠ **Common Mistakes**
>
> - Using `flask run` in the Dockerfile instead of gunicorn — Flask's development server is not suitable for production
> - Forgetting to add `gunicorn` to `requirements.txt` — the container will fail to start
> - Missing `EXPOSE 5000` — Azure Container Apps needs to know which port the application listens on
>
> ✓ **Quick check:** You have 5 files in your directory: `app.py`, `requirements.txt`, `Dockerfile`, `.gitignore`, `.dockerignore`

### **Step 2:** Create a GitHub Repository

The GitHub CLI (`gh`) lets you create a repository and push code without leaving the terminal. Using `gh repo view --json` later in the tutorial eliminates manual copy-pasting of the repository owner and name.

1. **Initialize** the git repository and make the first commit:

   ```bash
   git init
   git add -A
   git commit -m "Initial commit: Hello World Flask app"
   ```

   > ℹ **Windows users:** Some Git for Windows installations default to `master` instead of `main` as the initial branch name. This exercise and the GitHub Actions workflow expect `main`. Check your branch name with `git branch` and rename it if needed:
   >
   > ```bash
   > git branch -m master main
   > ```

2. **Create** a public GitHub repository and push:

   ```bash
   gh repo create hello-cicd --public --source . --push
   ```

3. **Verify** the repository was created:

   ```bash
   gh repo view --json nameWithOwner --jq '.nameWithOwner'
   ```

   This prints `<your-username>/hello-cicd`. You will use this command again in Step 5 to configure OIDC federation automatically.

> ℹ **Concept Deep Dive**
>
> The `gh repo create` command with `--source .` sets the current directory as the source and automatically adds the GitHub remote. The `--push` flag pushes the current branch immediately. This replaces the multi-step process of creating a repo on github.com, copying the remote URL, running `git remote add`, and pushing.
>
> ⚠ **Common Mistakes**
>
> - Running `gh repo create` before `git init` — the CLI needs an existing git repository when using `--source .`
> - Forgetting `--push` — the repository is created on GitHub but contains no code
>
> ✓ **Quick check:** `gh repo view --web` opens the repository in your browser and shows your code

### **Step 3:** Provision Azure Infrastructure

You need four Azure resources: a resource group (logical container), a container registry (stores Docker images), a Container Apps environment (hosting platform), and a container app (runs your application). All resources use a consistent `hello-cicd` naming convention.

> ℹ **First time using Azure?** New subscriptions (especially Azure for Students) may not have all required resource providers registered. Run these commands once before proceeding — the `--wait` flag ensures registration completes before you continue:
>
> ```bash
> az provider register --namespace Microsoft.ContainerRegistry --wait
> az provider register --namespace Microsoft.App --wait
> az provider register --namespace Microsoft.OperationalInsights --wait
> az provider register --namespace Microsoft.ManagedIdentity --wait
> ```

1. **Set** a unique suffix for your container registry name (ACR names must be globally unique):

   ```bash
   SUFFIX=$(openssl rand -hex 4)
   echo "Your suffix: $SUFFIX"
   ```

2. **Create** the resource group:

   ```bash
   az group create \
     --name rg-hello-cicd \
     --location swedencentral
   ```

3. **Create** the container registry:

   ```bash
   az acr create \
     --name acrhellocicd${SUFFIX} \
     --resource-group rg-hello-cicd \
     --sku Basic \
     --admin-enabled true
   ```

4. **Create** the Container Apps environment:

   ```bash
   az containerapp env create \
     --name cae-hello-cicd \
     --resource-group rg-hello-cicd \
     --location swedencentral
   ```

5. **Save** your resource names to a config file for use in later steps:

   ```bash
   cat > .azure-config << EOF
   RESOURCE_GROUP=rg-hello-cicd
   ACR_NAME=acrhellocicd${SUFFIX}
   LOCATION=swedencentral
   CONTAINER_APP=ca-hello-cicd
   EOF
   ```

6. **Verify** the config file and source it:

   ```bash
   cat .azure-config
   source .azure-config
   ```

   > ℹ **Windows users:** Git Bash may save the config file with Windows-style line endings (CRLF), which adds invisible `\r` characters to each variable value. This causes Azure CLI commands to fail with confusing errors. Clean the file before sourcing:
   >
   > ```bash
   > sed -i 's/\r$//' .azure-config
   > source .azure-config
   > ```

> ℹ **Concept Deep Dive**
>
> **Azure Container Apps** is a serverless container hosting platform. Unlike VMs, you do not manage the operating system, patching, or scaling — Azure handles the infrastructure. You provide a container image, and Container Apps runs it.
>
> **Azure Container Registry (ACR)** is a private Docker registry. Instead of pushing images to Docker Hub (public), you push to ACR where only your Azure resources can access them. The `--admin-enabled true` flag allows password-based login for the initial manual deployment. The automated pipeline in Step 5 uses OIDC instead.
>
> The `--sku Basic` tier costs approximately $5/month and is sufficient for development and learning. The Container Apps environment itself is free — you only pay for the compute resources your containers consume.
>
> ⚠ **Common Mistakes**
>
> - Using an ACR name that is already taken — the random suffix prevents this
> - Forgetting `--admin-enabled true` — the manual deployment in Step 4 needs admin credentials
> - Choosing a region far from your users — `swedencentral` is appropriate for this course
>
> ✓ **Quick check:** `az group show --name rg-hello-cicd -o table` shows the resource group, and `.azure-config` contains all four variable names

### **Step 4:** Build and Deploy Manually

Before automating with GitHub Actions, deploy once manually to verify that the application, Dockerfile, and Azure infrastructure all work correctly. This uses `az acr build` to build the Docker image on Azure (avoiding local Docker installation requirements) and `az containerapp create` to run it.

1. **Source** your configuration:

   ```bash
   source .azure-config
   ```

2. **Build** the Docker image on Azure:

   ```bash
   az acr build \
     --registry $ACR_NAME \
     --image hello-cicd:manual \
     --file Dockerfile .
   ```

   This uploads your source code to Azure and builds the image in the cloud. The image is tagged `hello-cicd:manual` and stored in your container registry.

3. **Get** the ACR login server name:

   ```bash
   ACR_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
   echo "ACR server: $ACR_SERVER"
   ```

4. **Create** the container app:

   ```bash
   az containerapp create \
     --name $CONTAINER_APP \
     --resource-group $RESOURCE_GROUP \
     --environment cae-hello-cicd \
     --image $ACR_SERVER/hello-cicd:manual \
     --registry-server $ACR_SERVER \
     --registry-username $(az acr credential show --name $ACR_NAME --query username -o tsv) \
     --registry-password $(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv) \
     --target-port 5000 \
     --ingress external
   ```

5. **Get** the application URL and verify it works:

   ```bash
   FQDN=$(az containerapp show \
     --name $CONTAINER_APP \
     --resource-group $RESOURCE_GROUP \
     --query "properties.configuration.ingress.fqdn" -o tsv)
   echo "Application URL: https://$FQDN"
   ```

6. **Open** the URL in your browser — you should see "Hello, World!"

   You can also verify from the terminal:

   ```bash
   curl -sf "https://$FQDN"
   ```

7. **Update** the application — now that the deployment works, change the message to verify you can deploy updates:

   > `app.py`

   ```python
   from flask import Flask

   app = Flask(__name__)


   @app.route('/')
   def hello():
       return 'Hello, Universe!'


   if __name__ == '__main__':
       app.run(debug=True)
   ```

8. **Rebuild** the image with a new tag and **update** the container app:

   ```bash
   az acr build \
     --registry $ACR_NAME \
     --image hello-cicd:manual-v2 \
     --file Dockerfile .

   az containerapp update \
     --name $CONTAINER_APP \
     --resource-group $RESOURCE_GROUP \
     --image $ACR_SERVER/hello-cicd:manual-v2
   ```

9. **Verify** the updated deployment:

   ```bash
   sleep 10
   curl -sf "https://$FQDN"
   ```

   You should now see `Hello, Universe!` — confirming that you can build, deploy, and update the application manually.

> ℹ **Concept Deep Dive**
>
> **`az acr build`** builds the Docker image on Azure infrastructure instead of on your local machine. This means you do not need Docker Desktop installed. It also guarantees the image is built for linux/amd64, avoiding architecture mismatches if you develop on Apple Silicon (ARM).
>
> The `--ingress external` flag makes the container app accessible from the internet. Container Apps automatically provisions a domain name and TLS certificate — you get HTTPS for free without configuring certificates or load balancers.
>
> The `--target-port 5000` flag tells Container Apps which port your application listens on (matching the gunicorn `--bind` in the Dockerfile). Container Apps routes incoming HTTPS traffic on port 443 to your container on port 5000.
>
> **`az containerapp update`** vs **`az containerapp create`:** You use `create` for the initial deployment and `update` for subsequent deployments. The `update` command only changes the image — it preserves all existing configuration (ingress, ports, environment variables). This is the same command the GitHub Actions workflow uses in Step 5.
>
> ⚠ **Common Mistakes**
>
> - Running `az acr build` from the wrong directory — you must be in the directory containing the Dockerfile
> - Forgetting `--target-port 5000` — Container Apps defaults to port 80, and your app will not respond
> - Missing `--ingress external` — the app deploys but is not accessible from the internet
>
> ✓ **Quick check:** `curl -sf "https://$FQDN"` returns `Hello, Universe!`

### **Step 5:** Automate with GitHub Actions

Now that the manual deployment works, automate it with a GitHub Actions workflow. This step creates a managed identity, configures OIDC federation (so no passwords are stored in GitHub), and writes the workflow file.

1. **Source** your configuration:

   ```bash
   source .azure-config
   ```

2. **Create** a managed identity for the pipeline:

   ```bash
   az identity create \
     --name id-hello-cicd-deploy \
     --resource-group $RESOURCE_GROUP \
     --location $LOCATION
   ```

   > ℹ **Windows users:** Git Bash automatically converts strings starting with `/` into Windows file paths (e.g., `/subscriptions/...` becomes `C:/Program Files/Git/subscriptions/...`). This silently breaks Azure resource IDs. Disable this behavior before continuing:
   >
   > ```bash
   > export MSYS_NO_PATHCONV=1
   > ```

3. **Get** the identity details and assign roles:

   ```bash
   PRINCIPAL_ID=$(az identity show \
     --name id-hello-cicd-deploy \
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

4. **Assign** roles — `AcrPush` for pushing images, `Contributor` for updating the container app:

   ```bash
   az role assignment create \
     --assignee $PRINCIPAL_ID \
     --role AcrPush \
     --scope $ACR_ID

   az role assignment create \
     --assignee $PRINCIPAL_ID \
     --role Contributor \
     --scope $RG_ID
   ```

5. **Configure** OIDC federation between GitHub and Azure:

   ```bash
   CLIENT_ID=$(az identity show \
     --name id-hello-cicd-deploy \
     --resource-group $RESOURCE_GROUP \
     --query clientId -o tsv)

   TENANT_ID=$(az account show --query tenantId -o tsv)
   SUBSCRIPTION_ID=$(az account show --query id -o tsv)

   REPO_FULL_NAME=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

   az identity federated-credential create \
     --name github-deploy \
     --identity-name id-hello-cicd-deploy \
     --resource-group $RESOURCE_GROUP \
     --issuer "https://token.actions.githubusercontent.com" \
     --subject "repo:${REPO_FULL_NAME}:ref:refs/heads/main" \
     --audiences "api://AzureADTokenExchange"
   ```

6. **Set** GitHub repository variables using the CLI:

   ```bash
   gh variable set AZURE_CLIENT_ID --body "$CLIENT_ID"
   gh variable set AZURE_TENANT_ID --body "$TENANT_ID"
   gh variable set AZURE_SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID"
   gh variable set ACR_NAME --body "$ACR_NAME"
   gh variable set RESOURCE_GROUP --body "$RESOURCE_GROUP"
   gh variable set CONTAINER_APP --body "$CONTAINER_APP"
   ```

7. **Verify** all variables are set:

   ```bash
   gh variable list
   ```

   You should see all six variables listed.

8. **Create** the workflow directory and file:

   ```bash
   mkdir -p .github/workflows
   ```

   > `.github/workflows/deploy.yml`

   ```yaml
   name: Build and Deploy

   on:
     push:
       branches: [main]

   permissions:
     id-token: write
     contents: read

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

         - name: Build and push to ACR
           run: |
             az acr build \
               --registry ${{ vars.ACR_NAME }} \
               --image hello-cicd:${{ github.sha }} .

         - name: Deploy to Container Apps
           run: |
             ACR_SERVER=$(az acr show --name ${{ vars.ACR_NAME }} --query loginServer -o tsv)
             az containerapp update \
               --name ${{ vars.CONTAINER_APP }} \
               --resource-group ${{ vars.RESOURCE_GROUP }} \
               --image $ACR_SERVER/hello-cicd:${{ github.sha }}

         - name: Verify deployment
           run: |
             FQDN=$(az containerapp show \
               --name ${{ vars.CONTAINER_APP }} \
               --resource-group ${{ vars.RESOURCE_GROUP }} \
               --query "properties.configuration.ingress.fqdn" -o tsv)
             for i in 1 2 3 4 5; do
               curl -sf "https://$FQDN" && exit 0
               echo "Attempt $i failed, retrying in 10s..."
               sleep 10
             done
             echo "Health check failed after 5 attempts!" && exit 1
   ```

9. **Commit** and **push** the workflow:

   ```bash
   git add -A
   git commit -m "Add GitHub Actions deployment workflow"
   git push
   ```

10. **Watch** the workflow run:

    ```bash
    gh run watch
    ```

    Wait for the workflow to complete. A successful run shows `✓` for all steps.

> ℹ **Concept Deep Dive**
>
> **OIDC federation** eliminates stored secrets entirely. The flow works like this:
>
> 1. GitHub Actions requests a JWT (JSON Web Token) from GitHub's identity provider
> 2. The workflow presents this token to Azure Active Directory
> 3. Azure verifies the token signature and checks the `subject` claim
> 4. Azure issues a short-lived access token for the managed identity
>
> The `--subject` field is critical for security. The format `repo:<owner>/<repo>:ref:refs/heads/main` means only the `main` branch of your specific repository can authenticate as this identity. A different repository — or even a different branch — cannot authenticate.
>
> The workflow uses the **full commit SHA** (`${{ github.sha }}`) as the image tag. Each build gets a unique tag like `:a1b2c3d4e5f6...` that maps to an exact git commit. This provides full traceability — you can always determine which code is running in production.
>
> **`gh repo view --json`** retrieves the repository owner and name programmatically, eliminating manual `<owner>/<repo>` substitution and the errors that come with it.
>
> ⚠ **Common Mistakes**
>
> - Forgetting the `permissions` block — OIDC login fails with "AADSTS700024" error
> - Using `secrets.` instead of `vars.` — the values were stored as variables, not secrets
> - Role assignments can take a few minutes to propagate — if the first run fails with a permissions error, wait and re-run
>
> ✓ **Quick check:** `gh run list` shows a successful workflow run

### **Step 6:** Test the Pipeline

Verify that the full CI/CD pipeline works by making a code change and watching it deploy automatically. After verifying, clean up all Azure resources.

1. **Update** the application to return a different message:

   > `app.py`

   ```python
   from flask import Flask

   app = Flask(__name__)


   @app.route('/')
   def hello():
       return 'Hello from CI/CD!'


   if __name__ == '__main__':
       app.run(debug=True)
   ```

2. **Commit** and **push** the change:

   ```bash
   git add -A
   git commit -m "Update greeting message"
   git push
   ```

3. **Watch** the automated deployment:

   ```bash
   gh run watch
   ```

4. **Verify** the change is live:

   ```bash
   source .azure-config
   FQDN=$(az containerapp show \
     --name $CONTAINER_APP \
     --resource-group $RESOURCE_GROUP \
     --query "properties.configuration.ingress.fqdn" -o tsv)
   curl -sf "https://$FQDN"
   ```

   You should see `Hello from CI/CD!` — the updated message deployed automatically.

5. **Clean up** all Azure resources when you are done:

   ```bash
   az group delete --name rg-hello-cicd --yes --no-wait
   ```

   This single command deletes the resource group and everything inside it (container registry, container app, managed identity).

6. **Optionally**, delete the GitHub repository:

   ```bash
   gh repo delete hello-cicd --yes
   ```

> ℹ **Concept Deep Dive**
>
> The complete pipeline flow is:
>
> 1. Developer pushes code to `main` branch
> 2. GitHub Actions starts the workflow
> 3. The runner authenticates with Azure using OIDC (no stored secrets)
> 4. `az acr build` builds the Docker image on Azure and tags it with the full commit SHA
> 5. Container Apps pulls the new image and restarts the container
> 6. A health check verifies the application responds
>
> The developer workflow becomes: write code, commit, push, done. The pipeline handles building, deploying, and verifying automatically.
>
> **Resource cleanup** is simple because all resources live in one resource group. The `--no-wait` flag returns immediately while Azure deletes resources in the background. Deletion typically completes within a few minutes.
>
> ✓ **Quick check:** The curl command returns `Hello from CI/CD!` and `az group show --name rg-hello-cicd` returns "not found" after cleanup completes

## Common Issues

> **If you encounter problems:**
>
> **"AADSTS700024: Client assertion is not within its valid time range":** The `permissions: id-token: write` block is missing from the workflow YAML.
>
> **"Error: federated identity credential not found":** The `--subject` in the federated credential does not match your repository. Verify with `gh repo view --json nameWithOwner` and compare against the federated credential.
>
> **`az acr build` fails with "Could not find Dockerfile":** You are running the command from the wrong directory. Navigate to the directory containing your `Dockerfile`.
>
> **Container app shows "Hello, World!" instead of "Hello from CI/CD!":** The browser may be caching. Try a hard refresh (Ctrl+Shift+R) or open in a private/incognito window.
>
> **Workflow fails at `az acr build` with permission denied:** Role assignments can take up to 10 minutes to propagate. Wait and re-run the workflow from the Actions tab.
>
> **`gh run watch` shows no runs:** The push may not have reached GitHub yet. Run `git push` again and check `gh run list`.
>
> **Still stuck?** Check the detailed workflow logs: `gh run view --log-failed` shows the output of the failing step.

## Summary

You've built a complete CI/CD pipeline from scratch:

- ✓ Created a minimal Flask application with a production Dockerfile
- ✓ Provisioned Azure Container Apps infrastructure entirely from the CLI
- ✓ Deployed manually to verify the application and infrastructure work
- ✓ Configured OIDC federation for passwordless authentication between GitHub and Azure
- ✓ Automated builds and deployments with GitHub Actions
- ✓ Verified the pipeline with a live code change

> **Key takeaway:** Modern CI/CD pipelines use identity federation (OIDC) instead of stored secrets — no passwords in GitHub, no secrets to rotate, no credentials to leak. Combined with cloud-native builds (`az acr build`), immutable commit-SHA image tags, and automated health checks, this pipeline provides a reliable, traceable, and secure deployment process.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add a `/health` endpoint to the Flask app and update the workflow health check to use it
> - Add path filters to the workflow so only application code changes trigger deployments
> - Implement rollback by deploying a previous commit SHA tag
> - Add a staging Container App that deploys on pull requests before production

## Done! 🎉

You've built a fully automated CI/CD pipeline. Push code to main and the pipeline handles the rest — build, deploy, and verify. Every deployment is traceable to an exact git commit, and no passwords are stored anywhere.
