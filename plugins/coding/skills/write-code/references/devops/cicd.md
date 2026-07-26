# CI/CD Pipeline Design

## Stage Ordering
- Run fastest checks first: linting, formatting, static analysis (seconds) → unit tests (seconds-minutes) → integration tests (minutes) → E2E tests (minutes-tens of minutes) → security scans (parallel with tests) → deployment.
- Build once, deploy everywhere. Create a single build artifact per commit and promote through all stages. Never rebuild per environment.
- Embed environment-specific config through deployment scripts, not build artifacts.

## Parallelism
- Run independent stages in parallel (linting, unit tests, security scans have no dependencies on each other).
- Use matrix builds for cross-version/cross-platform testing.
- Shard test suites across multiple runners using timing-based distribution (not alphabetical).

## Fail-Fast vs Complete
- Fail-fast for PR checks: `fail-fast: true` in matrix strategies. One failure cancels the rest.
- Complete for release validation: `fail-fast: false` for full compatibility reporting.
- Cancel redundant runs: use `concurrency` groups with `cancel-in-progress: true` when new commits push to the same PR.

## GitHub Actions Best Practices
- Pin ALL third-party actions to full-length commit SHAs. Tags can be force-pushed. SHA is the only immutable reference.
- Cache dependency directories using lockfile hashes: `hashFiles('**/package-lock.json')`. Reduces install from minutes to seconds.
- Use OIDC for all cloud provider auth (AWS, Azure, GCP). Eliminates long-lived secrets entirely.
- Never interpolate untrusted context values directly into `run:` scripts (`github.event.pull_request.title`, `github.head_ref`). Use intermediate environment variables.
- Set org-level default GITHUB_TOKEN to read-only. Grant elevated permissions only at job level.
- Use environment secrets with required reviewers for production credentials.
- Store reusable workflows in `.github/workflows/`, composite actions in `.github/actions/`.
- Version shared actions/workflows with semantic tags. Never use `@main` in production.
- Pin to commit SHA or tag in production workflows.

## Build Optimization
- Dependency caching: cache using lockfile hashes. 90%+ install time reduction.
- Docker layer caching: order Dockerfile with infrequently-changing content first. Enable BuildKit.
- Test result caching: use change-based test selection (`git diff` against merge base).
- Monorepo affected-only pipelines: only build/test/lint packages affected by the current change.
- Record median and P95 durations per stage. Set build time budgets. Alert when exceeded.

## Flaky Test Handling
- Detect automatically: rerun-based (run 20-50 times on same commit) or historical (>2% failure rate over 14-day window).
- Quarantine: remove from blocking CI but continue running. Failures don't block pipeline.
- Quarantine is temporary: define SLAs for fix timelines. Assign to code owners. Promote back after verification period.
- Fix root causes: replace hard-coded waits with explicit waits, use stable selectors, mock unstable services, isolate test data.

## DORA Metrics
1. Deployment Frequency: how often to production. Elite: multiple times per day.
2. Lead Time for Changes: commit to production. Elite: less than one hour.
3. Change Failure Rate: % of deployments causing failures. Elite: 0-15%.
4. Mean Time to Recovery: time to restore service. Elite: less than one hour.
- Dashboard these visibly for the team.

## Anti-Patterns
- Monolithic pipeline running everything sequentially for 45+ minutes — split into parallel stages.
- Rebuilding per environment — promote the same artifact.
- No fail-fast — linting should catch issues before the full test suite runs.
- Single pipeline owner — shared team responsibility.
- Bypassing the pipeline for "urgent" changes — these cost more in debugging.
- Ignoring failed builds — treat as requiring immediate resolution.
