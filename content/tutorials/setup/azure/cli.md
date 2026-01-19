+++
title = "Azure CLI"
program = "IPL"
cohort = "25"
courses = ["SNS"]
description = "Install Azure CLI and Bicep"
weight = 2
+++

# Azure CLI (Cloud Management)

The Azure CLI is your primary tool for managing Azure resources from the command line. This tutorial also covers Bicep CLI installation.

---

## PC (Windows)

### Option A: Using winget (recommended)

```bash
winget install Microsoft.AzureCLI
```

### Option B: Manual download

1. Download MSI installer from [https://aka.ms/installazurecli](https://aka.ms/installazurecli)
2. Run `azure-cli-*.msi`
3. Follow installer prompts
4. **Restart Git Bash after installation**

### Verification

```bash
# Restart Git Bash first
az --version
```

---

## Mac (Intel and ARM)

### Using Homebrew

```bash
brew install azure-cli
```

### Verification

```bash
az --version
```

**Note for ARM Mac:** Homebrew installs native ARM version.

---

## Authenticate with Azure (All Platforms)

After installation:

```bash
az login
```

- Browser window will open
- Sign in with your Azure account
- Terminal will show: "You have logged in"

### Verify authentication

```bash
az account show
```

### Set default subscription (if you have multiple)

```bash
# List subscriptions
az account list --output table

# Set default
az account set --subscription "Subscription Name"
```

---

## Bicep CLI (Infrastructure as Code)

Bicep CLI is installed via Azure CLI.

### Install Bicep

```bash
az bicep install
```

### Verification

```bash
az bicep version
```

**Expected output:** `Bicep CLI version 0.x.x`

---

## Troubleshooting

### Azure CLI not found (PC)

- **Solution:** Restart Git Bash after installation
- **Alternative:** Add to PATH manually:

```bash
echo 'export PATH="/c/Program Files/Microsoft SDKs/Azure/CLI2/wbin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
