+++
title = "From Intent to Code"
weight = 2
date = 2024-12-08
draft = false
+++

[Watch the presentation](/presentations/mini-lectures/from-intent-to-code.html)

---

Software projects begin with intentions and end with running systems. Between these endpoints lies a progression of increasingly concrete representations—documents, diagrams, and finally code—each serving a distinct purpose in transforming business objectives into operational software. Understanding this **abstraction hierarchy** reveals why planning remains essential despite the inherent uncertainty at each level, and how AI systems complement human judgment in navigating these transitions.

## It Starts with Intent

Everything begins with **intent**—a business need, an idea, a request. Intent can be vague ("we need better customer engagement") or specific ("we need a registration form for the upcoming webinar"). Regardless of clarity, intent is the trigger that starts the journey toward running software.

Intent is a **value proposition**: a statement of what value we want to create. Running systems are the **value delivery**: that value actually reaching users. Everything in between—documents, diagrams, code—transforms proposition into delivery.

Intent itself is not a document. It might be a conversation, an email, a slide in a presentation, or simply an understood organizational need. The first task in any project is capturing and formalizing this intent into structured documentation that eventually becomes code—and code that eventually becomes operational systems serving real users.

## The Three-Layer Model

Software development formalizes intent through three foundational document types, each capturing the same system from a different perspective:

1. **Business Requirements Document (BRD)** - The first formalization of intent. Captures the business need in stakeholder language: what they want, who needs it, and what success looks like from their perspective. Provides enough context on *why* to make the *what* meaningful.

2. **Product Requirements Document (PRD)** - Translates the business need into product specifications: functional requirements, non-functional requirements, user stories, constraints, and acceptance criteria.

3. **Architecture Documentation (C4 Model)** - Defines the technical design: a hierarchical view that progressively zooms from system context down to code structure.

The C4 model itself contains four levels of abstraction:
- **Context** - Who uses the system and how it fits into its environment. This is also where the technology stack is first defined—an early commitment based on PRD constraints and team capabilities. These choices are documented in Architecture Decision Records (ADRs) and guide all subsequent design work.
- **Containers** - The major technical building blocks (applications, databases, servers) that implement the chosen technology stack
- **Components** - The internal structure of each container
- **Code** - The actual implementation

Tech stack decisions made at the Context level are pragmatic commitments: teams proceed with their initial choices until concrete evidence proves them inadequate. Endless deliberation over technology alternatives delays progress without adding value.

This progression—intent to BRD to PRD to C4—moves from probabilistic to deterministic. Raw intent permits almost unlimited solutions. Business requirements narrow the field. Product requirements constrain it further. Architecture specifies structure. Code is the final artifact: deterministic, doing exactly what it specifies, with no remaining ambiguity. But code is not the destination—running software is. Code must be deployed, configured, and operated before it delivers value.

## Why Intermediate Layers Matter

The probabilistic nature of higher abstraction levels raises an obvious question: if only code determines system behavior, why maintain intermediate representations that remain inherently incomplete?

### Different Stakeholders, Different Altitudes

Business stakeholders articulate strategic intent in the BRD—they cannot directly specify code because they lack technical context. Engineers cannot divine business strategy from technical constraints alone—they lack market context.

The PRD creates an interface where business and technical expertise intersect. Architecture documentation bridges product requirements and engineering implementation. Each layer enables collaboration between people who think at different altitudes.

### Progressive Risk Reduction

Each step down the hierarchy reduces uncertainty and reveals risks earlier. Discovering that a feature conflicts with business intent during PRD development costs far less than discovering it after implementation. Finding architectural impossibilities while defining containers costs less than finding them during coding.

### Preserving Intent Through Implementation

Implementation requires countless micro-decisions: data structures, algorithms, error handling, performance trade-offs. Engineers make these decisions continuously, but they need context to make them well.

Higher abstraction levels preserve the reasoning behind decisions. A user story in the PRD explaining *why* a feature exists helps engineers choose between implementation alternatives. Non-functional requirements guide optimization priorities. Business context in the BRD prevents technically correct solutions that miss strategic objectives.

## The Incompleteness Problem

Intermediate abstraction levels share a challenging property: they are always incomplete descriptions of the final system. This is not a process failure but a mathematical certainty.

A PRD cannot enumerate every detail that code will implement—the specification would need to be as complex as the code itself, eliminating any abstraction benefit. Architecture diagrams capture structure and relationships but not every conditional branch or error path.

This incompleteness means planning documents represent possibilities, not certainties. Implementation reveals constraints, opportunities, and interactions that no amount of upfront planning can fully anticipate. The code that emerges will differ from what planning documents specified, even when the team follows them faithfully.

Plans do not need to be complete to be useful. A PRD that captures 80% of necessary functionality provides enormous value, even if implementation uncovers the remaining 20%. The value lies in direction and context, not in exhaustive specification.

## AI as a Translation Partner

AI systems excel at pattern recognition and transformation between representations. Large language models trained on software artifacts learn relationships between abstraction levels—how business intent maps to requirements, how requirements decompose into architecture, how architecture expands into code.

This enables AI to serve as a translation mechanism:
- Given a business need, AI can draft product requirements
- Given requirements, AI can propose architectural structures
- Given architecture, AI can generate implementation scaffolding
- Given code, AI can extract documentation and update higher-level artifacts

These translations operate probabilistically, like the abstraction levels themselves. AI-generated artifacts require validation and refinement, but they provide starting points that accelerate the translation process.

### The Complementary Partnership

Human cognition excels at moving from abstract to concrete—taking a nebulous business objective and imagining specific features that might achieve it. This requires understanding goals, evaluating trade-offs, and creative synthesis of possibilities.

AI systems demonstrate remarkable ability moving from concrete to abstract—given code, they can identify patterns, generate documentation, and propose higher-level descriptions.

This asymmetry creates collaboration rather than competition. Humans drive downward through the hierarchy, translating intent into specifications. AI assists by generating drafts, validating consistency, and maintaining alignment. As code emerges, AI works upward—generating documentation, updating architecture diagrams, keeping specifications aligned with reality.

This bidirectional flow creates a feedback loop where human intent drives downward specification while AI maintains upward coherence.

## Summary

Software projects begin with intent—a trigger that may be vague or specific—and progressively formalize it through abstraction layers: BRD captures the business need, PRD defines product specifications, and C4 architecture specifies technical design, zooming from system context through containers and components down to code. Code is the final artifact, but running software serving users is the actual goal.

Each layer operates probabilistically until code produces deterministic behavior. These intermediate layers remain necessary because they enable collaboration across stakeholder groups, reduce risk progressively, and preserve the original intent through implementation.

AI systems translate between these layers, excelling at moving from concrete to abstract while humans excel at moving from abstract to concrete. This complementary relationship enables faster iteration, better alignment, and sustainable practices across the abstraction hierarchy.
