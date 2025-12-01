+++
title = "Week 1 Technical Recap"
type = "slide"
date = 2025-12-01
draft = false
hidden = false

theme = "sky"
[revealOptions]
controls = true
progress = true
history = true
center = true
+++

### Week 1

## Technical Recap

- Three perspectives on servers
- Defense in depth security

---

## Server to a Client

- The browser is the **client** that requests content
- The server responds with code the browser understands (HTML, CSS, JavaScript)
- Communication happens over HTTP (HTTPS)

---

## Server as Computer

A Virtual Machine on Azure running Ubuntu Linux

- **CPU + RAM** - Determines the VM size on Azure
- **Disk** - Storage with operating system
- **NIC** - Network interface card
<small>

  - **IP** - Public IP address attached to NIC
  - **NSG** - Firewall rules attached to NIC

</small>

---

## Server with a Role

Install nginx to make the server become a

**Web Server**

- Listens on a specific **port** (typically 80 for HTTP)
- Runs as a **daemon** (background process)
- Serves web pages to incoming requests

---

## Security

### Defense in Depth

Multiple layers of protection, not just one

```text
┌─────────────────────────────┐
│  Azure Login (2FA)          │  ← Identity layer
├─────────────────────────────┤
│  Firewall (ports 80, 22)    │  ← Network layer
├─────────────────────────────┤
│  SSH Keys (not passwords)   │  ← Access layer
├─────────────────────────────┤
│  chmod (file permissions)   │  ← File system layer
└─────────────────────────────┘
```

---

## Identity Layer

### Azure Login

- Username + password + **2FA** (two-factor authentication)
- Protects access to the Azure portal
- First line of defense for managing resources

---

## Network Layer

### Firewall (NSG)

- Controls which ports are open to the internet
- **Port 22** - SSH access (remote administration)
- **Port 80** - HTTP traffic (web server)
- Block everything else by default

---

## Access Layer

### SSH Keys

- Key-based authentication instead of passwords
- Private key stays on your computer
- Public key is placed on the server
- Much harder to brute-force than passwords

---

## File System Layer

### File Permissions

- `chmod` controls who can read, write, execute files
- Restricts access even if someone gets onto the server
- Private keys need `chmod 400` (owner read-only)

---

## Summary

**Three server perspectives:**
1. Web server → serves content over HTTP
2. Computer → VM with CPU, RAM, disk, network
3. Role → nginx daemon listening on a port to provide a service

**Defense in depth:**
- Azure 2FA → Firewall → SSH keys → File permissions
- Security is built in from the start, not attached afterwards
