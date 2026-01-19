+++
title = "Configure HTTPS Manually with Self-Signed Certificate"
program = "IPL"
cohort = "25"
courses = ["SNS"]
description = "Manually configure nginx with SSL/TLS using a self-signed certificate on an Azure VM"
weight = 25
date = 2025-12-13
+++

## Goal

Configure a secure HTTPS connection on an Azure VM by manually setting up nginx as a reverse proxy with a self-signed SSL certificate. This hands-on approach teaches the fundamentals of TLS termination and HTTP-to-HTTPS redirection through direct server configuration.

> **What you'll learn:**
>
> - How to generate a self-signed SSL certificate using OpenSSL
> - How to configure nginx server blocks for internal applications
> - How to set up an HTTPS reverse proxy manually
> - How to redirect HTTP traffic to HTTPS automatically

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Azure CLI installed and configured (`az login` completed)
> - ✓ An active Azure subscription
> - ✓ Terminal access (macOS/Linux Terminal or Windows Git Bash)
> - ✓ Basic understanding of nginx and web servers
> - ✓ Familiarity with SSH and command-line text editing (nano or vim)

## Exercise Steps

### Overview

1. **Create the Provisioning Script**
2. **Deploy the VM to Azure**
3. **Create the Web Application Directory**
4. **Configure the Internal Web Server**
5. **Generate the Self-Signed Certificate**
6. **Configure the HTTPS Reverse Proxy**
7. **Enable Sites and Restart nginx**
8. **Test Your Implementation**

### **Step 1:** Create the Provisioning Script

Create a minimal provisioning script that deploys an Azure VM with nginx installed. Unlike automated approaches, this script only handles infrastructure setup—you will configure all nginx settings manually after connecting via SSH.

1. **Create** a new directory for the tutorial files:

   ```bash
   mkdir -p https-manual-tutorial
   cd https-manual-tutorial
   ```

2. **Create** a file named `provision.sh`

3. **Add** the following script:

   > `provision.sh`

   ```bash
   #!/bin/bash
   set -e

   # Configuration
   RESOURCE_GROUP="https-manual-rg"
   VM_NAME="https-manual-vm"
   LOCATION="swedencentral"

   echo "Creating resource group..."
   az group create \
     --name "$RESOURCE_GROUP" \
     --location "$LOCATION" \
     --output none

   echo "Creating VM..."
   az vm create \
     --resource-group "$RESOURCE_GROUP" \
     --name "$VM_NAME" \
     --image Ubuntu2404 \
     --size Standard_B1s \
     --admin-username azureuser \
     --generate-ssh-keys \
     --output none

   echo "Installing nginx..."
   az vm run-command invoke \
     --resource-group "$RESOURCE_GROUP" \
     --name "$VM_NAME" \
     --command-id RunShellScript \
     --scripts "sudo apt-get update && sudo apt-get install -y nginx openssl" \
     --output none

   echo "Opening port 80..."
   az vm open-port \
     --resource-group "$RESOURCE_GROUP" \
     --name "$VM_NAME" \
     --port 80 \
     --priority 1001 \
     --output none

   echo "Opening port 443..."
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
   echo "Connect via SSH:"
   echo "  ssh azureuser@$PUBLIC_IP"
   echo ""
   echo "Delete when done:"
   echo "  az group delete --name $RESOURCE_GROUP --yes"
   ```

4. **Make** the script executable:

   ```bash
   chmod +x provision.sh
   ```

> ℹ **Concept Deep Dive**
>
> **Why `az vm run-command invoke` instead of cloud-init?**
>
> Azure provides two main approaches for running commands on a VM during or after provisioning:
>
> 1. **Cloud-init** (`--custom-data`): Runs during the VM's first boot. Ideal for complex, declarative configurations that define the entire server state. You pass a YAML file that specifies packages, files, and commands to execute automatically.
>
> 2. **Run Command** (`az vm run-command invoke`): Runs commands on an already-running VM via the Azure VM Agent. Useful for ad-hoc tasks, troubleshooting, or when you want to keep provisioning simple and configure manually afterward.
>
> In this tutorial, we use `run-command` to install only the required packages (nginx and openssl), leaving all configuration for you to do manually via SSH. This teaches the underlying concepts without the abstraction layer of cloud-init. In production or automated deployments, cloud-init would be the preferred approach for reproducible infrastructure.
>
> The script deliberately avoids any nginx configuration—that's what you'll do manually in the following steps.
>
> ⚠ **Common Mistakes**
>
> - Running the script from the wrong directory
> - Forgetting to make the script executable with `chmod +x`
> - Not waiting for the `run-command` to complete before connecting
>
> ✓ **Quick check:** Script is executable (`ls -la provision.sh` shows `-rwxr-xr-x`)

