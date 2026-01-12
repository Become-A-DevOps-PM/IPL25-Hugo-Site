# Test Suite: Container Apps Deployment Verification

## Purpose

This document provides a comprehensive test suite for validating the Container Apps deployment of dev-3tier-flask. Each test case can be executed independently and includes clear pass/fail criteria.

**Estimated Total Time:** 15-20 minutes

## Prerequisites

Before running this test suite, ensure:

- [ ] Azure CLI installed (`az --version` returns 2.50+)
- [ ] Docker Desktop installed and running (`docker info` succeeds)
- [ ] `jq` installed (`jq --version` succeeds)
- [ ] Logged in to Azure (`az account show` succeeds)
- [ ] Working directory is `reference/dev-3tier-flask`

## Test Environment Setup

```bash
# Navigate to project directory
cd /Users/lasse/Developer/IPL_Development/IPL25-Hugo-Site/reference/dev-3tier-flask

# Source configuration
source config-containerapp.sh

# Print configuration for verification
print_config
```

---

## Phase 1: Infrastructure Provisioning

### Test 1.1: Resource Group Creation

**Objective:** Verify Azure resource group can be created.

**Steps:**

```bash
# Create resource group
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output table
```

**Expected Result:**

```
Location       Name
-------------  -----------------
swedencentral  rg-flask-dev-aca
```

**Verification:**

```bash
# Verify resource group exists
az group show --name "$RESOURCE_GROUP" --query "properties.provisioningState" -o tsv
```

**Pass Criteria:** Output is `Succeeded`

---

### Test 1.2: Parameters File Generation

**Objective:** Verify secrets file is created with valid SQL password.

**Steps:**

```bash
# Generate parameters file if not exists
if [ ! -f "infrastructure/parameters-containerapp.json" ]; then
    SQL_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=' | head -c 20)
    SQL_PASSWORD="${SQL_PASSWORD}Aa1!"

    cat > infrastructure/parameters-containerapp.json << EOF
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "sqlAdminUsername": { "value": "$SQL_ADMIN_USER" },
    "sqlAdminPassword": { "value": "$SQL_PASSWORD" },
    "databaseName": { "value": "$SQL_DATABASE" }
  }
}
EOF
    echo "Parameters file created"
else
    echo "Parameters file already exists"
fi
```

**Verification:**

```bash
# Verify file exists and has required fields
jq -e '.parameters.sqlAdminPassword.value' infrastructure/parameters-containerapp.json > /dev/null && echo "PASS: Password field exists" || echo "FAIL: Password field missing"
```

**Pass Criteria:** Output shows "PASS: Password field exists"

---

### Test 1.3: Bicep Template Deployment

**Objective:** Verify Bicep templates deploy successfully (ACR, Container Apps Environment, SQL Database).

**Steps:**

```bash
# Deploy infrastructure
az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file infrastructure/main-containerapp.bicep \
    --parameters infrastructure/parameters-containerapp.json \
    --output table
```

**Expected Result:** Deployment completes without errors (3-5 minutes).

**Verification:**

```bash
# Check deployment status
az deployment group show \
    --resource-group "$RESOURCE_GROUP" \
    --name "main-containerapp" \
    --query "properties.provisioningState" \
    -o tsv
```

**Pass Criteria:** Output is `Succeeded`

---

### Test 1.4: Container Registry Verification

**Objective:** Verify Azure Container Registry is created and accessible.

**Steps:**

```bash
# Get ACR details
az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --output table
```

**Expected Result:**

| NAME | RESOURCE GROUP | LOCATION | SKU | LOGIN SERVER |
|------|----------------|----------|-----|--------------|
| acrflaskdev | rg-flask-dev-aca | swedencentral | Basic | acrflaskdev.azurecr.io |

**Verification:**

```bash
# Verify ACR login server is accessible
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query loginServer -o tsv)
echo "ACR Login Server: $ACR_LOGIN_SERVER"

# Verify admin credentials available
az acr credential show --name "$ACR_NAME" --query "username" -o tsv
```

