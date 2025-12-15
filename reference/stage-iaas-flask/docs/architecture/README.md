# Architecture Documentation

This folder contains the C4 model architecture documentation for the Webinar Registration Website.

## Files

| File | Description |
|------|-------------|
| [workspace.dsl](workspace.dsl) | Structurizr DSL - single source of truth for all diagrams |
| [workspace.json](workspace.json) | Compiled workspace with layout information |
| [docs/](docs/) | Documentation imported by Structurizr via `!docs` |
| [adrs/](adrs/) | Architecture Decision Records imported via `!adrs` |

### Documentation Files

| File | Description |
|------|-------------|
| [docs/01-overview.md](docs/01-overview.md) | Project overview and quick links |
| [docs/02-context.md](docs/02-context.md) | Level 1: System Context |
| [docs/03-containers.md](docs/03-containers.md) | Level 2: Containers |
| [docs/04-components.md](docs/04-components.md) | Level 3: Components |
| [docs/05-deployment.md](docs/05-deployment.md) | Azure IaaS Deployment |

## Viewing Diagrams with Structurizr Lite

### Prerequisites

- Docker installed on your machine

### Quick Start

Run the following command from the project root:

```bash
docker run -it --rm -p 8080:8080 \
  -v "$(pwd)/reference/stage-iaas-flask/docs/architecture:/usr/local/structurizr" \
  structurizr/lite
```

Or if you're already in the architecture folder:

```bash
docker run -it --rm -p 8080:8080 \
  -v "$(pwd):/usr/local/structurizr" \
  structurizr/lite
```

Then open your browser at: **http://localhost:8080**

### What You'll See

Structurizr Lite will render the `workspace.dsl` file and provide:

- **Interactive diagrams** - Click to navigate, zoom in/out
- **Multiple views** - Context, Container, Component, and Deployment diagrams
- **Documentation tab** - Your markdown docs with embedded diagrams
- **Decisions tab** - Architecture Decision Records (ADRs)
- **Auto-generated legend** - Consistent styling across all diagrams

### Making Changes

1. Edit `workspace.dsl` in your editor
2. Save the file
3. Refresh your browser to see the changes

## Exporting Diagrams

From the Structurizr Lite UI, you can export diagrams as:

- PNG/SVG images
- PlantUML source
- Mermaid source
- DOT (Graphviz)

This allows you to include rendered diagrams in other documentation or presentations.

### Generating a Static Website

To export the entire workspace (diagrams, documentation, ADRs) as a static HTML website, use [Structurizr Site Generatr](https://github.com/avisi-cloud/structurizr-site-generatr).

#### Prerequisites

- Docker installed on your machine

#### Generate the Site

**Option A: Using workspace.json (preserves manual layout)**

If you've manually arranged diagrams in Structurizr Lite, use the JSON file to preserve your layout:

```bash
docker run --rm -v "$(pwd):/workspace" \
  ghcr.io/avisi-cloud/structurizr-site-generatr \
  generate-site \
  --workspace-file /workspace/workspace.json \
  --output-dir /workspace/build
```

**Option B: Using workspace.dsl (auto-layout)**

If you prefer auto-layout or haven't customized the diagram positions:

```bash
docker run --rm -v "$(pwd):/workspace" \
  ghcr.io/avisi-cloud/structurizr-site-generatr \
  generate-site \
  --workspace-file /workspace/workspace.dsl \
  --output-dir /workspace/build
```

**From the project root** (using JSON for manual layout):

```bash
docker run --rm -v "$(pwd)/reference/stage-iaas-flask/docs/architecture:/workspace" \
  ghcr.io/avisi-cloud/structurizr-site-generatr \
  generate-site \
  --workspace-file /workspace/workspace.json \
  --output-dir /workspace/build
```

The generated site will be in the `build/` folder.

> **Note**: The `workspace.json` file is updated when you save from Structurizr Lite (click "Save workspace" in the UI). Always save after making layout changes to keep the JSON in sync.

#### View the Generated Site

```bash
# Simple Python HTTP server
cd build
python3 -m http.server 8000
# Open http://localhost:8000
```

#### What's Included

The generated static site includes:

- All diagrams in SVG and PNG format
- Documentation pages (from `docs/` folder)
- Architecture Decision Records (from `adrs/` folder)
- Interactive model explorer
- Downloadable PlantUML sources

#### Deploying

The `build/` folder can be deployed to:

- GitHub Pages
- AWS S3 + CloudFront
- Azure Blob Storage + CDN
- Any static web hosting

## Related Documents

- [../PRD.md](../PRD.md) - Product Requirements Document
- [../BRD.md](../BRD.md) - Business Requirements Document
