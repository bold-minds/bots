# Review Lenses

9 review lenses with prompt templates. Each lens defines what the `qa` agent looks for when reviewing code through that perspective. The `/check` skill loads only the lenses relevant to each package.

---

## 1. Security

Review for vulnerabilities specific to the application's domain, not generic OWASP checklists.

**Prompt template:**

Review this code for security vulnerabilities. Focus on:

- **Input trust boundaries:** Is every external input (user input, LLM output, API responses, file content) treated as untrusted? Are there paths where external data flows into privileged operations without validation?
- **Credential handling:** Can secrets leak into logs, error messages, external APIs, or stored data? Are credentials scoped to the minimum required lifetime and access?
- **Injection vectors:** Can external content manipulate system behavior (prompt injection, command injection, SQL injection, path traversal, SSRF)?
- **Authentication/authorization:** Are security checks performed BEFORE the protected action, not after? Can any check be bypassed by an unexpected code path?
- **Default-deny:** Do security gates fail closed (deny on error) or fail open (allow on error)?
- **TOCTOU:** Is there a gap between when a security check runs and when the checked value is used?
- **Cryptographic correctness:** Are comparisons constant-time? Are hashes/signatures verified before trust decisions?

Report only high-confidence findings. For each: describe the attack vector, the impact, and a specific fix.

---

## 2. Performance

Review for performance issues that affect users or costs, not premature optimization.

**Prompt template:**

Review this code for performance issues. Focus on:

- **Hot path latency:** Is there unnecessary work on the critical request path? Redundant serialization, repeated computation, synchronous I/O that could be async?
- **Resource contention:** Are shared resources (mutexes, semaphores, DB connections, connection pools) held longer than necessary? Can contention cause cascading delays?
- **Memory allocation:** Are large buffers allocated per-request when they could be pooled or streamed? Are unbounded reads (io.ReadAll) used on untrusted input?
- **Caching:** Is repeated identical work cached? Are cache invalidation boundaries correct?
- **Concurrency utilization:** Are independent operations serialized when they could run in parallel? Are concurrency limits calibrated?
- **Cost efficiency:** For paid APIs (LLM, cloud services), is there unnecessary duplication of requests? Are results cached/reused within a session?

Report with estimated impact: latency (user-visible delay), cost ($/month), or scale (breaks at N concurrent users).

---

## 3. Staff Engineer

Review for code quality, maintainability, and adherence to project standards.

**Prompt template:**

Review this code against the project's CLAUDE.md standards and general engineering best practices. Focus on:

- **Size limits:** Do any files exceed the project's line limit? Do any functions exceed the function size limit? Identify extraction boundaries.
- **Error handling:** Is every error handled? Are errors wrapped with context? Are errors logged AND returned (double-logging)? Are typed sentinel errors used where callers need to distinguish cases?
- **Naming and organization:** Are names descriptive? Is code organized by logical concern? Are there utility/helper packages that should be inlined?
- **Dependency direction:** Do imports follow the project's layer rules? Are interfaces defined on the consumer side?
- **Tech debt indicators:** TODO/FIXME/HACK comments, //nolint directives on security linters, commented-out code, functions with >8 parameters.
- **Abstraction quality:** Are abstractions earning their complexity? Is there premature generalization or unnecessary indirection?

Rate each finding: [DEBT-CRITICAL] blocks next feature, [DEBT-HIGH] will compound, [DEBT-MEDIUM] fix next quarter.

---

## 4. Architect

Review for structural design quality and future extensibility.

**Prompt template:**

Review this code for architectural concerns. Focus on:

- **Layer violations:** Does the code respect the project's dependency direction rules? Are there imports that bypass the intended architecture?
- **Interface design:** Are interfaces minimal (1-3 methods ideal)? Are they defined where consumed, not where implemented? Do god-structs with 10+ fields need decomposition?
- **Coupling:** Can components be changed independently? Would a change to this code force changes in unrelated code?
- **Extensibility:** Can new capabilities (tool types, backends, providers) be added without modifying existing switch statements or dispatch logic?
- **Separation of concerns:** Is orchestration mixed with execution? Is configuration mixed with behavior? Is I/O mixed with business logic?
- **Scaling boundaries:** What prevents this from running as a distributed system? What state is shared that would need to be externalized?

Report: [ARCH-RISK] prevents scaling, [ARCH-DEBT] makes evolution harder, [ARCH-OK] well-designed.

---

## 5. Product Owner

Review for feature completeness and user-facing quality.

**Prompt template:**

Review this code from a product perspective. Focus on:

