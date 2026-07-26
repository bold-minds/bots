# Craft — Language-Agnostic Code Quality

These standards apply to all code in all languages. They are mandatory.

---

## Reliability & SRE

### Timeouts & Failure Handling

- **Every external call must have a bounded timeout.** Database queries, HTTP requests, queue operations, file I/O — all of them. Never rely on default infinite timeout behavior.
- **Design for partial failure.** When a dependency is down, prefer partial functionality over total failure. A non-essential call failure must not crash the whole request. Use bulkheads to isolate failures.
- **Fail-safe defaults.** If configuration is missing, use safe defaults. If a dependency is unavailable, degrade gracefully. Debug modes disabled by default.
- **Validate all configuration at startup and fail fast if invalid.** Do not discover bad config at runtime.

### Retries

- **Only retry transient errors.** 503 is retryable. 400 is not. Distinguish retryable from non-retryable errors explicitly.
- **Exponential backoff with jitter.** Never retry in a tight loop. Jitter prevents thundering herd.
- **Limit total retry attempts AND total retry time.** Track retry rates in metrics.
- **Operations that may be retried must be idempotent.** Use idempotency keys for mutating operations, unique constraints, or upsert semantics.

### Circuit Breakers

- **Implement circuit breakers for external dependencies.** Three states: closed (normal), open (failing fast), half-open (probing recovery).
- **Define failure thresholds** that trigger the circuit to open.
- **Define recovery probes** that test if the dependency is healthy again.

### Health Checks

- **Liveness check:** Is the process running? No external dependency checks. Must respond in <100ms. Used by orchestrators to know if the process needs restart.
- **Readiness check:** Can this instance serve traffic? Verifies critical dependencies (DB connected, cache reachable). Used by load balancers.
- **Startup probe:** For services with slow initialization. Prevents premature liveness failures during boot.

### Graceful Shutdown

- Handle termination signals (SIGINT, SIGTERM) with signal handlers.
- Complete or timeout in-flight requests with a shutdown context.
- Wait for background tasks to complete with a max shutdown wait time.
- Close resources in reverse order of initialization.

### Capacity Management Over Rate Limiting (Jon Moore, Strange Loop 2017)

Rate limiting (requests/second per client) is the wrong abstraction. It ignores what actually matters: whether the system can handle the work.

- **Use concurrency limiting, not rate limiting.** Limit simultaneous in-flight requests, not requests per second. When a service degrades (response time doubles), a fixed concurrency limit automatically halves throughput — protecting the system without manual intervention.
- **Little's Law: N = X × R.** Capacity (N) = throughput (X) × service time (R). When R increases under load, a fixed rate limit X becomes dangerous because N (actual load) grows. Concurrency limiting holds N constant, so X naturally decreases.
- **AIMD for adaptive capacity discovery.** When true capacity is unknown or elastic, use Additive Increase / Multiplicative Decrease: increase allowed concurrency by a constant per interval (+1/sec), decrease by a fraction (×0.75) when the service signals overload (429, 5xx, timeout). This discovers sustainable capacity dynamically.
- **Concurrency limits are composable.** Each client independently tracks its own in-flight count. No centralized coordination needed. Decentralized enforcement scales naturally.

### Statelessness

- Server processes must be stateless: no in-memory sessions as source of truth, no reliance on local disk for durable data.
- Use queues/background jobs for long-running work, non-critical post-processing, and high-volume fan-out.
- Configure dead-letter queues for repeatedly failing jobs.

---

## API Design

### REST Conventions

- **Design APIs around resources, not actions.** Use plural nouns, lowercase with hyphens. Colons for actions when needed (`/resources/{id}:archive`).
- **Use correct HTTP methods** with their idempotency and safety semantics:
  - GET (safe, idempotent) — read
  - POST (neither) — create
  - PUT (idempotent) — full replace
  - PATCH (neither) — partial update
  - DELETE (idempotent) — remove
