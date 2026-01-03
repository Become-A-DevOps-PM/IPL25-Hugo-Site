---
name: report-evaluation
description: Evaluate student assignment reports using three independent reviewers for consensus grading. Each reviewer reads the PDF and context files independently, then provides section assessments in Swedish. Results compiled with majority voting into GRADING-RESULTS.md. Use when grading prepared student submissions.
allowed-tools: Read, Write, Edit, Glob, Task, AskUserQuestion, WebFetch
triggers:
  - evaluate reports
  - grade assignments
  - student grading
  - assessment
---

# Report Evaluation Skill

Evaluate student reports using three independent reviewers for reliable consensus grading.

## Critical: Before Starting

**MUST READ from skill folder:**

1. Read `FEEDBACK-EXAMPLES.md` - Swedish feedback tone and style
2. Read `OUTPUT-FORMAT.md` - Expected output structure

## Assignment Folder Structure

Each assignment folder contains the context needed for evaluation. Most files must be in the assignment folder, but some (like COURSE-DESCRIPTION.md) can be shared in parent folders.

### Required Files in Assignment Folder

| File | Purpose | Search Behavior |
|------|---------|-----------------|
| `STUDENT-LIST.md` | Roster with submission status and grades | Assignment folder only |
| `ASSIGNMENT.md` | The assignment instructions (defines sections to evaluate) | Assignment folder only |
| `COURSE-DESCRIPTION.md` | Formal course criteria and learning objectives | **Parent folders up to project root** |
| `BACKGROUND.md` | Project scenario and learning context | Assignment folder only |
| `SPECIAL-CONSIDERATIONS.md` | Exceptions and adjustments for this assignment | Assignment folder only |
| `student-reports/` | Folder containing renamed PDFs | Assignment folder only |

### File Relationships

```
project-root/
├── COURSE-DESCRIPTION.md    # Can live here (shared across assignments)
└── assignments/
    ├── COURSE-DESCRIPTION.md    # Or here (shared across assignments)
    └── assignment-N/
        ├── COURSE-DESCRIPTION.md    # Or here (assignment-specific)
        ├── STUDENT-LIST.md          # WHO to evaluate
        ├── ASSIGNMENT.md            # WHAT to look for (report sections)
        ├── BACKGROUND.md            # WHY (context, scenario)
        ├── SPECIAL-CONSIDERATIONS.md # EXCEPTIONS (what's adjusted)
        ├── GRADING-RESULTS.md       # OUTPUT (created/updated by skill)
        └── student-reports/
            └── *.pdf                # Student submissions
```

**COURSE-DESCRIPTION.md search order:** Assignment folder → parent folder → grandparent → ... → project root. Uses the first one found.

## Core Tone Principles

**All feedback must be framed positively.** Never use negative critique.

When writing feedback, imagine you are actually saying this to the student face-to-face. Ask yourself: "Would I actually say this?" If it sounds bureaucratic, rewrite it.

| Principle | Description |
|-----------|-------------|
| **Face-to-face test** | The feedback should feel like something you'd actually say to the student in person |
| **Positive framing** | Frame everything positively - never mention what's missing or lacking |
| **Genuine enthusiasm** | Show real enthusiasm when something is good ("Riktigt snyggt!", "Kul att se...") |
| **Natural Swedish** | Use conversational language, not formal report language |

## Three-Reviewer Method

Each student report is evaluated by **three independent subagents in parallel**:

| Benefit | Explanation |
|---------|-------------|
| **Reliability** | Multiple perspectives reduce bias |
| **Consensus validation** | Unanimous vs split decisions visible |
| **Better feedback** | Select best feedback from variety |

### Consensus Rules

| Voting Pattern | Final Grade |
|----------------|-------------|
| 3/3 unanimous | Reviewer grade |
| 2/3 majority | Majority grade |
| 1/1/1 split | Flag for instructor review |

## Evaluation Workflow

### Step 0: Validate Input Files

**Before starting evaluation, check that all required input files exist.**

**Standard files** - Check in assignment folder only:
1. `STUDENT-LIST.md`
2. `ASSIGNMENT.md`
3. `BACKGROUND.md`
4. `SPECIAL-CONSIDERATIONS.md`
5. `student-reports/*.pdf` (at least one PDF)

**Parent-searchable files** - Check assignment folder first, then parent folders up to project root:
1. `COURSE-DESCRIPTION.md` - Search upward until found

**If any files are missing**, display this table to the terminal:

```
## Missing Input Files

The following files are required for evaluation:

| File | Status | Search Location | Purpose |
|------|--------|-----------------|---------|
| STUDENT-LIST.md | [Found/MISSING] | Assignment folder | Roster with student names, submission status, and grade column |
| ASSIGNMENT.md | [Found/MISSING] | Assignment folder | Assignment instructions - defines report sections and weights |
| COURSE-DESCRIPTION.md | [Found at: path / MISSING] | Parent folders → root | Formal course learning objectives and G/VG criteria |
| BACKGROUND.md | [Found/MISSING] | Assignment folder | Project scenario and learning context |
| SPECIAL-CONSIDERATIONS.md | [Found/MISSING] | Assignment folder | Exceptions and adjustments for this assignment |
| student-reports/*.pdf | [N found/MISSING] | Assignment folder | Student report PDFs to evaluate |
```

