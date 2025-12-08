# Scrum Primer for DevOps Projects

DevOps infrastructure projects operate in environments where requirements evolve as teams learn what works and what breaks. A firewall rule that seemed complete reveals gaps during testing. A database configuration that looked optimal under development loads fails under realistic traffic. Building the entire system before validating any part compounds these discovery costs.

**Scrum** addresses this reality through iterative development. Rather than planning six weeks of work upfront and hoping the plan survives contact with reality, Scrum structures work into short cycles that deliver functional increments, gather feedback, and adapt. This primer provides the foundational knowledge needed to participate effectively in an iterative project workflow.

This is not comprehensive Scrum training. You will receive that in a later course dedicated to agile methodologies. This article covers enough to understand iteration concepts, participate in ceremonies, and work within a sprint structure. The goal is practical participation, not certification.

## The Agile Foundation

Traditional project management emphasizes comprehensive planning. Define all requirements upfront, design the complete system, build everything according to plan, then test and deploy. This **waterfall** approach works when requirements are stable and well-understood, but infrastructure projects rarely meet these conditions.

Cloud platforms introduce dozens of configuration options. Security requirements emerge as systems take shape. Performance characteristics become clear only under realistic conditions. Budget constraints shift as actual costs become apparent. The longer a project waits to validate assumptions, the more expensive corrections become.

**Agile software development** recognizes this reality. The Agile Manifesto, written in 2001, articulates four value pairs. Each pair acknowledges both elements as important, but emphasizes one over the other:

- Individuals and interactions over processes and tools
- Working software over comprehensive documentation
- Customer collaboration over contract negotiation
- Responding to change over following a plan

That final value—responding to change over following a plan—captures the core insight. Plans are useful. Making plans helps teams think through problems and align on approach. But when reality differs from the plan, the team must adapt rather than rigidly following obsolete decisions.

Scrum implements these values through a structured framework. It provides just enough process to coordinate work without creating bureaucratic overhead. Teams plan work in short cycles, deliver working functionality each cycle, inspect results, and adapt the next cycle based on what they learned.

## Sprint Structure

Scrum organizes work into **sprints**—time-boxed iterations with specific objectives. A sprint has a fixed duration, typically one to four weeks. During that time, the team commits to delivering a defined set of work. When the sprint ends, the team demonstrates what they built, reflects on what went well and what could improve, then starts the next sprint.

The fixed duration matters. Teams cannot extend a sprint to finish more work or cut it short when things go well. This constraint forces realistic planning. If a team consistently overcommits and fails to complete sprint goals, they learn to plan more conservatively. If they finish early, they learn they can take on more work.

Each sprint produces a **potentially shippable increment**. "Potentially shippable" means the work meets quality standards and could be deployed to production, even if the decision is to wait. A sprint that concludes with untested code or partially completed features fails this standard. The increment must be functional, even if it represents only a subset of the final system.

For this course, sprints run one week. This compressed timeline mirrors the reality of professional DevOps work, where rapid iteration often outperforms lengthy planning cycles. A week provides enough time to complete meaningful infrastructure tasks—provision a resource, configure a service, implement a security control—while maintaining fast feedback loops.

## Core Ceremonies

Scrum defines four ceremonies that structure each sprint. These events serve specific purposes and happen at defined points in the sprint cycle. They are not arbitrary meetings, but essential synchronization points that keep the team aligned.

### Sprint Planning

**Sprint Planning** occurs at the start of each sprint. The team examines available work, determines what can be completed during the sprint, and commits to a sprint goal. The session answers two questions: What will we deliver this sprint? How will we accomplish that work?

The **Product Owner** (described in Team Roles below) presents prioritized work items. The team assesses each item's scope and complexity. Through discussion, the team selects items they believe they can complete within the sprint timeframe. These selected items form the **Sprint Backlog**.

Sprint planning requires honest assessment. Teams that routinely overcommit and fail to deliver erode trust and make planning meaningless. Teams that sandbag and deliver far more than committed waste planning time. Effective sprint planning balances ambition with realism, improving as the team learns its actual capacity.

For a one-week sprint, Sprint Planning typically takes one to two hours. Longer sprints require proportionally more planning time, but rarely more than eight hours for a four-week sprint.

### Daily Standup

The **Daily Standup** (also called Daily Scrum) is a brief synchronization meeting held at the same time each day. Team members share what they completed since the last standup, what they plan to work on before the next standup, and any obstacles blocking their progress.

