# DevOps PM IPL25 - Hugo Documentation Site

## Project Overview

This repository contains the Hugo-based documentation site for the DevOps PM IPL25 course. The site is deployed to GitHub Pages at <https://devops-pm-25.educ8.se/>.

**Purpose:** Public-facing course documentation, exercises, tutorials, and reveal.js presentations for the IPL25 DevOps Project Management course.

**Technology Stack:**
- Static site generator: Hugo Extended (v0.128.0+)
- Theme: DocDock (with compatibility patches for modern Hugo)
- Deployment: GitHub Actions -> GitHub Pages
- Presentations: Dual system (Standalone HTML + DocDock inline slides)

**Project Statistics:**
- 138 markdown content files (~1MB content)
- 15 active exercises (6 server + 3 network + 6 application)
- 62 presentations total (26 DocDock slides + 36 standalone HTML)
- 23 legacy files in 4 legacy directories
- 8 theme override files (32KB)
- 4 Claude Code skills + 2 custom commands
- 7 reference implementations

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

### Current Development Focus

**Active Course:** ASD (Agile Software Development and Deployment)

- New content defaults to `courses = ["ASD"]`
- SNS content is largely complete

**When in doubt:**

- Exercises in `application-development/` -> ASD
- Exercises in `deployment-foundation/`, `server-foundation/`, `network-foundation/` -> SNS
- Shared content (setup tutorials, cheat sheets) -> `["SNS", "ASD"]`

## Technology Stack (IPL25 - No Alternatives)

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

## Universal Content Rules

- **No cross-references between content** — Never link exercises to other exercises, articles to other articles, or exercises to articles. Each piece must stand alone for maintainability.
- **Exercises follow the create-exercise template** — see `.claude/skills/create-exercise/`
- **Convert LEMP examples to Flask/Python** — IPL25 uses Python exclusively
- **TOML frontmatter** — Hugo uses `+++` delimiters
- **Use 2024 content as source material** — Adapt, don't copy directly

## Directory Overview

Each major directory has its own CLAUDE.md with detailed guidance. Claude Code loads these automatically when working in that path.

| Directory | Purpose | Local CLAUDE.md |
|-----------|---------|-----------------|
| `content/` | Hugo markdown content (articles, exercises, tutorials) | Content authoring guide, naming conventions, bilingual strategy, legacy management, maturity assessment |
| `static/presentations/` | Standalone HTML reveal.js presentations | Dual presentation system, creation guide, Swedish Tech branding, linking patterns |
| `layouts/` | Theme override templates for DocDock | Override file inventory, key patches, build/deploy commands |
| `reference/` | Flask reference implementations (7 projects) | Implementation comparison table, "when to use which" guide |
| `reference/stage-ultimate/` | Production-grade 3-VM Flask deployment | Architecture, components, quick start |
| `.claude/skills/` | Claude Code skills for content creation | (Skills have their own SKILL.md files) |
| `themes/docdock/` | DocDock theme (git submodule) | **Never edit directly** |
| `docs/` | Project documentation and planning | — |

### Other Directory Contents (no local CLAUDE.md)

```
static/                                    (2.4MB)
+-- CNAME                                 # Custom domain: devops-pm-25.educ8.se
+-- robots.txt                            # Search engine directives (Disallow: /)
+-- images/NetworkOverview.png            # Network diagram
+-- js/feedback.js                        # Feedback system (11.4KB)
+-- tools/demo-dice/                      # Presenter-Tron 3000 (index.html + ball assets)
+-- presentations/                        # See static/presentations/CLAUDE.md

docs/                                      (8 files + planning/)
+-- hugo-github-pages-setup.md            # Complete setup tutorial (34KB)
+-- feedback-system-plan.md               # Feedback feature design (superseded)
+-- feedback-system-solution.md           # Implementation details (current)
+-- project-review-improvements.md        # Project improvement recommendations
+-- markdown-lint-report.md               # Lint analysis summary
+-- markdown-lint-report.json             # Lint analysis data
+-- repetition-ipl25-vecka1-notes.md      # Week 1 recap notes
+-- planning/book-outline.md              # Book concept notes

.claude/
+-- settings.local.json                   # Local Claude configuration
+-- skills/                               # 4 skills (see Claude Skills Summary below)
+-- commands/                             # 3 custom slash commands
    +-- check-links.md, lint-md.md, verify-exercise.md
    +-- scripts/crawl-links-local.sh, crawl-links-public.sh
```

## Related Repository - 2024 Reference Project

**Location:** `/Users/lasse/Library/Mobile Documents/iCloud~md~obsidian/Documents/IPL25-Server-Network-Security`

**Important:** This is a READ-ONLY reference. Never modify files in this directory.

The 2024 project contains complete course development materials:

- `course/PROJECT-CHARTER.md` — Course vision and pedagogy (15,000+ words)
- `course/COURSE-STRUCTURE.md` — Capability-based learning organization
- `course/TECH-STACK-DECISION-LOG.md` — Authoritative technology decisions
- `course/onboarding/SETUP-GUIDE.md` — Comprehensive setup guide (1,400+ lines)
- `course/syllabus/` — Assignments and study guides
- `context/concepts/` — 14 formal frameworks (Step Card, Service Trinity, NFR Ladder, Agentic Systems, etc.)
- `context/content/` — 99 markdown files, 26 exercises across 5 tracks (**uses LEMP/PHP — needs conversion to Flask/Python**)
- `.claude/agents/` — 5 specialized AI agent personas (Alva, David, Dennis, Therese, Stig)
- `.claude/skills/create-exercise/` — Exercise creation framework (GUIDE.md, TEMPLATE.md, EXAMPLE.md)
- `infra/` — Bicep templates, cloud-init scripts
- `src/` — Example Flask application code

## Related Repository - DemoDice

**Location:** `/Users/lasse/Developer/IPL_Development/DemoDice`

**Important:** This is a READ-ONLY reference. Never modify files in this directory.

The DemoDice project contains the "Presenter-Tron 3000" — a steampunk-themed lottery ball machine for randomizing presentation order during demos.

**Copied to this project:**
- `DemoDice/src/index-presenter-tron-canvas-sprite.html` -> `static/tools/demo-dice/index.html`
- `DemoDice/src/assets/ball-{1-6}.png` -> `static/tools/demo-dice/assets/`

**Check for updates:** If the DemoDice application is updated, copy updated files from `DemoDice/src/` to `static/tools/demo-dice/`.

## Claude Skills Summary

| Skill | Location | Purpose | When to Use |
|-------|----------|---------|-------------|
| Exercise Creation | `.claude/skills/create-exercise/` | Pedagogical exercise template framework | Creating new exercises |
| Swedish Tech Presentations | `.claude/skills/revealjs-skill/` | Standalone reveal.js with Swedish Tech branding | Creating HTML presentations |
| Student Technical Writer | `.claude/skills/student-technical-writer/` | Student-facing content style, explanatory depth | Writing technical articles |
| Technical Textbook Writer | `.claude/skills/technical-textbook-writer/` | Formal university textbook style | Formal academic documentation |

**Custom Commands:**
- `/check-links` — Link checking
- `/lint-md` — Markdown linting
- `/verify-exercise` — Exercise end-to-end testing

## Git Workflow

### Before Committing
Always ask before committing or pushing changes.

### Commit Message Format
```
Brief summary of changes

- Detailed point 1
- Detailed point 2

Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Branch Strategy
- `main` — Production, auto-deploys to GitHub Pages
- Feature branches for major changes

## Building and Deployment

```bash
# Local development
hugo server                # http://localhost:1313

# Production build
hugo --gc --minify
```

Automatic deployment via GitHub Actions when pushing to `main`. See `layouts/CLAUDE.md` for theme override details.

## Course Context

**IPL25 DevOps PM Course:**
- Duration: 6 weeks (4 weeks infrastructure + 2 weeks analysis)
- Focus: IT Project Manager perspective
- Language: Swedish instruction / English technical
- Students orchestrate AI agents to build Azure infrastructure

**Learning Philosophy:**
1. Decision-First Learning — Students make architectural decisions
2. AI-Assisted Implementation — 5 specialized agents as virtual team
3. Progressive Complexity — Binary choices -> complex architecture
4. Technical Empathy Building — Hands-on experience builds understanding

## Key Files Quick Reference

| File | Purpose |
|------|---------|
| `hugo.toml` | Hugo site configuration |
| `static/CNAME` | Custom domain (devops-pm-25.educ8.se) |
| `.github/workflows/hugo.yaml` | Deployment workflow (Hugo 0.128.0) |
| `.gitmodules` | DocDock theme submodule |
| `content/_index.md` | Homepage |
| `layouts/partials/pagination.html` | Hugo v0.148+ pagination fix |
| `layouts/partials/custom-head.html` | Analytics + robots meta |
| `layouts/_default/_markup/render-codeblock-mermaid.html` | Mermaid rendering |
| `static/presentations/swedish-tech-slides.css` | Swedish Tech branding |
| `static/js/feedback.js` | Feedback system |
| `reference/stage-ultimate/` | Production-grade Flask (3 VMs) |
| `reference/dev-3tier-flask/` | Simplified Flask (1 VM, 118 tests) |
| `reference/starter-flask/` | Minimal Flask for Container Apps |
| `docs/hugo-github-pages-setup.md` | Complete setup tutorial (34KB) |
| `docs/feedback-system-solution.md` | Feedback implementation details |

## Resources

- **Hugo Documentation:** <https://gohugo.io/documentation/>
- **DocDock Theme:** <https://github.com/vjeantet/hugo-theme-docdock>
- **Reveal.js:** <https://revealjs.com/>
- **GitHub Pages:** <https://docs.github.com/en/pages>
