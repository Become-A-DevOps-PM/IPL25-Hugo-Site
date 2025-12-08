+++
title = "Production Deployment with systemd"
description = "Configure Flask as a system service with secure credential storage"
weight = 6
+++

# Production Deployment with systemd

## Goal

Configure your Flask application as a proper system service that starts automatically, restarts on failure, and stores credentials securely outside the application directory.

> **What you'll learn:**
>
> - How to store credentials securely in `/etc/`
> - How to create systemd unit files for Python applications
> - How to manage services with systemctl
> - How to view logs with journalctl

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Azure VM with Flask application deployed
> - ✓ Azure PostgreSQL database accessible from the VM
> - ✓ Application working with manual Gunicorn start
> - ✓ SSH access to the VM with sudo privileges

## Exercise Steps

### Overview

1. **Create the Environment File**
2. **Create the systemd Unit File**
3. **Enable and Start the Service**
4. **Verify Service Operation**
5. **Test Automatic Restart**
6. **View Logs with journalctl**

### **Step 1:** Create the Environment File

Store your database credentials in a dedicated configuration directory under `/etc/`. This location keeps sensitive data outside the application directory and follows Linux conventions for system configuration.

1. **Connect** to your VM:

   ```bash
   ssh azureuser@YOUR_VM_IP
   ```

2. **Create** the configuration directory:

   ```bash
   sudo mkdir -p /etc/flask-contact-form
   ```

3. **Create** the environment file:

   ```bash
   sudo nano /etc/flask-contact-form/environment
   ```

4. **Add** the following content:

   > `/etc/flask-contact-form/environment`

   ```bash
   DATABASE_URL=postgresql://flaskadmin:DevOps2025!@flask-db-unique.postgres.database.azure.com:5432/contactform
   ```

   > **Note:** Replace `DevOps2025!` with your actual password and `flask-db-unique` with your server name.

5. **Save and exit** nano:
   - Press `Ctrl+O` to save
   - Press `Enter` to confirm
   - Press `Ctrl+X` to exit

6. **Secure** the file permissions:

   ```bash
   sudo chmod 600 /etc/flask-contact-form/environment
   sudo chown root:root /etc/flask-contact-form/environment
   ```

7. **Verify** the permissions:

   ```bash
   ls -la /etc/flask-contact-form/
   ```

   Expected output:

   ```text
   -rw------- 1 root root  xxx  Dec  x xx:xx environment
   ```

> ℹ **Concept Deep Dive**
>
> The `/etc/` directory is the standard location for system configuration files on Linux. Placing credentials here separates configuration from application code—a security best practice.
>
> Permission `600` means only the owner (root) can read or write the file. Other users, including the application user, cannot read it directly. However, systemd runs as root when loading unit files and can read the environment file, then passes variables to the service process.
>
> This approach keeps credentials out of:
> - The application directory (where developers might access them)
> - Environment variables visible in process listings
> - Git repositories or deployment scripts
>
> ⚠ **Common Mistakes**
>
> - Forgetting `sudo` when creating files in `/etc/`
> - Using 644 permissions exposes credentials to all users
> - Trailing spaces or newlines in the file cause connection errors
> - Forgetting to replace placeholder values
>
> ✓ **Quick check:** File shows `-rw-------` permissions and `root root` ownership

### **Step 2:** Create the systemd Unit File

Create a service definition that tells systemd how to start, stop, and manage your Flask application. The unit file references the environment file for configuration.

1. **Create** the unit file:

   ```bash
   sudo nano /etc/systemd/system/flask-contact-form.service
   ```

2. **Add** the following content:

   > `/etc/systemd/system/flask-contact-form.service`

   ```ini
   [Unit]
   Description=Flask Contact Form Application
   After=network.target

   [Service]
   User=azureuser
   Group=azureuser
   WorkingDirectory=/home/azureuser
   EnvironmentFile=/etc/flask-contact-form/environment
   ExecStart=/home/azureuser/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:5001 app:app
   Restart=always
   RestartSec=10

   [Install]
   WantedBy=multi-user.target
   ```

3. **Save and exit** nano

4. **Reload** systemd to recognize the new unit file:

   ```bash
   sudo systemctl daemon-reload
   ```

