// PostgreSQL Flexible Server with VNet Integration

@description('Location for all resources')
param location string

@description('PostgreSQL server name')
param serverName string

@description('Subnet resource ID (must be delegated to PostgreSQL)')
param subnetId string

@description('Virtual network resource ID')
param vnetId string

@description('Administrator username')
param adminUsername string

@description('Administrator password')
@secure()
param adminPassword string

// Private DNS Zone for PostgreSQL
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: '${serverName}.private.postgres.database.azure.com'
  location: 'global'
}

// Link DNS zone to VNet
resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'vnet-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// PostgreSQL Flexible Server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: serverName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    version: '16'
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    network: {
      delegatedSubnetResourceId: subnetId
      privateDnsZoneArmResourceId: privateDnsZone.id
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
  dependsOn: [
    privateDnsZoneLink
  ]
}

// Create the flask database
resource flaskDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  parent: postgresServer
  name: 'flask'
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

// Outputs
output serverFqdn string = postgresServer.properties.fullyQualifiedDomainName
output serverId string = postgresServer.id
output databaseName string = flaskDatabase.name