### **Step 2:** Deploy the VM to Azure

Execute the provisioning script to create the Azure VM with nginx installed. The deployment takes approximately 3-5 minutes.

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

4. **Connect** to the VM via SSH:

   ```bash
   ssh azureuser@<PUBLIC_IP>
   ```

5. **Verify** nginx is installed and running:

   ```bash
   sudo systemctl status nginx
   ```

   Expected: "Active: active (running)"

> ℹ **Concept Deep Dive**
>
> The VM now has nginx installed but only with the default configuration. The default nginx configuration serves a welcome page on port 80. You will replace this with a more sophisticated setup that includes an internal application server and an HTTPS reverse proxy.
>
> ⚠ **Common Mistakes**
>
> - SSH connection refused means the VM is still starting
> - "nginx: command not found" means the run-command didn't complete
>
> ✓ **Quick check:** SSH connection succeeds and nginx status shows "active"

### **Step 3:** Create the Web Application Directory

Create the directory structure and HTML file for your internal web application. This application will listen on port 8080 and only be accessible from localhost, protected by the HTTPS reverse proxy.

1. **Create** the web directory:

   ```bash
   sudo mkdir -p /var/www/hello
   ```

2. **Create** the HTML file:

   ```bash
   sudo nano /var/www/hello/index.html
   ```

