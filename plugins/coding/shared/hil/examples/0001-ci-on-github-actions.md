# ADR 0001 — CI and deploys run on GitHub Actions, on merge to main

Decided: 2026-09-13 (Claire)

## Decision
- A merge to main runs the gate, builds the image, and deploys test then prod, with no person in the loop.
- One workflow file: build, push, deploy, verify.
- A failed build, test or deploy stops the run; what was running keeps running.

## Options
- Deploy by hand over SSH: no procedure written down, and an agent session would need prod SSH, which the harness denies.
- DigitalOcean's own deploy-on-push from the registry: cannot order test before prod, and cannot gate prod on test's health check.
- Faster hosted runners (Blacksmith, Depot): a second vendor and bill for speed a ~8-minute run inside GitHub Free does not need.
- Another CI (CircleCI, Buildkite): a second vendor for what the repo's host already includes at no cost.

## Why
- The deploy procedure had to be written down anyway; a workflow is a runbook that cannot go stale.
- Deploy authority sits in a system the owner controls; no agent holds a prod credential.
- GitHub Free covers the volume: 2,000 Actions minutes a month on a private repo.
