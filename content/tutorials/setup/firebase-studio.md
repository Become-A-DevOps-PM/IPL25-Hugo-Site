+++
title = "Firebase Studio (Cloud-Based Alternative)"
program = "IPL"
cohort = "25"
courses = ["SNS"]
description = "Set up a cloud-based development environment with Firebase Studio"
weight = 100
+++

# Firebase Studio Setup Tutorial

## Goal

Set up Firebase Studio (Google's cloud-based development environment) with Azure CLI, Python 3.11+, PostgreSQL 16+, and Google Cloud SDK for Gemini API access.

> **What you'll learn:**
>
> - How to configure browser settings for Firebase Studio compatibility
> - How to enable clipboard functionality in the web-based IDE
> - How to configure development tools using Nix package manager
> - How to authenticate with Azure and Google Cloud services

## Prerequisites

> **Before starting, ensure you have:**
>
> - ✓ Google Account for Firebase Studio access
> - ✓ Modern web browser (Chrome, Firefox, or Safari recommended)
> - ✓ Stable internet connection
> - ✓ GitHub account for repository integration
> - ✓ Azure account (if using Azure CLI)

## Tutorial Steps

### Overview

1. **Configure Browser Settings**
2. **Create Firebase Studio Account and Workspace**
3. **Enable Clipboard Functionality**
4. **Configure Development Environment**
5. **Authenticate with Cloud Services**
6. **Verify Tool Installation**

### **Step 1:** Configure Browser Settings

Firebase Studio requires specific browser settings to function correctly. The platform uses cross-origin iframes, which require third-party cookies to be enabled for secure communication between domains.

1. **Choose your browser** and follow the corresponding instructions:

   **Chrome:**

   - Open Settings → Privacy and Security → Third-party cookies
   - Select "Allow third-party cookies"
   - Alternative: Click the eye icon in address bar → Enable "Third-party cookies"

   **Safari (Mac):**

   - Open Safari → Settings → Privacy
   - Uncheck "Prevent cross-site tracking"
   - Go to Advanced tab
   - Uncheck "Block all cookies"

   **Safari (iOS/iPad):**

   - Open Settings app → Safari
   - Enable "Allow Cross-Website Tracking"

   **Firefox:**

   - No configuration needed - third-party cookies work by default

2. **Verify JavaScript is enabled** in your browser settings

> ⚠ **Common Mistakes**
>
> - Safari users may experience issues even with correct settings - this is a known limitation
> - Browser extensions that block trackers may interfere with Firebase Studio
> - Private/Incognito mode may block third-party cookies by default
> - Pop-up blockers can prevent Firebase Studio from opening authentication windows - check for a pop-up blocker icon in your browser's address bar (especially in Safari) and allow pop-ups for studio.firebase.google.com
>
> ✓ **Quick check:** Browser settings updated and JavaScript enabled

### **Step 2:** Create Firebase Studio Account and Workspace

Access Firebase Studio and create your first cloud-based workspace. This process provisions a Debian-based virtual machine with full terminal access in Google Cloud infrastructure.

1. **Navigate to** <https://studio.firebase.google.com> in your browser

2. **Sign in** with your Google Account

3. **Accept** the Firebase Terms of Service and Android SDK Terms when prompted

4. **Create a new workspace:**

   - Locate the "Start Coding an App" section on the dashboard
   - Click the "+ New Workspace" button
   - In the left menu, select "MISC"
   - On the right side, choose "Empty Workspace"

5. **Wait for workspace provisioning** (first launch may take up to 5 minutes)

6. **Explore the interface** once the workspace loads:

   - File explorer on the left
   - Code editor in the center
   - Terminal panel at the bottom
   - Gemini AI assistant on the right

> ℹ **Concept Deep Dive**
>
> Firebase Studio provides a complete VS Code environment running in the cloud. Each workspace gets a full VM with 100 GiB for packages and 10 GiB for your home directory. The environment persists between sessions, so your files and configurations remain available when you return. You can also import existing repositories from GitHub or push your workspace code to GitHub using the integrated source control features.
>
> ✓ **Quick check:** Workspace loaded successfully with file explorer, editor, and terminal visible

### **Step 3:** Enable Clipboard Functionality

Configure clipboard permissions to enable copy and paste functionality (Ctrl+V / Command+V) in the web-based IDE.

1. **Wait for clipboard permission prompt** when you first attempt to paste content

2. **Click "Allow"** when your browser requests clipboard access

3. **If no prompt appears**, manually grant permissions:

   **Chrome:**

   - Navigate to `chrome://settings/content/clipboard`
   - Add `studio.firebase.google.com` to allowed sites
   - Add `*.cloudworkstations.dev` to allowed sites

   **Firefox:**

   - Type `about:config` in the address bar
   - Search for clipboard-related settings
   - Toggle clipboard permissions to "True"

4. **Test clipboard functionality** by copying text from outside the browser and pasting into the Firebase Studio editor

> ℹ **Concept Deep Dive**
>
> Web-based IDEs require explicit browser permission to access your clipboard for security reasons. The clipboard-write permission is granted automatically to active tabs, but clipboard-read permission must be explicitly requested to prevent malicious sites from accessing your clipboard data.
>
> ✓ **Quick check:** Successfully paste content into the editor using Ctrl+V or Command+V

### **Step 4:** Configure Development Environment

Configure your workspace with required development tools using Nix package manager. Firebase Studio uses declarative configuration in the `.idx/dev.nix` file to define your development environment.

1. **Open** the file explorer in Firebase Studio

2. **Navigate to** `.idx/dev.nix` in the workspace root

3. **Replace** the entire file contents with the following configuration:

   > `.idx/dev.nix`

   ```nix
   { pkgs, ... }: {
     # Use stable Nix package channel
     channel = "stable-24.05";

     # System packages to install
     packages = [
       pkgs.python311           # Python 3.11
       pkgs.postgresql_16       # PostgreSQL 16
       pkgs.azure-cli           # Azure CLI
       pkgs.google-cloud-sdk    # Google Cloud SDK (gcloud)
       pkgs.git                 # Git version control
     ];

     # Environment variables
     env = {
       FLASK_APP = "main.py";
       FLASK_ENV = "development";
     };

     # Enable PostgreSQL service
     services.postgres = {
       enable = true;
       package = pkgs.postgresql_16;
       enableTcp = true;
     };

     # Firebase Studio configuration
     idx = {
       # VS Code extensions
       extensions = [
         "google.gemini-cli-vscode-ide-companion"
         "ms-python.python"
         "ms-python.vscode-pylance"
       ];

       # Workspace lifecycle hooks
       workspace = {
         onCreate = {
           default.openFiles = [ ".idx/dev.nix" "README.md" ];
         };
       };

       # Preview configuration
       previews = {
         enable = true;
         previews = {
           web = {
             command = ["python" "main.py"];
             manager = "web";
           };
         };
       };
     };
   }
   ```

4. **Save** the file (Ctrl+S / Command+S)

5. **Create a .gitignore file** to exclude generated files from version control:

   - In the workspace root, create a new file named `.gitignore`
   - Add the following content:

   > `.gitignore`

   ```gitignore
   # PostgreSQL data directory
   .data/

   # Python virtual environments
   venv/
   env/
   ENV/
   .venv/

   # Python bytecode and cache
   __pycache__/
   *.py[cod]
   *$py.class
   *.so

   # Python distribution and packaging
   build/
   dist/
   *.egg-info/
   .eggs/

   # Flask instance folder
   instance/

   # Environment variables
   .env
   .env.local

   # IDE and editor files
   .vscode/
   .idea/
   *.swp
   *.swo
   *~

   # OS files
   .DS_Store
   Thumbs.db
   ```

6. **Rebuild the environment** to apply changes:

   - Open Command Palette (Ctrl+Shift+P / Command+Shift+P)
   - Type "Rebuild Environment"
   - Select "Rebuild Environment" from the dropdown
   - Wait for the rebuild process to complete (2-5 minutes)

7. **Verify the rebuild completed** by checking the terminal output for success messages

> ℹ **Concept Deep Dive**
>
> Nix is a declarative package manager that ensures reproducible development environments. The `packages` array specifies which tools to install, while `services` configures backend services like PostgreSQL. The `onCreate` hook runs commands when the workspace is first created, and `idx.previews` defines how to run your application for live preview. Search for available packages at <https://search.nixos.org/packages>.
>
> 💡 **Optional: Commit your configuration (recommended)**
>
> Git is pre-installed in Firebase Studio. You may notice a notification in the left sidebar (Git icon) showing uncommitted changes. To save your environment configuration to version control:
>
> ```bash
> git add .idx/dev.nix .gitignore
> git commit -m "$(cat <<'EOF'
> Configure Firebase Studio development environment
>
> - Add dev.nix with Python 3.11, PostgreSQL 16, Azure CLI, and Google Cloud SDK
> - Configure PostgreSQL service with TCP enabled
> - Add VS Code extensions for Python and Gemini CLI companion
> - Set up Flask environment variables and workspace lifecycle hooks
> - Create .gitignore to exclude PostgreSQL data, Python cache, and build artifacts
> EOF
> )"
> ```
>
> This commits your environment setup so others can replicate your development environment. You can do this now or wait until you've tested that everything works.
>
> ⚠ **Common Mistakes**
>
> - Syntax errors in the Nix file will cause rebuild to fail - check for missing brackets or semicolons
> - Rebuilding can take several minutes - don't interrupt the process
> - If the terminal becomes unresponsive, use Command Palette → "Hard Restart"
>
> ✓ **Quick check:** Environment rebuild completed without errors, terminal responsive

### **Step 5:** Authenticate with Cloud Services

Authenticate with Azure and Google Cloud to enable CLI access and API functionality. This step establishes secure connections to cloud platforms from your Firebase Studio workspace.

**Authenticate with Azure CLI:**

1. **Open a terminal** in Firebase Studio (Terminal → New Terminal)

2. **Run the Azure login command:**

   ```bash
   az login --use-device-code
   ```

3. **Follow the authentication flow:**

   - Copy the device code displayed in the terminal
   - Open <https://aka.ms/devicelogin> in a new browser tab
   - Paste the device code and click "Next"
   - Sign in with your Azure account credentials
   - Grant permissions when prompted
   - Return to Firebase Studio terminal

4. **Verify successful authentication** by running:

   ```bash
   az account show
   ```

**Authenticate with Google Cloud CLI:**

1. **Run the Google Cloud authentication command** in the terminal:

   ```bash
   gcloud auth application-default login
   ```

2. **Complete the browser authentication flow:**

   - A browser tab opens automatically
   - Sign in with your Google Account
   - Grant requested permissions
   - Wait for confirmation message
   - Return to Firebase Studio

**Authenticate Gemini CLI:**

1. **Start the Gemini CLI** in the terminal:

   ```bash
   gemini
   ```

2. **Choose authentication method** when prompted:

   - Select **"Login with API Key"** (recommended - most reliable)
   - Obtain your API key from <https://aistudio.google.com/app/apikey>
   - Paste the API key when prompted

   Alternatively, you can try **"Login with Google"** (option 1), though this method may experience authentication errors.

3. **Verify Gemini CLI is working** by asking a simple question at the prompt

> 💡 **Optional: Configure Custom Gemini Models in IDE**
>
> Firebase Studio provides built-in Gemini models that work automatically without any configuration. However, if you want to use your own API plan (e.g., access to Gemini 2.0 or other custom models), you can configure your own API key in the IDE settings (this is separate from the CLI authentication above):
>
> 1. Click the Gemini AI assistant icon on the right side of the Firebase Studio interface
> 2. Click the AI Settings icon (gear icon) in the Gemini chat window
> 3. Enter your Gemini API key in `IDX > AI: Gemini Api Key` field
>    - Obtain an API key from <https://aistudio.google.com/app/apikey>
>    - Or let Firebase Studio create one automatically via the App Prototyping agent
> 4. Select model provider in `IDX > AI: Model Provider` → choose "Gemini API"
> 5. Test access by asking a question in the Gemini chat panel
>
> If you skip this step, Gemini will work with the built-in models provided by Firebase Studio.

**Authentication Summary:**

> ℹ **Concept Deep Dive**
>
> Firebase Studio uses device code authentication for Azure because it cannot directly open browsers from the cloud VM. Google Cloud authentication works seamlessly because Firebase Studio is a Google product and handles authentication automatically when you sign in. The two-step process (gcloud auth + Gemini login) ensures both CLI access and IDE integration work correctly.
>
> ⚠ **Common Mistakes**
>
> - Microsoft requires multi-factor authentication for Azure CLI as of September 2025
> - Device code expires after 15 minutes - complete authentication promptly
> - Don't use `az upgrade` to update Azure CLI - Nix-managed packages must be upgraded by updating dev.nix and rebuilding the environment
> - If you see "No module named pip" errors, this is expected in Nix environments - packages are managed declaratively in dev.nix, not with pip
> - Don't commit API keys to your codebase - Firebase Studio automatically restricts keys
> - If Gemini login fails, ensure you completed gcloud auth first
>
> ✓ **Quick check:** Both `az account show` and `gcloud auth list` display your authenticated accounts, Gemini chat responds to queries

### **Step 6:** Set Up PostgreSQL Database

The PostgreSQL service is already running from your dev.nix configuration. You just need to create your personal database.

1. **Verify PostgreSQL is running:**

   ```bash
   pg_isready
   ```

   Expected output: `/tmp/postgres:5432 - accepting connections`

2. **Create your user database:**

   ```bash
   createdb
   ```

   This creates a database matching your username, which is the default connection.

3. **Verify PostgreSQL connection:**

   ```bash
   psql -c "SELECT version();"
   ```

   Expected output: PostgreSQL version information

> ℹ **Concept Deep Dive**
>
> When you enable PostgreSQL via `services.postgres.enable = true` in dev.nix, Firebase Studio automatically initializes and starts the database service. Unlike traditional PostgreSQL installations with a "postgres" superuser, you connect using your system username to a database of the same name. The `createdb` command without arguments creates this personal database.
>
> ✓ **Quick check:** The `psql -c "SELECT version();"` command returns PostgreSQL version without errors

### **Step 7:** Verify Other Tools

Confirm that all other development tools are correctly installed and functional in your workspace.

1. **Check Python version:**

   ```bash
   python --version
   ```

   Expected output: `Python 3.11.x` or higher

2. **Check Azure CLI version:**

   ```bash
   az --version
   ```

   Expected output: Azure CLI version information

3. **Check Google Cloud SDK version:**

   ```bash
   gcloud --version
   ```

   Expected output: Google Cloud SDK version information

> ✓ **Success indicators:**
>
> - All version commands return expected output
> - PostgreSQL initialized and accepts connections
> - No error messages in terminal output
>
> ✓ **Final verification checklist:**
>
> - ☐ Browser configured with third-party cookies enabled
> - ☐ Clipboard functionality works in the IDE
> - ☐ Firebase Studio workspace created and accessible
> - ☐ dev.nix configuration applied successfully
> - ☐ .gitignore file created
> - ☐ Azure CLI authenticated with device code
> - ☐ Google Cloud SDK authenticated
> - ☐ Gemini CLI authenticated (API key or Google login)
> - ☐ PostgreSQL database cluster initialized
> - ☐ All development tools verified and functional

## Common Issues

> **If you encounter problems:**
>
> **"Can't load because third-party cookies are disabled":** Verify cookie settings in your browser. Safari users should try Chrome or Firefox as an alternative.
>
> **"No space left on device":** Firebase Studio provides 100 GiB for packages and 10 GiB for home directory. Clean up temporary files or reduce package count in dev.nix.
>
> **Preview not loading:** Use Command Palette → "Hard Restart" or "Rebuild Environment" to reset the workspace.
>
> **Azure CLI command not found:** The az command may not be available immediately after rebuild. Try opening a new terminal or restart the workspace.
>
> **PostgreSQL connection refused:** Ensure the PostgreSQL service is enabled in dev.nix and rebuild was successful. Check service status in the terminal.
>
> **Workspace unresponsive:** Click More menu (⋮) → Restart VM → Reopen workspace to force a complete restart.
>
> **Backend connection timeout:** Wait 5 seconds and refresh the page. Check Backend ports panel to expose ports if needed.
>
> **Gemini token limit exceeded:** Create an `.aiexclude` file in workspace root to hide large directories from AI context (e.g., `.next/`, `node_modules/`, `venv/`).
>
> **Still stuck?** Review the official troubleshooting documentation at <https://firebase.google.com/docs/studio/troubleshooting>

## Summary

You've successfully set up Firebase Studio with a complete development environment that includes:

- ✓ Browser configured for web-based IDE compatibility
- ✓ Cloud-based workspace with persistent storage
- ✓ Python, PostgreSQL, Azure CLI, and Google Cloud SDK installed
- ✓ Authenticated access to Azure and Google Cloud platforms
- ✓ Gemini AI assistant configured for coding assistance

> **Key takeaway:** Firebase Studio provides a complete cloud-based development environment accessible from any device with a browser. The declarative Nix configuration ensures your development environment is reproducible and can be version-controlled alongside your code. This approach eliminates "works on my machine" problems and enables consistent development environments across teams.

## Going Deeper (Optional)

> **Want to collaborate with teammates?**
>
> Firebase Studio supports real-time collaboration for pair programming, code reviews, and mentoring. Multiple developers can work in the same workspace simultaneously with live cursors and shared file systems.
>
> **To share your workspace:**
>
> 1. Open Command Palette (`Cmd+Shift+P` on Mac, `Ctrl+Shift+P` on Windows/Linux)
> 2. Type "Firebase Studio" and select "Share Workspace"
> 3. Enter your colleague's email address
> 4. Click "Share"
> 5. Copy the generated workspace URL
> 6. Send the URL to your colleague
>
> **For your colleague:**
>
> 1. Open the shared URL in their browser
> 2. Confirm they trust the person sharing the workspace
> 3. Start collaborating in real-time
>
> **Features:**
>
> - See each other's cursors and edits in real-time in the text editor
> - Shared file system - changes are instantly visible to all collaborators
> - Individual terminals - each collaborator has their own terminal view
>
> ⚠️ **Security Warning:** Collaborators get complete access to your entire workspace, including all files, secrets, and terminal. Only share with people you fully trust.
>
> **Alternative for app preview only:** Use Preview → Make Preview Public to share just your running application without giving code access.

## Done! 🎉

Excellent work! You've configured a professional cloud-based development environment with Firebase Studio. This setup gives you access to Azure infrastructure, Google Cloud services, and AI-assisted development from any device with a browser. You're now ready to build, deploy, and manage cloud applications without local environment configuration.
