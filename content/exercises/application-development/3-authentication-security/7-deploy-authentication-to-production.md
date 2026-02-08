+++
title = "Deploy Authentication to Production"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Wire the admin CLI command into the container startup, configure admin credentials as Azure secrets, and verify authentication works on the live site"
weight = 7
+++

# Deploy Authentication to Production

## Goal

Deploy your authenticated News Flash application to Azure Container Apps with automatic admin user creation at container startup. Configure admin credentials as Azure secrets so the first admin user is seeded securely and idempotently every time the container starts.

> **What you'll learn:**
>
> - Why containerized applications need startup-time seeding for the first admin user
> - How to wire a CLI command into the container entrypoint for idempotent admin creation
> - How Azure Container Apps secrets differ from plain environment variables
> - How to verify authentication works end-to-end on a live production deployment

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Flask application with authentication, Flask-Login, and the `flask create-admin` CLI command
> - ✓ The `create-admin` command is idempotent (exits successfully when the user already exists)
> - ✓ Azure infrastructure provisioned (resource group, ACR, Container Apps, Azure SQL)
> - ✓ CI/CD pipeline deploying to Azure Container Apps on push to main
> - ✓ `.azure-config` file with all resource names
> - ✓ Azure CLI authenticated (`az login`)

## Exercise Steps

### Overview

1. **Update the Container Entrypoint**
2. **Add Admin Credentials as Azure Secrets**
3. **Deploy and Verify Admin Login**
4. **Verify Idempotent Startup**

### **Step 1:** Update the Container Entrypoint

Your container starts by running `entrypoint.sh`, which currently runs database migrations and then starts Gunicorn. The authentication system is deployed with the code, and migrations create the User table automatically — but no admin user exists in the production database. You cannot run `flask create-admin` manually because Azure Container Apps does not provide shell access to running containers. The solution is to run the command automatically at every container startup, right after migrations and before the application server starts.

1. **Open** the file `entrypoint.sh` in your application directory

2. **Replace** the contents with the following:

   > `application/entrypoint.sh`

   ```bash
   #!/bin/bash
   set -e

   echo "Running database migrations..."
   flask db upgrade

   echo "Seeding admin user..."
   flask create-admin "$ADMIN_USERNAME" -p "$ADMIN_PASSWORD"

   echo "Starting application..."
   exec gunicorn --bind 0.0.0.0:5000 --workers 2 --timeout 120 wsgi:app
   ```

> ℹ **Concept Deep Dive**
>
> The `entrypoint.sh` script now has three phases that run in sequence before the application serves any traffic:
>
> 1. **Migrations** — `flask db upgrade` applies any pending database schema changes. Alembic tracks which migrations have already been applied, so this is idempotent (safe to run repeatedly).
> 2. **Admin seeding** — `flask create-admin` creates the admin user from environment variables. If the admin already exists, the command prints "already exists — skipping" and exits with code 0. This is idempotent by design — you built this behavior in the previous exercise.
> 3. **Application server** — `exec gunicorn` replaces the shell process with Gunicorn, which becomes PID 1 and receives container lifecycle signals correctly.
>
> The `set -e` flag is critical here. It means "exit immediately if any command fails." If migrations fail (database unreachable), the container stops instead of starting an application against an outdated schema. If the admin seeding fails (password too short, missing environment variable), the container stops instead of running without an admin user. Only genuine errors cause failure — the idempotent "already exists" case exits with code 0, so `set -e` does not trigger.
>
> The `ADMIN_USERNAME` and `ADMIN_PASSWORD` variables come from the container's environment, which you will configure as Azure secrets in the next step. They are never stored in code, the Docker image, or the Git repository.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `set -e` means the container starts even if migrations or admin seeding fail
> - Using `|| true` after the `flask create-admin` command would suppress genuine errors (bad password, missing database) — the idempotent CLI design makes this unnecessary
> - Placing the admin seeding after `exec gunicorn` means it never runs — `exec` replaces the shell process
>
> ✓ **Quick check:** `entrypoint.sh` contains three commands in order: `flask db upgrade`, `flask create-admin`, `exec gunicorn`

