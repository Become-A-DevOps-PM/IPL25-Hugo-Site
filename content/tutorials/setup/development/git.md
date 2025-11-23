+++
title = "Git"
description = "Install Git version control"
weight = 1
+++

# Git (Version Control)

Git is required for version control and code management.

---

## PC (Windows): Git for Windows

**What you get:** Git + Git Bash (bash shell for Windows)

### Option A: Using winget (recommended)

```bash
winget install Git.Git
```

### Option B: Manual download

1. Download from [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Run installer `Git-2.x.x-64-bit.exe`
3. **Important installation options:**
   - ✅ Check "Git Bash Here"
   - ✅ Check "Git GUI Here"
   - ✅ Check "Git LFS"
   - ✅ Choose "Use Git from Git Bash only" (or "Use Git and optional Unix tools")
   - ✅ Choose "Checkout Windows-style, commit Unix-style line endings"
   - ✅ Choose "Use MinTTY (the default terminal of MSYS2)"
   - ✅ Choose default editor: **Visual Studio Code** (if already installed, otherwise Vim)

**IMPORTANT: After installation, ALWAYS use Git Bash for all commands!**

### Verification

```bash
# Open Git Bash (NOT PowerShell, NOT Command Prompt)
# Right-click desktop → "Git Bash Here" or search "Git Bash" in Start menu
git --version
```

---

## Mac (Intel and ARM): Git via Homebrew or Xcode

### Option A: Using Homebrew (recommended)

```bash
brew install git
```

### Option B: Xcode Command Line Tools

```bash
xcode-select --install
```

### Verification

```bash
git --version
```

**Note for ARM Mac:** Both methods install native ARM versions.

---

## Configure Git (All Platforms)

### Required configuration

```bash
git config --global user.name "Your Full Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

### Optional but recommended

```bash
git config --global core.editor "code --wait"
```

---

## Which Terminal to Use

### PC (Windows) Users

**ALWAYS use Git Bash for all terminal commands.**

- ❌ **DO NOT use:** PowerShell, Command Prompt (cmd), or Windows Terminal
- ✅ **ALWAYS use:** Git Bash

**How to open Git Bash:**

- Right-click on desktop → "Git Bash Here"
- Or: Start menu → search "Git Bash"
- Or: In VS Code → Open terminal and ensure Git Bash is selected

**Why Git Bash?**

- Provides bash shell on Windows (same as Mac/Linux)
- All course commands work in bash
- Avoids Windows-specific path and command issues

### Mac Users

**Use the built-in Terminal application.**

- Terminal.app (built-in)
- Or: iTerm2 (if you prefer)
- Uses bash or zsh by default (both work)

**How to open Terminal:**

- Applications → Utilities → Terminal
- Or: Cmd+Space → type "Terminal"
