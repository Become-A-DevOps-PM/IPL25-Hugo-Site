#!/bin/bash
set -e
RG="rg-flask-bicep-dev"

PROXY_IP=$(az vm show -g $RG -n vm-proxy --show-details -o tsv --query publicIps)

echo "Waiting for application to respond..."
MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # Health endpoint returns: {"status": "ok"}
    if curl -sk --max-time 5 "https://$PROXY_IP/health" | grep -q '"status".*"ok"'; then
        echo "Application is healthy."
        exit 0
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo "  Attempt $ATTEMPT/$MAX_ATTEMPTS - Application not ready yet..."
    sleep 10
done

echo "ERROR: Application did not become healthy within timeout"
exit 1
