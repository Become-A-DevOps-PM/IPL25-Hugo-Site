#!/bin/bash
# =============================================================================
# VERIFICATION TEST SUITE FOR FLASK-BICEP DEPLOYMENT
# =============================================================================
# Comprehensive end-to-end tests to verify the deployment is working correctly.
#
# Test categories:
#
# Application Tests (E1-E4):
#   E1: Health endpoint         - GET /health returns {"status": "ok"}
#   E2: Homepage                - GET / contains "Flask Demo Application"
#   E3: Create entry            - POST / creates a new database entry
#   E4: List entries            - GET /entries returns JSON array
#
# Security Tests (E5-E6):
#   E5: App server no public IP - vm-app should not be directly accessible
#   E6: Database no public access - PostgreSQL public network access disabled
#
# Database Tests (E7-E8):
#   E7: Database connectivity   - App can connect to PostgreSQL
#   E8: Entries table exists    - SQLAlchemy created the schema
#
# Test execution:
#   - All tests run sequentially
#   - Results collected and displayed as markdown table
#   - Exit code equals number of failed tests (0 = all passed)
#
# SSH access pattern:
#   - Database tests require SSH to app server
#   - Uses ProxyCommand through bastion (not -J) for reliability
#   - See LESSONS-LEARNED.md Issue 2 for details
#
# Classification:
#   - PASS: All tests passed (exit 0)
#   - PARTIAL: More passes than failures
#   - FAIL: More failures than passes
#
# Usage:
#   ./scripts/verification-tests.sh
#
# Prerequisites:
#   - Infrastructure deployed (deploy-all.sh completed)
#   - Azure CLI logged in
#   - jq installed (for JSON parsing)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Source central configuration
source "$PROJECT_DIR/config.sh"

# -----------------------------------------------------------------------------
# Get VM IP Addresses
# -----------------------------------------------------------------------------
BASTION_IP=$(get_vm_public_ip "$VM_BASTION")
PROXY_IP=$(get_vm_public_ip "$VM_PROXY")

# -----------------------------------------------------------------------------
# Test Framework
# -----------------------------------------------------------------------------
PASS_COUNT=0
FAIL_COUNT=0
RESULTS=""

# Run a single test and record the result
run_test() {
    local name="$1"
    local result="$2"
    local expected="$3"
    local notes="$4"

    if [ "$result" = "$expected" ]; then
        PASS_COUNT=$((PASS_COUNT + 1))
        RESULTS="${RESULTS}| $name | PASS | $notes |\n"
        echo "[PASS] $name"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        RESULTS="${RESULTS}| $name | FAIL | Expected: $expected, Got: $result |\n"
        echo "[FAIL] $name (expected: $expected, got: $result)"
    fi
}

echo "=== Running Verification Tests ==="
echo ""

# -----------------------------------------------------------------------------
# Application Tests (E1-E4)
# -----------------------------------------------------------------------------
# These tests verify the Flask application is responding correctly through
# the nginx reverse proxy. All requests go: curl -> nginx (proxy) -> Gunicorn (app)

# E1: Health endpoint
echo "Testing health endpoint..."
HEALTH_RESULT=$(curl -sk "https://$PROXY_IP/health" 2>/dev/null | jq -r '.status' 2>/dev/null || echo "failed")
run_test "Health endpoint (/health)" "$HEALTH_RESULT" "ok" "Response: {\"status\": \"ok\"}"

# E2: Homepage
echo "Testing homepage..."
HOMEPAGE=$(curl -sk "https://$PROXY_IP/" 2>/dev/null)
if echo "$HOMEPAGE" | grep -q "Flask Demo Application"; then
    run_test "Homepage (/)" "found" "found" "Contains 'Flask Demo Application'"
else
    run_test "Homepage (/)" "not_found" "found" "Missing expected content"
fi