This ceremony is time-boxed to 15 minutes. Participants stand to reinforce brevity. The goal is coordination, not detailed problem-solving. If two team members discover they need to discuss an implementation detail, they note that and continue the conversation after standup ends.

Daily Standups surface blockers quickly. If a team member cannot access a required Azure resource, that becomes visible immediately rather than consuming days of silent frustration. If two people are duplicating work, the standup reveals the overlap. If someone finished their tasks and needs new assignments, the team can respond.

In this course, Daily Standups may be adapted to the academic schedule. The principle—frequent synchronization to identify problems and coordinate work—remains valuable even if the specific cadence differs from daily.

### Sprint Review

The **Sprint Review** happens at the end of each sprint. The team demonstrates completed work to stakeholders. For software projects, this means showing working features. For infrastructure projects, this means demonstrating deployed resources, successful configurations, or implemented controls.

The emphasis is on working functionality, not presentations about work. A Sprint Review shows the provisioned virtual machine, the configured firewall rules, the deployed application—not slides describing these things. Stakeholders see what actually exists, not what the team intends to build.

This demonstration serves several purposes. It validates that the work meets requirements. It reveals whether the team's understanding of those requirements aligns with stakeholder expectations. It provides an opportunity for stakeholders to offer feedback that shapes the next sprint. It makes progress visible and tangible.

For a one-week sprint, the Sprint Review typically takes one hour. The team demonstrates work, stakeholders ask questions and provide feedback, and the group discusses whether to adjust priorities for upcoming sprints based on what they learned.

### Sprint Retrospective

The **Sprint Retrospective** follows the Sprint Review. While the review focuses on what the team built, the retrospective focuses on how the team worked. The goal is continuous improvement. What went well this sprint? What could improve? What specific changes will the team try in the next sprint?

Effective retrospectives create safe environments for honest discussion. If a team member struggled with an unfamiliar technology but hesitated to ask for help, that matters. If miscommunication led to duplicated work, identifying the communication gap helps prevent recurrence. If a new practice improved efficiency, the team can formalize it.

Retrospectives conclude with actionable commitments. "Communication was poor" is an observation. "We will document technical decisions in the project wiki and review them during standup" is an improvement action. The team selects one to three specific practices to try in the next sprint, then evaluates their effectiveness in the following retrospective.

For a one-week sprint, the retrospective typically takes 45 minutes. The team reflects on the sprint's process and commits to specific improvements.

## Team Roles

Scrum defines three roles, each with distinct responsibilities. Role clarity prevents confusion about who makes which decisions and who is accountable for specific outcomes.

### Product Owner

The **Product Owner** maintains the prioritized list of work and makes decisions about what gets built. When requirements conflict, the Product Owner resolves them. When new requests emerge, the Product Owner integrates them into the backlog at the appropriate priority. When the team asks "Should we build this feature or that one?", the Product Owner answers.

This role requires deep understanding of stakeholder needs and project objectives. The Product Owner balances competing demands—features, budget, timeline, quality—and makes trade-offs that maximize value delivery. They communicate stakeholder priorities to the team and communicate delivery realities to stakeholders.

In this course, the instructor often fills the Product Owner role, defining project requirements and exercise priorities. Understanding this role helps you recognize where requirements originate and who has authority to change them.

### Scrum Master

The **Scrum Master** facilitates the Scrum process. They schedule ceremonies, keep meetings time-boxed, help the team follow Scrum practices, and remove obstacles that block progress. When a team member needs access to a resource, the Scrum Master works to obtain it. When the team violates Scrum principles—skipping retrospectives, allowing standup to run long, committing to work without proper planning—the Scrum Master intervenes.

The Scrum Master is not a manager. They do not assign tasks or evaluate performance. They serve the team by protecting it from disruptions, coaching it in Scrum practices, and ensuring the process supports productivity rather than impeding it.

In professional settings, the Scrum Master might be a dedicated role or a responsibility rotated among team members. In this course, you may encounter Scrum Master responsibilities distributed across the team or handled by the instructor.

### Development Team

The **Development Team** (or simply "the team") consists of the people who perform the actual work. They estimate effort, commit to sprint goals, execute tasks, and deliver increments. The team is self-organizing—members decide how to accomplish committed work without external task assignment.

Scrum teams are intentionally cross-functional. Members possess different skills—development, infrastructure, testing, security—but collaborate on shared goals rather than working in isolated specialties. When a user story requires both application code and database changes, the team handles both rather than treating them as separate streams requiring coordination across departments.