- **Use comprehensive HTTP status codes:** 200, 201, 204, 400, 401, 403, 404, 409, 422, 429, 500, 502, 503, 504. Each has a specific meaning — use the right one.
- **snake_case for JSON fields.** No camelCase, no PascalCase in JSON.

### Response Shape

- Return resources directly (no wrapper) for single resources.
- Wrap collections with pagination metadata.
- ISO 8601 format with UTC timezone for all timestamps.

### Pagination

- Support cursor-based pagination for large datasets and offset-based for simple cases.
- Default limit: 20. Max limit: 100.
- Never return unbounded lists. Always paginate.

### Filtering & Sorting

- Filtering via query parameters.
- Consistent sort syntax: `?sort=field:asc` or `?sort=field:desc`.

### Versioning

- URL path prefix: `/api/v1/...`
- Deprecation lifecycle: current → deprecated (with `Deprecation` header and sunset date) → sunset.
- Maintain backward compatibility within a version.

### Rate Limiting

- By IP for unauthenticated, by user/key for authenticated.
- Return `429 Too Many Requests` with `Retry-After` header.
- Include rate limit headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.

### API Documentation

- Maintain OpenAPI 3.0+ specifications for all APIs.
- Validate implementations against specs in CI.
- Provide curl-based examples for every endpoint.

---

## Database Conventions

### Naming

- **Table names:** plural snake_case (`user_accounts`, not `UserAccount` or `user_account`).
- **Column names:** snake_case.
- **Indexes:** explicit names with pattern `table_column_idx`.
- **Foreign keys:** `table_referenced_table_fk`.
- **Constraints:** descriptive names (`users_email_unique`, `orders_status_check`).

### Standard Columns

- Mutable tables must have `created_at TIMESTAMPTZ NOT NULL DEFAULT now()` and `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()` with auto-update triggers.
- Soft deletes: `deleted_at TIMESTAMPTZ` (nullable) with partial index on `deleted_at IS NULL`.

### Types

- **Money:** NUMERIC, never FLOAT.
- **Timestamps:** TIMESTAMPTZ, never TIMESTAMP (always store timezone).
- **IDs:** UUIDs or ULIDs generated in the application layer, not SERIAL/BIGSERIAL.
- **Status columns:** enforced with CHECK constraints or database enums, not free-form strings.
- **Booleans:** positive descriptive names (`is_active`, `is_public`); never negated (`is_disabled`).
- **JSONB:** for flexible metadata only, not core relational fields. Document the intended structure.

### Queries

- Avoid N+1 query patterns; use batching, joins, and IN queries.
- Use prepared statements for repeated queries.
- Batch operations for bulk data (single INSERT with multiple values).
- Cursor-based pagination for large datasets.

### Transactions

- Use transactions for multi-statement operations.
- Choose appropriate isolation levels.
- Prevent deadlocks by acquiring locks in consistent order.

### Migrations

- Numbered migration files with up/down pairs.
- Migrations must be backward compatible: never remove columns in use; add new columns as nullable or with defaults.
- Destructive changes use two-step migrations: add new → backfill → switch → drop old.
- Large table operations: `CREATE INDEX CONCURRENTLY`, batched backfills.
- No ad-hoc DDL via cloud consoles or application startup code.

### Connection Pools

- Configure explicitly: max open connections, max idle connections, connection max lifetime, idle timeout.
- Use a shared connection/pool module; all server code reuses this module.

---

## Observability

### Structured Logging

- Use structured logging (key-value / JSON fields) everywhere. No raw string interpolation for log messages.
- Define standard log field constants across services: `request_id`, `trace_id`, `span_id`, `operation`, `duration_ms`, `status_code`, `error_code`, `service`, `version`.
- Log request lifecycle with middleware: log request start and completion with request_id, method, path, status_code, duration_ms.
- One log per error at the handling site. Log OR return, not both.

### Metrics (Prometheus Convention)

