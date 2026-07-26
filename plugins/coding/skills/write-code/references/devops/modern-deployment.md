# Modern Deployment Reference

Distilled from: Kamal docs, Charity Majors' Observability 2.0 (Honeycomb), willett.io SRE precepts, faasd/OpenFaaS docs, and related sources.

---

## Kamal for Solo Devs

### What It Is

Kamal deploys containerized web apps to any server (bare metal, cloud VMs) using Docker + Traefik. Zero-downtime deploys without Kubernetes complexity. Originally built for Rails but works with any containerized app.

### Why Not Kubernetes

"Kubernetes is a beast. Running it yourself on your own hardware is not for the faint of heart." Kamal uses imperative commands (like Capistrano) instead of declarative reconciliation. You see exactly what happens during deploy.

### When to Use Kamal

- Solo dev or small team deploying to 1-10 servers
- You want to own your infrastructure without vendor lock-in
- You need zero-downtime deploys without the K8s learning curve
- You want portability across providers (DigitalOcean, Hetzner, AWS, bare metal)

### When NOT to Use Kamal

- Auto-scaling beyond a few servers (use K8s or managed services)
- Complex service meshes with dozens of microservices
- Team already has Kubernetes expertise and infrastructure

### Core Workflow

1. Configure `deploy.yml` with server IPs, Docker image, environment
2. `kamal setup` -- provisions fresh Ubuntu with Docker, deploys app
3. `kamal deploy` -- builds, pushes image, performs rolling restart via Traefik
4. `kamal app logs` -- tail production logs
5. `kamal rollback` -- revert to previous version

### Key Capabilities

- **Rolling restarts** with asset bridging for zero-downtime
- **Remote builds** -- build on server, not local machine
- **Accessory management** -- run databases, Redis alongside app
- **Multi-server** -- deploy to multiple servers in parallel
- **Secrets** -- managed via environment variables with `.env` files

---

## faasd: Serverless Without Kubernetes

### What It Is

faasd is OpenFaaS reimagined for single-host deployment. Runs as a systemd service using containerd and CNI. Distributed as a single binary.

### When to Use faasd

- Functions/webhooks on a single $5-10/month VPS
- Background jobs, cron tasks, event handlers
- Learning serverless without cloud vendor lock-in
- Raspberry Pi or edge computing
- You want OpenFaaS API compatibility without K8s overhead

### When to Use Managed Serverless Instead

- Auto-scaling to zero is critical (cost optimization for bursty traffic)
- You need the cloud provider's ecosystem (event triggers, managed databases)
- You don't want to manage any infrastructure

### Serverless Tradeoffs for Solo Devs

| Factor | faasd | AWS Lambda / Cloud Functions | Containers (Kamal) |
|---|---|---|---|
| Cost at low traffic | $5/mo flat | Free tier then pay-per-use | $5-10/mo flat |
| Cost at high traffic | Flat (limited by VM) | Expensive (per-invocation) | Flat (limited by VM) |
| Cold starts | None (always running) | Yes (100ms-5s) | None |
| Vendor lock-in | None | High | None |
| Ops burden | Low (systemd) | Zero | Low-medium |
| Auto-scaling | Manual | Automatic | Manual |
| Local dev | Multipass VM | SAM/emulators | Docker Compose |

### Practical Recommendation for Solo Devs

Start with containers (Kamal or Docker Compose on a VPS). Add faasd for isolated functions/webhooks when you need them. Reach for managed serverless only when auto-scaling to zero saves meaningful money or when you need specific cloud triggers.

---

## Observability 2.0

### The Shift from Three Pillars to Unified Events

**Observability 1.0** (three pillars): Metrics, logs, and traces stored across separate tools. Pre-aggregated at write time -- you must decide what questions to ask before collecting data. Dead ends everywhere: a log can't become a trace, a metric can't drill into individual events.

**Observability 2.0** (single source of truth): Arbitrarily-wide structured log events (spans) stored in a columnar database. Aggregation happens at read time. You can click a log, turn it into a trace, visualize it over time, derive metrics and SLOs from it. No dead ends.

### Key Concept: Wide Events

A single structured event captures ALL context for a unit of work: request ID, user ID, endpoint, duration, error codes, feature flags, build version, database query count, cache hit/miss, response size -- hundreds of fields per event. This replaces separate logs, metrics, and trace data.

