// =============================================================================
// AZURE CONTAINER APP MODULE
// =============================================================================
// Creates the Flask application Container App with:
// - External ingress (HTTPS)
// - Auto-scaling (0 to N replicas)
// - Environment variables for database connection
// - Health probes for reliability
// =============================================================================

@description('Azure region for resources')
param location string

@description('Base name for resources (e.g., flask-dev)')
param baseName string

@description('Container Apps Environment ID')
param containerAppsEnvironmentId string

@description('Container image to deploy')
param containerImage string

@description('Container Registry login server')
param containerRegistryServer string

@description('Container Registry username')
param containerRegistryUsername string

@description('Container Registry password')
@secure()
param containerRegistryPassword string

@description('Database connection string')
@secure()
param databaseUrl string

@description('Flask secret key for sessions')
@secure()
param secretKey string = newGuid()

@description('Minimum number of replicas (0 enables scale to zero)')
param minReplicas int = 0

@description('Maximum number of replicas')
param maxReplicas int = 3

@description('CPU allocation (0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0)')
param cpu string = '0.5'

@description('Memory allocation (must match CPU: 0.5->1Gi, 1.0->2Gi, etc.)')
param memory string = '1Gi'

// -----------------------------------------------------------------------------
// Resource Names
// -----------------------------------------------------------------------------
var containerAppName = 'ca-${baseName}'

// -----------------------------------------------------------------------------
// Container App
// -----------------------------------------------------------------------------
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId

    configuration: {
      // Enable external HTTPS ingress
      ingress: {
        external: true
        targetPort: 5001
        transport: 'http'
        allowInsecure: false
      }

      // Container Registry credentials
      registries: [
        {
          server: containerRegistryServer
          username: containerRegistryUsername
          passwordSecretRef: 'registry-password'
        }
      ]

      // Secrets (referenced by environment variables)
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistryPassword
        }
        {
          name: 'database-url'
          value: databaseUrl
        }
        {
          name: 'secret-key'
          value: secretKey
        }
      ]
    }

    template: {
      containers: [
        {
          name: 'flask-app'
          image: containerImage
          resources: {
            cpu: json(cpu)
            memory: memory
          }
          env: [
            {
              name: 'DATABASE_URL'
              secretRef: 'database-url'
            }
            {
              name: 'SECRET_KEY'
              secretRef: 'secret-key'
            }
            {
              name: 'FLASK_ENV'
              value: 'production'
            }
          ]
          // Health probes for reliability
          probes: [
            {
              type: 'Readiness'
              httpGet: {
                path: '/api/health'
                port: 5001
              }
              initialDelaySeconds: 10
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 3
            }
            {
              type: 'Liveness'
              httpGet: {
                path: '/api/health'
                port: 5001
              }
              initialDelaySeconds: 30
              periodSeconds: 30
              timeoutSeconds: 5
              failureThreshold: 3
            }
          ]
        }
      ]

      // Auto-scaling configuration
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: [
          {
            name: 'http-scaling'
            http: {
              metadata: {
                concurrentRequests: '10'  // Scale up when >10 concurrent requests
              }
            }
          }
        ]
      }
    }
  }
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
@description('Container App FQDN (publicly accessible URL)')
output fqdn string = containerApp.properties.configuration.ingress.fqdn

@description('Container App name')
output name string = containerApp.name

@description('Container App resource ID')
output id string = containerApp.id

@description('Container App latest revision name')
output latestRevisionName string = containerApp.properties.latestRevisionName

@description('Application URL')
output applicationUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
