// Application server VM with Python environment

@description('Location for all resources')
param location string

@description('VM name')
param vmName string

@description('Subnet resource ID')
param subnetId string

@description('Application Security Group resource ID')
param asgId string

@description('SSH public key')
@secure()
param sshPublicKey string

@description('Base name for resources')
param baseName string

// Cloud-init configuration for app server
var cloudInitApp = '''
#cloud-config
package_update: true
package_upgrade: true

packages:
  - python3
  - python3-pip
  - python3-venv
  - postgresql-client

# Note: Create system user in runcmd to preserve Azure's default azureuser
# Using 'users:' directive replaces default users which breaks SSH access

write_files:
  - path: /etc/systemd/system/flask-app.service
    content: |
      [Unit]
      Description=Flask Application
      After=network.target

      [Service]
      Type=simple
      User=flask-app
      Group=flask-app
      WorkingDirectory=/opt/flask-app
      EnvironmentFile=/etc/flask-app/database.env
      ExecStart=/opt/flask-app/venv/bin/gunicorn --bind 0.0.0.0:5001 wsgi:app
      Restart=always
      RestartSec=5

      [Install]
      WantedBy=multi-user.target

runcmd:
  # Create flask-app system user (don't use cloud-init users: as it replaces default users)
  - useradd --system --shell /usr/sbin/nologin --no-create-home flask-app
  - mkdir -p /opt/flask-app
  - mkdir -p /etc/flask-app
  - python3 -m venv /opt/flask-app/venv
  - /opt/flask-app/venv/bin/pip install --upgrade pip wheel setuptools
  - chown -R azureuser:flask-app /opt/flask-app
  - chmod 775 /opt/flask-app
  - chmod 775 /opt/flask-app/venv
  - usermod -aG flask-app azureuser
  - chown root:flask-app /etc/flask-app
  - chmod 750 /etc/flask-app
  - touch /etc/flask-app/database.env
  - chown root:flask-app /etc/flask-app/database.env
  - chmod 640 /etc/flask-app/database.env
  - systemctl daemon-reload
'''

// Network interface (no public IP - internal only)
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-app'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          applicationSecurityGroups: [
            {
              id: asgId
            }
          ]
        }
      }
    ]
  }
}

// Virtual machine
resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'azureuser'
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
      customData: base64(cloudInitApp)
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// Outputs
output vmId string = vm.id
output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
