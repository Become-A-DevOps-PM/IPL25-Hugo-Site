# DevOps PM IPL25 - Hugo Documentation Site

## Project Overview

This repository contains the Hugo-based documentation site for the DevOps PM IPL25 course. The site is deployed to GitHub Pages at <https://devops-pm-25.educ8.se/>.

**Purpose:** Public-facing course documentation, exercises, tutorials, and reveal.js presentations for the IPL25 DevOps Project Management course.

**Technology Stack:**
- Static site generator: Hugo Extended (v0.128.0+)
- Theme: DocDock (with compatibility patches for modern Hugo)
- Deployment: GitHub Actions → GitHub Pages
- Presentations: Dual system (Standalone HTML + DocDock inline slides)

**Project Statistics:**
- 138 markdown content files (~1MB content)
- 15 active exercises (6 server + 3 network + 6 application)
- 62 presentations total (26 DocDock slides + 36 standalone HTML)
- 23 legacy files in 4 legacy directories
- 8 theme override files (32KB)
- 4 Claude Code skills + 2 custom commands
- 3 reference implementations (stage-ultimate, dev-3tier-flask, starter-flask)

## Course Taxonomy

**Program:** IPL (IT Project Management - Swedish: IT-Projektledning)
**Current Cohort:** 25

| Tag | Full Name |
|-----|-----------|
| SNS | Server, Network, Storage And IT Security |
| ASD | Agile Software Development And Deployment |

### Frontmatter Format

All content files include course taxonomy fields:

```toml
program = "IPL"
cohort = "25"
courses = ["SNS"]  # or ["ASD"] or ["SNS", "ASD"]
```

### Current Content Assignment

All existing content is tagged `courses = ["SNS"]`. When ASD course content is added:
- New ASD-specific content: `courses = ["ASD"]`
- Shared content (setup tutorials, cheat sheets): `courses = ["SNS", "ASD"]`

## Related Repository - 2024 Reference Project

**Location:** `/Users/lasse/Library/Mobile Documents/iCloud~md~obsidian/Documents/IPL25-Server-Network-Security`

**Important:** This is a READ-ONLY reference. Never modify files in this directory.

The 2024 project contains the complete course development materials:

### Key Resources in 2024 Project

**Course Administration (`course/`):**
- `PROJECT-CHARTER.md` - Complete course vision and pedagogy (15,000+ words)
- `COURSE-STRUCTURE.md` - Capability-based learning organization
- `TECH-STACK-DECISION-LOG.md` - Authoritative technology decisions
- `onboarding/SETUP-GUIDE.md` - Comprehensive setup guide (1,400+ lines)
- `syllabus/` - Assignments and study guides

**Technical Concept Papers (`context/concepts/`):**
14 formal frameworks including:
- Step Card Framework - Infrastructure evolution
- Service Trinity - Compute/Network/Storage foundation
- NFR Ladder - Non-functional requirements progression
- Agentic Systems - AI agent organization

**IPL24 Legacy Content (`context/content/`):**
- 99 markdown files with exercises and tutorials
- Organized by: compute, network, storage, it-security, risk-analysis
- 26 exercises across 5 tracks
- **Note:** Uses LEMP stack (PHP) - needs conversion to Flask/Python for IPL25

**AI Agent Personas (`.claude/agents/`):**
5 specialized agents:
1. Alva Architect - System architecture
2. David Developer - Flask/Python development
3. Dennis DevOps - CI/CD and automation
4. Therese Tester - Security and testing
5. Stig Teacher - Course boundaries and pedagogy

**Exercise Creation Skill (`.claude/skills/create-exercise/`):**
- Complete framework for creating consistent educational exercises
- GUIDE.md, TEMPLATE.md, EXAMPLE.md

**Infrastructure Code (`infra/`):**
- Bicep templates for Azure deployment
- Cloud-init scripts for server provisioning

**Flask Application (`src/`):**
- Example Flask application code
- Models, forms, templates

## Related Repository - DemoDice

**Location:** `/Users/lasse/Developer/IPL_Development/DemoDice`

**Important:** This is a READ-ONLY reference. Never modify files in this directory.

The DemoDice project contains the "Presenter-Tron 3000" - a steampunk-themed lottery ball machine for randomizing presentation order during demos.

**Copied to this project:**
- `DemoDice/src/index-presenter-tron-canvas-sprite.html` → `static/tools/demo-dice/index.html`
- `DemoDice/src/assets/ball-{1-6}.png` → `static/tools/demo-dice/assets/`

**Check for updates:** If the DemoDice application is updated, the source files are in `DemoDice/src/`. Copy updated files to `static/tools/demo-dice/` as needed.

## Reference Implementation - Stage Ultimate

**Location:** `reference/stage-ultimate/`

The "stage-ultimate" reference implementation is a complete, production-grade Flask Contact Form application deployed on Azure. It demonstrates best practices for:

- Infrastructure as Code (Azure CLI scripts)
- Network segmentation with proper security groups
- Bastion host for secure SSH access
- Reverse proxy with SSL termination
- Azure Key Vault for secrets management
- Managed identity for secure credential access

### Architecture Overview

```
Internet
    │
    ├──SSH (22)────→ Bastion VM ──SSH──→ Internal VMs
    │                (10.0.1.x)
    │
    └──HTTPS (443)─→ Reverse Proxy VM ──HTTP (5001)──→ App Server VM
                     (10.0.2.x)                        (10.0.3.x)
                                                           │
                                                           ├──→ PostgreSQL (Azure PaaS)
                                                           └──→ Key Vault (Azure PaaS)
```

### Directory Structure

