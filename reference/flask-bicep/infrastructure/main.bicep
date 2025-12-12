// Main orchestration template for Flask application infrastructure
// Deploys: Network, Bastion, Proxy, App Server, and PostgreSQL Database

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment name (used in resource naming)')
param environment string = 'dev'

@description('Project name (used in resource naming)')
param project string = 'flask-bicep'

@description('SSH public key for VM access')
@secure()
param sshPublicKey string

@description('PostgreSQL administrator username')
param dbAdminUsername string = 'adminuser'

@description('PostgreSQL administrator password')
@secure()
param dbAdminPassword string

// Naming convention variables
var baseName = '${project}-${environment}'
var vnetName = 'vnet-${baseName}'
var bastionVmName = 'vm-bastion'
var proxyVmName = 'vm-proxy'
var appVmName = 'vm-app'
var postgresServerName = 'psql-${baseName}'

// Deploy network infrastructure
module network 'modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    vnetName: vnetName
    baseName: baseName
  }
}

// Deploy bastion host
module bastion 'modules/bastion.bicep' = {
  name: 'bastionDeployment'
  params: {
    location: location
    vmName: bastionVmName
    subnetId: network.outputs.bastionSubnetId
    asgId: network.outputs.bastionAsgId
    sshPublicKey: sshPublicKey
    baseName: baseName
  }
}

// Deploy reverse proxy
module proxy 'modules/proxy.bicep' = {
  name: 'proxyDeployment'
  params: {
    location: location
    vmName: proxyVmName
    subnetId: network.outputs.webSubnetId
    asgId: network.outputs.proxyAsgId
    sshPublicKey: sshPublicKey
    baseName: baseName
  }
}

// Deploy application server
module app 'modules/app.bicep' = {
  name: 'appDeployment'
  params: {
    location: location
    vmName: appVmName
    subnetId: network.outputs.appSubnetId
    asgId: network.outputs.appAsgId
    sshPublicKey: sshPublicKey
    baseName: baseName
  }
}

// Deploy PostgreSQL database
module database 'modules/database.bicep' = {
  name: 'databaseDeployment'
  params: {
    location: location
    serverName: postgresServerName
    subnetId: network.outputs.dataSubnetId
    vnetId: network.outputs.vnetId
    adminUsername: dbAdminUsername
    adminPassword: dbAdminPassword
    baseName: baseName
  }
}

// Outputs
output bastionPublicIp string = bastion.outputs.publicIpAddress
output proxyPublicIp string = proxy.outputs.publicIpAddress
output postgresServerFqdn string = database.outputs.serverFqdn
output postgresDatabaseName string = database.outputs.databaseName
