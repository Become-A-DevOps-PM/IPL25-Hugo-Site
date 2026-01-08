# Architecture Documentation

C4 model architecture documentation for the Flask Three-Tier Application, built with [Structurizr](https://structurizr.com/).

## Quick Start

### Prerequisites

- Docker
- Node.js

### Build Static Site

```bash
./build-site.sh
```

This generates a complete static website in `build/` with your manual diagram layouts preserved. First run installs Puppeteer locally (~150MB).

### View the Site

```bash
cd build && python3 -m http.server 8000
# Open http://localhost:8000
```

### Interactive Editing

To edit diagrams interactively with live preview:

```bash
docker run -it --rm -p 8080:8080 \
  -v "$(pwd):/usr/local/structurizr" \
  structurizr/lite
# Open http://localhost:8080
```

Edit `workspace.dsl`, save, and refresh the browser to see changes. Use the UI to manually arrange diagram elements - layouts are saved to `workspace.json`.

## Architecture Overview

This is a **simplified learning environment** for Flask application development:

```
Internet ──→ VM (nginx:443 → Flask:5001) ──→ PostgreSQL
             Ubuntu 24.04                     Azure PaaS
             snet-default (10.0.0.0/24)       Public access
```

**Key Characteristics:**
- Single VM running nginx and Flask/Gunicorn
- Direct SSH access (no bastion host)
- PostgreSQL with public access
- ~$20/month cost
- 10-15 minute deployment

## Directory Contents

### Source Files (Version Controlled)

| File | Description |
|------|-------------|
| `workspace.dsl` | Structurizr DSL - single source of truth for architecture model |
| `workspace.json` | Workspace with manual layout positions (auto-saved by Structurizr Lite) |
| `docs/` | Markdown documentation imported via `!docs` directive |
| `adrs/` | Architecture Decision Records imported via `!adrs` directive |

### Build Scripts

| File | Description |
|------|-------------|
| `build-site.sh` | One-command build script (recommended) |
| `export-diagrams.js` | Puppeteer script for headless SVG export |
| `postprocess-build.py` | Converts dark theme SVGs to light and applies to build |
| `package.json` | Node.js dependencies (Puppeteer) |

### Generated Files (Git Ignored)

| Directory | Description |
|-----------|-------------|
| `build/` | Static HTML site ready for deployment |
| `diagrams/` | Exported SVG diagrams (intermediate step) |
| `node_modules/` | Puppeteer and dependencies |

### Documentation Files

| File | C4 Level | Description |
|------|----------|-------------|
| `docs/01-overview.md` | - | Project overview and quick links |
| `docs/02-context.md` | C1 | System Context - actors and system boundary |
| `docs/03-containers.md` | C2 | Containers - VM, database, network topology |
| `docs/04-components.md` | C3 | Components - Flask app internals, blueprints |
| `docs/05-deployment.md` | C4 | Deployment - Azure infrastructure details |

## How It Works

### Architecture Model

The `workspace.dsl` file defines the complete C4 model:
- **People** - Application User, Developer
- **Software System** - Flask Three-Tier Application
- **Containers** - Application Server (nginx + Flask), PostgreSQL
- **Components** - Blueprints, services, models, templates
- **Deployment** - Single VM in Azure with public PostgreSQL

### Diagram Views

| View | Key | Description |
|------|-----|-------------|
| System Context | `C1-Context` | High-level actors and system |
| Containers | `C2-Containers` | Technical building blocks |
| Components | `C3-Components` | Flask application internals |
| Deployment | `Deployment` | Simplified Azure infrastructure |

### Build Pipeline

```
workspace.dsl ──► Structurizr Site Generatr ──► build/ (auto-layout)
                                                    │
workspace.json ──► Structurizr Lite ──► Puppeteer ──► diagrams/*.svg
                                                    │
                                    postprocess-build.py
                                                    │
                                                    ▼
                                        build/ (manual layout)
```

1. **Site Generatr** creates static HTML from DSL (uses auto-layout)
2. **Structurizr Lite** loads workspace.json (contains manual layout)
3. **Puppeteer** exports SVGs from Structurizr Lite (preserves manual layout)
4. **Post-processor** replaces auto-layout SVGs with manual layout versions

## Editing Diagrams

### Modify the Model

1. Edit `workspace.dsl` in your editor
2. Run Structurizr Lite to preview changes
3. Arrange elements manually in the UI
4. Click "Save workspace" to update `workspace.json`
5. Run `./build-site.sh` to generate the static site

### DSL Quick Reference

```dsl
# Add a person
person "Name" "Description" "Tag"

# Add a container
container "Name" "Description" "Technology" "Tag"

# Add a relationship
person -> container "Description" "Protocol"

# Create a view
systemContext softwareSystem "ViewKey" "Description" {
    include *
    autoLayout
}
```

See [Structurizr DSL documentation](https://docs.structurizr.com/dsl/language) for full reference.

## Architecture Decision Records

| ADR | Status | Decision |
|-----|--------|----------|
| 0001 | Accepted | Use Pure IaaS Approach |
| 0002 | Accepted | Use Python Flask for Web Application |
| 0003 | Superseded | Use Bastion Host for SSH Access |
| 0004 | Accepted | Use Direct SSH for Simplified Learning Environment |

## Deploying the Site

The `build/` folder is a static site that can be deployed to:

- GitHub Pages
- AWS S3 + CloudFront
- Azure Blob Storage + CDN
- Netlify / Vercel
- Any static web hosting

## Related Documents

- [../PRD.md](../PRD.md) - Product Requirements Document
- [../BRD.md](../BRD.md) - Business Requirements Document
- [../../README.md](../../README.md) - Project quick start guide
- [../../CLAUDE.md](../../CLAUDE.md) - Development reference
