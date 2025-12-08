+++
title = "Provision Azure PostgreSQL"
description = "Create a managed PostgreSQL database in Azure and learn to connect to it"
weight = 4
+++

# Provision Azure PostgreSQL

## Goal

Create a managed PostgreSQL database in Azure for production use and verify connectivity from your local machine.

> **What you'll learn:**
>
> - How to create Azure Database for PostgreSQL using the Azure Portal
> - How to configure firewall rules for database access
> - How to connect to the database using various tools
> - How to configure your local application to use the cloud database

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ An active Azure subscription
> - ✓ Access to the Azure Portal (<https://portal.azure.com>)
> - ✓ The Flask application with database persistence working locally
> - ✓ Azure CLI installed (for appendix commands)

## Exercise Steps

### Overview

1. **Create the PostgreSQL Flexible Server**
2. **Create the Application Database**
3. **Configure Firewall Rules**
4. **Find Connection Information**
5. **Connect Local Application to Azure Database**
6. **Test Your Setup**

### **Step 1:** Create the PostgreSQL Flexible Server

Azure Database for PostgreSQL Flexible Server is a fully managed database service that handles backups, patching, and high availability. Creating a server through the Portal provides a visual interface for all configuration options.

1. **Navigate to** the Azure Portal at <https://portal.azure.com>

2. **Click** "Create a resource" in the top-left corner

3. **Search for** "Azure Database for PostgreSQL Flexible Server"

4. **Click** "Create" on the Azure Database for PostgreSQL Flexible Server option

5. **Configure** the Basics tab:

   - **Subscription:** Select your subscription
   - **Resource group:** Create new or select existing (e.g., `flask-app-rg`)
   - **Server name:** Enter `flask-db-unique` (replace `unique` with your initials or a number)
   - **Region:** Select `Sweden Central` or your preferred region
   - **PostgreSQL version:** Select `17` (latest stable)
   - **Workload type:** Select `Development` (lowest cost)

6. **Configure** compute and storage:

   - **Click** "Configure server" link under the Compute + storage section
   - **Select** the `Standard_B1ms` tier (1 vCore, the smallest option)
   - **Click** "Save"

7. **Configure** authentication:

   - **Authentication method:** PostgreSQL authentication only
   - **Admin username:** Enter `flaskadmin`
   - **Password:** Create a strong password (e.g., `DevOps2025!`) and save it securely

8. **Click** "Next: Networking"

9. **Configure** the Networking tab:

   - **Connectivity method:** Select `Public access (allowed IP addresses)`
   - **Allow public access:** Check the box
   - **Allow public access from any Azure service:** Check this box (allows VM access)

10. **Click** "Review + create"

11. **Review** the configuration summary

12. **Click** "Create" and wait for deployment (3-5 minutes)

13. **Click** "Go to resource" when deployment completes

> ℹ **Concept Deep Dive**
>
> Azure Database for PostgreSQL Flexible Server provides a managed PostgreSQL instance. "Managed" means Azure handles the operating system, security patches, backups, and monitoring. You focus on your data and application.
>
> The server name becomes part of your connection hostname: `flask-db-unique.postgres.database.azure.com`. This must be globally unique across all Azure customers, so replace `unique` with your initials or a number (e.g., `flask-db-jd` or `flask-db-42`).
>
> The "Development" workload type selects the Burstable tier with minimal resources—perfect for learning. Production workloads would use General Purpose or Memory Optimized tiers.
>
> The "Public access" option allows connections from the internet, controlled by firewall rules. In production, you might use Private endpoints instead, which keep traffic on Azure's internal network. "Allow public access from any Azure service" enables your VM to connect without knowing its specific IP address.
>
> ⚠ **Common Mistakes**
>
> - Using a weak password will cause security warnings
> - Forgetting the admin password requires a reset process
> - Choosing a region far from your VM increases latency
> - Deployment can take several minutes—be patient
>
> ✓ **Quick check:** Server shows "Running" status in the Overview page

### **Step 2:** Create the Application Database

A PostgreSQL server can host multiple databases. Now create a database specifically for the contact form application.

1. **Navigate to** your PostgreSQL server in the Azure Portal (search for `flask-db-unique` or find it under "All resources")

2. **Navigate to** "Databases" in the left sidebar

3. **Click** "+ Add" to create a new database

4. **Enter** the database name: `contactform`

5. **Click** "Save"

> ℹ **Concept Deep Dive**
>
> The database `contactform` is where your application stores data. The server (`flask-db-unique`) is the PostgreSQL instance that can contain many databases. This separation allows you to run multiple applications on a single server.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to create the database means the application can't connect
> - Database names are case-sensitive on PostgreSQL
>
> ✓ **Quick check:** Database `contactform` appears in the Databases list

### **Step 3:** Configure Firewall Rules

Add a firewall rule to allow connections to your database. Without this rule, the database rejects all external connections.

1. **Navigate to** "Networking" in the left sidebar

2. **Add a firewall rule** to allow all IP addresses:

   - **Click** "+ Add 0.0.0.0 - 255.255.255.255"
   - This allows connections from any IP address

3. **Click** "Save" and wait for the firewall rules to apply

> ⚠ **Security Warning**
>
> Allowing all IP addresses (0.0.0.0 - 255.255.255.255) is **not recommended for production**. We use this approach for learning to avoid connectivity issues when IP addresses change or when connecting from different locations.
>
> In a real production environment, you should:
>
> - Allow only specific IP addresses (your office, VPN, or VM)
> - Use Azure Private Endpoints to keep traffic on Azure's internal network
> - Implement network security groups for additional protection

> ℹ **Concept Deep Dive**
>
> Firewall rules control which IP addresses can connect to your database server. By default, all connections are blocked. Each rule specifies a range of allowed IP addresses.
>
> The database is still protected by username/password authentication. The firewall adds a network-level security layer on top of that.
>
> ⚠ **Common Mistakes**
>
> - Forgetting to click "Save" means rules aren't applied
> - Firewall rules take a minute to propagate
>
> ✓ **Quick check:** Firewall rule shows status "Succeeded"

### **Step 4:** Find Connection Information

Gather the connection details needed to connect your application to the database. PostgreSQL uses a connection string that contains all necessary information.

1. **Navigate to** "Overview" in the left sidebar

2. **Note** the following information:

   - **Endpoint:** `flask-db-unique.postgres.database.azure.com` (your server name will differ)
   - **Admin username:** `flaskadmin`
   - **PostgreSQL version:** 17

3. **Construct** your connection string:

   ```text
   postgresql://flaskadmin:DevOps2025!@flask-db-unique.postgres.database.azure.com:5432/contactform
   ```

   > **Note:** Replace `DevOps2025!` with your actual password and `flask-db-unique` with your server name.

4. **Save** this connection string securely (you'll need it in the next steps)

> ℹ **Concept Deep Dive**
>
> The PostgreSQL connection string follows this format:
>
> ```text
> postgresql://USERNAME:PASSWORD@HOSTNAME:PORT/DATABASE
> ```
>
> - `postgresql://` — Protocol identifier
> - `flaskadmin:PASSWORD` — Authentication credentials
> - `flask-db-unique-yourname.postgres.database.azure.com` — Server hostname
> - `5432` — PostgreSQL default port
> - `contactform` — Database name
>
> This single string contains everything needed to establish a database connection. Environment variables store this string so it's not hardcoded in your application.
>
> ⚠ **Common Mistakes**
>
> - Using the wrong database name (server name vs. database name)
> - Forgetting the port number (`:5432`)
> - Special characters in passwords may need URL encoding
>
> ✓ **Quick check:** Connection string includes all five components (protocol, credentials, host, port, database)

### **Step 5:** Connect Local Application to Azure Database

Test the cloud database connection by running your local Flask application against Azure PostgreSQL instead of SQLite. This verifies the database is accessible and properly configured.

1. **Add** the PostgreSQL driver to requirements.txt:

   > `requirements.txt`

   ```text
   flask
   gunicorn
   flask-sqlalchemy
   psycopg2-binary
   ```

2. **Install** the updated dependencies:

   ```bash
   pip install -r requirements.txt
   ```

3. **Set** the environment variable and run:

   **macOS/Linux:**

   ```bash
   DATABASE_URL='postgresql://flaskadmin:DevOps2025!@flask-db-unique.postgres.database.azure.com:5432/contactform' python app.py
   ```

   **Windows (Git Bash):**

   ```bash
   DATABASE_URL='postgresql://flaskadmin:DevOps2025!@flask-db-unique.postgres.database.azure.com:5432/contactform' python app.py
   ```

   **Windows (Command Prompt):**

   ```cmd
   set DATABASE_URL=postgresql://flaskadmin:DevOps2025!@flask-db-unique.postgres.database.azure.com:5432/contactform
   python app.py
   ```

   > **Note:** Replace `DevOps2025!` with your actual password and `flask-db-unique` with your server name.

4. **Navigate to** `http://localhost:5001/`

5. **Submit** a test message through the contact form

6. **Verify** the message appears at `/messages`

> ℹ **Concept Deep Dive**
>
> Setting `DATABASE_URL` before running the application overrides the SQLite default. Your Flask application code doesn't change—it reads the environment variable and connects to whatever database URL is provided.
>
> `psycopg2-binary` is the PostgreSQL adapter for Python. The `-binary` version includes pre-compiled libraries, avoiding the need to compile C extensions. For production, some teams prefer the standard `psycopg2` package compiled against system libraries.
>
> The first connection automatically creates the `message` table in PostgreSQL because of `db.create_all()` in your application code.
>
> ⚠ **Common Mistakes**
>
> - Connection timeout means firewall rules are blocking your IP
> - "password authentication failed" means wrong password or username
> - "database does not exist" means you didn't create the `contactform` database
>
> ✓ **Quick check:** Application starts without connection errors and form submission works

### **Step 6:** Test Your Setup

Verify the complete workflow works correctly and understand how to use database tools to inspect your data.

1. **Verify data persistence:**

   - Submit several test messages via the form
   - Refresh the `/messages` page to confirm they appear
   - Stop and restart the application
   - Verify messages still appear (data is in Azure, not local)

2. **Check the local SQLite file:**

   - Notice `messages.db` may still exist locally
   - It won't be updated when using Azure PostgreSQL
   - This demonstrates the environment-based switching

3. **(Optional) Connect with psql:**

   If you have the PostgreSQL client installed:

   ```bash
   psql 'postgresql://flaskadmin:DevOps2025!@flask-db-unique.postgres.database.azure.com:5432/contactform'
   ```

   You should see the `contactform=>` prompt, indicating you're connected to the database:

   ```text
   contactform=>
   ```

   Enter the following SQL command to view your data:

   ```sql
   SELECT * FROM message;
   ```

   Exit with `\q`

4. **(Optional) Connect with DBeaver:**

   DBeaver is a free, cross-platform database tool. Download it from <https://dbeaver.io/>.

   - **Open** DBeaver and click **Database** → **New Database Connection**
   - **Select** PostgreSQL and click **Next**
   - **Fill in** the connection settings:

     | Field | Value |
     |-------|-------|
     | Host | `flask-db-unique.postgres.database.azure.com` |
     | Port | `5432` |
     | Database | `contactform` |
     | Username | `flaskadmin` |
     | Password | `DevOps2025!` |

     > **Note:** Replace `flask-db-unique` with your server name and `DevOps2025!` with your actual password.

   - **Click** "Test Connection" to verify
   - **Click** "Finish" to save the connection
   - **Expand** the connection in the left panel to browse tables and view data

> ✓ **Success indicators:**
>
> - Application connects to Azure PostgreSQL without errors
> - Messages submitted locally appear in the cloud database
> - Data persists even after local application restart
> - (Optional) psql can query the data directly
>
> ✓ **Final verification checklist:**
>
> - ☐ PostgreSQL Flexible Server created in Azure
> - ☐ Database `contactform` created on the server
> - ☐ Firewall rules allow your local IP
> - ☐ Connection string saved securely
> - ☐ Local application connects to Azure database
> - ☐ Test messages saved and visible

## Common Issues

> **If you encounter problems:**
>
> **Connection timeout:** Check firewall rules include your current IP address
>
> **"password authentication failed":** Verify the password matches what you set during server creation
>
> **"database contactform does not exist":** Create the database in Azure Portal under Databases
>
> **"SSL connection required":** Azure requires SSL by default. SQLAlchemy handles this automatically with psycopg2
>
> **"no pg_hba.conf entry":** Your IP isn't in the firewall allow list
>
> **Still stuck?** Verify the connection string components match the Azure Portal values exactly

## Summary

You've successfully provisioned Azure PostgreSQL which:

- ✓ Provides a managed, production-ready database
- ✓ Handles backups and security patches automatically
- ✓ Can be accessed from your local machine and Azure VMs
- ✓ Works with your existing Flask application code

> **Key takeaway:** Managed databases let you focus on your application while Azure handles infrastructure concerns. The same application code works with SQLite locally and PostgreSQL in production—only the connection string changes.

## Going Deeper (Optional)

> **Want to explore more?**
>
> - Install **DBeaver** (<https://dbeaver.io/>) for a free, cross-platform graphical database interface that works with PostgreSQL, SQLite, and many other databases
> - Explore the Metrics blade in Azure Portal to monitor database performance
> - Try the Query Performance Insight feature
> - Review the backup and point-in-time restore options

## Done! 🎉

Excellent work! You've created a managed PostgreSQL database in Azure and verified your application can connect to it. This database will serve as the production backend for your deployed application.

---

## Appendix: Azure CLI Commands

If you prefer command-line tools, here are the equivalent Azure CLI commands for all Portal steps.

### Create Resource Group (if needed)

```bash
az group create \
  --name flask-app-rg \
  --location swedencentral
```

### Create PostgreSQL Flexible Server

```bash
az postgres flexible-server create \
  --resource-group flask-app-rg \
  --name flask-db-unique \
  --location swedencentral \
  --admin-user flaskadmin \
  --admin-password 'DevOps2025!' \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --version 17 \
  --public-access 0.0.0.0
```

### Create Database

```bash
az postgres flexible-server db create \
  --resource-group flask-app-rg \
  --server-name flask-db-unique \
  --database-name contactform
```

### Add Firewall Rule for Your IP

```bash
# Get your current public IP
MY_IP=$(curl -s ifconfig.me)

az postgres flexible-server firewall-rule create \
  --resource-group flask-app-rg \
  --name flask-db-unique \
  --rule-name AllowMyIP \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP
```

### Add Firewall Rule for Azure Services

```bash
az postgres flexible-server firewall-rule create \
  --resource-group flask-app-rg \
  --name flask-db-unique \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

### Get Connection String

```bash
echo 'postgresql://flaskadmin:DevOps2025!@flask-db-unique.postgres.database.azure.com:5432/contactform'
```

### Clean Up When Done

```bash
# Delete everything (careful - this removes all resources)
az group delete --name flask-app-rg --yes --no-wait
```

> **Note:** Replace `flask-db-unique` with your actual server name (e.g., `flask-db-jd`) and update the password to match your credentials.
