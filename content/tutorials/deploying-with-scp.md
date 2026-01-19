+++
title = "Deploy Files with SCP"
program = "IPL"
cohort = "25"
courses = ["SNS"]
description = "Transfer files from your local machine to a remote server using SCP"
weight = 20
date = 2025-12-01
+++

## Goal

Deploy a local HTML file to an nginx web server using SCP (Secure Copy Protocol). Learn how developers transfer files from their local development environment to remote servers.

> **What you'll learn:**
>
> - How to use `scp` to copy files to a remote server
> - Why you need to copy to `/tmp` first for privileged directories
> - How to create a simple deployment script with a configurable IP address

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ A running VM with nginx installed
> - ✓ SSH key access to the VM
> - ✓ An `index.html` file in a local project directory

## Tutorial Steps

### Overview

1. **Understand Your Local Development Directory**
2. **Copy the File Using SCP (Manual Method)**
3. **Move the File to the Web Server Root**
4. **Verify the Deployment**
5. **Create a Deployment Script**

### **Step 1:** Understand Your Local Development Directory

Most developers keep their projects in a dedicated workspace directory. This central location makes it easy to organize and find your work. The naming convention varies by operating system and personal preference.

1. **Identify** your workspace directory:

   - macOS: `~/Developer/` (Apple's convention)
   - Linux: `~/projects/` or `~/workspace/`
   - Windows: `C:\Users\YourName\projects\` or `~/development/`

2. **Navigate to** your project folder where your `index.html` file is located:

   ```bash
   cd ~/Developer/my-website
   ```

3. **Verify** the file exists:

   ```bash
   ls -la index.html
   ```

> ℹ **Concept Deep Dive**
>
> Having a dedicated development directory keeps your projects organized and makes it easier to write scripts that reference your work. Many developers structure their workspace with subdirectories for different types of projects or clients. Your `index.html` file is essentially your application - a simple static web application that the browser can render.
>
> ✓ **Quick check:** You can see your `index.html` file in the project directory

### **Step 2:** Copy the File Using SCP (Manual Method)

SCP (Secure Copy Protocol) uses SSH to transfer files securely between computers. You might expect to copy directly to the web server directory, but this will fail because `/var/www/html/` is owned by root.

1. **Try** to copy directly to the nginx root (this will fail - skip if you understand why):

   ```bash
   scp -i ~/.ssh/my-key.pem index.html azureuser@<SERVER_IP>:/var/www/html/
   ```

   You will see: `Permission denied`

2. **Copy** the file to the `/tmp` directory instead:

   ```bash
   scp -i ~/.ssh/my-key.pem index.html azureuser@<SERVER_IP>:/tmp/
   ```

   Replace `<SERVER_IP>` with your VM's public IP address.

> ℹ **Concept Deep Dive**
>
> The `/var/www/html/` directory is owned by root for security reasons - you don't want just anyone to be able to modify your web content. The `/tmp` directory is world-writable, meaning any user can write files there. This makes it a useful staging area for files that need to be moved to privileged locations.
>
> ⚠ **Common Mistakes**
>
> - Forgetting the `-i` flag to specify your SSH key
> - Using the wrong IP address (check Azure portal if unsure)
> - Forgetting to `chmod 400` your key file on macOS/Linux
>
> ✓ **Quick check:** The scp command completes without error

### **Step 3:** Move the File to the Web Server Root

Now that the file is on the server in `/tmp`, you need to move it to the nginx web root using sudo privileges. You can do this with a single SSH command without logging in interactively.

1. **Move** the file to the nginx root:

   ```bash
   ssh -i ~/.ssh/my-key.pem azureuser@<SERVER_IP> "sudo mv /tmp/index.html /var/www/html/"
   ```

   This command connects via SSH and executes the `mv` command with sudo.

> ℹ **Concept Deep Dive**
>
> The command in quotes after the SSH connection is executed remotely on the server. Using `sudo` elevates privileges to root, allowing you to write to `/var/www/html/`. The `mv` command moves (rather than copies) the file, which is efficient and cleans up the `/tmp` directory automatically.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `sudo` results in "Permission denied"
> - Misspelling the path `/var/www/html/` causes the file to go to the wrong location
> - Forgetting to use quotes around the remote command
>
> ✓ **Quick check:** Command completes without error

### **Step 4:** Verify the Deployment

Confirm that your file was deployed successfully by viewing it in a web browser.

1. **Open** a web browser

2. **Navigate to:** `http://<SERVER_IP>`

3. **Verify** your content appears correctly

> ✓ **Success indicators:**
>
> - Your HTML content displays in the browser
> - No "404 Not Found" or nginx default page
> - Page content matches your local `index.html` file

### **Step 5:** Create a Deployment Script

Typing these commands every time is tedious and error-prone. A deployment script automates the process and documents your deployment procedure. The script will have a configurable IP address so you can easily update it when your server changes.

1. **Create** a new file named `deploy.sh` in your project directory

2. **Add** the following script:

   > `~/Developer/my-website/deploy.sh`

   ```bash
   #!/bin/bash
   # =============================================================================
   # Deploy Script for Static Website
   # Copies index.html to nginx web server via SCP
   # =============================================================================

   # -----------------------------------------------------------------------------
   # CONFIGURATION - Update these values for your environment
   # -----------------------------------------------------------------------------

   # The public IP address of your Azure VM
   SERVER_IP="20.10.30.40"

   # Path to your SSH private key
   # Use the .pem file from Azure, or your own key (id_rsa, id_ed25519)
   SSH_KEY="~/.ssh/my-key.pem"

   # Username on the remote server
   USER="azureuser"

   # -----------------------------------------------------------------------------
   # DEPLOYMENT STEPS
   # -----------------------------------------------------------------------------

   echo "Deploying to $SERVER_IP..."

   # Step 1: Copy file to temporary location on server
   # We use /tmp because we have write permission there without sudo
   scp -o StrictHostKeyChecking=no -i $SSH_KEY index.html $USER@$SERVER_IP:/tmp/

   # Step 2: Move file to nginx web root
   # Requires sudo because /var/www/html is owned by root
   ssh -o StrictHostKeyChecking=no -i $SSH_KEY $USER@$SERVER_IP "sudo mv /tmp/index.html /var/www/html/"

   # Step 3: Confirm deployment
   echo "✓ Deployed successfully to http://$SERVER_IP"
   ```

3. **Make** the script executable:

   ```bash
   chmod +x deploy.sh
   ```

4. **Run** the deployment script:

   ```bash
   ./deploy.sh
   ```

> ℹ **Concept Deep Dive**
>
> The script separates configuration (at the top) from logic (the deployment steps). This makes it easy to update the IP address when you recreate your VM without searching through the code. The comments explain what each step does, which is valuable documentation for your future self or team members. The `echo` statements provide feedback so you know what's happening during deployment.
>
> ⚠ **Common Mistakes**
>
> - Forgetting `chmod +x` means you can't execute the script
> - Leaving the example IP address `20.10.30.40` instead of your actual VM IP
> - Using Windows line endings (VS Code handles this correctly, but avoid editing with other Windows editors)
>
> ✓ **Quick check:** Running `./deploy.sh` deploys your file and shows the success message

## Common Issues

> **If you encounter problems:**
>
> **"Permission denied (publickey)":** Your SSH key isn't being accepted. Check the key path and ensure it has correct permissions (`chmod 400`).
>
> **"scp: /var/www/html/index.html: Permission denied":** You tried to copy directly to the nginx root. Use the `/tmp` workaround described in Step 2.
>
> **File not updating in browser:** Your browser may be caching the old version. Try a hard refresh (Ctrl+Shift+R or Cmd+Shift+R) or open in incognito mode.
>
> **"Host key verification failed":** First time connecting to this server. Run an interactive SSH connection first to accept the host key, or use `-o StrictHostKeyChecking=no` in your script.
>
> **Still stuck?** Verify your VM is running and the IP address is correct in the Azure portal.

## Summary

You've successfully deployed files to a remote server using SCP which:

- ✓ Transfers files securely over SSH
- ✓ Uses the `/tmp` workaround for privileged directories
- ✓ Automates deployment with a reusable script

> **Key takeaway:** A deployment script saves time and reduces errors by automating repetitive tasks. The script also serves as documentation of your deployment process, making it easier for others (or your future self) to understand how to deploy changes.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add error handling to the script (check if scp succeeds before running mv)
> - Deploy an entire folder using the recursive flag: `scp -r -i $SSH_KEY ./public/* $USER@$SERVER_IP:/tmp/`
> - Use `rsync` instead of `scp` for more efficient transfers of multiple files
> - Add a backup step that saves the old file before replacing it

## Done! 🎉

Great job! You've learned how to deploy files to a remote server using SCP and created a reusable deployment script. This workflow is the foundation for more sophisticated deployment pipelines you'll encounter in professional development.