In this course, you function as both team members and project managers. You make technical decisions, implement infrastructure, and reflect on process effectiveness. This dual perspective—building systems while managing the work—mirrors the DevOps philosophy of breaking down barriers between development and operations.

## Artifacts

Scrum uses three artifacts to make work visible and manageable. These are not bureaucratic documents, but practical tools that help teams plan work, track progress, and deliver value.

### Product Backlog

The **Product Backlog** is the prioritized list of everything that might be built. It includes features, bug fixes, technical improvements, research tasks—any work the team might perform. Items at the top are detailed and ready to implement. Items lower down are rougher, awaiting refinement as they approach implementation.

The Product Owner maintains the Product Backlog, continuously reprioritizing based on changing needs, new information, and stakeholder feedback. As the project progresses and the team learns what works and what doesn't, the Product Backlog evolves to reflect that learning.

Backlog items are often written as **user stories**: short descriptions of functionality from a user's perspective. For infrastructure work, "users" might be application developers, operations staff, or end users whose experience depends on infrastructure quality.

### Sprint Backlog

The **Sprint Backlog** contains the work the team commits to completing during the current sprint. These items come from the Product Backlog, selected during Sprint Planning based on priority and the team's capacity. Once the sprint starts, the Sprint Backlog remains stable—the team doesn't add new work mid-sprint unless they finish committed items early.

The Sprint Backlog makes the team's commitment visible. Anyone can look at it and understand what the team is working on, what's complete, and what remains. This transparency helps coordinate work and reveals when priorities need adjustment.

### Increment

The **Increment** is the sum of all completed work at the end of a sprint. Each sprint produces a new Increment that builds on previous sprints. The Increment must meet the team's **Definition of Done**—the quality standards that determine when work is truly complete.

For infrastructure work, "done" typically means more than "configured." It means tested, documented, secured, and deployable. A virtual machine isn't done when it boots; it's done when it meets security requirements, handles expected load, integrates with monitoring systems, and can be recreated reliably if it fails.

The Definition of Done prevents teams from declaring work complete while leaving crucial tasks—security hardening, documentation, testing—for "later." Those tasks often never happen, creating technical debt that compounds over time.

## Integration in This Course

This course operates using weekly sprints. Each week, you receive objectives that define the sprint goal. You plan how to accomplish those objectives, execute the work, demonstrate results, and reflect on the process.

**Weekly iterations** compress the Scrum timeline. Professional teams typically run two to four week sprints. One-week sprints provide faster feedback but require tighter planning and disciplined execution. Every decision's impact becomes visible quickly.

**Demonstrations** correspond to Sprint Reviews. You show working infrastructure—deployed resources, configured services, functional applications. Demonstrations prove that work meets requirements and functions as intended. They also surface gaps between what was specified and what was needed.

**Retrospectives** help you develop process awareness. What git workflow patterns work well? Which Azure CLI commands prove most useful? When do you need to pause and research rather than charging ahead? Identifying these patterns improves your effectiveness in subsequent sprints.

This structure serves a larger purpose than project coordination. Understanding iterative development prepares you for modern DevOps practice, where rapid experimentation and continuous adaptation outperform rigid planning. The infrastructure you build in this course demonstrates technical capability. The process you practice builds professional habits.

## Scope Boundaries

This primer provides enough Scrum knowledge to participate in an iterative project. It does not cover estimation techniques, velocity tracking, backlog refinement practices, scaling frameworks for large organizations, or the nuances of different Scrum implementations.

You will study these topics in depth in dedicated agile methodology courses. For now, focus on the core rhythm: plan work, execute work, demonstrate results, reflect on process, repeat. This cycle—simple to describe, challenging to execute well—drives continuous improvement in both the product you build and the process you follow.

## Summary

Scrum structures work into fixed-duration sprints that deliver functional increments. Four ceremonies—Sprint Planning, Daily Standup, Sprint Review, Sprint Retrospective—coordinate team activity and ensure regular feedback. Three roles—Product Owner, Scrum Master, Development Team—clarify responsibilities and decision authority. Three artifacts—Product Backlog, Sprint Backlog, Increment—make work visible and manageable.

The framework emphasizes responding to change over following a plan. Each sprint cycle generates learning—about requirements, about technology, about team capacity. That learning informs the next sprint, allowing the team to adapt rather than rigidly executing predetermined plans. For DevOps projects, where infrastructure complexity and evolving requirements make comprehensive upfront planning impossible, this adaptability becomes essential.
