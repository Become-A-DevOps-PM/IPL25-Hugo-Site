+++
title = "From Intent to Code"
weight = 2
date = 2024-12-08
draft = false
+++

[Watch the presentation](/presentations/mini-lectures/from-intent-to-code.html)

---

Software projects begin with intentions and end with executable code. Between these endpoints lies a progression of increasingly concrete representations, each serving a distinct purpose in transforming business objectives into working systems. Understanding this **abstraction hierarchy** reveals why planning remains essential despite the inherent uncertainty at each level, and how AI systems complement human judgment in navigating these transitions.

## The Planning Hierarchy

Software development moves through distinct abstraction levels, each translating broader vision into more specific implementation guidance. The progression typically follows this sequence:

1. **Business Intent** - Strategic objectives and value propositions
2. **Requirements Specification** - Stakeholder needs and system constraints
3. **Product Requirements Document (PRD)** - Feature definitions and success criteria
4. **User Stories and Epics** - User-centric functionality descriptions
5. **Backlog Items** - Specific, prioritized work units
6. **Definition of Done** - Acceptance criteria and completion standards
7. **Code** - Executable implementation

Each level provides greater specificity than its predecessor while remaining incomplete until code executes. This incompleteness is not a flaw but a fundamental characteristic of the planning process.

## The Nature of Abstraction Levels

Higher abstraction levels operate in the realm of possibility and probability. A business intent like "reduce customer churn by improving onboarding" leaves enormous implementation space. The requirements specification narrows this space by identifying which aspects of onboarding need improvement, but still permits many valid solutions. The PRD specifies features, yet implementation details remain undefined.

This probabilistic nature persists through user stories and backlog items. A story describing how a user completes account setup does not specify database schemas, API endpoints, or validation logic. The **Definition of Done** establishes completion criteria—tests pass, documentation exists, code reviews are complete—but these criteria verify outcomes rather than dictate implementation.

Code represents the transition from probabilistic to deterministic. Executed code produces specific, measurable behavior. A function either validates an email address or it does not. An API endpoint either returns the expected response or it fails. The system behaves exactly as the code specifies, with no remaining ambiguity.

This deterministic property makes code the authoritative representation of system behavior. Documentation can drift from reality, requirements can become outdated, but running code defines what the system actually does. This is why the industry maxim holds that "code is truth"—it is the only artifact that unambiguously describes system behavior.

## Why Intermediate Levels Matter

The probabilistic nature of higher abstraction levels raises an obvious question: if only code determines system behavior, why maintain intermediate representations that remain inherently incomplete?

Several factors make these intermediate stages essential rather than optional.

### Shared Understanding Across Stakeholders

Different stakeholders engage at different abstraction levels. Business leaders articulate strategic intent. Product managers translate that intent into feature requirements. Engineers convert requirements into implementation. Each group brings specialized knowledge that applies most effectively at specific levels.

A business stakeholder cannot directly specify code—they lack the technical context. An engineer cannot divine business strategy from technical constraints alone—they lack market context. Intermediate levels create interfaces where different forms of expertise intersect. Requirements specifications bridge business intent and product features. User stories bridge product features and engineering backlog. Each level enables collaboration between stakeholders who think at different altitudes.

### Progressive Risk Reduction

Each step down the abstraction hierarchy reduces uncertainty. Business intent identifies what to build. Requirements specify who needs it and why. PRDs define how it should work. User stories break features into testable increments. Backlog items sequence implementation. Definition of Done establishes verification criteria.

This progressive refinement reveals risks at stages where course correction costs less. Discovering that a feature conflicts with business intent during PRD development costs far less than discovering it after implementation. Finding technical impossibilities during story breakdown costs less than finding them during coding. Each level serves as a checkpoint where assumptions can be validated before investing in more concrete work.

### Managing Complexity Through Decomposition

Large systems exceed human cognitive capacity to grasp completely. The abstraction hierarchy provides scaffolding for managing this complexity. A system might comprise thousands of features serving millions of users. Business intent captures strategic direction without detailing every feature. Requirements group related functionality into coherent capabilities. User stories break capabilities into implementable units. Backlog items sequence those units into achievable work.

