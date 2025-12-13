# HTTPS Self-Signed Certificate Tutorial

This reference implementation demonstrates how to configure nginx with HTTPS using a self-signed SSL certificate on an Azure VM.

## Architecture

```
Internet
    |
    +--HTTP (80)----> nginx (redirect to HTTPS)
    |
    +--HTTPS (443)--> nginx (reverse proxy)
                          |
                          +--HTTP (8080)--> Hello World app (localhost only)
```

## Files

| File | Description |
|------|-------------|
| `provision.sh` | Azure CLI script to create the VM |
| `cloud-init.yaml` | Cloud-init configuration for nginx + SSL |
| `tutorial.md` | Step-by-step tutorial (Hugo markdown) |

## Quick Start

```bash
# Make script executable
chmod +x provision.sh

# Deploy to Azure (takes ~3 minutes)
./provision.sh

# Wait for cloud-init (~2 minutes more)

# Test
curl -k https://<PUBLIC_IP>
```

## What Gets Deployed

- Ubuntu 24.04 VM (Standard_B1s)
- nginx with two virtual hosts:
  - Port 8080: Hello World static site (localhost only)
  - Port 80/443: HTTPS reverse proxy
- Self-signed SSL certificate (365 days)
- HTTP to HTTPS redirect

## Clean Up

```bash
az group delete --name https-tutorial-rg --yes --no-wait
```

## Key Concepts

1. **Self-signed certificate**: Generated with `openssl req -x509`
2. **HTTP redirect**: `return 301 https://$host$request_uri`
3. **Reverse proxy**: `proxy_pass http://127.0.0.1:8080`
4. **Cloud-init**: Automates server configuration on first boot