**Pass Criteria:**
- ACR login server is `acrflaskdev.azurecr.io`
- Admin username is returned

---

### Test 1.5: Container Apps Environment Verification

**Objective:** Verify Container Apps Environment is created.

**Steps:**

```bash
# Get environment details
az containerapp env show \
    --name "$CONTAINER_APP_ENV" \
    --resource-group "$RESOURCE_GROUP" \
    --output table
```

**Expected Result:**

| NAME | LOCATION | PROVISIONING STATE |
|------|----------|-------------------|
| cae-flask-dev | swedencentral | Succeeded |

**Verification:**

```bash
# Get environment ID (needed for Container App deployment)
CONTAINER_APP_ENV_ID=$(az containerapp env show \
    --name "$CONTAINER_APP_ENV" \
    --resource-group "$RESOURCE_GROUP" \
    --query "id" -o tsv)
echo "Environment ID: $CONTAINER_APP_ENV_ID"
```

**Pass Criteria:** Environment ID is returned (non-empty string)

---

### Test 1.6: SQL Database Verification

**Objective:** Verify Azure SQL Database is created and Online.

**Steps:**

```bash
# Get SQL Server details
az sql server show \
    --name "$SQL_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    --output table

# Get database status
az sql db show \
    --name "$SQL_DATABASE" \
    --server "$SQL_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    --output table
```

**Verification:**

```bash
# Check database is Online
DB_STATUS=$(az sql db show \
    --name "$SQL_DATABASE" \
    --server "$SQL_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    --query "status" -o tsv)
echo "Database Status: $DB_STATUS"

# Get SQL Server FQDN
SQL_FQDN=$(az sql server show \
    --name "$SQL_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    --query "fullyQualifiedDomainName" -o tsv)
echo "SQL Server FQDN: $SQL_FQDN"
```

**Pass Criteria:**
- Database status is `Online`
- SQL Server FQDN is `sql-flask-dev.database.windows.net`

---

## Phase 2: Docker Image Build and Push

### Test 2.1: Docker Build

**Objective:** Verify Docker image builds successfully with SQL Server ODBC driver.

**Steps:**

```bash
# Build Docker image
cd application
docker build -t flask-app:test -f Dockerfile .
cd ..
```

**Expected Result:** Build completes with "Successfully tagged flask-app:test"

**Verification:**

```bash
# Verify image exists
docker images flask-app:test --format "{{.Repository}}:{{.Tag}} - {{.Size}}"
```

**Pass Criteria:** Image `flask-app:test` exists with size ~500-800MB

---

### Test 2.2: Docker Image Local Test

**Objective:** Verify Docker image runs correctly locally (without database).

**Steps:**

```bash
# Run container locally (will fail database connection but Flask should start)
docker run -d --name flask-test -p 5001:5001 \
    -e FLASK_ENV=development \
    -e DATABASE_URL="sqlite:///test.db" \
    flask-app:test

# Wait for startup
sleep 5

# Check if container is running
docker ps --filter name=flask-test
```

**Verification:**

```bash
# Test health endpoint
curl -s http://localhost:5001/api/health | jq .

# Cleanup
docker stop flask-test && docker rm flask-test
```

**Pass Criteria:** Health endpoint returns `{"status": "ok"}`

---

### Test 2.3: ACR Login

**Objective:** Verify authentication to Azure Container Registry.

**Steps:**

```bash
# Login to ACR
az acr login --name "$ACR_NAME"
```

**Expected Result:** "Login Succeeded"

**Verification:**

```bash
# Verify login by listing repositories (should be empty initially)
az acr repository list --name "$ACR_NAME" -o table
```

**Pass Criteria:** Command succeeds (empty list is OK for first deployment)

---

### Test 2.4: Docker Push to ACR

**Objective:** Verify Docker image can be pushed to Azure Container Registry.

**Steps:**

```bash
# Get ACR login server
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query loginServer -o tsv)

# Tag image for ACR
docker tag flask-app:test "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

# Push to ACR
docker push "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
```

