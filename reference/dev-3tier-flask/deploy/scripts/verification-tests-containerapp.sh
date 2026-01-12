#!/bin/bash
# =============================================================================
# VERIFICATION TEST SUITE FOR CONTAINER APPS DEPLOYMENT
# =============================================================================
# End-to-end tests to verify the Container Apps deployment is working.
#
# Test categories:
#
# Application Tests (E1-E4):
#   E1: Health endpoint         - GET /api/health returns {"status": "ok"}
#   E2: Landing page            - GET / returns landing page
#   E3: Demo page               - GET /demo returns demo form
#   E4: API entries             - GET /api/entries returns JSON array
#
# Database Tests (E5):
#   E5: Registration endpoint   - GET /register loads (implies DB connectivity)
#
# Container App Tests (E6):
#   E6: HTTPS certificate       - Valid TLS certificate (managed by Azure)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Source central configuration
source "$PROJECT_DIR/config-containerapp.sh"

# Get Container App FQDN
APP_FQDN=$(get_container_app_fqdn)

if [ -z "$APP_FQDN" ]; then
    echo "ERROR: Could not get Container App FQDN. Is the app deployed?"
    exit 1
fi

BASE_URL="https://${APP_FQDN}"

# -----------------------------------------------------------------------------
# Test Framework
# -----------------------------------------------------------------------------
PASS_COUNT=0
FAIL_COUNT=0
RESULTS=""

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
echo "Container App: $CONTAINER_APP"
echo "Base URL:      $BASE_URL"
echo ""

# -----------------------------------------------------------------------------
# Application Tests (E1-E4)
# -----------------------------------------------------------------------------

# E1: Health endpoint
echo "Testing health endpoint..."
HEALTH_RESULT=$(curl -sk "${BASE_URL}/api/health" 2>/dev/null | jq -r '.status' 2>/dev/null || echo "failed")
run_test "Health endpoint (/api/health)" "$HEALTH_RESULT" "ok" "Response: {\"status\": \"ok\"}"

# E2: Landing page
echo "Testing landing page..."
LANDING=$(curl -sk "${BASE_URL}/" 2>/dev/null)
if echo "$LANDING" | grep -qi "flask\|welcome\|landing\|webinar"; then
    run_test "Landing page (/)" "found" "found" "Landing page served"
else
    run_test "Landing page (/)" "not_found" "found" "Missing expected content"
fi

# E3: Demo page
echo "Testing demo page..."
DEMO=$(curl -sk "${BASE_URL}/demo" 2>/dev/null)
if echo "$DEMO" | grep -qi "demo\|entry\|form"; then
    run_test "Demo page (/demo)" "found" "found" "Demo page served"
else
    run_test "Demo page (/demo)" "not_found" "found" "Missing expected content"
fi

# E4: API entries
echo "Testing API entries..."
ENTRIES=$(curl -sk "${BASE_URL}/api/entries" 2>/dev/null)
if echo "$ENTRIES" | jq -e '. | type == "array"' >/dev/null 2>&1; then
    run_test "API entries (/api/entries)" "array" "array" "JSON array returned"
else
    run_test "API entries (/api/entries)" "invalid" "array" "Not a valid JSON array"
fi

# E5: Registration page (implies database connectivity)
echo "Testing registration page..."
REGISTER=$(curl -sk "${BASE_URL}/register" 2>/dev/null)
if echo "$REGISTER" | grep -qi "register\|name\|email\|company"; then
    run_test "Registration page (/register)" "found" "found" "Database connectivity OK"
else
    run_test "Registration page (/register)" "not_found" "found" "Page not loading"
fi

# E6: HTTPS certificate validity
echo "Testing HTTPS certificate..."
CERT_CHECK=$(curl -s -o /dev/null -w "%{ssl_verify_result}" "${BASE_URL}/api/health" 2>/dev/null || echo "failed")
if [ "$CERT_CHECK" = "0" ]; then
    run_test "HTTPS certificate" "valid" "valid" "Managed certificate valid"
else
    run_test "HTTPS certificate" "invalid" "valid" "Certificate issue (code: $CERT_CHECK)"
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