"Metrics are a terrible building block for understanding rich data, because you have to discard all that valuable context at write time."

### Write-Time vs Read-Time Aggregation

| Aspect | O11y 1.0 (Write-Time) | O11y 2.0 (Read-Time) |
|---|---|---|
| Data model | Pre-defined metrics, log formats | Raw wide events, schema-on-read |
| Cardinality | Limited (cost explodes) | Unlimited (columnar storage) |
| Query flexibility | Dashboard-bound | Ad hoc, exploratory |
| New questions | Requires new instrumentation | Query existing data differently |
| Cost scaling | Multiplied across tools | Single store, dynamic sampling |

### Debugging Philosophy

**O11y 1.0 debugging**: Eyeball dashboards, pattern-match from experience, check known failure modes. Favors senior engineers with deep mental models.

**O11y 2.0 debugging**: Start with user impact, identify what anomalous events share in common, form hypotheses, interrogate data. Favors curiosity over tenure. "The best debuggers become the most curious, not the most tenured."

### Developer-Centric Observability

O11y 2.0 makes deployment the beginning of confidence-building, not the end. Developers instrument code, deploy, then inspect behavior through that instrumentation. Every deploy is validated through production telemetry, not just CI tests.

### Practical Implementation

- Store wide structured events in a columnar database (ClickHouse, Honeycomb, or similar)
- Use dynamic sampling (head-based or tail-based) to control costs
- Instrument with OpenTelemetry for vendor-neutral telemetry
- Stop building new dashboards for every question -- query raw events instead
- "Structured logs with injected trace IDs provide most of the benefits of APM at a fraction of the cost" (willett.io)

---

## SRE-Informed Development Practices

From willett.io's precepts for building software that's operable from day one.

### Configuration

- **No in-code fallbacks**: Services must crash on config load failure. Silent defaults hide problems behind deprecated code paths. Fail loud, fail fast.
- **Git everything**: Infrastructure, configs, dashboards, schedules -- all version-controlled. Enables point-in-time recovery and audit trails.
- **Fast config updates**: Support sub-5-minute feature flag and blocklist changes for rapid incident response.

### Testing Hierarchy

Production validation > integration tests > unit tests. Prioritize real-world validation over synthetic coverage.

- De-emphasize code coverage percentages -- they correlate poorly with actual reliability
- Monitor error logs, CPU usage, and request error rates to catch 90% of bad deploys
- Make regression signals obvious with automated checks on deploy

### Network Reliability

- **Strict timeout/retry discipline**: Zero or one retry maximum. Timeout at ~3x p99 latency.
- **Never retry as a band-aid** for flaky downstream services. Fix the flakiness.

### Infrastructure Precepts

- **Run 3 of everything**: "Two is one and one is none." Verify in production that 2 of 3 instances handle full load independently.
- **Structured logging is non-negotiable**: Combined with trace ID injection, this delivers 90% of APM value at far lower cost.
- **Containerize everything**: Docker standardizes dependencies better than config management tools.
- **Deploy daily minimum**: Reduces the window where broken code goes undetected.
- **Validate deploys in progress**: Canary deployments or readiness probes prevent broken images from fully rolling out.
- **Minimize state**: Use managed databases and caches. Stateful services are exponentially harder to operate.
- **Keep local dev fast**: Full local testing without CI/remote dependencies. Containerization helps.

### Kubernetes Precepts (When You Do Use It)

- Avoid custom operators and CRDs -- they create unnecessary complexity
- Use Helm for manifest management; avoid direct `kubectl` mutations
- Version control all resource definitions

---

## Dev Containers for Reproducible Environments

From "Lightning-Fast Development with Zed and Dev Containers."

### What Dev Containers Solve

"Works on my machine" is the single most common source of onboarding friction. Dev containers define the entire development environment (OS, language runtimes, tools, extensions, settings) as code in `.devcontainer/devcontainer.json`.

### How It Works

1. `.devcontainer/devcontainer.json` specifies a Docker image (or Dockerfile), features to install, port mappings, and editor settings.
2. The editor (VS Code, Zed, JetBrains) detects the config, builds/pulls the container, and mounts the workspace inside it.
3. Developer writes code locally; execution, linting, testing happen inside the container.
4. New team members go from `git clone` to productive in minutes, not days.

