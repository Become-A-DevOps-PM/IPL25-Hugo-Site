+++
title = "Set Up HTTPS with a Self-Signed Certificate"
description = "Configure nginx with SSL/TLS using a self-signed certificate on an Azure VM"
weight = 30
+++

# Set Up HTTPS with a Self-Signed Certificate

## Goal

Configure a secure HTTPS connection on an Azure VM using nginx as a reverse proxy with a self-signed SSL certificate, demonstrating the fundamentals of TLS termination and HTTP-to-HTTPS redirection.

> **What you'll learn:**
>
> - How to generate a self-signed SSL certificate using OpenSSL
> - How to configure nginx as an HTTPS reverse proxy
> - How to redirect HTTP traffic to HTTPS automatically
> - How to use cloud-init to automate server configuration

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Azure CLI installed and configured (`az login` completed)
> - ✓ An active Azure subscription
> - ✓ Terminal access (macOS/Linux Terminal or Windows Git Bash)
> - ✓ Basic understanding of nginx and web servers

## Exercise Steps

### Overview

1. **Create the Cloud-Init Configuration**
2. **Create the Provisioning Script**
3. **Deploy the VM to Azure**
4. **Verify HTTPS Configuration**
5. **Test Your Implementation**

### **Step 1:** Create the Cloud-Init Configuration

Cloud-init automates server configuration during the first boot. This configuration file installs nginx, generates a self-signed certificate, and sets up the reverse proxy. By defining everything declaratively, you ensure consistent, repeatable deployments.

1. **Create** a new directory for the tutorial files:

   ```bash
   mkdir -p https-tutorial
   cd https-tutorial
   ```

2. **Create** a file named `cloud-init.yaml`

3. **Add** the following configuration:

   > `cloud-init.yaml`

   ```yaml
   #cloud-config

   package_update: true
   package_upgrade: true

   packages:
     - nginx
     - openssl

   write_files:
     # Simple Hello World HTML page
     - path: /var/www/hello/index.html
       content: |
         <!DOCTYPE html>
         <html>
         <head>
             <title>Hello World - HTTPS Tutorial</title>
             <style>
                 body {
                     font-family: Arial, sans-serif;
                     max-width: 600px;
                     margin: 100px auto;
                     padding: 20px;
                     text-align: center;
                 }
                 h1 { color: #667eea; }
                 .status {
                     background: #d4edda;
                     color: #155724;
                     padding: 10px 20px;
                     border-radius: 5px;
                     display: inline-block;
                 }
             </style>
         </head>
         <body>
             <h1>🔒 Hello World!</h1>
             <p>You are viewing this page over HTTPS.</p>
             <div class="status">✓ SSL/TLS Active</div>
         </body>
         </html>
       owner: www-data:www-data
       permissions: '0644'

     # Hello World site (port 8080, localhost only)
     - path: /etc/nginx/sites-available/hello
       content: |
         server {
             listen 127.0.0.1:8080;
             server_name localhost;
             root /var/www/hello;
             index index.html;
         }
       owner: root:root
       permissions: '0644'

     # HTTPS reverse proxy configuration
     - path: /etc/nginx/sites-available/https-proxy
       content: |
         # HTTP to HTTPS redirect
         server {
             listen 80 default_server;
             server_name _;
             return 301 https://$host$request_uri;
         }

         # HTTPS server
         server {
             listen 443 ssl default_server;
             server_name _;

             ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
             ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

             ssl_protocols TLSv1.2 TLSv1.3;
             ssl_prefer_server_ciphers off;

             location / {
                 proxy_pass http://127.0.0.1:8080;
                 proxy_set_header Host $host;
                 proxy_set_header X-Real-IP $remote_addr;
                 proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                 proxy_set_header X-Forwarded-Proto $scheme;
             }
         }
       owner: root:root
       permissions: '0644'

   runcmd:
     # Generate self-signed certificate
     - |
       openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
         -keyout /etc/ssl/private/nginx-selfsigned.key \
         -out /etc/ssl/certs/nginx-selfsigned.crt \
         -subj "/C=SE/ST=Stockholm/L=Stockholm/O=Tutorial/CN=localhost"

     # Set certificate permissions
     - chmod 600 /etc/ssl/private/nginx-selfsigned.key

     # Create web directory
     - mkdir -p /var/www/hello
     - chown -R www-data:www-data /var/www/hello

     # Enable sites
     - rm -f /etc/nginx/sites-enabled/default
     - ln -sf /etc/nginx/sites-available/hello /etc/nginx/sites-enabled/hello
     - ln -sf /etc/nginx/sites-available/https-proxy /etc/nginx/sites-enabled/https-proxy

     # Restart nginx
     - systemctl restart nginx
   ```

