# Architecture Wisdom

Distilled from Martin Fowler (Bounded Context, Transitional Architecture, Scaling Architecture Conversationally),
plus practical architectural patterns. Only practices NOT covered in craft/SKILL.md.

---

## Bounded Context (Eric Evans / Martin Fowler)

### Core Insight
- **A single unified model for a large system is neither feasible nor cost-effective.** The word "Customer" means different things to billing, support, and marketing. Trying to force one model creates confusion, not clarity.
- **Divide large systems into Bounded Contexts, each with its own unified model.** Within a context, the model is consistent and the language is precise. Across contexts, concepts may overlap but models differ.

### Actionable Practices
- **Identify contexts by language boundaries.** When the same word means different things to different teams or departments, you've found a context boundary. "Meter" in an electricity utility meant different things to grid operations, customer service, and field maintenance.
- **Share concepts across contexts through explicit mapping, not shared models.** Two contexts may both have "Product" but with different fields, invariants, and lifecycles. Define an anti-corruption layer or translation map at the boundary.
- **Unrelated concepts stay in their own context.** A "support ticket" exists only in the customer support context. Don't pollute other contexts with concepts they don't use.
- **Draw a context map.** A visual diagram showing all bounded contexts and their relationships (shared kernel, customer-supplier, conformist, anti-corruption layer, open host, published language). This is the most important architectural diagram you can have.
- **The dominant force for boundary placement is human culture, not technology.** Models act as ubiquitous language. When the language changes (different team, different department), the model must change.
- **Multiple contexts can exist within the same application.** The in-memory domain model and the relational database model are different bounded contexts within a single service, connected by a mapping layer (your ORM or repository).

---

## Transitional Architecture (Martin Fowler)

### Core Insight
- **Architecture is not a one-time decision but a series of transitions.** The target architecture matters less than the path to get there. A beautiful target that can't be reached incrementally is worthless.

### Actionable Practices
- **Every architectural element you introduce must earn its keep in the current transition, not just in the final state.** Don't add an API gateway "because we'll need it later." Add it when there's a concrete, current problem it solves.
- **Intermediate architectures are expected and acceptable.** The system between state A and state B will be messy. This is normal. Plan for it rather than pretending the jump is atomic.
- **Design for reversibility.** Prefer architectural choices that can be undone. A new service behind a feature flag is reversible. A full data model migration is not. Favor the reversible option when the outcome is uncertain.
- **Strangler fig over big bang.** Incrementally route traffic from old to new system. The old system gradually loses responsibilities until it can be decommissioned. Never plan a "big cutover weekend."
- **Kill transitional elements when they've served their purpose.** Temporary abstractions, compatibility shims, and migration scripts accumulate if not actively removed. Schedule cleanup as part of the migration plan, not as a separate "someday" task.
- **Transitional architecture requires monitoring the transition itself.** Track which percentage of traffic hits old vs new, which features are migrated, which are pending. Without this, transitions stall at 80% forever.

---

## Scaling Architecture Conversationally (Andrew Harmel-Law / Thoughtworks)

### Core Insight
- **Traditional top-down architecture doesn't scale with autonomous teams.** A small group of architects cannot feed a large number of independent teams. The answer is decentralized architectural decision-making, not more architects.

### The Advice Process (Core Mechanism)
- **Rule: Anyone can make an architectural decision.**
- **Qualifier: Before deciding, the decision-taker must consult two groups:**
  1. Everyone who will be meaningfully affected by the decision.
  2. People with expertise in the area of the decision.
- **The decision-taker is NOT obligated to agree with the advice.** They must seek it out and listen, but consensus is not required. This empowers action while preventing ignorance.
- **Specifically seek out people who will disagree.** Freed from the need to agree, they engage more seriously. The quality of advice improves dramatically.
- **The scope of consultation indicates the size of the decision.** If you need to consult 15 people, the decision is large. Consider splitting it into smaller decisions that each require fewer consultations.
- **The decision-taker is accountable for the outcome.** Empowerment and accountability are paired. This naturally creates appropriate levels of caution.

### Four Supporting Elements

#### 1. Decision Records (extending ADRs from craft/SKILL.md)
- **Store in source repos alongside the code they describe,** not in a separate wiki.
- **Record the advice received and from whom.** This is the Advice Process addition to standard ADRs: makes the process transparent and helps future decision-makers identify who to consult on related topics.

#### 2. Architecture Advisory Forum
- **A regular, scheduled meeting where decisions are discussed.** Not a gate or approval board -- a place where advice is given. The decision-taker presents, attendees advise.
- **Attendance is voluntary.** People come because the topics are relevant to them, not because they're required. This naturally self-selects the right audience.
- **The forum doesn't make decisions.** It provides a structured time and place for the conversations that the Advice Process requires. The decision-taker still decides.

#### 3. Team-Sourced Architectural Principles
- **Principles emerge from the teams, not from architects.** Collect what teams have learned about what works and what doesn't. Codify these as shared principles.
- **Principles guide decisions when no advisor is available.** They act as a compass for autonomous teams making independent decisions.
- **Keep the list short and living.** 5-10 principles that are regularly reviewed and updated. A list of 50 principles is a list nobody reads.

#### 4. Technology Radar
- **Maintain an org-specific technology radar.** Categorize technologies as Adopt/Trial/Assess/Hold. This gives teams a shared vocabulary for technology choices.
- **Hold means "stop adopting."** It doesn't mean "rip out immediately." It signals that new projects should not choose this technology and existing usage should be migrated when convenient.
- **Update quarterly.** A stale radar is worse than no radar because it creates false confidence.

### How to Fail at Decentralized Architecture
- **Taking back control.** If an architect overrides an Advice Process decision, trust collapses immediately and permanently. The whole system depends on genuine empowerment.
- **Not actually seeking advice.** Rubber-stamping decisions after the fact is not the Advice Process. The consultation must happen before the decision is made.
- **No supporting elements.** The Advice Process alone, without decision records, forums, principles, or radar, degrades into chaos. All five elements work together.

---

## Architectural Decision Heuristics

### When to Split a Service
- **Split when teams need to deploy independently** and the current shared codebase prevents that. Team autonomy is the primary driver, not technical purity.
- **Don't split when the domain boundary is unclear.** Getting a service boundary wrong is much more expensive than getting a module boundary wrong. Modules can be refactored; service boundaries involve API contracts, data ownership, and operational overhead.
- **A monolith with good module boundaries is better than microservices with unclear boundaries.** The module structure of a monolith can evolve into service boundaries when the time is right.

### When to Introduce an Abstraction Layer
- **Wait for three concrete instances before abstracting.** One case is a specific solution. Two cases might be coincidence. Three cases reveal a genuine pattern worth abstracting.
- **The abstraction must reduce total complexity.** If it adds a new concept, a new file, and a new indirection without removing existing complexity, it's not an abstraction -- it's just more code.
- **Delete abstractions that serve only one case.** They're not abstractions; they're indirection that makes the code harder to follow.
