# ADR 0001 — CI and deploys run on GitHub Actions, on merge to main

Decided: 2026-09-13 (Claire)

## Decision
- A merge to main runs the gate, builds the image, and deploys test then prod, with no person in the loop.
- One workflow file: build, push, deploy, verify.
- A failed build, test or deploy stops the run; what was running keeps running.

## Options
GitHub — Actions, chosen.
- Pro: included with the repo's host; 2,000 minutes a month on a private repo at no cost
- Pro: a run of about 8 minutes; roughly 250 runs a month inside the free tier
- Pro: environments, secrets and a branch policy for prod in the same place as the code
- Con: the slowest runners of the options; fine at this volume
- Health: GitHub's own product, status page public, no end of life announced; checked 2026-09-13

Nobody — deploys by hand over SSH, the state before this.
- Con: no procedure written down; the only record was a build log
- Con: an agent session would need prod SSH, which the harness denies

DigitalOcean — deploy-on-push from the registry, rejected.
- Pro: no workflow file at all
- Con: cannot order test before prod
- Con: cannot gate prod on test's health check

Blacksmith or Depot — faster hosted runners, rejected.
- Pro: faster builds
- Con: a second vendor and a bill, for speed an 8-minute run does not need

CircleCI or Buildkite — a separate CI, rejected.
- Con: a second vendor for what the repo's host already includes

## Why
- The deploy procedure had to be written down anyway; a workflow is a runbook that cannot go stale.
- Deploy authority sits in a system the owner controls; no agent holds a prod credential.
- GitHub Free covers the volume.
