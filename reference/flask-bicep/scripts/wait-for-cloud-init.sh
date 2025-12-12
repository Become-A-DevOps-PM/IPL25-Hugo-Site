#!/bin/bash
set -e
RG="rg-flask-bicep-dev"

BASTION_IP=$(az vm show -g $RG -n vm-bastion --show-details -o tsv --query publicIps)

# Common SSH options to avoid interactive prompts
SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

# Wait for bastion first (direct SSH)
echo "Waiting for bastion cloud-init..."
until ssh $SSH_OPTS azureuser@$BASTION_IP "cloud-init status --wait" 2>/dev/null; do
    echo "  Bastion not ready yet, retrying..."
    sleep 10
done
echo "  Bastion cloud-init complete."

# Wait for proxy and app via bastion jump
for VM in vm-proxy vm-app; do
    echo "Waiting for $VM cloud-init..."
    ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@$VM "cloud-init status --wait"
    echo "  $VM cloud-init complete."
done

echo "All VMs configured."
