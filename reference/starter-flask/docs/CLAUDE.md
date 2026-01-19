# Docs Directory

Documentation, design decisions, and development history.

## Quick Reference

| Document | Purpose | Read When |
|----------|---------|-----------|
| `architecture.md` | Design patterns and code review | Understanding the codebase |
| `future-improvements.md` | Enhancement ideas | Extending the app |
| `disable-airplay-macos.md` | Port 5000 fix for macOS | Flask won't start |

## Files

### architecture.md

Comprehensive code review covering:
- **Architecture choices**: SSR, monolithic, synchronous, stateless
- **Design patterns**: MVC, Application Factory, Blueprint, PRG
- **Code principles**: Guard clauses, graceful degradation, DRY
- **Patterns NOT used**: Why microservices, APIs, caching are omitted

Read this to understand *why* the code is structured this way.

### future-improvements.md

Optional enhancements for extending the app:
- Logging with Python's logging module
- Type hints for better IDE support
- Health check endpoint
- Model enhancements (`__repr__`, `to_dict`)
- API endpoints
- Input validation with Flask-WTF
- Pagination
- Non-root container user

Each improvement includes code examples.

### disable-airplay-macos.md

macOS Monterey+ uses port 5000 for AirPlay Receiver. This doc explains:
- How to disable AirPlay Receiver (System Settings)
- Alternative: `flask run --port 5001`

## Subdirectory

### planning/

Development history and design documents:

| File | Content |
|------|---------|
| `01-initial-plan.md` | Original minimal Flask (no database) |
| `02-database-plan.md` | Adding Azure SQL with graceful degradation |
| `03-notes-list-plan.md` | Adding the `/notes` list page |
| `04-migrations-design.md` | Flask-Migrate architecture decisions |
| `test-report.md` | Test execution results |

These show the evolution of the application. Useful for understanding design decisions or as templates for planning similar features.

## When to Reference

| Situation | Document |
|-----------|----------|
| Understanding code structure | `architecture.md` |
| Adding new features | `future-improvements.md` |
| Port 5000 in use on Mac | `disable-airplay-macos.md` |
| How was X implemented? | `planning/*.md` |