### Practical Configuration

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/node:1": { "version": "20" },
    "ghcr.io/devcontainers/features/go:1": { "version": "1.22" }
  },
  "forwardPorts": [3000, 8080],
  "postCreateCommand": "npm install",
  "customizations": {
    "vscode": {
      "extensions": ["esbenp.prettier-vscode", "dbaeumer.vscode-eslint"]
    }
  }
}
```

### Key Benefits

- **CI/CD parity**: Same container used for local dev can run in CI. Eliminates "it passes locally" failures.
- **Polyglot teams**: Each repo defines its own toolchain. No global version manager conflicts.
- **Security**: Dev dependencies isolated from host machine.

### When NOT to Use

- Performance-critical GPU work (container overhead matters)
- Teams already standardized on Nix or similar reproducible builds
- Solo projects where environment drift is not a problem

---

## Developer-First Secrets Management

From "Enabling Engineering Teams Through Developer-First Secrets Management."

### The Problem

Secrets sprawl across `.env` files, CI variables, cloud consoles, Slack DMs, and wikis. No single source of truth. Rotation requires touching multiple systems. Developers bypass security controls because they are friction-heavy.

### Developer-First Principles

1. **Single source of truth**: All secrets live in one system (Vault, 1Password, Doppler, Infisical). Everything else references it.
2. **Least-privilege by default**: Developers get access to secrets for their services only. No shared "production" credentials.
3. **Frictionless access**: CLI and IDE integrations so developers never copy-paste secrets. `dotenv-vault`, `op run`, or `doppler run` inject secrets at runtime.
4. **Rotation without deploys**: Secrets referenced by name, not value. Rotation updates the source; consumers pick up changes automatically or on next restart.
5. **Audit trail**: Every secret access logged with who, when, from where.

### Implementation Patterns

| Pattern | How It Works | Example Tools |
|---|---|---|
| **Secrets reference in env** | CI/CD fetches secrets at deploy time, injects as env vars | Vault + CI integration, Doppler, Infisical |
| **Secrets-as-code** | Terraform provider reads secrets from vault during apply | `1password/terraform-provider-onepassword`, Vault provider |
| **Runtime injection** | CLI wrapper injects secrets into process env | `op run`, `doppler run`, `vault exec` |
| **Sidecar/init container** | K8s sidecar fetches secrets, writes to shared volume | Vault Agent, External Secrets Operator |

### Anti-Patterns

- `.env` files committed to git (even "encrypted" ones are risky)
- Shared service accounts with long-lived credentials
- Secrets in CI environment variables without scoping to specific jobs/branches
- Manual rotation processes (humans forget; automate it)

---

## Edge Computing Concepts

From "What is Edge Compute?"

### Definition

Edge compute runs application logic geographically close to end users -- at CDN Points of Presence (PoPs) rather than centralized origin servers. The goal is to reduce latency by eliminating round-trips to distant data centers.

### Edge vs. Origin vs. CDN

| Layer | What It Does | Latency | Capabilities |
|---|---|---|---|
| **CDN** | Caches static assets at edge | Low | Read-only, no compute |
| **Edge Compute** | Runs code at edge | Low | Read/write, limited compute, short execution time |
| **Origin Server** | Full application logic | Higher | Full compute, full state, long execution |

### What Runs Well at the Edge

- **Request routing and rewriting**: A/B testing, feature flags, geolocation-based routing
- **Authentication/authorization**: JWT validation, bot detection
- **HTML transformation**: Personalization, injecting headers/footers, ESI-like composition
- **API aggregation**: Combine multiple API calls into one response closer to the user
- **Image/content optimization**: Resize, format conversion on the fly

### What Does NOT Belong at the Edge

- Long-running computations (edge functions have 50ms-50s execution limits)
- Heavy database operations (edge is far from your database; use edge-compatible DBs like Turso, PlanetScale, Neon for read replicas)
- Stateful sessions (edge is stateless by design; use KV stores for lightweight state)

### Edge Platforms

| Platform | Runtime | Key Constraint |
|---|---|---|
| Cloudflare Workers | V8 isolates | 10ms-30s CPU time |
| Vercel Edge Functions | V8 isolates (WinterCG) | 25s execution |
| Deno Deploy | Deno runtime | 50ms CPU per request |
| Fastly Compute | WASM | 50ms CPU time |
| AWS CloudFront Functions | Limited JS | 5ms execution |
| AWS Lambda@Edge | Node.js | 30s execution, higher latency |

### Key Insight

Edge compute is not a replacement for your backend. It is a layer that intercepts requests and handles what it can before forwarding the rest to origin. Think of it as programmable CDN, not distributed servers.

---

## Self-Service Infrastructure with Terraform

From "Self-Service Infrastructure at Lufthansa Systems with Terraform."

### The Pattern

Platform teams build Terraform modules that encapsulate organizational standards (networking, security, compliance). Product teams consume these modules through a self-service interface -- they request infrastructure by filling in variables, not by writing Terraform from scratch.

### How It Works

1. **Module library**: Platform team publishes versioned, opinionated Terraform modules to a private registry (Terraform Cloud, Artifactory, S3-backed). Modules encode best practices: tagging, networking, IAM policies, monitoring.
2. **Self-service interface**: Product teams create a `main.tf` that references modules with minimal input variables (app name, environment, size). No raw resource definitions.
3. **Guardrails**: Sentinel/OPA policies prevent non-compliant configurations at plan time. Teams cannot skip security groups, deploy to unapproved regions, or use oversized instances.
4. **GitOps workflow**: All infrastructure changes go through PR review. Terraform plan runs in CI; apply requires approval.

### Benefits

- Product teams get infrastructure in minutes, not weeks of tickets
- Platform team controls blast radius through module design
- Compliance is built into the modules, not enforced after the fact
- Infrastructure changes are auditable through git history

### Module Design Principles

- **Opinionated defaults, minimal inputs**: A module for an "app" should need only `name` and `environment`. Everything else has a sensible, compliant default.
- **Versioned releases**: Semantic versioning. Breaking changes get major bumps. Teams pin to versions and upgrade deliberately.
- **Composable**: Small, focused modules that compose rather than monolithic "everything" modules.

---

## CI Testing Matrix Pattern

From "GitHub Actions -- Create a Testing Matrix."

### What a Matrix Is

A matrix strategy runs the same job across multiple combinations of variables (OS, language version, database version, feature flags). GitHub Actions expands the matrix into parallel jobs automatically.

### Configuration

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest]
    node: [18, 20, 22]
    include:
      - os: ubuntu-latest
        node: 22
        coverage: true  # extra variable for specific combo
    exclude:
      - os: macos-latest
        node: 18  # skip this combination
  fail-fast: false  # don't cancel other jobs if one fails
```

