+++
title = "PostgreSQL"
description = "Install PostgreSQL database"
weight = 4
+++

# PostgreSQL Client (Database Client)

**Note:** We use PostgreSQL for **both local development and Azure production** (no SQLite). This ensures:

- Production parity: Same database everywhere
- No migration headaches: What works locally works in Azure
- One database to learn: PostgreSQL only

---

## PC (Windows)

**Manual installation required:**

1. Download PostgreSQL installer from [https://www.postgresql.org/download/windows/](https://www.postgresql.org/download/windows/)
2. Run installer `postgresql-*.exe` (version 14 or later)
3. During installation:
   - ✅ Check "PostgreSQL Server" (needed for local development)
   - ✅ Check "Command Line Tools" (includes psql)
   - ✅ Check "pgAdmin" (optional, but useful for database management)
   - ❌ Uncheck "Stack Builder" (optional, can skip)
   - Set password for database superuser (postgres) - **remember this password!**
   - Use default port: 5432
4. Complete installation
5. **Restart Git Bash after installation**

### Verify service is running

PostgreSQL service should start automatically on Windows. To verify:

- Run: `services.msc`
- Look for "postgresql-x64-14" (or similar) - should show "Running"

### Add to PATH (if not automatic)

```bash
# Add to ~/.bashrc in Git Bash
echo 'export PATH="/c/Program Files/PostgreSQL/16/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Verification

```bash
# Restart Git Bash first
psql --version

# Test connection to local database
psql -U postgres -h localhost
# Enter the password you set during installation
# Type \q to quit
```

---

## Mac (Intel and ARM)

### Using Homebrew

```bash
# Install PostgreSQL (includes both client and server)
brew install postgresql@14
```

### Start PostgreSQL service

```bash
# Start PostgreSQL service and enable auto-start on system boot
brew services start postgresql@14
```

### Verification

```bash
# Check version
psql --version

# Verify service is running
brew services list | grep postgresql

# Test connection to local database
psql -U $(whoami) -d postgres
# Type \q to quit
```

**Note for ARM Mac:** Homebrew installs native ARM version.

---

## Troubleshooting

### psql not found (PC)

- **Solution:** Ensure PostgreSQL bin folder is in PATH
- **Check:** `C:\Program Files\PostgreSQL\16\bin` exists
- **Add to PATH:** See installation section above

### Connection fails on Mac

If `psql -U $(whoami) -d postgres` fails, create your user database:

```bash
createdb $(whoami)
psql
```
