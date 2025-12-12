# Flask Application on Azure - Bicep Implementation Plan

This document outlines the phased implementation plan for deploying a minimal Flask application on Azure using Infrastructure as Code (Bicep) and cloud-init configuration.

---

## ⚠️ AGENT EXECUTION INSTRUCTIONS - READ FIRST

**This section is mandatory reading before taking any action.** If you've been asked to "follow the implementation plan" or "execute this plan", follow these instructions exactly.

### Execution Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        MANDATORY EXECUTION WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  STEP 0: READ THIS ENTIRE DOCUMENT FIRST                                         │
│          Do NOT start executing until you understand the full plan               │
│          Key sections: Automated Execution Protocol (line ~3126+)                │
│                                                                                  │
│  STEP 1: CREATE ALL FILES FROM THIS DOCUMENT                                     │
│          Extract code from Implementation Phases into actual files               │
│          Create: infrastructure/, cloud-init/, scripts/, deploy/, application/   │
│          This document is the ONLY file that exists - you must create the rest   │
│                                                                                  │
│  STEP 2: CREATE execution-state.json                                             │
│          Use the JSON template in "Automated Execution Protocol" section         │
│          This is your authoritative task tracker                                 │
│                                                                                  │
│  STEP 3: ANALYZE DEPENDENCIES FOR PARALLELIZATION                                │
│          See "Dependency Analysis and Subagent Delegation" section               │
│          Identify which tasks can run in parallel via subagents                  │
│                                                                                  │
│  STEP 4: EXECUTE PHASES A → F                                                    │
│          Phase A: Prerequisites & Setup (main agent)                             │
│          Phase B: Infrastructure Deployment (main agent)                         │
│          Phase C: Resource Readiness (SPAWN SUBAGENTS - parallel)                │
│          Phase D: Application Deployment (main agent)                            │
│          Phase E: Verification & Testing (partial subagents)                     │
│          Phase F: Report Generation (main agent)                                 │
│                                                                                  │
│  STEP 5: ITERATE ON ERRORS - DO NOT GIVE UP                                      │
│          Self-heal errors using diagnostic commands                              │
│          Retry failed tasks (respect max_attempts)                               │
│          Log all errors, root causes, and resolutions                            │
│                                                                                  │
│  STEP 6: GENERATE FINAL REPORT                                                   │
│          Classify as PASS / PARTIAL / FAIL                                       │
│          Document any deviations from plan                                       │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Quick Reference: Key Sections

| Section | Line | Purpose |
|---------|------|---------|
| **Time Tracking Requirements** | ~114 | HOW to capture precise timestamps using system calls |
| **When In Doubt, Refer to This Document** | ~214 | Reminder to always check this plan for task context |
| **Resuming After Interruption** | ~235 | HOW to resume after context compaction or session break |
| **Implementation Phases** | ~642 | WHAT to build (technical details of each component) |
| **Complete Bicep Templates** | ~1505 | All 6 Bicep files with complete code (~820 lines total) |
| **Automated Execution Protocol** | ~3126 | HOW to execute (methodology, JSON tracking, error handling) |
| **JSON Execution State Template** | ~3145 | 24 tasks across 6 phases with dependencies |
| **Dependency Analysis & Subagent Delegation** | ~3595 | Which tasks to parallelize, subagent context requirements |
| **Error Handling Strategy** | ~3851 | Common errors and self-healing actions |

### ⚠️ CRITICAL: File Creation Required

**This implementation plan document (IMPLEMENTATION-PLAN.md) is the ONLY file that exists.** All other files listed in the File Structure section must be **CREATED FROM THIS DOCUMENT** before execution can begin.

The document contains complete code samples for:
- All Bicep templates (`infrastructure/*.bicep`)
- All cloud-init YAML files (`cloud-init/*.yaml`)
- All shell scripts (`scripts/*.sh`, `deploy/*.sh`, `deploy-all.sh`)
- Flask application code (`application/*.py`)
- Configuration files (`.gitignore`, `parameters.example.json`)

**You must extract and create these files from the code blocks in this document.**

### Execution Checklist

```
□ Step 0: Read entire document, understand architecture and phases
□ Step 1: CREATE ALL FILES from code samples in this document:
    □ Directory structure (scripts/, infrastructure/, cloud-init/, deploy/, application/)
    □ Bicep templates (main.bicep, modules/*.bicep)
    □ Cloud-init files (bastion.yaml, proxy.yaml, app-server.yaml)
    □ Shell scripts (deploy-all.sh, scripts/*.sh, deploy/deploy.sh)
    □ Application files (app.py, requirements.txt, wsgi.py)
    □ Config files (.gitignore, parameters.example.json)
□ Step 2: Create execution-state.json with unique execution_id
□ Step 3: Verify all prerequisites (A1-A6)
□ Step 4: Deploy infrastructure via Bicep (B1-B2)
□ Step 5: Spawn subagents for parallel tasks:
    □ Subagent 1: PostgreSQL readiness monitor (C1)
    □ Subagent 2: Cloud-init monitor for all VMs (C2, C3, C4)
    □ Subagent 3: Security verification (E5, E6)
□ Step 6: Deploy application (D1-D4) after subagents complete
□ Step 7: Run functional tests (E1-E4, E7, E8)
□ Step 8: Collect logs and generate test report (F1-F2)
□ Step 9: Update execution-state.json with final results
```

### Critical Behaviors

1. **UNATTENDED EXECUTION** - No human intervention required. Make decisions autonomously.
2. **JSON-FIRST** - Create and maintain execution-state.json as your single source of truth.
3. **PARALLELIZE** - Use subagents for C1, C2-C4, E5-E6 to save time and context.
4. **ITERATE** - Retry failed tasks up to max_attempts. Investigate and fix errors.
5. **DOCUMENT** - Log every error, its root cause, and how you resolved it.
6. **COMPLETE** - Do not stop until all tasks are done or definitively failed.
7. **REFER BACK** - When in doubt about any task, ALWAYS refer back to this IMPLEMENTATION-PLAN.md for full context. The plan contains detailed specifications for every component.
8. **TIME TRACKING** - Record precise timestamps for every task using system calls (see Time Tracking section below).

### ⏱️ Time Tracking Requirements

**All timestamps MUST be captured using actual system calls**, not estimates. This ensures accurate duration tracking for performance analysis.

**How to capture timestamps:**

```bash
# Get current timestamp in ISO 8601 format with timezone
date -u +"%Y-%m-%dT%H:%M:%SZ"

# Example output: 2024-01-15T14:32:45Z
```

**What to track:**

| Event | When to Record | JSON Field |
|-------|----------------|------------|
| **Workflow Start** | Before Step 1 begins | `started_at` (root level) |
| **Workflow End** | After F2 (report) completes | `completed_at` (root level) |
| **Phase Start** | When first task of phase begins | `phases.[X].started_at` |
| **Phase End** | When last task of phase completes | `phases.[X].completed_at` |
| **Task Start** | Immediately before executing task | `tasks.[N].started_at` |
| **Task End** | Immediately after task verification | `tasks.[N].completed_at` |

**Calculate durations:**

```bash
# Calculate duration in seconds between two ISO timestamps
START="2024-01-15T14:32:45Z"
END="2024-01-15T14:45:12Z"

# On macOS:
START_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$START" +%s)
END_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$END" +%s)
DURATION=$((END_SEC - START_SEC))
echo "Duration: ${DURATION} seconds"

# On Linux:
START_SEC=$(date -d "$START" +%s)
END_SEC=$(date -d "$END" +%s)
DURATION=$((END_SEC - START_SEC))
echo "Duration: ${DURATION} seconds"
```

**Time tracking in execution-state.json:**

```json
{
  "started_at": "2024-01-15T14:32:45Z",
  "completed_at": "2024-01-15T15:12:33Z",
  "total_duration_seconds": 2388,

  "phases": {
    "A": {
      "started_at": "2024-01-15T14:32:45Z",
      "completed_at": "2024-01-15T14:33:12Z",
      "duration_seconds": 27
    }
  },

  "tasks": [
    {
      "id": "A1",
      "started_at": "2024-01-15T14:32:45Z",
      "completed_at": "2024-01-15T14:32:47Z",
      "duration_seconds": 2
    }
  ]
}
```

**Final report must include:**

```markdown
## Execution Timing Summary

| Metric | Value |
|--------|-------|
| **Total Duration** | 39 minutes 48 seconds |
| **Start Time** | 2024-01-15T14:32:45Z |
| **End Time** | 2024-01-15T15:12:33Z |

### Phase Durations
| Phase | Duration | Notes |
|-------|----------|-------|
| A: Prerequisites | 27s | All checks passed |
| B: Infrastructure | 18m 45s | Bicep deployment |
| C: Resource Readiness | 12m 30s | PostgreSQL took longest |
| D: Application Deployment | 3m 15s | Smooth deployment |
| E: Verification | 4m 22s | All tests passed |
| F: Report Generation | 49s | Logs collected |

### Slowest Tasks
1. B2: Deploy Bicep templates - 18m 12s
2. C1: Wait for PostgreSQL ready - 11m 45s
3. C2: Wait for bastion cloud-init - 4m 30s
```

### 📚 When In Doubt, Refer to This Document

**IMPORTANT:** If you are ever uncertain about:
- What a task requires
- How to implement a specific component
- What parameters or configuration to use
- How to handle an edge case
- What the expected output should be

**ALWAYS read the relevant section of this IMPLEMENTATION-PLAN.md document.** It contains:
- Complete Bicep template code (Implementation Phases 1-5)
- Complete cloud-init YAML configurations (Phase 2, 3, 5)
- Complete Flask application code (Phase 6)
- Complete shell script implementations (Phase 7)
- Network architecture and IP addressing (Network Design section)
- Database connection details (Database Connection Strategy section)
- SSH configuration (SSH Configuration section)
- Error handling strategies (Error Handling Strategy section)

**The implementation plan is your authoritative reference.** Do not guess or assume - look it up.

### 🔄 Resuming After Interruption (Context Compaction / Session Break)

If you are resuming work after a context compaction, session interruption, or you've been asked to "continue" or "resume" the implementation:

**IMMEDIATE FIRST ACTIONS:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         RESUME PROTOCOL                                          │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  1. READ execution-state.json                                                    │
│     Location: reference/flask-bicep/execution-state.json                         │
│     This is your SINGLE SOURCE OF TRUTH for current progress                     │
│                                                                                  │
│  2. CHECK the "status" and "current_task" fields                                 │
│     - If status = "in_progress", find current_task and resume from there         │
│     - If status = "not_started", begin from Step 1 (file creation)               │
│     - If status = "completed", report final results to user                      │
│                                                                                  │
│  3. SCAN the "tasks" array for:                                                  │
│     - Tasks with status = "in_progress" (resume these)                           │
│     - Tasks with status = "failed" (may need retry)                              │
│     - Tasks with status = "pending" and all dependencies "completed"             │
│                                                                                  │
│  4. CHECK for running subagents                                                  │
│     - Look for tasks C1, C2-C4, E5-E6 that may be in_progress                   │
│     - These may have been running in parallel before interruption                │
│     - Verify their status before spawning new subagents                          │
│                                                                                  │
│  5. READ execution-log.md for context                                            │
│     Location: reference/flask-bicep/execution-log.md                             │
│     Contains human-readable narrative of what was done                           │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Key Files to Check on Resume:**

| File | Location | Purpose |
|------|----------|---------|
| `execution-state.json` | `reference/flask-bicep/` | **PRIMARY** - Machine-readable progress tracker |
| `execution-log.md` | `reference/flask-bicep/` | Human-readable execution narrative |
| `errors/` | `reference/flask-bicep/errors/` | Error artifacts from failed tasks |
| `diagnostics/` | `reference/flask-bicep/diagnostics/` | Captured diagnostic logs |

**Resume Decision Tree:**

```
execution-state.json exists?
├── NO  → Start fresh (Step 0: Read document, Step 1: Create files)
└── YES → Read it
          │
          ├── status = "not_started"
          │   └── Check if files exist → If yes, proceed to Step 2 (create JSON was done)
          │                            → If no, Step 1 (create files)
          │
          ├── status = "in_progress"
          │   └── Find current_task → Resume that task
          │       └── Check if task was partially complete
          │           └── May need to verify/rollback partial state
          │
          ├── status = "failed"
          │   └── Read errors_log → Understand what failed
          │       └── Attempt to fix and retry from failed task
          │
          └── status = "completed"
              └── Read final_result → Report to user
                  └── Ask if they want to run verification again
```

**Verifying Azure State on Resume:**

If resuming mid-deployment, verify actual Azure state matches expected state:

```bash
# Check if resource group exists
az group show -n rg-flask-bicep-dev -o table 2>/dev/null

# If exists, list resources to understand current state
az resource list -g rg-flask-bicep-dev -o table

# Check PostgreSQL state
az postgres flexible-server show -g rg-flask-bicep-dev -n psql-flask-bicep-dev --query state -o tsv 2>/dev/null

# Check VM states
az vm list -g rg-flask-bicep-dev -d -o table 2>/dev/null
```

Update `execution-state.json` if Azure state differs from recorded state (e.g., a task marked "in_progress" but the resource is actually "Succeeded").

### Warning: Two "Phase" Systems

This document contains TWO different phase numbering systems:

| System | Where | Purpose |
|--------|-------|---------|
| **Implementation Phases 1-8** | "Implementation Phases" section (~line 642) | Describes WHAT to build (technical components) |
| **Execution Phases A-F** | JSON tasks, Automated Execution Protocol | Describes HOW to execute (workflow steps) |

**When executing, follow Phases A-F from the JSON execution state**, not Implementation Phases 1-8. The Implementation Phases section provides technical reference only.

---

## Prerequisites

Before running the deployment, ensure you have the following installed and configured:

| Requirement | Command to Check | Installation |
|-------------|------------------|--------------|
| Azure CLI | `az --version` | `brew install azure-cli` |
| Azure Login | `az account show` | `az login` |
| jq (JSON processor) | `jq --version` | `brew install jq` |
| SSH Key | `ls ~/.ssh/id_rsa.pub` | `ssh-keygen -t rsa -b 4096` |

**Azure Subscription:** An active Azure subscription with permissions to create:
- Resource Groups
- Virtual Networks and Subnets
- Virtual Machines (Standard_B1s)
- PostgreSQL Flexible Server
- Network Security Groups

**Estimated cost:** ~$44/month (see Technology Stack section for breakdown)

---

## Overview

### Purpose

Deploy a simple Flask application in a **three-tier infrastructure architecture** on Azure:

1. **Web Tier** - Reverse proxy (nginx) for SSL termination and request routing
2. **Application Tier** - Flask application server (Gunicorn)
3. **Data Tier** - Managed PostgreSQL database