3. **Add** the following content:

   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <meta charset="UTF-8">
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
   ```

4. **Save** the file (in nano: `Ctrl+O`, `Enter`, `Ctrl+X`)

5. **Set** the correct ownership:

   ```bash
   sudo chown -R www-data:www-data /var/www/hello
   ```

> ℹ **Concept Deep Dive**
>
> The `/var/www/` directory is the conventional location for web content on Debian/Ubuntu systems. The `www-data` user is the nginx worker process user, and it needs read access to serve the files. Setting proper ownership ensures nginx can read the files while maintaining security.
>
> ⚠ **Common Mistakes**
>
> - Creating files in the wrong directory
> - Forgetting to save the file in nano
> - Not setting the correct ownership (results in 403 Forbidden)
>
> ✓ **Quick check:** `ls -la /var/www/hello/` shows `index.html` owned by `www-data`

### **Step 4:** Configure the Internal Web Server

Create an nginx server block that serves your application on port 8080, listening only on localhost. This internal server is not directly accessible from the internet—requests must flow through the HTTPS reverse proxy.

1. **Create** the server block configuration:

   ```bash
   sudo nano /etc/nginx/sites-available/hello
   ```

2. **Add** the following configuration:

   ```nginx
   server {
       listen 127.0.0.1:8080;
       server_name localhost;
       root /var/www/hello;
       index index.html;
   }
   ```

3. **Save** the file

4. **Test** the nginx configuration:

   ```bash
   sudo nginx -t
   ```

   Expected: "syntax is ok" and "test is successful"

> ℹ **Concept Deep Dive**
>
> The `listen 127.0.0.1:8080` directive is crucial for security. By binding to localhost only, the application cannot be accessed directly from the internet. All external traffic must go through the HTTPS proxy, which you will configure next. This pattern is called "reverse proxy" and is standard practice for securing web applications.
>
> ⚠ **Common Mistakes**
>
> - Using `listen 8080` or `listen 0.0.0.0:8080` exposes the app directly to the internet
> - Typos in the configuration file cause nginx to fail
> - Forgetting the semicolons at the end of directives
>
> ✓ **Quick check:** `sudo nginx -t` reports no errors

### **Step 5:** Generate the Self-Signed Certificate

Create a self-signed SSL certificate using OpenSSL. This certificate enables HTTPS encryption but will show a browser warning because it's not signed by a trusted Certificate Authority.

1. **Generate** the certificate and private key:

   ```bash
   sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout /etc/ssl/private/nginx-selfsigned.key \
     -out /etc/ssl/certs/nginx-selfsigned.crt \
     -subj "/C=SE/ST=Stockholm/L=Stockholm/O=Tutorial/CN=localhost"
   ```

2. **Set** restrictive permissions on the private key:

   ```bash
   sudo chmod 600 /etc/ssl/private/nginx-selfsigned.key
   ```

3. **Verify** the certificate was created:

   ```bash
   sudo ls -la /etc/ssl/certs/nginx-selfsigned.crt
   sudo ls -la /etc/ssl/private/nginx-selfsigned.key
   ```

4. **View** the certificate details:

   ```bash
   openssl x509 -in /etc/ssl/certs/nginx-selfsigned.crt -noout -subject
   ```

   Expected: `subject=C=SE, ST=Stockholm, L=Stockholm, O=Tutorial, CN=localhost`

> ℹ **Concept Deep Dive**
>
> The OpenSSL command creates two files: a public certificate (`.crt`) and a private key (`.key`). The `-nodes` flag means "no DES encryption" on the key, allowing nginx to read it without a password. The `-subj` flag provides certificate information without interactive prompts. The 365-day validity is typical for development certificates.
>
> Self-signed certificates encrypt traffic just like CA-signed certificates, but browsers don't trust them by default because there's no third-party verification of identity.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `sudo` results in permission denied errors
> - Incorrect paths cause nginx to fail on startup
> - Not setting restrictive permissions on the private key is a security risk
>
> ✓ **Quick check:** Both certificate files exist and the subject shows your information

### **Step 6:** Configure the HTTPS Reverse Proxy

Create the nginx configuration that terminates HTTPS and forwards requests to your internal application. This configuration also redirects all HTTP traffic to HTTPS automatically.

1. **Create** the HTTPS proxy configuration:

   ```bash
   sudo nano /etc/nginx/sites-available/https-proxy
   ```

2. **Add** the following configuration:

   ```nginx
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
   ```

3. **Save** the file

4. **Test** the configuration:

   ```bash
   sudo nginx -t
   ```

   Expected: "syntax is ok" and "test is successful"

> ℹ **Concept Deep Dive**
>
> This configuration defines two server blocks:
>
> - The first listens on port 80 and redirects all requests to HTTPS using a 301 (permanent) redirect
> - The second listens on port 443 with SSL enabled and proxies requests to the internal application
>
> The `proxy_set_header` directives pass important information to the backend application, such as the client's real IP address and the original protocol (https). This is essential when your application needs to know it's behind a proxy.
>
> ⚠ **Common Mistakes**
>
> - Incorrect certificate paths cause nginx to fail
> - Using `proxy_pass http://localhost:8080` instead of `127.0.0.1` can cause DNS resolution issues
> - Missing semicolons or curly braces break the configuration
>
> ✓ **Quick check:** `sudo nginx -t` reports no syntax errors

### **Step 7:** Enable Sites and Restart nginx

Enable your new configurations and disable the default site. This step activates your HTTPS setup by creating symbolic links in the sites-enabled directory.

1. **Remove** the default site:

   ```bash
   sudo rm -f /etc/nginx/sites-enabled/default
   ```

2. **Enable** the hello site:

   ```bash
   sudo ln -sf /etc/nginx/sites-available/hello /etc/nginx/sites-enabled/hello
   ```

3. **Enable** the HTTPS proxy:

   ```bash
   sudo ln -sf /etc/nginx/sites-available/https-proxy /etc/nginx/sites-enabled/https-proxy
   ```

4. **Verify** the enabled sites:

   ```bash
   ls -la /etc/nginx/sites-enabled/
   ```

   Expected: `hello` and `https-proxy` symlinks

5. **Restart** nginx to apply changes:

   ```bash
   sudo systemctl restart nginx
   ```

6. **Verify** nginx is running:

   ```bash
   sudo systemctl status nginx
   ```

   Expected: "Active: active (running)"

7. **Test** the internal application:

   ```bash
   curl http://localhost:8080
   ```

   Expected: HTML content with "Hello World"

