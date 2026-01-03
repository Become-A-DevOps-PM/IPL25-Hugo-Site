# Assignments Folder - Claude Code Instructions

## Critical: Student Data Protection

**NEVER commit student reports or submissions to git.**

When working with student reports in this folder:

1. **Check .gitignore** before any git operations
2. **Add new folders** to `.gitignore` immediately when created:
   ```
   assignment-N/student-reports/
   ```
3. **Verify exclusion** before committing:
   ```bash
   git status --ignored
   ```

## Folder Structure

Each assignment has its own folder with student reports as a subfolder:
```
assignment-1/
├── assignment-1.md           # Assignment description (English)
├── assignment-1-swe.md       # Assignment description (Swedish)
├── STUDENT-LIST.md           # Roster with submission status
└── student-reports/          # Student submissions (git-ignored)

assignment-2/
└── ...
```

## When Processing New Assignments

1. After unzipping student submissions, immediately verify the folder is in `.gitignore`
2. If not present, add it before any other operations
3. Run `git status` to confirm files are ignored

## File Naming Convention

All student PDFs should be renamed to:
```
lastname_firstname_originalname.pdf
```

- Prefix in lowercase
- Swedish characters simplified (ö→o, ä→a, å→a)
- Compound surnames joined without spaces

## Reference Documents

| Document | Purpose |
|----------|---------|
| `CLASS-LIST.md` | Master student roster with file prefixes |
| `assignment-N/STUDENT-LIST.md` | Per-assignment submission status |
| `STUDENT-REPORT-PROCESSING.md` | Full workflow documentation |
| `DOCX-TO-PDF-CONVERSION.md` | Technical reference for file conversion |

## Privacy Reminder

Student submissions contain personal data protected under GDPR. Handle accordingly:
- No cloud uploads to unauthorized services
- No sharing outside grading context
- Delete after retention period