**Expected Result:** Push completes with all layers uploaded.

**Verification:**

```bash
# Verify image in ACR
az acr repository show-tags --name "$ACR_NAME" --repository "$IMAGE_NAME" -o table
```

**Pass Criteria:** Tag `latest` appears in repository

---

### Test 2.5: ACR Image Manifest

**Objective:** Verify pushed image is valid and accessible.

**Steps:**

```bash
# Show image manifest
az acr repository show-manifests \
    --name "$ACR_NAME" \
    --repository "$IMAGE_NAME" \
    --output table
```

**Verification:**

```bash
# Get image digest
az acr repository show \
    --name "$ACR_NAME" \
    --image "${IMAGE_NAME}:${IMAGE_TAG}" \
    --query "digest" -o tsv
```

**Pass Criteria:** Image digest (sha256:...) is returned

---

## Phase 3: Container App Deployment

### Test 3.1: Container App Creation

**Objective:** Verify Container App can be created with the pushed image.

**Steps:**

```bash
# Get required values
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query "username" -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)
SQL_PASSWORD=$(jq -r '.parameters.sqlAdminPassword.value' infrastructure/parameters-containerapp.json)
SQL_FQDN=$(az sql server show --name "$SQL_SERVER" --resource-group "$RESOURCE_GROUP" --query "fullyQualifiedDomainName" -o tsv)
DATABASE_URL="mssql+pyodbc://${SQL_ADMIN_USER}:${SQL_PASSWORD}@${SQL_FQDN}/${SQL_DATABASE}?driver=ODBC+Driver+18+for+SQL+Server"

# Create Container App
az containerapp create \
    --name "$CONTAINER_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --environment "$CONTAINER_APP_ENV" \
    --image "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}" \
    --registry-server "$ACR_LOGIN_SERVER" \
    --registry-username "$ACR_USERNAME" \
    --registry-password "$ACR_PASSWORD" \
    --target-port 5001 \
    --ingress external \
    --min-replicas 0 \
    --max-replicas 3 \
    --cpu 0.5 \
    --memory 1Gi \
    --env-vars \
        "DATABASE_URL=$DATABASE_URL" \
        "FLASK_ENV=production" \
        "SECRET_KEY=$(openssl rand -hex 32)" \
    --output table
```

**Expected Result:** Container App created with external ingress.

**Verification:**

```bash
# Get Container App status
az containerapp show \
    --name "$CONTAINER_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --query "properties.provisioningState" -o tsv
```

**Pass Criteria:** Provisioning state is `Succeeded`

---

### Test 3.2: Container App FQDN

**Objective:** Verify Container App has a publicly accessible URL.

**Steps:**

```bash
# Get FQDN
APP_FQDN=$(az containerapp show \
    --name "$CONTAINER_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --query "properties.configuration.ingress.fqdn" -o tsv)
echo "Application URL: https://$APP_FQDN/"
```

**Verification:**

```bash
# Test URL is accessible (may take 30-60 seconds for first cold start)
echo "Waiting for application to start (cold start may take 30-60 seconds)..."
for i in {1..12}; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "https://${APP_FQDN}/api/health" 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        echo "Application responding: HTTP $HTTP_CODE"
        break
    fi
    echo "Attempt $i/12: HTTP $HTTP_CODE - waiting 10 seconds..."
    sleep 10
done
```

**Pass Criteria:** HTTP 200 response within 2 minutes

---

### Test 3.3: Health Endpoint

**Objective:** Verify Flask application health endpoint responds correctly.

**Steps:**

```bash
# Get health response
APP_FQDN=$(az containerapp show --name "$CONTAINER_APP" --resource-group "$RESOURCE_GROUP" --query "properties.configuration.ingress.fqdn" -o tsv)
curl -s "https://${APP_FQDN}/api/health" | jq .
```

**Expected Result:**

```json
{
  "status": "ok"
}
```

**Pass Criteria:** Response contains `"status": "ok"`