> ℹ **Concept Deep Dive**
>
> The `sites-available` and `sites-enabled` pattern is an nginx convention on Debian/Ubuntu. Configuration files in `sites-available` are templates; only those symlinked into `sites-enabled` are active. This makes it easy to enable/disable sites without deleting configuration files.
>
> The `-sf` flags to `ln` mean: `-s` for symbolic link, `-f` to force (overwrite existing links).
>
> ⚠ **Common Mistakes**
>
> - Forgetting to remove the default site causes conflicting configurations
> - Using `nginx reload` instead of `restart` may not pick up all changes
> - Typos in the symlink command create broken links
>
> ✓ **Quick check:** Both symlinks exist and curl to localhost:8080 returns HTML

### **Step 8:** Test Your Implementation

Verify the complete HTTPS setup by testing from your browser. Exit the SSH session first, then test from your local machine.

1. **Exit** the SSH session:

   ```bash
   exit
   ```

2. **Open** a web browser on your local machine

3. **Navigate to** the HTTP URL:

   ```text
   http://<PUBLIC_IP>
   ```

4. **Verify** automatic redirect:
   - Browser should redirect to `https://<PUBLIC_IP>`
   - URL bar should show HTTPS

5. **Accept** the security warning:
   - Chrome: Click "Advanced" → "Proceed to [IP] (unsafe)"
   - Firefox: Click "Advanced" → "Accept the Risk and Continue"
   - Safari: Click "Show Details" → "visit this website"

6. **Verify** the Hello World page displays:
   - Page title: "Hello World - HTTPS Tutorial"
   - Shows "✓ SSL/TLS Active" status

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
> - `curl -k` returns HTML content
>
> ✓ **Final verification checklist:**
>
> - ☐ VM deployed and accessible via SSH
> - ☐ Web directory created with index.html
> - ☐ Internal server block configured on port 8080
> - ☐ Self-signed certificate generated
> - ☐ HTTPS proxy configured with redirect
> - ☐ Both sites enabled in sites-enabled
> - ☐ nginx restarted without errors
> - ☐ HTTP redirects to HTTPS
> - ☐ Hello World page displays correctly

## Common Issues

> **If you encounter problems:**
>
> **"Connection refused" on port 443:** Check that the port was opened with `az vm open-port`. Verify with `az network nsg rule list --resource-group https-manual-rg --nsg-name https-manual-vmNSG -o table`
>
> **"502 Bad Gateway":** The internal application isn't running. Verify the hello site is enabled and check `curl http://localhost:8080` from the VM.
>
> **nginx shows default page:** The sites weren't enabled correctly. Check `/etc/nginx/sites-enabled/` contains the correct symlinks and the default site was removed.
>
> **"nginx: [emerg] cannot load certificate":** Certificate paths are incorrect. Verify files exist at `/etc/ssl/certs/nginx-selfsigned.crt` and `/etc/ssl/private/nginx-selfsigned.key`
>
> **Configuration syntax errors:** Run `sudo nginx -t` to see detailed error messages. Common issues are missing semicolons or mismatched braces.
>
> **Still stuck?** SSH into the VM and check nginx logs: `sudo tail -f /var/log/nginx/error.log`

## Clean Up

> **When finished, delete all resources:**
>
> ```bash
> az group delete --name https-manual-rg --yes --no-wait
> ```
>
> This removes the VM, network resources, and all associated costs. The `--no-wait` flag returns immediately while deletion continues in the background.

## Summary

You've successfully configured HTTPS with a self-signed certificate through manual configuration which:

- ✓ Created an internal application server on port 8080
- ✓ Generated a self-signed SSL certificate
- ✓ Configured nginx as an HTTPS reverse proxy
- ✓ Automatically redirects HTTP traffic to HTTPS
- ✓ Protects the internal application from direct internet access

> **Key takeaway:** Understanding manual configuration gives you deep insight into how nginx and SSL work. While automation tools like cloud-init are valuable for production deployments, knowing the underlying configuration makes troubleshooting easier and helps you understand what automated tools are actually doing.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add additional security headers (HSTS, X-Frame-Options)
> - Configure SSL session caching for improved performance
> - Set up multiple virtual hosts with different SSL certificates
> - Replace the self-signed certificate with Let's Encrypt using Certbot
> - Add HTTP Basic Authentication to the reverse proxy

## Done!

Excellent work! You've learned how to manually configure HTTPS with nginx by creating server blocks, generating certificates, and setting up a reverse proxy. This hands-on experience builds foundational knowledge that applies to any web server configuration, whether you're using automated tools or configuring servers directly.
