# Student Report Processing Workflow

This document describes the workflow for processing student report submissions from Google Classroom, including manual steps and automated processing with Claude Code.

## Overview

Student assignments submitted via Google Classroom arrive in various formats and naming conventions. This workflow standardizes the files for easier grading and record-keeping.

**Goals:**
- Consistent file naming: `lastname_firstname_originalname.pdf`
- All files in PDF format
- Remove duplicate submissions (keep best/latest version)
- Track submission status per student

## CRITICAL: Git and Privacy Protection

> **Student reports must NEVER be committed to git.**

Student submissions contain personal data protected under GDPR. Before processing any assignment:

### Immediate Actions After Creating Report Folder

1. **Verify `.gitignore` exists** in `docs/assignments/`
2. **Add the new folder** to `.gitignore` immediately:
   ```
   assignment-N/student-reports/
   ```
3. **Confirm exclusion** before any git operations:
   ```bash
   git status --ignored
   ```

### Privacy Requirements

| Requirement | Action |
|-------------|--------|
| No version control | Add to `.gitignore` before processing |
| No cloud uploads | Use only local tools for conversion |
| No unauthorized sharing | Keep within grading context |
| Retention limits | Delete after course completion |

### Verification Command

```bash
# Run this before any git commit in the assignments folder
git status --ignored | grep student-reports
```

If student report folders appear in `git status` (not in ignored section), **STOP** and fix `.gitignore` first.

## Step 1: Manual Download from Google Classroom

**Performed by:** Instructor

1. Open Google Classroom
2. Navigate to the assignment
3. Click on "Student Work"
4. Select all submissions
5. Download as ZIP file (Google Classroom bundles all submissions)
6. Unzip to target directory:
   ```
   docs/assignments/assignment-N/student-reports/
   ```

**Result:** A directory containing student submissions with inconsistent naming:
- Some include student names
- Some have generic names like "Rapport.pdf" or "Inlämningsuppgift.pdf"
- Mixed formats: PDF, DOCX (from Google Docs export or Word)
- Duplicate submissions with `(1)`, `(2)` suffixes

## Step 2: Automated Renaming (Claude Code)

**Performed by:** Claude Code with subagents

### Process

1. **List all PDF files** in the directory
2. **Spawn parallel subagents** - one per PDF file
3. Each subagent:
   - Reads the PDF content
   - Extracts student name from document (title page, headers, signatures)
   - Renames file to `lastname_firstname_originalname.pdf` (lowercase prefix)
4. Results collected and reported

### Command Pattern

```
# User prompt:
"Go through all PDFs in [directory] and rename the file so the student name
(lastname_firstname) is used as prefix. Give a subagent the task for one PDF
in order to parallelize."
```

### Handling Edge Cases

- **Name not found in PDF:** Report file for manual identification
- **Name in filename only:** Cross-reference with class roster
- **Compound surnames:** Combine without spaces (e.g., `martinezlofgren_anna-isabel_`)
- **Swedish characters:** Simplified in prefix (ö→o, ä→a, å→a, é→e)

### Why Subagents? Context Isolation Pattern

Using one subagent per PDF file provides critical benefits:

| Benefit | Explanation |
|---------|-------------|
| **Context isolation** | Each agent only loads one PDF into its context, avoiding overflow when processing many files |
| **Parallel execution** | All 35 PDFs processed simultaneously instead of sequentially |
| **Failure isolation** | If one PDF fails (too large, corrupted), others still complete |
| **Memory efficiency** | Each agent's context is released after completing its task |

**Problem solved:** Reading 35 PDFs (some 15+ MB) sequentially would overflow the context window. The main agent would lose early file contents before finishing.

**How it works:**
1. Main agent spawns 35 parallel subagents
2. Each subagent reads only its assigned PDF
3. Subagent extracts name, renames file, reports result
4. Main agent collects all results (just text summaries, not PDF contents)

