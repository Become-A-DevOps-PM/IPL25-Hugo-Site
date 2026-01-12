# Deploy Directory

Azure deployment and cleanup scripts.

## Scripts

| Script | Purpose | Duration |
|--------|---------|----------|
| `provision-sql.sh` | Create Azure SQL Database | ~5 min |
| `deploy.sh` | Deploy app to Container Apps | ~5-10 min |
| `delete.sh` | Remove all Azure resources | ~2 min |

## Usage

### Full Deployment (with database)

```bash
# 1. Provision database first
./deploy/provision-sql.sh

# 2. Deploy application
./deploy/deploy.sh

# 3. Run migrations in container
az containerapp exec --name starter-flask-app --resource-group rg-starter-flask
flask db upgrade
exit
```

### Quick Deployment (no database)

```bash
./deploy/deploy.sh
# App runs with graceful degradation - form shows error
```

### Cleanup

```bash
./deploy/delete.sh
# Prompts for confirmation, then deletes everything
```

## What Gets Created

| Resource | Name | Purpose |
|----------|------|---------|
| Resource Group | `rg-starter-flask` | Container for all resources |
| Container Registry | Auto-generated | Stores Docker images |
| Container Apps Environment | Auto-generated | Managed Kubernetes |
| Log Analytics | Auto-generated | Logging |
| Container App | `starter-flask-app` | Running application |
| SQL Server | `sql-starter-flask-*` | Database server (optional) |
| SQL Database | `flask` | Database (optional) |

## Configuration Files

| File | Purpose | Git |
|------|---------|-----|
| `.database-url` | Azure SQL connection string | Ignored |
| `.sql-server-name` | SQL server name for cleanup | Ignored |

These files are created by `provision-sql.sh` and used by `deploy.sh` and `delete.sh`.

## Script Details

### provision-sql.sh

1. Creates resource group (if needed)
2. Creates Azure SQL Server with random suffix
3. Configures firewall (AllowAzureServices + AllowAll for learning)
4. Creates database (Basic tier, 5 DTU, ~$5/month)
5. Saves connection string to `.database-url`

### deploy.sh

1. Checks for `.database-url` (optional)
2. Generates `SECRET_KEY`
3. Runs `az containerapp up` (builds Dockerfile, creates resources)
4. Sets environment variables (`FLASK_ENV=azure`, `DATABASE_URL`, `SECRET_KEY`)
5. Outputs application URL

### delete.sh

1. Shows what will be deleted
2. Prompts for confirmation
3. Deletes resource group (background)
4. Removes local config files

## Environment Variables Set

| Variable | Value | Purpose |
|----------|-------|---------|
| `FLASK_ENV` | `azure` | Use AzureConfig |
| `DATABASE_URL` | Connection string | Azure SQL connection |
| `SECRET_KEY` | Random 64-char hex | Session encryption |

## Cost Estimate

| Resource | Monthly |
|----------|---------|
| Container Apps | ~$5-10 |
| Container Registry | ~$5 |
| Azure SQL (optional) | ~$5 |
| **Total** | **~$15-20** |

## Troubleshooting

```bash
# View logs
az containerapp logs show --name starter-flask-app --resource-group rg-starter-flask --follow

# Check status
az containerapp show --name starter-flask-app --resource-group rg-starter-flask \
    --query "{url:properties.configuration.ingress.fqdn, status:properties.runningStatus}"

# Redeploy after changes
./deploy/deploy.sh
```
