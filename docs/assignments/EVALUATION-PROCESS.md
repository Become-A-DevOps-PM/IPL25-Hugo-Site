# Assignment Evaluation Process

This document describes the process for evaluating student assignment submissions using Claude Code, mapping them to formal course criteria, and providing constructive feedback.

## Quick Start: Kickoff Prompt

Use this prompt in a fresh Claude Code session to start grading:

```
Evaluate student reports for Assignment 1.

Read the evaluation process: docs/assignments/EVALUATION-PROCESS.md
Student reports are in: docs/assignments/assignment-1/student-reports/
Results go in: docs/assignments/assignment-1/GRADING-RESULTS.md

For each student:
1. Spawn a subagent to read and evaluate the PDF
2. Add the result to GRADING-RESULTS.md

Start with [student name] or process all students in parallel.
```

**To evaluate a single student:**
```
Evaluate the report for [Student Name] following docs/assignments/EVALUATION-PROCESS.md
```

**To evaluate all remaining students:**
```
Evaluate all student reports in docs/assignments/assignment-1/student-reports/
that are not yet in GRADING-RESULTS.md. Use parallel subagents.
Follow the process in docs/assignments/EVALUATION-PROCESS.md
```

## Grading Scale

All feedback should be framed positively. Use these terms consistently:

| Term | Grade Level | Description |
|------|-------------|-------------|
| **Okay** | Pass (G) | Meets minimum requirements, just passed |
| **Good** | Pass (G) | Clearly meets requirements, solid work |
| **Very Good** | Distinction (VG) | Exceeds requirements, demonstrates deeper understanding |
| **Excellent** | Beyond VG | Exceptional work, goes beyond what was required |

**Important:** Never use negative critique. Frame areas for improvement in positive terms.

## Project Background (Assignment 1)

### Scenario: CM Corp

Students worked on a fictional assignment from "CM Corp" where they acted as IT project managers responsible for delivering a technical solution.

**Business Demand:** The marketing department requested a simple, user-friendly website to promote an upcoming webinar, including event information and a registration form.

**Business Needs:**
1. Webinar information display (topic, date, agenda, speakers)
2. Functional signup form with data validation
3. Scalable infrastructure for traffic spikes
4. Deployment deadline: Christmas

### Learning Context

- **Group work** with weekly demonstrations and feedback
- **Iterative development** - MVP first, then add layers
- **Progressive technical complexity:**
  1. Local Flask + SQLite
  2. Single Azure VM deployment
  3. Azure PostgreSQL integration
  4. Network segmentation (VNet, subnets, NSG)
  5. Security hardening (bastion, HTTPS, SSH keys)
  6. Production setup (systemd, reverse proxy)

- **AI assistance encouraged** for learning, debugging, code generation
- **Report must be written by the student** (not AI-generated)

### Evaluation Context

When evaluating, consider:
- Students had 4 weeks to build incrementally
- Weekly demos meant iterative feedback and improvement
- AI tools were allowed and encouraged for building the solution
- The report demonstrates understanding, not just copy-paste

See: [assignment-1/BACKGROUND.md](assignment-1/BACKGROUND.md) for full details.

## Course Learning Objectives (Assignment 1)

From the formal course description, Assignment 1 covers:

| Category | Objective | Pass (G) Criteria | Distinction (VG) Criteria |
|----------|-----------|-------------------|---------------------------|
| **Knowledge** | Explain how IT systems and their components are structured | Student demonstrates understanding of system architecture | — |
| **Skill** | Build a functioning IT configuration and present its security aspects | Student has built and documented a working solution | Student applies knowledge for a more secure and robust solution |

## Assignment 1 Section Mapping

The assignment sections map to the learning objectives as follows:

| Assignment Section | Weight | Learning Objective | VG Opportunity |
|--------------------|--------|-------------------|----------------|
| 1. Summary | 5% | Knowledge | No |
| 2. Technical Architecture | 30% | Knowledge + Skill | Yes |
| 3. Application Stack | 30% | Knowledge + Skill | Yes |
| 4. Security | 20% | Skill | **Yes (primary)** |
| 5. Risk Awareness | 5% | Knowledge | No |
| 6. Process Reflection | 10% | — | No |

## Evaluation Criteria by Section

### 1. Summary (5%)

**Pass (G):**
- Project purpose is stated
- Main components are listed

**Indicators:**
- Okay: Brief mention of purpose and components
- Good: Clear overview connecting purpose to solution

### 2. Technical Architecture and Configuration (30%)

**Pass (G):**
- Network layout described (VNet, subnets)
- Server roles explained (bastion, proxy, app server)
- Database configuration mentioned
- Verification steps with screenshots

**Distinction (VG) indicators:**
- NSG rules clearly explained with security rationale
- Automation approach documented (scripts, CLI)
- Reproducibility considered

**Indicators:**
- Okay: Basic description, minimal verification
- Good: Clear descriptions with screenshots showing working configuration
- Very Good: Detailed explanations with security rationale, automation documented
- Excellent: Professional-grade documentation, could be used as reference

