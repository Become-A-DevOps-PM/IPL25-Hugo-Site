# Plan: Enhance Create-Exercise Skill with Technology Profiles

> **STATUS:** PLANNED - Ready for implementation when needed
> **Created:** 2025-12-08
> **Context:** Discussion about making the create-exercise skill technology-agnostic

---

## Background and Motivation

### The Problem

The `create-exercise` skill at `.claude/skills/create-exercise/` currently has **hardcoded C#/.NET examples** throughout its documentation files. This is problematic because:

1. **IPL25 uses Python/Flask** - The course technology stack is Python, not C#
2. **Reusability is limited** - The skill can't easily be used for other technology stacks
3. **Future courses may use different stacks** - AWS instead of Azure, different languages, etc.

### The Constraint

We want to **preserve the C# content** because:
- The skill should be reusable across different projects
- Future courses might use C#/.NET
- The C# examples are well-written and demonstrate the template structure correctly

### The Solution

Create a **profile-based system** where:
- Core skill files remain technology-agnostic (structure, formatting, workflow)
- Technology-specific patterns live in separate profile files
- The skill selects the appropriate profile based on project context

---

## Current Skill Structure

```
.claude/skills/create-exercise/
├── SKILL.md      (6.8KB)  - Main skill definition, workflow, quality checklist
├── GUIDE.md      (14.6KB) - Template philosophy, formatting rules, writing guidelines
├── TEMPLATE.md   (8.8KB)  - Exercise structure template with placeholders
└── EXAMPLE.md    (12KB)   - Complete C# Repository Pattern example
```

### Files with Hardcoded C#/.NET Content

| File | C# Content | What Needs to Change |
|------|------------|---------------------|
| `EXAMPLE.md` | 100% C# code | Move entirely to profile |
| `TEMPLATE.md` | C# snippets in placeholders | Make language-agnostic |
| `GUIDE.md` | C# examples in formatting demos | Replace with generic or multiple examples |
| `SKILL.md` | References `csharp` in code blocks | Add profile selection logic |

---

## Proposed New Structure

```
.claude/skills/create-exercise/
├── SKILL.md              # Updated: Add profile selection step
├── GUIDE.md              # Updated: Technology-agnostic formatting rules
├── TEMPLATE.md           # Updated: Generic placeholders
├── profiles/
│   ├── README.md         # How profiles work, available options
│   ├── csharp-dotnet-azure.md    # C#/.NET + Azure (current EXAMPLE.md content)
│   ├── python-flask-azure.md     # Python/Flask + Azure (NEW)
│   └── python-flask-aws.md       # Python/Flask + AWS (FUTURE)
└── examples/             # Optional: Full exercise examples per profile
    ├── csharp-repository-pattern.md
    └── python-repository-pattern.md
```

### Naming Convention for Profiles

Format: `{language}-{framework}-{cloud}.md`

Examples:
- `csharp-dotnet-azure.md` - C#/.NET Core on Azure
- `python-flask-azure.md` - Python/Flask on Azure
- `python-flask-aws.md` - Python/Flask on AWS
- `python-django-azure.md` - Python/Django on Azure (future)
- `typescript-node-azure.md` - TypeScript/Node.js on Azure (future)

---

## Implementation Plan

### Phase 1: Restructure Without Breaking Changes

**Goal:** Create the new structure while preserving all existing content.

#### Step 1.1: Create profiles directory

```bash
mkdir -p .claude/skills/create-exercise/profiles
```

#### Step 1.2: Create profiles/README.md

```markdown
# Technology Profiles for Create-Exercise Skill

This directory contains technology-specific patterns and examples for creating
exercises. Each profile defines:

- Technology stack (language, framework, database, cloud)
- Code block language identifiers
- Common code patterns (models, repositories, routes, tests)
- File path conventions
- Technology-specific common mistakes
- Infrastructure patterns

## Available Profiles

| Profile | Language | Framework | Cloud | Status |
|---------|----------|-----------|-------|--------|
| csharp-dotnet-azure.md | C# | .NET Core | Azure | ✅ Complete |
| python-flask-azure.md | Python | Flask | Azure | ✅ Complete |
| python-flask-aws.md | Python | Flask | AWS | 📋 Planned |

## How to Use

1. Check the project's CLAUDE.md for technology stack
2. Load the matching profile
3. Use the profile's patterns when creating exercises

## Profile Structure

Each profile contains:

1. **Technology Stack** - Versions and components
2. **Code Block Identifiers** - Language tags for code blocks
3. **Example Patterns** - Model, repository, route, test examples
4. **File Conventions** - Where files should be created
5. **Common Mistakes** - Technology-specific pitfalls
6. **Infrastructure Patterns** - Cloud deployment commands
```

