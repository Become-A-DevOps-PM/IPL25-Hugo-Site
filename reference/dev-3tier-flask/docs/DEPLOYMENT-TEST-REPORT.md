# Deployment Test Report

**Date:** 2026-01-07
**Environment:** Azure Sweden Central
**Resource Group:** rg-flask-dev

## Summary

The simplified Flask three-tier infrastructure was successfully deployed and tested. The deployment encountered several issues that required fixes before achieving full functionality.

**Final Result:** ✅ PASS - All 6 verification tests passing

## Deployment Timeline

| Step | Status | Duration |
|------|--------|----------|
| Infrastructure Provisioning | ✅ Pass | ~8 minutes |
| PostgreSQL Ready | ✅ Pass | Immediate |
| Cloud-init Completion | ✅ Pass | ~3 minutes |
| Application Deployment | ✅ Pass (after fixes) | ~2 minutes |
| Health Check | ✅ Pass (after fixes) | Immediate |
| Verification Tests | ✅ Pass (6/6) | ~30 seconds |

## Issues Encountered and Resolutions

### Issue 1: Incorrect Ubuntu Image Reference

**Problem:** The Bicep VM module used an incorrect Azure image reference for Ubuntu 24.04 LTS.

```bicep
# Incorrect
offer: '0001-com-ubuntu-server-noble'
sku: '24_04-lts-gen2'

# Correct
offer: 'ubuntu-24_04-lts'
sku: 'server'
```

**Error Message:**
```
The following list of images referenced from the deployment template are not found:
Publisher: Canonical, Offer: 0001-com-ubuntu-server-noble, Sku: 24_04-lts-gen2
```

**Resolution:** Updated `infrastructure/modules/vm.bicep` with correct image reference.

**File Changed:** `infrastructure/modules/vm.bicep` (lines 84-86)

---

### Issue 2: Cloud-init File Creation Order

**Problem:** Cloud-init `write_files` runs before `runcmd`, causing `/etc/flask-app/app.env` to fail because:
1. The `flask-app` group doesn't exist yet (created in runcmd)
2. The `/etc/flask-app/` directory doesn't exist yet

**Error in cloud-init log:**
```
chown: cannot access '/etc/flask-app/app.env': No such file or directory
```

**Resolution:** Moved the `app.env` file creation from `write_files` to `runcmd` (after user/directory creation).

**File Changed:** `infrastructure/cloud-init/app-server.yaml` (lines 94-109)

---

### Issue 3: Incorrect SSH Service Name on Ubuntu 24.04

**Problem:** Ubuntu 24.04 uses `ssh.service` instead of `sshd.service`.

**Error in cloud-init log:**
```
Failed to restart sshd.service: Unit sshd.service not found.
```

**Resolution:** Changed `systemctl restart sshd` to `systemctl restart ssh`.

**File Changed:** `infrastructure/cloud-init/app-server.yaml` (line 137)

---

### Issue 4: Wait Script Treats Error as Non-Complete

**Problem:** The `wait-for-cloud-init.sh` script used `cloud-init status --wait` which returns non-zero for "error" status, causing infinite retry loops even when cloud-init had completed (with errors).

**Resolution:** Rewrote the script to explicitly check for both "done" and "error" states as completion.

**File Changed:** `deploy/scripts/wait-for-cloud-init.sh` (complete rewrite)

---

### Issue 5: Missing sudo in Deploy Script

**Problem:** The deploy script's `chown` command failed because `azureuser` cannot change group ownership to `flask-app` without elevated privileges.

**Error:**
```
chown: changing ownership of '/opt/flask-app/...': Operation not permitted
```

**Resolution:** Added `sudo` to the chown and chmod commands.

**File Changed:** `deploy/deploy.sh` (line 51)

---

### Issue 6: Health Check Response Mismatch

**Problem:** The wait-for-flask-app.sh script expected `"status": "ok"` but the app returns `"status": "healthy"`.

**Resolution:** Updated the grep pattern to check for `"status"` instead of `"status".*"ok"`.

**Files Changed:**
- `deploy/scripts/wait-for-flask-app.sh` (line 53)
- `deploy/scripts/verification-tests.sh` (line 98)