---

## Phase 4: Database Schema Configuration

### Test 4.1: Database Table Creation

**Objective:** Verify SQLAlchemy creates database tables.

**Steps:**

```bash
# Execute database initialization in container
az containerapp exec \
    --name "$CONTAINER_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --command python -- -c "
from app import create_app
from app.extensions import db
app = create_app()
with app.app_context():
    db.create_all()
    print('SUCCESS: Database tables created')
"
```

**Expected Result:** Output shows "SUCCESS: Database tables created"

**Pass Criteria:** No errors, success message displayed

---

### Test 4.2: Verify Tables Exist

**Objective:** Verify expected tables were created in SQL Database.

**Steps:**

```bash
# List tables via Flask shell
az containerapp exec \
    --name "$CONTAINER_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --command python -- -c "
from app import create_app
from app.extensions import db
from sqlalchemy import inspect

app = create_app()
with app.app_context():
    inspector = inspect(db.engine)
    tables = inspector.get_table_names()
    print('Tables found:', tables)

    expected = ['entries', 'registration', 'user']
    for table in expected:
        if table in tables:
            print(f'  ✓ {table}')
        else:
            print(f'  ✗ {table} MISSING')
"
```

**Expected Result:**

```
Tables found: ['entries', 'registration', 'user']
  ✓ entries
  ✓ registration
  ✓ user
```

**Pass Criteria:** All three tables exist

---

### Test 4.3: Database Connectivity Test

**Objective:** Verify application can read/write to database.

**Steps:**

```bash
# Test database write and read
az containerapp exec \
    --name "$CONTAINER_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --command python -- -c "
from app import create_app
from app.extensions import db
from app.models import Entry

app = create_app()
with app.app_context():
    # Create test entry
    test_entry = Entry(value='Test entry from verification suite')
    db.session.add(test_entry)
    db.session.commit()
    print(f'Created entry with ID: {test_entry.id}')

    # Read back
    entries = Entry.query.all()
    print(f'Total entries in database: {len(entries)}')

    # Cleanup test entry
    db.session.delete(test_entry)
    db.session.commit()
    print('Test entry cleaned up')
    print('SUCCESS: Database read/write working')
"
```

**Pass Criteria:** Entry created, read, and deleted successfully

---

## Phase 5: Admin User Creation

### Test 5.1: Create Admin User

**Objective:** Create admin user for application authentication.

**Steps:**

```bash
# Create admin user with password
az containerapp exec \
    --name "$CONTAINER_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --command python -- -c "
from app import create_app
from app.services.auth_service import AuthService

app = create_app()
with app.app_context():
    # Check if admin already exists
    from app.models import User
    existing = User.query.filter_by(username='admin').first()
    if existing:
        print('Admin user already exists')
    else:
        # Create admin with known password for testing
        user = AuthService.create_user('admin', 'TestPassword123!')
        if user:
            print(f'SUCCESS: Admin user created with ID: {user.id}')
        else:
            print('FAIL: Could not create admin user')
"
```

**Expected Result:** "SUCCESS: Admin user created" or "Admin user already exists"

**Pass Criteria:** Admin user exists in database

---

### Test 5.2: Verify Admin User Exists

**Objective:** Verify admin user is in the database.

**Steps:**

```bash
# Query admin user
az containerapp exec \
    --name "$CONTAINER_APP" \
    --resource-group "$RESOURCE_GROUP" \
    --command python -- -c "
from app import create_app
from app.models import User

app = create_app()
with app.app_context():
    admin = User.query.filter_by(username='admin').first()
    if admin:
        print(f'Admin user found:')
        print(f'  ID: {admin.id}')
        print(f'  Username: {admin.username}')
        print(f'  Is Active: {admin.is_active}')
        print(f'  Has Password Hash: {bool(admin.password_hash)}')
    else:
        print('FAIL: Admin user not found')
"
```

**Pass Criteria:** Admin user found with valid password hash

---

### Test 5.3: Admin Login Test (HTTP)