```
reference/stage-ultimate/
├── README.md                    # Quick-start guide (6 steps)
├── ARCHITECTURE.md              # 10 mermaid diagrams at different abstraction levels
├── PLAN-INFRASTRUCTURE.md       # Detailed infrastructure specification
├── PLAN-APPLICATION.md          # Detailed application specification
│
├── infrastructure/              # Azure provisioning
│   ├── provision.sh            # Main script (~600 lines)
│   ├── cloud-init-bastion.yaml # SSH hardening, fail2ban
│   ├── cloud-init-proxy.yaml   # nginx, SSL, fail2ban
│   └── cloud-init-app-server.yaml # Python, Azure CLI
│
├── application/                 # Flask application
│   ├── app.py                  # Application factory
│   ├── config.py               # Configuration with Key Vault fallback
│   ├── models.py               # SQLAlchemy models
│   ├── routes.py               # Blueprint with all routes
│   ├── validators.py           # Input validation
│   ├── keyvault.py             # Azure Key Vault integration
│   ├── wsgi.py                 # Gunicorn entry point
│   ├── requirements.txt        # Production dependencies
│   ├── templates/              # Jinja2 templates (6 files)
│   └── static/style.css        # Application styling
│
└── deploy/                      # Deployment automation
    ├── deploy.sh               # Main deployment script
    ├── nginx/                  # Reverse proxy config
    │   ├── flask-contact-form.conf
    │   └── ssl-params.conf
    └── systemd/
        └── flask-contact-form.service
```

### Key Features

| Component | Technology | Purpose |
|-----------|------------|---------|
| VMs (3x) | Standard_B1s | Bastion, Proxy, App Server |
| Database | PostgreSQL Flexible Server (B1ms) | Production data storage |
| Secrets | Azure Key Vault + RBAC | Secure credential management |
| Identity | System-assigned Managed Identity | No stored credentials |
| Networking | 5 subnets + NSGs | Network segmentation |
| SSL | Self-signed certificates | HTTPS termination |

### Cost Estimate

~$40-50/month for learning environment (all resources use lowest cost tiers)

### Quick Start

```bash
# 1. Provision infrastructure (15-20 minutes)
cd reference/stage-ultimate/infrastructure
./provision.sh

# 2. Wait for cloud-init (2-3 minutes)

# 3. Deploy application (3-5 minutes)
cd ../deploy
./deploy.sh

# 4. Access application
PROXY_IP=$(az vm show -g flask-ultimate-rg -n flask-ultimate-proxy --show-details -o tsv --query publicIps)
echo "https://$PROXY_IP/"
```

### Documentation Files

- **README.md** - Quick-start with prerequisites, steps, troubleshooting
- **ARCHITECTURE.md** - Visual diagrams including:
  - High-level overview
  - Network topology with IP addresses
  - User request flow (sequence diagram)
  - SSH management flow
  - NSG rules visualization
  - Application component stack
  - Data flow and trust boundaries
  - Deployment pipeline
- **PLAN-INFRASTRUCTURE.md** - Complete infrastructure specification
- **PLAN-APPLICATION.md** - Complete application specification

## Reference Implementation - Dev Three-Tier Flask

**Location:** `reference/dev-3tier-flask/`

A simplified Flask application deployment on Azure for learning application development. Single-VM deployment with nginx, Flask/Gunicorn, and PostgreSQL.

### Architecture Overview

```
Internet ──→ VM (nginx:443 → Flask:5001) ──→ PostgreSQL
             Ubuntu 24.04                     Azure PaaS
             snet-default (10.0.0.0/24)       Public access
```

### Key Features

| Component | Details |
|-----------|---------|
| VM | Standard_B1s, Ubuntu 24.04 LTS |
| Web Server | nginx with self-signed SSL |
| App Server | Gunicorn (2 workers) on port 5001 |
| Database | PostgreSQL 16 Flexible Server |
| Cost | ~$20/month |
| Deploy time | 10-15 minutes |

### Application Features

- **Landing page** with webinar registration
- **Admin authentication** (Flask-Login, session-based)
- **Protected admin routes** for attendee management
- **CSV export** functionality
- **WTForms validation** with CSRF protection
- **OWASP security headers**

### Quick Start

```bash
# Deploy everything
./deploy-all.sh

# Access application
VM_IP=$(az vm show -g rg-flask-dev -n vm-app --show-details -o tsv --query publicIps)
open "https://$VM_IP/"

# Default admin login: admin / Admin123!

# Cleanup
./delete-all.sh
```

### Directory Structure

```
reference/dev-3tier-flask/
├── deploy-all.sh              # One-command deployment
├── delete-all.sh              # Resource cleanup
├── config.sh                  # Central configuration
├── infrastructure/            # Bicep templates + cloud-init
├── application/               # Flask app with blueprints
│   ├── app/
│   │   ├── routes/           # main, demo, admin, auth, api
│   │   ├── models/           # Entry, Registration, User
│   │   ├── services/         # Business logic layer
│   │   └── forms/            # WTForms with validation
│   └── tests/                # 118 pytest tests
├── deploy/                    # Deployment scripts
└── docs/                      # Extensive documentation
    └── exercises/            # Phase 2-4 exercise guides
```

### Comparison with stage-ultimate

| Aspect | dev-3tier-flask | stage-ultimate |
|--------|-----------------|----------------|
| Purpose | Application development | Infrastructure security |
| VMs | 1 (combined) | 3 (bastion, proxy, app) |
| SSH | Direct | Via bastion jump host |
| PostgreSQL | Public access | Private DNS |
| Complexity | Low | Moderate-High |

Use **dev-3tier-flask** when learning Flask, Python, or basic Azure deployment.
Use **stage-ultimate** when learning network security, defense in depth, or production patterns.

## Reference Implementation - Starter Flask

**Location:** `reference/starter-flask/`

A minimal Flask application for learning Container Apps deployment with optional Azure SQL Database. Features **graceful degradation**: the app starts and serves pages even without a database connection.

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      User's Browser                              │
└───────────────────────────┬─────────────────────────────────────┘
                            │ HTTPS