### **Step 2:** Add Admin Credentials as Azure Secrets

Azure Container Apps supports two types of environment variable values: plain text and secret references. Plain text values are visible to anyone who can view the container configuration. Secret references store the value in Azure's encrypted secret store and inject it at runtime — the value is never visible in the container configuration, deployment logs, or Azure Portal overview.

Your existing deployment already uses plain environment variables for `FLASK_ENV`, `SECRET_KEY`, and `DATABASE_URL`. For admin credentials, you will use the more secure secret reference approach.

1. **Source** your configuration file:

   ```bash
   source .azure-config
   ```

2. **Choose** a strong admin password (minimum 8 characters):

   ```bash
   ADMIN_USERNAME="admin"
   ADMIN_PASSWORD="$(openssl rand -base64 12)"
   echo "Admin password: $ADMIN_PASSWORD"
   ```

   **Save this password immediately.** You will need it to log in to your application.

3. **Save** the admin credentials to `.azure-config`:

   ```bash
   cat >> .azure-config << EOF
   ADMIN_USERNAME="$ADMIN_USERNAME"
   ADMIN_PASSWORD="$ADMIN_PASSWORD"
   EOF
   ```

4. **Create** the secrets in Azure Container Apps:

   ```bash
   az containerapp secret set \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --secrets \
       admin-username="$ADMIN_USERNAME" \
       admin-password="$ADMIN_PASSWORD"
   ```

   > **Note:** Secret names in Azure Container Apps use lowercase letters, numbers, and hyphens only. The name `admin-password` becomes the reference key for the environment variable.

5. **Set** the environment variables to reference the secrets:

   ```bash
   az containerapp update \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --set-env-vars \
       "ADMIN_USERNAME=secretref:admin-username" \
       "ADMIN_PASSWORD=secretref:admin-password"
   ```

6. **Verify** the secrets and environment variables are configured:

   ```bash
   az containerapp show \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --query "properties.template.containers[0].env[].{name:name, source:secretRef}" \
     -o table
   ```

   You should see `ADMIN_USERNAME` and `ADMIN_PASSWORD` in the list with secret references (not plain values).

> ℹ **Concept Deep Dive**
>
> The `az containerapp secret set` command stores values in Azure's encrypted secret store. The `az containerapp update --set-env-vars "ADMIN_PASSWORD=secretref:admin-password"` command tells the container to read the `ADMIN_PASSWORD` environment variable from the secret named `admin-password` at startup.
>
> This two-step approach (create secret, then reference it) provides several security benefits:
>
> - **Secrets are encrypted at rest** in Azure's secret store, not stored as plain text in the container configuration
> - **Secrets are not visible** in deployment logs, `az containerapp show` output, or the Azure Portal overview
> - **Secrets can be rotated** by updating the secret value without changing the container configuration or triggering a redeployment
> - **Secrets follow the principle of least privilege** — only the running container can read the value
>
> Compare this with the plain `--set-env-vars "SECRET_KEY=$SECRET_KEY"` approach used earlier for `SECRET_KEY` and `DATABASE_URL`. Those values are visible in the container configuration. For a learning environment this is acceptable, but for credentials that grant access (like admin passwords), secret references are the correct approach.
>
> ⚠ **Common Mistakes**
>
> - Using uppercase or underscores in secret names — Azure Container Apps secret names only allow lowercase letters, numbers, and hyphens
> - Forgetting the `secretref:` prefix — without it, the literal string "admin-password" is used as the value instead of referencing the secret
> - Setting secrets after updating env vars — the secret must exist before it can be referenced
>
> ✓ **Quick check:** `az containerapp secret list --name $CA_NAME --resource-group $RESOURCE_GROUP -o table` shows both `admin-username` and `admin-password`

### **Step 3:** Deploy and Verify Admin Login

With the entrypoint updated and secrets configured, push your changes to trigger the CI/CD pipeline. The pipeline builds the new image (containing the updated `entrypoint.sh`), deploys it to Container Apps, and the container starts with the new startup sequence: migrations, admin seeding, then Gunicorn.

