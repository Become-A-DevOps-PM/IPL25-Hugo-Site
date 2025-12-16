+++
title = "AI as Co-worker"
weight = 1
date = 2024-12-08
draft = false
+++

[Watch the presentation](/presentations/mini-lectures/ai-as-co-worker.html)

---

The most useful shift in thinking about AI is this: stop asking "Can AI do this task?" and start asking "How should I brief this team member?"

This reframing matters because AI agents process context, apply specialized knowledge, and produce substantive work outputs—characteristics that align more closely with a specialist consultant than with software. Treating AI as merely a tool misrepresents its capabilities and limits its value.

## The Co-worker Mental Model

A project manager does not micromanage a developer or infrastructure engineer. Instead, they provide context about project goals, specify requirements, and review deliverables. The specialist brings domain expertise and executes within their area of competence. AI agents function the same way—they require clear direction and oversight, but they generate value through specialized capabilities that complement human judgment.

Tools have features to learn. Colleagues have strengths to leverage and working relationships to develop. The co-worker framing shapes how you interact with AI: providing richer context, expecting iteration, and focusing on outcomes rather than step-by-step instructions.

## Three Modes of Interaction

Most people start using AI like an advanced search engine, then gradually discover they can delegate more sophisticated work. This progression follows three distinct modes, each requiring different collaboration approaches.

### Ask Mode: Direct Query Response

The simplest interaction follows a question-answer pattern. The project manager needs specific information, the AI provides it, and the conversation concludes.

**Characteristics:**
- Single exchange or short thread
- Factual or procedural questions
- Immediate application of the answer

**Appropriate uses:**
- Syntax verification ("What is the correct flag for recursive directory creation in Bash?")
- Concept definitions ("What does CIDR notation specify in a network address?")
- Quick reference lookups ("What port does PostgreSQL listen on by default?")
- Command construction ("How do I list all running processes owned by the nginx user?")

This mode resembles asking a colleague for quick confirmation or a reference detail. The interaction requires minimal context because the answer does not depend on broader project decisions. Ask mode works well for filling knowledge gaps during execution but provides limited value for complex problem-solving.

### Investigate Mode: Exploratory Analysis

Investigation involves examining a situation to understand its current state, identify patterns, or explain observed behavior. The AI analyzes provided information and explains what it reveals.

**Characteristics:**
- Medium-length interaction (several exchanges)
- Diagnostic or analytical focus
- Builds shared understanding of a situation

**Appropriate uses:**
- Error diagnosis ("This deployment fails with a connection timeout—what might cause that?")
- Configuration review ("Does this nginx configuration expose any security risks?")
- Architecture evaluation ("How does this database schema handle concurrent updates?")
- Pattern identification ("What security vulnerabilities appear in this authentication flow?")

Investigation mode requires the AI to access relevant information—error messages, configuration files, code samples, or system state. This context may come from files the AI can read directly or from information provided in conversation. The AI examines this context and provides analysis based on its training. This mode parallels asking a specialist to review documentation and explain their assessment.

The output of investigation mode informs decisions rather than executing them. The project manager gains clarity about a situation, which then guides subsequent actions.

### Plan-Execute Mode: Collaborative Implementation

Plan-execute mode involves the AI generating work products—code, configuration files, documentation, or implementation plans. The project manager defines requirements and success criteria, the AI produces deliverables, and the human reviews and integrates the output.

**Characteristics:**
- Extended interaction with multiple iterations
- Creative or constructive tasks
- Produces artifacts for integration into the project

**Appropriate uses:**
- Infrastructure automation ("Create a Bash script that provisions a VM with nginx and configures firewall rules")
- Code development ("Write a Flask route that validates user input and stores it in PostgreSQL")
- Configuration generation ("Produce an nginx configuration that serves a Flask application with SSL termination")
- Documentation creation ("Draft deployment instructions for this Azure infrastructure")

This mode delivers the highest value but requires the most sophisticated collaboration. The project manager must provide sufficient context for the AI to understand requirements, evaluate the generated output for correctness and fit, and iterate when the first attempt does not fully meet specifications.

Plan-execute mode positions the AI as an implementation partner. The human maintains decision authority and quality oversight while the AI handles substantial portions of the technical execution.

### Beyond These Modes

These three modes represent progressively sophisticated collaboration within a single session with one AI agent. Further levels exist—autonomous agents executing long-running tasks across multiple sessions, or coordinated teams of specialized agents working in parallel. Those patterns introduce additional complexity around orchestration, state management, and quality assurance that extend beyond the foundational collaboration skills covered here.

## The Role of Context

The difference between generic AI output and genuinely useful output is context. An AI agent only knows what it can access—through files in a project directory, information provided in conversation, or documentation that establishes project conventions.

Three categories of context matter most.

### Intent Context

Intent describes what you aim to accomplish and why. AI agents propose better approaches when they understand the underlying goal.

**Weak:** "Create a database."

**Strong:** "Create a PostgreSQL database for a Flask application storing user accounts and blog posts. Fewer than 100 concurrent users initially, but the schema should support growth. Data persistence and referential integrity are requirements."