┌───────────────────────────▼─────────────────────────────────────┐
│              Azure Container Apps (managed ingress)              │
└───────────────────────────┬─────────────────────────────────────┘
                            │ Port 5000
┌───────────────────────────▼─────────────────────────────────────┐
│                    Flask App (Gunicorn)                          │
└──────────────────────────┼──────────────────────────────────────┘
                           │ SQLAlchemy
┌──────────────────────────▼──────────────────────────────────────┐
│  Local: SQLite (notes.db)  │  Azure: Azure SQL (Basic tier)     │
└─────────────────────────────────────────────────────────────────┘
```

### Key Features

| Feature | Description |
|---------|-------------|
| Graceful Degradation | App starts without database; shows errors only when DB operations attempted |
| Multi-Environment Config | `local` (SQLite), `azure` (Azure SQL), `pytest` (in-memory) |
| Flask-Migrate | Database schema versioning with Alembic |
| Container-Ready | Dockerfile with ODBC Driver 18 for Azure SQL |
| Cost | ~$15-20/month |

### Quick Start

```bash
# Local development (no Azure required)
cd reference/starter-flask/application
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
flask db upgrade
flask run --debug
# Open http://localhost:5000

# Deploy to Azure Container Apps
./deploy/deploy.sh          # Without database (graceful degradation)
# OR
./deploy/provision-sql.sh   # Create Azure SQL first
./deploy/deploy.sh          # Then deploy app

# Cleanup
./deploy/delete.sh
```

### Directory Structure

```
reference/starter-flask/
├── README.md               # User-facing quick start
├── application/
│   ├── app.py              # Flask application factory
│   ├── config.py           # Configuration classes
│   ├── models.py           # SQLAlchemy Note model
│   ├── routes.py           # Route handlers
│   ├── wsgi.py             # Gunicorn entry point
│   ├── Dockerfile          # Container build with ODBC driver
│   ├── migrations/         # Flask-Migrate database migrations
│   ├── templates/          # Jinja2 templates
│   └── tests/              # pytest test suite
├── deploy/
│   ├── provision-sql.sh    # Create Azure SQL Database
│   ├── deploy.sh           # Deploy to Container Apps
│   └── delete.sh           # Remove all resources
└── docs/
    ├── architecture.md     # Architecture and design patterns
    └── future-improvements.md  # Enhancement ideas
```

### Application Endpoints

| Route | Method | Purpose |
|-------|--------|---------|
| `/` | GET | Home page |
| `/notes` | GET | List all saved notes |
| `/notes/new` | GET | Display note form |
| `/notes/new` | POST | Save new note |

## Working Guidelines

### Content Development

When creating content for this Hugo site:

1. **Exercises should follow the create-exercise template** from the 2024 project
2. **Convert LEMP examples to Flask/Python** - IPL25 uses Python exclusively
3. **Preserve frontmatter format** - Hugo uses TOML (`+++`)
4. **Each piece of content must stand alone** - No cross-references between articles, exercises, or other content within this project. This is critical for maintainability. Each article and exercise must be self-contained.
5. **Use the 2024 content as source material** - Adapt, don't copy directly

### Technology Stack (IPL25 - No Alternatives)

```
Cloud:         Azure (mandatory)
OS:            Ubuntu 24.04 LTS
Language:      Python 3.11+
Web Framework: Flask 2.3+
Web Server:    nginx 1.24+
Database:      PostgreSQL 14+
Frontend:      HTML5 + CSS3 + Vanilla JavaScript
WSGI:          Gunicorn
IaC:           Bicep templates
Scripting:     Bash
CI/CD:         GitHub Actions
```

### Hugo Site Structure

```
content/                                   (118 markdown files, 744KB)
├── _index.md                             # Homepage
├── getting-started/                       (4 files - complete)
│   ├── _index.md
│   ├── course-introduction.md
│   ├── project-assignment.md
│   └── setup-overview.md
├── tutorials/                             (17 files - complete)
│   └── setup/                            # Modular setup guides
│       ├── _index.md
│       ├── package-managers.md
│       ├── azure/                        # Azure account + CLI
│       ├── development/                  # Git, PostgreSQL, Python, VS Code
│       ├── github/                       # GitHub account + CLI
│       └── ai-tools/                     # Claude, ChatGPT, Gemini
├── infrastructure-fundamentals/           (60 files - complete)
│   ├── _index.md
│   ├── compute/                          # 4 topics + sizing article
│   │   ├── 1-what-is-a-server/          # Article + 2 slides (EN/SE)
│   │   ├── 2-common-server-roles/
│   │   ├── 3-inside-a-physical-server/
│   │   ├── 4-inside-a-virtual-server/
│   │   ├── 5-azure-vm-sizing-and-cost.md
│   │   └── legacy/                       # 5 v1 files
│   ├── network/                          # 6 topics
│   │   ├── 1-what-is-a-network/         # Article + 2 slides (EN/SE)
│   │   ├── 2-ip-addresses-and-cidr-ranges/
│   │   ├── 3-private-and-public-networks/
│   │   ├── 4-firewalls/
│   │   ├── 5-the-osi-model/
│   │   ├── 6-network-intermediaries/
│   │   └── legacy/                       # 7 v1 files
│   └── storage/                          # 3 topics
│       ├── 1-what-is-persistence/       # Article + 2 slides (EN/SE)
│       ├── 2-databases/
│       ├── 3-storage/
│       └── legacy/                       # 4 v1 files
├── exercises/                             (34 files)
│   ├── _index.md
│   ├── server-foundation/                # Complete (6 exercises)
│   │   ├── 1-portal-interface/          # Exercises 1-3
│   │   │   ├── 1-provisioning-vm-portal.md
│   │   │   ├── 2-provisioning-vm-ssh-keys.md
│   │   │   └── 3-automating-nginx-custom-data.md
│   │   ├── 2-command-line-interface/    # Exercises 4-6
│   │   │   ├── 4-resource-group-az-cli.md
│   │   │   ├── 5-provisioning-vm-az-cli.md
│   │   │   └── 6-automating-vm-bash-script.md
│   │   └── legacy/                       # 10 files (v1 + v2 variants)
│   ├── network-foundation/               # Complete (3 exercises)
│   │   ├── 1-portal-interface/          # Exercises 1-2
│   │   │   ├── 1-creating-virtual-network.md
│   │   │   └── 2-virtual-network-enhanced-security.md
│   │   ├── 2-command-line-interface/    # Exercise 3
│   │   │   └── 3-virtual-network-az-cli.md
│   │   └── legacy/                       # 3 v1 files
│   └── application-development/          # Complete (6 exercises)
│       ├── 1. develop-flask-locally.md
│       ├── 2. deploy-flask-application-basic.md
│       ├── 3. add-database-persistence.md
│       ├── 4. provision-azure-postgresql.md
│       ├── 5. deploy-flask-with-database.md
│       └── 6. production-deployment-systemd.md
├── cheat-sheets/                         (4 files)
│   ├── _index.md
│   ├── bash-scripting-cheatsheet.md
│   ├── cloud-init-cheatsheet.md
│   └── linux-cheatsheet.md
├── project-templates/                     (5 files)
│   ├── _index.md
│   ├── demo-instructions.md              # English
│   ├── demo-instruktioner.md             # Swedish
│   ├── retrospective-template.md         # English
│   └── retrospective-template-sv.md      # Swedish
├── presentations/                         (1 file)
│   └── _index.md                         # Links to standalone HTML
├── week-1/                                (1 file)
│   └── _index.md                         # Week 1 overview (chapter)
├── week-2/                                (1 file)
│   └── _index.md                         # Week 2 overview (chapter)
├── privacy-feedback.md                    # Privacy policy for feedback system
├── application/                           # Placeholder (_index only)
└── it-security/                           # Placeholder (_index only)