Additional infrastructure:
- Bastion host for secure SSH management access
- Network segmentation with dedicated subnets per tier
- Private connectivity to database (no public endpoint)

### Deployment Strategy

The deployment follows a **two-stage approach**:

1. **Infrastructure Provisioning and Configuration (Bicep + cloud-init)**
   - Bicep templates create all Azure resources (including the `flask` database on PostgreSQL)
   - Cloud-init configures VMs with required software and services
   - Cloud-init does **NOT** deploy the application code

2. **Application Deployment (Bash script via SSH jump)**
   - A separate `deploy.sh` script copies application files to the app server
   - Uses SSH ProxyJump (`-J`) through the bastion host
   - Runs from the local development machine

```
┌─────────────────┐     SSH Jump      ┌─────────────┐     SSH      ┌─────────────┐
│ Local Machine   │ ─────────────────▶│ vm-bastion  │ ───────────▶ │ vm-app      │
│                 │                   │ (jump host) │              │             │
│ deploy.sh       │                   │             │              │ Application │
│ application/    │ ═══scp files════▶ │             │ ═══════════▶ │ deployed    │
└─────────────────┘                   └─────────────┘              └─────────────┘
```

**Why this approach?**
- Keeps application code separate from infrastructure
- Allows iterative development without reprovisioning VMs
- Mirrors real-world deployment workflows
- Cloud-init prepares the environment; deploy script delivers the code

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ Azure (Resource Group: rg-flask-bicep-dev)                                      │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │ Virtual Network: vnet-flask-bicep-dev (10.0.0.0/16)                       │  │
│  │                                                                           │  │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐           │  │
│  │  │ snet-bastion    │  │ snet-web        │  │ snet-app        │           │  │
│  │  │ 10.0.1.0/24     │  │ 10.0.2.0/24     │  │ 10.0.3.0/24     │           │  │
│  │  │                 │  │                 │  │                 │           │  │
│  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │           │  │
│  │  │  │ vm-bastion│  │  │  │ vm-proxy  │  │  │  │ vm-app    │  │           │  │
│  │  │  │ fail2ban  │──┼──┼─▶│ nginx     │──┼──┼─▶│ Gunicorn  │  │           │  │
│  │  │  └───────────┘  │  │  │ :80/:443  │  │  │  │ Flask     │  │           │  │
│  │  │       │         │  │  └───────────┘  │  │  │ :5001     │  │           │  │
│  │  │       │ SSH:22  │  │       ▲         │  │  └─────┬─────┘  │           │  │
│  │  └───────┼─────────┘  └───────┼─────────┘  └────────┼────────┘           │  │
│  │          │                    │                     │                    │  │
│  │          │              ┌─────┴─────┐               │                    │  │
│  │          │              │ pip-proxy │               │                    │  │
│  │          │              │ Public IP │               │                    │  │
│  │          │              └───────────┘               │                    │  │
│  │    ┌─────┴─────┐                              ┌─────┴─────────────────┐  │  │
│  │    │pip-bastion│                              │ snet-data             │  │  │
│  │    │ Public IP │                              │ 10.0.4.0/24           │  │  │
│  │    └───────────┘                              │                       │  │  │
│  │                                               │  ┌─────────────────┐  │  │  │
│  │                                               │  │ psql-flask-bicep│  │  │  │
│  │                                               │  │ PostgreSQL      │  │  │  │
│  │                                               │  │ Flexible Server │  │  │  │
│  │                                               │  │ :5432           │  │  │  │
│  │                                               │  │ (VNet Integr.)  │  │  │  │
│  │                                               │  └─────────────────┘  │  │  │
│  │                                               └───────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘

Traffic Flows:
─────────────
Browser ──HTTP/HTTPS──▶ pip-proxy ──▶ vm-proxy:80/443 ──▶ vm-app:5001 ──▶ psql:5432
SSH     ──────────────▶ pip-bastion ──▶ vm-bastion:22 ──▶ (internal VMs):22
```

---

## Naming Convention

Following [Microsoft Cloud Adoption Framework naming conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) with [recommended abbreviations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).

### Pattern

```
<resource-abbreviation>-<workload>-<environment>[-<region>][-<instance>]
```

### Resource Names

| Resource Type | Abbreviation | Full Name |
|--------------|--------------|-----------|
| Resource Group | rg | `rg-flask-bicep-dev` |
| Virtual Network | vnet | `vnet-flask-bicep-dev` |
| Subnet (Bastion) | snet | `snet-bastion` |
| Subnet (Web) | snet | `snet-web` |
| Subnet (App) | snet | `snet-app` |
| Subnet (Data) | snet | `snet-data` |
| NSG (Bastion) | nsg | `nsg-bastion` |
| NSG (Web) | nsg | `nsg-web` |
| NSG (App) | nsg | `nsg-app` |
| NSG (Data) | nsg | `nsg-data` |
| ASG (Bastion) | asg | `asg-bastion` |
| ASG (Proxy) | asg | `asg-proxy` |
| ASG (App) | asg | `asg-app` |
| Public IP (Bastion) | pip | `pip-bastion` |
| Public IP (Proxy) | pip | `pip-proxy` |
| NIC (Bastion) | nic | `nic-bastion` |
| NIC (Proxy) | nic | `nic-proxy` |
| NIC (App) | nic | `nic-app` |
| VM (Bastion) | vm | `vm-bastion` |
| VM (Proxy) | vm | `vm-proxy` |
| VM (App) | vm | `vm-app` |
| PostgreSQL Server | psql | `psql-flask-bicep-dev` |
| PostgreSQL Database | - | `flask` |
| Private DNS Zone | - | `postgres.database.azure.com` |
| Virtual Network Link | - | `vnetlink-flask-bicep-dev` |

---

## Technology Stack

| Layer | Technology | Version | Notes |
|-------|------------|---------|-------|
| **Infrastructure** |
| IaC | Bicep | Latest | Azure-native, type-safe |
| VM Config | cloud-init | cloud-config | Declarative YAML |
| Region | Sweden Central | - | `swedencentral` |
| **Compute** |
| VM Size | Standard_B1s | - | 1 vCPU, 1 GiB RAM (~$7/month) |
| OS | Ubuntu | 24.04 LTS | Per course standards |
| **Application** |
| Language | Python | 3.12+ | Ubuntu 24.04 default |
| Framework | Flask | 3.0+ | Minimal application |
| WSGI | Gunicorn | Latest | Production server |
| **Web** |
| Reverse Proxy | nginx | 1.24+ | SSL termination |
| SSL | Self-signed | - | For learning environment |
| **Database** |
| Service | PostgreSQL Flexible Server | 16 | Azure managed |
| Tier | Burstable B1ms | - | 1 vCore, 2 GiB (~$12/month) |
| Storage | 32 GiB | - | Minimum size |
| **Security** |
| SSH Keys | User's default | `~/.ssh/id_rsa.pub` | Same key for all VMs |
| SSH Hardening | fail2ban | Latest | On bastion host |
| Network | NSG + ASG | - | Defense in depth |
| Connectivity | VNet Integration | - | No public DB endpoint |

### Estimated Monthly Cost

| Resource | Cost |
|----------|------|
| 3x Standard_B1s VMs | ~$21 |
| PostgreSQL B1ms | ~$12 |
| Storage (32 GiB) | ~$4 |
| Public IPs (2x) | ~$7 |
| **Total** | **~$44/month** |

---

## Network Design

### Address Space

| Network | CIDR | Purpose |
|---------|------|---------|
| Virtual Network | 10.0.0.0/16 | 65,536 addresses |
| snet-bastion | 10.0.1.0/24 | Bastion host (256 addresses) |
| snet-web | 10.0.2.0/24 | Reverse proxy (256 addresses) |
| snet-app | 10.0.3.0/24 | Application server (256 addresses) |
| snet-data | 10.0.4.0/24 | PostgreSQL VNet Integration (256 addresses, **delegated**) |

### Subnet Delegation

The `snet-data` subnet **must** be delegated to PostgreSQL Flexible Server. This is required for VNet Integration:

```bicep
// In network.bicep - snet-data subnet definition
{
  name: 'snet-data'
  properties: {
    addressPrefix: '10.0.4.0/24'
    delegations: [
      {
        name: 'Microsoft.DBforPostgreSQL.flexibleServers'
        properties: {
          serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
        }
      }
    ]
  }
}
```

**Important:** A delegated subnet can only contain resources of the delegated type. No VMs or other resources can be placed in `snet-data`.

### Internal DNS Resolution

Azure automatically provides internal DNS resolution within a virtual network. VMs can reach each other using their hostname without needing static IP addresses.

| VM | Hostname | Subnet |
|----|----------|--------|
| vm-bastion | `vm-bastion` | snet-bastion |
| vm-proxy | `vm-proxy` | snet-web |
| vm-app | `vm-app` | snet-app |

**Example:** The nginx reverse proxy configuration uses the hostname `vm-app` to forward requests:
```nginx
proxy_pass http://vm-app:5001;
```

**Database:** Uses Private DNS zone for resolution within the VNet:
```
psql-flask-bicep-dev.postgres.database.azure.com
```

**Note:** With VNet Integration, the server is accessible from within the VNet using the standard Azure PostgreSQL hostname. The Private DNS Zone ensures this resolves to the private IP within the VNet.

### Application Security Groups

Each VM is assigned to an Application Security Group (ASG), enabling identity-based network rules rather than IP-based rules.

| ASG | Assigned To | Purpose |
|-----|-------------|---------|
| `asg-bastion` | vm-bastion | SSH jump host identity |
| `asg-proxy` | vm-proxy | Reverse proxy identity |
| `asg-app` | vm-app | Application server identity |

### Network Security Groups

NSG rules reference ASGs for source/destination, making rules more readable and maintainable.

#### nsg-bastion (Bastion Subnet)

| Priority | Name | Direction | Source | Destination | Port | Action |
|----------|------|-----------|--------|-------------|------|--------|
| 100 | AllowSSHInbound | Inbound | Internet | asg-bastion | 22 | Allow |
| 1000 | DenyAllInbound | Inbound | * | * | * | Deny |

#### nsg-web (Web Subnet)

| Priority | Name | Direction | Source | Destination | Port | Action |
|----------|------|-----------|--------|-------------|------|--------|
| 100 | AllowHTTPInbound | Inbound | Internet | asg-proxy | 80 | Allow |
| 110 | AllowHTTPSInbound | Inbound | Internet | asg-proxy | 443 | Allow |
| 120 | AllowSSHFromBastion | Inbound | asg-bastion | asg-proxy | 22 | Allow |
| 1000 | DenyAllInbound | Inbound | * | * | * | Deny |

#### nsg-app (App Subnet)

| Priority | Name | Direction | Source | Destination | Port | Action |
|----------|------|-----------|--------|-------------|------|--------|
| 100 | AllowAppFromProxy | Inbound | asg-proxy | asg-app | 5001 | Allow |
| 110 | AllowSSHFromBastion | Inbound | asg-bastion | asg-app | 22 | Allow |
| 1000 | DenyAllInbound | Inbound | * | * | * | Deny |

#### nsg-data (Data Subnet)

| Priority | Name | Direction | Source | Destination | Port | Action |
|----------|------|-----------|--------|-------------|------|--------|
| 100 | AllowPostgresFromApp | Inbound | 10.0.3.0/24 | * | 5432 | Allow |
| 1000 | DenyAllInbound | Inbound | * | * | * | Deny |

**Note:** The source uses `snet-app` CIDR (`10.0.3.0/24`) instead of an ASG because PostgreSQL Flexible Server is a PaaS service, not a VM with a NIC that can be assigned to an ASG.

---

## Implementation Phases

### Phase 1: Network Foundation

**Objective:** Deploy the virtual network with all subnets and security groups.

**Bicep Resources:**
- Virtual Network
- 4 Subnets
- 4 Network Security Groups
- 3 Application Security Groups (bastion, proxy, app)
- NSG ↔ Subnet associations

**Verification:**
```bash
# List all resources in resource group
az resource list --resource-group rg-flask-bicep-dev --output table

# Verify vNet and subnets
az network vnet show --resource-group rg-flask-bicep-dev --name vnet-flask-bicep-dev --output table
az network vnet subnet list --resource-group rg-flask-bicep-dev --vnet-name vnet-flask-bicep-dev --output table

# Verify NSGs
az network nsg list --resource-group rg-flask-bicep-dev --output table
```

**Success Criteria:**
- [ ] Virtual network created with 10.0.0.0/16 address space
- [ ] All 4 subnets created with correct CIDR ranges
- [ ] All 4 NSGs created and associated with subnets
- [ ] All 3 ASGs created (asg-bastion, asg-proxy, asg-app)

---

### Phase 2: Bastion Host

**Objective:** Deploy the bastion host with public IP and SSH hardening.

**Bicep Resources:**
- Public IP (pip-bastion)
- Network Interface (nic-bastion)
- Virtual Machine (vm-bastion)

**Complete cloud-init for bastion** (`cloud-init/bastion.yaml`):
```yaml
#cloud-config
package_update: true
package_upgrade: true

packages:
  - fail2ban
  - ufw

write_files:
  - path: /etc/fail2ban/jail.local
    content: |
      [sshd]
      enabled = true
      port = ssh
      filter = sshd
      logpath = /var/log/auth.log
      maxretry = 3
      bantime = 3600
      findtime = 600

  - path: /etc/ssh/sshd_config.d/hardening.conf
    content: |
      PasswordAuthentication no
      PermitRootLogin no
      PubkeyAuthentication yes
      MaxAuthTries 3

runcmd:
  # Enable and start fail2ban
  - systemctl enable fail2ban
  - systemctl start fail2ban
  # Restart SSH to apply hardening
  - systemctl restart sshd
```

**Verification:**
```bash
# Get bastion public IP
BASTION_IP=$(az vm show --resource-group rg-flask-bicep-dev --name vm-bastion --show-details --query publicIps --output tsv)

# Test SSH connection
ssh -i ~/.ssh/id_rsa azureuser@$BASTION_IP

# On bastion, verify fail2ban is running
sudo systemctl status fail2ban
sudo fail2ban-client status sshd
```

**Success Criteria:**
- [ ] Bastion VM created and running
- [ ] Public IP assigned and accessible
- [ ] SSH connection successful with key authentication
- [ ] fail2ban active and monitoring SSH

---

### Phase 3: Reverse Proxy

**Objective:** Deploy the nginx reverse proxy with public IP and SSL.

**Bicep Resources:**
- Public IP (pip-proxy)
- Network Interface (nic-proxy)
- Virtual Machine (vm-proxy)

**Cloud-init Configuration:**
- nginx installation
- Self-signed SSL certificate generation (stored in `/etc/nginx/ssl/`)
- Reverse proxy configuration pointing to `vm-app:5001` (using internal DNS)
- HTTP to HTTPS redirect (all port 80 traffic redirected to port 443)

**nginx configuration file** (`/etc/nginx/sites-available/flask-app`):
```nginx
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name _;
    return 301 https://$host$request_uri;
}