### Key Options

- **`fail-fast: false`**: Let all matrix combinations complete even if one fails. Critical for understanding the full compatibility picture.
- **`include`**: Add specific variable combinations or inject extra variables into existing combos.
- **`exclude`**: Remove specific combinations from the generated matrix.
- **`max-parallel`**: Limit concurrent jobs to avoid resource exhaustion.

### Practical Uses

- Test against multiple Node/Python/Go versions to verify compatibility
- Test against multiple databases (Postgres 14/15/16)
- Test on multiple OS targets for CLI tools or native packages
- Run with different feature flag combinations

### Anti-Pattern

Avoid matrices with >20 combinations unless you have specific compatibility requirements. Each combination consumes CI minutes. Use `include` to test specific critical combos instead of exhaustive Cartesian products.

---

## Private Terraform Modules in GitHub Actions

From "Github Actions with a private Terraform module."

### The Problem

Terraform modules hosted in private GitHub repos require authentication when `terraform init` pulls them. GitHub Actions runners do not have this access by default.

### Solution: SSH Key or GitHub App Token

**SSH deploy key approach** (recommended for module repos):

```yaml
- uses: webfactory/ssh-agent@v0.9.0
  with:
    ssh-private-key: ${{ secrets.TERRAFORM_MODULE_DEPLOY_KEY }}

- name: Terraform Init
  run: terraform init
```

Module source uses SSH URL:
```hcl
module "vpc" {
  source = "git@github.com:org/terraform-modules.git//modules/vpc?ref=v1.2.0"
}
```

**GitHub App token approach** (when accessing multiple private repos):

```yaml
- uses: actions/create-github-app-token@v1
  id: app-token
  with:
    app-id: ${{ secrets.APP_ID }}
    private-key: ${{ secrets.APP_PRIVATE_KEY }}

- name: Configure git for HTTPS
  run: git config --global url."https://x-access-token:${{ steps.app-token.outputs.token }}@github.com/".insteadOf "https://github.com/"
```

