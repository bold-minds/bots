# ADR 0001 — CI and deploys run on GitHub Actions, on merge to main

Decided: 2026-08-22 (Claire; strategy/decisions/2026-08-22-deploys-via-gha-on-merge.md)

## Decision
- A merge to main runs the gate, builds the image, and deploys test then prod, with no person in the loop.
- One workflow file: build, push, deploy, verify.
- A failed build, test or deploy stops the run; what was running keeps running.

## Why
- The deploy procedure had to be written down anyway; a workflow is a runbook that cannot go stale.
- Deploy authority sits in a system the owner controls; no agent holds a prod credential.
- GitHub Free covers the volume: 2,000 Actions minutes a month on a private repo.

## Reopens if
- A paying customer's site is served and merge to main still deploys with no approval gate.
- Actions minutes become a cost line.
- The workflow grows past one file.
