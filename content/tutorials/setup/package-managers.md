+++
title = "Package Managers"
description = "Install package managers for your platform"
weight = 1
+++

# Package Managers

Package managers simplify installing and updating software. Set these up first before installing other tools.

---

## PC (Windows) - Optional: winget

Windows Package Manager (winget) is **optional but recommended** for easier installation.

### Check if installed

```bash
winget --version
```

### If not installed

- Built into Windows 11 by default
- Windows 10: Install from Microsoft Store: "App Installer"

**Alternative:** Download installers manually (instructions provided in each tool's tutorial)

---

## Mac - Required: Homebrew

Homebrew is **strongly recommended** for Mac users.

### Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Follow post-installation instructions displayed in terminal** (add Homebrew to PATH)

### Installation paths

- **Mac ARM (Apple Silicon):** Homebrew installs to `/opt/homebrew`
- **Mac Intel:** Homebrew installs to `/usr/local`

### Verification

```bash
brew --version
```

### Troubleshooting

If Homebrew installation fails, ensure Xcode Command Line Tools are installed first:

```bash
xcode-select --install
```

Then retry the Homebrew installation.
