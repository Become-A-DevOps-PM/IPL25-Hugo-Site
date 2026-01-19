+++
title = "Deploy Flask with Database"
program = "IPL"
cohort = "25"
courses = ["SNS"]
description = "Deploy the database-enabled Flask application to Azure VM with PostgreSQL"
weight = 5
+++

# Deploy Flask with Database

## Goal

Deploy your Flask application with database persistence to your Azure VM, connecting it to Azure PostgreSQL using environment variables.

> **What you'll learn:**
>
> - How to transfer updated application files to a remote server
> - How to add the PostgreSQL driver to your deployment
> - How to configure database connections using environment variables
> - How to verify the complete deployment workflow

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ An Azure VM running Ubuntu with SSH access (from the basic deployment exercise)
> - ✓ Azure PostgreSQL database provisioned and accessible
> - ✓ Your PostgreSQL connection string ready
> - ✓ Updated local Flask application with database persistence

## Exercise Steps

### Overview

1. **Update Requirements File**
2. **Transfer Application Files**
3. **Install Dependencies on Server**
4. **Run with Database Connection**
5. **Test Your Deployment**

### **Step 1:** Update Requirements File

Ensure your requirements file includes all dependencies needed for PostgreSQL connectivity. The server needs the same packages as your local environment, plus the PostgreSQL driver.

1. **Open** `requirements.txt` in your project directory

2. **Verify** it contains all necessary packages:

   > `requirements.txt`

   ```text
   flask
   gunicorn
   flask-sqlalchemy
   psycopg2-binary
   ```

3. **Save** the file

> ℹ **Concept Deep Dive**
>
> The `psycopg2-binary` package provides the PostgreSQL adapter for Python. It's the same package you installed locally when connecting to Azure PostgreSQL. The `-binary` version includes pre-compiled libraries, which simplifies installation on the server.
>
> Keeping requirements.txt synchronized between development and production ensures consistent behavior. If a package works locally but isn't in requirements.txt, it won't be installed on the server.
>
> ✓ **Quick check:** File contains exactly four packages

### **Step 2:** Transfer Application Files

Copy your updated application files to the Azure VM. This includes the modified `app.py` with database support and the updated `requirements.txt`.

1. **Open** a terminal on your local machine

2. **Navigate to** your Flask project directory

3. **Transfer** the files using SCP:

   ```bash
   scp app.py requirements.txt azureuser@YOUR_VM_IP:~/
   ```

4. **Verify** the transfer completed without errors

> ℹ **Concept Deep Dive**
>
> SCP (Secure Copy Protocol) uses your SSH key for authentication, the same key you use to connect to the VM. The `~/` destination places files in the user's home directory on the server.
>
> We transfer both files even if only one changed. This ensures the server always has the complete, current application. For larger projects with many files, you might use `rsync` for incremental transfers or set up a Git-based deployment.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to replace `YOUR_VM_IP` with the actual IP address
> - Transferring from the wrong local directory
> - Firewall blocking SSH (port 22) or wrong SSH key
>
> ✓ **Quick check:** SCP shows successful transfer of both files

### **Step 3:** Install Dependencies on Server

Connect to the VM, activate the virtual environment, and install the updated dependencies. The server needs the PostgreSQL driver to connect to Azure PostgreSQL.

> **Note:** The virtual environment was already created in the basic deployment exercise. If you're using the same VM, it should already exist.

1. **Connect** to your VM:

   ```bash
   ssh azureuser@YOUR_VM_IP
   ```

2. **Activate** the virtual environment:

   ```bash
   source venv/bin/activate
   ```

   Your prompt should show `(venv)` prefix.

3. **Install** the updated dependencies:

   ```bash
   pip install -r requirements.txt
   ```

4. **Verify** psycopg2-binary is installed:

   ```bash
   pip list | grep psycopg2
   ```

   Expected output:

   ```text
   psycopg2-binary    2.9.x
   ```

> ℹ **Concept Deep Dive**
>
> Running `pip install -r requirements.txt` again installs any new packages (psycopg2-binary) while leaving existing packages unchanged. Pip recognizes already-installed packages and skips them.
>
> The virtual environment on the server mirrors your local environment. This consistency is why the same code works in both places—the Python packages are identical.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to activate the virtual environment installs packages system-wide
> - Running pip without the requirements file misses dependencies
> - Not verifying installation means errors appear at runtime
>
> ✓ **Quick check:** `pip list` shows flask, gunicorn, flask-sqlalchemy, and psycopg2-binary

### **Step 4:** Run with Database Connection

Start Gunicorn with the DATABASE_URL environment variable pointing to your Azure PostgreSQL database. This single command configures the connection for the current session.

