+++
title = "Securely Manage Servers Behind a Bastion Host"
weight = 10
date = 2024-02-26
draft = false
+++

## Introduction

This tutorial explains how to securely manage servers on Azure when they are not directly exposed to the internet and are located behind a bastion host. By following this guide, you will learn how to use SSH agent forwarding to access internal servers and how to transfer files securely through SSH tunnels.

## Prerequisites

- An Azure account with a deployed bastion host and internal servers
- SSH key pairs for each server
- Basic knowledge of command-line interfaces (CLI)
- For Windows users: Git Bash or similar terminal (Mac and Linux users can use the pre-installed terminal)

## Understanding the Setup

In a secure architecture, internal servers (like application servers) have no public IP address and cannot be accessed directly from the internet. Instead, you connect through a bastion host (also called a jump server) that acts as a secure entry point.

```
Your Computer → Bastion Host (public IP) → Internal Server (private IP only)
```

The challenge is: how do you authenticate to the internal server if you can only reach it through the bastion host? The answer is **SSH agent forwarding**.

## Step 1: Secure Your SSH Keys

First, ensure your SSH private keys have the correct permissions:

```bash
chmod 400 bastion-key.pem
chmod 400 app-server-key.pem
```

## Step 2: Start the SSH Agent

The SSH agent is a program that holds your private keys in memory and provides them when needed for authentication.

```bash
eval $(ssh-agent)
```

This starts the SSH agent and sets up environment variables so your SSH client can communicate with it.

## Step 3: Add Keys to the Agent

Add your private keys to the agent:

```bash
ssh-add ~/path/to/bastion-key.pem
ssh-add ~/path/to/app-server-key.pem
```

Verify the keys are loaded:

```bash
ssh-add -l
```

You should see both keys listed.

## Step 4: Connect with Agent Forwarding

Connect to the bastion host with the `-A` flag to enable agent forwarding:

```bash
ssh -A azureuser@<BastionHost_PublicIP>
```

The `-A` flag forwards your SSH agent connection to the bastion host. This means the bastion host can use your local SSH agent to authenticate further connections, without your private keys ever being copied to the bastion host.

## Step 5: Jump to Internal Server

Once connected to the bastion host, you can SSH to the internal server using its private IP:

```bash
ssh azureuser@<AppServer_PrivateIP>
```

The authentication happens through the forwarded agent connection - your private key is still securely on your local machine.

## SSH Agent Commands Reference

| Command | Description |
|---------|-------------|
| `eval $(ssh-agent)` | Start the SSH agent and configure environment |
| `ssh-add <keyfile>` | Add a private key to the agent |
| `ssh-add -l` | List keys currently held by the agent |
| `ssh-add -D` | Remove all keys from the agent |
| `ssh -A user@host` | Connect with agent forwarding enabled |

## Transferring Files Through a Bastion Host

There are two ways to copy files to an internal server through a bastion host: **ProxyJump** (simpler) and **SSH Tunnel** (more flexible).

### Option 1: ProxyJump (Recommended)

The `-J` flag (ProxyJump) lets you transfer files in a single command without setting up a separate tunnel:

```bash
scp -J azureuser@<BastionHost_PublicIP> myfile.txt azureuser@<AppServer_PrivateIP>:~/
```

This command:
- Connects to the bastion host first
- Then forwards the connection to the app server
- Copies the file directly to the app server's home directory

You can also use ProxyJump for SSH connections:

```bash
ssh -J azureuser@<BastionHost_PublicIP> azureuser@<AppServer_PrivateIP>
```

This is the simplest approach for quick file transfers and one-off connections.

### Option 2: SSH Tunnel

For long-running sessions or when you need to transfer many files, setting up a persistent SSH tunnel can be more convenient.

**Set up the tunnel:**

Open a terminal and create a tunnel:

```bash
ssh -A -N -L 2222:<AppServer_PrivateIP>:22 azureuser@<BastionHost_PublicIP>
```

This command:
- `-A` enables agent forwarding
- `-N` means no remote commands (just the tunnel)
- `-L 2222:<AppServer_PrivateIP>:22` forwards local port 2222 to the app server's SSH port

The terminal will appear to "hang" - this is normal. The tunnel is now active.

**Copy files through the tunnel:**

In a **new terminal**, add your keys to the agent again (each terminal has its own environment):