> ℹ **Concept Deep Dive**
>
> The unit file has three sections:
>
> **[Unit]** - Metadata and dependencies
> - `Description` appears in status output and logs
> - `After=network.target` ensures network is available before starting
>
> **[Service]** - How to run the application
> - `User/Group` specifies which user runs the process (not root)
> - `WorkingDirectory` sets the current directory for the process
> - `EnvironmentFile` loads variables from the file you created
> - `ExecStart` is the exact command to run (full path to gunicorn)
> - `Restart=always` automatically restarts if the process crashes
> - `RestartSec=10` waits 10 seconds before restart attempts
>
> **[Install]** - When the service should start
> - `WantedBy=multi-user.target` means start during normal boot
>
> The service runs as `azureuser`, not root. This limits damage if the application is compromised. However, root initially reads the environment file and passes variables to the process.
>
> Notice that we don't need to activate the virtual environment. By using the full absolute path `/home/azureuser/venv/bin/gunicorn`, systemd runs the gunicorn executable directly from the virtual environment. This gunicorn automatically uses the Python interpreter and packages from that same venv. Activation only modifies your PATH to find executables—when you specify the full path, activation is unnecessary.
>
> ⚠ **Common Mistakes**
>
> - Wrong path to gunicorn (must be absolute path in venv)
> - Wrong WorkingDirectory (app.py must be there)
> - Forgetting `daemon-reload` after creating/editing unit files
> - Typos in the EnvironmentFile path
>
> ✓ **Quick check:** `daemon-reload` completes without errors

### **Step 3:** Enable and Start the Service

Enable the service to start at boot and start it immediately. These are two separate operations in systemd.

1. **Enable** the service (auto-start at boot):

   ```bash
   sudo systemctl enable flask-contact-form
   ```

   Expected output:

   ```text
   Created symlink /etc/systemd/system/multi-user.target.wants/flask-contact-form.service → /etc/systemd/system/flask-contact-form.service.
   ```

2. **Start** the service immediately:

   ```bash
   sudo systemctl start flask-contact-form
   ```

3. **Check** the service status:

   ```bash
   sudo systemctl status flask-contact-form
   ```

   Expected output (look for "Active: active (running)"):

   ```text
   ● flask-contact-form.service - Flask Contact Form Application
        Loaded: loaded (/etc/systemd/system/flask-contact-form.service; enabled; vendor preset: enabled)
        Active: active (running) since Mon 2024-12-01 10:00:00 UTC; 5s ago
      Main PID: 12345 (gunicorn)
         Tasks: 3 (limit: 1024)
        Memory: 50.0M
           CPU: 500ms
        CGroup: /system.slice/flask-contact-form.service
                ├─12345 /home/azureuser/venv/bin/python /home/azureuser/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:5001 app:app
                ├─12346 /home/azureuser/venv/bin/python /home/azureuser/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:5001 app:app
                └─12347 /home/azureuser/venv/bin/python /home/azureuser/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:5001 app:app
   ```