- Naming: `namespace_subsystem_name_unit` with `_total` suffix for counters.
- Low-cardinality labels only: method, status_code, error_type. **Never** user_id or request_id as labels.
- Choose appropriate histogram buckets for different latency ranges.

### Distributed Tracing

- Use OpenTelemetry for distributed tracing.
- Propagate trace context across service boundaries.
- Create spans for significant operations. Span naming: `"OperationType TargetResource"`.
- Add attributes and record errors in spans.

### Alerting

- Define alert severities (Critical/High/Medium/Low) with response time expectations.
- Descriptive alert names: `ServiceSeverityCondition`.
- Every alert must link to a runbook.

---

## Configuration Management

### Priority

Configuration source priority (highest to lowest):
1. CLI flags
2. Environment variables
3. Config files
4. Code defaults

### Startup

- Use strongly-typed configuration structs (not raw string maps).
- Log effective configuration at startup, redacting secrets.
- Required secrets must cause fail-fast with clear error message if missing.
- Non-secret config should have code-level defaults so the service runs even if the var is unset.

### Secrets

- Support secret rotation without service restart.
- Never log secret values. Never include in error messages.
- Document how to generate secrets with concrete commands.

### Feature Flags

- Use structured feature flags with percentage-based gradual rollout for risky changes.
- Feature flags enable quick rollback without deploy.

### Hot Reload

- Non-critical config (log level, feature flags, rate limits, timeouts): support hot reload.
- Critical config (port, DB URL, TLS certs): require restart.

### Environment Detection

- Explicit environment detection (development/staging/production).
- Production safeguards: require TLS, require authentication, reject development secrets.

### Documentation

- Maintain `.env.example` files with header block describing service name, minimal required vars, and quick-start steps.
- Group variables by importance: REQUIRED / RECOMMENDED / OPTIONAL.

---

## Git Workflow

### Conventional Commits

Format: `type(scope): subject`

| Type | Purpose |
|------|---------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| test | Adding or updating tests |
| refactor | Code refactoring |
| perf | Performance improvement |
| chore | Maintenance |
| ci | CI/CD changes |

### Branch Naming

`type/TICKET-short-description` (e.g., `feat/PROJ-123-add-user-auth`)

### Pull Requests

- Keep PRs under 400 lines of changes.
- Single logical change per PR.
- Require at least one approving review, all CI checks passing, no unresolved conversations.
- Prefer squash-and-merge for feature branches.

### Force Push

- Never bare `git push --force`. Always `--force-with-lease`.

### CHANGELOG

- Maintain CHANGELOG.md using Keep a Changelog format.
- Sections: Added, Changed, Fixed, Deprecated, Removed, Security.
- Versions in descending order. `[Unreleased]` section at top.
- Update as changes are made, not at release time.

### Releases

- Annotated tags for releases with semantic versioning.
- Git tags match CHANGELOG versions: `v1.0.0`.

### Hotfix Process

- Branch from latest release tag.
- Minimal fix only — no feature work.
- Expedited review.
- Tag new patch release.

---

## Feature Completeness

### Definition of Done

A feature is not done until:
- All documented functionality works
- Edge cases are handled
- Error states are handled
- Input validation is in place
- Tests cover the new behavior
- Documentation is updated
- Metrics/observability are in place
- Security implications are addressed
- Backward compatibility is maintained (or breaking change is documented)

### No Partial Implementations

- All announced endpoints must be functional.
- All documented parameters must work.
- No placeholder code in production.

### Boy Scout Rule

When you touch a file that contains smells, make at least one small improvement or add an explicit TODO with owner, description, and scope. Adding more code to a mess without improving it is not acceptable.

### Consistent Naming

The same domain concept must use consistent names across database columns, backend services, APIs, frontend stores, props, and components. No ad-hoc renaming across layers.

---

## Code Review Standards

Based on Google's engineering practices for effective code review.

### Approval Philosophy