**Objective:** Verify admin can log in via the web interface.

**Steps:**

```bash
# Get FQDN
APP_FQDN=$(az containerapp show --name "$CONTAINER_APP" --resource-group "$RESOURCE_GROUP" --query "properties.configuration.ingress.fqdn" -o tsv)

# Test login page loads
echo "Testing login page..."
LOGIN_PAGE=$(curl -s "https://${APP_FQDN}/auth/login")
if echo "$LOGIN_PAGE" | grep -qi "login\|username\|password"; then
    echo "✓ Login page loads correctly"
else
    echo "✗ Login page not loading"
fi

# Test admin area is protected
echo "Testing admin area protection..."
ADMIN_REDIRECT=$(curl -s -o /dev/null -w "%{http_code}" "https://${APP_FQDN}/admin/attendees")
if [ "$ADMIN_REDIRECT" = "302" ] || [ "$ADMIN_REDIRECT" = "401" ]; then
    echo "✓ Admin area is protected (HTTP $ADMIN_REDIRECT)"
else
    echo "✗ Admin area not protected (HTTP $ADMIN_REDIRECT)"
fi
```

**Pass Criteria:**
- Login page loads with form
- Admin area redirects to login (HTTP 302)

---

## Phase 6: End-to-End Verification

### Test 6.1: Full Application Test Suite

**Objective:** Run comprehensive verification tests.

**Steps:**

```bash
# Run the verification test script
./deploy/scripts/verification-tests-containerapp.sh
```

**Expected Result:**

```
=== Test Summary ===
Total: 6 | Passed: 6 | Failed: 0
Classification: PASS
```

**Pass Criteria:** All 6 tests pass

---

### Test 6.2: Manual Endpoint Verification

**Objective:** Manually verify all application endpoints.

**Steps:**

```bash
APP_FQDN=$(az containerapp show --name "$CONTAINER_APP" --resource-group "$RESOURCE_GROUP" --query "properties.configuration.ingress.fqdn" -o tsv)

echo "=== Manual Endpoint Verification ==="
echo ""

# Landing page
echo -n "Landing page (/): "
curl -s -o /dev/null -w "%{http_code}" "https://${APP_FQDN}/"
echo ""

# Registration form
echo -n "Registration (/register): "
curl -s -o /dev/null -w "%{http_code}" "https://${APP_FQDN}/register"
echo ""

# Demo page
echo -n "Demo page (/demo): "
curl -s -o /dev/null -w "%{http_code}" "https://${APP_FQDN}/demo"
echo ""

# Webinar page
echo -n "Webinar (/webinar): "
curl -s -o /dev/null -w "%{http_code}" "https://${APP_FQDN}/webinar"
echo ""

# Health API
echo -n "Health API (/api/health): "
curl -s -o /dev/null -w "%{http_code}" "https://${APP_FQDN}/api/health"
echo ""

# Entries API
echo -n "Entries API (/api/entries): "
curl -s -o /dev/null -w "%{http_code}" "https://${APP_FQDN}/api/entries"
echo ""

# Login page
echo -n "Login (/auth/login): "
curl -s -o /dev/null -w "%{http_code}" "https://${APP_FQDN}/auth/login"
echo ""

# Admin (should redirect)
echo -n "Admin (/admin/attendees): "
curl -s -o /dev/null -w "%{http_code}" "https://${APP_FQDN}/admin/attendees"
echo ""
```

**Pass Criteria:** All endpoints return HTTP 200 (except admin which returns 302)

---

### Test 6.3: TLS Certificate Verification

**Objective:** Verify HTTPS is working with valid certificate.

**Steps:**

```bash
APP_FQDN=$(az containerapp show --name "$CONTAINER_APP" --resource-group "$RESOURCE_GROUP" --query "properties.configuration.ingress.fqdn" -o tsv)

# Check certificate
echo "Checking TLS certificate..."
echo | openssl s_client -servername "$APP_FQDN" -connect "${APP_FQDN}:443" 2>/dev/null | openssl x509 -noout -dates -issuer
```

