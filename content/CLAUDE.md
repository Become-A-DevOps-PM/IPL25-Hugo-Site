# Content Authoring Guide

All Hugo content lives under `content/`. This file covers structure, naming, organization, bilingual strategy, legacy management, and content maturity.

## Frontmatter Format

Hugo uses TOML frontmatter (`+++`). All content files include course taxonomy:

```toml
+++
title = "Page Title"
program = "IPL"
cohort = "25"
courses = ["SNS"]  # or ["ASD"] or ["SNS", "ASD"]
+++
```

## Content Rules

1. **Exercises follow the create-exercise template** — see `.claude/skills/create-exercise/`
2. **Convert LEMP examples to Flask/Python** — IPL25 uses Python exclusively
3. **Each piece of content must stand alone** — No cross-references between articles, exercises, or other content. This is critical for maintainability.
4. **Use 2024 content as source material** — Adapt, don't copy directly
5. **Don't include dates or "next week" references**
6. **Don't reference IPL24 file paths** in public content

## Directory Structure

```
content/
+-- _index.md                             # Homepage
+-- getting-started/                       (4 files - complete)
|   +-- _index.md, course-introduction.md, project-assignment.md, setup-overview.md
+-- tutorials/                             (17 files - complete)
|   +-- setup/                            # Modular setup guides
|       +-- azure/, development/, github/, ai-tools/
+-- infrastructure-fundamentals/           (60 files - complete)
|   +-- compute/                          # 4 topics + sizing article
|   |   +-- 1-what-is-a-server/          # Article + 2 slides (EN/SE)
|   |   +-- 2-common-server-roles/
|   |   +-- 3-inside-a-physical-server/
|   |   +-- 4-inside-a-virtual-server/
|   |   +-- 5-azure-vm-sizing-and-cost.md
|   |   +-- legacy/                       # 5 v1 files
|   +-- network/                          # 6 topics + legacy/
|   +-- storage/                          # 3 topics + legacy/
+-- exercises/                             (34 files)
|   +-- server-foundation/                # 6 exercises (3 Portal + 3 CLI) + legacy/
|   +-- network-foundation/               # 3 exercises (2 Portal + 1 CLI) + legacy/
|   +-- deployment-foundation/            # 6 exercises (Flask lifecycle)
+-- cheat-sheets/                         (4 files: bash, cloud-init, linux)
+-- project-templates/                     (5 files, bilingual)
+-- presentations/                         (1 file: _index.md linking to standalone HTML)
+-- week-1/, week-2/                      (chapter overview pages)
+-- application/, it-security/            (placeholder sections, _index only)
+-- privacy-feedback.md                    # Privacy policy for feedback system
```

## File Naming Conventions

### Kebab-Case Standard

All active content uses kebab-case:

```
GOOD: what-is-a-server.md, provisioning-vm-portal.md
BAD:  What Is A Network - Article.md  (legacy only)
```

### Topic Organization Pattern

Infrastructure fundamentals use consistent structure:

```
[topic-pillar]/
+-- [number]-[kebab-case-name]/
    +-- [name].md              # Main article
    +-- [name]-slides.md       # English DocDock slides
    +-- [name]-slides-swe.md   # Swedish DocDock slides
```

### Exercise Organization Pattern

Exercises are grouped by interface type (not by week):

```
server-foundation/
+-- 1-portal-interface/          # Manual/Visual (exercises 1-3)
+-- 2-command-line-interface/    # Scriptable/Automated (exercises 4-6)
```

**Pedagogical progression:** Manual -> CLI -> Automation

### Section Index Pattern

Every directory has `_index.md` (29 instances):
- Defines section title, description, weight
- Controls navigation menu appearance
- Can mark sections as `chapter = true` for special styling
- Legacy directories use `weight = 99` and `hidden = true`

## Bilingual Content Strategy

### Suffix Conventions

- `-swe.md` or `-swe.html` for Swedish slide content
- `-sv.md` for Swedish article/document content (project templates)
- No suffix = English (default language)

### What is Bilingual

- **All infrastructure-fundamentals slides** (26 files = 13 bilingual pairs)
- **Compute standalone HTML presentations** (8 files = 4 bilingual pairs)
- **Project templates** (2 bilingual pairs: demo instructions + retrospective)

### English Only

All articles, exercise instructions, setup tutorials, and cheat sheets are English only.

**Rationale:** Technical content in English aligns with industry standards, Azure/GitHub documentation language, and the course focus on technical PM skills in an international context.

### Presentation Links in Articles

Articles display bilingual presentation links prominently:

```markdown
[Watch the presentation](/presentations/infrastructure-fundamentals/compute/1-what-is-a-server.html)

[Se presentationen på svenska](/presentations/infrastructure-fundamentals/compute/1-what-is-a-server-swe.html)

---

[Article content in English follows...]
```

## Legacy Content Management

Legacy content is preserved in `legacy/` subdirectories, hidden from navigation.

### Legacy Directories (23 files across 4 directories)

| Directory | Files | Content |
|-----------|-------|---------|
| `exercises/server-foundation/legacy/` | 10 | v1 originals + v2 intermediates |
| `infrastructure-fundamentals/compute/legacy/` | 5 | v1 articles (spaces in names) |
| `infrastructure-fundamentals/network/legacy/` | 7 | v1 articles |
| `infrastructure-fundamentals/storage/legacy/` | 4 | v1 articles |

### Legacy Characteristics

- **Old naming:** Title case with spaces (e.g., "What Is A Network - Article.md")
- **Version suffixes:** -v1, -v2 for iteration tracking
- **Flat structure:** No topic subdirectories
- **Hidden:** `hidden = true` in frontmatter or `_index.md`

### Migration Pattern (Legacy -> Active)

1. **Naming:** Spaces -> kebab-case
2. **Structure:** Flat -> topic directories
3. **Content:** Basic -> expanded with student-technical-writer style
4. **Language:** English only -> bilingual slides added

### Retention Policy

- Keep legacy during validation period
- Can remove after new content proven in production
- Git history preserves all versions regardless
- Consider cleanup after one semester of successful use

## Content Maturity Assessment

| Section | Status | Files | Notes |
|---------|--------|-------|-------|
| Getting Started | Complete | 4 | Course intro, setup overview, project |
| Infra - Compute | Complete | 17 | 4 topics + sizing + standalone HTML + legacy |
| Infra - Network | Complete | 21 | 6 topics, no standalone HTML yet |
| Infra - Storage | Complete | 21 | 3 topics, no standalone HTML yet |
| Exercises - Server | Complete | 19 | 6 active + 10 legacy |
| Exercises - Network | Complete | 7 | 3 active + 3 legacy |
| Exercises - Deployment | Complete | 6 | Full Flask lifecycle |
| Tutorials - Setup | Complete | 17 | Azure, GitHub, Dev, AI Tools |
| Cheat Sheets | Partial | 4 | Could expand: Git, Azure CLI, PostgreSQL |
| Project Templates | Partial | 5 | Demo + retrospective (bilingual) |
| Application | Placeholder | 1 | Flask/Python tutorials needed |
| IT Security | Placeholder | 1 | Security concepts, GDPR needed |

## Content Migration from 2024

### Do

- Use IPL24 exercise progression as a model (Manual -> CLI -> Automation)
- Preserve pedagogical approach and learning objectives
- Convert PHP/LEMP examples to Python/Flask
- Adapt security concepts and networking theory
- Follow create-exercise template structure

### Don't

- Copy PHP code examples directly
- Reference IPL24 file paths in public content
- Include dates or "next week" references
- Create cross-references between content
- Modify the 2024 reference project
