#!/bin/bash
set -euo pipefail

#
# Provision Azure Infrastructure for Flask Contact Form
#
# This script creates all Azure resources needed for the stage-ultimate deployment.
# Uses cost-effective tiers suitable for learning/development.
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
RESOURCE_GROUP="flask-ultimate-rg"
LOCATION="swedencentral"
VNET_NAME="flask-ultimate-vnet"
UNIQUE_SUFFIX=$(openssl rand -hex 4)

# VM Configuration (cost-optimized)
VM_SIZE="Standard_B1s"
VM_IMAGE="Ubuntu2404"

# PostgreSQL Configuration (cost-optimized)
PG_SKU="Standard_B1ms"
PG_TIER="Burstable"
PG_VERSION="17"
PG_STORAGE="32"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Get SSH public key
get_ssh_key() {
    local ssh_key=""
    if [[ -f ~/.ssh/id_rsa.pub ]]; then
        ssh_key=$(cat ~/.ssh/id_rsa.pub)
    elif [[ -f ~/.ssh/id_ed25519.pub ]]; then
        ssh_key=$(cat ~/.ssh/id_ed25519.pub)
    else
        log_error "No SSH public key found in ~/.ssh/"
        exit 1
    fi
    echo "$ssh_key"
}

SSH_KEY=$(get_ssh_key)

#######################################
# Phase 1: Resource Group
#######################################
create_resource_group() {
    log_step "Creating resource group: $RESOURCE_GROUP"

    if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
        log_warn "Resource group already exists"
    else
        az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
        log_info "Resource group created"
    fi
}

#######################################
# Phase 2: Network Foundation
#######################################
create_network() {
    log_step "Creating virtual network and subnets"

    # Create VNet
    if az network vnet show --resource-group "$RESOURCE_GROUP" --name "$VNET_NAME" &>/dev/null; then
        log_warn "VNet already exists"
    else
        az network vnet create \
            --resource-group "$RESOURCE_GROUP" \
            --name "$VNET_NAME" \
            --address-prefix 10.0.0.0/16 \
            --location "$LOCATION" \
            --output none
        log_info "VNet created"
    fi

    # Create subnets
    local subnets=(
        "bastion-subnet:10.0.1.0/24"
        "proxy-subnet:10.0.2.0/24"
        "app-subnet:10.0.3.0/24"
        "db-subnet:10.0.4.0/24"
        "keyvault-subnet:10.0.5.0/24"
    )

    for subnet_config in "${subnets[@]}"; do
        local name="${subnet_config%%:*}"
        local prefix="${subnet_config##*:}"

        if az network vnet subnet show --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$name" &>/dev/null; then
            log_warn "Subnet $name already exists"
        else
            az network vnet subnet create \
                --resource-group "$RESOURCE_GROUP" \
                --vnet-name "$VNET_NAME" \
                --name "$name" \
                --address-prefix "$prefix" \
                --output none
            log_info "Subnet $name created"
        fi
    done
}

# Note: ASGs are not used in this deployment.
# NSG rules use subnet CIDR ranges instead for simplicity.

