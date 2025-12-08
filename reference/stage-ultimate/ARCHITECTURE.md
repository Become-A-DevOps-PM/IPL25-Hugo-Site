# Stage Ultimate - Architecture Documentation

This document provides visual representations of the Flask Contact Form infrastructure at different abstraction levels.

---

## 1. High-Level Overview

A simplified view showing the main components and their relationships.

```mermaid
flowchart LR
    subgraph Internet
        User([User])
        Admin([Administrator])
    end

    subgraph Azure["Azure Cloud (Sweden Central)"]
        subgraph Network["flask-ultimate-vnet (10.0.0.0/16)"]
            Bastion[Bastion Host]
            Proxy[Reverse Proxy]
            App[Application Server]
        end
        DB[(PostgreSQL)]
        KV[Key Vault]
    end

    User -->|HTTPS| Proxy
    Admin -->|SSH| Bastion
    Bastion -.->|SSH| Proxy
    Bastion -.->|SSH| App
    Proxy -->|HTTP| App
    App -->|SQL| DB
    App -->|HTTPS| KV
```

---

## 2. Network Topology

Detailed view of the Virtual Network structure with subnets and IP addressing.

```mermaid
flowchart TB
    subgraph Internet["Internet"]
        User([User Browser])
        Admin([Administrator])
    end

    subgraph Azure["Azure Resource Group: flask-ultimate-rg"]
        subgraph VNet["Virtual Network: flask-ultimate-vnet<br/>Address Space: 10.0.0.0/16"]

            subgraph bastion-subnet["bastion-subnet<br/>10.0.1.0/24"]
                BastionVM["flask-ultimate-bastion<br/>Private: 10.0.1.4<br/>Public: Dynamic"]
            end

            subgraph proxy-subnet["proxy-subnet<br/>10.0.2.0/24"]
                ProxyVM["flask-ultimate-proxy<br/>Private: 10.0.2.4<br/>Public: Dynamic"]
            end

            subgraph app-subnet["app-subnet<br/>10.0.3.0/24"]
                AppVM["flask-ultimate-app<br/>Private: 10.0.3.4<br/>No Public IP"]
            end

            subgraph db-subnet["db-subnet<br/>10.0.4.0/24"]
                PostgreSQL[("PostgreSQL Flexible Server<br/>flask-db-*.postgres.database.azure.com")]
            end

            subgraph kv-subnet["keyvault-subnet<br/>10.0.5.0/24"]
                KeyVault["Key Vault<br/>flask-kv-*"]
            end
        end
    end

    User -->|"HTTPS (443)"| ProxyVM
    Admin -->|"SSH (22)"| BastionVM
    BastionVM -.->|"SSH (22)"| ProxyVM
    BastionVM -.->|"SSH (22)"| AppVM
    ProxyVM -->|"HTTP (5001)"| AppVM
    AppVM -->|"PostgreSQL (5432)"| PostgreSQL
    AppVM -->|"HTTPS (443)"| KeyVault
```

---

## 3. User Request Flow

Sequence diagram showing how a user request travels through the system.

```mermaid
sequenceDiagram
    autonumber
    participant User as User Browser
    participant Internet as Internet
    participant Proxy as Reverse Proxy<br/>(nginx)
    participant App as App Server<br/>(Gunicorn)
    participant DB as PostgreSQL
    participant KV as Key Vault

    Note over App,KV: Application startup (once)
    App->>KV: GET /secrets/database-url<br/>(Managed Identity)
    KV-->>App: Database connection string
    App->>KV: GET /secrets/secret-key<br/>(Managed Identity)
    KV-->>App: Flask secret key

    Note over User,DB: User submits contact form
    User->>+Internet: HTTPS GET /contact
    Internet->>+Proxy: TCP 443 (TLS)
    Note over Proxy: SSL Termination
    Proxy->>+App: HTTP GET :5001/contact
    App-->>-Proxy: HTML Response
    Proxy-->>-Internet: HTTPS Response
    Internet-->>-User: Contact Form Page

    User->>+Internet: HTTPS POST /contact<br/>(form data)
    Internet->>+Proxy: TCP 443 (TLS)
    Proxy->>+App: HTTP POST :5001/contact
    App->>+DB: INSERT INTO messages
    DB-->>-App: Success
    App-->>-Proxy: HTTP 302 Redirect
    Proxy-->>-Internet: HTTPS 302
    Internet-->>-User: Redirect to /thank-you
```

---

## 4. SSH Management Flow

How administrators access the infrastructure through the bastion host.

