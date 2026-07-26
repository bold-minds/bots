# Incident Response & Postmortems

## Severity Levels

| Severity | Impact | Response Time | Escalation |
|---|---|---|---|
| P1 / SEV1 | Service-wide outage, data loss risk | Immediate, all hands | Automatic to leadership |
| P2 / SEV2 | Major feature degraded, significant user impact | Within 30 minutes | On-call + team lead |
| P3 / SEV3 | Minor feature affected, workaround exists | Within 4 hours | On-call |
| P4 / SEV4 | Cosmetic, minimal impact | Next business day | Standard queue |

## Incident Roles
- **Incident Commander:** coordinates response, makes decisions, manages communication cadence. Does NOT debug.
- **Technical Lead:** diagnoses root cause, implements mitigation, coordinates technical response.
- **Communications Lead:** updates status page, notifies stakeholders, sends regular status updates.
- Regular status updates: every 30 min for P1, hourly for P2.

## Incident Workflow
1. **Detect:** alert, customer report, or monitoring anomaly.
2. **Triage:** classify severity, assign roles, open incident channel.
3. **Mitigate:** apply immediate fix (rollback, scale up, circuit breaker, rate limit).
4. **Resolve:** fix root cause, verify resolution, close incident.
5. **Postmortem:** within 48-72 hours.

## Communication Templates
- Pre-draft status page updates, customer notifications, internal escalation messages.
- Include: what is affected, what is being done, estimated time to resolution, next update time.
- On-call handoff docs: what next on-call needs to know about ongoing incidents.

## Common Mitigation Strategies
- Rollback to last known good version.
- Scale up capacity.
- Kill problematic queries.
- Enable circuit breakers.
- Apply rate limiting.
- Redirect traffic away from affected component.

## Postmortem Template

```
# Incident Postmortem: [Title]

## Summary
[2-3 sentences: what, severity, duration]

## Details
- Severity: P1/P2/P3/P4
- Duration: [start] to [end] (UTC)
- Impact: [users/requests affected, revenue impact]
- Detection: [how discovered]
- Incident Commander: [name]

## Timeline (UTC)
| Time | Event |
|---|---|
| HH:MM | [event] |

## Root Cause Analysis (Five Whys)
1. Why? Because...
2. Why? Because...
(continue to root cause)

## Contributing Factors
- [factor]

## What Went Well
- [positive]

## What Went Poorly
- [improvement area]

## Action Items
| Action | Owner | Priority | Due Date | Status |
|---|---|---|---|---|
| [fix] | [name] | P1 | YYYY-MM-DD | Open |

## Lessons Learned
[key takeaways]
```

## Postmortem Rules
- **Blameless.** Focus on systems and processes, never individuals.
- **48-72 hours** while details are fresh.
- **Single owner** who shepherds the postmortem and tracks action items.
- **Action items:** specific description, single owner, priority, due date. Track to completion.
- **Five Whys** to drill past symptoms to root cause.
- **UTC timestamps** throughout to avoid timezone confusion.
- **Share widely** — value is proportional to learning created.
- **Peer review** before publishing for accuracy and completeness.
- Write for P1/P2 always. P3 at team discretion.

## Metrics to Track
- MTTD (Mean Time to Detect), MTTR (Mean Time to Recover).
- Incident count by severity per quarter.
- Action item completion rate.
- Weekly: review action items. Monthly: review trends. Quarterly: review process.

---

## STPA: Proactive Hazard Analysis (Google SRE)

STPA (System Theoretic Process Analysis) is an MIT-originated hazard analysis method that Google adapted for pure software systems. Unlike postmortems (reactive -- learn after failure) and chaos engineering (test known failure modes), STPA systematically discovers risks you haven't imagined yet.

### Core Insight
Outages are rarely caused by a single component failing. They're caused by **unsafe control actions** -- interactions between components that are individually correct but systemically dangerous. A perfectly functioning autoscaler can cause an outage by scaling down a service that's experiencing slow-but-valid requests.

### When to Use STPA
- Designing a new system or major architectural change
- After a postmortem reveals systemic issues that Five Whys can't reach
- When multiple incidents share a pattern but have different "root causes"
- Before deploying a system that has complex control relationships (autoscalers, load balancers, feature flags, circuit breakers, deployment pipelines)

### The STPA Process for Software Systems

**Step 1: Define losses and hazards.**
What outcomes are unacceptable? (Data loss, prolonged outage, data corruption, privacy breach.) What system-level conditions lead to those outcomes? (Service overload, stale config, split-brain, cascading failure.)

**Step 2: Model the control structure.**
Draw the system as a hierarchy of controllers and controlled processes. Each controller (autoscaler, load balancer, deployment pipeline, feature flag service, human operator) sends control actions (scale up, route traffic, deploy, enable flag) and receives feedback (metrics, health checks, logs).

**Step 3: Identify unsafe control actions (UCAs).**
For each control action, ask four questions:
1. **Not providing** the action when needed causes a hazard? (Autoscaler doesn't scale up during traffic spike)
2. **Providing** the action when not needed causes a hazard? (Autoscaler scales up during a metrics pipeline delay, wasting resources and masking the real issue)
3. **Providing too early, too late, or out of order** causes a hazard? (Deploying before migrations complete)
4. **Stopping too soon or applying too long** causes a hazard? (Circuit breaker stays open after downstream recovers)

**Step 4: Identify causal scenarios.**
For each UCA, ask: what could cause this controller to take this unsafe action? Trace through: incorrect feedback (stale metrics), incorrect mental model (operator believes service is healthy when it's degraded), missing feedback (no health check for this specific failure mode), delays (metrics pipeline lag), conflicts (two controllers making contradictory decisions).

**Step 5: Design controls and mitigations.**
For each causal scenario, design a safeguard: better feedback (add a health check), constraints on control actions (max scale-down rate), redundant controllers, human approval gates for high-risk actions.

### STPA vs. Other Methods

| Method | When | Finds |
|--------|------|-------|
| Postmortem / Five Whys | After incident | What caused THIS incident |
| Chaos Engineering | During testing | How system handles KNOWN failure modes |
| STPA | Before incidents | Risks from INTERACTIONS between components you haven't tested |

### Practical Application
Run a lightweight STPA when adding any new controller to your system (autoscaler, circuit breaker, feature flag, deployment pipeline, rate limiter). Ask the four UCA questions for each control action. The exercise typically takes 1-2 hours and surfaces 3-5 risks that would otherwise become incidents.
