// =============================================================================
// AZURE CONTAINER APPS ENVIRONMENT MODULE
// =============================================================================
// Creates the shared environment for Container Apps including:
// - Log Analytics Workspace (monitoring and logging)
// - Container Apps Environment (execution environment)
// =============================================================================

@description('Azure region for resources')
param location string

@description('Base name for resources (e.g., flask-dev)')
param baseName string

// -----------------------------------------------------------------------------
// Resource Names
// -----------------------------------------------------------------------------
var logAnalyticsName = 'log-${baseName}'
var containerAppsEnvName = 'cae-${baseName}'

// -----------------------------------------------------------------------------
// Log Analytics Workspace
// -----------------------------------------------------------------------------
// Required for Container Apps monitoring and logging
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'  // Pay-as-you-go pricing
    }
    retentionInDays: 30  // Minimum retention
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// -----------------------------------------------------------------------------
// Container Apps Environment
// -----------------------------------------------------------------------------
// Shared environment where Container Apps run
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: containerAppsEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false  // Not needed for learning environment
  }
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
@description('Container Apps Environment ID')
output environmentId string = containerAppsEnvironment.id

@description('Container Apps Environment name')
output environmentName string = containerAppsEnvironment.name

@description('Container Apps Environment default domain')
output defaultDomain string = containerAppsEnvironment.properties.defaultDomain

@description('Log Analytics Workspace ID')
output logAnalyticsWorkspaceId string = logAnalytics.id

@description('Log Analytics Workspace name')
output logAnalyticsWorkspaceName string = logAnalytics.name