- **Approve when the CL improves overall code health**, even if it is not perfect. No codebase is ideal; incremental improvement is the goal.
- Technical facts and data override personal opinions. The style guide is authoritative for style questions — if it is not in the style guide, it is a preference, not a requirement.

### Review Checklist

Every review must evaluate:
- **Correctness:** Does the code do what it claims?
- **Design:** Is this the right abstraction? Does it belong in this module?
- **Complexity:** Can another engineer understand and modify it without introducing bugs?
- **Tests:** Correct, meaningful, and covering the change. Tests must fail without the change.
- **Naming:** Clear, descriptive, consistent with project conventions.
- **Comments:** Explain WHY, not WHAT. No commented-out code.
- **Style:** Consistent with the project style guide.
- **Security:** No injection vectors, no exposed secrets, no broken auth.
- **Performance:** No unnecessary allocations, no N+1 queries, no unbounded growth.
- **Architectural compliance:** Changes align with existing ADRs.

### Turnaround

- **Maximum one business day** for initial review response.
- **Target: 4 hours** for standard changes.
- **Small changes (< 50 lines):** respond within 1 hour.
- If you cannot review in time, reassign or acknowledge with an ETA.

### Approval Requirements

- At least **one code owner** approval required for all changes.
- **Two approvals** required for critical paths: authentication, authorization, payments, data migrations, infrastructure.

### Comment Etiquette

- **LGTM with non-blocking comments is acceptable.** Prefix optional suggestions with `Nit:` to signal they are non-blocking.
- Distinguish between "must fix before merge" and "consider for future."
- Provide concrete suggestions, not vague criticism. Show the better code, not just "this is wrong."

---

## Architecture Decision Records

### When to Write an ADR

Write an ADR for **architecturally significant decisions** — those affecting:
- System structure or decomposition
- Non-functional requirements (performance, security, scalability)
- External dependencies or third-party integrations
- Public interfaces or API contracts
- Construction techniques (frameworks, languages, deployment strategies)

### Template

**Minimum required fields:**

```
# NNNN - Title

## Status
[Proposed | Accepted | Rejected | Deprecated | Superseded by NNNN]

## Context
What is the issue? What forces are at play?

## Decision
What is the change being proposed or decided?

## Consequences
What are the positive, negative, and neutral effects?
```

**Extended fields** (recommended for significant decisions):
- **Date:** When the decision was made.
- **Decision Makers:** Who was involved in the decision.
- **Options Considered:** What alternatives were evaluated.
- **Rationale:** Why this option was chosen over alternatives.

### Lifecycle

- **Proposed:** The ADR is open for discussion. Content is mutable.
- **Accepted or Rejected:** The decision is finalized. Content is **immutable**. Corrections of typos are allowed; substantive changes are not.
- **Changes require a new ADR** that explicitly supersedes the original. The original ADR's status is updated to `Superseded by NNNN`.

### Conventions

- **One decision per ADR.** Do not bundle multiple decisions.
- **Focus on WHY.** The context and rationale matter more than the decision itself.
- **Single owner.** One person is responsible for driving the ADR to a decision.
- **File naming:** `docs/adr/NNNN-short-title.md` (zero-padded sequence number, lowercase, hyphen-separated).

---

## Twelve-Factor App

Build SaaS apps that are portable, scalable, and operationally sound. The twelve factors are: (I) one codebase, many deploys; (II) explicit dependency declaration and isolation; (III) config in environment variables; (IV) backing services as attached resources; (V) strict build/release/run separation; (VI) stateless processes; (VII) port binding; (VIII) concurrency via the process model; (IX) fast startup, graceful shutdown; (X) dev/prod parity; (XI) logs as event streams to stdout; (XII) admin tasks as one-off processes.

See `references/twelve-factor.md` for the full detailed table.

See `references/architecture-wisdom.md` for Bounded Context, Transitional Architecture, the Advice Process for decentralized architectural decision-making, and architectural decision heuristics.