layouts/
└── partials/                             # 7 theme overrides (28KB)
    ├── custom-head.html                  # Analytics + robots meta
    ├── header.html                       # Header compatibility
    ├── language-selector.html            # Language switching
    ├── pagination.html                   # Hugo v0.148+ Pager API fix
    ├── flex/
    │   ├── body-aftercontent.html       # Page layout fixes
    │   └── scripts.html                  # Reveal.js integration
    └── original/
        └── scripts.html                  # Original theme scripts

static/                                    (2.4MB)
├── CNAME                                 # devops-pm-25.educ8.se
├── robots.txt                            # Search engine directives
├── images/
│   └── NetworkOverview.png              # Network diagram
├── js/
│   └── feedback.js                       # Feedback system (11.4KB)
├── tools/
│   └── demo-dice/                       # Presenter-Tron 3000 tool
│       ├── index.html
│       └── assets/ball-{1-6}.png
└── presentations/                        # Standalone HTML presentations (36 files)
    ├── course-introduction.html          # Course overview
    ├── project-assignment.html           # Project requirements
    ├── swedish-tech-slides.css           # Swedish Tech branding
    ├── lars-appel.jpg                    # Instructor photo (112KB)
    ├── webinar-mockup.png                # Supporting image (309KB)
    └── infrastructure-fundamentals/
        ├── compute/                      # 8 files (4 topics × 2 langs)
        │   ├── 1-what-is-a-server.html
        │   ├── 1-what-is-a-server-swe.html
        │   ├── 2-common-server-roles.html
        │   ├── 2-common-server-roles-swe.html
        │   ├── 3-inside-a-physical-server.html
        │   ├── 3-inside-a-physical-server-swe.html
        │   ├── 4-inside-a-virtual-server.html
        │   └── 4-inside-a-virtual-server-swe.html
        ├── network/                      # 12 files (6 topics × 2 langs)
        │   ├── 1-what-is-a-network.html
        │   ├── 1-what-is-a-network-swe.html
        │   ├── 2-ip-addresses-and-cidr-ranges.html
        │   ├── 2-ip-addresses-and-cidr-ranges-swe.html
        │   ├── 3-private-and-public-networks.html
        │   ├── 3-private-and-public-networks-swe.html
        │   ├── 4-firewalls.html
        │   ├── 4-firewalls-swe.html
        │   ├── 5-the-osi-model.html
        │   ├── 5-the-osi-model-swe.html
        │   ├── 6-network-intermediaries.html
        │   └── 6-network-intermediaries-swe.html
        └── storage/                      # 6 files (3 topics × 2 langs)
            ├── 1-what-is-persistence.html
            ├── 1-what-is-persistence-swe.html
            ├── 2-databases.html
            ├── 2-databases-swe.html
            ├── 3-storage.html
            └── 3-storage-swe.html

.claude/
├── settings.local.json                   # Local Claude configuration
├── skills/                               # 4 Claude Code skills
│   ├── create-exercise/                  # Exercise creation framework
│   ├── revealjs-skill/                   # Swedish Tech presentations
│   ├── student-technical-writer/         # Student-facing content style
│   └── technical-textbook-writer/        # Formal textbook style
└── commands/                             # 2 custom slash commands
    ├── check-links.md                   # Link checking command
    ├── lint-md.md                       # Markdown linting command
    └── scripts/                         # Supporting scripts
        ├── crawl-links-local.sh
        └── crawl-links-public.sh

docs/                                      (8 files + planning/)
├── hugo-github-pages-setup.md           # Complete setup tutorial (34KB)
├── feedback-system-plan.md              # Feedback feature design (superseded)
├── feedback-system-solution.md          # Implementation details (current)
├── project-review-improvements.md       # Project improvement recommendations
├── markdown-lint-report.md              # Lint analysis summary
├── markdown-lint-report.json            # Lint analysis data
├── repetition-ipl25-vecka1-notes.md     # Week 1 recap notes
└── planning/                            # Future/aspirational content
    └── book-outline.md                  # Book concept notes