> ℹ **Concept Deep Dive**
>
> `enable` and `start` are different operations:
> - `enable` creates a symlink so the service starts at boot
> - `start` begins the service immediately
>
> You need both: `enable` alone doesn't start the service now, and `start` alone doesn't persist across reboots.
>
> The status output shows:
> - `enabled` - will start at boot
> - `active (running)` - currently running
> - Main PID and child workers
> - Memory and CPU usage
>
> ⚠ **Common Mistakes**
>
> - Assuming `enable` also starts the service (it doesn't)
> - Not checking status after start (errors aren't always visible)
> - Forgetting sudo for systemctl commands
>
> ✓ **Quick check:** Status shows "active (running)" in green

### **Step 4:** Verify Service Operation

Confirm the application is working correctly by testing it through your web browser. The service should be accessible without you manually starting Gunicorn.

1. **Open** a web browser on your local machine

2. **Navigate to** `http://YOUR_VM_IP:5001/`

3. **Test the contact form:**

   - Click "Contact Us"
   - Submit a test message
   - Verify the thank you page appears

4. **Verify data persistence:**

   - Navigate to `/messages`
   - Confirm your message was saved
   - Previous messages should also appear

5. **Test after disconnecting SSH:**

   - Close your SSH terminal
   - Wait 30 seconds
   - Refresh the browser page
   - **Application should still work** (running as a service, not tied to SSH session)

> ℹ **Concept Deep Dive**
>
> When you ran Gunicorn manually in the previous exercise, the process was tied to your SSH session. Closing the terminal (or losing connection) would stop the application.
>
> As a systemd service, the application runs independently of any user session. It starts at boot, continues running after you disconnect, and restarts automatically if it crashes.
>
> This is the fundamental difference between development/testing (manual start) and production deployment (service management).
>
> ✓ **Quick check:** Application works after SSH disconnect

### **Step 5:** Test Automatic Restart

Verify that systemd automatically restarts the application if it crashes. This resilience is crucial for production deployments.

1. **Connect** to your VM via SSH

2. **Find** the main Gunicorn process ID:

   ```bash
   sudo systemctl status flask-contact-form | grep "Main PID"
   ```

3. **Kill** the main process to simulate a crash:

   ```bash
   sudo kill -9 $(pgrep -f "gunicorn.*app:app" | head -1)
   ```

4. **Wait** 10-15 seconds (RestartSec is 10 seconds)

5. **Check** the service status:

   ```bash
   sudo systemctl status flask-contact-form
   ```

   Expected: Status shows "active (running)" with a new PID

6. **Verify** in browser:

   - Refresh `http://YOUR_VM_IP:5001/`
   - Application should be working again

> ℹ **Concept Deep Dive**
>
> The `kill -9` signal immediately terminates a process without cleanup—similar to a crash. The `Restart=always` directive tells systemd to restart the service regardless of how it exited.
>
> The status output shows restart count and last restart time. In production, frequent restarts indicate a problem that needs investigation.
>
> Alternative restart policies:
> - `Restart=on-failure` - only restart if exit code indicates error
> - `Restart=on-abnormal` - restart on signal, timeout, or watchdog
> - `Restart=no` - never auto-restart
>
> ⚠ **Common Mistakes**
>
> - Killing the wrong process (worker instead of main)
> - Not waiting long enough for restart
> - Confusing service status with process status
>
> ✓ **Quick check:** Service recovers automatically after forced termination

### **Step 6:** View Logs with journalctl

Learn to view application logs using journalctl. All output from the service (stdout and stderr) is captured in the systemd journal.

1. **View** recent logs for the service:

   ```bash
   sudo journalctl -u flask-contact-form -n 50
   ```

   This shows the last 50 log lines.

2. **Follow** logs in real-time:

   ```bash
   sudo journalctl -u flask-contact-form -f
   ```

   Press `Ctrl+C` to stop following.

3. **View** logs since last boot:

   ```bash
   sudo journalctl -u flask-contact-form -b
   ```

4. **View** logs from a specific time:

   ```bash
   sudo journalctl -u flask-contact-form --since "1 hour ago"
   ```

5. **Test logging** by submitting a form:

   - With `journalctl -f` running in SSH terminal
   - Submit a contact form in your browser
   - Watch the form data appear in the logs

> ℹ **Concept Deep Dive**
>
> journalctl is the log viewer for systemd's journal. Unlike traditional log files in `/var/log/`, the journal is structured and indexed, making searches faster.
>
> Common options:
> - `-u <service>` - filter by service name
> - `-n <number>` - show last N lines
> - `-f` - follow (like `tail -f`)
> - `-b` - current boot only
> - `--since` / `--until` - time-based filtering
>
> The application's `print()` statements appear in these logs. In production, you would use proper Python logging instead of print(), but the output destination is the same.
>
> ✓ **Quick check:** Form submissions appear in journalctl output

## Useful Commands Reference

> **Common systemctl commands:**
>
> ```bash
> # Check service status
> sudo systemctl status flask-contact-form
>
> # Start the service
> sudo systemctl start flask-contact-form
>
> # Stop the service
> sudo systemctl stop flask-contact-form
>
> # Restart the service
> sudo systemctl restart flask-contact-form
>
> # Enable auto-start at boot
> sudo systemctl enable flask-contact-form
>
> # Disable auto-start
> sudo systemctl disable flask-contact-form
>
> # Reload unit file after editing
> sudo systemctl daemon-reload
> ```

> ✓ **Success indicators:**
>
> - Service shows "active (running)" in status
> - Application accessible via browser
> - Service continues running after SSH disconnect
> - Automatic restart after forced crash
> - Logs visible in journalctl
>
> ✓ **Final verification checklist:**
>
> - ☐ Environment file created in `/etc/flask-contact-form/`
> - ☐ Environment file has 600 permissions (root only)
> - ☐ Unit file created in `/etc/systemd/system/`
> - ☐ Service enabled and started
> - ☐ Application works through browser
> - ☐ Service restarts after crash
> - ☐ Logs accessible via journalctl

## Common Issues

> **If you encounter problems:**
>
> **Service fails to start:** Check `journalctl -u flask-contact-form -n 100` for error messages
>
> **"No such file or directory" for gunicorn:** Verify the path in ExecStart matches your venv location
>
> **Database connection error in logs:** Check the DATABASE_URL in environment file
>
> **Permission denied errors:** Verify User/Group in unit file matches directory ownership
>
> **"EnvironmentFile not found":** Check the path and filename in the unit file
>
> **Service starts but app doesn't work:** Check WorkingDirectory contains app.py
>
> **Still stuck?** Run gunicorn manually with the same command from ExecStart to see detailed errors

## Summary

You've successfully configured a production deployment which:

- ✓ Stores credentials securely in `/etc/`
- ✓ Runs as a system service managed by systemd
- ✓ Starts automatically at boot
- ✓ Restarts automatically after crashes
- ✓ Provides centralized logging via journalctl

> **Key takeaway:** systemd transforms your application from a manually-run script into a proper service. The combination of secure credential storage, automatic restarts, and centralized logging are foundational production deployment practices.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Add nginx as a reverse proxy in front of Gunicorn
> - Configure SSL/TLS for HTTPS
> - Set up log rotation for long-running services
> - Add health check endpoints for monitoring
> - Explore systemd timers for scheduled tasks

## Done! 🎉

Excellent work! You've completed a production-quality deployment. Your application now runs as a proper system service with secure credentials, automatic recovery, and professional logging. This is how real-world Python applications are deployed on Linux servers.