create_nsgs() {
    log_step "Creating Network Security Groups"

    # Bastion NSG - Allow SSH from Internet
    if ! az network nsg show --resource-group "$RESOURCE_GROUP" --name "bastion-nsg" &>/dev/null; then
        az network nsg create --resource-group "$RESOURCE_GROUP" --name "bastion-nsg" --location "$LOCATION" --output none
        az network nsg rule create \
            --resource-group "$RESOURCE_GROUP" \
            --nsg-name "bastion-nsg" \
            --name "AllowSSHFromInternet" \
            --priority 100 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            --destination-port-ranges 22 \
            --source-address-prefixes Internet \
            --output none
        log_info "bastion-nsg created"
    else
        log_warn "bastion-nsg already exists"
    fi

    # Proxy NSG - Allow HTTP/HTTPS from Internet, SSH from Bastion
    if ! az network nsg show --resource-group "$RESOURCE_GROUP" --name "proxy-nsg" &>/dev/null; then
        az network nsg create --resource-group "$RESOURCE_GROUP" --name "proxy-nsg" --location "$LOCATION" --output none

        az network nsg rule create \
            --resource-group "$RESOURCE_GROUP" \
            --nsg-name "proxy-nsg" \
            --name "AllowHTTPFromInternet" \
            --priority 100 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            --destination-port-ranges 80 \
            --source-address-prefixes Internet \
            --output none

        az network nsg rule create \
            --resource-group "$RESOURCE_GROUP" \
            --nsg-name "proxy-nsg" \
            --name "AllowHTTPSFromInternet" \
            --priority 110 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            --destination-port-ranges 443 \
            --source-address-prefixes Internet \
            --output none

        az network nsg rule create \
            --resource-group "$RESOURCE_GROUP" \
            --nsg-name "proxy-nsg" \
            --name "AllowSSHFromBastion" \
            --priority 120 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            --destination-port-ranges 22 \
            --source-address-prefixes 10.0.1.0/24 \
            --output none

        log_info "proxy-nsg created"
    else
        log_warn "proxy-nsg already exists"
    fi

    # App NSG - Allow 5001 from Proxy, SSH from Bastion
    if ! az network nsg show --resource-group "$RESOURCE_GROUP" --name "app-nsg" &>/dev/null; then
        az network nsg create --resource-group "$RESOURCE_GROUP" --name "app-nsg" --location "$LOCATION" --output none

        az network nsg rule create \
            --resource-group "$RESOURCE_GROUP" \
            --nsg-name "app-nsg" \
            --name "AllowAppFromProxy" \
            --priority 100 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            --destination-port-ranges 5001 \
            --source-address-prefixes 10.0.2.0/24 \
            --output none

        az network nsg rule create \
            --resource-group "$RESOURCE_GROUP" \
            --nsg-name "app-nsg" \
            --name "AllowSSHFromBastion" \
            --priority 110 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            --destination-port-ranges 22 \
            --source-address-prefixes 10.0.1.0/24 \
            --output none

        log_info "app-nsg created"
    else
        log_warn "app-nsg already exists"
    fi

    # DB NSG - Allow PostgreSQL from App subnet
    if ! az network nsg show --resource-group "$RESOURCE_GROUP" --name "db-nsg" &>/dev/null; then
        az network nsg create --resource-group "$RESOURCE_GROUP" --name "db-nsg" --location "$LOCATION" --output none

        az network nsg rule create \
            --resource-group "$RESOURCE_GROUP" \
            --nsg-name "db-nsg" \
            --name "AllowPostgresFromApp" \
            --priority 100 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            --destination-port-ranges 5432 \
            --source-address-prefixes 10.0.3.0/24 \
            --output none

        log_info "db-nsg created"
    else
        log_warn "db-nsg already exists"
    fi

    # Key Vault NSG - Allow HTTPS from App subnet
    if ! az network nsg show --resource-group "$RESOURCE_GROUP" --name "keyvault-nsg" &>/dev/null; then
        az network nsg create --resource-group "$RESOURCE_GROUP" --name "keyvault-nsg" --location "$LOCATION" --output none

        az network nsg rule create \
            --resource-group "$RESOURCE_GROUP" \
            --nsg-name "keyvault-nsg" \
            --name "AllowHTTPSFromApp" \
            --priority 100 \
            --direction Inbound \
            --access Allow \
            --protocol Tcp \
            --destination-port-ranges 443 \
            --source-address-prefixes 10.0.3.0/24 \
            --output none

        log_info "keyvault-nsg created"
    else
        log_warn "keyvault-nsg already exists"
    fi

    # Associate NSGs with subnets
    log_info "Associating NSGs with subnets..."
    local subnet_nsgs=(
        "bastion-subnet:bastion-nsg"
        "proxy-subnet:proxy-nsg"
        "app-subnet:app-nsg"
        "db-subnet:db-nsg"
        "keyvault-subnet:keyvault-nsg"
    )

    for config in "${subnet_nsgs[@]}"; do
        local subnet="${config%%:*}"
        local nsg="${config##*:}"

        az network vnet subnet update \
            --resource-group "$RESOURCE_GROUP" \
            --vnet-name "$VNET_NAME" \
            --name "$subnet" \
            --network-security-group "$nsg" \
            --output none
    done
    log_info "NSGs associated with subnets"
}