reference/                                 # Reference implementations
├── stage-ultimate/                       # Production-grade Flask (3 VMs, bastion)
│   ├── README.md                        # Quick-start guide
│   ├── ARCHITECTURE.md                  # 10 mermaid diagrams
│   ├── infrastructure/                  # Azure provisioning scripts
│   ├── application/                     # Flask application code
│   └── deploy/                          # Deployment automation
├── dev-3tier-flask/                      # Simplified Flask (1 VM, direct SSH)
│   ├── deploy-all.sh                    # One-command deployment
│   ├── delete-all.sh                    # Resource cleanup
│   ├── infrastructure/                  # Bicep templates + cloud-init
│   ├── application/                     # Flask app with blueprints
│   │   ├── app/routes/                 # main, demo, admin, auth, api
│   │   ├── app/models/                 # Entry, Registration, User
│   │   └── tests/                      # 118 pytest tests
│   └── docs/exercises/                  # Phase 2-4 implementation guides
└── starter-flask/                        # Minimal Flask for Container Apps
    ├── application/                     # Flask app with graceful degradation
    │   ├── app.py, models.py, routes.py
    │   ├── Dockerfile                   # ODBC Driver 18 for Azure SQL
    │   └── migrations/                  # Flask-Migrate
    └── deploy/                          # Container Apps deployment
```

### Claude Skills (This Project)

This project includes 4 Claude Code skills for content creation:

**1. Exercise Creation (`create-exercise/`):**
- Framework for creating consistent educational exercises
- Files: SKILL.md, GUIDE.md, TEMPLATE.md, EXAMPLE.md
- Enforces pedagogical structure and template compliance
- Use: `/skill create-exercise` when creating new exercises

**2. Swedish Tech Presentations (`revealjs-skill/`):**
- Creates standalone reveal.js presentations with Swedish Tech branding
- Blue/yellow color scheme, professional styling
- Files: SKILL.md, README.md, example-template.html, config.js, template.css
- Outputs to `static/presentations/` as self-contained HTML files
- Use: Reference SKILL.md for presentation creation guidelines

**3. Student Technical Writer (`student-technical-writer/`):**
- Writing style for student-facing technical content
- Balances conceptual understanding with practical application
- Third-person expository style, explanatory depth
- Used for all infrastructure-fundamentals articles
- Use: Reference when writing or rewriting technical articles

**4. Technical Textbook Writer (`technical-textbook-writer/`):**
- Formal university textbook style (expository, objective, third-person)
- Files: SKILL.md, references/examples.md, references/patterns.md, scripts/validate_textbook.py
- Rigorous academic approach for formal course materials
- Use: For formal textbook content or academic documentation

## Presentation Architecture

This project uses **TWO distinct presentation systems** serving different purposes:

### 1. Standalone HTML Presentations (Primary - 36 files)

**Location:** `static/presentations/`
**Technology:** Self-contained HTML with CDN-linked reveal.js + Swedish Tech CSS
**Count:** 36 files (2 course + 26 infrastructure bilingual + 8 compute)

**Use for:**
- Course introductions and overview presentations
- Content linked from articles (preferred linking target)
- Professional branded presentations for external sharing
- Content requiring custom branding or analytics

**Files:**
```
static/presentations/
├── course-introduction.html              # Course overview
├── project-assignment.html               # Project requirements
└── infrastructure-fundamentals/
    ├── compute/                          # 8 files (4 topics × 2 langs)
    ├── network/                          # 12 files (6 topics × 2 langs)
    └── storage/                          # 6 files (3 topics × 2 langs)
```

**Characteristics:**
- Swedish Tech branding (blue/yellow color scheme)
- Google Analytics integration (G-50TPJY0FZH)
- `noindex,nofollow` robots meta tag
- Geometric backgrounds and professional styling
- Direct file access, no Hugo processing

**Creating new standalone presentations:**
- Use `.claude/skills/revealjs-skill/SKILL.md` as guide
- Output to `static/presentations/[category]/[name].html`
- Create bilingual pairs (EN and -swe)
- Link from articles or presentations index

### 2. DocDock Inline Slides (Legacy/Supplementary - 26 files)

**Location:** `content/` with `type = "slide"` in frontmatter
**Technology:** Hugo-processed markdown with DocDock theme + reveal.js
**Count:** 26 files (13 English + 13 Swedish)

**Use for:**
- Quick technical slides embedded in content structure
- Legacy slide content (currently hidden from navigation)
- Supplementary to standalone HTML (not primary linking target)

**Coverage:**
```
infrastructure-fundamentals/
├── compute/        4 topics × 2 langs = 8 files (also have standalone HTML)
├── network/        6 topics × 2 langs = 12 files (DocDock only)
└── storage/        3 topics × 2 langs = 6 files (DocDock only)
```

**Characteristics:**
- Markdown format with TOML frontmatter
- `hidden = true` (not visible in navigation)
- `theme = "sky"` (DocDock default)
- Hugo URL structure: `/[section]/[topic]/[name]-slides/`
- Bilingual pairs: `-slides.md` (EN) and `-slides-swe.md` (SE)

**Example frontmatter:**
```markdown
+++
title = "What is a Server?"
type = "slide"
date = 2024-11-17
draft = false
hidden = true
theme = "sky"

[revealOptions]
controls = true
progress = true
history = true
center = true
+++

# Slide 1
Content

---

# Slide 2
Use `---` for horizontal slides
Use `___` for vertical slides
```

### Presentation Linking Pattern

**Articles link to standalone HTML presentations** (not DocDock slides):

Example from infrastructure-fundamentals articles:
```markdown
[Watch the presentation](/presentations/infrastructure-fundamentals/compute/1-what-is-a-server.html)

