# Go — How We Write Go

Standards for all Go code. Mandatory. Detailed rules for each area are in reference files — consult them when working in that area.

---

## Philosophy: Clean Architecture + Grug + Dave Cheney

When in conflict: Cheney's Go-specific advice wins over Grug's generalities, and Grug wins over Uncle Bob's abstractions. Simplicity and clarity beat architectural purity every time.

### The Zen of Go (Dave Cheney)

1. A good package starts with a good name.
2. Simplicity matters.
3. Avoid package level state.
4. Plan for failure, not success.
5. Return early rather than nesting deeply.
6. If you think it's slow, prove it with a benchmark.
7. Before you launch a goroutine, know when it will stop.
8. Leave concurrency to the caller.
9. Write tests to lock in the behaviour of your package's API.
10. Maintainability counts.

### The Synthesis

| Uncle Bob | Grug | Cheney | We Do |
|---|---|---|---|
| Separate concerns into layers | Too many layers = complexity | Fewer, larger packages | 3-4 layers max. Add only when forced. |
| Depend on abstractions | Interfaces everywhere = overengineering | Interfaces at point of use, 1-method ideal | Interfaces at BOUNDARIES only. Concrete within packages. |
| Entities are pure business logic | No over-modeling | Make zero values useful | Plain structs with methods. No base classes. |
| Use Cases orchestrate | Don't over-architect | Keep main() small | Service functions. No ceremony. |
| Frameworks are details | Monolith usually good | Avoid cgo, pure Go | Pick Fiber, commit. No framework-agnostic abstractions. |

---

## Quick Reference

Consult the relevant reference file for full rules, examples, and rationale.

### Code Quality → `references/go-quality.md`

| Area | Key Rules |
|---|---|
| **Naming** | Clarity over brevity. No type info in names. `var` for zero-value, `:=` for init. Package name is part of identifier. |
| **Comments** | Explain WHAT, HOW, or WHY — never mix. Write before code. Don't comment bad code, rewrite it. |
| **Style** | Max 4 params. Named struct fields. `Name()` not `GetName()`. ≤50 line functions. ≤400 line files. |
| **Packages** | Name for what they provide. No `util`/`common`/`helpers`. Fewer, larger packages. Avoid `pkg/`. |
| **Architecture** | Consumer-side interfaces. Package SQL ownership. Inject all deps. No mutable globals. |
| **Zero Values** | Make them useful. Nil slices work. Design types to function without initialization. |
| **Security** | `filepath.Clean` + prefix check. No secrets in logs. Parameterized SQL. No `http.DefaultClient`. |
| **Cgo** | Avoid unless absolutely necessary. Sacrifices too much of Go's toolchain. |

### Error Handling → `references/error-handling.md`

| Strategy | Preference |
|---|---|
| **Opaque errors** | Preferred — `err != nil` and nothing more |
| **Behavior assertion** | Good — `Temporary() bool` interface checks |
| **Error types** | Sparingly — avoid in public API |
| **Sentinel errors** | Avoid — coupling, breaks with wrapping |

Key: wrap with context (`"open db: %w"`), handle each error exactly once (handle OR return, never both), eliminate errors by redesigning the API.

### Concurrency & Context → `references/concurrency.md`

- Never store context in structs. First param, named `ctx`.
- Before every `go`: when will it stop? What causes that? What signals completion?
- Leave concurrency to the caller — library code should not spawn goroutines.
- `context.Value()` is "thread local storage in a cheap suit" — cancellation signals only.
- Sender closes channels, never receiver. `chan struct{}` for signaling.

### API & Interface Design → `references/api-design.md`

- Accept interfaces, return concrete types. Narrow interfaces (1-method ideal).
- Functional options: `func NewServer(opts ...Option)` for configurable constructors.
- Fiber v3 only. `fiber.Ctx` (interface), not `*fiber.Ctx` (pointer).
- slog only. Log OR return errors, never both. No `log.Fatal` in libraries.

### Testing → `references/testing.md`

- Table-driven with `t.Run`. Consider map for randomized order.
- External test package by default. `t.Helper()` in all helpers. `t.Parallel()`.
- AAA structure. Descriptive names: `TestX_Method_ReturnsY_WhenZ`.
- Fakes > stubs > mocks. Coverage: 90%+ critical, 80%+ handlers, 70%+ infra.
- Fix flaky tests within 24 hours. `benchstat` for comparisons.

### Performance → `references/performance.md`

- Prove it with a benchmark before optimizing.
- Pre-allocate slices. `sync.Pool` for frequent allocs. `strings.Builder`.
- `-gcflags=-m` for escape analysis. Avoid interface boxing in hot paths.
- Stack > heap. Compact structs for cache locality. Performance budgets per operation type.

---

## Reference Files

- **`references/go-quality.md`** — Naming, comments, style, package design, architecture, zero values, security, common mistakes, cgo
- **`references/error-handling.md`** — Core rules, Cheney's ranked strategy (opaque → behavior → types → sentinels), error elimination patterns
- **`references/concurrency.md`** — Context discipline, goroutine lifecycle, resource management, channels, synchronization
- **`references/api-design.md`** — Interfaces, functional options, Fiber v3, slog logging
- **`references/testing.md`** — Conventions, build tags, coverage targets, test anti-patterns, benchmarks
- **`references/performance.md`** — Measurement-first, allocation, data structures, I/O, budgets
- **`references/go-wisdom.md`** — Design philosophy (Worse Is Better, Grug Brain), logging, concurrency patterns, data type pitfalls, API design pitfalls, benchmark traps, GC tuning, HyperLogLog

For CI/CD, GitHub Actions, linting, dependabot, and documentation standards, use the `/devops` skill.