#######################################
# Phase 3: Key Vault
#######################################
create_keyvault() {
    log_step "Creating Key Vault"

    local kv_name="flask-kv-${UNIQUE_SUFFIX}"

    if az keyvault list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv 2>/dev/null | grep -q .; then
        kv_name=$(az keyvault list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv)
        log_warn "Key Vault already exists: $kv_name"
    else
        az keyvault create \
            --resource-group "$RESOURCE_GROUP" \
            --name "$kv_name" \
            --location "$LOCATION" \
            --enable-soft-delete true \
            --retention-days 7 \
            --output none

        log_info "Key Vault created: $kv_name"
    fi

    # Generate and store database password
    local db_password="FlaskDB-${UNIQUE_SUFFIX}!"

    if ! az keyvault secret show --vault-name "$kv_name" --name "postgresql-admin-password" &>/dev/null; then
        az keyvault secret set \
            --vault-name "$kv_name" \
            --name "postgresql-admin-password" \
            --value "$db_password" \
            --output none
        log_info "Database password stored in Key Vault"
    fi

    # Generate and store Flask secret key
    if ! az keyvault secret show --vault-name "$kv_name" --name "secret-key" &>/dev/null; then
        local secret_key=$(openssl rand -hex 32)
        az keyvault secret set \
            --vault-name "$kv_name" \
            --name "secret-key" \
            --value "$secret_key" \
            --output none
        log_info "Flask secret key stored in Key Vault"
    fi

    echo "$kv_name"
}

#######################################
# Phase 4: PostgreSQL
#######################################
create_postgresql() {
    local kv_name="$1"
    log_step "Creating PostgreSQL Flexible Server"

    local pg_name="flask-db-${UNIQUE_SUFFIX}"
    local db_password=$(az keyvault secret show --vault-name "$kv_name" --name "postgresql-admin-password" --query "value" -o tsv)

    if az postgres flexible-server show --resource-group "$RESOURCE_GROUP" --name "$pg_name" &>/dev/null; then
        log_warn "PostgreSQL server already exists: $pg_name"
    else
        # Create PostgreSQL server with public access for now
        # Private endpoint would require additional networking setup
        az postgres flexible-server create \
            --resource-group "$RESOURCE_GROUP" \
            --name "$pg_name" \
            --location "$LOCATION" \
            --admin-user flaskadmin \
            --admin-password "$db_password" \
            --sku-name "$PG_SKU" \
            --tier "$PG_TIER" \
            --version "$PG_VERSION" \
            --storage-size "$PG_STORAGE" \
            --public-access 0.0.0.0 \
            --output none

        log_info "PostgreSQL server created: $pg_name"

        # Create database
        az postgres flexible-server db create \
            --resource-group "$RESOURCE_GROUP" \
            --server-name "$pg_name" \
            --database-name contactform \
            --output none

        log_info "Database 'contactform' created"

        # Add firewall rule for Azure services
        az postgres flexible-server firewall-rule create \
            --resource-group "$RESOURCE_GROUP" \
            --name "$pg_name" \
            --rule-name AllowAzureServices \
            --start-ip-address 0.0.0.0 \
            --end-ip-address 0.0.0.0 \
            --output none

        log_info "Firewall rule added for Azure services"
    fi

    # Store database URL in Key Vault
    local pg_host="${pg_name}.postgres.database.azure.com"
    local db_url="postgresql://flaskadmin:${db_password}@${pg_host}:5432/contactform"

    az keyvault secret set \
        --vault-name "$kv_name" \
        --name "database-url" \
        --value "$db_url" \
        --output none

    log_info "Database URL stored in Key Vault"

    echo "$pg_name"
}

#######################################
# Phase 5: Virtual Machines
#######################################
create_bastion_vm() {
    log_step "Creating Bastion VM"

    local vm_name="flask-ultimate-bastion"

    if az vm show --resource-group "$RESOURCE_GROUP" --name "$vm_name" &>/dev/null; then
        log_warn "Bastion VM already exists"
        return
    fi

    # Create public IP
    az network public-ip create \
        --resource-group "$RESOURCE_GROUP" \
        --name "${vm_name}-pip" \
        --allocation-method Dynamic \
        --sku Basic \
        --output none

    # Create NIC
    az network nic create \
        --resource-group "$RESOURCE_GROUP" \
        --name "${vm_name}-nic" \
        --vnet-name "$VNET_NAME" \
        --subnet "bastion-subnet" \
        --public-ip-address "${vm_name}-pip" \
        --output none

    # Create VM with cloud-init
    az vm create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$vm_name" \
        --nics "${vm_name}-nic" \
        --image "$VM_IMAGE" \
        --size "$VM_SIZE" \
        --admin-username azureuser \
        --ssh-key-values "$SSH_KEY" \
        --custom-data "$SCRIPT_DIR/cloud-init-bastion.yaml" \
        --output none

    log_info "Bastion VM created"
}