#### Step 1.3: Move EXAMPLE.md to csharp-dotnet-azure.md

1. Copy `EXAMPLE.md` to `profiles/csharp-dotnet-azure.md`
2. Add profile header with metadata
3. Keep `EXAMPLE.md` temporarily for backwards compatibility
4. Add deprecation notice to old `EXAMPLE.md`

#### Step 1.4: Create python-flask-azure.md profile

Create new profile with Python/Flask patterns based on:
- The reference implementation at `reference/stage-ultimate/`
- IPL25 course technology stack from CLAUDE.md
- Equivalent patterns to the C# profile

---

### Phase 2: Update Core Files

**Goal:** Make SKILL.md, GUIDE.md, and TEMPLATE.md technology-agnostic.

#### Step 2.1: Update SKILL.md

Add new section after "Critical: Before Starting":

```markdown
## Technology Profile Selection

Before creating an exercise, determine the technology stack:

### Step 0: Load Technology Profile

1. **Check project context:**
   - Read the project's CLAUDE.md for technology stack
   - Look for existing exercises to match style
   - Ask user if unclear

2. **Load the appropriate profile** from `profiles/` directory:
   - `csharp-dotnet-azure.md` - C#/.NET Core + Azure
   - `python-flask-azure.md` - Python/Flask + Azure
   - `python-flask-aws.md` - Python/Flask + AWS

3. **Use profile patterns** for:
   - Code examples and syntax
   - File path conventions
   - Common mistakes sections
   - Test commands
   - Infrastructure references

If no profile matches the project stack, ask the user which to use
or offer to create exercises with generic placeholders.
```

Update the "Exercise Creation Workflow" section:

```markdown
### Step 1: Gather Requirements

Ask the user for:

- Exercise topic/title
- **Technology profile** (or auto-detect from project)
- Target audience level (beginner/intermediate/advanced)
- Key concepts to cover
- Desired output directory
```

Update the "Common Language Identifiers" section to reference profiles:

```markdown
### Code Block Language Identifiers

See the active technology profile for specific identifiers. Common ones:

**General:**
- `bash` - Shell commands
- `yaml` - Configuration files
- `json` - JSON data
- `markdown` - Markdown examples
- `sql` - Database queries

**Profile-specific:** See `profiles/{profile-name}.md`
```

#### Step 2.2: Update GUIDE.md

**Changes needed:**

1. **Remove C#-specific examples** from formatting demonstrations
2. **Replace with generic or multi-language examples**
3. **Add reference to profiles** for technology-specific patterns

Example change in "Complete Example" section:

```markdown
## Complete Example

See the `profiles/` directory for complete technology-specific examples:

- `profiles/csharp-dotnet-azure.md` - C#/.NET example
- `profiles/python-flask-azure.md` - Python/Flask example

Below is a generic structure showing the template format:
```

Update the "Common Language Identifiers for Code Blocks" section:

```markdown
### Common Language Identifiers for Code Blocks

**Universal identifiers:**
- `bash` - Shell commands (all platforms)
- `yaml` - YAML configuration
- `json` - JSON data
- `markdown` - Markdown examples
- `sql` - SQL queries
- `html` - HTML/templates

**Language-specific:** Refer to active profile for:
- Primary language identifier (e.g., `python`, `csharp`)
- Framework-specific identifiers
- Template language identifiers
```

#### Step 2.3: Update TEMPLATE.md

**Changes needed:**

1. Replace `csharp` with `{language}` placeholder
2. Replace `.cs` file extensions with `{ext}` placeholder
3. Replace `namespace YourApp...` with generic comments
4. Add profile reference at top

Add header:

```markdown
# Exercise Template

> **Note:** This template shows the structure and formatting rules.
> For technology-specific code patterns, see the appropriate profile
> in the `profiles/` directory.
```

Change code block examples from:

```markdown
   ```csharp
   namespace YourApp.Models;

   public class ExampleClass
   {
       // This property stores [purpose]
       public string Name { get; set; }
   }
   ```
```

To:

```markdown
   ```{language}
   // {file_description}
   // See active profile for language-specific patterns

   // Example structure:
   // - Define the class/module
   // - Add properties/attributes
   // - Include comments explaining purpose
   ```
```

