# Runbooks

## Structure Template

```
# Runbook: [Service/Alert Name]

## Overview
[One paragraph: what this runbook covers]

## Alert Reference
- Alert name: [exact name]
- Severity: P1/P2/P3/P4
- Dashboard: [link]
- Service owner: [team/person]

## Prerequisites
- Required access/permissions
- Required tools

## Diagnosis Steps
1. [Step with exact command]
   Expected output: [what normal looks like]
2. [Step with exact command]
   Expected output: [what normal looks like]
3. Decision: if [condition A], go to step 4. If [condition B], go to step 6.

## Mitigation Steps
1. [Exact remediation command]
2. [Verification command]
3. [Expected result after mitigation]

## Escalation
- When to escalate
- Who to contact
- Escalation channels

## Rollback Procedure
[Steps to undo mitigation if it causes issues]

## Post-Incident
- [ ] Create incident ticket
- [ ] Update runbook if steps were inaccurate
- [ ] Schedule postmortem if severity warrants
```

## Key Rules
- **Every alert links to a runbook. Every runbook links to its alert.**
- **Single purpose:** one scenario per runbook. Split if too many steps.
- **Decision trees:** structure as branches based on symptoms, not linear scripts.
- **Exact commands:** copy-pasteable, not vague instructions.
- **Expected outputs:** show what normal vs abnormal looks like.
- **Ownership:** service teams own service runbooks; SRE/Ops own infrastructure runbooks.
- **Review cadence:** update after system changes, SLO updates, tooling changes, or process changes.
- **Test regularly:** run through in game days or incident simulations.
- **Keep concise:** only details needed during high-pressure situations. Link to deeper docs for background.
