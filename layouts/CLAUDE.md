# Theme Overrides (layouts/)

The DocDock theme (2018) requires compatibility patches for Hugo 0.128+. All patches live here as overrides — **never edit `themes/docdock/` directly**.

## Override Files (7 files, 28KB)

| File | Purpose |
|------|---------|
| `partials/custom-head.html` | Google Analytics (G-50TPJY0FZH) + `noindex,nofollow` robots meta |
| `partials/header.html` | Header compatibility, nil pointer fixes |
| `partials/language-selector.html` | Language switching UI |
| `partials/pagination.html` | Hugo v0.148+ Pager API fix (`.Prev.URL` instead of `.Prev.RelPermalink`) |
| `partials/flex/body-aftercontent.html` | Page layout fixes |
| `partials/flex/scripts.html` | Reveal.js integration, menu collapse prevention |
| `partials/original/scripts.html` | Original theme script references |
| `_default/_markup/render-codeblock-mermaid.html` | Mermaid diagram rendering |

## Key Patches Applied

- Fix nil pointer errors on taxonomy pages
- Replace deprecated `.Site.IsMultiLingual` with `hugo.IsMultilingual`
- Fix pagination for Hugo v0.148+ (Pager API change: `.Prev.RelPermalink` -> `.Prev.URL`)
- Prevent menu collapse on active sections
- Add custom analytics and SEO controls

## Building and Testing

```bash
# Local development
hugo server
# Site available at http://localhost:1313

# Production build
hugo --gc --minify
```

## Deployment

Automatic deployment via GitHub Actions when pushing to `main` branch.

- **Workflow:** `.github/workflows/hugo.yaml`
- **Hugo version:** 0.128.0 (Extended)
- **Source:** GitHub Actions
- **Custom domain:** devops-pm-25.educ8.se

## Rules

- **Never edit `themes/docdock/`** — it is a git submodule
- All overrides go in `layouts/partials/` matching the theme's directory structure
- Test locally with `hugo server` after any layout change
- Theme submodule is referenced in `.gitmodules`