1. **Commit** and **push** the updated entrypoint:

   ```bash
   git add application/entrypoint.sh
   git commit -m "Add admin seeding to container startup"
   git push
   ```

2. **Watch** the GitHub Actions workflow in your repository's Actions tab. Wait for the green checkmark.

3. **Check** the container logs to verify the admin seeding ran:

   ```bash
   source .azure-config
   az containerapp logs show \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --tail 20
   ```

   You should see output like:

   ```text
   Running database migrations...
   INFO  [alembic.runtime.migration] Context impl MSSQLImpl.
   INFO  [alembic.runtime.migration] Will assume transactional DDL.
   Seeding admin user...
   Admin user 'admin' created successfully.
   Starting application...
   [INFO] Starting gunicorn 22.0.0
   ```

4. **Get** your application URL:

   ```bash
   az containerapp show \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --query "properties.configuration.ingress.fqdn" \
     -o tsv
   ```

5. **Navigate** to `https://<your-app-url>/auth/login` in your browser

6. **Log in** with the admin credentials you created in Step 2

7. **Verify** you can access the admin dashboard at `https://<your-app-url>/admin/subscribers`

> ℹ **Concept Deep Dive**
>
> The deployment flow for this change is:
>
> 1. You push code containing the updated `entrypoint.sh`
> 2. GitHub Actions builds a new Docker image (the entrypoint is baked into the image)
> 3. Container Apps pulls the new image and creates a new revision
> 4. The new container starts and runs `entrypoint.sh`
> 5. Migrations run (no-op if already applied)
> 6. Admin seeding runs (creates user on first deploy, skips on subsequent deploys)
> 7. Gunicorn starts serving traffic
>
> The admin credentials (stored as Azure secrets) are injected as environment variables when the container starts. They never appear in the Docker image, Git history, or CI/CD logs. The `entrypoint.sh` script reads them via `$ADMIN_USERNAME` and `$ADMIN_PASSWORD` — standard Unix environment variable expansion.
>
> ✓ **Quick check:** You can log in to the production site with the admin credentials and see the subscriber dashboard

### **Step 4:** Verify Idempotent Startup

The final verification confirms that the idempotent design works in production. When the container restarts (due to scaling, updates, or Azure maintenance), the admin seeding should detect the existing user and continue without errors.

1. **Restart** the container to simulate a new deployment:

   ```bash
   source .azure-config
   az containerapp revision restart \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --revision $(az containerapp show \
       --name $CA_NAME \
       --resource-group $RESOURCE_GROUP \
       --query "properties.latestRevisionName" -o tsv)
   ```

2. **Wait** 30 seconds for the container to restart, then **check** the logs:

   ```bash
   sleep 30
   az containerapp logs show \
     --name $CA_NAME \
     --resource-group $RESOURCE_GROUP \
     --tail 20
   ```

   You should see:

   ```text
   Running database migrations...
   INFO  [alembic.runtime.migration] Will assume transactional DDL.
   Seeding admin user...
   Admin user 'admin' already exists — skipping.
   Starting application...
   [INFO] Starting gunicorn 22.0.0
   ```

3. **Log in** again to verify the admin account still works after the restart

> ℹ **Concept Deep Dive**
>
> Idempotency means "running the same operation multiple times produces the same result as running it once." Both phases of the startup script are idempotent:
>
> - `flask db upgrade` checks which migrations have been applied and skips them
> - `flask create-admin` checks if the user exists and skips if so
>
> This is essential for containerized applications because containers restart frequently — during deployments, scaling events, health check failures, and Azure platform maintenance. A startup script that fails on the second run would cause cascading restart loops (the container crashes, restarts, crashes again).
>
> The alternative approach of using `|| true` after the command (`flask create-admin ... || true`) would also prevent startup failures, but it masks genuine errors. If the database is unreachable, `|| true` would silently swallow the error and start the application server against an empty database. The idempotent CLI design you built is superior because it only succeeds when the operation is genuinely safe — creating a new user or confirming one already exists.
>
> ✓ **Quick check:** Container logs show "already exists — skipping" on restart, and the admin account still works

