# DevOps — CI/CD, Containers, Infrastructure & Security

Standards for CI/CD pipelines, containers, infrastructure, and release management. Mandatory. Detailed rules in reference files.

---

## Quick Reference

### CI/CD → `references/cicd.md`

- Order stages by speed: lint → unit tests → integration → E2E → deploy.
- Build once, deploy everywhere — never rebuild per environment.
- Run independent stages in parallel. Use matrix builds for cross-platform.
- Pin GitHub Actions to full SHA. Use OIDC for cloud auth. Read-only GITHUB_TOKEN by default.
- Cache dependencies using lockfile hashes. Shard large test suites across runners.
- Quarantine flaky tests — remove from blocking CI, fix within SLA, promote back after verification.
- Track DORA metrics: deployment frequency, lead time, change failure rate, MTTR.

### Containers → `references/containers.md`

- Multi-stage builds: build in full SDK, run in minimal image (Alpine/distroless).
- Copy dependency manifests before source code for layer caching.
- Run as non-root. Drop all capabilities. Read-only filesystem. No secrets in images.
- Pin base images by digest hash. Scan for vulnerabilities in CI.
- Separate readiness probes (traffic routing) from liveness probes (restart triggers).
- One concern per container. Design as ephemeral. Graceful SIGTERM handling.

### Infrastructure → `references/infrastructure.md`

- Version control all infrastructure definitions.
- Remote state backends only. State locking. Encrypt state. Never commit state to Git.
- Staging must mirror production. Never use real customer data in non-prod.
- Code flows one direction: dev → staging → production. Immutable artifacts at each promotion.
- Deployment strategies: blue-green (instant rollback), canary (gradual exposure), rolling (no extra infra), feature flags (decouple deploy from release).

### Security → `references/security.md`

- Supply chain: SLSA provenance, Sigstore for signing, SBOM with every release.
- Secrets: centralized vault, automated rotation, least privilege, mount as volumes not env vars.
- GitHub Actions: restrict third-party actions, CODEOWNERS on workflows, ephemeral runners, no script injection.
- Never hardcode secrets in code, config, or images. Never commit to version control.

### Release → `references/release.md`

- Automate releases with semantic-release (zero-touch) or release-please (review before release).
- Tag with `v` prefix, annotated tags, never delete after publication.
- Immutable artifacts. Store in registries, not source control. SHA256 checksums.
- RBAC on artifact management: CI publishes, devs read, admins delete.

---

## Build System: Task Only

Use [Task](https://taskfile.dev) (`Taskfile.yml`) for all build automation. Never use Make/Makefile.

- Task provides better cross-platform support, clearer YAML syntax, and proper error handling.
- All build, test, lint, and validation commands must be defined as Task targets.
- Run `task` with no arguments to execute the default target (typically build + lint + test).

---

## Validation Script Pattern

Every project should have a `validate.sh` (or equivalent) as the single source of truth for shippability.

**Run after:** package restructuring, file renames, new dependencies, before PRs, before deploys.

**Checks (in order):** environment → linting → build → unit tests → integration tests → coverage → git cleanliness (CI mode).

**All steps always run.** Use `|| true` so all steps execute even when early steps fail. Complete picture of what's broken. Exit code 1 if any failed.

---

## Linting: golangci-lint (Go Projects)

Required linters: depguard, errcheck (check-type-assertions), godox, gosec, govet, ineffassign, staticcheck, unused.

- Require explanation and specific linter name for all `//nolint` directives.
- Exclude test files from bodyclose, dupl, errcheck, funlen, goconst, gosec, noctx, wrapcheck.

---

## Documentation Standards

Every project MUST have: `README.md`, `docs/ARCHITECTURE.md`, `docs/QUICKSTART.md`, `docs/SCHEMA.md`, `docs/OPERATIONS.md`, `.github/SECURITY.md`.

GitHub templates required: PR template, bug report, feature request, CODEOWNERS.

CHANGELOG.md using Keep a Changelog format with Added/Changed/Fixed/Deprecated/Removed/Security sections.

---

## Reference Files

- **`references/cicd.md`** — Pipeline design, GitHub Actions, build optimization, flaky tests, DORA metrics, anti-patterns
- **`references/containers.md`** — Docker multi-stage builds, image size, layer caching, 12 security rules, health checks, container design
- **`references/infrastructure.md`** — IaC, state management, environment management, deployment strategies, cost optimization
- **`references/security.md`** — SLSA, Sigstore, SBOM, secrets management, GitHub Actions hardening
- **`references/release.md`** — Release automation tools, tagging, artifact management
- **`references/modern-deployment.md`** — Kamal for solo devs, faasd serverless without Kubernetes, Observability 2.0 (wide events, read-time aggregation), SRE-informed development practices

For monitoring, incident response, postmortems, and runbooks, use the `/detective` skill.