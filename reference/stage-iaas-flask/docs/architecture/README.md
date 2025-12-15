# Architecture Documentation

This folder contains the C4 model architecture documentation for the Webinar Registration Website.

## Files

| File | Description |
|------|-------------|
| [workspace.dsl](workspace.dsl) | Structurizr DSL - single source of truth for all diagrams |
| [C1-context.md](C1-context.md) | Level 1: System Context |
| [C2-containers.md](C2-containers.md) | Level 2: Containers |
| [C3-components.md](C3-components.md) | Level 3: Components |

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
- **Auto-generated legend** - Consistent styling across all diagrams
- **Export options** - PNG, SVG, PlantUML, Mermaid, and more

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

## Related Documents

- [../PRD.md](../PRD.md) - Product Requirements Document
- [../BRD.md](../BRD.md) - Business Requirements Document
