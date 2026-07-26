# Observability

## Three Pillars
- **Metrics:** numeric measurements over time (CPU, memory, request rate, error rate, latency).
- **Logs:** discrete events with context (structured JSON with timestamps).
- **Traces:** end-to-end request flow across distributed services.

## SLIs, SLOs, SLAs
- **SLI** (Service Level Indicator): the metric measured (request latency p99, availability %).
- **SLO** (Service Level Objective): internal target for the SLI (99.9% availability, p99 < 200ms).
- **SLA** (Service Level Agreement): contractual commitment with consequences for violation.
- Set SLOs slightly stricter than SLAs for safety buffer.
- Use error budgets (100% minus SLO target) to balance reliability with feature velocity.
- Start with business-critical services first, then expand.

## What to Monitor
- **Services (RED):** request rate, error rate, duration.
- **Resources (USE):** utilization, saturation, errors.
- **Business:** signups, transactions, revenue impact.
- **Infrastructure:** node health, disk usage, network throughput.
- **Application:** queue depth, connection pool usage, cache hit rates.

## Alerting
- Alert on symptoms (high error rate) not causes (high CPU) — symptoms are what users experience.
- Multi-window, multi-burn-rate alerting based on SLO error budgets.
- Every alert must be actionable — if no action to take, it should not page.
- Classify: page (immediate human action), ticket (next business day), log (informational).
- Proactive anomaly detection to catch issues before SLO breach.
- Descriptive alert names: `ServiceSeverityCondition`.
- Every alert links to a runbook.

## Structured Logging
- JSON format for all log output. Never unstructured plaintext in production.
- Every log entry MUST include: `timestamp` (ISO 8601 UTC), `level`, `service`, `version`, `environment`, `correlation_id`/`request_id`, `message`.
- Generate unique correlation ID at entry point (API gateway, load balancer).
- Propagate via HTTP headers (`X-Correlation-ID` or `X-Request-ID`) to all downstream services.
- Include correlation ID in every log entry and every trace span.
- Write to stdout/stderr (twelve-factor). Let the platform handle collection.
- Aggregate all logs into centralized system (ELK/EFK, Datadog, CloudWatch, Splunk).
- Same logging library and format across all services.
- Never log secrets, tokens, passwords, PII, or full credit card numbers.
- Log levels: ERROR (requires action), WARN (degraded but functional), INFO (significant events), DEBUG (development only).
- 60-70% reduction in debugging time reported with proper correlation IDs.

## Distributed Tracing
- Use OpenTelemetry. Propagate trace context across service boundaries.
- Create spans for significant operations. Name: `"OperationType TargetResource"`.
- Add attributes and record errors in spans.
- 30-45 days log retention with defined retention strategies.

## Backup & Disaster Recovery
- Define RTO (max acceptable downtime) and RPO (max acceptable data loss) per service.
- Encrypt backups at rest and in transit. Geo-replicate across regions.
- Automate backup scheduling based on data criticality. Apply RBAC to backups.
- Test full restore procedures at least quarterly. Measure actual RTO/RPO during drills.
- Use IaC so infrastructure can be recreated in recovery region. Without IaC, restoring may exceed RTO.
- Keep DR runbooks updated and accessible during outages.
