# Report for Website Launch for Webinar

## Overview

You have built a fully functional registration form for the webinar. It is deployed on Azure and uses different server roles such as a reverse proxy, bastion host, and application server, along with a managed database service. For this assignment, you will prepare a **launch report** that demonstrates the solution is ready for launch (and your understanding of the system's components).

In addition to providing **technical** and **project management** details, you should include **testing and verification steps** to show how you ensured that each part of the solution works as expected. Use **screenshots** and **descriptions**.


## Purpose

The assignment aims to:

1. Demonstrate your knowledge of infrastructure, application stack, and security measures while connecting these to a project management perspective.
2. Demonstrate your ability to implement, test, and verify functionality in the solution.


## Structure
Your report should include the following sections:

### 1. Summary (5%)
   - Provide a brief overview of the project's purpose and objectives.
   - Summarize the system's main components and their functions.

### 2. Technical Architecture and Configuration (30%)

   - **Description:**

     - Describe the Azure infrastructure, including:
       - Network layout (subnets, NSG rules, internal/external communication).
       - The role of reverse proxy, bastion host, and application server.
       - The managed database service (Azure Database for PostgreSQL).
     - Describe key configurations (e.g., nginx rules for reverse proxy, Azure Database for PostgreSQL settings, Gunicorn configuration).
     - If you used automation (Azure CLI, bash scripts, etc.), describe your approach and how it improves reproducibility.

   - **Verification:**

     - Provide step-by-step instructions for how you verified:
       - Correct network communication between components.
       - NSG rules (e.g., successful or blocked connection attempts).
     - Include screenshots from configuration pages and test results (e.g., Azure portal, SSH terminal).

### 3. Application Stack and Functionality (30%)

   - **Description:**

     - Describe the application stack:
       - **Operating System:** Ubuntu Linux
       - **Web Server:** nginx (reverse proxy)
       - **Application Server:** Gunicorn (WSGI server)
       - **Web Framework:** Flask (Python)
       - **Database:** PostgreSQL (Azure managed service)
     - Explain the flow of the contact form - from user input through the reverse proxy and application server to data storage in the database.

   - **Verification:**

     - Show how you tested:
       - The contact form (e.g., form submission, validation, and data storage).
       - Database connection (e.g., queries against the database to retrieve stored data). You can use a GUI tool like DBeaver or the PostgreSQL CLI (`psql`) to connect and verify.
     - Include screenshots of the form in action and results from database queries.

### 4. Security (20%)

   - **Description:**

     - Highlight security measures taken, including:
       - Network security (NSG rules, ASG, network segmentation)
       - SSH access (bastion host, SSH keys, agent forwarding)
       - HTTPS configuration (SSL certificate on reverse proxy)
       - Secrets management (how the database connection string is handled)

   - **Verification:**
     - Describe tests for:
       - SSH connection (e.g., successful access via bastion host using agent forwarding or ProxyJump).
       - NSG rules (e.g., blocked and allowed connections).
       - HTTPS (e.g., certificate is served, browser shows secure connection).
     - Provide screenshots showing blocked and allowed connections, and HTTPS working.

### 5. Risk Awareness (5%)

   - **Description:**

     - Reflect on potential risks associated with launching the website. What could go wrong?
     - Consider technical, operational, or security-related concerns.
     - For each risk you identify, briefly suggest how it could be addressed.

   This section is about demonstrating awareness of risks, not a formal risk analysis.

### 6. Process Reflection (10%)

   Reflect briefly on how you worked:

   - **Iterative development:** How did building incrementally (MVP first, then adding layers) affect your progress? What did you learn from the weekly demos?
   - **AI usage:** How did you use AI tools (Claude, ChatGPT, Copilot, etc.) in this project? For what tasks - understanding concepts, debugging, generating code, writing configurations? What worked well, and where did AI give you incorrect guidance? How did you verify AI-generated solutions?
   - **Automation:** If you had to rebuild your entire infrastructure from scratch tomorrow, how long would it take? What's automated vs. what requires manual steps?

   **Important:** There is no penalty for using AI to build your solution - in fact, effective use of AI is encouraged and rewarded. However, this report itself must be written by you, not generated by AI.


### Submission Details

- **Format:** PDF document (uploaded to Google Classroom)
- **Length:** Approximately 4–8 pages (excluding images).

---


# Tips: Build the Solution Gradually!

When building the solution and preparing your report, it is important to be methodical. Start simple, ensure each component works, and then add more complexity. This way, you will have a working solution early, even if security and architectural features are not fully implemented from the beginning.

### 1. Focus on a Minimal Viable Product (MVP) First

- Start with **core functionality**:

  - Develop the Flask application locally with SQLite for quick iteration.
  - Provision a single VM with Gunicorn to serve the Flask app (SQLite works fine initially).
  - Ensure the contact form works and that form data is stored in the database.

This gives you a working foundation to build upon before adding advanced configurations like the managed PostgreSQL database, reverse proxy, and network segmentation.

### 2. Build the Solution Gradually in Layers

After MVP, add layers to the solution one at a time and test each step.

- **Step 1: Basic Networking**
  - Create a virtual network (VNet) with a single subnet.
  - Connect the application server to this subnet and confirm it can be reached via its IP address.
  - Test SSH access.

- **Step 2: Reverse Proxy**
  - Introduce nginx as a reverse proxy to handle incoming traffic.
  - Configure nginx to forward requests to Gunicorn (typically on port 5001).
  - Test that traffic to the proxy is correctly forwarded to the Flask application.
  - Check regularly (e.g., with curl or browser) that it works.

- **Step 3: Managed Database**
  - Provision Azure Database for PostgreSQL (managed service).
  - Configure the Flask application to connect to PostgreSQL instead of SQLite.
  - Verify the database connection and that data from the form is stored in the database (use DBeaver or `psql` to query the database).

### 3. Work on Security Early

Even when working on basic functionality, you can implement some important security steps:

- Use SSH keys for server access.
- Restrict incoming traffic to necessary ports (e.g., port 22 for SSH, port 80 for HTTP) using NSG.

### 4. Test and Verify Continuously

At each step, verify that your solution works as expected. You can use these techniques:

- **Manual tests:** Test connections (e.g., curl or browser and database queries).
- **Screenshots:** Take screenshots when it works of forms, database queries, etc. Run history.
- **Iterative testing:** After making a change, test the workflow again to ensure it still works.

### 5. Add Advanced Security Last

When the basic functionality is verified, you can focus on advanced aspects such as:

- Implement NSG, ASG, and Service Tags.
- Provision a bastion host for secure SSH access to internal servers.
- Configure systemd services for automatic application startup and management.
- Configure a self-signed SSL certificate on the reverse proxy to enable HTTPS.

Security and architectural improvements should be built on top of a stable and working foundation.

### 6. Use the Azure Portal and CLI for Verification

- **Portal:** Use the Azure portal for visual feedback of Azure CLI commands (NSG rules, network topology, etc.).

### 7. Take Notes

- Document each step while you work:
  - What you added or changed.
  - How you tested it.
  - What results you got.
- This makes it easier to write the report and ensures you don't forget anything.


### Example Progression

1. Develop Flask application locally with SQLite database.
2. Test the contact form to ensure basic functionality works locally.
3. Provision a single Azure VM with Gunicorn to serve the Flask app.
4. Deploy the Flask application and verify it works via HTTP.
5. Provision Azure Database for PostgreSQL and configure the application to use it.
6. Add network segmentation with VNet and NSG rules.
7. Add ASG and Service Tags for fine-grained security.
8. Provision a Bastion Host and verify secure SSH access.
9. Configure systemd for production process management.
10. Run a final test of the solution and take screenshots.
