// Reverse proxy VM with nginx and SSL

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

// Cloud-init configuration for proxy
var cloudInitProxy = '''
#cloud-config
package_update: true
package_upgrade: true

packages:
  - nginx
  - openssl

write_files:
  - path: /etc/nginx/sites-available/flask-app
    content: |
      # HTTP to HTTPS redirect
      server {
          listen 80;
          server_name _;
          return 301 https://$host$request_uri;
      }

      # HTTPS server with reverse proxy
      server {
          listen 443 ssl;
          server_name _;

          ssl_certificate /etc/nginx/ssl/nginx.crt;
          ssl_certificate_key /etc/nginx/ssl/nginx.key;
          ssl_protocols TLSv1.2 TLSv1.3;
          ssl_ciphers HIGH:!aNULL:!MD5;

          location / {
              proxy_pass http://vm-app:5001;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
          }
      }

runcmd:
  - mkdir -p /etc/nginx/ssl
  - openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/CN=flask-app/O=Learning/C=SE"
  - ln -sf /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled/flask-app
  - rm -f /etc/nginx/sites-enabled/default
  - systemctl reload nginx
'''

// Public IP for proxy
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-proxy'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// Network interface
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-proxy'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
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
      customData: base64(cloudInitProxy)
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
output publicIpAddress string = publicIp.properties.ipAddress
output vmId string = vm.id