> ℹ **Concept Deep Dive**
>
> The cloud-init configuration uses three main sections:
>
> - **packages**: Installs nginx and openssl during first boot
> - **write_files**: Creates configuration files before services start
> - **runcmd**: Executes commands after packages are installed
>
> The nginx setup creates two virtual hosts: one for the application (port 8080, localhost only) and one for the HTTPS proxy (ports 80 and 443). The application server is not directly accessible from the internet—all traffic flows through the HTTPS proxy.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `#cloud-config` on the first line causes cloud-init to fail silently
> - YAML indentation errors will prevent the configuration from being parsed
> - Using `0.0.0.0:8080` instead of `127.0.0.1:8080` exposes the app server directly
>
> ✓ **Quick check:** File saved with correct YAML syntax (no tab characters)

### **Step 2:** Create the Provisioning Script

The provisioning script uses Azure CLI to create all required resources. It creates a resource group, deploys the VM with cloud-init, and opens the necessary firewall ports.

1. **Create** a file named `provision.sh`

2. **Add** the following script:

   > `provision.sh`

   ```bash
   #!/bin/bash
   set -e

   # Configuration
   RESOURCE_GROUP="https-tutorial-rg"
   VM_NAME="https-vm"
   LOCATION="swedencentral"

   echo "Creating resource group..."
   az group create \
     --name "$RESOURCE_GROUP" \
     --location "$LOCATION" \
     --output none

   echo "Creating VM with cloud-init..."
   az vm create \
     --resource-group "$RESOURCE_GROUP" \
     --name "$VM_NAME" \
     --image Ubuntu2404 \
     --size Standard_B1s \
     --admin-username azureuser \
     --generate-ssh-keys \
     --custom-data cloud-init.yaml \
     --output none

   echo "Opening ports 80 and 443..."
   az vm open-port \
     --resource-group "$RESOURCE_GROUP" \
     --name "$VM_NAME" \
     --port 80 \
     --priority 1001 \
     --output none

   az vm open-port \
     --resource-group "$RESOURCE_GROUP" \
     --name "$VM_NAME" \
     --port 443 \
     --priority 1002 \
     --output none

   # Get public IP
   PUBLIC_IP=$(az vm show \
     --resource-group "$RESOURCE_GROUP" \
     --name "$VM_NAME" \
     --show-details \
     --query publicIps \
     --output tsv)

   echo ""
   echo "======================================"
   echo "Deployment complete!"
   echo "======================================"
   echo "Public IP: $PUBLIC_IP"
   echo ""
   echo "Wait 2-3 minutes, then visit:"
   echo "  https://$PUBLIC_IP"
   echo ""
   echo "SSH: ssh azureuser@$PUBLIC_IP"
   echo ""
   echo "Delete when done:"
   echo "  az group delete --name $RESOURCE_GROUP --yes"
   ```

3. **Make** the script executable:

   ```bash
   chmod +x provision.sh
   ```

> ℹ **Concept Deep Dive**
>
> The script uses several Azure CLI commands:
>
> - `az group create` creates a resource group to contain all resources
> - `az vm create --custom-data` provisions the VM and passes the cloud-init file
> - `az vm open-port` modifies the Network Security Group to allow inbound traffic
>
> The `--generate-ssh-keys` flag uses existing SSH keys from `~/.ssh/` or creates new ones. The `--output none` flag suppresses verbose JSON output for cleaner terminal display.
>
> ⚠ **Common Mistakes**
>
> - Running the script from the wrong directory means cloud-init.yaml won't be found
> - Forgetting to open port 443 results in HTTPS connections being blocked
> - Not waiting for cloud-init to complete causes "502 Bad Gateway" errors
>
> ✓ **Quick check:** Script is executable (`ls -la provision.sh` shows `-rwxr-xr-x`)