Then use **AskUserQuestion** to ask:

> "Some required input files are missing. Do you want to continue anyway?"
> - Options: "Yes, continue with available files" / "No, stop and fix missing files"

**If all files are present**, display a brief confirmation:

```
## Input Validation Passed

All required files found in [assignment-folder]:
- STUDENT-LIST.md
- ASSIGNMENT.md
- COURSE-DESCRIPTION.md
- BACKGROUND.md
- SPECIAL-CONSIDERATIONS.md
- student-reports/ (N PDFs found)

Proceeding with evaluation...
```

### Step 1: Load Context Files

Read all context files, using the paths determined in Step 0:

```
[assignment-folder]/ASSIGNMENT.md             # Report structure and sections
[found-path]/COURSE-DESCRIPTION.md            # Formal G/VG criteria (may be in parent folder)
[assignment-folder]/BACKGROUND.md             # Project context
[assignment-folder]/SPECIAL-CONSIDERATIONS.md # Exceptions
```

**Note:** COURSE-DESCRIPTION.md path comes from the parent folder search in Step 0. Pass this resolved path to reviewer subagents.

From these files, extract:
- **Sections to evaluate** (from ASSIGNMENT.md)
- **Section weights** (from ASSIGNMENT.md)
- **Pass (G) criteria** (from COURSE-DESCRIPTION.md)
- **Distinction (VG) criteria** (from COURSE-DESCRIPTION.md)
- **Which sections can earn VG** (from BACKGROUND.md or COURSE-DESCRIPTION.md)

### Step 2: Build Student List

Read `[assignment-folder]/STUDENT-LIST.md` and identify:
- Students with "Report Submitted: Yes"
- Students without a grade in "Betyg" column

### Step 3: Parallel Batch Evaluation

**Batch size:** Maximum 10 students per batch. If more than 10 students need evaluation, process in multiple batches.

#### 3a. Create Batches

```
students_to_evaluate = [students with submitted reports but no grade]
batches = split into groups of max 10 students
```

#### 3b. For Each Batch: Spawn All Reviewers in Parallel

For a batch of N students (max 10), spawn **N × 3 = up to 30 subagents in parallel**.

Each subagent receives the same prompt (see `REVIEWER-PROMPT.md`) instructing them to:
1. Read all context files from the assignment folder
2. Read and evaluate the student's PDF
3. **Follow any code repository links** (GitHub, GitLab, etc.) found in the report
4. Assess each section defined in ASSIGNMENT.md
5. Determine overall grade based on COURSE-DESCRIPTION.md criteria
6. Write feedback in Swedish

**Spawning pattern for batch:**
```
# Single message with all Task calls for the batch:
Task: Student 1 - Reviewer 1
Task: Student 1 - Reviewer 2
Task: Student 1 - Reviewer 3
Task: Student 2 - Reviewer 1
Task: Student 2 - Reviewer 2
Task: Student 2 - Reviewer 3
... (up to 30 parallel tasks)
```

#### 3c. Collect All Results

Wait for **all subagents in the batch** to complete before proceeding. Each returns:
- Student name (to match results)
- Grade (G or VG)
- Section assessments (term + comment for each section)
- Feedback (3 sentences in Swedish)
- Reasoning (brief justification)

#### 3d. Process Results for Each Student

For each student in the batch, apply consensus:

**Majority voting:**
```
If all 3 agree: Final grade = reviewer grade (unanimous)
If 2/3 agree: Final grade = majority grade (majority)
If all different: Flag for manual review (split)
```

**Select best feedback** from the 3 options:
1. Most warm and encouraging
2. Most specific to student's work
3. Most natural Swedish (not bureaucratic)

#### 3e. Batch Write Results

After processing all students in the batch:

1. **Append all evaluations** to `GRADING-RESULTS.md` in one write operation
2. **Update all grades** in `STUDENT-LIST.md` in one edit operation

This batch write approach:
- Reduces file I/O operations
- Prevents partial state if interrupted
- Enables atomic batch completion

#### 3f. Display Batch Summary

After each batch completes, display summary for all students in the batch:

```
## Batch 1/2 Complete (10 students)

| Student | Grade | Consensus |
|---------|-------|-----------|
| Andersson, Anna | VG | 3/3 |
| Eriksson, Erik | G | 2/3 |
| ... | ... | ... |

✓ All 10 evaluations saved to GRADING-RESULTS.md
✓ STUDENT-LIST.md updated with grades
```

#### 3g. Continue with Next Batch

If more batches remain, repeat steps 3b-3f for the next batch.

### Step 4: Display Final Summary

After all batches complete, display overall progress:

```
## Evaluation Complete

**Total students evaluated:** [N]
**Batches processed:** [M]

| Grade | Count |
|-------|-------|
| VG | [X] |
| G | [Y] |

**Consensus quality:**
- Unanimous (3/3): [N]
- Majority (2/3): [N]
- Split (flagged): [N]

Proceeding to generate summary tables...
```

### Step 5: Generate Summary Tables

After all students are evaluated, add **two summary sections** to GRADING-RESULTS.md:

#### 5a. Compact Assessment Overview Table

Create a table showing all evaluated students with their grades and section assessments at a glance. This table should:

1. **Use abbreviated section names** derived from ASSIGNMENT.md (e.g., "Teknisk arkitektur" → "Arkitektur", "Applikationsstack" → "Appstack")
2. **Include all students** sorted alphabetically by last name
3. **Show the consensus vote count** (e.g., "3/3", "2/3", or "Override" for instructor adjustments)
4. **Display section assessments** using the grading scale terms (Okej/Bra/Mycket bra/Utmärkt)

**Template format:**

```markdown
## Sammanfattning

| Student | Betyg | Röster | [Section1] | [Section2] | [Section3] | [Section4] | [Section5] | [Section6] |
|---------|-------|--------|------------|------------|------------|------------|------------|------------|
| Lastname, Firstname | VG | 3/3 | Bra | Mycket bra | Bra | Mycket bra | Bra | Mycket bra |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |
```

**Column guidelines:**
- **Student**: "Lastname, Firstname" format for easy alphabetical sorting
- **Betyg**: Final grade (G or VG)
- **Röster**: Vote count (3/3, 2/3) or "Override" if instructor adjusted
- **Section columns**: Use the most representative assessment from the three reviewers (majority or most common)

#### 5b. Statistics Summary

After the compact table, add statistical summaries:

```markdown
# Summary Statistics

## Grade Distribution

| Grade | Count | Percentage |
|-------|-------|------------|
| **VG (Väl godkänt)** | [N] | [X]% |
| **G (Godkänt)** | [N] | [X]% |
| **Total Evaluated** | [N] | 100% |

### VG Recipients ([N] students)

| Student | Consensus | Notable Strength |
|---------|-----------|------------------|
| [Name] | 3/3 | [Key observation from evaluation] |
| ... | ... | ... |

### Consensus Breakdown

| Voting Pattern | Count |
|----------------|-------|
| Unanimous (3/3) | [N] |
| Majority (2/3) | [N] |
| Split (1/1/1) | [N] |

### Missing Submissions ([N] students)

- [Name]
- ...

---

*Evaluation completed: [DATE]*
*Method: Three-reviewer consensus grading*
*All feedback written in Swedish using du/din form*
```

#### 5c. Table Placement

The summaries should be placed at the **end** of GRADING-RESULTS.md, after all individual student evaluations. Structure:

```
# Grading Results - [Assignment Name]
[Individual student evaluations...]
---
## Sammanfattning
[Compact assessment overview table]
---
# Summary Statistics
[Statistics tables]
```

## Grading Scale Reference

| Swedish Term | English | Grade Level |
|--------------|---------|-------------|
| Okej | Okay | Pass minimum |
| Bra | Good | Solid pass |
| Mycket bra | Very Good | Distinction level |
| Utmärkt | Excellent | Beyond requirements |

| Grade | Swedish | Criteria |
|-------|---------|----------|
| G | Godkänt | All sections meet minimum |
| VG | Väl godkänt | G criteria + VG-eligible sections show deeper understanding |

## Single Student Evaluation

To evaluate just one student:

```
Evaluate the report for [Student Name] in [assignment-folder-path]
Use the three-reviewer method from report-evaluation skill.
```

## Batch Evaluation

To evaluate all remaining students:

```
Evaluate all ungraded students in [assignment-folder-path]
Use parallel batch mode (max 10 students per batch, 3 reviewers each).
Write results to GRADING-RESULTS.md and STUDENT-LIST.md after each batch.
```

**Performance characteristics:**
- Up to 30 parallel subagents per batch (10 students × 3 reviewers)
- ~10x faster than sequential processing for large classes
- Batch writes reduce file I/O overhead

## Handling Split Decisions

If reviewers split 1/1/1 (e.g., G, VG, G with different reasoning):

1. Display all three assessments in terminal
2. Note the split in GRADING-RESULTS.md
3. Use majority grade but flag: `G (split - instructor review)`
4. Include all three feedback options for instructor to choose

## Quality Controls

Before completing:

- [ ] All students in STUDENT-LIST.md have grades
- [ ] GRADING-RESULTS.md has entry for each evaluated student
- [ ] Summary table reflects all evaluations
- [ ] Split decisions flagged for review
- [ ] Feedback is in Swedish and uses "du/din"

## Privacy Note

GRADING-RESULTS.md contains student names and grades. It must be:

1. Added to `.gitignore`
2. Never committed to public repositories
3. Shared only with authorized instructors
