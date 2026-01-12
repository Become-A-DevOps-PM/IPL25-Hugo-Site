# CI/CD Pipeline: Dev Three-Tier Flask

## Goal

Automate the deployment of dev-3tier-flask using GitHub Actions, transforming the manual runbook steps into a repeatable, automated pipeline.

> **What this document covers:**
>
> - Setting up GitHub Secrets for secure credential management
> - Creating a GitHub Actions workflow for automated deployment
> - Mapping runbook steps to pipeline jobs
> - Manual triggers and environment management
> - Rollback and recovery strategies

## Prerequisites

> **Before implementing CI/CD, ensure you have:**
>
> - Completed the manual deployment using the Operations Runbook at least once
> - GitHub repository with Actions enabled
> - Azure service principal with Contributor access
> - Understanding of GitHub Actions basics

## Pipeline Architecture

The CI/CD pipeline automates the 6 steps from the Operations Runbook:

```
GitHub Actions Workflow
│
├── Job 1: provision-infrastructure
│   ├── Create resource group
│   └── Deploy Bicep templates
│
├── Job 2: wait-for-infrastructure
│   ├── Poll PostgreSQL until Ready
│   └── Poll VM cloud-init completion
│
├── Job 3: deploy-application
│   ├── SCP application files
│   ├── Configure DATABASE_URL
│   └── Start flask-app service
│
├── Job 4: create-admin-user
│   └── Run flask create-admin command
│
└── Job 5: verify-deployment
    └── Run verification tests
```

> **Trigger Options:**
>
> - `workflow_dispatch` - Manual trigger with optional parameters
> - `push` to `main` - Automatic deployment on merge (optional)
> - `schedule` - Scheduled deployments (e.g., nightly rebuilds)

## GitHub Secrets Configuration

### Required Secrets

Create these secrets in your GitHub repository settings under **Settings → Secrets and variables → Actions**.

| Secret Name | Description | How to Obtain |
|-------------|-------------|---------------|
| `AZURE_CREDENTIALS` | Azure service principal JSON | See Step 1 below |
| `SSH_PRIVATE_KEY` | SSH private key for VM access | `cat ~/.ssh/id_rsa` |
| `DB_ADMIN_PASSWORD` | PostgreSQL admin password | Generate or use existing |

### Step 1: Create Azure Service Principal

1. **Create the service principal:**

   ```bash
   az ad sp create-for-rbac \
     --name "github-actions-flask-deploy" \
     --role contributor \
     --scopes /subscriptions/$(az account show --query id -o tsv) \
     --json-auth
   ```

2. **Copy the JSON output** - it looks like:

   ```json
   {
     "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
     "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
     "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   }
   ```

3. **Add to GitHub Secrets** as `AZURE_CREDENTIALS`

### Step 2: Add SSH Private Key

1. **Copy your SSH private key:**

   ```bash
   cat ~/.ssh/id_rsa
   ```

2. **Add the entire key** (including `-----BEGIN` and `-----END-----` lines) to GitHub Secrets as `SSH_PRIVATE_KEY`

### Step 3: Add Database Password

1. **Generate a secure password** or use the existing one from `parameters.json`:

   ```bash
   jq -r '.parameters.dbAdminPassword.value' infrastructure/parameters.json
   ```

2. **Add to GitHub Secrets** as `DB_ADMIN_PASSWORD`

## GitHub Actions Workflow

Create the workflow file at `.github/workflows/deploy.yml`:

```yaml
name: Deploy Flask Application

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'dev'
        type: choice
        options:
          - dev
          - staging
      action:
        description: 'Action to perform'
        required: true
        default: 'deploy'
        type: choice
        options:
          - deploy
          - destroy
      create_admin:
        description: 'Create admin user'
        required: false
        default: 'true'
        type: boolean

env:
  PROJECT: flask
  ENVIRONMENT: ${{ github.event.inputs.environment || 'dev' }}
  LOCATION: swedencentral
  DB_ADMIN_USER: adminuser
  VM_ADMIN_USER: azureuser

jobs:
  # ==========================================================================
  # Job 1: Provision Azure Infrastructure
  # ==========================================================================
  provision-infrastructure:
    name: Provision Infrastructure
    runs-on: ubuntu-latest
    if: ${{ github.event.inputs.action != 'destroy' }}
    outputs:
      vm_ip: ${{ steps.get-outputs.outputs.vm_ip }}
      postgres_fqdn: ${{ steps.get-outputs.outputs.postgres_fqdn }}

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Set resource names
        id: names
        run: |
          echo "RESOURCE_GROUP=rg-${{ env.PROJECT }}-${{ env.ENVIRONMENT }}" >> $GITHUB_OUTPUT
          echo "POSTGRES_SERVER=psql-${{ env.PROJECT }}-${{ env.ENVIRONMENT }}" >> $GITHUB_OUTPUT

      - name: Create Resource Group
        run: |
          az group create \
            --name ${{ steps.names.outputs.RESOURCE_GROUP }} \
            --location ${{ env.LOCATION }} \
            --output none

      - name: Generate parameters.json
        run: |
          cat > reference/dev-3tier-flask/infrastructure/parameters.json << EOF
          {
            "parameters": {
              "dbAdminUsername": { "value": "${{ env.DB_ADMIN_USER }}" },
              "dbAdminPassword": { "value": "${{ secrets.DB_ADMIN_PASSWORD }}" }
            }
          }
          EOF

      - name: Deploy Bicep Templates
        run: |
          az deployment group create \
            --resource-group ${{ steps.names.outputs.RESOURCE_GROUP }} \
            --template-file reference/dev-3tier-flask/infrastructure/main.bicep \
            --parameters reference/dev-3tier-flask/infrastructure/parameters.json \
            --parameters sshPublicKey="${{ secrets.SSH_PUBLIC_KEY || '' }}" \
            --output none

      - name: Get Deployment Outputs
        id: get-outputs
        run: |
          VM_IP=$(az vm show \
            -g ${{ steps.names.outputs.RESOURCE_GROUP }} \
            -n vm-app \
            --show-details \
            -o tsv \
            --query publicIps)

          POSTGRES_FQDN=$(az postgres flexible-server show \
            -g ${{ steps.names.outputs.RESOURCE_GROUP }} \
            -n ${{ steps.names.outputs.POSTGRES_SERVER }} \
            --query fullyQualifiedDomainName \
            -o tsv)

          echo "vm_ip=$VM_IP" >> $GITHUB_OUTPUT
          echo "postgres_fqdn=$POSTGRES_FQDN" >> $GITHUB_OUTPUT
          echo "VM IP: $VM_IP"
          echo "PostgreSQL: $POSTGRES_FQDN"

  # ==========================================================================
  # Job 2: Wait for Infrastructure
  # ==========================================================================
  wait-for-infrastructure:
    name: Wait for Infrastructure
    runs-on: ubuntu-latest
    needs: provision-infrastructure
    if: ${{ github.event.inputs.action != 'destroy' }}

    steps:
      - name: Azure Login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Wait for PostgreSQL
        run: |
          RESOURCE_GROUP="rg-${{ env.PROJECT }}-${{ env.ENVIRONMENT }}"
          POSTGRES_SERVER="psql-${{ env.PROJECT }}-${{ env.ENVIRONMENT }}"

          echo "Waiting for PostgreSQL to be ready..."
          for i in {1..40}; do
            STATE=$(az postgres flexible-server show \
              -g $RESOURCE_GROUP \
              -n $POSTGRES_SERVER \
              --query state -o tsv 2>/dev/null || echo "Provisioning")

            echo "Attempt $i/40: PostgreSQL state = $STATE"

            if [ "$STATE" = "Ready" ]; then
              echo "PostgreSQL is ready!"
              exit 0
            fi

            sleep 30
          done

          echo "ERROR: PostgreSQL did not become ready in time"
          exit 1

      - name: Wait for Cloud-init
        run: |
          VM_IP="${{ needs.provision-infrastructure.outputs.vm_ip }}"

          echo "Waiting for cloud-init to complete..."
          for i in {1..30}; do
            # SSH with timeout and check for cloud-init marker
            if ssh -o ConnectTimeout=10 \
                   -o StrictHostKeyChecking=no \
                   -o UserKnownHostsFile=/dev/null \
                   -o LogLevel=ERROR \
                   ${{ env.VM_ADMIN_USER }}@$VM_IP \
                   "test -f /var/lib/cloud/instance/cloud-init-complete" 2>/dev/null; then
              echo "Cloud-init complete!"
              exit 0
            fi

            echo "Attempt $i/30: Cloud-init still running..."
            sleep 10
          done

          echo "ERROR: Cloud-init did not complete in time"
          exit 1
        env:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}

  # ==========================================================================
  # Job 3: Deploy Application
  # ==========================================================================
  deploy-application:
    name: Deploy Application
    runs-on: ubuntu-latest
    needs: [provision-infrastructure, wait-for-infrastructure]
    if: ${{ github.event.inputs.action != 'destroy' }}

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup SSH Key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa

      - name: Set variables
        id: vars
        run: |
          VM_IP="${{ needs.provision-infrastructure.outputs.vm_ip }}"
          POSTGRES_HOST="psql-${{ env.PROJECT }}-${{ env.ENVIRONMENT }}.postgres.database.azure.com"
          DATABASE_URL="postgresql://${{ env.DB_ADMIN_USER }}:${{ secrets.DB_ADMIN_PASSWORD }}@${POSTGRES_HOST}:5432/flask?sslmode=require"

          echo "vm_ip=$VM_IP" >> $GITHUB_OUTPUT
          echo "database_url=$DATABASE_URL" >> $GITHUB_OUTPUT

      - name: Copy Application Files
        run: |
          VM_IP="${{ steps.vars.outputs.vm_ip }}"
          SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

          echo "Copying application files..."
          scp -r $SSH_OPTS \
            reference/dev-3tier-flask/application/* \
            ${{ env.VM_ADMIN_USER }}@${VM_IP}:/opt/flask-app/

      - name: Configure and Start Application
        run: |
          VM_IP="${{ steps.vars.outputs.vm_ip }}"
          DATABASE_URL="${{ steps.vars.outputs.database_url }}"
          SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

          ssh $SSH_OPTS ${{ env.VM_ADMIN_USER }}@${VM_IP} << 'REMOTE_SCRIPT'
          set -e

          # Fix permissions
          sudo chown -R azureuser:flask-app /opt/flask-app
          sudo chmod -R 750 /opt/flask-app

          # Install dependencies
          /opt/flask-app/venv/bin/pip install -q -r /opt/flask-app/requirements.txt

          # Configure database connection
          echo "DATABASE_URL=$DATABASE_URL" | sudo tee /etc/flask-app/app.env > /dev/null
          echo "FLASK_ENV=production" | sudo tee -a /etc/flask-app/app.env > /dev/null
          sudo chmod 640 /etc/flask-app/app.env
          sudo chown root:flask-app /etc/flask-app/app.env

          # Initialize database
          cd /opt/flask-app
          source venv/bin/activate
          eval $(sudo cat /etc/flask-app/app.env)
          python3 -c 'from app import create_app; from app.extensions import db; app=create_app(); ctx=app.app_context(); ctx.push(); db.create_all(); print("Database initialized")'

          # Start service
          sudo systemctl enable flask-app
          sudo systemctl restart flask-app

          echo "Application deployed successfully"
          REMOTE_SCRIPT
        env:
          DATABASE_URL: ${{ steps.vars.outputs.database_url }}

  # ==========================================================================
  # Job 4: Create Admin User
  # ==========================================================================
  create-admin-user:
    name: Create Admin User
    runs-on: ubuntu-latest
    needs: [provision-infrastructure, deploy-application]
    if: ${{ github.event.inputs.action != 'destroy' && github.event.inputs.create_admin == 'true' }}

    steps:
      - name: Setup SSH Key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa

      - name: Create Admin User
        run: |
          VM_IP="${{ needs.provision-infrastructure.outputs.vm_ip }}"
          SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

          # Check if admin user already exists
          EXISTS=$(ssh $SSH_OPTS ${{ env.VM_ADMIN_USER }}@${VM_IP} << 'CHECK_SCRIPT'
          cd /opt/flask-app
          source venv/bin/activate
          eval $(sudo cat /etc/flask-app/app.env)
          python3 -c "from app import create_app; from app.models import User; app=create_app(); ctx=app.app_context(); ctx.push(); print('exists' if User.query.filter_by(username='admin').first() else 'missing')"
          CHECK_SCRIPT
          )

          if [ "$EXISTS" = "exists" ]; then
            echo "Admin user already exists, skipping creation"
            exit 0
          fi

          # Create admin user with generated password
          ADMIN_PASSWORD=$(openssl rand -base64 16)

          ssh $SSH_OPTS ${{ env.VM_ADMIN_USER }}@${VM_IP} << REMOTE_SCRIPT
          cd /opt/flask-app
          source venv/bin/activate
          eval \$(sudo cat /etc/flask-app/app.env)
          python3 << PYTHON_SCRIPT
          from app import create_app
          from app.services.auth_service import AuthService

          app = create_app()
          with app.app_context():
              user = AuthService.create_user('admin', '$ADMIN_PASSWORD')
              if user:
                  print('Admin user created successfully')
              else:
                  print('Failed to create admin user')
          PYTHON_SCRIPT
          REMOTE_SCRIPT

          echo "::notice::Admin user created with password: $ADMIN_PASSWORD"
          echo "::warning::Save this password securely - it will not be shown again"

  # ==========================================================================
  # Job 5: Verify Deployment
  # ==========================================================================
  verify-deployment:
    name: Verify Deployment
    runs-on: ubuntu-latest
    needs: [provision-infrastructure, deploy-application]
    if: ${{ github.event.inputs.action != 'destroy' }}

    steps:
      - name: Wait for Application
        run: |
          VM_IP="${{ needs.provision-infrastructure.outputs.vm_ip }}"

          echo "Waiting for Flask application to respond..."
          for i in {1..30}; do
            RESPONSE=$(curl -sk "https://${VM_IP}/api/health" 2>/dev/null | jq -r '.status' 2>/dev/null || echo "not_ready")

            if [ "$RESPONSE" = "ok" ]; then
              echo "Application is healthy!"
              break
            fi

            echo "Attempt $i/30: Application not ready yet..."
            sleep 10
          done

      - name: Run Verification Tests
        run: |
          VM_IP="${{ needs.provision-infrastructure.outputs.vm_ip }}"
          PASS=0
          FAIL=0

          echo "Running verification tests..."
          echo ""

          # Test 1: Health endpoint
          if curl -sk "https://${VM_IP}/api/health" | jq -e '.status == "ok"' > /dev/null 2>&1; then
            echo "✅ Health endpoint: PASS"
            PASS=$((PASS + 1))
          else
            echo "❌ Health endpoint: FAIL"
            FAIL=$((FAIL + 1))
          fi

          # Test 2: Landing page
          if curl -sk "https://${VM_IP}/" | grep -qi "flask\|welcome\|landing"; then
            echo "✅ Landing page: PASS"
            PASS=$((PASS + 1))
          else
            echo "❌ Landing page: FAIL"
            FAIL=$((FAIL + 1))
          fi

          # Test 3: Demo page
          if curl -sk "https://${VM_IP}/demo" | grep -qi "demo\|entry\|form"; then
            echo "✅ Demo page: PASS"
            PASS=$((PASS + 1))
          else
            echo "❌ Demo page: FAIL"
            FAIL=$((FAIL + 1))
          fi

          # Test 4: API entries
          if curl -sk "https://${VM_IP}/api/entries" | jq -e 'type == "array"' > /dev/null 2>&1; then
            echo "✅ API entries: PASS"
            PASS=$((PASS + 1))
          else
            echo "❌ API entries: FAIL"
            FAIL=$((FAIL + 1))
          fi

          echo ""
          echo "Results: $PASS passed, $FAIL failed"

          if [ $FAIL -gt 0 ]; then
            echo "::error::Verification tests failed"
            exit 1
          fi

      - name: Deployment Summary
        run: |
          VM_IP="${{ needs.provision-infrastructure.outputs.vm_ip }}"
          echo "## Deployment Complete! 🚀" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "| Resource | Value |" >> $GITHUB_STEP_SUMMARY
          echo "|----------|-------|" >> $GITHUB_STEP_SUMMARY
          echo "| Application URL | https://${VM_IP}/ |" >> $GITHUB_STEP_SUMMARY
          echo "| Health Check | https://${VM_IP}/api/health |" >> $GITHUB_STEP_SUMMARY
          echo "| Admin Login | https://${VM_IP}/auth/login |" >> $GITHUB_STEP_SUMMARY
          echo "| SSH Access | \`ssh azureuser@${VM_IP}\` |" >> $GITHUB_STEP_SUMMARY

  # ==========================================================================
  # Job: Destroy Infrastructure (Optional)
  # ==========================================================================
  destroy-infrastructure:
    name: Destroy Infrastructure
    runs-on: ubuntu-latest
    if: ${{ github.event.inputs.action == 'destroy' }}

    steps:
      - name: Azure Login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Delete Resource Group
        run: |
          RESOURCE_GROUP="rg-${{ env.PROJECT }}-${{ env.ENVIRONMENT }}"

          echo "Deleting resource group: $RESOURCE_GROUP"
          az group delete \
            --name $RESOURCE_GROUP \
            --yes \
            --no-wait

          echo "Resource group deletion initiated"
```