# E3: Create entry
echo "Testing create entry..."
CREATE_CODE=$(curl -sk -X POST "https://$PROXY_IP/" -d "value=verification-test-$(date +%s)" -w '%{http_code}' -o /dev/null 2>/dev/null)
if [ "$CREATE_CODE" = "200" ] || [ "$CREATE_CODE" = "302" ]; then
    run_test "Create entry (POST /)" "success" "success" "HTTP $CREATE_CODE"
else
    run_test "Create entry (POST /)" "failed" "success" "HTTP $CREATE_CODE"
fi

# E4: List entries
echo "Testing list entries..."
ENTRIES=$(curl -sk "https://$PROXY_IP/entries" 2>/dev/null)
if echo "$ENTRIES" | jq -e '. | length > 0' >/dev/null 2>&1; then
    run_test "List entries (/entries)" "has_entries" "has_entries" "JSON array returned"
else
    run_test "List entries (/entries)" "empty" "has_entries" "No entries found"
fi

# -----------------------------------------------------------------------------
# Security Tests (E5-E6)
# -----------------------------------------------------------------------------
# These tests verify the infrastructure security configuration.
# The app server should only be reachable through the reverse proxy.
# The database should only be reachable from the app server's subnet.

# E5: App server no public IP
echo "Testing app server security..."
APP_PUBLIC_IP=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_APP" --show-details -o tsv --query publicIps 2>/dev/null)
if [ -z "$APP_PUBLIC_IP" ] || [ "$APP_PUBLIC_IP" = "None" ]; then
    run_test "App server no public IP" "none" "none" "Security verified"
else
    run_test "App server no public IP" "has_ip" "none" "Found: $APP_PUBLIC_IP"
fi

# E6: Database no public access
echo "Testing database security..."
DB_PUBLIC=$(az postgres flexible-server show -g "$RESOURCE_GROUP" -n "$POSTGRES_SERVER" --query network.publicNetworkAccess -o tsv 2>/dev/null || echo "Unknown")
if [ "$DB_PUBLIC" = "Disabled" ]; then
    run_test "Database no public access" "Disabled" "Disabled" "Security verified"
else
    run_test "Database no public access" "$DB_PUBLIC" "Disabled" "Public access found"
fi

# -----------------------------------------------------------------------------
# Database Tests (E7-E8)
# -----------------------------------------------------------------------------
# These tests verify the Flask app can connect to PostgreSQL and that
# SQLAlchemy created the expected schema. Requires SSH access to app server.

# E7: Database connectivity
echo "Testing database connectivity..."
DB_TEST=$(ssh_via_bastion "$VM_APP" "source /etc/flask-app/app.env && psql \"\$DATABASE_URL\" -c 'SELECT 1;' 2>&1" 2>/dev/null)
if echo "$DB_TEST" | grep -q "1 row"; then
    run_test "Database connectivity" "connected" "connected" "SELECT 1 succeeded"
else
    run_test "Database connectivity" "failed" "connected" "Connection error"
fi

# E8: Entries table exists
echo "Testing entries table..."
TABLE_TEST=$(ssh_via_bastion "$VM_APP" "source /etc/flask-app/app.env && psql \"\$DATABASE_URL\" -c '\\dt entries' 2>&1" 2>/dev/null)
if echo "$TABLE_TEST" | grep -q "entries"; then
    run_test "Entries table exists" "exists" "exists" "Table found in database"
else
    run_test "Entries table exists" "missing" "exists" "Table not found"
fi

# -----------------------------------------------------------------------------
# Test Summary
# -----------------------------------------------------------------------------
echo ""
echo "=== Test Summary ==="
TOTAL=$((PASS_COUNT + FAIL_COUNT))
echo "Total: $TOTAL | Passed: $PASS_COUNT | Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -eq 0 ]; then
    CLASSIFICATION="PASS"
elif [ $PASS_COUNT -gt $FAIL_COUNT ]; then
    CLASSIFICATION="PARTIAL"
else
    CLASSIFICATION="FAIL"
fi

echo "Classification: $CLASSIFICATION"

# Output results table
echo ""
echo "| Test | Result | Notes |"
echo "|------|--------|-------|"
echo -e "$RESULTS"

exit $FAIL_COUNT