```bash
eval $(ssh-agent)
ssh-add ~/path/to/app-server-key.pem
```

Now copy files using the tunnel:

```bash
scp -P 2222 myfile.txt azureuser@localhost:~/
```

This sends the file through localhost:2222, which the tunnel forwards to the app server.

### Verify the Transfer

Connect to the app server to verify:

```bash
ssh -J azureuser@<BastionHost_PublicIP> azureuser@<AppServer_PrivateIP>
ls ~/
```

You should see your transferred file.

### Which Option to Choose?

| Use Case | Recommended Option |
|----------|-------------------|
| Quick one-off file transfer | ProxyJump (`-J`) |
| Single SSH session | ProxyJump (`-J`) |
| Multiple file transfers over time | SSH Tunnel |
| Running multiple commands/sessions | SSH Tunnel |
| Scripted deployments | ProxyJump (`-J`) |

## Command Reference

### ProxyJump Flags

| Command | Description |
|---------|-------------|
| `ssh -J jump@bastion user@target` | SSH through bastion to target |
| `scp -J jump@bastion file user@target:~/` | Copy file through bastion to target |

### SSH Tunnel Flags

| Flag | Description |
|------|-------------|
| `-N` | No remote commands - just maintain the tunnel |
| `-L local:remote:port` | Forward local port to remote address:port |
| `-f` | Run in background (optional, for long-running tunnels) |

## Deploying Files to Protected Directories

When deploying application files, you often need to copy them to directories that require root permissions, such as `/opt/`, `/etc/`, or `/var/www/`. Since SCP runs as a regular user, you cannot write directly to these locations.

The solution is a two-step process:

### Step 1: Copy to a Temporary Location

First, copy the file to your home directory or `/tmp/`:

```bash
scp -J azureuser@<BastionHost_PublicIP> myapp.tar.gz azureuser@<AppServer_PrivateIP>:~/
```

### Step 2: Move to Final Location via SSH

Then SSH in and use `sudo` to move the file:

```bash
ssh -J azureuser@<BastionHost_PublicIP> azureuser@<AppServer_PrivateIP>

# Now on the app server:
sudo mv ~/myapp.tar.gz /opt/
sudo tar -xzf /opt/myapp.tar.gz -C /opt/
```

### One-Liner with Remote Commands

You can also combine the SSH connection with remote commands:

```bash
ssh -J azureuser@<BastionHost_PublicIP> azureuser@<AppServer_PrivateIP> \
  "sudo mv ~/myapp.tar.gz /opt/ && sudo tar -xzf /opt/myapp.tar.gz -C /opt/"
```

### Example: Deploying nginx Configuration

```bash
# Copy config to home directory
scp -J azureuser@<BastionHost_PublicIP> nginx.conf azureuser@<AppServer_PrivateIP>:~/

# Move to /etc/nginx/ and reload
ssh -J azureuser@<BastionHost_PublicIP> azureuser@<AppServer_PrivateIP> \
  "sudo mv ~/nginx.conf /etc/nginx/nginx.conf && sudo nginx -t && sudo systemctl reload nginx"
```

This pattern of "copy to temp, then sudo move" is standard practice for deploying files to production servers.

## Security Best Practices

1. **Never copy private keys to the bastion host** - Use agent forwarding instead
2. **Use separate keys for each server** - If one key is compromised, others remain secure
3. **Verify keys are loaded** before connecting - Use `ssh-add -l`
4. **Close tunnels when done** - Press Ctrl+C in the tunnel terminal

## Common Issues

**"Agent forwarding not working"**
- Ensure you started ssh-agent and added keys before connecting
- Use `ssh-add -l` to verify keys are loaded
- Make sure you used the `-A` flag when connecting to bastion

**"Permission denied" when connecting to internal server**
- Verify the correct key is loaded in the agent
- Check that agent forwarding is enabled (use `-A`)
- Ensure the internal server's authorized_keys has the correct public key

**"Connection refused" on tunnel port**
- Verify the tunnel is still running in the other terminal
- Check that you're using the correct local port (2222 in our example)

## Summary

SSH agent forwarding allows you to securely access internal servers through a bastion host without copying private keys. SSH tunnels enable file transfers to servers that have no direct internet access. Together, these techniques provide secure management of infrastructure in a defense-in-depth architecture.
