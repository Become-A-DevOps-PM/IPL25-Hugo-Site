# Assignment 1 - Perspectives and Design Notes

Notes from the discussion about different perspectives to incorporate in the midterm assignment (Launch Report for Webinar).

---

## Overview

The assignment asks students to create a "launch report" demonstrating their solution is ready for production. Beyond just technical documentation, we want students to reflect on multiple perspectives that are relevant for IT Project Managers in a DevOps context.

---

## Perspectives Incorporated

### 1. Technical Perspective (60% of assignment)

**Sections:** Technical Architecture (30%) + Application Stack (30%)

What we're assessing:
- Understanding of infrastructure components (VMs, networking, managed services)
- Understanding of application stack (Flask, Gunicorn, nginx, PostgreSQL)
- Ability to verify and test that components work correctly
- Data flow understanding (user → reverse proxy → application server → database)

Key elements:
- Network layout (subnets, NSG rules, internal/external communication)
- Role of each server component
- Key configurations (nginx, Gunicorn, PostgreSQL)
- Verification with screenshots and test results

**Automation is rewarded here:** Students who used Azure CLI, bash scripts, or other automation can describe their approach in this section.

---

### 2. Security Perspective (20% of assignment)

**Section:** Security (20%)

What we're assessing:
- Awareness of security measures at multiple layers
- Ability to verify security controls work

Key elements:
- Network security (NSG, ASG, network segmentation)
- SSH access (bastion host, SSH keys, agent forwarding)
- HTTPS configuration (SSL certificates)
- Secrets management (database connection string handling)

Verification includes:
- SSH via bastion (agent forwarding or ProxyJump)
- NSG blocked/allowed connections
- HTTPS working in browser

---

### 3. Risk Awareness Perspective (5% of assignment)

**Section:** Risk Awareness (5%)

**Note:** This is intentionally light - it's a precursor to the formal risk analysis module that comes later in the course.

What we're assessing:
- Basic awareness that things can go wrong
- Ability to think about technical, operational, and security risks
- Initial thinking about mitigation

**Not** a formal risk analysis - just demonstrating awareness. The formal risk analysis framework comes in the next part of the course.

---

### 4. Project Management Perspective (part of Process Reflection)

**Section:** Process Reflection (10%)

What we're assessing:
- Understanding of iterative/agile development benefits
- Reflection on the weekly demo process
- Communication awareness (implicit in how they write the report)

Key questions:
- How did building incrementally (MVP first, then layers) affect progress?
- What did you learn from the weekly demos?
- What would have been different with a "big bang" approach?

**Connection to PM role:** Students are future IT Project Managers - they need to understand why iterative delivery works, not just follow it blindly.

---

### 5. Automation / Infrastructure as Code Perspective (integrated)

**Integrated into:** Technical Architecture section + Process Reflection

What we're assessing:
- Whether students used automation (Azure CLI, scripts) vs. manual portal clicking
- Understanding of reproducibility benefits
- Awareness of where they are on the automation spectrum

Key questions:
- How did you provision infrastructure? (Portal vs CLI vs scripts)
- How reproducible is your setup?
- If you had to rebuild from scratch, how long would it take?

**Rewarded:** Students who automated more should be able to describe it in Technical Architecture and will have better answers about reproducibility.

---

### 6. AI Usage Perspective (part of Process Reflection)

**Section:** Process Reflection (10%)

**Philosophy:** Complete transparency about AI use is encouraged. Using AI effectively to build the solution is rewarded, not penalized.

What we're assessing:
- Honest reflection on how AI tools were used
- Critical thinking about AI assistance (what worked, what didn't)
- Verification practices (how did they check AI output was correct?)

Key questions:
- How did you use AI tools (Claude, ChatGPT, Copilot, etc.)?
- For what tasks? (understanding, debugging, code generation, configs)
- What worked well? Where did AI mislead you?
- How did you verify AI-generated solutions?

**Important distinction:**
- ✅ Using AI to build the solution = encouraged and rewarded
- ❌ Using AI to write the report = not allowed

The report must be written by the student because:
1. Writing forces understanding
2. We're assessing their ability to communicate technical work
3. The reflection questions require genuine personal experience

---

## Section Weights Summary

| Section | Weight | Primary Perspective |
|---------|--------|---------------------|
| Summary | 5% | Communication |
| Technical Architecture | 30% | Technical + Automation |
| Application Stack | 30% | Technical |
| Security | 20% | Security |
| Risk Awareness | 5% | Risk (precursor) |
| Process Reflection | 10% | PM + AI + Automation |

---

## Design Decisions

### Why is Risk Awareness only 5%?

Risk analysis is taught formally in the next module of the course. This section is just a "precursor" to get students thinking about risks before they learn the formal frameworks. We don't want to grade them on something they haven't been taught yet.

### Why allow AI for building but not for the report?

1. **Reality of modern development:** AI tools are part of professional practice now. Hiding AI use or penalizing it would be counterproductive.

2. **Assessment validity:** We need to assess what students understand. If they can use AI to build a working system AND explain it in their own words, they understand it.

3. **The report tests understanding:** Writing the report forces students to articulate what they built. AI-generated reports wouldn't demonstrate this understanding.

4. **Transparency over hiding:** We want students to be honest about their tools and methods. This is a professional skill.

### Why integrate automation rather than make it a separate section?

1. **Not all students automated equally:** Some used portal, some used CLI, some wrote scripts. A separate section would disadvantage portal users.

2. **Natural fit in Technical Architecture:** Describing "how you built it" naturally includes automation if they used it.

3. **Reproducibility question in Reflection:** This captures automation benefits even for those who didn't automate much (they'll recognize it would take longer to rebuild).

### Why include iterative development reflection?

1. **Course used weekly demos:** Students experienced sprint-based delivery firsthand.

2. **PM perspective:** Understanding WHY iterative works is crucial for project managers.

3. **Contrast with alternatives:** Asking "what would be different with big bang" helps them appreciate what they experienced.

---

## Future Considerations

### Grading Criteria (G/VG)

Not explicitly defined in the assignment yet. Could add later:

**G-level (Pass):**
- All sections present
- Working solution demonstrated
- Basic verification shown
- Some reflection on process

**VG-level (Distinction):**
- Deep technical understanding shown
- Significant automation used and explained
- Thoughtful security analysis
- Insightful reflection on AI use and iterative process
- Professional quality documentation

### Project Management Perspective - Could Expand

Currently light touch. Could add more explicit PM questions:
- What decisions did you make and why?
- What would you communicate to stakeholders?
- How would you estimate effort for similar work?

Kept minimal for now to avoid overloading the assignment.

---

## Tech Stack Changes from IPL24

The assignment was updated from the 2024 version to reflect the new tech stack:

| Component | IPL24 (Old) | IPL25 (New) |
|-----------|-------------|-------------|
| Language | PHP | Python |
| Framework | - | Flask |
| App Server | Apache/mod_php | Gunicorn |
| Database | MySQL (VM) | PostgreSQL (Azure managed) |
| Local DB | - | SQLite |
| Stack Name | LEMP | Custom (no acronym) |

Key changes made to assignment:
- All MySQL references → PostgreSQL
- All PHP references → Flask/Python
- Added Gunicorn as application server
- Changed "database server VM" → "managed database service"
- Added SQLite for local development in tips
- Added DBeaver/psql hints for database verification