[Se presentationen på svenska](/presentations/infrastructure-fundamentals/compute/1-what-is-a-server-swe.html)

---

[Article content follows...]
```

### Current State

**All infrastructure-fundamentals presentations:**
- Exist in BOTH formats (standalone HTML + DocDock slides)
- Articles link to standalone HTML (preferred)
- DocDock slides are supplementary/legacy
- Full bilingual coverage (EN + Swedish)

**Course presentations:**
- Only standalone HTML (course-introduction, project-assignment)
- No DocDock equivalents needed

**Recommendation:** For new content, prefer standalone HTML presentations for better control, branding, and consistent user experience.

## Legacy Content Management

Legacy content is preserved in dedicated directories to maintain version history while keeping active content clean.

**Legacy Directories:** (23 files total across 4 directories)

```
content/
├── exercises/server-foundation/legacy/           (10 files)
│   ├── _index.md (weight=99, hidden=true)
│   ├── exercise-1-provisioning-vm-portal.md     # Original v1
│   ├── exercise-2-provisioning-vm-ssh-keys.md
│   ├── exercise-3-automating-nginx-custom-data.md
│   ├── exercise-4-resource-group-az-cli.md
│   ├── exercise-5-provisioning-vm-az-cli.md
│   ├── exercise-6-automating-vm-bash-script.md
│   ├── exercise-1-provisioning-vm-portal-v2.md  # Intermediate v2
│   ├── exercise-2-provisioning-vm-ssh-keys-v2.md
│   └── exercise-3-automating-nginx-custom-data-v2.md
├── infrastructure-fundamentals/
│   ├── compute/legacy/                           (5 files)
│   │   ├── _index.md
│   │   └── [4 v1 articles with spaces in names]
│   ├── network/legacy/                           (7 files)
│   │   ├── _index.md
│   │   └── [6 v1 articles: "What Is A Network - Article.md", etc.]
│   └── storage/legacy/                           (4 files)
│       ├── _index.md
│       └── [3 v1 articles: "What is Persistence - Article.md", etc.]
```

**Legacy Content Characteristics:**
- **Old naming:** Title case with spaces (e.g., "What Is A Network - Article.md")
- **Version suffixes:** -v1, -v2 for iteration tracking
- **Flat structure:** No topic subdirectories
- **Hidden from navigation:** `hidden = true` in frontmatter or legacy _index.md
- **Preserved for reference:** Can compare with new versions, rollback if needed

**Migration Pattern:**
1. **Naming:** Spaces → kebab-case (e.g., "What Is A Network.md" → "what-is-a-network.md")
2. **Structure:** Flat → topic directories (e.g., `exercise-1.md` → `1-portal-interface/1-provisioning-vm-portal.md`)
3. **Content:** Basic → expanded with student-technical-writer style
4. **Language:** English only → bilingual slides added

**Retention Policy:**
- Keep legacy during validation period (content is stable)
- Can remove after new content proven in production
- Git history preserves all versions regardless
- Consider cleanup after one semester of successful use

## Bilingual Content Strategy

The project supports Swedish and English content to serve diverse student populations.

### Full Bilingual Support

**All infrastructure-fundamentals slides** (26 files = 13 bilingual pairs):
- Compute: 4 topics × 2 languages = 8 slide files
- Network: 6 topics × 2 languages = 12 slide files
- Storage: 3 topics × 2 languages = 6 slide files

**Compute standalone presentations** (8 files = 4 bilingual pairs):
- All 4 compute topics have HTML presentations in both languages

**Suffix conventions:**
- `-swe.md` or `-swe.html` for Swedish slide content
- `-sv.md` for Swedish article/document content (project templates)
- No suffix = English (default language)

### Partial Bilingual Support

**Project templates** (2 bilingual pairs):
- `demo-instructions.md` and `demo-instruktioner.md`
- `retrospective-template.md` and `retrospective-template-sv.md`

### English Only

**All articles** (technical content):
- Infrastructure-fundamentals articles
- Exercise instructions
- Setup tutorials
- Cheat sheets

**Rationale:** Technical content in English aligns with:
- Industry standard documentation language
- Azure/GitHub documentation language
- Course focus on technical PM skills in international context

### Presentation Pattern in Articles

Articles display bilingual presentation links prominently:

```markdown
[Watch the presentation](/presentations/infrastructure-fundamentals/compute/1-what-is-a-server.html)

[Se presentationen på svenska](/presentations/infrastructure-fundamentals/compute/1-what-is-a-server-swe.html)

---

[Article content in English follows...]
```

This pattern provides:
- Clear language choice for visual learners
- Accommodation for Swedish-speaking students
- Professional English technical content
- Side-by-side accessibility

## File Naming and Organization Patterns

### Kebab-Case Standard

**All active content uses kebab-case** for URLs and maintainability:

```
✅ Good (active content):
what-is-a-server.md
common-server-roles.md
ip-addresses-and-cidr-ranges.md
provisioning-vm-portal.md
bash-scripting-cheatsheet.md

❌ Legacy (old content):
What Is A Network - Article.md
IP Addresses and CIDR Ranges - Article.md
Network Intermediaries - Article.md
```

### Topic Organization Pattern

**Infrastructure fundamentals use consistent structure:**

```
[topic-pillar]/
└── [number]-[kebab-case-name]/
    ├── [name].md              # Main article (technical content)
    ├── [name]-slides.md       # English DocDock presentation
    └── [name]-slides-swe.md   # Swedish DocDock presentation
```

**Example:**
```
compute/
└── 1-what-is-a-server/
    ├── what-is-a-server.md
    ├── what-is-a-server-slides.md
    └── what-is-a-server-slides-swe.md