1. **Start** Gunicorn with the environment variable:

   ```bash
   DATABASE_URL='postgresql://flaskadmin:DevOps2025!@flask-db-unique.postgres.database.azure.com:5432/contactform' gunicorn --workers 2 --bind 0.0.0.0:5001 app:app
   ```

   > **Note:** Replace `DevOps2025!` with your actual password and `flask-db-unique` with your server name.

2. **Observe** the startup output:

   ```text
   [INFO] Starting gunicorn 21.2.0
   [INFO] Listening at: http://0.0.0.0:5001
   [INFO] Using worker: sync
   [INFO] Booting worker with pid: 12345
   [INFO] Booting worker with pid: 12346
   ```

> ℹ **Concept Deep Dive**
>
> Setting the environment variable inline (`DATABASE_URL="..." gunicorn ...`) makes it available only for that command. When you stop Gunicorn, the variable disappears. This is intentional for testing—you'll use a more persistent approach in the production exercise.
>
> The application code reads `os.environ.get('DATABASE_URL', 'sqlite:///messages.db')`. When DATABASE_URL is set, SQLAlchemy connects to PostgreSQL. When it's not set, it falls back to SQLite.
>
> Gunicorn with 2 workers can handle multiple concurrent requests. Each worker is a separate process with its own database connection pool.
>
> ⚠ **Common Mistakes**
>
> - Quotes around the connection string are required if password contains special characters
> - Missing the `gunicorn` command after the environment variable
> - Wrong database name (`contactform` vs. server name)
>
> ✓ **Quick check:** Gunicorn starts without database connection errors

### **Step 5:** Test Your Deployment

Verify the complete system works: browser to VM to Azure PostgreSQL and back. This end-to-end test confirms all components are properly connected.

1. **Open** a web browser on your local machine

2. **Navigate to** `http://YOUR_VM_IP:5001/`

3. **Test the contact form:**

   - Click "Contact Us"
   - Enter test data:
     - Name: `VM Test User`
     - Email: `vmtest@example.com`
     - Message: `This message was submitted through the deployed VM!`
   - Click "Send Message"
   - Verify the thank you page appears

4. **Verify database storage:**

   - Click "View Messages" or navigate to `/messages`
   - Confirm your message appears with correct timestamp
   - **Check:** Any messages from local testing should also appear (same database)

5. **Test data persistence:**

   - Stop Gunicorn on the VM with `Ctrl+C`
   - Restart with the same command
   - Navigate to `/messages` again
   - **Verify messages still exist** (data is in Azure PostgreSQL)

6. **Stop** Gunicorn when finished testing:

   - Press `Ctrl+C` in the SSH terminal

> ✓ **Success indicators:**
>
> - Application loads in browser via VM's public IP
> - Form submission saves data successfully
> - Messages page shows all submissions
> - Data persists after Gunicorn restart
> - Messages from local testing appear (shared database)
>
> ✓ **Final verification checklist:**
>
> - ☐ Updated files transferred to VM
> - ☐ psycopg2-binary installed in virtual environment
> - ☐ Gunicorn starts without connection errors
> - ☐ Form submission works through browser
> - ☐ Messages display at `/messages`
> - ☐ Data persists across restarts

## Common Issues

> **If you encounter problems:**
>
> **Connection refused in browser:** Verify port 5001 is open in VM's Network Security Group
>
> **Database connection timeout:** Check Azure PostgreSQL firewall allows VM's IP or Azure services
>
> **"password authentication failed":** Verify the password in DATABASE_URL matches Azure PostgreSQL
>
> **"database contactform does not exist":** Create the database in Azure Portal
>
> **"No module named psycopg2":** Activate virtual environment and run `pip install -r requirements.txt`
>
> **Still stuck?** Test the connection string locally first to isolate the issue

## Summary

You've successfully deployed the database-enabled application which:

- ✓ Runs on your Azure VM using Gunicorn
- ✓ Connects to Azure PostgreSQL using environment variable
- ✓ Persists form data to a managed cloud database
- ✓ Uses the same code as local development

> **Key takeaway:** Environment variables separate configuration from code. The same `app.py` runs locally with SQLite and on the server with PostgreSQL—only the `DATABASE_URL` changes. This is a fundamental DevOps principle.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Monitor database connections in Azure Portal metrics
> - Test what happens when you use a wrong password (error handling)
> - Compare message counts between local SQLite and Azure PostgreSQL
> - Explore running Gunicorn in the background with `nohup`

## Done! 🎉

Great work! Your application is now deployed with a production database. However, the current setup requires manually starting Gunicorn and typing the connection string each time. The next exercise addresses this by configuring a proper system service.