This decomposition makes large systems tractable. No single person needs to hold the entire system in their mind simultaneously. Different stakeholders maintain detailed understanding at their relevant abstraction levels while retaining broader context from adjacent levels.

### Preserving Intent Through Implementation

Implementation requires countless micro-decisions. A feature specified in a PRD might require hundreds of code-level choices: data structures, algorithms, error handling strategies, performance optimizations. Engineers make these decisions continuously, but they need context to make them well.

Higher abstraction levels preserve the reasoning behind decisions. A user story explaining why a feature exists helps engineers choose between implementation alternatives that satisfy the specification equally but differ in user impact. Requirements that identify performance constraints guide optimization priorities. Business intent prevents technically correct solutions that miss strategic objectives.

Without these levels, implementation becomes disconnected from purpose. Code works, but possibly in ways that undermine the original goals. Intermediate levels maintain the thread from strategic intent through tactical implementation.

## The Fundamental Incompleteness Problem

Despite their necessity, intermediate abstraction levels share a challenging property: they are always incomplete descriptions of the final system. This incompleteness is not a process failure but a mathematical certainty.

A requirements specification cannot enumerate every detail that code will implement. The specification would need to be as complex as the code itself, eliminating any abstraction benefit. User stories cannot fully describe system behavior—they capture intentions and examples, but edge cases, error handling, and interaction effects emerge during implementation.

This incompleteness means planning documents represent possibilities, not certainties. A PRD describes what the team intends to build, not what they will inevitably deliver. Implementation reveals constraints, opportunities, and interactions that no amount of upfront planning can fully anticipate. The code that emerges will differ from what any planning document specified, even when the team follows the plan faithfully.

Teams sometimes respond to this reality by abandoning planning as futile. If plans cannot perfectly predict outcomes, why invest in them? This reaction misses the value that planning provides even when it cannot guarantee outcomes.

Plans do not need to be complete to be useful. A requirements specification that captures 80% of necessary functionality provides enormous value, even if implementation uncovers the remaining 20%. User stories that illuminate user intent guide implementation even when they cannot enumerate every scenario. The value lies in direction and context, not in exhaustive specification.

## AI as a Translation Layer

AI systems excel at pattern recognition and transformation between representations. Large language models trained on vast corpuses of software artifacts learn relationships between abstraction levels. They recognize how business intent typically maps to requirements, how requirements decompose into user stories, how stories expand into backlog items.

This pattern recognition enables AI to serve as a translation mechanism between abstraction levels. Given a business intent, an AI system can generate plausible requirements specifications. Given requirements, it can draft user stories. Given stories, it can propose backlog items with acceptance criteria.

These translations operate probabilistically, like the abstraction levels themselves. An AI-generated requirements specification represents possible requirements, not definitive ones. The generated artifacts require validation and refinement, but they provide starting points that accelerate the translation process.

The value multiplies when AI systems access organizational context. An AI with knowledge of existing systems, past projects, and technical constraints generates proposals aligned with organizational reality rather than generic best practices. It suggests requirements that fit existing architecture, stories that align with team capabilities, backlog items that sequence sensibly with current work.

AI translation works in both directions. Given code, AI can generate documentation, extract user stories, or infer requirements. This backward translation helps teams maintain alignment between implementation and planning artifacts. As code evolves, AI can update specifications to reflect actual behavior, preventing the drift that normally separates documentation from reality.

## The Human-AI Collaboration Pattern

The most significant insight about AI in planning emerges from examining where human and machine cognition excel at different directional movements through the abstraction hierarchy.

### AI Strengths: Concrete to Abstract

AI systems demonstrate remarkable ability moving upward from concrete to abstract. Given specific code, AI can identify patterns, extract common functionality, generate documentation, and propose higher-level descriptions. This capability stems from pattern recognition—AI systems see many implementations and learn to recognize their abstract characteristics.

An AI examining code can identify that it implements a user authentication system, generate API documentation, propose test cases, and extract business rules. These upward translations require recognizing patterns in concrete behavior and describing them at higher abstraction levels.