**Handling failures:**
- If a PDF is too large (>15MB), the subagent may fail with API size error
- Failed files are reported back and handled manually or with alternative methods
- Example: One 17.9MB file failed subagent analysis, resolved via MD5 comparison

## Step 3: Cross-Reference with Class Roster

**Performed by:** Claude Code using `CLASS-LIST.md`

When PDFs cannot be identified from content alone:

1. Reference `docs/assignments/CLASS-LIST.md` for all student names and prefixes
2. Claude Code matches unidentified files by:
   - Partial name matches in filename
   - First name only (matched to roster for surname)
   - Abbreviations (e.g., "Firstname L" → Firstname Lastname)
3. Remaining unidentified files flagged for manual review

### Class Roster Format

```
Firstname Lastname Campus/Class
Example Student IPL25 Campus Mölndal
Another Student IPL25 Campus Mölndal
...
```

## Step 4: Convert Non-PDF Files

**Performed by:** Claude Code using AppleScript + Microsoft Word

### Supported Conversions

| Source Format | Method |
|---------------|--------|
| .docx (Word) | AppleScript → Microsoft Word → PDF export |
| .docx (Google Docs export) | Same as above |

### Conversion Command

```bash
osascript <<'EOF'
set inputFile to "/path/to/input.docx"
set outputFile to "/path/to/lastname_firstname_originalname.pdf"

tell application "Microsoft Word"
    activate
    open inputFile
    delay 2
    set theDoc to active document
    save as theDoc file name outputFile file format format PDF
    close theDoc saving no
end tell
EOF
```

### Post-Conversion

- Delete original .docx file after successful conversion
- Verify PDF was created with correct file size

## Step 5: Remove Duplicate Submissions

**Performed by:** Claude Code with subagents

Students often submit multiple versions. Google Classroom adds `(1)`, `(2)` suffixes.

### Process

1. **Identify duplicates** by student prefix:
   ```bash
   ls *.pdf | sed 's/_.*//' | sort | uniq -c | sort -rn | grep -v "^ *1 "
   ```

2. **Spawn parallel subagents** - one per student with duplicates

3. Each subagent:
   - Reads all versions for that student
   - Compares content (page count, completeness, dates)
   - Identifies best version (usually most complete or latest)
   - Deletes inferior versions
   - Reports actions taken

### Selection Criteria

| Factor | Preference |
|--------|------------|
| Page count | More pages (if additional content) |
| Completeness | Includes all appendices/attachments |
| File size | Larger (if same page count) |
| Filename | Cleaner (no parentheses) if content identical |
| Content quality | Explicit conclusions, AI acknowledgment |

### Verification

```bash
# Check MD5 for potentially identical files
md5 student_*.pdf
```

## Step 6: Generate Student List

**Performed by:** Claude Code

Create a markdown file tracking all students and submission status:

```markdown
| Full Name | File Prefix | Report Submitted |
|-----------|-------------|------------------|
| Firstname Lastname | `lastname_firstname` | Yes |
| Another Student | `student_another` | No |
...
```

### Summary Statistics

- Total students
- Reports submitted
- Missing reports (with names listed)

## Step 7: Protect from Git (MANDATORY)

**Performed by:** Claude Code (automatically) or Instructor

> This step should happen FIRST, immediately after unzipping, not last.

### Check and Update .gitignore

```bash
# Check if .gitignore exists
cat docs/assignments/.gitignore

# If the new assignment folder is not listed, add it:
echo "assignment-N/student-reports/" >> docs/assignments/.gitignore
```

### Current .gitignore Content

```
# docs/assignments/.gitignore
assignment-1/student-reports/
assignment-2/student-reports/
assignment-3/student-reports/
```

**Add new folders as assignments are created.**

### Verification

```bash
# Confirm files are ignored
git status --ignored

# Should show:
# Ignored files:
#   docs/assignments/assignment-1/student-reports/
```

### Why This Matters