---

### Phase 3: Create Python/Flask/Azure Profile

**Goal:** Create a complete profile for IPL25's technology stack.

#### Step 3.1: Profile Header

```markdown
# Python/Flask + Azure Profile

> **Use this profile for:** IPL25 DevOps PM course and similar Python/Flask projects on Azure

## Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Language | Python | 3.11+ |
| Web Framework | Flask | 2.3+ |
| ORM | SQLAlchemy / Flask-SQLAlchemy | 2.x |
| Database (prod) | PostgreSQL (Azure Flexible Server) | 14+ |
| Database (dev) | SQLite | 3.x |
| WSGI Server | Gunicorn | 21+ |
| Web Server | nginx | 1.24+ |
| Cloud | Azure | - |
| OS | Ubuntu | 24.04 LTS |
```

#### Step 3.2: Code Block Identifiers

```markdown
## Code Block Language Identifiers

| Identifier | Use For |
|------------|---------|
| `python` | Python source code |
| `bash` | Shell commands, scripts |
| `html` | Jinja2 templates |
| `css` | Stylesheets |
| `yaml` | Cloud-init, GitHub Actions |
| `toml` | pyproject.toml, configuration |
| `sql` | Database queries |
| `json` | JSON data, API responses |
| `ini` | Configuration files |
```

#### Step 3.3: Example Patterns

Include complete, copy-paste-ready examples for:

1. **Model Definition** (SQLAlchemy)
2. **Repository Pattern** (if applicable)
3. **Route/Blueprint Definition**
4. **Form Handling** (WTForms)
5. **Configuration Pattern** (Flask config classes)
6. **Test Examples** (pytest)
7. **Application Factory** (create_app pattern)

#### Step 3.4: File Path Conventions

```markdown
## File Path Conventions

| Purpose | Path | Example |
|---------|------|---------|
| Application factory | `app.py` | `> app.py` |
| Models | `models.py` | `> models.py` |
| Routes | `routes.py` | `> routes.py` |
| Configuration | `config.py` | `> config.py` |
| Forms | `forms.py` | `> forms.py` |
| Validators | `validators.py` | `> validators.py` |
| Templates | `templates/{name}.html` | `> templates/contact.html` |
| Static files | `static/{type}/{file}` | `> static/css/style.css` |
| Requirements | `requirements.txt` | `> requirements.txt` |
| Tests | `tests/test_{module}.py` | `> tests/test_routes.py` |
```

#### Step 3.5: Common Mistakes (Python-specific)

```markdown
## Common Mistakes

### Environment Issues
- **Forgetting to activate venv** - Always run `source venv/bin/activate` first
- **Missing dependencies** - Run `pip install -r requirements.txt` after pulling changes
- **Wrong Python version** - Use `python3` explicitly, not `python`

### Database Issues
- **Forgetting db.session.commit()** - Changes aren't persisted without commit
- **Not handling None** - `query.get(id)` returns `None` if not found
- **Circular imports** - Import models inside functions if needed

### Flask Issues
- **Missing return statement** - All routes must return a response
- **Wrong template path** - Templates are relative to `templates/` directory
- **Debug mode in production** - Never use `debug=True` in production

### Azure Issues
- **Firewall blocking connections** - Add client IP to PostgreSQL firewall
- **Wrong connection string format** - PostgreSQL uses `postgresql://` not `postgres://`
- **Missing managed identity permissions** - Grant Key Vault access to VM identity
```

#### Step 3.6: Infrastructure Patterns

```markdown
## Infrastructure Patterns (Azure)

### Local Development
```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run development server
flask --app app run --port 5001 --debug
```

### Azure VM Deployment
```bash
# Provision VM
az vm create \
    --resource-group $RG_NAME \
    --name flask-app-vm \
    --image Ubuntu2404 \
    --size Standard_B1s \
    --admin-username azureuser \
    --generate-ssh-keys

# Connect via SSH
ssh azureuser@<public-ip>
```

### Azure PostgreSQL
```bash
# Create PostgreSQL server
az postgres flexible-server create \
    --resource-group $RG_NAME \
    --name $DB_SERVER_NAME \
    --location swedencentral \
    --sku-name Standard_B1ms \
    --version 17 \
    --admin-user flaskadmin \
    --admin-password "$DB_PASSWORD"
```

