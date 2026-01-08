// Main orchestration template for simplified Flask application infrastructure
// Deploys: Network (1 subnet), Single VM (nginx + Flask), PostgreSQL (public access)

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment name (used in resource naming)')
param environment string = 'dev'

@description('Project name (used in resource naming)')
param project string = 'flask'

@description('SSH public key for VM access')
@secure()
param sshPublicKey string

@description('PostgreSQL administrator username')
param dbAdminUsername string = 'adminuser'

@description('PostgreSQL administrator password')
@secure()
param dbAdminPassword string

// Naming convention variable
var baseName = '${project}-${environment}'

// Load cloud-init configuration
var cloudInitConfig = loadTextContent('cloud-init/app-server.yaml')

// Deploy simplified network (1 subnet, 1 NSG)
module network 'modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    baseName: baseName
  }
}

// Deploy single VM with nginx + Flask
module vm 'modules/vm.bicep' = {
  name: 'vmDeployment'
  params: {
    location: location
    baseName: baseName
    subnetId: network.outputs.subnetId
    sshPublicKey: sshPublicKey
    cloudInitConfig: cloudInitConfig
  }
}

// Deploy PostgreSQL with public access
module database 'modules/database.bicep' = {
  name: 'databaseDeployment'
  params: {
    location: location
    baseName: baseName
    administratorLogin: dbAdminUsername
    administratorPassword: dbAdminPassword
  }
}

// Outputs
output vmPublicIp string = vm.outputs.publicIpAddress
output vmPrivateIp string = vm.outputs.privateIpAddress
output postgresServerFqdn string = database.outputs.serverFqdn
output postgresDatabaseName string = database.outputs.databaseName