| Risk | Consequence |
|------|-------------|
| Student names in public repo | GDPR violation |
| Student work exposed | Academic integrity issues |
| Personal data in git history | Difficult to fully remove |

**Rationale:** Student work contains personal data and must never be committed to public repositories. Even if removed later, git history retains the data.

## File Structure After Processing

```
docs/assignments/
├── .gitignore                          # Excludes student report folders
├── CLAUDE.md                           # Claude Code instructions for this folder
├── CLASS-LIST.md                       # Master student roster (all assignments)
├── STUDENT-REPORT-PROCESSING.md        # This document
├── DOCX-TO-PDF-CONVERSION.md           # Technical reference for conversions
│
└── assignment-1/                       # Assignment 1 folder
    ├── assignment-1.md                 # Assignment description (English)
    ├── assignment-1-swe.md             # Assignment description (Swedish)
    ├── STUDENT-LIST.md                 # Roster with submission status
    └── student-reports/                # Not tracked in git
        ├── aminzadeh_pouya_Rapport.pdf
        ├── amnehagen_fredrick_leveransrapport.pdf
        ├── andersson_jonas_Rapport...pdf
        └── ... (one PDF per student)
```

## Future Automation Opportunities

### Potential Script: `process-student-reports.sh`

```bash
#!/bin/bash
# Hypothetical automation script

ASSIGNMENT_NUM=$1
INPUT_ZIP=$2
ASSIGNMENT_DIR="docs/assignments/assignment-${ASSIGNMENT_NUM}"
OUTPUT_DIR="${ASSIGNMENT_DIR}/student-reports"

# 0. Create directory structure
mkdir -p "$OUTPUT_DIR"

# 1. Unzip submissions
unzip "$INPUT_ZIP" -d "$OUTPUT_DIR"

# 2. Convert all DOCX to PDF
for docx in "$OUTPUT_DIR"/*.docx; do
    # Use osascript or pandoc
done

# 3. Call Claude Code API for renaming
# (Would require Claude Code API/SDK integration)

# 4. Generate student list
# 5. Remove duplicates
```

### Integration Points

| Step | Automation Potential | Complexity |
|------|---------------------|------------|
| Download from Classroom | Google Classroom API | High (auth) |
| Unzip | Shell script | Low |
| DOCX → PDF | Shell script (osascript/pandoc) | Low |
| Extract names from PDF | Claude API with vision | Medium |
| Rename files | Shell script | Low |
| Remove duplicates | Claude API for content analysis | Medium |
| Generate reports | Shell script | Low |

### Recommended Next Steps

1. **Create batch DOCX→PDF script** using the documented osascript approach
2. **Build student roster database** (JSON/YAML) for automated matching
3. **Develop Claude API integration** for PDF name extraction
4. **Add checksum verification** to detect true duplicates instantly

## Commands Reference

### Find duplicates by prefix
```bash
ls *.pdf | sed 's/_.*//' | sort | uniq -c | sort -rn
```

### List unique students
```bash
ls *.pdf | sed 's/_.*//' | sort -u
```

### Check for non-PDF files
```bash
ls | grep -v '\.pdf$'
```

### Verify file count
```bash
ls *.pdf | wc -l
```

## Session Log (Assignment 1)

**Date:** 2025-01-03

| Step | Action | Result |
|------|--------|--------|
| 1 | Manual download from Google Classroom | 35 files in ZIP |
| 2 | Parallel rename with 35 subagents | 32 renamed, 3 needed manual ID |
| 3 | Cross-reference with class roster | 2 more identified |
| 4 | Manual identification | 1 file identified |
| 5 | Fix incorrect extractions | 2 names corrected |
| 6 | Convert DOCX | 1 file converted |
| 7 | Remove duplicates (6 students) | 8 files deleted |
| 8 | Generate student list | 28 submitted, 3 missing |
| 9 | Add .gitignore | Protected from git |

**Final result:** 28 clean PDFs with consistent naming