### **Step 3:** Deploy the VM to Azure

Execute the provisioning script to create all Azure resources. The deployment takes approximately 2-3 minutes for the VM creation, plus another 2-3 minutes for cloud-init to complete.

1. **Verify** you are logged into Azure:

   ```bash
   az account show --query name -o tsv
   ```

   If not logged in, run `az login` first.

2. **Run** the provisioning script:

   ```bash
   ./provision.sh
   ```

3. **Note** the public IP address displayed at the end

4. **Wait** 2-3 minutes for cloud-init to complete

5. **(Optional) Monitor** cloud-init progress:

   ```bash
   ssh azureuser@<PUBLIC_IP> 'sudo tail -f /var/log/cloud-init-output.log'
   ```

   Press `Ctrl+C` to stop following the log.

> ℹ **Concept Deep Dive**
>
> Cloud-init runs during the first boot and can take several minutes to complete package installation and configuration. The VM is accessible via SSH almost immediately, but nginx may not be fully configured until cloud-init finishes.
>
> Monitoring `/var/log/cloud-init-output.log` shows real-time progress. When you see "Cloud-init finished" the setup is complete.
>
> ⚠ **Common Mistakes**
>
> - Testing HTTPS before cloud-init completes shows nginx default page or errors
> - SSH connection refused means the VM is still starting
> - "Connection timed out" on port 443 means the NSG port isn't open yet
>
> ✓ **Quick check:** SSH connection succeeds and cloud-init log shows completion

### **Step 4:** Verify HTTPS Configuration

Connect to the VM via SSH to verify the nginx configuration and certificate were created correctly. Understanding the server configuration helps troubleshoot any issues.

1. **Connect** to the VM via SSH:

   ```bash
   ssh azureuser@<PUBLIC_IP>
   ```

2. **Verify** nginx is running:

   ```bash
   sudo systemctl status nginx
   ```

   Expected: "Active: active (running)"

3. **Check** the certificate was created:

   ```bash
   sudo ls -la /etc/ssl/certs/nginx-selfsigned.crt
   sudo ls -la /etc/ssl/private/nginx-selfsigned.key
   ```

4. **View** the certificate details:

   ```bash
   openssl x509 -in /etc/ssl/certs/nginx-selfsigned.crt -noout -subject
   ```

   Expected: `subject=C=SE, ST=Stockholm, L=Stockholm, O=Tutorial, OU=DevOps, CN=<YOUR_PUBLIC_IP>`

5. **Test** nginx configuration:

   ```bash
   sudo nginx -t
   ```

   Expected: "syntax is ok" and "test is successful"

6. **Verify** the sites are enabled:

   ```bash
   ls -la /etc/nginx/sites-enabled/
   ```

   Expected: `hello` and `https-proxy` symlinks

7. **Test** the internal application:

   ```bash
   curl http://localhost:8080
   ```

   Expected: HTML content with "Hello World"

8. **Exit** the SSH session:

   ```bash
   exit
   ```

> ℹ **Concept Deep Dive**
>
> The self-signed certificate contains:
>
> - **Subject**: Information about the certificate owner (CN=your public IP)
> - **Issuer**: Who signed the certificate (same as subject for self-signed)
> - **Validity**: 365 days from creation
> - **Public Key**: RSA 2048-bit key used for encryption
>
> The cloud-init script automatically fetches the VM's public IP address and uses it as the Common Name (CN) in the certificate. This is done by querying an external service (`ifconfig.me`) during first boot.
>
> Unlike certificates from a Certificate Authority (CA), self-signed certificates are not trusted by browsers by default. Browsers will show a security warning, which is expected for development and testing purposes.
>
> ⚠ **Common Mistakes**
>
> - Checking port 8080 from outside the VM fails (it only listens on localhost)
> - Missing certificate files indicate cloud-init didn't complete
> - "nginx: command not found" means packages weren't installed
>
> ✓ **Quick check:** All nginx tests pass and certificate exists

