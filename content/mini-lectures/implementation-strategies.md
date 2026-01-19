+++
title = "Implementation Strategies"
program = "IPL"
cohort = "25"
courses = ["SNS"]
weight = 3
date = 2024-12-08
draft = false
+++

[Watch the presentation](/presentations/mini-lectures/implementation-strategies.html)

---

The fundamental reframe for implementation strategy is this: stop asking "how do we build this system?" and start asking "what do we need to learn, and how do we learn it efficiently?"

Development must begin before complete information exists. Requirements remain unclear, technical approaches are untested, and user needs evolve throughout the project lifecycle. Attempting to resolve all uncertainty through upfront analysis does not work—complex interactions only emerge during implementation.

The alternative is designing **feedback loops**: building strategic pieces of the system to answer specific questions. Each implementation produces evidence—working software that users can evaluate, performance metrics that reveal bottlenecks, integration points that expose compatibility issues.

Four implementation strategies address different types of uncertainty: Minimum Viable Product, Walking Skeleton, Rapid Prototyping, and Spike investigations. Selecting the appropriate strategy depends on which questions carry the most risk.

## Minimum Viable Product

**Core question:** Do users value this solution?

A **Minimum Viable Product** (MVP) delivers the smallest set of functionality that provides genuine value to users. The emphasis falls on "viable"—the product must actually solve a problem, even if it solves it with minimal features. An MVP is not a prototype or demo; it is a functioning product that users can adopt for real work.

The purpose is to test fundamental assumptions about product-market fit. Does the core value proposition resonate? Will people actually use this? These questions require observing real users interacting with working software—analysis alone cannot answer them.

Building an MVP requires ruthless prioritization. Features are excluded not because they lack value, but because they can be deferred. The goal is to reach users as quickly as possible, then gather feedback to guide subsequent development.

Consider a team building a project management application. An MVP might include only task creation, assignment, and status updates—no file attachments, no time tracking, no reporting dashboards. If users cannot accomplish basic project coordination with these features, the concept needs revision. If users adopt the MVP enthusiastically despite its limitations, their feature requests guide prioritization.

**Trade-off:** MVPs ship with known limitations. Code quality may be lower than production standards, error handling minimal, performance adequate rather than optimized. These compromises are intentional—investing in polish before validating core assumptions wastes effort on features that may be discarded.

## Walking Skeleton

**Core question:** Does our architecture work end-to-end?

A **Walking Skeleton** implements a thin but complete slice through all system layers, from user interface through business logic to data persistence. Unlike an MVP, which focuses on delivering user value, a Walking Skeleton proves that the system architecture functions end-to-end—that components integrate, deployment pipelines work, and the fundamental technical approach is sound.

The skeleton executes one simple scenario completely. For a web application: user submits a form, application validates input, business logic processes the request, data persists to the database, confirmation displays to the user. Each architectural layer participates, but only with the simplest possible implementation—just enough code to prove the plumbing works.

This strategy reveals integration problems early. Authentication between layers, data serialization, network configuration, database connection pooling, deployment procedures—all become concrete rather than theoretical. Issues that would derail development if discovered late surface when the cost of addressing them is minimal.

Walking Skeletons particularly benefit projects with architectural uncertainty: new technology stacks, unfamiliar deployment platforms, complex integration requirements. Building a thin vertical slice proves the approach before investing heavily in features built on that foundation.

Once the skeleton functions, it becomes the foundation for subsequent development. The team adds features by expanding each layer incrementally, maintaining integration continuously rather than facing a difficult integration phase at project end.

**Trade-off:** A Walking Skeleton provides minimal user value initially. Users cannot evaluate the product meaningfully until several iterations flesh out the skeleton with real functionality.

## Rapid Prototyping

**Core question:** Is this approach worth pursuing?

**Rapid Prototyping** creates quick, disposable experiments to explore possibilities and gather feedback. Prototypes are explicitly not production code—they exist to answer questions, then be discarded. This disposability enables speed: prototypes can ignore error handling, skip optimization, hardcode values, and take shortcuts unacceptable in production software.

Prototypes serve multiple purposes. **Exploratory prototypes** investigate unfamiliar technologies: Can this library do what we need? **Evaluative prototypes** present concepts to users: Does this interaction model make sense? Is this visualization useful?

The power lies in low commitment. A prototype might take hours or days rather than weeks, and the team can abandon unsuccessful experiments without loss. If failure is cheap, teams explore more options and discover better solutions.

**Critical discipline:** Prototypes must remain clearly separated from production code. The temptation to evolve a prototype into production software is strong, but prototypes make trade-offs inappropriate for production—missing error handling, inadequate security, brittle assumptions. Extract the lessons learned and rebuild with production standards.

