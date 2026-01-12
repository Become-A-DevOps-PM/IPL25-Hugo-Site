// =============================================================================
// CONTAINER APPS INFRASTRUCTURE ORCHESTRATOR
// =============================================================================
// Deploys the complete Container Apps infrastructure:
// 1. Azure Container Registry (store Docker images)
// 2. Container Apps Environment (shared execution environment)
// 3. Azure SQL Database (Basic tier, always on)
// 4. Container App (Flask application) - deployed separately after image push
//
// Architecture:
//   Internet ──HTTPS──→ Container App ──→ SQL Database Basic
//                       (Flask/Gunicorn)   (Always on, ~$5/month)
//                       Auto-scale 0-N
//
// Cost Estimate: ~$5-7/month (vs ~$20 for VM-based)
//
// Usage:
//   az deployment group create \
//     --resource-group rg-flask-dev-aca \
//     --template-file main-containerapp.bicep \
//     --parameters parameters-containerapp.json
// =============================================================================

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Project name for resource naming')
param project string = 'flask'

@description('Environment name (dev, staging, prod)')
param environment string = 'dev'

@description('SQL Server administrator username')
param sqlAdminUsername string = 'sqladmin'

@description('SQL Server administrator password')
@secure()
param sqlAdminPassword string

@description('Database name')
param databaseName string = 'flask'

// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------
var baseName = '${project}-${environment}'

// -----------------------------------------------------------------------------
// Module: Container Registry
// -----------------------------------------------------------------------------
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'container-registry'
  params: {
    location: location
    baseName: baseName
    adminUserEnabled: true
  }
}

// -----------------------------------------------------------------------------
// Module: Container Apps Environment
// -----------------------------------------------------------------------------
module containerAppsEnvironment 'modules/container-apps-environment.bicep' = {
  name: 'container-apps-environment'
  params: {
    location: location
    baseName: baseName
  }
}

// -----------------------------------------------------------------------------
// Module: SQL Database
// -----------------------------------------------------------------------------
module sqlDatabase 'modules/sql-database.bicep' = {
  name: 'sql-database'
  params: {
    location: location
    baseName: baseName
    administratorLogin: sqlAdminUsername
    administratorPassword: sqlAdminPassword
    databaseName: databaseName
  }
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
// Container Registry outputs
@description('Container Registry login server')
output acrLoginServer string = containerRegistry.outputs.loginServer

@description('Container Registry name')
output acrName string = containerRegistry.outputs.name

// Container Apps Environment outputs
@description('Container Apps Environment ID (for Container App deployment)')
output containerAppsEnvironmentId string = containerAppsEnvironment.outputs.environmentId

@description('Container Apps Environment default domain')
output containerAppsDefaultDomain string = containerAppsEnvironment.outputs.defaultDomain

// SQL Database outputs
@description('SQL Server FQDN')
output sqlServerFqdn string = sqlDatabase.outputs.serverFqdn

@description('SQL Server name')
output sqlServerName string = sqlDatabase.outputs.serverName

@description('Database name')
output sqlDatabaseName string = sqlDatabase.outputs.databaseName

@description('Connection string template (add password)')
output connectionStringTemplate string = sqlDatabase.outputs.connectionStringTemplate

// -----------------------------------------------------------------------------
// Next Steps (displayed in deployment output)
// -----------------------------------------------------------------------------
// After this deployment completes:
// 1. Build and push Docker image to ACR
// 2. Deploy Container App using deploy-containerapp.sh
// 3. Create admin user
// 4. Verify deployment
