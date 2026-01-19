+++
title = "Visual Studio Code"
program = "IPL"
cohort = "25"
courses = ["SNS"]
description = "Install VS Code and extensions"
weight = 2
+++

# Visual Studio Code (IDE)

---

## PC (Windows)

### Option A: Using winget

```bash
winget install Microsoft.VisualStudioCode
```

### Option B: Manual download

1. Download from [https://code.visualstudio.com/](https://code.visualstudio.com/)
2. Run installer `VSCodeSetup-x64-*.exe`
3. Accept defaults
4. ✅ Check "Add to PATH" (important)

### Configure Git Bash as default terminal

1. Open VS Code
2. Press `Ctrl+Shift+P` (Command Palette)
3. Type "Terminal: Select Default Profile"
4. Select **"Git Bash"**

### Verification

```bash
# In Git Bash
code --version
```

---

## Mac (Intel)

1. Download from [https://code.visualstudio.com/](https://code.visualstudio.com/)
2. Download **"Mac Intel Chip"** version
3. Open downloaded `.zip` file
4. Drag `Visual Studio Code.app` to `Applications` folder

### Add to PATH

1. Open VS Code
2. Press `Cmd+Shift+P` (Command Palette)
3. Type "Shell Command: Install 'code' command in PATH"
4. Press Enter

### Verification

```bash
code --version
```

---

## Mac (ARM / Apple Silicon)

1. Download from [https://code.visualstudio.com/](https://code.visualstudio.com/)
2. Download **"Mac Apple Silicon"** version
3. Open downloaded `.zip` file
4. Drag `Visual Studio Code.app` to `Applications` folder

### Add to PATH

1. Open VS Code
2. Press `Cmd+Shift+P` (Command Palette)
3. Type "Shell Command: Install 'code' command in PATH"
4. Press Enter

### Verification

```bash
code --version
```

**Note:** Native ARM version provides better performance on Apple Silicon.

---

## Essential Extensions

After installing VS Code, install these extensions for the course:

### Python Development

- **Python** (`ms-python.python`) - Official Python extension with IntelliSense, debugging, linting
- **Pylance** (`ms-python.vscode-pylance`) - Fast Python language server with type checking

### Database (PostgreSQL)

- **SQLTools** (`mtxr.sqltools`) - Database management and query execution
- **SQLTools PostgreSQL Driver** (`mtxr.sqltools-driver-pg`) - PostgreSQL driver for SQLTools

### Azure & Infrastructure

- **Bicep** (`ms-azuretools.vscode-bicep`) - Official Bicep language support
- **Azure Account** (`ms-vscode.azure-account`) - Sign in to Azure and manage subscriptions
- **Azure Resources** (`ms-azuretools.vscode-azureresourcegroups`) - View and manage Azure resources

### Remote Development

- **Remote - SSH** (`ms-vscode-remote.remote-ssh`) - Connect to Azure VMs via SSH

### Code Quality

- **GitLens** (`eamodio.gitlens`) - Supercharge Git with blame annotations, history, and more

### Configuration & Scripting

- **YAML** (`redhat.vscode-yaml`) - YAML language support for config files
- **Bash IDE** (`mads-hartmann.bash-ide-vscode`) - Bash scripting support with linting

---

## Install All Essential Extensions at Once

### PC (Windows) - Git Bash

```bash
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension mtxr.sqltools
code --install-extension mtxr.sqltools-driver-pg
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-vscode.azure-account
code --install-extension ms-azuretools.vscode-azureresourcegroups
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension eamodio.gitlens
code --install-extension redhat.vscode-yaml
code --install-extension mads-hartmann.bash-ide-vscode
```

### Mac (Intel and ARM) - Terminal

```bash
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension mtxr.sqltools
code --install-extension mtxr.sqltools-driver-pg
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-vscode.azure-account
code --install-extension ms-azuretools.vscode-azureresourcegroups
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension eamodio.gitlens
code --install-extension redhat.vscode-yaml
code --install-extension mads-hartmann.bash-ide-vscode
```

### Verify Extensions Installed

```bash
code --list-extensions
```

---

## Optional Extensions

- **Markdown All in One** (`yzhang.markdown-all-in-one`) - Markdown editing with preview
- **EditorConfig** (`editorconfig.editorconfig`) - Maintain consistent coding styles
- **Docker** (`ms-azuretools.vscode-docker`) - Docker support (if you explore containers later)

---

## Configure SQLTools for PostgreSQL

After installing SQLTools extensions:

1. Open VS Code
2. Press `Ctrl+Shift+P` (PC) or `Cmd+Shift+P` (Mac)
3. Type "SQLTools: Add New Connection"
4. Select "PostgreSQL"
5. Configure connection (when needed):
   - **Connection name:** `Local PostgreSQL`
   - **Server:** `localhost`
   - **Port:** `5432`
   - **Database:** `postgres`
   - **Username:** `postgres` (PC) or your username (Mac)
   - **Password:** (your PostgreSQL password)
   - **SSL:** Disabled (for local development)

---

## Troubleshooting

### `code` command not found (Mac)

**Solution:** Open VS Code and run "Shell Command: Install 'code' command in PATH"

### Git Bash not default terminal in VS Code (PC)

**Solution:** Open VS Code → `Ctrl+Shift+P` → "Terminal: Select Default Profile" → "Git Bash"
