+++
title = "Deploy a Flask Application (Basic)"
program = "IPL"
cohort = "25"
courses = ["SNS"]
description = "Transfer and run a Python web application on your Azure VM"
weight = 2
+++

# Deploy a Flask Application (Basic)

## Goal

Deploy a minimal Flask contact form application to your Azure VM using a Python virtual environment, and verify it responds to HTTP requests.

> **Note:** This exercise demonstrates a simplified deployment for learning purposes. Production deployments would include nginx as a reverse proxy, HTTPS with SSL certificates, a systemd service for process management, and the application organized in `/opt/` with proper permissions.

> **What you'll learn:**
>
> - How to transfer application files to a remote server using SCP
> - How to create a Python virtual environment on a server
> - How to install dependencies from a requirements file
> - How to run a Flask application with Gunicorn

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ An Azure VM running Ubuntu 24.04 with SSH access ([quick setup with Azure CLI](#appendix-quick-vm-setup-with-azure-cli))
> - ✓ The `app.py` and `requirements.txt` files from this module saved locally
> - ✓ Port 5001 open in your VM's Network Security Group

## Exercise Steps

### Overview

1. **Transfer the Application Files**
2. **Set Up the Server Environment**
3. **Install Dependencies and Run**
4. **Test Your Deployment**

### **Step 1:** Transfer the Application Files

The application consists of two files: the Python application and its dependencies list.

1. **Open** a terminal on your local machine

2. **Verify SSH access** to your VM:

   ```bash
   ssh azureuser@YOUR_VM_IP
   ```

   > Replace `YOUR_VM_IP` with your VM's public IP address. If this succeeds, type `exit` to return to your local machine.

3. **Navigate to** the directory containing your Flask application (on your local machine)

4. **Transfer both files** to your VM using SCP:

   ```bash
   scp app.py requirements.txt azureuser@YOUR_VM_IP:~/
   ```

> ℹ **Concept Deep Dive**
>
> SCP (Secure Copy Protocol) uses SSH for secure file transfer. The syntax `user@host:path` specifies the destination. The `~/` path places files in the user's home directory on the server.
>
> For larger applications with many files, you would transfer the entire directory with `scp -r` or use `rsync` for incremental updates.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to replace `YOUR_VM_IP` with the actual IP address
> - Forgetting to transfer `requirements.txt` along with `app.py`
> - Using the wrong SSH key if you have multiple keys configured
>
> ✓ **Quick check:** SCP completes without errors

### **Step 2:** Set Up the Server Environment

Now connect to the server to install Python's virtual environment support and set up the application.

1. **Connect to your VM** via SSH:

   ```bash
   ssh azureuser@YOUR_VM_IP
   ```

2. **Update packages and install venv** (required on Ubuntu):

   ```bash
   sudo apt update
   sudo apt install -y python3-venv
   ```

3. **Verify the files were transferred:**

   ```bash
   ls -la ~/app.py ~/requirements.txt
   ```

   Expected output:

   ```text
   -rw-r--r-- 1 azureuser azureuser 2847 Dec  1 10:00 /home/azureuser/app.py
   -rw-r--r-- 1 azureuser azureuser   15 Dec  1 10:00 /home/azureuser/requirements.txt
   ```

4. **Create** a virtual environment:

   ```bash
   python3 -m venv venv
   ```

5. **Activate** the virtual environment:

   ```bash
   source venv/bin/activate
   ```

6. **Verify** activation by checking your prompt:

   Your terminal prompt should now show `(venv)` at the beginning:

   ```text
   (venv) azureuser@vm:~$
   ```

> ℹ **Concept Deep Dive**
>
> Ubuntu 24.04 includes Python 3.12 by default, but the `venv` module must be installed separately with `apt`. Once installed, `python3 -m venv` creates an isolated Python environment in the `venv/` directory.
>
> When activated, the virtual environment modifies your PATH so that `python` and `pip` commands use the versions inside `venv/`. Packages installed with `pip` go into this directory only, keeping the system Python clean.
>
> This is the same approach used during local development—both your local machine and the server use virtual environments with identical dependencies.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to install `python3-venv` first (causes "ensurepip is not available" error)
> - Forgetting to activate before installing packages
> - Running pip commands without the virtual environment active
>
> ✓ **Quick check:** Your prompt shows `(venv)` prefix

### **Step 3:** Install Dependencies and Run

With the virtual environment active, install all packages and start the application.

1. **Install** the required packages:

   ```bash
   pip install -r requirements.txt
   ```

2. **Verify** the installation:

   ```bash
   pip list
   ```

   Expected output includes:

   ```text
   Package      Version
   ------------ -------
   flask        3.0.0
   gunicorn     21.2.0
   ...
   ```

3. **Start Gunicorn** with the Flask application:

   ```bash
   gunicorn --workers 2 --bind 0.0.0.0:5001 app:app
   ```

   > The `app:app` syntax means: from the `app` module (app.py), use the `app` object (the Flask instance). The `--workers 2` flag spawns two worker processes to handle concurrent requests.

4. **Observe the startup output:**

   ```text
   [INFO] Starting gunicorn 21.2.0
   [INFO] Listening at: http://0.0.0.0:5001
   [INFO] Using worker: sync
   [INFO] Booting worker with pid: 12345
   [INFO] Booting worker with pid: 12346
   ```

> ℹ **Concept Deep Dive**
>
> The `requirements.txt` file ensures that the server installs exactly the same packages as your local development environment. This reproducibility is essential—code that works locally should work identically on the server.
>
> Notice we don't need `sudo` or `--break-system-packages`. The virtual environment gives us an isolated space where we have full control without affecting system packages.
>
> Gunicorn provides production features that Flask's built-in development server lacks:
>
> - Multiple worker processes for concurrent requests
> - Automatic restart of crashed workers
> - Optimized performance for production workloads
>
> Binding to `0.0.0.0` makes the server accessible on all network interfaces, allowing external connections. In a complete production setup, nginx would sit in front of Gunicorn to handle SSL, static files, and act as a reverse proxy.
>
> **Note:** Production deployments typically organize applications in `/opt/` with proper permissions and a systemd service. We use the home directory here for simplicity.
>
> ⚠ **Common Mistakes**
>
> - Binding to `127.0.0.1` instead of `0.0.0.0` blocks external access
> - Forgetting to activate the virtual environment before running Gunicorn
> - Running from the wrong directory means Gunicorn cannot find `app.py`
>
> ✓ **Quick check:** Gunicorn shows "Listening at" with no error messages

### **Step 4:** Test Your Deployment

With Gunicorn running, the application should respond to HTTP requests from your browser.

1. **Open a web browser** on your local machine

2. **Navigate to:** `http://YOUR_VM_IP:5001/`

   > Replace `YOUR_VM_IP` with your VM's public IP address.

3. **Verify the landing page** displays "Welcome" with a link to the contact form

4. **Click "Contact Us"** and test the contact form:
   - Enter a name: `Test User`
   - Enter an email: `test@example.com`
   - Enter a message: `Hello from the browser!`
   - Click "Send Message"

5. **Verify the response:**
   - The browser should display "Thank You!"
   - The page should show the name and email you entered

6. **Check the server terminal:**
   - Return to your SSH session
   - Observe the form data printed to the console

7. **Stop Gunicorn** when finished testing:
   - Press `Ctrl+C` in the SSH terminal

> ✓ **Success indicators:**
>
> - Landing page loads in the browser
> - Contact form page loads when clicking the link
> - Form submission displays the thank you page
> - Form data appears in the Gunicorn terminal output
>
> ✓ **Final verification checklist:**
>
> - ☐ Application files transferred to VM
> - ☐ Virtual environment created and activated
> - ☐ Dependencies installed from requirements.txt
> - ☐ Gunicorn starts without errors
> - ☐ All three pages accessible from browser
> - ☐ Form submission works correctly

## Common Issues

> **If you encounter problems:**
>
> **Connection refused in browser:** Verify port 5001 is open in your VM's Network Security Group
>
> **"No module named flask" error:** Ensure virtual environment is activated (prompt shows `(venv)`)
>
> **Gunicorn command not found:** Activate the virtual environment first with `source venv/bin/activate`
>
> **"No module named app" error:** Run gunicorn from the directory containing app.py
>
> **Page loads but form doesn't submit:** Verify the form action URL matches your route (`/contact`)
>
> **Still stuck?** Delete `venv/` and repeat Steps 2-3 to create a fresh environment

## Summary

You've successfully deployed a Flask application which:

- ✓ Uses a virtual environment for isolated, reproducible dependencies
- ✓ Runs on your Azure VM using Gunicorn as the application server
- ✓ Responds to HTTP requests from external clients
- ✓ Processes form submissions and returns dynamic responses

> **Key takeaway:** Virtual environments ensure your application runs identically on the server as it does locally. The `requirements.txt` file makes deployments reproducible—anyone can recreate your exact environment with `pip install -r requirements.txt`.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Try running Gunicorn with more workers: `gunicorn --workers 4 --bind 0.0.0.0:5001 app:app`
> - Run Gunicorn in the background using `nohup` or `screen`
> - Configure Gunicorn as a systemd service for automatic startup
> - Add nginx as a reverse proxy in front of Gunicorn
> - Organize the application in `/opt/` with proper permissions for production

## Done! 🎉

Excellent work! You've deployed a Flask application to a remote server using proper Python practices—virtual environments and requirements files. This foundation prepares you for more complex deployments involving reverse proxies, HTTPS, and process management.

---

## Appendix: Quick VM Setup with Azure CLI

If you need to create a new VM for this exercise, save this script to a file and run it from your local terminal.

### The Script

Create a file named `create-flask-vm.sh` with the following content:

```bash
#!/bin/bash

# Configuration
RESOURCE_GROUP="flask-app-rg"
VM_NAME="flask-vm"
LOCATION="swedencentral"

# Create resource group
echo "Creating resource group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create VM with Ubuntu 24.04
echo "Creating VM (this takes a few minutes)..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Ubuntu2404 \
  --size Standard_B1s \
  --admin-username azureuser \
  --generate-ssh-keys

# Open port 5001 for the Flask application
echo "Opening port 5001..."
az vm open-port \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --port 5001

# Get and display the public IP
IP_ADDRESS=$(az vm show \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --show-details \
  --query publicIps \
  --output tsv)

echo ""
echo "======================================"
echo "VM created successfully!"
echo "======================================"
echo "Public IP: $IP_ADDRESS"
echo ""
echo "Connect with: ssh azureuser@$IP_ADDRESS"
echo "Delete with:  az group delete --name $RESOURCE_GROUP --yes"
```

### Run the Script

```bash
# Make the script executable
chmod +x create-flask-vm.sh

# Run the script
./create-flask-vm.sh
```

### Clean Up When Done

```bash
# Delete everything when finished
az group delete --name flask-app-rg --yes --no-wait
```

> **Note:** This script creates a minimal VM suitable for learning. Production deployments would include additional security configurations, managed identities, and infrastructure-as-code templates.