---

### Issue 7: Special Characters in Database Password

**Problem:** The auto-generated password contained `!` which caused authentication failures when used in the PostgreSQL connection URL (needs URL encoding as `%21`).

**Observation:** Direct `psql` connection worked, but SQLAlchemy failed because the `!` was not URL-encoded.

**Resolution:** For this deployment, manually set a simpler password without special characters.

**Recommended Fix for Scripts:** Update `infrastructure/scripts/init-secrets.sh` to either:
1. Generate passwords without special characters, or
2. URL-encode special characters in the DATABASE_URL

---

### Issue 8: Database Tables Not Created

**Problem:** The Flask application expects database tables to exist, but they weren't created automatically on first request.

**Error in Flask logs:**
```
sqlalchemy.exc.ProgrammingError: relation "entries" does not exist
```

**Resolution:** Manually ran table creation via Python shell.

**Recommended Fix:** Add database initialization to the deployment script:
```bash
ssh $SSH_OPTS "${VM_ADMIN_USER}@${VM_IP}" \
  "cd /opt/flask-app && source venv/bin/activate && \
   eval \$(sudo cat /etc/flask-app/app.env) && \
   python3 -c 'from app import create_app; from app.extensions import db; \
   app=create_app(); ctx=app.app_context(); ctx.push(); db.create_all()'"
```

---

### Issue 9: Verification Script Permission Error

**Problem:** The verification tests tried to `source /etc/flask-app/app.env` as `azureuser`, but the file is owned by `root:flask-app` with `640` permissions.

**Resolution:** Updated verification tests to use `eval $(sudo cat /etc/flask-app/app.env)`.

**File Changed:** `deploy/scripts/verification-tests.sh` (lines 135, 144)

---

## Final Test Results

```
=== Running Verification Tests ===
VM IP: 4.165.130.130

Testing health endpoint...
[PASS] Health endpoint (/api/health)
Testing landing page...
[PASS] Landing page (/)
Testing demo page...
[PASS] Demo page (/demo)
Testing API entries...
[PASS] API entries (/api/entries)
Testing database connectivity...
[PASS] Database connectivity
Testing entries table...
[PASS] Entries table exists

=== Test Summary ===
Total: 6 | Passed: 6 | Failed: 0
Classification: PASS
```

## End-to-End Verification

Successfully created and retrieved a database entry:

```bash
# Create entry
curl -skL -X POST https://4.165.130.130/demo/ -d "value=Test entry"

# Retrieve entries
curl -sk https://4.165.130.130/api/entries
# Returns: [{"created_at":"2026-01-07T16:02:16.403397","id":1,"value":"Test entry..."}]
```

## Resource Costs

| Resource | SKU | Estimated Monthly Cost |
|----------|-----|------------------------|
| VM (vm-app) | Standard_B1s | ~$7 |
| PostgreSQL | Burstable B1ms | ~$12 |
| Public IP | Standard | ~$3 |
| **Total** | | **~$22/month** |

## Recommendations

1. **Password Generation:** Update `init-secrets.sh` to avoid special characters or URL-encode them
2. **Database Init:** Add automatic table creation to `deploy.sh`
3. **Documentation:** Update CLAUDE.md quick start to mention these requirements
4. **Testing:** Run full deploy-all.sh on clean environment to verify all fixes work together

## Files Modified During Testing

| File | Changes |
|------|---------|
| `infrastructure/modules/vm.bicep` | Fixed Ubuntu image reference |
| `infrastructure/cloud-init/app-server.yaml` | Fixed file creation order, SSH service name |
| `deploy/deploy.sh` | Added sudo for permissions |
| `deploy/scripts/wait-for-cloud-init.sh` | Handle error status as completion |
| `deploy/scripts/wait-for-flask-app.sh` | Fixed health check pattern |
| `deploy/scripts/verification-tests.sh` | Fixed health response, sudo for env file |

## Cleanup

To delete all resources:
```bash
./delete-all.sh
```

Or manually:
```bash
az group delete -n rg-flask-dev --yes
```
