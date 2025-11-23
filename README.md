# DevOps PM IPL25

Documentation site for DevOps PM IPL25, built with Hugo and the DocDock theme.

## Local Development

### Prerequisites

- [Hugo Extended](https://gohugo.io/installation/) (v0.128.0 or later)

### Setup

```bash
# Clone with submodules
git clone --recurse-submodules <repo-url>

# Or if already cloned, initialize submodules
git submodule update --init --recursive

# Start development server
hugo server
```

The site will be available at `http://localhost:1313/`

## Creating Content

### Documentation Pages

Create markdown files in the `content/` directory:

```bash
hugo new getting-started/new-page.md
```

### Reveal.js Presentations

Create slide presentations using the `type = "slide"` front matter:

```markdown
+++
title = "My Presentation"
type = "slide"
theme = "league"

[revealOptions]
transition = "convex"
controls = true
progress = true
+++

# Slide 1

Content here

---

# Slide 2

Use `---` for horizontal slides
Use `___` for vertical slides
```

## Deployment

The site automatically deploys to GitHub Pages when changes are pushed to the `main` branch.

**Site URL:** https://devops-pm-25.educ8.se/

### GitHub Pages Setup

1. Go to repository Settings > Pages
2. Set Source to "GitHub Actions"

## Theme

This site uses the [DocDock theme](https://github.com/vjeantet/hugo-theme-docdock) with patches for Hugo 0.128+ compatibility.