The strong version clarifies technology choice, application context, scale expectations, and key requirements—enabling appropriate design choices rather than generic commands. Intent context also helps AI identify when stated goals conflict with proposed approaches.

### Technology Stack Context

Specifying exact technologies, versions, and platforms eliminates ambiguity. A PostgreSQL 14 configuration differs from PostgreSQL 12; Azure CLI commands differ from AWS CLI.

**Essential technology context:** Operating system and version, programming language and version, frameworks and libraries, infrastructure platform, supporting services.

Precise technology context generates commands and code that execute correctly in the target environment and prevents suggestions for incompatible alternatives.

### Tool and Environment Context

AI agents benefit from understanding existing tools and workflows—infrastructure management approach, version control, CI/CD platform, development environment, and access patterns.

Tool context shapes output form. An AI aware that the project uses Bicep templates generates Bicep code rather than manual CLI commands. Environmental constraints—no root access, firewall restrictions, compliance requirements—prevent proposals of unusable solutions.

## Calibrating Trust

Here is the key difference between AI and human colleagues: AI does not accumulate wisdom. Each session starts without memory of previous interactions. Context can persist through project documentation, but the AI itself does not learn from experience or improve judgment over time.

This characteristic demands a specific approach to delegation and verification.

### Capabilities and Boundaries

AI agents excel at pattern-based tasks grounded in their training data. They can explain established concepts, generate code following known patterns, and apply documented best practices. This makes them valuable for implementation work that follows understood approaches.

**AI strengths:**
- Syntax-heavy tasks (writing configuration files, generating boilerplate code)
- Structured formats (JSON, YAML, SQL queries)
- Standard patterns (common deployment scripts, conventional file structures)
- Documentation synthesis (explaining concepts, drafting instructions)
- Iterative refinement (adjusting output based on specific feedback)
- Execution and verification (running commands, testing code, checking results)

AI agents have genuine limitations that shape how to work with them effectively. These constraints persist regardless of the tools available.

**AI limitations:**
- Training data cutoff (lacks information about recent developments)
- No persistent memory across sessions (context must be re-established or documented)
- Limited ability to detect subtle logical errors in generated code
- Cannot apply judgment about undocumented organizational policies or preferences
- May produce confident but incorrect outputs, particularly for edge cases

Understanding these boundaries enables appropriate task delegation. An AI can draft and execute a deployment script, but it cannot judge whether the deployment timing aligns with business constraints. An AI can analyze PostgreSQL query patterns if given access to logs, but it cannot determine whether the performance trade-offs align with unstated product priorities.

### Verification Strategies

AI output requires verification before production integration, with the approach scaled to risk.

**For code and configuration:** Review for logical errors and edge cases, test in non-production environments, verify security and compliance alignment.

**For explanations and documentation:** Cross-reference claims against authoritative sources, verify alignment with chosen technology versions, test documented procedures.

A Bash script automating provisioning warrants thorough testing. Documentation explaining a concept requires accuracy checks but poses less risk initially.

### Iteration and Refinement

AI collaboration often requires multiple rounds. Initial output may be directionally correct but need adjustment for specific requirements—similar to reviewing a colleague's first draft.

**Effective iteration:** Identify specific issues, provide concrete correction criteria, test revisions, and confirm the final version meets requirements. Starting with a working baseline and refining it produces better results than attempting perfect specifications upfront.

## Documenting AI Collaboration

Transparency about AI integration serves multiple purposes: team members understand how work was produced, auditors can verify human oversight, and teams can identify which collaboration patterns generate value.

**Practical documentation:**
- Note when AI generated initial code, configuration, or documentation
- Record verification steps applied before integration
- Track which task types worked well versus required extensive rework

This documentation enables continuous improvement. If certain tasks consistently require substantial correction, that suggests insufficient context or inappropriate delegation. If other tasks integrate smoothly, that validates the approach.

## Integration into Project Workflows

Effective AI collaboration requires deliberate integration rather than ad hoc usage. Certain workflow stages benefit more than others—particularly pattern-based work with clear specifications: drafting automation scripts, generating configuration files, creating documentation, and researching unfamiliar technologies.

**Workflow considerations:**
- Allocate time for AI output review in task estimates
- Establish verification criteria for AI-generated deliverables
- Create templates for common requests to ensure consistent context

Like any professional skill, AI collaboration improves with deliberate practice.

## Key Takeaways

**Shift your mental model.** Ask "How should I brief this team member?" rather than "Can AI do this task?"

**Match mode to task.** Use ask mode for quick lookups, investigate mode for analysis and diagnosis, plan-execute mode for producing deliverables.

**Context determines quality.** Provide intent (what and why), technology stack (specific versions), and tool context (existing workflows and constraints).

**AI does not accumulate wisdom.** Each session starts fresh. Persist important context through documentation.

**Scale verification to risk.** Critical infrastructure scripts warrant thorough testing. Documentation drafts require accuracy checks but carry less risk.

**Treat collaboration as a skill.** Effectiveness improves with practice—structuring requests, evaluating outputs, and iterating efficiently.
