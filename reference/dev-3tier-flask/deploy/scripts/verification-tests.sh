#!/bin/bash
# =============================================================================
# VERIFICATION TEST SUITE FOR SIMPLIFIED FLASK DEPLOYMENT
# =============================================================================
# End-to-end tests to verify the deployment is working correctly.
#
# Test categories:
#
# Application Tests (E1-E4):
#   E1: Health endpoint         - GET /api/health returns {"status": "ok"}
#   E2: Landing page            - GET / returns landing page
#   E3: Demo page               - GET /demo returns demo form
#   E4: API entries             - GET /api/entries returns JSON array
#
# Database Tests (E5-E6):
#   E5: Database connectivity   - App can connect to PostgreSQL
#   E6: Entries table exists    - SQLAlchemy created the schema
#
# Test execution:
#   - All tests run sequentially
#   - Results collected and displayed as markdown table
#   - Exit code equals number of failed tests (0 = all passed)
#
# SSH access:
#   - Database tests require SSH to app VM
#   - Uses direct SSH (single VM architecture)
#
# Classification:
#   - PASS: All tests passed (exit 0)
#   - PARTIAL: More passes than failures
#   - FAIL: More failures than passes
#
# Usage:
#   ./deploy/scripts/verification-tests.sh
#
# Prerequisites:
#   - Infrastructure deployed
#   - Azure CLI logged in
#   - jq installed (for JSON parsing)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Source central configuration
source "$PROJECT_DIR/config.sh"

# -----------------------------------------------------------------------------
# Get VM IP Address
# -----------------------------------------------------------------------------
VM_IP=$(get_vm_public_ip)

if [ -z "$VM_IP" ]; then
    echo "ERROR: Could not get VM public IP. Is the infrastructure deployed?"
    exit 1
fi

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
echo "VM IP: $VM_IP"
echo ""

# -----------------------------------------------------------------------------
# Application Tests (E1-E4)
# -----------------------------------------------------------------------------
# These tests verify the Flask application is responding correctly through
# the nginx reverse proxy. All requests go: curl -> nginx -> Gunicorn

# E1: Health endpoint
echo "Testing health endpoint..."
HEALTH_RESULT=$(curl -sk "https://$VM_IP/api/health" 2>/dev/null | jq -r '.status' 2>/dev/null || echo "failed")
run_test "Health endpoint (/api/health)" "$HEALTH_RESULT" "ok" "Response: {\"status\": \"ok\"}"

# E2: Landing page
echo "Testing landing page..."
LANDING=$(curl -sk "https://$VM_IP/" 2>/dev/null)
if echo "$LANDING" | grep -qi "flask\|welcome\|landing"; then
    run_test "Landing page (/)" "found" "found" "Landing page served"
else
    run_test "Landing page (/)" "not_found" "found" "Missing expected content"
fi

# E3: Demo page
echo "Testing demo page..."
DEMO=$(curl -sk "https://$VM_IP/demo" 2>/dev/null)
if echo "$DEMO" | grep -qi "demo\|entry\|form"; then
    run_test "Demo page (/demo)" "found" "found" "Demo page served"
else
    run_test "Demo page (/demo)" "not_found" "found" "Missing expected content"
fi

# E4: API entries
echo "Testing API entries..."
ENTRIES=$(curl -sk "https://$VM_IP/api/entries" 2>/dev/null)
if echo "$ENTRIES" | jq -e '. | type == "array"' >/dev/null 2>&1; then
    run_test "API entries (/api/entries)" "array" "array" "JSON array returned"
else
    run_test "API entries (/api/entries)" "invalid" "array" "Not a valid JSON array"
fi

# -----------------------------------------------------------------------------
# Database Tests (E5-E6)
# -----------------------------------------------------------------------------
# These tests verify the Flask app can connect to PostgreSQL and that
# SQLAlchemy created the expected schema. Requires SSH access to VM.

# E5: Database connectivity
echo "Testing database connectivity..."
DB_TEST=$(ssh_to_vm "eval \$(sudo cat /etc/flask-app/app.env) && psql \"\$DATABASE_URL\" -c 'SELECT 1;' 2>&1" 2>/dev/null || echo "connection failed")
if echo "$DB_TEST" | grep -q "1 row"; then
    run_test "Database connectivity" "connected" "connected" "SELECT 1 succeeded"
else
    run_test "Database connectivity" "failed" "connected" "Connection error"
fi

# E6: Entries table exists
echo "Testing entries table..."
TABLE_TEST=$(ssh_to_vm "eval \$(sudo cat /etc/flask-app/app.env) && psql \"\$DATABASE_URL\" -c '\\dt entries' 2>&1" 2>/dev/null || echo "table check failed")
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
