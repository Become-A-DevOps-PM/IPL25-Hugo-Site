+++
title = "Cloud-init Cheat Sheet"
weight = 30
date = 2024-11-25
draft = false
+++

Quick reference for cloud-init and Azure custom data scripts.

## What is Cloud-init?

Cloud-init runs scripts automatically when a VM first boots. In Azure, this is called **Custom Data**.

## Script Requirements

| Requirement | Description |
|-------------|-------------|
| Shebang | Must start with `#!/bin/bash` |
| No sudo | Runs as root already |
| Non-interactive | No user prompts (`-y` flags) |
| One-time | Runs only on first boot |

## Basic Template

```bash
#!/bin/bash

# Update packages
apt update

# Install software
apt install -y nginx

# Configure service
systemctl enable nginx
systemctl start nginx
```

## Using with Azure CLI

```bash
az vm create \
  --resource-group MyGroup \
  --name MyVM \
  --image Ubuntu2404 \
  --custom-data @cloud-init.sh
```

The `@` reads from file.

## Common Tasks

### Install packages

```bash
#!/bin/bash
apt update
apt install -y nginx python3 python3-pip
```

### Create files

```bash
#!/bin/bash
cat > /var/www/html/index.html << 'EOF'
<html>
<body>
<h1>Hello World</h1>
</body>
</html>
EOF
```

### Set permissions

```bash
#!/bin/bash
chown -R www-data:www-data /var/www/html
chmod 755 /var/www/html
```

### Enable services

```bash
#!/bin/bash
systemctl enable nginx
systemctl start nginx
```

### Create users

```bash
#!/bin/bash
useradd -m -s /bin/bash newuser
echo "newuser:password" | chpasswd
```

### Write to log

```bash
#!/bin/bash
exec > /var/log/cloud-init-custom.log 2>&1
echo "Starting custom data script"
# ... commands
echo "Script complete"
```

## Example: Web Server Setup

```bash
#!/bin/bash

# Update system
apt update

# Install nginx
apt install -y nginx

# Create custom page
echo "<h1>Deployed via Cloud-init</h1>" > /var/www/html/index.html

# Ensure nginx runs
systemctl enable nginx
systemctl start nginx
```

## Example: Python/Flask Setup

```bash
#!/bin/bash

# Update system
apt update

# Install dependencies
apt install -y python3 python3-pip python3-venv nginx

# Create app directory
mkdir -p /var/www/app
cd /var/www/app

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Flask
pip install flask gunicorn
```

## Debugging

### Check if script ran

```bash
# Cloud-init logs
cat /var/log/cloud-init.log
cat /var/log/cloud-init-output.log

# Custom log (if you redirected)
cat /var/log/cloud-init-custom.log
```

### Check cloud-init status

```bash
cloud-init status
```

### Re-run cloud-init (testing only)

```bash
sudo cloud-init clean
sudo cloud-init init
```

## Best Practices

| Practice | Reason |
|----------|--------|
| Test locally first | Catch errors before deploying |
| Use `-y` flags | Avoid interactive prompts |
| Log output | Easier debugging |
| Check exit codes | Ensure commands succeed |
| Keep it simple | Complex scripts are harder to debug |

## Troubleshooting

| Issue | Check |
|-------|-------|
| Script didn't run | Verify shebang, file encoding |
| Package install failed | Check `/var/log/cloud-init-output.log` |
| Service not starting | Check systemctl status |
| File not created | Check permissions and paths |