create_proxy_vm() {
    log_step "Creating Reverse Proxy VM"

    local vm_name="flask-ultimate-proxy"

    if az vm show --resource-group "$RESOURCE_GROUP" --name "$vm_name" &>/dev/null; then
        log_warn "Proxy VM already exists"
        return
    fi

    # Create public IP
    az network public-ip create \
        --resource-group "$RESOURCE_GROUP" \
        --name "${vm_name}-pip" \
        --allocation-method Dynamic \
        --sku Basic \
        --output none

    # Create NIC
    az network nic create \
        --resource-group "$RESOURCE_GROUP" \
        --name "${vm_name}-nic" \
        --vnet-name "$VNET_NAME" \
        --subnet "proxy-subnet" \
        --public-ip-address "${vm_name}-pip" \
        --output none

    # Create VM with cloud-init
    az vm create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$vm_name" \
        --nics "${vm_name}-nic" \
        --image "$VM_IMAGE" \
        --size "$VM_SIZE" \
        --admin-username azureuser \
        --ssh-key-values "$SSH_KEY" \
        --custom-data "$SCRIPT_DIR/cloud-init-proxy.yaml" \
        --output none

    log_info "Proxy VM created"
}

create_app_vm() {
    local kv_name="$1"
    log_step "Creating App Server VM"

    local vm_name="flask-ultimate-app"

    if az vm show --resource-group "$RESOURCE_GROUP" --name "$vm_name" &>/dev/null; then
        log_warn "App VM already exists"
        return
    fi

    # Create NIC (NO public IP)
    az network nic create \
        --resource-group "$RESOURCE_GROUP" \
        --name "${vm_name}-nic" \
        --vnet-name "$VNET_NAME" \
        --subnet "app-subnet" \
        --output none

    # Create VM with cloud-init and managed identity
    az vm create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$vm_name" \
        --nics "${vm_name}-nic" \
        --image "$VM_IMAGE" \
        --size "$VM_SIZE" \
        --admin-username azureuser \
        --ssh-key-values "$SSH_KEY" \
        --assign-identity \
        --custom-data "$SCRIPT_DIR/cloud-init-app-server.yaml" \
        --output none

    log_info "App VM created with managed identity"

    # Get managed identity principal ID
    local principal_id=$(az vm identity show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$vm_name" \
        --query "principalId" -o tsv)

    # Grant Key Vault access using RBAC (modern Key Vaults use RBAC by default)
    local kv_id=$(az keyvault show --name "$kv_name" --query "id" -o tsv)

    az role assignment create \
        --assignee-object-id "$principal_id" \
        --assignee-principal-type ServicePrincipal \
        --role "Key Vault Secrets User" \
        --scope "$kv_id" \
        --output none

    log_info "Key Vault RBAC access granted to App VM managed identity"
}

#######################################
# Main
#######################################
main() {
    echo "=========================================="
    echo "  Azure Infrastructure Provisioning"
    echo "=========================================="
    echo ""
    echo "Resource Group: $RESOURCE_GROUP"
    echo "Location: $LOCATION"
    echo "Unique Suffix: $UNIQUE_SUFFIX"
    echo ""

    create_resource_group
    create_network
    create_nsgs

    local kv_name=$(create_keyvault)
    local pg_name=$(create_postgresql "$kv_name")

    create_bastion_vm
    create_proxy_vm
    create_app_vm "$kv_name"

    echo ""
    echo "=========================================="
    echo "  Provisioning Complete!"
    echo "=========================================="
    echo ""

    # Output information
    local bastion_ip=$(az vm show --resource-group "$RESOURCE_GROUP" --name "flask-ultimate-bastion" --show-details --query "publicIps" -o tsv)
    local proxy_ip=$(az vm show --resource-group "$RESOURCE_GROUP" --name "flask-ultimate-proxy" --show-details --query "publicIps" -o tsv)
    local app_private_ip=$(az vm show --resource-group "$RESOURCE_GROUP" --name "flask-ultimate-app" --show-details --query "privateIps" -o tsv)

    echo "Resources created:"
    echo "  Key Vault: $kv_name"
    echo "  PostgreSQL: $pg_name"
    echo ""
    echo "VM IP Addresses:"
    echo "  Bastion (public): $bastion_ip"
    echo "  Proxy (public): $proxy_ip"
    echo "  App Server (private): $app_private_ip"
    echo ""
    echo "SSH to App Server:"
    echo "  ssh -J azureuser@$bastion_ip azureuser@$app_private_ip"
    echo ""
    echo "Next step: Run deploy.sh to deploy the application"
}

main "$@"
