# Infrastructure & Environment Management

## Infrastructure as Code
- Version control ALL infrastructure definitions, pipeline configs, and policy rules.
- Create reusable modules for common patterns (VPC, compute cluster, database).
- Keep modules focused on a single concern with well-defined inputs/outputs.
- Split infrastructure by logical component (networking, compute, storage) each with its own state.

### State Management
- ALWAYS use remote state backends — never local state in production.
- Enable state locking to prevent concurrent modifications.
- Enable backend versioning for rollback capability.
- Encrypt state at rest and in transit — state files contain sensitive values.
- Never commit state files to Git.
- Separate state by environment in different state files or workspaces.
- Break large state into smaller files by blast radius.

### Testing
- Run `validate` and `plan` in CI before any apply.
- Use policy-as-code tools (OPA, Sentinel, Checkov) for compliance.
- Implement automated drift detection.
- Tag all resources with: environment, owner, project, cost-center, managed-by.

## Environment Management
- Development: isolated per developer/team, fast feedback, fully automated provisioning.
- Staging: must mirror production in hardware, software, configuration, and deployment methods.
- Production: requires manual approval gates.
- Use the same backing services, deployment scripts, and tools across all environments.
- Use IaC to guarantee consistency — never configure manually.
- NEVER use real customer data in non-production — violates GDPR/privacy regulations.
- Code flows one direction: dev → staging → production. Each promotion is an immutable artifact.

## Deployment Strategies
- **Blue-Green:** two identical environments, switch traffic in one action. Instant rollback. Requires 2x infrastructure.
- **Canary:** release incrementally to small subset (1% → 5% → 25% → 100%). Limits blast radius. Requires traffic splitting.
- **Rolling:** gradually replace instances one-by-one. No extra infra, but multiple versions run simultaneously.
- **Feature Flags:** decouple deployment from release. Deploy disabled, enable per-segment. Clean up stale flags.
- **Automated Rollback:** define triggers (error rate, latency, health check failures). Do not rely on human intervention.

## Cost Optimization
- Eliminate idle/unused resources (unattached volumes, stopped instances).
- Rightsize compute based on actual utilization.
- Manage storage lifecycles — move infrequent data to cheaper tiers.
- Reserved/Savings Plans for steady-state (up to 72% savings). Spot for fault-tolerant (up to 90%).
- Auto-scale to match demand — don't run at peak 24/7.
- Schedule non-prod to shut down outside business hours.
- Tag every resource. Budget alerts at 50%, 80%, 100%.