# HTTPS server with reverse proxy
server {
    listen 443 ssl;
    server_name _;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://vm-app:5001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Complete cloud-init for proxy** (`cloud-init/proxy.yaml`):
```yaml
#cloud-config
package_update: true
package_upgrade: true

packages:
  - nginx
  - openssl

write_files:
  - path: /etc/nginx/sites-available/flask-app
    content: |
      # HTTP to HTTPS redirect
      server {
          listen 80;
          server_name _;
          return 301 https://$host$request_uri;
      }

      # HTTPS server with reverse proxy
      server {
          listen 443 ssl;
          server_name _;

          ssl_certificate /etc/nginx/ssl/nginx.crt;
          ssl_certificate_key /etc/nginx/ssl/nginx.key;
          ssl_protocols TLSv1.2 TLSv1.3;
          ssl_ciphers HIGH:!aNULL:!MD5;

          location / {
              proxy_pass http://vm-app:5001;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
          }
      }

runcmd:
  # Generate self-signed SSL certificate
  - mkdir -p /etc/nginx/ssl
  - openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/CN=flask-app/O=Learning/C=SE"
  # Activate the site configuration
  - ln -sf /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled/flask-app
  - rm -f /etc/nginx/sites-enabled/default
  # Reload nginx to apply changes
  - systemctl reload nginx
```

**Verification:**
```bash
# Get proxy public IP
PROXY_IP=$(az vm show --resource-group rg-flask-bicep-dev --name vm-proxy --show-details --query publicIps --output tsv)

# Test HTTP redirect (should return 301 redirect to HTTPS)
curl -I http://$PROXY_IP
# Expected: HTTP/1.1 301 Moved Permanently
#           Location: https://$PROXY_IP/

# Test HTTPS (expect 502 Bad Gateway until app server is ready)
curl -k https://$PROXY_IP

# SSH via bastion to proxy
ssh -J azureuser@$BASTION_IP azureuser@vm-proxy

# On proxy, verify nginx is running
sudo systemctl status nginx
sudo nginx -t
```

**Success Criteria:**
- [ ] Proxy VM created and running
- [ ] Public IP assigned
- [ ] nginx installed and running
- [ ] Self-signed SSL certificate generated
- [ ] HTTP requests redirect to HTTPS (301)
- [ ] SSH accessible via bastion (jump host)

---

### Phase 4: Database

**Objective:** Deploy PostgreSQL Flexible Server with private connectivity.

**Bicep Resources:**
- PostgreSQL Flexible Server (psql-flask-bicep-dev)
- PostgreSQL Database (`flask`) - created within the server
- Private DNS Zone (`postgres.database.azure.com`) - for VNet DNS resolution
- Virtual Network Link (links DNS zone to vnet-flask-bicep-dev)

**Note:** Azure PostgreSQL Flexible Server uses **VNet Integration** (delegated subnet) rather than Private Endpoints. The server is deployed directly into `snet-data` with a delegated subnet. This is simpler and more cost-effective than Private Link for single-server scenarios.

**DNS Resolution:** When using VNet Integration, Azure automatically creates a Private DNS Zone for the PostgreSQL server. We create our own Private DNS Zone (`postgres.database.azure.com`) linked to our VNet to ensure internal resolution works correctly.

**Configuration:**
- Tier: Burstable B1ms
- Storage: 32 GiB
- PostgreSQL version: 16
- Database name: `flask` (created by Bicep)
- VNet Integration: Server deployed into snet-data (delegated subnet)
- No public access
- Administrator credentials (passed as parameters)

**Verification:**
```bash
# Verify PostgreSQL server exists
az postgres flexible-server show --resource-group rg-flask-bicep-dev --name psql-flask-bicep-dev --output table

# Verify database 'flask' was created
az postgres flexible-server db show --resource-group rg-flask-bicep-dev --server-name psql-flask-bicep-dev --database-name flask --output table

# Verify VNet integration (delegated subnet)
az postgres flexible-server show --resource-group rg-flask-bicep-dev --name psql-flask-bicep-dev --query network --output json

# SSH to app server (Phase 5) and test connection
# psql "host=psql-flask-bicep-dev.postgres.database.azure.com dbname=flask user=adminuser password=xxx sslmode=require"
```

**Success Criteria:**
- [ ] PostgreSQL Flexible Server created (B1ms tier)
- [ ] Database `flask` created within the server
- [ ] VNet integration configured (snet-data delegated)
- [ ] Private DNS zone configured and linked to VNet
- [ ] No public access enabled

---

### Phase 5: Application Server (VM Setup)

**Objective:** Deploy the application server VM and prepare the environment for the Flask application.

**Bicep Resources:**
- Network Interface (nic-app)
- Virtual Machine (vm-app)

**Cloud-init Configuration:**
- Python 3.12 and pip
- Create `flask-app` system user and group (for running the service)
- Add `azureuser` to `flask-app` group (allows deployment via scp)
- Create application directory (`/opt/flask-app/`) owned by `azureuser:flask-app` with mode 775
  - This allows `azureuser` to deploy via scp and `flask-app` to run the app
- Create virtual environment (`/opt/flask-app/venv/`)
- Install base Python packages (pip, wheel, setuptools)
- postgresql-client for CLI verification
- Create `/etc/flask-app/` directory for configuration (mode 750, owned by root:flask-app)
- Create systemd service file (disabled until app is deployed)

**Directory permissions strategy:**
```
/opt/flask-app/           owner: azureuser, group: flask-app, mode: 775
├── app.py                (deployed by scp as azureuser)
├── requirements.txt
├── wsgi.py
└── venv/                 owner: azureuser, group: flask-app, mode: 775

/etc/flask-app/           owner: root, group: flask-app, mode: 750
└── database.env          owner: root, group: flask-app, mode: 640
```

**Complete cloud-init for app server** (`cloud-init/app-server.yaml`):
```yaml
#cloud-config
package_update: true
package_upgrade: true

packages:
  - python3
  - python3-pip
  - python3-venv
  - postgresql-client

# Create flask-app system user
users:
  - name: flask-app
    system: true
    shell: /usr/sbin/nologin
    no_create_home: true

write_files:
  - path: /etc/systemd/system/flask-app.service
    content: |
      [Unit]
      Description=Flask Application
      After=network.target

      [Service]
      Type=simple
      User=flask-app
      Group=flask-app
      WorkingDirectory=/opt/flask-app
      EnvironmentFile=/etc/flask-app/database.env
      ExecStart=/opt/flask-app/venv/bin/gunicorn --bind 0.0.0.0:5001 wsgi:app
      Restart=always
      RestartSec=5

      [Install]
      WantedBy=multi-user.target

runcmd:
  # Create application directory structure
  - mkdir -p /opt/flask-app
  - mkdir -p /etc/flask-app

  # Create virtual environment
  - python3 -m venv /opt/flask-app/venv

  # Install base packages in venv
  - /opt/flask-app/venv/bin/pip install --upgrade pip wheel setuptools

  # Set ownership: azureuser owns for deployment, flask-app group for running
  - chown -R azureuser:flask-app /opt/flask-app
  - chmod 775 /opt/flask-app
  - chmod 775 /opt/flask-app/venv

  # Add azureuser to flask-app group (allows scp deployment)
  - usermod -aG flask-app azureuser

  # Set config directory permissions
  - chown root:flask-app /etc/flask-app
  - chmod 750 /etc/flask-app

  # Create placeholder for database.env (deploy.sh will populate it)
  - touch /etc/flask-app/database.env
  - chown root:flask-app /etc/flask-app/database.env
  - chmod 640 /etc/flask-app/database.env

  # Reload systemd to recognize new service (but don't start yet)
  - systemctl daemon-reload
```

**Note:** Cloud-init does **NOT** deploy the application code. It only prepares the environment. The systemd service is created but not enabled/started until `deploy.sh` runs.

**Verification:**
```bash
# SSH via bastion to app server
ssh -J azureuser@$BASTION_IP azureuser@vm-app

# Verify Python environment is ready
/opt/flask-app/venv/bin/python --version

# Verify application directory exists
ls -la /opt/flask-app/

# Verify systemd service file exists (but not running yet)
cat /etc/systemd/system/flask-app.service

# Verify postgresql-client is installed
psql --version

# Verify flask-app user exists
id flask-app

# Verify azureuser is in flask-app group (for deployment permissions)
groups azureuser | grep flask-app
```

**Success Criteria:**
- [ ] App VM created and running
- [ ] Python 3.12 installed
- [ ] Virtual environment created at `/opt/flask-app/venv/`
- [ ] Application directory `/opt/flask-app/` exists with correct permissions (775, azureuser:flask-app)
- [ ] systemd service file created (but service not yet active)
- [ ] postgresql-client installed
- [ ] `flask-app` system user created
- [ ] `azureuser` is member of `flask-app` group

---

### Phase 6: Flask Application Development

**Objective:** Create the minimal Flask application with database connectivity.

**Files to create:**

```
application/
├── app.py              # Flask application with routes and models
├── requirements.txt    # Python dependencies
└── wsgi.py             # Gunicorn entry point
```

**Application features:**
- SQLAlchemy model for `Entry` (id, value, created_at)
- `db.create_all()` called on startup to create tables if they don't exist
- Routes: GET `/` (form), POST `/` (create entry), GET `/entries` (list), GET `/health`
- **Dual database support:** Uses PostgreSQL if `DATABASE_URL` is set, otherwise falls back to SQLite for local development

**Complete `application/app.py`:**
```python
import os
from flask import Flask, request, render_template_string, jsonify, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

app = Flask(__name__)

# Use PostgreSQL if DATABASE_URL is set, otherwise SQLite for local development
database_url = os.environ.get('DATABASE_URL')
if database_url:
    app.config['SQLALCHEMY_DATABASE_URI'] = database_url
else:
    # SQLite fallback for local development (no PostgreSQL required)
    basedir = os.path.abspath(os.path.dirname(__file__))
    app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{os.path.join(basedir, "local.db")}'

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)


class Entry(db.Model):
    __tablename__ = 'entries'  # Explicit table name
    id = db.Column(db.Integer, primary_key=True)
    value = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


# Create tables on startup
with app.app_context():
    db.create_all()


# HTML Templates
INDEX_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>Flask App</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
        form { margin: 20px 0; }
        input[type="text"] { padding: 10px; width: 300px; }
        button { padding: 10px 20px; background: #007bff; color: white; border: none; cursor: pointer; }
        button:hover { background: #0056b3; }
        .entries { margin-top: 30px; }
        .entry { padding: 10px; border-bottom: 1px solid #eee; }
        .meta { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <h1>Flask Demo Application</h1>
    <p>Running on: {{ db_type }}</p>

    <form method="POST" action="/">
        <input type="text" name="value" placeholder="Enter a value..." required>
        <button type="submit">Add Entry</button>
    </form>

    <div class="entries">
        <h2>Recent Entries ({{ count }} total)</h2>
        {% for entry in entries %}
        <div class="entry">
            <strong>{{ entry.value }}</strong>
            <div class="meta">ID: {{ entry.id }} | Created: {{ entry.created_at.strftime('%Y-%m-%d %H:%M:%S') }}</div>
        </div>
        {% else %}
        <p>No entries yet. Add one above!</p>
        {% endfor %}
    </div>

    <p><a href="/entries">View all entries as JSON</a> | <a href="/health">Health check</a></p>
</body>
</html>
'''


@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        value = request.form.get('value')
        if value:
            entry = Entry(value=value)
            db.session.add(entry)
            db.session.commit()
        return redirect(url_for('index'))

    entries = Entry.query.order_by(Entry.created_at.desc()).limit(10).all()
    count = Entry.query.count()
    db_type = 'PostgreSQL' if os.environ.get('DATABASE_URL') else 'SQLite (local)'
    return render_template_string(INDEX_TEMPLATE, entries=entries, count=count, db_type=db_type)


@app.route('/entries')
def list_entries():
    entries = Entry.query.order_by(Entry.created_at.desc()).all()
    return jsonify([{
        'id': e.id,
        'value': e.value,
        'created_at': e.created_at.isoformat()
    } for e in entries])


@app.route('/health')
def health():
    """Health check endpoint - returns JSON with status 'ok'"""
    return jsonify({"status": "ok"})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
```

**`application/wsgi.py`:**
```python
from app import app

if __name__ == '__main__':
    app.run()
```

**`application/requirements.txt`:**
```
flask>=3.0.0
flask-sqlalchemy>=3.1.0
gunicorn>=21.0.0
psycopg2-binary>=2.9.9
```

**Database configuration:**

| Environment | DATABASE_URL | Database Used |
|-------------|--------------|---------------|
| Local development | Not set | SQLite (`local.db`) |
| Azure deployment | Set via `/etc/flask-app/database.env` | PostgreSQL |

**Verification (local development with SQLite):**
```bash
cd application
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py

# In another terminal
curl http://localhost:5001/
curl -X POST http://localhost:5001/ -d "value=test"
curl http://localhost:5001/entries
curl http://localhost:5001/health

# SQLite database file created at application/local.db
```

**Success Criteria:**
- [ ] `app.py` created with Flask app, SQLAlchemy model, and routes
- [ ] `requirements.txt` created with all dependencies
- [ ] `wsgi.py` created for Gunicorn
- [ ] Application runs locally with SQLite (no external dependencies)
- [ ] Application uses PostgreSQL when `DATABASE_URL` is set

---

### Phase 7: Application Deployment (via Bash Script)

**Objective:** Deploy the Flask application code to the app server using a deployment script that connects via SSH jump through the bastion host.

**Deployment Script:** `deploy/deploy.sh`

**What the script does:**
1. Retrieve bastion and app server IPs from Azure
2. Copy application files to app server via `scp -J` (SSH jump)
3. Install Python dependencies in the virtual environment
4. Create database configuration file with connection string
5. Enable and start the systemd service
6. Verify the application is running

**Note:** The database schema (tables) is created automatically by the Flask application using SQLAlchemy's `create_all()` when the application first connects to an empty database. No separate migration tool is used.

**Files copied:**
```
application/
├── app.py              → /opt/flask-app/app.py
├── requirements.txt    → /opt/flask-app/requirements.txt
└── wsgi.py             → /opt/flask-app/wsgi.py
```

**Deployment command:**
```bash
# From the reference/flask-bicep directory
./deploy/deploy.sh
```

**Complete `deploy/deploy.sh`:**
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

RG="rg-flask-bicep-dev"
PARAMS_FILE="$PROJECT_DIR/infrastructure/parameters.json"
APP_DIR="$PROJECT_DIR/application"

# Common SSH options to avoid interactive prompts
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

echo "Starting application deployment..."

# 1. Validate parameters.json exists
if [ ! -f "$PARAMS_FILE" ]; then
    echo "ERROR: $PARAMS_FILE not found. Run ./scripts/init-secrets.sh first."
    exit 1
fi

# 2. Validate password
"$PROJECT_DIR/scripts/validate-password.sh"

# 3. Get bastion public IP
echo "Getting bastion IP..."
BASTION_IP=$(az vm show -g $RG -n vm-bastion --show-details -o tsv --query publicIps)
if [ -z "$BASTION_IP" ]; then
    echo "ERROR: Could not get bastion public IP. Is the infrastructure deployed?"
    exit 1
fi

# 4. Extract credentials from parameters.json (using jq)
DB_USER=$(jq -r '.parameters.dbAdminUsername.value' "$PARAMS_FILE")
DB_PASS=$(jq -r '.parameters.dbAdminPassword.value' "$PARAMS_FILE")

# 5. Build connection string
DB_HOST="psql-flask-bicep-dev.postgres.database.azure.com"
DATABASE_URL="postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:5432/flask?sslmode=require"

# 6. Copy application files via SSH jump (using internal hostname)
echo "Copying application files..."
scp $SSH_OPTS -J azureuser@$BASTION_IP \
    "$APP_DIR/app.py" \
    "$APP_DIR/wsgi.py" \
    "$APP_DIR/requirements.txt" \
    azureuser@vm-app:/opt/flask-app/

# 7. Install dependencies (via SSH)
echo "Installing Python dependencies..."
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app \
  "/opt/flask-app/venv/bin/pip install -q -r /opt/flask-app/requirements.txt"

# 8. Create database config (with proper permissions)
echo "Configuring database connection..."
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app \
  "echo 'DATABASE_URL=$DATABASE_URL' | sudo tee /etc/flask-app/database.env > /dev/null && \
   sudo chmod 640 /etc/flask-app/database.env && \
   sudo chown root:flask-app /etc/flask-app/database.env"

# 9. Enable and start the service (SQLAlchemy creates tables on first connection)
echo "Starting Flask service..."
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app \
  "sudo systemctl enable flask-app && sudo systemctl restart flask-app"

echo "Application deployed successfully."
```

**Verification:**
```bash
# SSH via bastion to app server
ssh -J azureuser@$BASTION_IP azureuser@vm-app

# Verify Flask service is running
sudo systemctl status flask-app

# Test application locally
curl http://localhost:5001/

# Verify database connection
source /etc/flask-app/database.env
psql "$DATABASE_URL" -c "SELECT 1;"

# Check application logs
sudo journalctl -u flask-app -f
```

**Success Criteria:**
- [ ] Application files copied to `/opt/flask-app/`
- [ ] Python dependencies installed in virtual environment
- [ ] Database configuration file created with correct permissions
- [ ] systemd service enabled and running
- [ ] Application responding on port 5001
- [ ] Database tables created automatically on first request (via SQLAlchemy `create_all()`)

---

### Phase 8: End-to-End Verification

**Objective:** Verify the complete solution works end-to-end.

**Tests:**

1. **Web Access Test**
   ```bash
   # Access application via browser
   curl -k https://$PROXY_IP/

   # Submit form data
   curl -k -X POST https://$PROXY_IP/ -d "value=test-entry"

   # Verify entry was created
   curl -k https://$PROXY_IP/entries
   ```

2. **Database Verification via CLI**
   ```bash
   # SSH to app server
   ssh -J azureuser@$BASTION_IP azureuser@vm-app

   # Connect to database
   source /etc/flask-app/database.env
   psql "$DATABASE_URL"

   # Query entries
   SELECT * FROM entries;
   ```

3. **Security Verification**
   ```bash
   # Verify app server has no public IP
   az vm show --resource-group rg-flask-bicep-dev --name vm-app --show-details --query publicIps --output tsv
   # Should return empty

   # Verify database has no public access
   az postgres flexible-server show --resource-group rg-flask-bicep-dev --name psql-flask-bicep-dev --query network.publicNetworkAccess --output tsv
   # Should return "Disabled"
   ```

**Success Criteria:**
- [ ] Application accessible via HTTPS through proxy
- [ ] Form submission creates database entry
- [ ] Entries visible on /entries page
- [ ] Database entries verifiable via psql CLI
- [ ] No public IPs on app server or database

---

## File Structure

**`.gitignore` contents:**
```
# Secrets (NEVER commit)
infrastructure/parameters.json

# Local development database
application/local.db
*.db

# Python
__pycache__/
*.pyc
.venv/
venv/

# IDE
.vscode/
.idea/

# OS
.DS_Store
```

```
reference/flask-bicep/
├── IMPLEMENTATION-PLAN.md          # This document
├── README.md                       # Quick-start guide
├── .gitignore                      # Ignores parameters.json, local.db
│
├── deploy-all.sh                   # ONE-CLICK SOLUTION: runs everything
│
├── scripts/
│   ├── init-secrets.sh             # Initialize parameters.json with generated password
│   ├── validate-password.sh        # Validate password meets Azure requirements
│   ├── wait-for-postgres.sh        # Poll until PostgreSQL is ready
│   ├── wait-for-cloud-init.sh      # Wait for all VMs to complete cloud-init
│   ├── wait-for-app.sh             # Verify application is responding
│   └── verification-tests.sh       # Run full test suite, generate report
│
├── infrastructure/
│   ├── main.bicep                  # Orchestration template
│   ├── parameters.example.json     # Template (committed, no secrets)
│   ├── parameters.json             # Actual parameters (gitignored, has secrets)
│   └── modules/
│       ├── network.bicep           # vNet, subnets, NSGs, ASGs
│       ├── bastion.bicep           # Bastion VM
│       ├── proxy.bicep             # Reverse proxy VM
│       ├── app.bicep               # Application server VM
│       └── database.bicep          # PostgreSQL + VNet Integration + database
│
├── cloud-init/
│   ├── bastion.yaml                # Bastion: SSH hardening, fail2ban
│   ├── proxy.yaml                  # Proxy: nginx, SSL certificates, HTTP→HTTPS redirect
│   └── app-server.yaml             # App: Python env, systemd service (no app code)
│
├── deploy/
│   └── deploy.sh                   # Application deployment script (SSH jump)
│
├── application/
│   ├── app.py                      # Flask application
│   ├── requirements.txt            # Python dependencies
│   └── wsgi.py                     # Gunicorn entry point
│
└── [Generated during execution]
    ├── execution-state.json        # JSON task tracker (created first, updated throughout)
    ├── execution-log.md            # Human-readable execution narrative
    ├── test-report.md              # Final PASS/PARTIAL/FAIL report
    ├── errors/                     # Error artifacts (if any)
    └── diagnostics/                # Captured diagnostic logs
```

### Separation of Concerns

| File/Directory | Purpose | When Executed |
|----------------|---------|---------------|
| `deploy-all.sh` | **One-click deployment orchestrator** | Single command to deploy everything |
| `scripts/` | Secret initialization, validation | Called by deploy-all.sh or manually |
| `infrastructure/` | Azure resources (Bicep) | Called by deploy-all.sh |
| `cloud-init/` | VM environment setup | Automatically on first boot |
| `deploy/` | Application code deployment | Called by deploy-all.sh |
| `application/` | Flask source code | Copied by deploy/deploy.sh |

---

## Complete Bicep Templates

This section contains all the Bicep templates required for infrastructure deployment. These must be created before running `deploy-all.sh`.

### Main Orchestration Template

**`infrastructure/main.bicep`** - The entry point that orchestrates all modules:

```bicep
// Main orchestration template for Flask application infrastructure
// Deploys: Network, Bastion, Proxy, App Server, and PostgreSQL Database

@description('Location for all resources')
param location string = resourceGroup().location

@description('Environment name (used in resource naming)')
param environment string = 'dev'

@description('Project name (used in resource naming)')
param project string = 'flask-bicep'

@description('SSH public key for VM access')
@secure()
param sshPublicKey string

@description('PostgreSQL administrator username')
param dbAdminUsername string = 'adminuser'

@description('PostgreSQL administrator password')
@secure()
param dbAdminPassword string

// Naming convention variables
var baseName = '${project}-${environment}'
var vnetName = 'vnet-${baseName}'
var bastionVmName = 'vm-bastion'
var proxyVmName = 'vm-proxy'
var appVmName = 'vm-app'
var postgresServerName = 'psql-${baseName}'

// Deploy network infrastructure
module network 'modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    vnetName: vnetName
    baseName: baseName
  }
}