### **Step 5:** Test Your Implementation

Verify the complete HTTPS setup by testing from your browser. The self-signed certificate will trigger a browser warning, which is normal and expected for development environments.

1. **Open** a web browser on your local machine

2. **Navigate to** the HTTP URL:

   ```text
   http://<PUBLIC_IP>
   ```

3. **Verify** automatic redirect:
   - Browser should redirect to `https://<PUBLIC_IP>`
   - URL bar should show HTTPS

4. **Accept** the security warning:
   - Chrome: Click "Advanced" → "Proceed to [IP] (unsafe)"
   - Firefox: Click "Advanced" → "Accept the Risk and Continue"
   - Safari: Click "Show Details" → "visit this website"

5. **Verify** the Hello World page displays:
   - Page title: "Hello World - HTTPS Tutorial"
   - Shows "✓ SSL/TLS Active" status

6. **Inspect** the certificate in your browser:
   - Click the padlock icon (may show warning for self-signed)
   - View certificate details
   - Verify subject shows "O=Tutorial" and CN matches your public IP

7. **Test** from command line (optional):

   ```bash
   curl -k https://<PUBLIC_IP>
   ```

   The `-k` flag tells curl to accept the self-signed certificate.

> ✓ **Success indicators:**
>
> - HTTP requests redirect to HTTPS automatically
> - HTTPS page loads (after accepting certificate warning)
> - Page displays "Hello World" with SSL/TLS active status
> - Certificate shows correct subject information
> - `curl -k` returns HTML content
>
> ✓ **Final verification checklist:**
>
> - ☐ VM deployed and accessible via SSH
> - ☐ nginx running with both sites enabled
> - ☐ Self-signed certificate generated
> - ☐ HTTP redirects to HTTPS
> - ☐ Hello World page displays correctly
> - ☐ Browser shows certificate details

## Common Issues

> **If you encounter problems:**
>
> **"Connection refused" on port 443:** Check that the port was opened with `az vm open-port`. Verify with `az network nsg rule list --resource-group https-tutorial-rg --nsg-name https-vmNSG -o table`
>
> **"502 Bad Gateway":** Cloud-init hasn't finished. Wait another minute and refresh, or check cloud-init log via SSH.
>
> **nginx shows default page:** The sites weren't enabled. Check `/etc/nginx/sites-enabled/` contains the symlinks.
>
> **Certificate errors during curl:** Use `curl -k` to skip certificate verification for self-signed certs.
>
> **"nginx: command not found":** Cloud-init failed to install packages. Check `/var/log/cloud-init-output.log` for errors.
>
> **Still stuck?** SSH into the VM and run `sudo nginx -t` to check for configuration errors.

## Clean Up

> **When finished, delete all resources:**
>
> ```bash
> az group delete --name https-tutorial-rg --yes --no-wait
> ```
>
> This removes the VM, network resources, and all associated costs. The `--no-wait` flag returns immediately while deletion continues in the background.

## Summary

You've successfully configured HTTPS with a self-signed certificate which:

- ✓ Automatically redirects HTTP traffic to HTTPS
- ✓ Terminates SSL/TLS at the nginx reverse proxy
- ✓ Protects an internal application running on port 8080
- ✓ Uses cloud-init for automated, repeatable configuration

> **Key takeaway:** Self-signed certificates provide encryption but not identity verification. They're suitable for development, testing, and internal systems. For production public-facing sites, use certificates from a trusted Certificate Authority like Let's Encrypt.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Replace the self-signed certificate with a Let's Encrypt certificate using Certbot
> - Add HTTP Strict Transport Security (HSTS) headers for enhanced security
> - Configure additional SSL parameters like session caching and OCSP stapling
> - Implement a more complex application behind the reverse proxy

## Done! 🎉

Excellent work! You've learned how to configure HTTPS with a self-signed certificate using nginx as a reverse proxy. This foundational knowledge applies to securing any web application, and the cloud-init approach demonstrates Infrastructure as Code principles for repeatable deployments.