### 3. Application Stack and Functionality (30%)

**Pass (G):**
- Stack components described (Ubuntu, nginx, Gunicorn, Flask, PostgreSQL)
- Data flow explained (form → proxy → app → database)
- Form functionality verified with screenshots
- Database queries shown

**Distinction (VG) indicators:**
- Deep understanding of component interactions
- Thorough testing documented
- Error handling considered

**Indicators:**
- Okay: Components listed, basic verification
- Good: Clear flow description, working form demonstrated
- Very Good: Comprehensive testing, understands why each component is needed
- Excellent: Could troubleshoot issues based on documentation

### 4. Security (20%) — Primary VG Section

**Pass (G):**
- Network security mentioned (NSG, segmentation)
- SSH access via bastion documented
- HTTPS configuration shown
- Some verification of security measures

**Distinction (VG) criteria:**
- Demonstrates a **more secure and robust solution**
- Multiple security layers implemented and explained
- Security decisions justified
- Blocked connection attempts shown (not just allowed)

**Indicators:**
- Okay: Security measures listed but minimal verification
- Good: Security measures implemented and verified
- Very Good: Defense-in-depth approach, understands attack vectors
- Excellent: Security-first thinking throughout, proactive risk mitigation

### 5. Risk Awareness (5%)

**Pass (G):**
- At least 2-3 risks identified
- Mitigation suggestions provided

**Indicators:**
- Okay: Generic risks mentioned
- Good: Relevant risks with practical mitigations

### 6. Process Reflection (10%)

**Pass (G):**
- Iterative development reflected upon
- AI usage described honestly
- Automation level assessed

**Indicators:**
- Okay: Brief answers to each point
- Good: Thoughtful reflection showing learning

## Evaluation Process

### Step 1: Read the Report

```
Read the student PDF and note:
- Which sections are present
- Quality of screenshots/verification
- Depth of explanations
```

### Step 2: Assess Each Section

For each section, determine:
1. Does it meet Pass (G) criteria?
2. If applicable, does it show VG-level work?
3. What term applies? (Okay/Good/Very Good/Excellent)

### Step 3: Determine Overall Grade

**Pass (G):** All sections meet minimum criteria

**Distinction (VG):** Pass criteria met AND Security section (or Technical Architecture) demonstrates "more secure and robust solution"

### Step 4: Write Feedback (3 sentences)

**Style:** Write as if you're a teacher speaking directly to the student. Use "du/din" (you/your). Be warm, encouraging, and genuine - not bureaucratic or stiff. The feedback should feel like something you'd actually say to the student face-to-face.

**Tone guidelines:**
- Use natural, conversational Swedish - not formal report language
- Show genuine enthusiasm when something is good ("Riktigt snyggt!", "Kul att se...")
- Be specific about what impressed you
- Avoid stiff phrases like "visar på mogen förståelse" or "den tekniska substansen är solid"
- It's okay to use exclamation marks and casual expressions

Structure:
1. **Strength:** What the student did well - be specific and enthusiastic
2. **Achievement:** Highlight something that stood out
3. **Recognition:** Warm, encouraging closing

**Example feedback for Distinction (VG):**
> "Riktigt snyggt jobbat med C4-modellen och verifieringstesterna - särskilt bra att du testade både vad som fungerar och vad som blockeras. Din riskmatris är genomtänkt och visar att du förstår helheten. Roligt att läsa en rapport med personlig touch som ändå håller tekniskt!"

**Example feedback for Pass (G) - solid work:**
> "Bra jobbat! Du har fått ihop alla delar och visar tydligt hur allt hänger ihop med bra skärmbilder. Speciellt kul att se hur du verifierade att formuläret sparar data hela vägen till databasen."

**Example feedback for Pass (G) - minimum level:**
> "Du har fått med det som behövs och visar en fungerande lösning. Skärmbilderna bekräftar att systemet fungerar som det ska. Bra grund att bygga vidare på!"

## Automated Evaluation with Claude Code

### Three-Reviewer Method

Each student report is evaluated by **three independent subagents in parallel**. This provides:
- More reliable grading through multiple perspectives
- Consensus validation (unanimous vs. split decisions)
- Better feedback through variety of observations

The main agent then:
1. Compares all three evaluations
2. Determines final grade (majority vote)
3. Selects or synthesizes the best feedback
4. Reports voting results to terminal
5. Saves result to GRADING-RESULTS.md **without asking**

### How Subagents Get Context

Subagents don't share the main conversation's context. To give them full context, the subagent prompt instructs them to **read the documentation files first**:

1. `EVALUATION-PROCESS.md` - Full evaluation criteria and grading scale
2. `assignment-1/BACKGROUND.md` - Project scenario and learning context
3. `assignment-1/SPECIAL-CONSIDERATIONS.md` - Exceptions and adjustments for this assignment
4. `assignment-1/STUDENT-LIST.md` - Complete student roster with submission status and grades

This ensures subagents have complete context without embedding everything in the prompt.