// Deploy bastion host
module bastion 'modules/bastion.bicep' = {
  name: 'bastionDeployment'
  params: {
    location: location
    vmName: bastionVmName
    subnetId: network.outputs.bastionSubnetId
    asgId: network.outputs.bastionAsgId
    sshPublicKey: sshPublicKey
    baseName: baseName
  }
}

// Deploy reverse proxy
module proxy 'modules/proxy.bicep' = {
  name: 'proxyDeployment'
  params: {
    location: location
    vmName: proxyVmName
    subnetId: network.outputs.webSubnetId
    asgId: network.outputs.proxyAsgId
    sshPublicKey: sshPublicKey
    baseName: baseName
  }
}

// Deploy application server
module app 'modules/app.bicep' = {
  name: 'appDeployment'
  params: {
    location: location
    vmName: appVmName
    subnetId: network.outputs.appSubnetId
    asgId: network.outputs.appAsgId
    sshPublicKey: sshPublicKey
    baseName: baseName
  }
}

// Deploy PostgreSQL database
module database 'modules/database.bicep' = {
  name: 'databaseDeployment'
  params: {
    location: location
    serverName: postgresServerName
    subnetId: network.outputs.dataSubnetId
    vnetId: network.outputs.vnetId
    adminUsername: dbAdminUsername
    adminPassword: dbAdminPassword
    baseName: baseName
  }
}

// Outputs
output bastionPublicIp string = bastion.outputs.publicIpAddress
output proxyPublicIp string = proxy.outputs.publicIpAddress
output postgresServerFqdn string = database.outputs.serverFqdn
output postgresDatabaseName string = database.outputs.databaseName
```

### Network Module

**`infrastructure/modules/network.bicep`** - Virtual network, subnets, NSGs, and ASGs:

```bicep
// Network infrastructure: VNet, Subnets, NSGs, ASGs

@description('Location for all resources')
param location string

@description('Virtual network name')
param vnetName string

@description('Base name for resources')
param baseName string

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-bastion'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsgBastion.id
          }
        }
      }
      {
        name: 'snet-web'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: nsgWeb.id
          }
        }
      }
      {
        name: 'snet-app'
        properties: {
          addressPrefix: '10.0.3.0/24'
          networkSecurityGroup: {
            id: nsgApp.id
          }
        }
      }
      {
        name: 'snet-data'
        properties: {
          addressPrefix: '10.0.4.0/24'
          networkSecurityGroup: {
            id: nsgData.id
          }
          delegations: [
            {
              name: 'Microsoft.DBforPostgreSQL.flexibleServers'
              properties: {
                serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
              }
            }
          ]
        }
      }
    ]
  }
}

// Application Security Groups
resource asgBastion 'Microsoft.Network/applicationSecurityGroups@2023-05-01' = {
  name: 'asg-bastion'
  location: location
}

resource asgProxy 'Microsoft.Network/applicationSecurityGroups@2023-05-01' = {
  name: 'asg-proxy'
  location: location
}

resource asgApp 'Microsoft.Network/applicationSecurityGroups@2023-05-01' = {
  name: 'asg-app'
  location: location
}

// Network Security Group - Bastion
resource nsgBastion 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-bastion'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSHInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asgBastion.id
            }
          ]
          destinationPortRange: '22'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// Network Security Group - Web
resource nsgWeb 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-web'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHTTPInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asgProxy.id
            }
          ]
          destinationPortRange: '80'
        }
      }
      {
        name: 'AllowHTTPSInbound'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asgProxy.id
            }
          ]
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowSSHFromBastion'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceApplicationSecurityGroups: [
            {
              id: asgBastion.id
            }
          ]
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asgProxy.id
            }
          ]
          destinationPortRange: '22'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// Network Security Group - App
resource nsgApp 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-app'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowFlaskFromProxy'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceApplicationSecurityGroups: [
            {
              id: asgProxy.id
            }
          ]
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asgApp.id
            }
          ]
          destinationPortRange: '5001'
        }
      }
      {
        name: 'AllowSSHFromBastion'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceApplicationSecurityGroups: [
            {
              id: asgBastion.id
            }
          ]
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asgApp.id
            }
          ]
          destinationPortRange: '22'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// Network Security Group - Data
resource nsgData 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-data'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowPostgreSQLFromApp'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '10.0.3.0/24'  // App subnet CIDR (ASGs don't work with PaaS)
          sourcePortRange: '*'
          destinationAddressPrefix: '10.0.4.0/24'
          destinationPortRange: '5432'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// Outputs
output vnetId string = vnet.id
output bastionSubnetId string = vnet.properties.subnets[0].id
output webSubnetId string = vnet.properties.subnets[1].id
output appSubnetId string = vnet.properties.subnets[2].id
output dataSubnetId string = vnet.properties.subnets[3].id
output bastionAsgId string = asgBastion.id
output proxyAsgId string = asgProxy.id
output appAsgId string = asgApp.id
```

### Bastion Module

**`infrastructure/modules/bastion.bicep`** - Bastion host with public IP:

```bicep
// Bastion host VM with public IP for SSH access

@description('Location for all resources')
param location string

@description('VM name')
param vmName string

@description('Subnet resource ID')
param subnetId string

@description('Application Security Group resource ID')
param asgId string

@description('SSH public key')
@secure()
param sshPublicKey string

@description('Base name for resources')
param baseName string

// Cloud-init configuration for bastion
var cloudInitBastion = '''
#cloud-config
package_update: true
package_upgrade: true

packages:
  - fail2ban
  - ufw

write_files:
  - path: /etc/fail2ban/jail.local
    content: |
      [sshd]
      enabled = true
      port = ssh
      filter = sshd
      logpath = /var/log/auth.log
      maxretry = 3
      bantime = 3600
      findtime = 600

  - path: /etc/ssh/sshd_config.d/hardening.conf
    content: |
      PasswordAuthentication no
      PermitRootLogin no
      PubkeyAuthentication yes
      MaxAuthTries 3

runcmd:
  - systemctl enable fail2ban
  - systemctl start fail2ban
  - systemctl restart sshd
'''

