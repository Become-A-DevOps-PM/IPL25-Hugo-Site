// =============================================================================
// AZURE SQL DATABASE MODULE
// =============================================================================
// Creates Azure SQL Database resources:
// - SQL Server (logical server)
// - SQL Database (Basic tier for cost-effective learning)
// - Firewall rule to allow Azure services
// =============================================================================

@description('Azure region for resources')
param location string

@description('Base name for resources (e.g., flask-dev)')
param baseName string

@description('SQL Server administrator login')
param administratorLogin string = 'sqladmin'

@description('SQL Server administrator password')
@secure()
param administratorPassword string

@description('Database name')
param databaseName string = 'flask'

// -----------------------------------------------------------------------------
// Resource Names
// -----------------------------------------------------------------------------
var sqlServerName = 'sql-${baseName}'

// -----------------------------------------------------------------------------
// SQL Server (Logical Server)
// -----------------------------------------------------------------------------
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// -----------------------------------------------------------------------------
// SQL Database
// -----------------------------------------------------------------------------
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: 'Basic'        // ~$5/month, always on
    tier: 'Basic'
    capacity: 5          // 5 DTUs
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648  // 2 GB max size for Basic
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
  }
}

// -----------------------------------------------------------------------------
// Firewall Rule - Allow Azure Services
// -----------------------------------------------------------------------------
// Required for Container Apps to connect to SQL Database
resource firewallRuleAzure 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAllAzureIPs'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'  // Special range that allows Azure services
  }
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
@description('SQL Server fully qualified domain name')
output serverFqdn string = sqlServer.properties.fullyQualifiedDomainName

@description('SQL Server name')
output serverName string = sqlServer.name

@description('Database name')
output databaseName string = sqlDatabase.name

@description('Connection string for pyodbc (without password)')
output connectionStringTemplate string = 'mssql+pyodbc://${administratorLogin}@${sqlServer.properties.fullyQualifiedDomainName}/${databaseName}?driver=ODBC+Driver+18+for+SQL+Server'