**Pass Criteria:** Certificate is valid and issued by Microsoft/DigiCert

---

## Cleanup

### Remove Test Resources

After testing, clean up all resources:

```bash
# Delete everything
./delete-all-containerapp.sh

# Or manually:
az group delete --name "$RESOURCE_GROUP" --yes --no-wait
```

### Clean Local Artifacts

```bash
# Remove local Docker images
docker rmi flask-app:test
docker rmi acrflaskdev.azurecr.io/flask-app:latest

# Remove parameters file (optional)
rm infrastructure/parameters-containerapp.json
```

---

## Test Results Summary Template

Copy and fill in after running tests:

```markdown
## Test Run: [DATE]

### Phase 1: Infrastructure Provisioning
- [ ] Test 1.1: Resource Group Creation - PASS/FAIL
- [ ] Test 1.2: Parameters File Generation - PASS/FAIL
- [ ] Test 1.3: Bicep Template Deployment - PASS/FAIL
- [ ] Test 1.4: Container Registry Verification - PASS/FAIL
- [ ] Test 1.5: Container Apps Environment Verification - PASS/FAIL
- [ ] Test 1.6: SQL Database Verification - PASS/FAIL

### Phase 2: Docker Image Build and Push
- [ ] Test 2.1: Docker Build - PASS/FAIL
- [ ] Test 2.2: Docker Image Local Test - PASS/FAIL
- [ ] Test 2.3: ACR Login - PASS/FAIL
- [ ] Test 2.4: Docker Push to ACR - PASS/FAIL
- [ ] Test 2.5: ACR Image Manifest - PASS/FAIL

### Phase 3: Container App Deployment
- [ ] Test 3.1: Container App Creation - PASS/FAIL
- [ ] Test 3.2: Container App FQDN - PASS/FAIL
- [ ] Test 3.3: Health Endpoint - PASS/FAIL

### Phase 4: Database Schema Configuration
- [ ] Test 4.1: Database Table Creation - PASS/FAIL
- [ ] Test 4.2: Verify Tables Exist - PASS/FAIL
- [ ] Test 4.3: Database Connectivity Test - PASS/FAIL

### Phase 5: Admin User Creation
- [ ] Test 5.1: Create Admin User - PASS/FAIL
- [ ] Test 5.2: Verify Admin User Exists - PASS/FAIL
- [ ] Test 5.3: Admin Login Test - PASS/FAIL

### Phase 6: End-to-End Verification
- [ ] Test 6.1: Full Application Test Suite - PASS/FAIL
- [ ] Test 6.2: Manual Endpoint Verification - PASS/FAIL
- [ ] Test 6.3: TLS Certificate Verification - PASS/FAIL

### Overall Result: PASS/FAIL
### Notes:
[Add any observations or issues encountered]
```

---

## Troubleshooting

### Container App Not Starting

```bash
# Check logs
az containerapp logs show --name "$CONTAINER_APP" --resource-group "$RESOURCE_GROUP" --follow

# Check revision status
az containerapp revision list --name "$CONTAINER_APP" --resource-group "$RESOURCE_GROUP" -o table
```

### Database Connection Issues

```bash
# Verify DATABASE_URL environment variable
az containerapp show --name "$CONTAINER_APP" --resource-group "$RESOURCE_GROUP" \
    --query "properties.template.containers[0].env" -o table

# Test SQL connectivity from container
az containerapp exec --name "$CONTAINER_APP" --resource-group "$RESOURCE_GROUP" \
    --command python -- -c "
import os
print('DATABASE_URL:', os.environ.get('DATABASE_URL', 'NOT SET')[:50] + '...')
"
```

### Image Pull Errors

```bash
# Verify ACR credentials in Container App
az containerapp show --name "$CONTAINER_APP" --resource-group "$RESOURCE_GROUP" \
    --query "properties.configuration.registries" -o table

# Re-authenticate ACR
az acr login --name "$ACR_NAME"
```
