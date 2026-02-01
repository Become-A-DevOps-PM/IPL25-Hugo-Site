# Presentations

This project uses **two distinct presentation systems**. Standalone HTML (this directory) is the primary system.

## 1. Standalone HTML Presentations (Primary — 36 files)

**Location:** `static/presentations/`
**Technology:** Self-contained HTML with CDN-linked reveal.js + Swedish Tech CSS

### File Layout

```
static/presentations/
+-- course-introduction.html              # Course overview
+-- project-assignment.html               # Project requirements
+-- swedish-tech-slides.css               # Swedish Tech branding
+-- lars-appel.jpg                        # Instructor photo
+-- webinar-mockup.png                    # Supporting image
+-- infrastructure-fundamentals/
    +-- compute/                          # 8 files (4 topics x 2 langs)
    +-- network/                          # 12 files (6 topics x 2 langs)
    +-- storage/                          # 6 files (3 topics x 2 langs)
```

### Characteristics

- Swedish Tech branding (blue/yellow color scheme)
- Google Analytics integration (G-50TPJY0FZH)
- `noindex,nofollow` robots meta tag
- Geometric backgrounds and professional styling
- Direct file access, no Hugo processing

### Creating New Presentations

- Use `.claude/skills/revealjs-skill/SKILL.md` as the creation guide
- Output to `static/presentations/[category]/[name].html`
- Create bilingual pairs: `[name].html` (EN) and `[name]-swe.html` (SE)
- Link from articles or presentations index

## 2. DocDock Inline Slides (Legacy/Supplementary — 26 files)

**Location:** `content/` directories with `type = "slide"` in frontmatter
**Technology:** Hugo-processed markdown with DocDock theme + reveal.js

### Coverage

```
infrastructure-fundamentals/
+-- compute/   4 topics x 2 langs = 8 files  (also have standalone HTML)
+-- network/   6 topics x 2 langs = 12 files (DocDock only)
+-- storage/   3 topics x 2 langs = 6 files  (DocDock only)
```

### Characteristics

- Markdown format with TOML frontmatter
- `hidden = true` (not visible in navigation)
- `theme = "sky"` (DocDock default)
- Hugo URL: `/[section]/[topic]/[name]-slides/`
- Bilingual pairs: `-slides.md` (EN) and `-slides-swe.md` (SE)

### DocDock Slide Frontmatter

```toml
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
```

Use `---` for horizontal slides, `___` for vertical slides.

## Linking Pattern

Articles link to **standalone HTML presentations** (not DocDock slides):

```markdown
[Watch the presentation](/presentations/infrastructure-fundamentals/compute/1-what-is-a-server.html)

[Se presentationen på svenska](/presentations/infrastructure-fundamentals/compute/1-what-is-a-server-swe.html)

---

[Article content follows...]
```

## Recommendation

For new content, prefer standalone HTML presentations for better control, branding, and consistent user experience.
