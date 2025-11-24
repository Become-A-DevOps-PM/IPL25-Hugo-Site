+++
title = "Setup Overview"
description = "Complete setup checklist and verification"
weight = 20
+++

# Setup Overview

Complete installation checklist for the DevOps PM course. Follow the tutorials in order to set up all required tools.

**Time Estimate:** 60-90 minutes total

---

## Installation Order

Follow this order to ensure dependencies are met:

### 1. Prerequisites

- [ ] [Package Managers](/tutorials/setup/package-managers/) (Mac: Homebrew required, PC: winget optional)

### 2. Accounts

- [ ] [Azure Account](/tutorials/setup/azure/account/) (pay-as-you-go)
- [ ] [GitHub Account](/tutorials/setup/github/account/)

### 3. Development Environment

- [ ] [Git](/tutorials/setup/development/git/) (PC: includes Git Bash)
- [ ] [Visual Studio Code](/tutorials/setup/development/vscode/)
- [ ] [Python 3.11+](/tutorials/setup/development/python/)
- [ ] [PostgreSQL](/tutorials/setup/development/postgresql/)

### 4. Cloud & Infrastructure Tools

- [ ] [Azure CLI + Bicep](/tutorials/setup/azure/cli/)
- [ ] [GitHub CLI](/tutorials/setup/github/cli/)

### 5. AI Tools (Recommended)

- [ ] [Gemini](/tutorials/setup/ai-tools/gemini/) (recommended - free with CLI)
- [ ] [Claude](/tutorials/setup/ai-tools/claude/) (optional)
- [ ] [ChatGPT](/tutorials/setup/ai-tools/chatgpt/) (optional)

---

## Verification Script

After installing all tools, verify your setup:

**IMPORTANT: Run verification script in:**

- **PC:** Git Bash
- **Mac:** Terminal

### Download and run

**Option A: Download and run locally**

```bash
# PC: Run in Git Bash | Mac: Run in Terminal

# Download script
curl -fsSL https://raw.githubusercontent.com/Become-A-DevOps-PM/onboarding/main/verify-setup.sh -o verify-setup.sh

# Make executable
chmod +x verify-setup.sh

# Run
./verify-setup.sh
```

**Option B: Run directly (without download)**

```bash
curl -fsSL https://raw.githubusercontent.com/Become-A-DevOps-PM/onboarding/main/verify-setup.sh | bash
```

---

## Expected Results

### ✅ Success - All Tools Installed

```text
✅ WEEK 1: OK
✅ ALL: OK

🎉 You are fully prepared for the entire course!
```

### ⚠️ Partial - Week 1 Ready, Missing Some Tools

```text
✅ WEEK 1: OK
❌ ALL: NOT OK

⚠️  You are ready for Week 1, but missing tools for the full course.
```

### ❌ Not Ready - Missing Week 1 Tools

```text
❌ WEEK 1: NOT OK
❌ ALL: NOT OK

❌ You are NOT ready for Week 1.
```

---

## Quick Reference: Installation Commands

### PC (Windows) - Using winget

**IMPORTANT: Terminal to use:**

- **winget commands:** Use PowerShell or Command Prompt (winget doesn't work in Git Bash)
- **All other commands (az, gh, npm, git, etc.):** Use Git Bash

```bash
# ========================================
# RUN IN POWERSHELL OR COMMAND PROMPT:
# ========================================

# Git for Windows
winget install Git.Git

# VS Code
winget install Microsoft.VisualStudioCode

# Azure CLI
winget install Microsoft.AzureCLI

# GitHub CLI
winget install GitHub.cli

# Python 3.11+
winget install Python.Python.3.11

# ========================================
# AFTER INSTALLING GIT, RUN IN GIT BASH:
# ========================================

# Bicep (via Azure CLI)
az bicep install

# Git configuration
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Mac - Using Homebrew

```bash
# Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Git
brew install git

# Azure CLI
brew install azure-cli

# GitHub CLI
brew install gh

# Python 3.11+
brew install python@3.11

# PostgreSQL
brew install postgresql@14
brew services start postgresql@14

# Bicep (via Azure CLI)
az bicep install

# Gemini CLI
brew install gemini-cli
```

---

## Post-Installation Checklist

Once all tools are installed:

- [ ] Azure account created (pay-as-you-go)
- [ ] GitHub account created
- [ ] Git installed and configured
- [ ] VS Code installed
- [ ] **PC only:** Git Bash set as VS Code default terminal
- [ ] Azure CLI installed and authenticated (`az login`)
- [ ] GitHub CLI installed and authenticated (`gh auth login`)
- [ ] Bicep CLI installed (`az bicep version` works)
- [ ] Python 3.11+ installed
- [ ] PostgreSQL client installed
- [ ] AI Chatbot account created (Gemini recommended)
- [ ] AI CLI tool installed (Gemini CLI recommended)
- [ ] Verification script shows: **✅ WEEK 1: OK** and **✅ ALL: OK**
- [ ] Azure billing alerts configured (recommended)
- [ ] Azure MFA/2FA enabled (required)
- [ ] GitHub 2FA enabled (required)

---

## Troubleshooting

### Common Issues

#### Azure CLI not found (PC)

- **Solution:** Restart Git Bash after installation
- **Alternative:** Add to PATH manually:

```bash
echo 'export PATH="/c/Program Files/Microsoft SDKs/Azure/CLI2/wbin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Python not found (PC)

- **Solution:** Ensure you checked "Add Python to PATH" during installation
- **Fix:** Reinstall Python and check the PATH option
- **Verification:** Restart Git Bash

#### `code` command not found (Mac)

- **Solution:** Open VS Code and run "Shell Command: Install 'code' command in PATH"

#### Git Bash not default terminal in VS Code (PC)

- **Solution:** Open VS Code → `Ctrl+Shift+P` → "Terminal: Select Default Profile" → "Git Bash"

#### Homebrew installation issues (Mac)

- **Check:** Ensure Xcode Command Line Tools are installed first:

```bash
xcode-select --install
```

- **Follow:** Post-installation instructions to add Homebrew to PATH

#### psql not found (PC)

- **Solution:** Ensure PostgreSQL bin folder is in PATH
- **Check:** `C:\Program Files\PostgreSQL\16\bin` exists

---

## Next Steps

1. **Set up Azure billing alerts** (if not already done)
2. **Wait for Day 1 instructions**
3. **We will have some time during the course to troubleshoot as well**

---

## Support

**Installation issues?**

- Check troubleshooting section above
- Search error messages online

**Ready for the course?**

- Run verification script: `./verify-setup.sh`
- Expected output: ✅ WEEK 1: OK and ✅ ALL: OK
