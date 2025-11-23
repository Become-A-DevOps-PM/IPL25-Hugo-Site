+++
title = "Python"
description = "Install Python 3.11+"
weight = 3
+++

# Python 3.11+ (Programming Language)

---

## PC (Windows)

### Option A: Using winget (recommended)

```bash
winget install Python.Python.3.11
```

### Option B: Manual download

1. Download from [https://www.python.org/downloads/](https://www.python.org/downloads/)
2. Download **Python 3.11.x** (or later)
3. Run installer `python-3.11.x-amd64.exe`
4. ✅ **CRITICAL:** Check "Add Python to PATH"
5. Choose "Install Now"
6. **Restart Git Bash after installation**

### Verification

```bash
# Restart Git Bash first
python --version
# OR
python3 --version

# Verify pip
pip --version
```

---

## Mac (Intel and ARM)

### Using Homebrew

```bash
brew install python@3.11
```

### Verification

```bash
python3 --version
pip3 --version
```

**Note for ARM Mac:** Homebrew installs native ARM version.

---

## Verify Python Version (All Platforms)

Ensure version is 3.11 or higher:

```bash
python3 --version
```

**Expected output:** `Python 3.11.x` or `Python 3.12.x` or higher

---

## Troubleshooting

### Python not found (PC)

- **Solution:** Ensure you checked "Add Python to PATH" during installation
- **Fix:** Reinstall Python and check the PATH option
- **Verification:** Restart Git Bash after installation