### systemd Service
```ini
[Unit]
Description=Flask Application
After=network.target

[Service]
User=www-data
WorkingDirectory=/opt/flask-app
Environment="PATH=/opt/flask-app/venv/bin"
ExecStart=/opt/flask-app/venv/bin/gunicorn --workers 2 --bind 127.0.0.1:5001 wsgi:app

[Install]
WantedBy=multi-user.target
```
```

---

### Phase 4: Validation and Testing

**Goal:** Ensure the updated skill works correctly.

#### Step 4.1: Test with Python/Flask exercise

1. Invoke the skill to create a Python/Flask exercise
2. Verify it selects the correct profile
3. Check generated code matches Python conventions
4. Ensure formatting rules are followed

#### Step 4.2: Test with C#/.NET exercise

1. Invoke the skill specifying C#/.NET
2. Verify it uses the csharp-dotnet-azure profile
3. Check backwards compatibility with existing workflow

#### Step 4.3: Update project-review-improvements.md

1. Mark "Convert create-exercise skill to Flask" as completed
2. Update the priority matrix
3. Document the new profile system

---

### Phase 5: Documentation Updates

**Goal:** Update all references to the new system.

#### Step 5.1: Update CLAUDE.md

Add to the Claude Skills section:

```markdown
**1. Exercise Creation (`create-exercise/`):**
- Framework for creating consistent educational exercises
- **Technology profiles:** Supports multiple stacks (Python/Flask, C#/.NET)
- Files: SKILL.md, GUIDE.md, TEMPLATE.md, profiles/
- Use: `/skill create-exercise` when creating new exercises
```

#### Step 5.2: Update docs/project-review-improvements.md

Mark the skill conversion as completed and describe the solution.

---

## File-by-File Change Summary

| File | Action | Changes |
|------|--------|---------|
| `SKILL.md` | Update | Add profile selection step, update workflow |
| `GUIDE.md` | Update | Remove C#-specific examples, add profile references |
| `TEMPLATE.md` | Update | Use generic placeholders, add profile note |
| `EXAMPLE.md` | Deprecate | Add notice pointing to profiles |
| `profiles/README.md` | Create | Profile system documentation |
| `profiles/csharp-dotnet-azure.md` | Create | Move content from EXAMPLE.md, add metadata |
| `profiles/python-flask-azure.md` | Create | New profile for IPL25 stack |

---

## Estimated Effort

| Phase | Tasks | Time Estimate |
|-------|-------|---------------|
| Phase 1 | Restructure, create profiles dir | 1 hour |
| Phase 2 | Update core files | 2 hours |
| Phase 3 | Create Python/Flask profile | 2-3 hours |
| Phase 4 | Validation and testing | 1 hour |
| Phase 5 | Documentation updates | 30 minutes |
| **Total** | | **6-7 hours** |

---

## Success Criteria

- [ ] Skill can create exercises for Python/Flask/Azure projects
- [ ] Skill can still create exercises for C#/.NET/Azure projects
- [ ] Profile selection is automatic based on project context
- [ ] Core files (SKILL.md, GUIDE.md, TEMPLATE.md) are technology-agnostic
- [ ] All formatting and quality rules still apply regardless of technology
- [ ] New profiles can be added without modifying core files
- [ ] Documentation is updated to reflect new system

---

## Future Considerations

### Additional Profiles to Consider

- `python-django-azure.md` - Django framework
- `python-flask-aws.md` - AWS deployment
- `typescript-node-azure.md` - Node.js backend
- `java-spring-azure.md` - Spring Boot

### Profile Inheritance (Advanced)

Consider a system where profiles can inherit from base profiles:

```
profiles/
├── _base-azure.md         # Common Azure patterns
├── _base-aws.md           # Common AWS patterns
├── python-flask-azure.md  # Inherits from _base-azure.md
└── python-flask-aws.md    # Inherits from _base-aws.md
```

This would reduce duplication as more profiles are added.

### Profile Auto-Detection

Could enhance SKILL.md to auto-detect the profile based on:
- Presence of `requirements.txt` vs `*.csproj`
- CLAUDE.md technology stack section
- Existing file extensions in the project

---

## References

- Current skill location: `.claude/skills/create-exercise/`
- Reference implementation: `reference/stage-ultimate/` (Python/Flask/Azure example)
- IPL25 tech stack: See CLAUDE.md "Technology Stack" section
- Original discussion: 2025-12-08 session about skill reusability

---

*Plan created: 2025-12-08*
*Ready for implementation when prioritized*
