+++
title = "Week 2 Technical Recap"
type = "slide"
date = 2025-12-08
weight = 2
draft = false
hidden = false

theme = "sky"
[revealOptions]
controls = true
progress = true
history = true
center = true
+++

### Week 2

## Technical Recap

- IP addresses and Azure VNets
- Firewall rules (the five-tuple)
- OSI Layer 4 vs Layer 7
- Reverse proxy and bastion host

---

## IP Addresses

**Private** - Used inside networks, not routable on internet

- `10.0.0.0/8` - Large networks
- `172.16.0.0/12` - Medium networks
- `192.168.0.0/16` - Small networks

**Public** - Globally unique, routable on internet

- Assigned by your cloud provider
- Required for internet-facing services

---

## Azure Virtual Networks

```text
┌─────────────────────────────────────┐
│  VNet: 10.0.0.0/16                  │
│  (Your private address space)       │
│                                     │
│  ┌─────────────┐  ┌─────────────┐  │
│  │ Subnet A    │  │ Subnet B    │  │
│  │ 10.0.1.0/24 │  │ 10.0.2.0/24 │  │
│  │             │  │             │  │
│  │  [VM]  [VM] │  │  [VM]       │  │
│  └─────────────┘  └─────────────┘  │
└─────────────────────────────────────┘
```

VMs get **private IPs** from their subnet

---

## Public IP in Azure

```text
        Internet
            │
    ┌───────┴───────┐
    │  Public IP    │
    │  20.1.2.3     │
    └───────┬───────┘
            │
    ┌───────┴───────┐
    │  VM (NIC)     │
    │  10.0.1.4     │  ← Private IP
    └───────────────┘
```

Public IP attached to NIC allows inbound traffic from internet

---

## Network Security Group (NSG)

Firewall rules using the **five-tuple**:

<small>

| Rule | Src IP | Src Port | Dest IP | Dest Port | Protocol |
|------|--------|----------|---------|-----------|----------|
| Allow SSH | `*` | `*` | `10.0.1.4` | `22` | TCP |
| Allow HTTP | `*` | `*` | `10.0.1.4` | `80` | TCP |

</small>

Default behavior: **Deny all** unless explicitly allowed

---

## OSI Model: Layer 4

### Transport Layer

- **TCP** - Reliable, ordered delivery (HTTP, SSH, databases)
- **UDP** - Fast, no guarantees (video streaming)

**NSG rules operate at Layer 4**

- Can filter by IP address and port number
- Cannot inspect application content

---

## OSI Model: Layer 7

### Application Layer

- **HTTP/HTTPS** - Web traffic (port 80/443)
- **SSH** - Secure shell (port 22)

**Layer 7 devices can inspect content**

- Read HTTP headers and URLs
- Make routing decisions based on application data
- Terminate SSL/TLS encryption

---

## Reverse Proxy

Sits **in front of** application servers

```text
                 ┌───────────┐      ┌───────────┐
  Internet ────► │  nginx    │ ───► │ Gunicorn  │
                 │ :80/:443  │      │  :5001    │
                 └───────────┘      └───────────┘
                 Reverse proxy       App server
                  (Layer 7)        (internal only)
```

- Terminates SSL, routes requests, hides internal structure
- Client only sees the proxy, not the app server

---

## Bastion Host

Secure **jump server** for SSH access

```text
                 ┌───────────┐      ┌───────────┐
  Internet ────► │  Bastion  │ ───► │ Target VM │
                 │    :22    │      │    :22    │
                 └───────────┘      └───────────┘
                  Jump server       No public IP
                  (public IP)         needed
```

- Only the bastion has a public IP
- Target VMs stay isolated from internet
- All SSH traffic flows through one controlled entry point

---

## Summary

<small>

**IP Addressing:** Private IPs inside VNet, public IP for internet access

**Firewall (NSG):** Five-tuple rules, default deny, explicit allow

**OSI Layers:** L4 = port filtering (NSG), L7 = content inspection (proxy)

**Intermediaries:** Reverse proxy fronts app servers, bastion for SSH access

</small>