### Prompt Template for Each Reviewer

```
Evaluate this student report for Assignment 1.

**Step 1: Read context files**
- Read: docs/assignments/EVALUATION-PROCESS.md (evaluation criteria, grading scale, output format)
- Read: docs/assignments/assignment-1/BACKGROUND.md (project scenario, learning context)
- Read: docs/assignments/assignment-1/SPECIAL-CONSIDERATIONS.md (exceptions and adjustments)

**Step 2: Read and evaluate the student report**
- Student: [Name]
- File: [path to PDF]

**Step 3: Provide evaluation**
For each section (Sammanfattning, Teknisk arkitektur, Applikationsstack, Säkerhet, Riskmedvetenhet, Processreflektion):
- Swedish assessment term: Okej / Bra / Mycket bra / Utmärkt
- One sentence explanation in Swedish

Overall grade: Godkänt (G) or Väl godkänt (VG)

Feedback: 3 sentences IN SWEDISH, speaking directly to student using "du/din". Be warm, encouraging, genuine - like a teacher speaking face-to-face. Use natural conversational Swedish, not bureaucratic language.

Return the full evaluation in the markdown format specified in EVALUATION-PROCESS.md.
```

### Single Student Evaluation Process

1. Spawn 3 subagents in parallel with the prompt template above
2. Wait for all 3 to complete
3. Compare results:
   - Show voting table for each section
   - Determine final grade (majority vote)
   - Use majority vote for each section rating
   - Select best feedback (most warm and specific)
4. Display terminal summary:
   ```
   ## [Student Name] - Voting Results
   Grade: VG (unanimous 3/3) or G (2/3 majority)
   ```
5. Save result to GRADING-RESULTS.md immediately (no confirmation needed)
6. Update STUDENT-LIST.md with the grade in the Betyg column

### Batch Evaluation Process

For evaluating all students:

1. Read `assignment-1/STUDENT-LIST.md` to get the complete student roster
2. Check which students have "Report Submitted: Yes" but no grade yet
3. For each remaining student, spawn 3 reviewer subagents in parallel
4. Main agent synthesizes results and saves to GRADING-RESULTS.md
5. Update STUDENT-LIST.md with the grade
6. Report progress after each student
7. Flag any non-unanimous decisions for optional manual review

### Files to Update After Each Evaluation

| File | What to Update |
|------|----------------|
| `assignment-1/GRADING-RESULTS.md` | Add full evaluation with voting table, section assessments, and feedback |
| `assignment-1/STUDENT-LIST.md` | Update the Betyg column with grade and vote count (e.g., "VG (3/3)") |

### Student Roster Reference

Always use `assignment-1/STUDENT-LIST.md` as the source of truth for:
- Complete list of students (31 total)
- Which students have submitted reports (28 submitted, 3 missing)
- Which students have been graded (check Betyg column)
- File prefix for matching PDF files

## Output Format

**Important:** All grading results and feedback must be written in **Swedish** since students are Swedish-speaking.

### Swedish Assessment Terms

| English | Swedish |
|---------|---------|
| Okay | Okej |
| Good | Bra |
| Very Good | Mycket bra |
| Excellent | Utmärkt |
| Pass (G) | Godkänt (G) |
| Distinction (VG) | Väl godkänt (VG) |

### Per-Student Result

```markdown
## [Student Name]

**Fil:** `lastname_firstname_....pdf`

### Bedömning per avsnitt
| Avsnitt | Bedömning | Kommentar |
|---------|-----------|-----------|
| Sammanfattning | Bra | Tydlig översikt |
| Teknisk arkitektur | Mycket bra | Detaljerad NSG-förklaring |
| Applikationsstack | Bra | Fungerande formulär demonstrerat |
| Säkerhet | Mycket bra | Försvar på djupet |
| Riskmedvetenhet | Okej | Grundläggande risker identifierade |
| Processreflektion | Bra | Ärlig AI-reflektion |

### Betyg: **Väl godkänt (VG)**

### Återkoppling
Du visar mycket bra säkerhetsimplementation med flera skyddslager tydligt dokumenterade. Din förståelse för hela infrastrukturstacken från nätverk till applikation är tydlig. Bra jobbat med de metodiska verifieringsstegen.
```

### Summary Table

```markdown
| Student | Betyg | Sammanfattning | Arkitektur | Appstack | Säkerhet | Risk | Reflektion |
|---------|-------|----------------|------------|----------|----------|------|------------|
| Lastname, Firstname | VG | Bra | Mycket bra | Bra | Mycket bra | Okej | Bra |
| Student, Example | G | Okej | Bra | Bra | Bra | Okej | Bra |
| ... | | | | | | | |
```

## Notes for Refinement

- [ ] Test evaluation prompts on sample reports
- [ ] Calibrate "Very Good" threshold for Security section
- [ ] Define minimum screenshot requirements
- [ ] Handle incomplete submissions
- [ ] Handle late submissions

---

*This is a working document. Refine based on actual evaluation experience.*