## Workflow Triggers

### Manual Deployment

Navigate to **Actions → Deploy Flask Application → Run workflow**:

- **Environment:** `dev` or `staging`
- **Action:** `deploy` or `destroy`
- **Create admin:** `true` or `false`

### Automatic Deployment (Optional)

Add to the `on:` section in the workflow:

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'reference/dev-3tier-flask/application/**'
      - 'reference/dev-3tier-flask/infrastructure/**'
```

### Scheduled Deployments (Optional)

Add for nightly rebuilds:

```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily
```

## Runbook to Pipeline Mapping

| Runbook Step | Pipeline Job | Notes |
|--------------|--------------|-------|
| Step 1: Prepare Environment | (Runner has tools) | GitHub runners have az CLI pre-installed |
| Step 2: Configure Secrets | provision-infrastructure | Secrets from GitHub Secrets |
| Step 3: Provision Infrastructure | provision-infrastructure | Bicep deployment |
| Step 4: Deploy Application | deploy-application | SCP + configure + start |
| Step 5: Create Admin User | create-admin-user | Auto-generates password |
| Step 6: Verify Deployment | verify-deployment | Runs 4 HTTP tests |

## Rollback Strategy

### Failed Deployment Recovery

If a deployment fails:

1. **Check the failed job logs** in GitHub Actions
2. **SSH to VM** for debugging:

   ```bash
   az vm show -g rg-flask-dev -n vm-app --show-details -o tsv --query publicIps
   ssh azureuser@<IP>
   ```

3. **Re-run the workflow** after fixing issues
4. **Or destroy and redeploy:**
   - Run workflow with action: `destroy`
   - Wait for deletion
   - Run workflow with action: `deploy`

### Application Rollback

For application-level rollback:

1. **Revert the commit** in Git
2. **Push to main** (if auto-deploy enabled) or trigger manual deploy
3. The pipeline will deploy the previous version

## Security Considerations

> **Best Practices:**
>
> - Rotate `DB_ADMIN_PASSWORD` periodically
> - Use separate service principals per environment
> - Consider Azure Key Vault for production secrets
> - Enable branch protection on `main`
> - Require approval for destroy actions
>
> **Never Do:**
>
> - Store secrets in workflow files
> - Echo secrets in logs
> - Use the same credentials for prod and dev

## Monitoring and Observability

After deployment, monitor using:

1. **GitHub Actions:** Workflow run history and logs
2. **Azure Portal:** VM metrics, PostgreSQL metrics
3. **Application logs:**

   ```bash
   ssh azureuser@<VM_IP> "sudo journalctl -u flask-app -f"
   ```

4. **Health endpoint:** Poll `https://<VM_IP>/api/health`

## Summary

The CI/CD pipeline automates the complete deployment process:

- **Infrastructure provisioning** with Bicep templates
- **Application deployment** via SSH/SCP
- **Admin user creation** with auto-generated passwords
- **Verification testing** before marking success
- **Cleanup capability** for resource destruction

> **Key Benefits:**
>
> - Repeatable deployments
> - Version-controlled infrastructure
> - Audit trail in GitHub Actions
> - Reduced manual errors
> - Quick environment recreation
