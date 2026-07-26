---
name: write-code
description: >
  Use when writing, creating, or modifying code in any language or domain. Orchestrates the full
  code writing workflow: captures intent, detects the domain (Go, frontend, infrastructure, SRE),
  loads the relevant coding standards, writes code following those standards, and runs adversarial
  self-review. Trigger when: the user asks to build, implement, add, create, write, or modify
  code, features, components, endpoints, configs, pipelines, or infrastructure.
---

# Write Code

Orchestrate code writing with mechanical loading of domain-specific standards.

## Process

### 1. Capture intent, then write the scenarios

Invoke `capture-intent` to understand what the user is asking for, enumerate every element, define how each will be fulfilled, and surface risks.

> **If the `foundations` plugin is not installed,** `capture-intent` and
> `check-evidence` are unavailable. Do their work inline instead of skipping it:
> quote the request, enumerate every element including the implicit ones, name
> the mechanism for each and whether it is guaranteed to run, and at the end run
> the adversarial pass — intent trace, artifact wiring, deferral grep, and the
> failure modes you checked with the evidence for each.

Then turn those enumerated elements into Gherkin scenarios and show them to the user **before writing any code** — see `references/gauntlet/bdd.md`. A wrong scenario caught here costs a sentence; caught after implementation, it costs the feature. If an element can't be written as a scenario, it isn't understood yet — say so rather than guessing.

Skip for changes with no observable behavior (formatting, dependency bumps, internal renames), with a one-line note saying so.

### 2. Detect domain

Based on the task, identify which domains apply. Multiple domains can apply to a single task.

| Signal | Domain | References to load |
|--------|--------|-------------------|
| Go files, `.go` imports, backend services | **Go** | `references/go/` |
| Astro, Svelte, TypeScript, CSS, HTML, UI components | **Frontend** | `references/frontend/` |
| CI/CD, Docker, GitHub Actions, deployment, infrastructure | **DevOps** | `references/devops/` |
| Monitoring, alerting, incidents, runbooks, SLOs | **SRE** | `references/sre/` |

**Always load `references/craft/standards.md` — language-agnostic standards that apply to all code.** Also load, when relevant: `references/craft/twelve-factor.md` for the twelve-factor app checklist (config, statelessness, dev/prod parity, and the rest of the SaaS deployment shape), and `references/craft/architecture-wisdom.md` for Bounded Context, Transitional Architecture, and architectural decision-making guidance.

**Always load `references/gauntlet/standards.md` — the mechanical gates that decide whether the work is done.** Then load the language gate file for each domain touched: Go → `references/gauntlet/go.md`, Frontend → `references/gauntlet/frontend.md`. Load `references/gauntlet/bdd.md` whenever the change has observable behavior — its scenarios get written at step 1, before the code.

### 3. Load standards

Read the standards file for each detected domain. These are the rules you follow while writing code.

**For Go:**
1. Read `references/craft/standards.md`
2. Read `references/go/standards.md`
3. Read additional Go references as needed based on the task:
   - Error handling → `references/go/error-handling.md`
   - Concurrency → `references/go/concurrency.md`
   - API/interface design → `references/go/api-design.md`
   - Testing → `references/go/testing.md`
   - Performance → `references/go/performance.md`
   - Quality/naming/style → `references/go/go-quality.md`
   - Design wisdom → `references/go/go-wisdom.md`
   - DDD patterns → `references/go/ddd-patterns.md`
   - DSLs, parsers, ASTs, editor/language tooling → `references/go/editor-tooling.md`

**For Frontend:**
1. Read `references/craft/standards.md`
2. Read `references/frontend/standards.md`
3. Read additional frontend references as needed:
   - Astro → `references/frontend/astro.md`
   - Svelte → `references/frontend/svelte.md`
   - TypeScript → `references/frontend/typescript.md`
   - JavaScript → `references/frontend/javascript.md`
   - CSS → `references/frontend/css.md`
   - Tailwind → `references/frontend/tailwind.md`
   - JSON conventions → `references/frontend/json.md`
   - Performance → `references/frontend/web-performance.md`

**For DevOps:**
1. Read `references/craft/standards.md`
2. Read `references/devops/standards.md`
3. Read additional devops references as needed:
   - CI/CD pipelines → `references/devops/cicd.md`
   - Containers → `references/devops/containers.md`
   - Infrastructure → `references/devops/infrastructure.md`
   - Security/supply chain → `references/devops/security.md`
   - Releases → `references/devops/release.md`
   - Modern deployment → `references/devops/modern-deployment.md`

**For SRE:**
1. Read `references/craft/standards.md`
2. Read `references/sre/standards.md`
3. Read additional SRE references as needed:
   - Observability/logging → `references/sre/observability.md`
   - Incidents/postmortems → `references/sre/incidents.md`
   - Runbooks → `references/sre/runbooks.md`

### 4. Write the code

Follow the loaded standards. Apply craft standards to all code. Apply domain-specific standards to domain-specific work.

### 5. Run the gauntlet — blocking

Run **every** tier-1 gate for the languages touched, per `references/gauntlet/`. Not the relevant ones. Every one.

A gate is a command with a threshold that blocks and produces evidence. Paste the actual command output, not a summary of it. Close with the full gate table — every applicable gate gets a row, including any that could not run.

Failing gate → fix the code and re-run. Never lower a threshold to make it green.

Run tier 2 (mutation testing, fuzzing) when the change touches parsers, decoders, money math, permission checks, or state machines.

### 6. Self-review

Invoke `check-evidence` to run the adversarial self-review before claiming done.

The gauntlet catches mechanical defects. `check-evidence` catches the rest: a correct implementation of the wrong requirement, a gap between what `capture-intent` captured and what got built, a threshold that passed for the wrong reason.

### 7. Report

State what was built, paste the gate table, and name anything left unverified. A green gauntlet with an unrun gate is not a pass — say which one and why.
