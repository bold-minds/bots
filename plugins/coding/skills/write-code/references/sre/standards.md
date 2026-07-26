# Detective — SRE, Incident Response & Observability

Standards for investigating, diagnosing, responding to, and preventing production issues. The detective is the incident commander and investigator. Detailed rules in reference files.

---

## Quick Reference

### Observability → `references/observability.md`

- Three pillars: metrics (numeric over time), logs (discrete events), traces (end-to-end request flow).
- SLIs measure, SLOs target, SLAs contractualize. Set SLOs slightly stricter than SLAs.
- RED method for services: request rate, error rate, duration. USE method for resources: utilization, saturation, errors.
- Alert on symptoms (high error rate) not causes (high CPU). Every alert must be actionable.
- Multi-window, multi-burn-rate alerting based on SLO error budgets.
- Classify: page (immediate), ticket (next business day), log (informational).

### Logging → `references/observability.md`

- Structured JSON for all logs. Every entry: timestamp (ISO 8601 UTC), level, service, version, environment, correlation_id, message.
- Generate correlation ID at entry point, propagate via `X-Correlation-ID` header to all downstream services.
- Write to stdout/stderr (twelve-factor). Centralize collection (ELK, Datadog, CloudWatch).
- Never log secrets, tokens, passwords, PII.

### Incident Response → `references/incidents.md`

- Severity levels P1-P4 with defined response times and escalation requirements.
- Roles: Incident Commander (coordinates), Technical Lead (diagnoses), Communications Lead (updates stakeholders).
- Pre-written communication templates for status pages, customer notifications, internal escalation.
- Automated rollback triggers: error rate, latency, health check failures, crash loops.

### Postmortems → `references/incidents.md`

- Blameless. "How did the system allow this?" not "Who caused this?"
- Within 48-72 hours while details are fresh.
- Five Whys to drill past symptoms to root cause. UTC timestamps throughout.
- Action items MUST have: specific description, single owner, priority, due date.
- Track action items to completion — postmortems without follow-through are useless.

### Proactive Prevention: STPA → `references/incidents.md`

- **STPA (System Theoretic Process Analysis)** is a hazard analysis method from MIT safety engineering that Google adapted for software systems. It finds risks BEFORE incidents happen, unlike postmortems which only learn after.
- The insight: outages are not caused by component failures alone — they're caused by **unsafe control actions** between components. A perfectly functioning load balancer can cause an outage if it routes traffic to a service that isn't ready.
- Use STPA when designing new systems, making significant architectural changes, or when postmortems keep finding systemic issues that Five Whys can't reach.

### Runbooks → `references/runbooks.md`

- Every alert must link to a runbook. Every runbook must link to its alert.
- Structure as decision trees, not linear scripts — branch based on symptoms.
- Include exact copy-pasteable commands with expected outputs (normal vs abnormal).
- Single purpose per runbook. Keep concise for high-pressure situations.
- Test in game days. Update after every system change.

### Backup & DR → `references/observability.md`

- Define RTO (max downtime) and RPO (max data loss) per service.
- Test full restore procedures at least quarterly. Measure actual RTO/RPO during drills.
- Use IaC so infrastructure can be recreated in recovery region.
- Encrypt backups at rest and in transit. Geo-replicate.

---

## Reference Files

- **`references/observability.md`** — SLIs/SLOs/SLAs, RED/USE methods, alerting, structured logging, correlation IDs, backup/DR
- **`references/incidents.md`** — Severity levels, incident roles, communication, postmortem template, five whys, action tracking
- **`references/runbooks.md`** — Structure template, decision trees, alert linking, testing, ownership