User research benefits particularly from rapid prototyping. Abstract questions ("Would you find this feature useful?") produce speculative answers. Concrete demonstrations ("Try completing this task using this interface") produce behavioral evidence.

**Trade-off:** Prototypes that attempt to answer too many questions become complex and time-consuming, losing the advantages of rapid experimentation. Effective prototyping requires clear focus: What specific question does this prototype answer?

## Spike

**Core question:** Is this specific approach feasible?

A **Spike** (from Scrum terminology) is a time-boxed investigation of a specific technical question. Unlike a prototype, which produces a demonstration, a spike produces knowledge—a brief document, a recommendation, a small code sample, or simply a decision about feasibility.

Spikes address questions like: Is this third-party API suitable for our needs? What performance can we expect from this database configuration? How difficult would migrating to this framework be?

**Time-boxing is essential.** The team allocates a specific amount of time—typically a few hours to a few days—then stops regardless of whether they reached definitive answers. If the allocated time proves insufficient, that itself provides information: the problem is more complex than anticipated.

The spike process involves focused research and experimentation: reading documentation, examining code examples, building small test cases, conducting performance benchmarks. The goal is gathering enough information to make informed decisions, not building production-ready code.

Teams typically use spikes during planning to resolve uncertainties that block estimation or design decisions. A story requiring integration with a third-party service might include a spike to verify the API provides necessary capabilities. A performance-critical feature might begin with a spike to benchmark candidate technologies.

**Spike outcomes inform subsequent work:** If viable and straightforward, proceed with implementation. If unexpectedly complex, reconsider the approach. If the question remains unresolved within the time box, allocate more investigation, seek alternatives, or accept the uncertainty and address it iteratively.

**Trade-off:** Without time-boxing, investigations consume arbitrary time pursuing diminishing returns. Spikes force prioritization: What information is essential versus merely interesting?

## Selecting an Implementation Strategy

Match the strategy to the questions that carry the highest risk:

| Strategy | Primary Question | Deliverable | Duration |
|----------|-----------------|-------------|----------|
| MVP | Do users value this solution? | Functioning product with minimal features | Weeks to months |
| Walking Skeleton | Does our architecture work end-to-end? | Complete but minimal vertical slice | Days to weeks |
| Rapid Prototyping | Is this approach worth pursuing? | Disposable demonstration or experiment | Hours to days |
| Spike | Is this specific approach feasible? | Knowledge and recommendation | Hours to days |

Projects commonly combine strategies. A team might begin with spikes to evaluate competing technologies, then build a Walking Skeleton to prove integration works, then develop MVP features incrementally to validate user value.

**The wrong strategy wastes effort.** Building a Walking Skeleton when the fundamental value proposition is unproven means validating architecture for a product users may not want. Building an MVP without architectural validation risks discovering late that the approach cannot scale. Strategy selection requires identifying which uncertainties matter most at the current project stage.

## Functionality First or Quality First?

Implementation strategy also involves choosing what to prioritize: functional requirements (features, capabilities) or quality attributes (performance, security, reliability).

**Functionality-first** delivers working features with minimal attention to quality. The application might be slow, security basic, but users can accomplish tasks. MVP typically follows this approach—validate product-market fit quickly, then invest in quality once core functionality is proven valuable.

**Quality-first** establishes architectural constraints before building features: authentication frameworks, deployment pipelines, performance benchmarks. Walking Skeleton typically follows this approach—prove quality attributes can be achieved within the architecture before building features on that foundation.

**The trade-off:** Functionality-first gets user feedback quickly but risks building on a foundation that cannot support production requirements. Quality-first ensures solid technical foundation but delays validation of whether users want what is being built.

Many projects alternate: establish quality foundation through Walking Skeleton, then iterate on functionality through MVP increments, pausing periodically to address quality attributes that emerge as bottlenecks.

## Key Takeaways

**Reframe implementation as learning.** Ask "what do we need to learn?" rather than "how do we build this?"

**Match strategy to uncertainty.** MVP for user value questions, Walking Skeleton for architectural questions, Rapid Prototyping for design exploration, Spikes for specific technical feasibility.

**Combine strategies across project phases.** Spikes → Walking Skeleton → MVP increments addresses different uncertainties at appropriate times.

**Never evolve prototypes into production code.** Extract lessons learned and rebuild with production standards.

**Time-box investigations.** Spikes without limits consume arbitrary time pursuing diminishing returns.

**Wrong strategy wastes effort.** Validating architecture for a product users may not want is as wasteful as building features on a foundation that cannot scale.