// Public IP for bastion
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-bastion'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// Network interface
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-bastion'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: subnetId
          }
          applicationSecurityGroups: [
            {
              id: asgId
            }
          ]
        }
      }
    ]
  }
}

// Virtual machine
resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'azureuser'
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
      customData: base64(cloudInitBastion)
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// Outputs
output publicIpAddress string = publicIp.properties.ipAddress
output vmId string = vm.id
```

### Proxy Module

**`infrastructure/modules/proxy.bicep`** - Reverse proxy with nginx:

```bicep
// Reverse proxy VM with nginx and SSL

@description('Location for all resources')
param location string

@description('VM name')
param vmName string

@description('Subnet resource ID')
param subnetId string

@description('Application Security Group resource ID')
param asgId string

@description('SSH public key')
@secure()
param sshPublicKey string

@description('Base name for resources')
param baseName string

// Cloud-init configuration for proxy
var cloudInitProxy = '''
#cloud-config
package_update: true
package_upgrade: true

packages:
  - nginx
  - openssl

write_files:
  - path: /etc/nginx/sites-available/flask-app
    content: |
      # HTTP to HTTPS redirect
      server {
          listen 80;
          server_name _;
          return 301 https://$host$request_uri;
      }

      # HTTPS server with reverse proxy
      server {
          listen 443 ssl;
          server_name _;

          ssl_certificate /etc/nginx/ssl/nginx.crt;
          ssl_certificate_key /etc/nginx/ssl/nginx.key;
          ssl_protocols TLSv1.2 TLSv1.3;
          ssl_ciphers HIGH:!aNULL:!MD5;

          location / {
              proxy_pass http://vm-app:5001;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
          }
      }

runcmd:
  - mkdir -p /etc/nginx/ssl
  - openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/CN=flask-app/O=Learning/C=SE"
  - ln -sf /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled/flask-app
  - rm -f /etc/nginx/sites-enabled/default
  - systemctl reload nginx
'''

// Public IP for proxy
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-proxy'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// Network interface
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-proxy'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: subnetId
          }
          applicationSecurityGroups: [
            {
              id: asgId
            }
          ]
        }
      }
    ]
  }
}

// Virtual machine
resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'azureuser'
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
      customData: base64(cloudInitProxy)
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// Outputs
output publicIpAddress string = publicIp.properties.ipAddress
output vmId string = vm.id
```

### App Server Module

**`infrastructure/modules/app.bicep`** - Application server with Python:

```bicep
// Application server VM with Python environment

@description('Location for all resources')
param location string

@description('VM name')
param vmName string

@description('Subnet resource ID')
param subnetId string

@description('Application Security Group resource ID')
param asgId string

@description('SSH public key')
@secure()
param sshPublicKey string

@description('Base name for resources')
param baseName string

// Cloud-init configuration for app server
var cloudInitApp = '''
#cloud-config
package_update: true
package_upgrade: true

packages:
  - python3
  - python3-pip
  - python3-venv
  - postgresql-client

users:
  - name: flask-app
    system: true
    shell: /usr/sbin/nologin
    no_create_home: true

write_files:
  - path: /etc/systemd/system/flask-app.service
    content: |
      [Unit]
      Description=Flask Application
      After=network.target

      [Service]
      Type=simple
      User=flask-app
      Group=flask-app
      WorkingDirectory=/opt/flask-app
      EnvironmentFile=/etc/flask-app/database.env
      ExecStart=/opt/flask-app/venv/bin/gunicorn --bind 0.0.0.0:5001 wsgi:app
      Restart=always
      RestartSec=5

      [Install]
      WantedBy=multi-user.target

runcmd:
  - mkdir -p /opt/flask-app
  - mkdir -p /etc/flask-app
  - python3 -m venv /opt/flask-app/venv
  - /opt/flask-app/venv/bin/pip install --upgrade pip wheel setuptools
  - chown -R azureuser:flask-app /opt/flask-app
  - chmod 775 /opt/flask-app
  - chmod 775 /opt/flask-app/venv
  - usermod -aG flask-app azureuser
  - chown root:flask-app /etc/flask-app
  - chmod 750 /etc/flask-app
  - touch /etc/flask-app/database.env
  - chown root:flask-app /etc/flask-app/database.env
  - chmod 640 /etc/flask-app/database.env
  - systemctl daemon-reload
'''

// Network interface (no public IP - internal only)
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-app'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          applicationSecurityGroups: [
            {
              id: asgId
            }
          ]
        }
      }
    ]
  }
}

// Virtual machine
resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'azureuser'
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
      customData: base64(cloudInitApp)
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// Outputs
output vmId string = vm.id
output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
```

### Database Module

**`infrastructure/modules/database.bicep`** - PostgreSQL Flexible Server with VNet integration:

```bicep
// PostgreSQL Flexible Server with VNet Integration

@description('Location for all resources')
param location string

@description('PostgreSQL server name')
param serverName string

@description('Subnet resource ID (must be delegated to PostgreSQL)')
param subnetId string

@description('Virtual network resource ID')
param vnetId string

@description('Administrator username')
param adminUsername string

@description('Administrator password')
@secure()
param adminPassword string

@description('Base name for resources')
param baseName string

// Private DNS Zone for PostgreSQL
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: '${serverName}.private.postgres.database.azure.com'
  location: 'global'
}

// Link DNS zone to VNet
resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'vnet-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// PostgreSQL Flexible Server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: serverName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    version: '16'
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    network: {
      delegatedSubnetResourceId: subnetId
      privateDnsZoneArmResourceId: privateDnsZone.id
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
  dependsOn: [
    privateDnsZoneLink
  ]
}

// Create the flask database
resource flaskDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
  parent: postgresServer
  name: 'flask'
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

// Outputs
output serverFqdn string = postgresServer.properties.fullyQualifiedDomainName
output serverId string = postgresServer.id
output databaseName string = flaskDatabase.name
```

### Bicep Templates Summary

| File | Lines | Purpose |
|------|-------|---------|
| `infrastructure/main.bicep` | ~95 | Orchestration, parameters, module calls |
| `infrastructure/modules/network.bicep` | ~280 | VNet, 4 subnets, 4 NSGs, 3 ASGs |
| `infrastructure/modules/bastion.bicep` | ~115 | Bastion VM, public IP, cloud-init |
| `infrastructure/modules/proxy.bicep` | ~130 | Proxy VM, public IP, nginx cloud-init |
| `infrastructure/modules/app.bicep` | ~115 | App VM, Python environment cloud-init |
| `infrastructure/modules/database.bicep` | ~85 | PostgreSQL, Private DNS Zone, flask database |

**Total:** ~820 lines of Bicep code

---

## SSH Configuration

### SSH Key Strategy

All VMs use the **user's default SSH key** from `~/.ssh/id_rsa.pub`. This simplifies key management for a learning environment.

**Key location:**
```
~/.ssh/id_rsa      # Private key (stays on local machine)
~/.ssh/id_rsa.pub  # Public key (deployed to all VMs)
```

**How the key is deployed:**
- Bicep reads the public key from local filesystem
- Key is passed to each VM during provisioning
- All three VMs (bastion, proxy, app) receive the same public key

**Bicep parameter:**
```bicep
@secure()
param sshPublicKey string
```

**Note:** The SSH public key cannot be loaded directly in Bicep from the user's filesystem. Instead, `deploy-all.sh` reads `~/.ssh/id_rsa.pub` and passes it as a parameter:
```bash
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
az deployment group create ... --parameters sshPublicKey="$SSH_KEY"
```

### SSH Access Patterns

| From | To | Command |
|------|----|---------|
| Local | Bastion | `ssh azureuser@<bastion-pip>` |
| Local | Proxy | `ssh -J azureuser@<bastion-pip> azureuser@vm-proxy` |
| Local | App | `ssh -J azureuser@<bastion-pip> azureuser@vm-app` |
| Bastion | Proxy | `ssh azureuser@vm-proxy` |
| Bastion | App | `ssh azureuser@vm-app` |

### SSH Config File (Optional)

For convenience, add to `~/.ssh/config`:

```
Host bastion-flask
    HostName <bastion-public-ip>
    User azureuser
    IdentityFile ~/.ssh/id_rsa

Host proxy-flask
    HostName vm-proxy
    User azureuser
    ProxyJump bastion-flask

Host app-flask
    HostName vm-app
    User azureuser
    ProxyJump bastion-flask
```

Then connect with: `ssh app-flask`

---

## Database Connection Strategy

### Connection String Format

```
postgresql://adminuser:password@psql-flask-bicep-dev.postgres.database.azure.com:5432/flask?sslmode=require
```

### Password Requirements

Azure PostgreSQL Flexible Server enforces the following password rules ([source](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-manage-server-portal)):

| Requirement | Rule |
|-------------|------|
| Length | 8-128 characters |
| Complexity | Must contain characters from **3 of 4** categories |
| | - Uppercase letters (A-Z) |
| | - Lowercase letters (a-z) |
| | - Numbers (0-9) |
| | - Special characters (!, $, #, %, etc.) |

### Secrets Management (Without Key Vault)

Since this learning project does not use Azure Key Vault, secrets are managed via a local parameters file:

```
infrastructure/
├── parameters.json          # Contains secrets - GITIGNORED
└── parameters.example.json  # Template without secrets - committed
```

**parameters.example.json structure:**
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "sshPublicKey": {
      "value": "PLACEHOLDER_SSH_KEY"
    },
    "dbAdminUsername": {
      "value": "adminuser"
    },
    "dbAdminPassword": {
      "value": "PLACEHOLDER_GENERATE_SECURE_PASSWORD"
    }
  }
}
```

**Complete `scripts/init-secrets.sh`:**
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PARAMS_EXAMPLE="$PROJECT_DIR/infrastructure/parameters.example.json"
PARAMS_FILE="$PROJECT_DIR/infrastructure/parameters.json"

# Parse arguments
PASSWORD=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --password)
            PASSWORD="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if parameters.json already exists
if [ -f "$PARAMS_FILE" ]; then
    echo "parameters.json already exists. Delete it first to reinitialize."
    exit 0
fi

# Copy template
echo "Creating parameters.json from template..."
cp "$PARAMS_EXAMPLE" "$PARAMS_FILE"

# Generate password if not provided
if [ -z "$PASSWORD" ]; then
    echo "Generating secure password..."
    # Generate 20-char password with required character classes
    # Uses: uppercase, lowercase, numbers, and special chars
    PASSWORD=$(openssl rand -base64 32 | tr -dc 'A-Za-z0-9!@#$%^&*' | head -c 20)
    # Ensure at least one of each required type
    PASSWORD="${PASSWORD:0:17}Aa1!"
fi

# Validate password meets Azure requirements
"$SCRIPT_DIR/validate-password.sh" "$PASSWORD"

# Update parameters.json with password (SSH key is passed separately at deploy time)
echo "Updating parameters.json..."
jq --arg pass "$PASSWORD" '.parameters.dbAdminPassword.value = $pass' "$PARAMS_FILE" > "$PARAMS_FILE.tmp"
mv "$PARAMS_FILE.tmp" "$PARAMS_FILE"

echo "Secrets initialized successfully."
echo "  Password: [hidden - stored in parameters.json]"
echo ""
echo "IMPORTANT: parameters.json contains secrets and should NOT be committed to git."
```

**Complete `scripts/validate-password.sh`:**
```bash
#!/bin/bash
# Validates password meets Azure PostgreSQL requirements
# Can be called with password as argument, or reads from parameters.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PARAMS_FILE="$PROJECT_DIR/infrastructure/parameters.json"

# Get password from argument or parameters.json
if [ -n "$1" ]; then
    PASSWORD="$1"
elif [ -f "$PARAMS_FILE" ]; then
    PASSWORD=$(jq -r '.parameters.dbAdminPassword.value' "$PARAMS_FILE")
else
    echo "ERROR: No password provided and parameters.json not found"
    exit 1
fi