> ✓ **Success indicators:**
>
> - `entrypoint.sh` runs migrations, seeds admin, then starts Gunicorn
> - Admin credentials stored as Azure Container Apps secrets (not plain environment variables)
> - CI/CD pipeline deploys successfully with the updated entrypoint
> - Container logs show "Admin user 'admin' created successfully" on first deploy
> - Admin can log in to the production site and access the subscriber dashboard
> - Container restart shows "already exists — skipping" (idempotent)
> - Admin account works after restart without re-creation
>
> ✓ **Final verification checklist:**
>
> - [ ] `entrypoint.sh` updated with `flask create-admin` between migrations and Gunicorn
> - [ ] Azure secrets created for `admin-username` and `admin-password`
> - [ ] Environment variables `ADMIN_USERNAME` and `ADMIN_PASSWORD` reference secrets
> - [ ] Changes pushed and CI/CD pipeline completed successfully
> - [ ] Container logs show admin seeding output
> - [ ] Admin login works on the production site
> - [ ] Container restart does not fail or duplicate the admin user
> - [ ] Admin credentials saved in `.azure-config` for reference

## Common Issues

> **If you encounter problems:**
>
> **Container fails to start after push:** Check the container logs with `az containerapp logs show`. If you see "Error: No such command 'create-admin'", verify that the CLI command is registered in `app/__init__.py` with `app.cli.add_command()`.
>
> **"Error: Password must be at least 8 characters long":** The `ADMIN_PASSWORD` environment variable is either missing or too short. Verify the secret exists with `az containerapp secret list` and that the env var references it with `secretref:`.
>
> **Admin seeding line missing from logs:** Ensure `entrypoint.sh` contains the `flask create-admin` line. Rebuild and redeploy — the entrypoint is baked into the Docker image, so code changes require a new image.
>
> **"ADMIN_USERNAME: unbound variable":** The environment variable is not set on the container. Run `az containerapp show --query "properties.template.containers[0].env"` to verify both `ADMIN_USERNAME` and `ADMIN_PASSWORD` are listed.
>
> **Login fails with correct password:** Check that the `ADMIN_PASSWORD` in `.azure-config` matches the secret you created. If you regenerated the password, update the Azure secret with `az containerapp secret set`.
>
> **Secret name rejected:** Azure Container Apps secret names only allow lowercase letters, numbers, and hyphens. Use `admin-password`, not `ADMIN_PASSWORD` or `admin_password`.
>
> **Still stuck?** Verify each layer independently: (1) `az containerapp secret list` shows both secrets, (2) `az containerapp show --query "properties.template.containers[0].env"` shows both env vars with secret references, (3) container logs show the seeding output.

## Summary

You've successfully deployed authentication to production:

- ✓ Updated the container entrypoint to seed the admin user at every startup
- ✓ Configured admin credentials as Azure Container Apps secrets
- ✓ Verified the admin can log in to the production site
- ✓ Confirmed idempotent behavior on container restart

> **Key takeaway:** Containerized applications cannot rely on manual setup steps — everything must be automated in the startup script. The combination of idempotent CLI commands and environment-variable-driven configuration means the container is self-sufficient: it applies its own migrations, creates its own admin user, and starts serving traffic without human intervention. Credentials live in Azure's secret store, not in code or Docker images. This pattern scales to any number of containers and survives any number of restarts.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Migrate `DATABASE_URL` and `SECRET_KEY` from plain env vars to secret references for consistent security
> - Add a `/api/health` endpoint that checks database connectivity and returns the application version
> - Implement admin password rotation by updating the Azure secret and restarting the container
> - Research Azure Key Vault integration for centralized secret management across multiple applications

## Done! 🎉

You have completed the Authentication and Security exercise series. Your News Flash application is fully deployed with authentication, admin user seeding, security headers, and protected routes — all running on Azure Container Apps with credentials managed securely through Azure's secret store.
