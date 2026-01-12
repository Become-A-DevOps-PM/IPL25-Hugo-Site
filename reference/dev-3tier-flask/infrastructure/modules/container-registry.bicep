// =============================================================================
// AZURE CONTAINER REGISTRY MODULE
// =============================================================================
// Creates an Azure Container Registry for storing Docker images.
// Uses Basic SKU for cost-effective learning environments.
// =============================================================================

@description('Azure region for resources')
param location string

@description('Base name for resources (e.g., flask-dev)')
param baseName string

@description('Enable admin user for registry authentication')
param adminUserEnabled bool = true

// -----------------------------------------------------------------------------
// Resource Names
// -----------------------------------------------------------------------------
// ACR names must be globally unique, alphanumeric only, 5-50 characters
var acrName = 'acr${replace(baseName, '-', '')}'

// -----------------------------------------------------------------------------
// Container Registry
// -----------------------------------------------------------------------------
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'  // Cost-effective for learning (~$5/month)
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: 'Enabled'
    policies: {
      retentionPolicy: {
        status: 'disabled'  // Basic SKU doesn't support retention policies
      }
    }
  }
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
@description('Container Registry login server')
output loginServer string = containerRegistry.properties.loginServer

@description('Container Registry name')
output name string = containerRegistry.name

@description('Container Registry resource ID')
output id string = containerRegistry.id

@description('Container Registry admin username (if admin enabled)')
output adminUsername string = adminUserEnabled ? containerRegistry.listCredentials().username : ''

@description('Container Registry admin password (if admin enabled)')
@secure()
output adminPassword string = adminUserEnabled ? containerRegistry.listCredentials().passwords[0].value : ''