### Best Practices

- Pin module references to tags (`?ref=v1.2.0`), never `main`
- Use read-only deploy keys scoped to the module repo only
- Rotate keys/tokens on a schedule
- Cache `.terraform` directory in CI to avoid re-downloading modules on every run

---

## Secrets-as-Code with Terraform

From `1Password/terraform-provider-onepassword`.

### The Pattern

Instead of hardcoding secrets or passing them through CI environment variables, Terraform reads secrets directly from a secrets manager (1Password, Vault, AWS Secrets Manager) at plan/apply time.

### 1Password Terraform Provider Example

```hcl
provider "onepassword" {
  service_account_token = var.op_service_account_token
}

data "onepassword_item" "database" {
  vault = "Infrastructure"
  title = "Production Database"
}

resource "aws_db_instance" "main" {
  username = data.onepassword_item.database.username
  password = data.onepassword_item.database.password
  # ...
}
```

### Why This Matters

- **Secrets never appear in Terraform state in plaintext** (when using `sensitive = true` on outputs)
- **Rotation is decoupled from infrastructure changes**: Update the secret in 1Password; next `terraform apply` picks up the new value
- **Single source of truth**: Developers, CI/CD, and Terraform all reference the same secret store
- **Audit trail**: 1Password/Vault logs every access

### Caveats

- Terraform state still contains resource attributes -- use remote state with encryption (S3 + KMS, Terraform Cloud)
- Service account tokens for the provider itself need secure storage (CI secret, not committed)
- Mark all secret-containing outputs as `sensitive = true` to prevent them appearing in plan output

---

## Infrastructure Preferences & Patterns

### Alpine Linux on DigitalOcean

Use minimal Alpine images instead of full Ubuntu for DO droplets (ref: benpye/alpine-droplet). Alpine gives you:

- **Smaller attack surface**: ~5MB base vs ~200MB Ubuntu. Fewer packages installed means fewer CVEs to patch.
- **Faster boot**: Sub-second to running state. Matters for auto-scaling or reprovisioning.
- **Lower resource usage**: More headroom on $5-10/mo droplets where every MB of RAM counts.
- **musl libc caveat**: Some software assumes glibc. Test your stack on Alpine before committing. Common pain points: DNS resolution edge cases, Python packages with C extensions, certain Go binaries compiled with CGO.

Philosophy: lean infrastructure. Start with nothing, add only what you need. The opposite of "full Ubuntu with everything pre-installed."

### Self-Hosted GitHub Actions Runners

**When to self-host runners:**
- Private network access (runners need to reach internal services, databases, or APIs not exposed to the internet)
- Specialized hardware (GPU builds, ARM targets, large-memory jobs)
- Cost control at scale (GitHub-hosted minutes get expensive past ~2000 min/month on Teams)
- Persistent caches (avoid re-downloading dependencies on every run; local Docker layer cache, npm/Go module cache)

**When to use GitHub-hosted runners:**
- Simplicity and zero maintenance are the priority
- Ephemeral, clean environments matter (reproducibility over speed)
- Low-to-moderate CI usage where cost isn't a concern

**Proxy/firewall consideration**: Self-hosted runners behind corporate firewalls need explicit proxy configuration. Set `https_proxy`/`http_proxy` environment variables on the runner. GitHub Actions traffic must reach `github.com`, `api.github.com`, `*.actions.githubusercontent.com`, and your container registry. Allowlist these or route through a forward proxy.

### faasd Cloud-Config Bootstrap Pattern

The `cloud-config.tpl` pattern from faasd shows how to bootstrap an entire serverless platform on a single VM using cloud-init:

1. **cloud-init user-data** script runs on first boot of a fresh VM (any cloud provider that supports user-data).
2. Script installs containerd, CNI plugins, and faasd as a systemd service -- all from a single template file.
3. The VM is reproducible: destroy and recreate from the same cloud-config, get identical infrastructure.

**The generalizable pattern**: Use cloud-init user-data scripts to provision complete application stacks on fresh VMs. This gives you infrastructure-as-code reproducibility without Kubernetes complexity. Works for any single-node deployment: faasd, Docker Compose apps, Caddy + app combos, monitoring stacks. Pair with Terraform's `user_data` argument on `digitalocean_droplet` or `aws_instance` to make it fully declarative.
