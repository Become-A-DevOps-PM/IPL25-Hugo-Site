#!/bin/bash
# Comprehensive verification test suite for Flask Bicep deployment
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

RG="rg-flask-bicep-dev"
POSTGRES_SERVER="psql-flask-bicep-dev"

# Get IPs
BASTION_IP=$(az vm show -g $RG -n vm-bastion --show-details -o tsv --query publicIps)
PROXY_IP=$(az vm show -g $RG -n vm-proxy --show-details -o tsv --query publicIps)

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

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
echo ""

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

# E5: App server no public IP
echo "Testing app server security..."
APP_PUBLIC_IP=$(az vm show -g $RG -n vm-app --show-details -o tsv --query publicIps 2>/dev/null)
if [ -z "$APP_PUBLIC_IP" ] || [ "$APP_PUBLIC_IP" = "None" ]; then
    run_test "App server no public IP" "none" "none" "Security verified"
else
    run_test "App server no public IP" "has_ip" "none" "Found: $APP_PUBLIC_IP"
fi

# E6: Database no public access
echo "Testing database security..."
DB_PUBLIC=$(az postgres flexible-server show -g $RG -n $POSTGRES_SERVER --query network.publicNetworkAccess -o tsv 2>/dev/null || echo "Unknown")
if [ "$DB_PUBLIC" = "Disabled" ]; then
    run_test "Database no public access" "Disabled" "Disabled" "Security verified"
else
    run_test "Database no public access" "$DB_PUBLIC" "Disabled" "Public access found"
fi

# E7: Database connectivity
echo "Testing database connectivity..."
DB_TEST=$(ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app \
    "source /etc/flask-app/database.env && psql \"\$DATABASE_URL\" -c 'SELECT 1;' 2>&1" 2>/dev/null)
if echo "$DB_TEST" | grep -q "1 row"; then
    run_test "Database connectivity" "connected" "connected" "SELECT 1 succeeded"
else
    run_test "Database connectivity" "failed" "connected" "Connection error"
fi

# E8: Entries table exists
echo "Testing entries table..."
TABLE_TEST=$(ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app \
    "source /etc/flask-app/database.env && psql \"\$DATABASE_URL\" -c '\\dt entries' 2>&1" 2>/dev/null)
if echo "$TABLE_TEST" | grep -q "entries"; then
    run_test "Entries table exists" "exists" "exists" "Table found in database"
else
    run_test "Entries table exists" "missing" "exists" "Table not found"
fi

# Generate summary
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