```mermaid
sequenceDiagram
    autonumber
    participant Admin as Administrator<br/>(Local Machine)
    participant Bastion as Bastion Host<br/>(10.0.1.4)
    participant Proxy as Proxy VM<br/>(10.0.2.4)
    participant App as App Server<br/>(10.0.3.4)

    Note over Admin,Bastion: Direct SSH (Public IP)
    Admin->>Bastion: ssh azureuser@<bastion-public-ip>
    Bastion-->>Admin: Shell access

    Note over Admin,Proxy: SSH via ProxyJump
    Admin->>Bastion: ssh -J azureuser@bastion azureuser@10.0.2.4
    Bastion->>Proxy: Forward SSH connection
    Proxy-->>Bastion: Shell established
    Bastion-->>Admin: Shell access to Proxy

    Note over Admin,App: SSH via ProxyJump
    Admin->>Bastion: ssh -J azureuser@bastion azureuser@10.0.3.4
    Bastion->>App: Forward SSH connection
    App-->>Bastion: Shell established
    Bastion-->>Admin: Shell access to App Server
```

---

## 5. Network Security Groups

Visual representation of NSG rules controlling traffic between subnets.

```mermaid
flowchart TB
    subgraph Internet["Internet"]
        ExtUser([External Users])
        ExtAdmin([Administrators])
    end

    subgraph bastion-nsg["bastion-nsg"]
        direction TB
        B_Rule1["Allow Inbound<br/>SSH (22) from Internet"]
    end

    subgraph proxy-nsg["proxy-nsg"]
        direction TB
        P_Rule1["Allow Inbound<br/>HTTP (80) from Internet"]
        P_Rule2["Allow Inbound<br/>HTTPS (443) from Internet"]
        P_Rule3["Allow Inbound<br/>SSH (22) from 10.0.1.0/24"]
    end

    subgraph app-nsg["app-nsg"]
        direction TB
        A_Rule1["Allow Inbound<br/>TCP (5001) from 10.0.2.0/24"]
        A_Rule2["Allow Inbound<br/>SSH (22) from 10.0.1.0/24"]
    end

    subgraph db-nsg["db-nsg"]
        direction TB
        D_Rule1["Allow Inbound<br/>PostgreSQL (5432) from 10.0.3.0/24"]
    end

    subgraph kv-nsg["keyvault-nsg"]
        direction TB
        K_Rule1["Allow Inbound<br/>HTTPS (443) from 10.0.3.0/24"]
    end

    ExtAdmin -->|"SSH (22)"| B_Rule1
    ExtUser -->|"HTTP (80)"| P_Rule1
    ExtUser -->|"HTTPS (443)"| P_Rule2
    B_Rule1 -->|"SSH (22)"| P_Rule3
    B_Rule1 -->|"SSH (22)"| A_Rule2
    P_Rule2 -->|"HTTP (5001)"| A_Rule1
    A_Rule1 -->|"PostgreSQL (5432)"| D_Rule1
    A_Rule1 -->|"HTTPS (443)"| K_Rule1
```

---

## 6. Application Component Stack

What software runs on each virtual machine.

```mermaid
flowchart TB
    subgraph BastionStack["Bastion VM Stack"]
        direction TB
        B_OS["Ubuntu 24.04 LTS"]
        B_SSH["OpenSSH Server"]
        B_F2B["fail2ban"]
        B_OS --- B_SSH
        B_SSH --- B_F2B
    end

    subgraph ProxyStack["Proxy VM Stack"]
        direction TB
        P_OS["Ubuntu 24.04 LTS"]
        P_NGINX["nginx 1.24"]
        P_SSL["Self-signed SSL Certificate"]
        P_F2B["fail2ban"]
        P_OS --- P_NGINX
        P_NGINX --- P_SSL
        P_SSL --- P_F2B
    end

    subgraph AppStack["App Server VM Stack"]
        direction TB
        A_OS["Ubuntu 24.04 LTS"]
        A_SYSTEMD["systemd service"]
        A_GUNICORN["Gunicorn (2 workers)"]
        A_FLASK["Flask 3.0 Application"]
        A_VENV["Python 3.12 + venv"]
        A_IDENTITY["Managed Identity"]
        A_OS --- A_SYSTEMD
        A_SYSTEMD --- A_GUNICORN
        A_GUNICORN --- A_FLASK
        A_FLASK --- A_VENV
        A_VENV --- A_IDENTITY
    end

    subgraph AzureServices["Azure Managed Services"]
        direction TB
        PG["PostgreSQL Flexible Server<br/>Version 17<br/>Burstable B1ms"]
        KV["Azure Key Vault<br/>RBAC Enabled<br/>Secrets: database-url,<br/>secret-key, postgresql-admin-password"]
    end

    ProxyStack -->|"Reverse Proxy"| AppStack
    AppStack -->|"SQL Queries"| PG
    AppStack -->|"Secret Retrieval"| KV
```