- **User-facing errors:** When something fails, what does the end user see? Is it actionable or generic? Does it expose internal details?
- **Feature completeness:** Are there obvious capabilities missing that users would expect? How does this compare to alternatives?
- **Discoverability:** Can users find all available features? Is there inline help? Are new capabilities documented?
- **Configuration experience:** When configuration has errors, are messages actionable? Is there validation before runtime failure?
- **Observability for users:** Can users see what the system is doing? Job progress, costs, history, debugging information?

Report: [PRODUCT-GAP] missing expected feature, [PRODUCT-FRICTION] works but hard to use, [PRODUCT-RISK] competitive disadvantage.

---

## 6. SRE

Review for operational reliability and observability.

**Prompt template:**

Review this code for operational concerns. Focus on:

- **Graceful degradation:** When a dependency is down (API, database, external service), does the system queue, fail fast, or hang? Are there circuit breakers and timeouts?
- **Health checks:** Are health/readiness probes comprehensive? Do they check all critical dependencies? Are there gaps in monitoring?
- **Crash recovery:** What happens to in-flight work when the process restarts? Is state recoverable? Are stale resources cleaned up?
- **Observability:** Are there metrics for latency, error rates, resource utilization? Are logs structured and at appropriate levels? Is tracing wired?
- **Deployment safety:** Can the system be rolled back? Are migrations reversible? Is there a readiness gate before accepting traffic?
- **Resource management:** Are goroutines/threads tracked and stoppable? Are connections pooled and bounded? Are file handles closed?

Report: [OPS-CRITICAL] will cause outage, [OPS-HIGH] degraded service, [OPS-MEDIUM] operational friction.

---

## 7. QA

Review for test quality and coverage.

**Prompt template:**

Review the test code and coverage for this package. Focus on:

- **Coverage gaps:** What error paths have no test assertions? What success paths are untested? Are edge cases covered (empty input, nil, maximum values, unicode)?
- **Mock fidelity:** Do mocks/fakes simulate failure modes (timeouts, rate limits, malformed responses, OOM) or only happy paths? Happy-path-only mocks create false confidence.
- **Test isolation:** Can tests run in parallel without interference? Are resources cleaned up? Are there flaky time.Sleep patterns?
- **Negative tests:** Are there tests proving the ABSENCE of bad behavior (e.g., secret NOT in output, denied action NOT executed)?
- **Regression coverage:** Do bug-fix references in code comments have corresponding regression tests?
- **Non-deterministic testing:** For LLM or random outputs, how are tests controlled? Fixed seeds? Fixture responses?

Report: [QA-GAP] untested scenario with risk level, [QA-WEAK] test exists but insufficient, [QA-GOOD] well-tested area.

---

## 8. Legal

Review for compliance and data handling concerns.

**Prompt template:**

Review this code for legal and compliance concerns. Focus on:

- **Data retention:** Is there a defined retention period for stored data? Can data be deleted on request (right to erasure)?
- **PII inventory:** What personally identifiable information is stored? User IDs, names, emails, messages, IP addresses? Is it documented?
- **Third-party data flow:** Is user data sent to external services? Is this disclosed to users? Are data processing agreements in place?
- **License compliance:** Are dependency licenses compatible with the project's license? Any AGPL/GPL copyleft risk?
- **AI content disclosure:** Is AI-generated content labeled? Is there attribution to the model that generated it?
- **Audit trail:** Can the system prove who did what, when, and with what outcome? Is the trail tamper-evident?

Report: [LEGAL-RISK] regulatory exposure, [LEGAL-GAP] missing policy/control, [LEGAL-OK] adequately handled.

---

## 9. UX

Review for user interaction quality (applicable when the package has user-facing surfaces).

**Prompt template:**

Review this code for user experience concerns. Focus on:

- **Progress visibility:** During long operations, does the user see what's happening? Phase progress, estimated time, intermediate results?
- **Error communication:** Are error messages formatted for readability? Do they include "what to do next" guidance? Are internal details hidden?
- **Information density:** Are large outputs truncated with "see more" options? Are code blocks, formatting, and icons used for scannability?
- **Threading/organization:** Are related messages grouped (threaded replies vs channel flood)? Is the conversation structure logical?
- **Discoverability:** Is help available inline? Are unknown commands met with "Did you mean?" suggestions? Is the full capability surface documented?
- **Consistency:** Do similar operations produce similar feedback patterns? Are status indicators, icons, and formatting consistent?

Report: [UX-GOOD] well-designed, [UX-IMPROVE] works but could be better, [UX-MISSING] expected pattern not implemented.
