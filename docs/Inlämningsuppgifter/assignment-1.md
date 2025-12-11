# Report for Website Launch for Webinar

## Overview

You have built a fully functional registration form for the webinar. It is deployed on Azure and uses different server roles such as a reverse proxy, bastion host, application server, and database server. For this assignment, you will prepare a **launch report** that demonstrates the solution is ready for launch (and your understanding of the system's components).

In addition to providing **technical** and **project management** details, you should include **testing and verification steps** to show how you ensured that each part of the solution works as expected. Use **screenshots** and **descriptions**.


## Purpose

The assignment aims to:

1. Demonstrate your knowledge of infrastructure, application stack, and security measures while connecting these to a project management perspective.
2. Demonstrate your ability to implement, test, and verify functionality in the solution.


## Structure
Your report should include the following sections:

### 1. Summary (10%)
   - Provide an overall description of the project's purpose, scope, and objectives.
   - Summarize the system's main components and their functions.

### 2. Technical Architecture and Configuration (30%)

   - **Description:**

     - Describe the Azure infrastructure, including:
       - Network layout (subnets, NSG rules, internal/external communication).
       - The role of reverse proxy, bastion host, application server, and database server.
     - Describe key configurations (e.g., Nginx rules for reverse proxy, MySQL settings).

   - **Verification:**

     - Provide step-by-step instructions for how you verified:
       - Correct network communication between components.
       - NSG rules (e.g., successful or blocked connection attempts).
     - Include screenshots from configuration pages and test results (e.g., Azure portal, SSH terminal).

### 3. Application Stack and Functionality (30%)

   - **Description:**

     - Describe the application stack (LEMP: Linux, Nginx, MySQL, PHP).
     - Explain the flow of the contact form - from user input to data storage in the database.

   - **Verification:**

     - Show how you tested:
       - The contact form (e.g., form submission, validation, and data storage).
       - Database connection (e.g., queries against the database to retrieve stored data).
     - Include screenshots of the form in action and results from database queries.

### 4. Security (20%)

   - **Description:**

     - Highlight security measures taken (e.g., with NSG, ASG, and SSH).

   - **Verification:**
     - Describe tests for:
       - SSH connection (e.g., successful access via bastion host).
       - NSG rules (e.g., blocked and allowed connections).
     - Provide screenshots showing blocked and allowed connections.

### 5. Risk Analysis (10%)

   - **Description:**

     - Identify potential risks (technical, operational, or security-related) for the website launch.
     - Suggest mitigation strategies for each identified risk.


### Submission Details

- **Format:** PDF document (uploaded to Google Classroom)
- **Length:** Approximately 3–6 pages (excluding images).

---


# Tips: Build the Solution Gradually!

When building the solution and preparing your report, it is important to be methodical. Start simple, ensure each component works, and then add more complexity. This way, you will have a working solution early, even if security and architectural features are not fully implemented from the beginning.

### 1. Focus on a Minimal Viable Product (MVP) First

- Start with **core functionality**:

  - Provision a single VM with Nginx, PHP, and MySQL.
  - Ensure the contact form works and that form data is stored in the database.

This gives you a working foundation to build upon before adding advanced configurations like security and networking.

### 2. Build the Solution Gradually in Layers

After MVP, add layers to the solution one at a time and test each step.

- **Step 1: Basic Networking**
  - Create a virtual network (VNet) with a single subnet.
  - Connect the application server to this subnet and confirm it can be reached via its IP address.
  - Test SSH access.

- **Step 2: Reverse Proxy**
  - Introduce Nginx as a reverse proxy to handle incoming traffic.
  - Test that traffic to the proxy is correctly forwarded to the web server.
  - Check regularly (e.g., with curl or browser) that it works.

- **Step 3: Database Server**
  - Add the database server (MySQL).
  - Configure the application server (PHP code) to connect to the database server.
  - Verify the database connection and that data from the form is stored in the database.

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

Security and architectural improvements should be built on top of a stable and working foundation.

### 6. Use the Azure Portal and CLI for Verification

- **Portal:** Use the Azure portal for visual feedback of Azure CLI commands (NSG rules, network topology, etc.).

### 7. Take Notes

- Document each step while you work:
  - What you added or changed.
  - How you tested it.
  - What results you got.
- This makes it easier to write the report and ensures you don't forget anything.


### Example

1. Provision and configure a single VM with Nginx, PHP, and MySQL.
2. Test the contact form to ensure basic functionality.
3. Add a reverse proxy and test.
4. Separate the database to its own VM and test app-to-database communication.
5. Add ASG and Service Tags.
6. Provision a Bastion Host and verify secure SSH access.
7. Run a final test of the solution and take screenshots.