---

## 7. Data Flow and Trust Boundaries

Shows how data flows and where security boundaries exist.

```mermaid
flowchart TB
    subgraph Untrusted["Untrusted Zone (Internet)"]
        User([User])
    end

    subgraph DMZ["DMZ (Public-Facing)"]
        Bastion["Bastion<br/>(SSH only)"]
        Proxy["Reverse Proxy<br/>(HTTPS termination)"]
    end

    subgraph Trusted["Trusted Zone (Private Network)"]
        App["Application Server"]

        subgraph DataLayer["Data Layer"]
            DB[(PostgreSQL)]
            KV[Key Vault]
        end
    end

    User ==>|"HTTPS (encrypted)"| Proxy
    Proxy -->|"HTTP (plaintext, private network)"| App
    App -->|"TLS (encrypted)"| DB
    App -->|"HTTPS + Managed Identity"| KV

    Bastion -.->|"SSH (management)"| Proxy
    Bastion -.->|"SSH (management)"| App

    style Untrusted fill:#ffcccc,stroke:#cc0000
    style DMZ fill:#ffffcc,stroke:#cccc00
    style Trusted fill:#ccffcc,stroke:#00cc00
    style DataLayer fill:#cce5ff,stroke:#0066cc
```

---

## 8. Deployment Pipeline

How code and configuration flow from development to production.

```mermaid
flowchart LR
    subgraph Local["Local Development Machine"]
        Code["Application Code<br/>(application/)"]
        Scripts["Deploy Scripts<br/>(deploy/)"]
        Infra["Provisioning Scripts<br/>(infrastructure/)"]
    end

    subgraph Azure["Azure Cloud"]
        subgraph Provision["Phase 1: Provision"]
            RG["Resource Group"]
            Net["VNet + Subnets + NSGs"]
            KVault["Key Vault + Secrets"]
            PGServer["PostgreSQL Server"]
            VMs["3 Virtual Machines"]
        end

        subgraph Deploy["Phase 2: Deploy"]
            Sync["rsync via Bastion"]
            Setup["pip install + venv"]
            Systemd["systemd service"]
            Nginx["nginx configuration"]
            Migrate["Database migration"]
        end
    end

    Infra -->|"./provision.sh"| RG
    RG --> Net --> KVault --> PGServer --> VMs

    Code -->|"./deploy.sh"| Sync
    Scripts -->|"./deploy.sh"| Sync
    Sync --> Setup --> Systemd --> Nginx --> Migrate
```

---

## 9. Port and Protocol Summary

| Source | Destination | Port | Protocol | Purpose |
|--------|-------------|------|----------|---------|
| Internet | Bastion | 22 | SSH | Administrator access |
| Internet | Proxy | 80 | HTTP | Redirect to HTTPS |
| Internet | Proxy | 443 | HTTPS | User web traffic |
| Bastion (10.0.1.0/24) | Proxy | 22 | SSH | Management access |
| Bastion (10.0.1.0/24) | App Server | 22 | SSH | Management access |
| Proxy (10.0.2.0/24) | App Server | 5001 | HTTP | Application traffic |
| App Server (10.0.3.0/24) | PostgreSQL | 5432 | PostgreSQL | Database queries |
| App Server (10.0.3.0/24) | Key Vault | 443 | HTTPS | Secret retrieval |

---

## 10. IP Address Reference

| Component | Private IP | Public IP | Subnet |
|-----------|------------|-----------|--------|
| Bastion VM | 10.0.1.4 | Dynamic | bastion-subnet |
| Proxy VM | 10.0.2.4 | Dynamic | proxy-subnet |
| App Server VM | 10.0.3.4 | None | app-subnet |
| PostgreSQL | N/A (PaaS) | N/A | db-subnet (logical) |
| Key Vault | N/A (PaaS) | N/A | keyvault-subnet (logical) |

---

## Diagram Legend

```mermaid
flowchart LR
    A[VM/Service] -->|"Solid: Data flow"| B[VM/Service]
    C[VM/Service] -.->|"Dashed: Management"| D[VM/Service]
    E[VM/Service] ==>|"Thick: Encrypted"| F[VM/Service]
    G([Rounded: External Actor])
    H[(Cylinder: Database)]
    I[Rectangle: Service/VM]
```