```

### Exercise Organization Pattern

**Exercises grouped by interface type** (not by week):

```
server-foundation/
├── 1-portal-interface/          # Manual/Visual
│   ├── 1-provisioning-vm-portal.md
│   ├── 2-provisioning-vm-ssh-keys.md
│   └── 3-automating-nginx-custom-data.md
└── 2-command-line-interface/    # Scriptable/Automated
    ├── 4-resource-group-az-cli.md
    ├── 5-provisioning-vm-az-cli.md
    └── 6-automating-vm-bash-script.md
```

**Pedagogical progression:** Manual → CLI → Automation

### Section Index Pattern

**Every directory has `_index.md`** (29 instances):
- Defines section title, description, weight
- Controls navigation menu appearance
- Can mark sections as `chapter = true` for special styling
- Legacy directories use `weight = 99` and `hidden = true`

## Content Maturity Assessment

### Production Ready (6 sections)

**1. Infrastructure Fundamentals - Compute** (17 files)
- ✅ 4 complete article+slide topics
- ✅ Standalone HTML presentations
- ✅ Sizing/cost article
- ✅ Legacy preserved

**2. Infrastructure Fundamentals - Network** (21 files)
- ✅ 6 complete article+slide topics
- ⚠️ No standalone HTML (DocDock only)
- ✅ Legacy preserved

**3. Infrastructure Fundamentals - Storage** (21 files)
- ✅ 3 complete article+slide topics
- ⚠️ No standalone HTML (DocDock only)
- ✅ Legacy preserved

**4. Exercises - Server Foundation** (19 files)
- ✅ 6 active exercises (3 Portal + 3 CLI)
- ✅ Interface-based organization
- ✅ Legacy with v2 variants
- ✅ Pedagogical progression

**5. Exercises - Network Foundation** (7 files)
- ✅ 3 active exercises (2 Portal + 1 CLI)
- ✅ Interface-based organization
- ✅ Legacy preserved

**6. Exercises - Application Development** (6 files)
- ✅ Complete Flask application lifecycle
- ✅ Local development → Azure deployment → Production
- ✅ Database persistence with SQLAlchemy
- ✅ Azure PostgreSQL provisioning
- ✅ systemd service configuration

**7. Tutorials - Setup** (17 files)
- ✅ Modular guides (Azure, GitHub, Dev, AI Tools)
- ✅ Package manager guidance
- ✅ Complete coverage

**8. Getting Started** (4 files)
- ✅ Course introduction
- ✅ Project assignment
- ✅ Setup overview

### Partially Developed (2 sections)

**9. Cheat Sheets** (4 files)
- ✅ Bash, Cloud-init, Linux
- ⚠️ Could expand: Git, Azure CLI, PostgreSQL

**10. Project Templates** (5 files)
- ✅ Demo instructions (bilingual)
- ✅ Retrospective template (bilingual)
- ⚠️ Minimal but functional

### Placeholder Sections (2 sections)

**11-12. Content Sections** (_index only):
- ⚠️ application (Flask development tutorials)
- ⚠️ it-security (Security concepts, GDPR)

**Status:** Sections created for navigation, awaiting content development

## Theme Overrides

The DocDock theme (2018) requires compatibility patches for Hugo 0.128+. All patches are in `layouts/partials/` as overrides - never edit the theme directly.

**7 Override Files** (28KB total):
1. **custom-head.html** - Google Analytics + robots meta (`noindex,nofollow`)
2. **header.html** - Header compatibility, nil pointer fixes
3. **language-selector.html** - Language switching UI
4. **pagination.html** - Hugo v0.148+ Pager API fix (`.Prev.URL` instead of `.Prev.RelPermalink`)
5. **flex/body-aftercontent.html** - Page layout fixes
6. **flex/scripts.html** - Reveal.js integration, menu collapse prevention
7. **original/scripts.html** - Original theme script references

**Key Patches:**
- Fix nil pointer errors on taxonomy pages
- Replace deprecated `.Site.IsMultiLingual` with `hugo.IsMultilingual`
- Fix pagination for Hugo v0.148+ (Pager API change)
- Prevent menu collapse on active sections
- Add custom analytics and SEO controls

### Building and Testing

```bash
# Local development
hugo server

# Production build
hugo --gc --minify

# Site available at http://localhost:1313
```

### Deployment

Automatic deployment via GitHub Actions when pushing to `main` branch.

**GitHub Pages Settings:**
- Source: GitHub Actions
- Custom domain: devops-pm-25.educ8.se

## Content Migration from 2024

When migrating content from the 2024 project:

### Do
- Use IPL24 exercise progression as a model (Manual → CLI → Automation)
- Preserve pedagogical approach and learning objectives
- Convert PHP/LEMP examples to Python/Flask
- Adapt security concepts and networking theory
- Follow create-exercise template structure

### Don't
- Copy PHP code examples directly
- Reference IPL24 file paths in public content
- Include dates or "next week" references
- **Create cross-references between content** - Never link exercises to other exercises, articles to other articles, or exercises to articles within this project. Each piece must stand alone for maintainability.
- Modify the 2024 reference project

### Content Development Status

**✅ Complete Sections:**
1. **Getting Started** - Course introduction, setup overview, project assignment
2. **Infrastructure Fundamentals - Compute** - 4 topics with articles + bilingual slides + standalone HTML
3. **Infrastructure Fundamentals - Network** - 6 topics with articles + bilingual slides (no standalone HTML yet)
4. **Infrastructure Fundamentals - Storage** - 3 topics with articles + bilingual slides (no standalone HTML yet)
5. **Exercises - Server Foundation** - 6 exercises organized by interface type (Portal/CLI)
6. **Exercises - Network Foundation** - 3 exercises organized by interface type (Portal/CLI)
7. **Exercises - Application Development** - 6 exercises covering full Flask lifecycle:
   - Local development with Flask
   - Basic deployment to Azure VM
   - Database persistence with SQLAlchemy/SQLite
   - Azure PostgreSQL provisioning
   - Deployment with database connection
   - Production deployment with systemd
8. **Tutorials - Setup** - Modular setup guides (Azure, GitHub, Development, AI Tools)

**⚠️ Partially Complete:**
9. **Cheat Sheets** - Bash, Cloud-init, Linux (could expand: Git, Azure CLI, PostgreSQL)
10. **Project Templates** - Demo instructions + retrospectives (bilingual)

**❌ Placeholder Sections (Need Development):**
11. **Application Content** - Flask, Python, web development tutorials
12. **IT Security Content** - Security concepts, GDPR, risk analysis

## Git Workflow

### Before Committing
Always ask before committing or pushing changes.

### Commit Message Format
```
Brief summary of changes

