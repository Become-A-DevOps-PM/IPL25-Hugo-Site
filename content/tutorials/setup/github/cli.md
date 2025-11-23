+++
title = "GitHub CLI"
description = "Install GitHub CLI"
weight = 2
+++

# GitHub CLI (Repository Management)

---

## PC (Windows)

### Option A: Using winget (recommended)

```bash
winget install GitHub.cli
```

### Option B: Manual download

1. Download from [https://cli.github.com/](https://cli.github.com/)
2. Download Windows MSI installer
3. Run `gh_*_windows_amd64.msi`
4. **Restart Git Bash after installation**

### Verification

```bash
# Restart Git Bash first
gh --version
```

---

## Mac (Intel and ARM)

### Using Homebrew

```bash
brew install gh
```

### Verification

```bash
gh --version
```

**Note for ARM Mac:** Homebrew installs native ARM version.

---

## Authenticate with GitHub (All Platforms)

After installation:

```bash
gh auth login
```

### Follow prompts

1. Choose: **GitHub.com**
2. Choose: **HTTPS**
3. Choose: **Login with a web browser**
4. Copy the one-time code shown
5. Press Enter to open browser
6. Paste code and authorize

### Verify authentication

```bash
gh auth status
```