# Check length (8-128 characters)
LENGTH=${#PASSWORD}
if [ $LENGTH -lt 8 ] || [ $LENGTH -gt 128 ]; then
    echo "ERROR: Password must be 8-128 characters (got $LENGTH)"
    exit 1
fi

# Count character categories present
CATEGORIES=0

# Check for uppercase
if [[ "$PASSWORD" =~ [A-Z] ]]; then
    CATEGORIES=$((CATEGORIES + 1))
fi

# Check for lowercase
if [[ "$PASSWORD" =~ [a-z] ]]; then
    CATEGORIES=$((CATEGORIES + 1))
fi

# Check for numbers
if [[ "$PASSWORD" =~ [0-9] ]]; then
    CATEGORIES=$((CATEGORIES + 1))
fi

# Check for special characters
if [[ "$PASSWORD" =~ [^A-Za-z0-9] ]]; then
    CATEGORIES=$((CATEGORIES + 1))
fi

# Must have at least 3 of 4 categories
if [ $CATEGORIES -lt 3 ]; then
    echo "ERROR: Password must contain characters from at least 3 of these categories:"
    echo "  - Uppercase letters (A-Z)"
    echo "  - Lowercase letters (a-z)"
    echo "  - Numbers (0-9)"
    echo "  - Special characters (!@#\$%^&* etc.)"
    echo "  Current password has only $CATEGORIES categories"
    exit 1
fi

echo "Password validation: OK"
exit 0
```

**Requires:** `jq` command-line JSON processor (installed via package manager)

```bash
# Initialize secrets before first deployment
./scripts/init-secrets.sh

# Or provide your own password
./scripts/init-secrets.sh --password "YourSecurePassword123!"
```

**Password validation** is also performed by:
- `scripts/init-secrets.sh` when generating/setting password
- `deploy/deploy.sh` before attempting deployment (fails fast with clear error)

### Environment File Location (on VM)

The connection string will be stored in a protected environment file:

```
/etc/flask-app/database.env
```

**File contents:**
```bash
DATABASE_URL=postgresql://adminuser:password@psql-flask-bicep-dev.postgres.database.azure.com:5432/flask?sslmode=require
```

**File permissions:**
```bash
# Owner: root, readable by flask-app service user
sudo chmod 640 /etc/flask-app/database.env
sudo chown root:flask-app /etc/flask-app/database.env
```

### systemd Service Reference

```ini
[Service]
User=flask-app
Group=flask-app
WorkingDirectory=/opt/flask-app
EnvironmentFile=/etc/flask-app/database.env
ExecStart=/opt/flask-app/venv/bin/gunicorn --bind 0.0.0.0:5001 wsgi:app
Restart=always
```

---

## Flask Application (Minimal)

### Functionality

| Route | Method | Description |
|-------|--------|-------------|
| `/` | GET | Display "Hello World" message and form |
| `/` | POST | Insert submitted value into database |
| `/entries` | GET | Display all entries from database |
| `/health` | GET | Health check endpoint |

### Database Schema

The schema is defined in the Flask application using SQLAlchemy models. Tables are created automatically when the application first connects to an empty database using `db.create_all()` (application-first approach, no migrations).

```sql
-- Equivalent SQL (created by SQLAlchemy)
-- Table name is explicitly set via __tablename__ = 'entries'
CREATE TABLE entries (
    id SERIAL PRIMARY KEY,
    value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Dependencies

```
flask>=3.0.0
flask-sqlalchemy>=3.1.0
gunicorn>=21.0.0
psycopg2-binary>=2.9.9
```

---

## Deployment Commands

### One-Click Deployment

The entire solution can be deployed with a single command:

```bash
./deploy-all.sh
```

**What `deploy-all.sh` does:**

```bash
#!/bin/bash
set -e

RG="rg-flask-bicep-dev"
LOCATION="swedencentral"

echo "=== Flask Bicep Deployment ==="

# Prerequisites check
echo "Checking prerequisites..."

# Check Azure CLI is installed and logged in
if ! command -v az &> /dev/null; then
    echo "ERROR: Azure CLI is not installed. Run: brew install azure-cli"
    exit 1
fi

if ! az account show &> /dev/null; then
    echo "ERROR: Not logged into Azure. Run: az login"
    exit 1
fi

# Check jq is installed (needed for JSON parsing)
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is not installed. Run: brew install jq"
    exit 1
fi

# Check SSH key exists
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "ERROR: SSH key not found at ~/.ssh/id_rsa.pub"
    echo "Generate one with: ssh-keygen -t rsa -b 4096"
    exit 1
fi

echo "Prerequisites OK."

# Step 0: Initialize secrets (if not already done)
if [ ! -f infrastructure/parameters.json ]; then
    echo "Initializing secrets..."
    ./scripts/init-secrets.sh
fi

# Validate password format
./scripts/validate-password.sh

# Step 1: Create resource group
echo "Creating resource group..."
az group create --name $RG --location $LOCATION --output none

# Step 2: Read SSH public key
echo "Reading SSH public key..."
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)

# Step 3: Deploy infrastructure (Bicep + cloud-init)
echo "Deploying infrastructure (this takes 10-15 minutes)..."
az deployment group create \
  --resource-group $RG \
  --template-file infrastructure/main.bicep \
  --parameters infrastructure/parameters.json \
  --parameters sshPublicKey="$SSH_KEY" \
  --output none

# Step 4: Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
./scripts/wait-for-postgres.sh

# Step 5: Wait for cloud-init to complete on all VMs
echo "Waiting for VMs to be configured..."
./scripts/wait-for-cloud-init.sh

# Step 6: Deploy application
echo "Deploying application..."
./deploy/deploy.sh

# Step 7: Verify application is healthy
echo "Verifying application health..."
./scripts/wait-for-app.sh

# Step 8: Show access information
PROXY_IP=$(az vm show -g $RG -n vm-proxy --show-details -o tsv --query publicIps)
echo ""
echo "=== Deployment Complete ==="
echo "Application URL: https://$PROXY_IP/"
echo "(Accept the self-signed certificate warning)"
```

### Timing and Wait Scripts

The deployment uses dedicated wait scripts to handle timing dependencies properly:

#### `scripts/wait-for-postgres.sh`
Polls PostgreSQL until state is "Ready" (with timeout):
```bash
#!/bin/bash
set -e
RG="rg-flask-bicep-dev"
SERVER_NAME="psql-flask-bicep-dev"
MAX_ATTEMPTS=40  # 40 * 30s = 20 minutes
ATTEMPT=0

echo "Waiting for PostgreSQL Flexible Server..."
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    STATE=$(az postgres flexible-server show \
        --resource-group $RG \
        --name $SERVER_NAME \
        --query state --output tsv 2>/dev/null || echo "NotFound")

    if [ "$STATE" = "Ready" ]; then
        echo "PostgreSQL is ready."
        exit 0
    fi

    ATTEMPT=$((ATTEMPT + 1))
    echo "  Attempt $ATTEMPT/$MAX_ATTEMPTS - Current state: $STATE (waiting...)"
    sleep 30
done

echo "ERROR: PostgreSQL did not become ready within 20 minutes"
exit 1
```

#### `scripts/wait-for-cloud-init.sh`
Waits for cloud-init to complete on all VMs via SSH:
```bash
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
```

#### `scripts/wait-for-app.sh`
Verifies the application is responding with healthy status:
```bash
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
```

### Timing Dependency Chain

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Deployment Timeline                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  az deployment group create (Bicep)                                     │
│  ├── Creates VNet, Subnets, NSGs, ASGs        (~1 min)                 │
│  ├── Creates VMs (bastion, proxy, app)        (~3 min)                 │
│  │   └── cloud-init starts automatically                               │
│  └── Creates PostgreSQL Flexible Server       (~10-15 min)             │
│                                                                         │
│  ════════════════════════════════════════════════════════════════════  │
│                                                                         │
│  wait-for-postgres.sh                                                   │
│  └── Polls until PostgreSQL state = "Ready"                            │
│                                                                         │
│  wait-for-cloud-init.sh                                                 │
│  ├── Bastion: SSH + cloud-init status --wait                           │
│  ├── Proxy: SSH jump + cloud-init status --wait                        │
│  └── App: SSH jump + cloud-init status --wait                          │
│                                                                         │
│  ════════════════════════════════════════════════════════════════════  │
│                                                                         │
│  deploy/deploy.sh                                                       │
│  ├── Copy application files via SCP                                    │
│  ├── Install dependencies                                               │
│  ├── Configure database connection string                               │
│  └── Start Flask service                                                │
│      └── SQLAlchemy creates tables on first request                    │
│                                                                         │
│  ════════════════════════════════════════════════════════════════════  │
│                                                                         │
│  wait-for-app.sh                                                        │
│  └── Polls /health endpoint until responding                           │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Manual Step-by-Step Deployment

If you prefer to run each step manually:

#### Step 0: Initialize Secrets (First Time Only)

```bash
# Generate parameters.json with a random secure password
./scripts/init-secrets.sh

# Or provide your own password
./scripts/init-secrets.sh --password "YourSecurePassword123!"
```

#### Step 1: Infrastructure Provisioning

```bash
# Create resource group
az group create --name rg-flask-bicep-dev --location swedencentral

# Deploy infrastructure
az deployment group create \
  --resource-group rg-flask-bicep-dev \
  --template-file infrastructure/main.bicep \
  --parameters infrastructure/parameters.json

# Wait for cloud-init to complete (2-5 minutes)
```

#### Step 2: Application Deployment

```bash
./deploy/deploy.sh
```

---

## Cleanup

```bash
# Delete all resources
az group delete --name rg-flask-bicep-dev --yes --no-wait
```

---

## Automated Execution Protocol

This section defines how to execute the implementation plan in a fully **unattended** manner with error handling, self-healing, and comprehensive reporting.

### First Step: Generate JSON Execution Plan

**IMPORTANT:** Before executing any deployment tasks, the first action must be to read through this entire implementation plan and generate a comprehensive `execution-state.json` file. This JSON file serves as the authoritative task tracker throughout the entire execution.

**Why JSON format:**
- **Precise state tracking** - Reliably read and update specific fields without parsing ambiguity
- **Rich metadata** - Track attempts, timestamps, errors, verification results in one place
- **Atomic updates** - Read whole file, update one field, write back - no structure corruption risk
- **Query-friendly** - Easy to check "how many tasks pending?" or "which tasks failed?"
- **Resume capability** - If execution is interrupted, read JSON and know exactly where to resume

**JSON Execution State Structure:**

```json
{
  "execution_id": "flask-bicep-YYYYMMDD-HHMMSS",
  "plan_version": "1.0",
  "started_at": null,
  "completed_at": null,
  "status": "not_started",
  "current_phase": null,
  "current_task": null,

  "environment": {
    "azure_subscription": null,
    "azure_region": "swedencentral",
    "resource_group": "rg-flask-bicep-dev",
    "user_principal": null
  },

  "phases": {
    "A": { "name": "Prerequisites & Setup", "status": "pending", "started_at": null, "completed_at": null },
    "B": { "name": "Infrastructure Deployment", "status": "pending", "started_at": null, "completed_at": null },
    "C": { "name": "Resource Readiness", "status": "pending", "started_at": null, "completed_at": null },
    "D": { "name": "Application Deployment", "status": "pending", "started_at": null, "completed_at": null },
    "E": { "name": "Verification & Testing", "status": "pending", "started_at": null, "completed_at": null },
    "F": { "name": "Report Generation", "status": "pending", "started_at": null, "completed_at": null }
  },

  "tasks": [
    {
      "id": "A1",
      "phase": "A",
      "name": "Verify Azure CLI installed",
      "description": "Check that Azure CLI is installed and accessible",
      "status": "pending",
      "required": true,
      "attempts": 0,
      "max_attempts": 1,
      "started_at": null,
      "completed_at": null,
      "duration_seconds": null,
      "command": "az --version",
      "verification": {
        "method": "exit_code",
        "expected": 0,
        "actual": null,
        "passed": null,
        "output_snippet": null
      },
      "errors": [],
      "resolution": null,
      "notes": ""
    },
    {
      "id": "A2",
      "phase": "A",
      "name": "Verify Azure CLI logged in",
      "description": "Check that user is authenticated to Azure",
      "status": "pending",
      "required": true,
      "attempts": 0,
      "max_attempts": 1,
      "command": "az account show",
      "verification": {
        "method": "exit_code_and_output",
        "expected": 0,
        "check_field": "user.name",
        "actual": null,
        "passed": null
      },
      "errors": [],
      "depends_on": ["A1"]
    },
    {
      "id": "A3",
      "phase": "A",
      "name": "Verify jq installed",
      "description": "Check that jq JSON processor is available",
      "status": "pending",
      "required": true,
      "command": "jq --version",
      "verification": { "method": "exit_code", "expected": 0 }
    },
    {
      "id": "A4",
      "phase": "A",
      "name": "Verify SSH key exists",
      "description": "Check that SSH public key exists at ~/.ssh/id_rsa.pub",
      "status": "pending",
      "required": true,
      "command": "test -f ~/.ssh/id_rsa.pub && echo 'EXISTS'",
      "verification": { "method": "output_contains", "expected": "EXISTS" }
    },
    {
      "id": "A5",
      "phase": "A",
      "name": "Initialize secrets",
      "description": "Create parameters.json with generated password if not exists",
      "status": "pending",
      "required": true,
      "command": "./scripts/init-secrets.sh",
      "verification": { "method": "file_exists", "path": "infrastructure/parameters.json" },
      "depends_on": ["A3"]
    },
    {
      "id": "A6",
      "phase": "A",
      "name": "Validate password",
      "description": "Verify password meets Azure requirements",
      "status": "pending",
      "required": true,
      "command": "./scripts/validate-password.sh",
      "verification": { "method": "exit_code", "expected": 0 },
      "depends_on": ["A5"]
    },

    {
      "id": "B1",
      "phase": "B",
      "name": "Create resource group",
      "description": "Create Azure resource group rg-flask-bicep-dev",
      "status": "pending",
      "required": true,
      "attempts": 0,
      "max_attempts": 3,
      "command": "az group create --name rg-flask-bicep-dev --location swedencentral",
      "verification": {
        "method": "az_resource_state",
        "resource_type": "group",
        "expected_state": "Succeeded"
      },
      "depends_on": ["A6"]
    },
    {
      "id": "B2",
      "phase": "B",
      "name": "Deploy Bicep templates",
      "description": "Deploy all infrastructure via main.bicep",
      "status": "pending",
      "required": true,
      "attempts": 0,
      "max_attempts": 3,
      "estimated_duration_minutes": 15,
      "command": "az deployment group create --resource-group rg-flask-bicep-dev --template-file infrastructure/main.bicep --parameters infrastructure/parameters.json --parameters sshPublicKey=\"$(cat ~/.ssh/id_rsa.pub)\"",
      "verification": {
        "method": "az_deployment_state",
        "expected_state": "Succeeded"
      },
      "depends_on": ["B1"],
      "on_error": {
        "diagnostic_commands": [
          "az deployment group show -g rg-flask-bicep-dev -n main --query properties.error"
        ],
        "common_fixes": [
          { "error_pattern": "already exists", "fix": "Delete conflicting resource or use different name" },
          { "error_pattern": "quota", "fix": "Request quota increase or use smaller VM size" },
          { "error_pattern": "delegation", "fix": "Remove existing subnet delegation" }
        ]
      }
    },

    {
      "id": "C1",
      "phase": "C",
      "name": "Wait for PostgreSQL ready",
      "description": "Poll until PostgreSQL Flexible Server state is Ready",
      "status": "pending",
      "required": true,
      "attempts": 0,
      "max_attempts": 40,
      "poll_interval_seconds": 30,
      "timeout_minutes": 20,
      "command": "./scripts/wait-for-postgres.sh",
      "verification": {
        "method": "az_postgres_state",
        "expected_state": "Ready"
      },
      "depends_on": ["B2"]
    },
    {
      "id": "C2",
      "phase": "C",
      "name": "Wait for bastion cloud-init",
      "description": "Wait for cloud-init to complete on bastion VM",
      "status": "pending",
      "required": true,
      "timeout_minutes": 10,
      "command": "ssh $SSH_OPTS azureuser@$BASTION_IP 'cloud-init status --wait'",
      "verification": { "method": "cloud_init_status", "expected": "done" },
      "depends_on": ["B2"]
    },
    {
      "id": "C3",
      "phase": "C",
      "name": "Wait for proxy cloud-init",
      "description": "Wait for cloud-init to complete on proxy VM",
      "status": "pending",
      "required": true,
      "command": "ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-proxy 'cloud-init status --wait'",
      "verification": { "method": "cloud_init_status", "expected": "done" },
      "depends_on": ["C2"]
    },
    {
      "id": "C4",
      "phase": "C",
      "name": "Wait for app server cloud-init",
      "description": "Wait for cloud-init to complete on app server VM",
      "status": "pending",
      "required": true,
      "command": "ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app 'cloud-init status --wait'",
      "verification": { "method": "cloud_init_status", "expected": "done" },
      "depends_on": ["C2"]
    },

    {
      "id": "D1",
      "phase": "D",
      "name": "Copy application files",
      "description": "SCP application files to app server via bastion jump",
      "status": "pending",
      "required": true,
      "max_attempts": 3,
      "command": "scp $SSH_OPTS -J azureuser@$BASTION_IP application/*.py application/requirements.txt azureuser@vm-app:/opt/flask-app/",
      "verification": {
        "method": "ssh_file_exists",
        "host": "vm-app",
        "path": "/opt/flask-app/app.py"
      },
      "depends_on": ["C4"]
    },
    {
      "id": "D2",
      "phase": "D",
      "name": "Install Python dependencies",
      "description": "Install requirements.txt in virtual environment",
      "status": "pending",
      "required": true,
      "max_attempts": 3,
      "command": "ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app '/opt/flask-app/venv/bin/pip install -r /opt/flask-app/requirements.txt'",
      "verification": { "method": "exit_code", "expected": 0 },
      "depends_on": ["D1"]
    },
    {
      "id": "D3",
      "phase": "D",
      "name": "Configure database connection",
      "description": "Create /etc/flask-app/database.env with connection string",
      "status": "pending",
      "required": true,
      "max_attempts": 3,
      "verification": {
        "method": "ssh_file_exists",
        "host": "vm-app",
        "path": "/etc/flask-app/database.env"
      },
      "depends_on": ["D2", "C1"]
    },
    {
      "id": "D4",
      "phase": "D",
      "name": "Start Flask service",
      "description": "Enable and start flask-app systemd service",
      "status": "pending",
      "required": true,
      "max_attempts": 3,
      "command": "ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app 'sudo systemctl enable flask-app && sudo systemctl restart flask-app'",
      "verification": {
        "method": "ssh_service_status",
        "service": "flask-app",
        "expected": "active"
      },
      "depends_on": ["D3"],
      "on_error": {
        "diagnostic_commands": [
          "ssh ... 'sudo journalctl -u flask-app --no-pager | tail -50'",
          "ssh ... 'sudo systemctl status flask-app'"
        ]
      }
    },

    {
      "id": "E1",
      "phase": "E",
      "name": "Test health endpoint",
      "description": "Verify /health returns {\"status\": \"ok\"}",
      "status": "pending",
      "required": true,
      "max_attempts": 30,
      "poll_interval_seconds": 10,
      "command": "curl -sk https://$PROXY_IP/health",
      "verification": {
        "method": "json_field",
        "field": "status",
        "expected": "ok"
      },
      "depends_on": ["D4"]
    },
    {
      "id": "E2",
      "phase": "E",
      "name": "Test homepage",
      "description": "Verify homepage loads with expected content",
      "status": "pending",
      "required": true,
      "command": "curl -sk https://$PROXY_IP/",
      "verification": {
        "method": "output_contains",
        "expected": "Flask Demo Application"
      },
      "depends_on": ["E1"]
    },
    {
      "id": "E3",
      "phase": "E",
      "name": "Test create entry",
      "description": "POST a new entry and verify redirect/success",
      "status": "pending",
      "required": true,
      "command": "curl -sk -X POST https://$PROXY_IP/ -d 'value=test-entry' -w '%{http_code}'",
      "verification": {
        "method": "http_status",
        "expected": [200, 302]
      },
      "depends_on": ["E2"]
    },
    {
      "id": "E4",
      "phase": "E",
      "name": "Test list entries",
      "description": "Verify /entries returns JSON array",
      "status": "pending",
      "required": true,
      "command": "curl -sk https://$PROXY_IP/entries",
      "verification": {
        "method": "json_array_not_empty"
      },
      "depends_on": ["E3"]
    },
    {
      "id": "E5",
      "phase": "E",
      "name": "Verify app server no public IP",
      "description": "Security check: app server should have no public IP",
      "status": "pending",
      "required": true,
      "command": "az vm show -g rg-flask-bicep-dev -n vm-app --show-details --query publicIps -o tsv",
      "verification": {
        "method": "output_empty"
      },
      "depends_on": ["B2"]
    },
    {
      "id": "E6",
      "phase": "E",
      "name": "Verify database no public access",
      "description": "Security check: PostgreSQL should have public access disabled",
      "status": "pending",
      "required": true,
      "command": "az postgres flexible-server show -g rg-flask-bicep-dev -n psql-flask-bicep-dev --query network.publicNetworkAccess -o tsv",
      "verification": {
        "method": "output_equals",
        "expected": "Disabled"
      },
      "depends_on": ["B2"]
    },
    {
      "id": "E7",
      "phase": "E",
      "name": "Test database connectivity",
      "description": "Verify app server can connect to PostgreSQL",
      "status": "pending",
      "required": true,
      "command": "ssh $SSH_OPTS -J ... 'source /etc/flask-app/database.env && psql \"$DATABASE_URL\" -c \"SELECT 1;\"'",
      "verification": {
        "method": "output_contains",
        "expected": "1 row"
      },
      "depends_on": ["D3"]
    },
    {
      "id": "E8",
      "phase": "E",
      "name": "Verify entries table exists",
      "description": "Check that SQLAlchemy created the entries table",
      "status": "pending",
      "required": true,
      "command": "ssh $SSH_OPTS -J ... 'source /etc/flask-app/database.env && psql \"$DATABASE_URL\" -c \"\\dt entries\"'",
      "verification": {
        "method": "output_contains",
        "expected": "entries"
      },
      "depends_on": ["E1"]
    },

    {
      "id": "F1",
      "phase": "F",
      "name": "Collect diagnostic logs",
      "description": "Gather cloud-init logs, nginx logs, flask logs from all VMs",
      "status": "pending",
      "required": false,
      "depends_on": ["E8"]
    },
    {
      "id": "F2",
      "phase": "F",
      "name": "Generate test report",
      "description": "Create test-report.md with PASS/PARTIAL/FAIL assessment",
      "status": "pending",
      "required": true,
      "depends_on": ["F1"]
    }
  ],

  "summary": {
    "total_tasks": 24,
    "completed": 0,
    "failed": 0,
    "skipped": 0,
    "pending": 24,
    "errors_encountered": 0,
    "errors_self_healed": 0
  },

  "errors_log": [],

  "final_result": {
    "status": null,
    "classification": null,
    "total_duration_minutes": null,
    "deviations_from_plan": [],
    "recommendations": []
  }
}
```

**Task Status Values:**
- `pending` - Not yet started
- `in_progress` - Currently executing
- `completed` - Successfully finished
- `failed` - Failed after max retries
- `skipped` - Skipped due to dependency failure or not required

**How to Use the JSON Execution State:**

1. **Initialize:** Create `execution-state.json` from the template above before starting
2. **Before each task:** Read JSON, find next pending task (respecting dependencies), update status to `in_progress`
3. **Execute:** Run the task's command, capture output and timing
4. **Verify:** Run the verification check defined for that task
5. **Update:** Write results back to JSON (pass/fail, duration, errors if any)
6. **On error:** Log error details to `errors_log`, determine fix, increment attempts, retry or mark failed
7. **Continue:** Move to next task, update `current_task` pointer
8. **Complete:** When all tasks done, update `summary` and `final_result`, generate markdown report

### Dependency Analysis and Subagent Delegation

This section analyzes task dependencies to identify opportunities for parallel execution via subagents. Delegating independent tasks to subagents speeds up execution and conserves the main agent's context window.

#### Task Dependency Graph

```
PHASE A: Prerequisites (Sequential - Main Agent)
┌─────────────────────────────────────────────────────────────────────────────┐
│  A1 ──► A2                                                                  │
│  (az)   (login)     A3        A4         A5 ──► A6                          │
│                     (jq)      (ssh)      (init)  (validate)                 │
│                                            ▲                                │
│                                            │                                │
│                                         depends on A3 (jq)                  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼ All Phase A complete
PHASE B: Infrastructure (Sequential - Main Agent)
┌─────────────────────────────────────────────────────────────────────────────┐
│  B1 ──────────────► B2                                                      │
│  (resource group)   (bicep deploy, ~15 min)                                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼ B2 complete
PHASE C: Resource Readiness (PARALLELIZABLE - Subagents)
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ┌──► C2 (bastion cloud-init) ──► C3 (proxy)        │
│  B2 complete ───────────►│                               ──► C4 (app)       │
│                          └──► C1 (PostgreSQL ready)                         │
│                                                                             │
│  C1, C2 can run in PARALLEL (different resources)                           │
│  C3, C4 can run in PARALLEL after C2 (different VMs via same bastion)       │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼ C1, C3, C4 all complete
PHASE D: Application Deployment (Sequential - Main Agent or Subagent)
┌─────────────────────────────────────────────────────────────────────────────┐
│  D1 ──► D2 ──► D3 ──► D4                                                    │
│  (copy)  (pip)  (db config)  (start service)                                │
│                   ▲                                                         │
│                   │ also depends on C1 (PostgreSQL ready)                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼ D4 complete
PHASE E: Verification (PARTIALLY PARALLELIZABLE - Subagents)
┌─────────────────────────────────────────────────────────────────────────────┐
│  FUNCTIONAL TESTS (sequential):     SECURITY TESTS (parallel, after B2):   │
│  E1 ──► E2 ──► E3 ──► E4            E5 (app no public IP)                   │
│  (health) (home) (create) (list)    E6 (db no public access)                │
│                                     E7 (db connectivity) ─► after D3        │
│                                     E8 (entries table) ─► after E1          │
│                                                                             │
│  E5, E6 can run in PARALLEL with C phase (only need B2)                     │
│  E1-E4 are sequential (each depends on previous)                            │
│  E7, E8 have separate dependencies                                          │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼ All E tasks complete
PHASE F: Report Generation (Sequential - Main Agent)
┌─────────────────────────────────────────────────────────────────────────────┐
│  F1 ──► F2                                                                  │
│  (collect logs)  (generate report)                                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Parallel Execution Opportunities

| Parallel Group | Tasks | When to Start | Subagent Suitable? | Notes |
|----------------|-------|---------------|-------------------|-------|
| **Prerequisites** | A1, A3, A4 | Immediately | No | Fast checks, run in main agent |
| **Resource Readiness** | C1, C2 | After B2 | ✅ YES | Different resources, no interference |
| **Cloud-init VMs** | C3, C4 | After C2 | ✅ YES | Different VMs via same SSH jump |
| **Security Checks** | E5, E6 | After B2 | ✅ YES | Azure CLI queries, independent |
| **DB Verification** | E7, E8 | After D3, E1 | Maybe | Can combine with functional tests |

#### Subagent Delegation Strategy

**Recommended Subagent Tasks:**

1. **Subagent 1: PostgreSQL Readiness Monitor** (after B2 completes)
   - Task: C1 - Wait for PostgreSQL ready
   - Duration: Up to 20 minutes (polling every 30s)
   - Returns: PostgreSQL FQDN, state confirmation
   - Context needed: Resource group name, server name
   - Why delegate: Long-running poll, saves main agent context

2. **Subagent 2: VM Cloud-init Monitor** (after B2 completes)
   - Tasks: C2, then C3 and C4 in parallel
   - Duration: Up to 10 minutes per VM
   - Returns: Cloud-init status for all VMs, any errors encountered
   - Context needed: Bastion public IP, SSH options, VM hostnames
   - Why delegate: Multiple SSH sessions, long-running waits

3. **Subagent 3: Security Verification** (after B2 completes)
   - Tasks: E5, E6 (can start immediately after infrastructure)
   - Duration: ~30 seconds
   - Returns: Security compliance status (public IP check, DB access check)
   - Context needed: Resource group name, VM name, PostgreSQL server name
   - Why delegate: Independent of application deployment, quick checks

**Tasks to Keep in Main Agent:**

| Phase | Tasks | Reason |
|-------|-------|--------|
| A | All | Fast prerequisite checks, sequential dependencies |
| B | B1, B2 | Critical path, needs error handling and context |
| D | D1-D4 | Sequential deployment, needs coordination |
| E | E1-E4 | Sequential functional tests, validates deployment |
| F | F1, F2 | Final report generation, needs all context |

#### Subagent Execution Pattern

```
MAIN AGENT                          SUBAGENT 1              SUBAGENT 2              SUBAGENT 3
    │                                   │                       │                       │
    ├─── Phase A (prerequisites) ───────┼───────────────────────┼───────────────────────┤
    │                                   │                       │                       │
    ├─── Phase B (infrastructure) ──────┼───────────────────────┼───────────────────────┤
    │                                   │                       │                       │
    │   B2 complete ────────────────────┼───────────────────────┼───────────────────────┤
    │          │                        │                       │                       │
    │          ├─── spawn ─────────────►│ C1: PostgreSQL        │                       │
    │          │                        │ (poll ready)          │                       │
    │          ├─── spawn ──────────────┼──────────────────────►│ C2,C3,C4: Cloud-init  │
    │          │                        │                       │ (wait all VMs)        │
    │          ├─── spawn ──────────────┼───────────────────────┼──────────────────────►│
    │          │                        │                       │                E5,E6: │
    │          │                        │                       │           Security    │
    │          │                        │                       │                       │
    │   (main agent waits or does       │                       │                       │
    │    lightweight status checks)     │                       │                       │
    │          │                        │                       │                       │
    │          │◄── return C1 result ───┤                       │                       │
    │          │◄────────────────────── return C2-C4 result ────┤                       │
    │          │◄─────────────────────────────────────── return E5,E6 result ───────────┤
    │          │
    │   All C tasks verified ───────────
    │          │
    ├─── Phase D (app deployment) ──────
    │          │
    ├─── Phase E: E1-E4 (functional) ───
    │          │
    ├─── Phase E: E7, E8 (db verify) ───
    │          │
    ├─── Phase F (report) ──────────────
    │          │
    ▼   DONE
```

#### Subagent Context Requirements

Each subagent needs minimal context to operate independently:

**Subagent 1 (PostgreSQL Monitor):**
```json
{
  "task": "C1",
  "resource_group": "rg-flask-bicep-dev",
  "postgres_server": "psql-flask-bicep-dev",
  "max_attempts": 40,
  "poll_interval_seconds": 30,
  "success_criteria": "state == Ready"
}
```

**Subagent 2 (Cloud-init Monitor):**
```json
{
  "tasks": ["C2", "C3", "C4"],
  "bastion_ip": "$BASTION_IP",
  "ssh_opts": "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null",
  "vms": ["vm-bastion", "vm-proxy", "vm-app"],
  "timeout_minutes": 10,
  "success_criteria": "cloud-init status == done"
}
```

**Subagent 3 (Security Verification):**
```json
{
  "tasks": ["E5", "E6"],
  "resource_group": "rg-flask-bicep-dev",
  "checks": [
    {"vm": "vm-app", "assert": "publicIps == null"},
    {"postgres": "psql-flask-bicep-dev", "assert": "publicNetworkAccess == Disabled"}
  ]
}
```

#### Estimated Time Savings

| Execution Mode | Estimated Duration | Context Usage |
|----------------|-------------------|---------------|
| **Fully Sequential** | ~35-45 minutes | High (all in main agent) |
| **With Subagents** | ~20-25 minutes | Low (main agent freed during waits) |

**Time savings:** ~10-20 minutes (parallelizing C1 with C2-C4, and E5-E6 with C phase)

**Context savings:** Main agent context preserved during:
- PostgreSQL provisioning wait (up to 20 min of polling)
- Cloud-init completion (up to 10 min per VM)
- Can handle errors in main flow while subagents wait

### Execution Principles

1. **Unattended Operation** - No human intervention required during execution
2. **Error Detection & Self-Healing** - Automatically detect, diagnose, and fix errors
3. **Iterative Approach** - Retry failed steps, don't give up on first error
4. **Comprehensive Logging** - Log all errors, root causes, and resolutions
5. **Final Test Report** - Generate pass/partial/fail assessment

### Execution Phases

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    AUTOMATED EXECUTION WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE A: Prerequisites & Setup                                             │
│  ├── Verify all prerequisites (Azure CLI, jq, SSH key)                     │
│  ├── Initialize secrets if needed                                           │
│  └── Create execution log file                                              │
│                                                                             │
│  PHASE B: Infrastructure Deployment (with retry)                            │
│  ├── Create resource group                                                  │
│  ├── Deploy Bicep templates                                                 │
│  ├── ON ERROR: Analyze, fix, retry (max 3 attempts)                        │
│  └── Log: error, root cause, resolution                                     │
│                                                                             │
│  PHASE C: Wait for Resources (with timeout)                                 │
│  ├── Wait for PostgreSQL (poll until Ready)                                │
│  ├── Wait for VM cloud-init completion                                      │
│  ├── ON ERROR: SSH into VMs to diagnose                                    │
│  └── Log: timing, any issues encountered                                    │
│                                                                             │
│  PHASE D: Application Deployment (with retry)                               │
│  ├── Copy files, install dependencies, configure                           │
│  ├── Start service                                                          │
│  ├── ON ERROR: Check logs, fix config, retry                               │
│  └── Log: deployment steps, any fixes applied                               │
│                                                                             │
│  PHASE E: Verification & Testing                                            │
│  ├── Health check endpoint                                                  │
│  ├── Functional tests (create entry, list entries)                         │
│  ├── Security verification (no public IPs where shouldn't be)              │
│  └── Log: all test results                                                  │
│                                                                             │
│  PHASE F: Generate Test Report                                              │
│  ├── Compile all logs                                                       │
│  ├── Assess: PASS / PARTIAL / FAIL                                         │
│  └── Document any workarounds or deviations                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Error Handling Strategy

#### Common Errors and Self-Healing Actions

| Error Type | Detection Method | Self-Healing Action |
|------------|------------------|---------------------|
| **Bicep deployment failure** | Non-zero exit code from `az deployment` | Read error message, check resource conflicts, retry with fixes |
| **PostgreSQL not ready** | State != "Ready" after timeout | Check Azure portal status via CLI, extend wait time |
| **Cloud-init failed** | `cloud-init status` returns error | SSH to VM, read `/var/log/cloud-init-output.log`, fix and re-run commands |
| **SSH connection refused** | Connection timeout/refused | Check NSG rules via CLI, verify public IP assigned |
| **nginx 502 Bad Gateway** | curl returns 502 | SSH to proxy, check nginx logs, verify upstream is running |
| **Flask service won't start** | systemctl status shows failed | SSH to app, check `journalctl -u flask-app`, fix config |
| **Database connection failed** | App logs show connection error | Verify DNS resolution, check credentials, test with psql |
| **Permission denied on files** | scp or service startup fails | SSH and fix ownership/permissions |

#### Diagnostic Commands Available

**Azure CLI diagnostics:**
```bash
# Check resource deployment status
az deployment group show -g rg-flask-bicep-dev -n main --query properties.provisioningState

# List all resources and their states
az resource list -g rg-flask-bicep-dev -o table

# Check PostgreSQL server state
az postgres flexible-server show -g rg-flask-bicep-dev -n psql-flask-bicep-dev --query state

# Check VM states
az vm list -g rg-flask-bicep-dev -d -o table

# Check NSG rules
az network nsg rule list -g rg-flask-bicep-dev --nsg-name nsg-web -o table
```

**SSH diagnostics (via bastion jump):**
```bash
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"
BASTION_IP=$(az vm show -g rg-flask-bicep-dev -n vm-bastion --show-details -o tsv --query publicIps)

# Check cloud-init status and logs
ssh $SSH_OPTS azureuser@$BASTION_IP "cloud-init status"
ssh $SSH_OPTS azureuser@$BASTION_IP "sudo cat /var/log/cloud-init-output.log | tail -50"

# Check nginx on proxy
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-proxy "sudo nginx -t"
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-proxy "sudo cat /var/log/nginx/error.log | tail -20"

# Check Flask service on app server
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app "sudo systemctl status flask-app"
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app "sudo journalctl -u flask-app --no-pager | tail -50"

# Test database connectivity from app server
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app "source /etc/flask-app/database.env && psql \"\$DATABASE_URL\" -c 'SELECT 1;'"

# Check DNS resolution
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app "nslookup psql-flask-bicep-dev.postgres.database.azure.com"
ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-proxy "nslookup vm-app"
```

### Execution Log Format

All execution activities are logged to `execution-log.md` with the following structure:

```markdown
# Execution Log - [TIMESTAMP]

## Environment
- Azure Subscription: [subscription-id]
- Region: swedencentral
- Resource Group: rg-flask-bicep-dev

## Phase A: Prerequisites
- [x] Azure CLI: OK (version X.Y.Z)
- [x] Azure Login: OK (user@domain.com)
- [x] jq: OK (version X.Y)
- [x] SSH Key: OK (~/.ssh/id_rsa.pub)
- [x] Secrets initialized: OK

## Phase B: Infrastructure Deployment
### Attempt 1
- Started: [timestamp]
- Command: az deployment group create ...
- Result: SUCCESS / FAILED
- Duration: X minutes

### Error (if any)
- Error Message: [full error]
- Root Cause: [analysis]
- Resolution: [what was fixed]
- Retry: Yes/No

## Phase C: Resource Readiness
- PostgreSQL ready: [timestamp] (waited X minutes)
- Bastion cloud-init: [timestamp]
- Proxy cloud-init: [timestamp]
- App cloud-init: [timestamp]

### Issues Encountered
- [description of any issues and fixes]

## Phase D: Application Deployment
- Files copied: OK
- Dependencies installed: OK
- Database configured: OK
- Service started: OK

### Issues Encountered
- [description of any issues and fixes]

## Phase E: Verification Tests
| Test | Result | Notes |
|------|--------|-------|
| Health endpoint (/health) | PASS/FAIL | Response: {"status": "ok"} |
| Homepage (/) | PASS/FAIL | HTTP 200, rendered HTML |
| Create entry (POST /) | PASS/FAIL | Entry created successfully |
| List entries (/entries) | PASS/FAIL | JSON array returned |
| App server no public IP | PASS/FAIL | Verified via az cli |
| Database no public access | PASS/FAIL | Verified via az cli |

## Phase F: Final Assessment

### Overall Result: PASS / PARTIAL / FAIL

### Summary
- Total duration: X minutes
- Errors encountered: N
- Errors self-healed: N
- Manual interventions required: N

### Deviations from Plan
- [list any changes made during execution]

### Recommendations
- [any improvements identified]
```

### Test Report Classification

| Classification | Criteria |
|----------------|----------|
| **PASS** | All tests pass, no errors or all errors self-healed, no deviations from plan |
| **PARTIAL** | Core functionality works but with workarounds, some tests skipped, or minor deviations |
| **FAIL** | Critical functionality broken, unable to self-heal after max retries |

### Verification Test Suite

Execute these tests in order after deployment:

```bash
#!/bin/bash
# verification-tests.sh

PROXY_IP=$(az vm show -g rg-flask-bicep-dev -n vm-proxy --show-details -o tsv --query publicIps)
BASTION_IP=$(az vm show -g rg-flask-bicep-dev -n vm-bastion --show-details -o tsv --query publicIps)
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

echo "=== Verification Test Suite ==="
TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Health endpoint
echo -n "Test 1: Health endpoint... "
if curl -sk "https://$PROXY_IP/health" | grep -q '"status".*"ok"'; then
    echo "PASS"
    ((TESTS_PASSED++))
else
    echo "FAIL"
    ((TESTS_FAILED++))
fi

# Test 2: Homepage loads
echo -n "Test 2: Homepage loads... "
if curl -sk "https://$PROXY_IP/" | grep -q "Flask Demo Application"; then
    echo "PASS"
    ((TESTS_PASSED++))
else
    echo "FAIL"
    ((TESTS_FAILED++))
fi

# Test 3: Create entry
echo -n "Test 3: Create entry... "
RESPONSE=$(curl -sk -X POST "https://$PROXY_IP/" -d "value=test-$(date +%s)" -w "%{http_code}" -o /dev/null)
if [ "$RESPONSE" = "302" ] || [ "$RESPONSE" = "200" ]; then
    echo "PASS"
    ((TESTS_PASSED++))
else
    echo "FAIL (HTTP $RESPONSE)"
    ((TESTS_FAILED++))
fi

# Test 4: List entries (JSON)
echo -n "Test 4: List entries JSON... "
if curl -sk "https://$PROXY_IP/entries" | grep -q '"id"'; then
    echo "PASS"
    ((TESTS_PASSED++))
else
    echo "FAIL"
    ((TESTS_FAILED++))
fi

# Test 5: App server has no public IP
echo -n "Test 5: App server no public IP... "
APP_PUBLIC_IP=$(az vm show -g rg-flask-bicep-dev -n vm-app --show-details --query publicIps -o tsv)
if [ -z "$APP_PUBLIC_IP" ]; then
    echo "PASS"
    ((TESTS_PASSED++))
else
    echo "FAIL (has IP: $APP_PUBLIC_IP)"
    ((TESTS_FAILED++))
fi

# Test 6: Database has no public access
echo -n "Test 6: Database no public access... "
DB_PUBLIC=$(az postgres flexible-server show -g rg-flask-bicep-dev -n psql-flask-bicep-dev --query network.publicNetworkAccess -o tsv)
if [ "$DB_PUBLIC" = "Disabled" ]; then
    echo "PASS"
    ((TESTS_PASSED++))
else
    echo "FAIL (public access: $DB_PUBLIC)"
    ((TESTS_FAILED++))
fi

# Test 7: Database connectivity from app server
echo -n "Test 7: Database connectivity... "
DB_TEST=$(ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app \
    "source /etc/flask-app/database.env && psql \"\$DATABASE_URL\" -c 'SELECT 1;' 2>&1")
if echo "$DB_TEST" | grep -q "1 row"; then
    echo "PASS"
    ((TESTS_PASSED++))
else
    echo "FAIL"
    ((TESTS_FAILED++))
fi

# Test 8: Entries table exists
echo -n "Test 8: Entries table exists... "
TABLE_TEST=$(ssh $SSH_OPTS -J azureuser@$BASTION_IP azureuser@vm-app \
    "source /etc/flask-app/database.env && psql \"\$DATABASE_URL\" -c '\\dt entries' 2>&1")
if echo "$TABLE_TEST" | grep -q "entries"; then
    echo "PASS"
    ((TESTS_PASSED++))
else
    echo "FAIL"
    ((TESTS_FAILED++))
fi

echo ""
echo "=== Test Results ==="
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "Overall: PASS"
    exit 0
elif [ $TESTS_PASSED -gt $TESTS_FAILED ]; then
    echo "Overall: PARTIAL"
    exit 1
else
    echo "Overall: FAIL"
    exit 2
fi
```

### Iteration Strategy

When errors occur, follow this iteration approach:

```
┌─────────────────────────────────────────────────────────────────┐
│                    ERROR HANDLING LOOP                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. DETECT ERROR                                                │
│     └── Capture exit code, error message, context               │
│                                                                 │
│  2. DIAGNOSE ROOT CAUSE                                         │
│     ├── Parse error message                                     │
│     ├── Check Azure resource status (az CLI)                    │
│     ├── SSH to affected VM if applicable                        │
│     ├── Read relevant logs                                      │
│     └── Identify specific failure point                         │
│                                                                 │
│  3. DETERMINE FIX                                               │
│     ├── Configuration issue → Fix config, retry                 │
│     ├── Timing issue → Wait longer, retry                       │
│     ├── Permission issue → Fix permissions, retry               │
│     ├── Resource conflict → Delete/rename, retry                │
│     └── Unknown → Log details, attempt generic fixes            │
│                                                                 │
│  4. APPLY FIX                                                   │
│     └── Execute corrective commands                             │
│                                                                 │
│  5. LOG EVERYTHING                                              │
│     ├── Original error                                          │
│     ├── Diagnostic findings                                     │
│     ├── Root cause analysis                                     │
│     ├── Fix applied                                             │
│     └── Outcome of retry                                        │
│                                                                 │
│  6. RETRY (up to MAX_RETRIES per phase)                         │
│     ├── If success → Continue to next phase                     │
│     ├── If same error → Try different fix                       │
│     └── If max retries → Log as unresolved, assess impact       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Maximum Retry Limits

| Phase | Max Retries | Timeout |
|-------|-------------|---------|
| Infrastructure deployment | 3 | 30 min total |
| PostgreSQL readiness | 40 polls | 20 min |
| Cloud-init completion | 30 polls | 15 min per VM |
| Application deployment | 3 | 10 min total |
| Health check verification | 30 polls | 5 min |

### Unattended Execution Checklist

Before starting unattended execution, verify:

- [ ] Azure CLI installed and logged in (`az account show`)
- [ ] Correct subscription selected (`az account set -s <subscription>`)
- [ ] jq installed (`jq --version`)
- [ ] SSH key exists (`~/.ssh/id_rsa.pub`)
- [ ] Sufficient Azure quota for resources
- [ ] No existing resource group with same name (or okay to reuse)
- [ ] Network connectivity to Azure APIs
- [ ] Sufficient disk space for logs

### Post-Execution Artifacts

After execution completes, the following artifacts are generated:

```
reference/flask-bicep/
├── execution-log.md           # Detailed execution log
├── test-report.md             # Final test report with PASS/PARTIAL/FAIL
├── errors/                    # Directory for error artifacts (if any)
│   ├── error-001-bicep.txt   # Captured error details
│   ├── error-002-nginx.txt
│   └── ...
└── diagnostics/               # Diagnostic outputs captured
    ├── cloud-init-bastion.log
    ├── cloud-init-proxy.log
    ├── cloud-init-app.log
    ├── nginx-error.log
    └── flask-app-journal.log
```

---

## References

- [Microsoft Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure Resource Abbreviations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure PostgreSQL Flexible Server Pricing](https://azure.microsoft.com/en-us/pricing/details/postgresql/flexible-server/)
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)