This strength makes AI valuable for maintenance and comprehension tasks. Faced with legacy code, an AI can generate explanatory documentation. Given a codebase, it can extract architectural diagrams. Presented with implementation details, it can articulate the design patterns in use.

### Human Strengths: Abstract to Concrete

Human cognition excels in the opposite direction—moving from abstract vision to concrete implementation. Humans can take a nebulous business objective and imagine specific features that might achieve it. They can envision user experiences, anticipate needs, and design solutions in contexts they have never encountered before.

This capability involves more than pattern matching. It requires understanding goals, evaluating trade-offs, exercising judgment about what matters, and creative synthesis of possibilities. These are domains where current AI systems struggle, despite their impressive capabilities in other areas.

When stakeholders articulate a business intent like "make the platform more accessible," human product managers draw on domain knowledge, user empathy, regulatory understanding, and market context to propose specific requirements. Engineers take those requirements and envision implementations, making architectural choices that balance competing concerns.

### The Complementary Partnership

This asymmetry creates opportunity for collaboration rather than competition. Humans drive downward through the hierarchy, translating intent into increasingly concrete specifications. AI assists by generating starting points, validating consistency, and maintaining alignment as details emerge.

A product manager articulates business intent and high-level requirements. AI generates draft user stories based on those requirements and organizational patterns. The product manager refines these stories, exercising judgment about priorities and feasibility. AI expands stories into backlog items with acceptance criteria. Engineers review and adjust these items based on technical constraints. AI generates implementation scaffolding. Engineers complete the implementation with domain-specific logic.

Throughout this process, AI also works upward. As code emerges, AI generates documentation. As implementation reveals new patterns, AI updates stories and requirements to reflect reality. As the system evolves, AI maintains alignment between abstraction levels, reducing the drift that normally accumulates between plans and implementation.

This bidirectional flow creates a feedback loop where human intent drives downward specification while AI maintains upward coherence. Neither human nor AI could achieve this alignment alone, but together they navigate the abstraction hierarchy more effectively than traditional processes permit.

## Practical Implications for Project Management

Understanding abstraction levels and the human-AI collaboration pattern changes how project managers approach planning.

Planning remains essential, but perfection becomes less critical. Since higher levels are inherently probabilistic, investing effort to eliminate all ambiguity wastes resources. Plans need sufficient detail to guide decisions, not exhaustive specification. AI fills gaps with contextually appropriate defaults that teams can accept or refine.

Iteration cycles shorten because translation between levels accelerates. Teams can move from business intent to backlog items in hours rather than weeks, using AI to generate drafts that humans validate and refine. This acceleration enables responding to feedback faster—requirements changes translate to updated backlog items within the same planning cycle.

Documentation maintenance shifts from manual burden to automated coherence. As implementation evolves, AI propagates changes through abstraction levels, keeping specifications aligned with reality. This automation prevents the documentation rot that undermines long-term project health.

Most significantly, teams can maintain more direct connection between business intent and implementation. Traditional processes insert so much latency between levels that strategic vision and daily coding become disconnected. AI-assisted translation maintains tighter coupling, helping engineers understand why their work matters while helping business stakeholders see how their objectives manifest in code.

## Summary

Software projects move through abstraction levels from business intent to executable code. Each level operates probabilistically until code produces deterministic behavior. These intermediate levels remain necessary despite incompleteness because they enable collaboration, reduce risk progressively, manage complexity, and preserve intent through implementation.

AI systems translate between these levels, excelling at moving from concrete to abstract while humans excel at moving from abstract to concrete. This complementary relationship creates opportunities for collaboration where human judgment guides direction while AI maintains coherence. Understanding this dynamic enables project managers to leverage AI capabilities effectively while recognizing where human expertise remains irreplaceable.

The progression from intent to code will always involve uncertainty and refinement. AI tools do not eliminate this reality, but they change how teams navigate it—enabling faster iteration, better alignment, and more sustainable planning practices across the abstraction hierarchy.