- Detailed point 1
- Detailed point 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Branch Strategy
- `main` - Production, auto-deploys to GitHub Pages
- Feature branches for major changes

## Key Files Reference

| File/Directory | Purpose |
|----------------|---------|
| **Configuration** | |
| `hugo.toml` | Hugo site configuration (baseURL, theme, outputs) |
| `static/CNAME` | Custom domain (devops-pm-25.educ8.se) |
| `static/robots.txt` | Search engine directives (Disallow: /) |
| `.github/workflows/hugo.yaml` | Deployment workflow (Hugo 0.128.0, GitHub Pages) |
| `.gitmodules` | DocDock theme submodule reference |
| **Content** | |
| `content/_index.md` | Homepage |
| `content/getting-started/` | Course introduction (4 files) |
| `content/tutorials/setup/` | Modular setup guides (17 files) |
| `content/infrastructure-fundamentals/` | Core concepts (60 files: compute/network/storage) |
| `content/exercises/server-foundation/` | Server exercises (19 files: 6 active + 10 legacy) |
| `content/exercises/network-foundation/` | Network exercises (9 files: 3 active + 3 legacy) |
| `content/exercises/application-development/` | Flask exercises (7 files: 6 active) |
| `content/cheat-sheets/` | Quick reference materials (4 files) |
| `content/project-templates/` | Demo + retrospective templates (6 files, bilingual) |
| `content/*/legacy/` | Legacy content directories (23 files total) |
| **Presentations** | |
| `static/presentations/` | Standalone HTML presentations (36 files) |
| `static/presentations/swedish-tech-slides.css` | Swedish Tech branding |
| `content/presentations/_index.md` | Presentations index page |
| **Reference Implementations** | |
| `reference/stage-ultimate/` | Production-grade Flask (3 VMs, bastion, Key Vault) |
| `reference/stage-ultimate/infrastructure/provision.sh` | Azure provisioning script |
| `reference/stage-ultimate/ARCHITECTURE.md` | 10 mermaid architecture diagrams |
| `reference/dev-3tier-flask/` | Simplified Flask (1 VM, direct SSH, ~$20/month) |
| `reference/dev-3tier-flask/deploy-all.sh` | One-command deployment |
| `reference/dev-3tier-flask/application/` | Flask app with blueprints (118 tests) |
| `reference/dev-3tier-flask/docs/exercises/` | Phase 2-4 implementation guides |
| `reference/starter-flask/` | Minimal Flask for Container Apps (~$15-20/month) |
| `reference/starter-flask/application/` | Flask app with graceful degradation |
| `reference/starter-flask/deploy/deploy.sh` | Container Apps deployment |
| **Theme Overrides** | |
| `layouts/partials/pagination.html` | Hugo v0.148+ pagination fix |
| `layouts/partials/custom-head.html` | Analytics + robots meta |
| `layouts/partials/header.html` | Header compatibility |
| `layouts/partials/language-selector.html` | Language switching |
| `layouts/partials/flex/` | Flex theme overrides (2 files) |
| `layouts/partials/original/` | Original theme overrides (1 file) |
| `layouts/_default/_markup/render-codeblock-mermaid.html` | Mermaid diagram rendering |
| **Claude Skills & Commands** | |
| `.claude/skills/create-exercise/` | Exercise creation framework (4 files) |
| `.claude/skills/revealjs-skill/` | Swedish Tech presentations (5 files) |
| `.claude/skills/student-technical-writer/` | Student-facing content style (1 file) |
| `.claude/skills/technical-textbook-writer/` | Formal textbook style (4 files) |
| `.claude/commands/check-links.md` | Link checking slash command |
| `.claude/commands/lint-md.md` | Markdown linting slash command |
| **Documentation** | |
| `docs/hugo-github-pages-setup.md` | Complete setup tutorial (34KB) |
| `docs/feedback-system-plan.md` | Feedback feature design (superseded) |
| `docs/feedback-system-solution.md` | Implementation details (current) |
| `docs/project-review-improvements.md` | Project improvement recommendations |
| `docs/planning/book-outline.md` | Book concept notes |
| `CLAUDE.md` | This project documentation file |
| **Theme** | |
| `themes/docdock/` | DocDock theme (git submodule, never edit directly) |

## Course Context

**IPL25 DevOps PM Course:**
- Duration: 6 weeks (4 weeks infrastructure + 2 weeks analysis)
- Focus: IT Project Manager perspective
- Language: Swedish instruction / English technical
- Students orchestrate AI agents to build Azure infrastructure

**Learning Philosophy:**
1. Decision-First Learning - Students make architectural decisions
2. AI-Assisted Implementation - 5 specialized agents as virtual team
3. Progressive Complexity - Binary choices → complex architecture
4. Technical Empathy Building - Hands-on experience builds understanding

## Resources

- **Hugo Documentation:** <https://gohugo.io/documentation/>
- **DocDock Theme:** <https://github.com/vjeantet/hugo-theme-docdock>
- **Reveal.js:** <https://revealjs.com/>
- **GitHub Pages:** <https://docs.github.com/en/pages>
