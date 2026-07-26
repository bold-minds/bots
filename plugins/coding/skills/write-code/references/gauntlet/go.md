# Gauntlet — Go

Read `gauntlet/standards.md` first for the contract. Every tier-1 gate below runs on every Go task.

## Tier 1

Run from the module root, in this order. Order matters — a build failure makes every later result meaningless.

| # | Gate | Command | Threshold |
|---|------|---------|-----------|
| 1 | Format | `gofmt -l .` | empty output |
| 2 | Build | `go build ./...` | exit 0 |
| 3 | Vet | `go vet ./...` | exit 0 |
| 4 | Lint | `golangci-lint run` | exit 0 |
| 5 | Test + race | `go test -race ./...` | exit 0 |
| 6 | Coverage | `go test -cover ./...` | see targets below |
| 7 | Acceptance | `go test ./features/...` (godog, strict) | exit 0, 0 undefined steps |

Gate 7 applies whenever the change has observable behavior, and its feature files are written at step 1 before implementation. See `gauntlet/bdd.md`.

### Coverage targets

From `go/standards.md` — these are the existing numbers, not new ones:

- **90%+** critical logic
- **80%+** handlers
- **70%+** infrastructure

Report the actual percentage per package against its target. A single repo-wide average hides the package that dropped to 40%. Like every threshold in this file, these are defaults a project may override in its `scope.md` — see `gauntlet/standards.md`.

Generated files, `main.go` wiring, and vendored code are excluded from targets. Nothing else is.

### Notes on specific gates

**`gofmt -l .`** prints the names of unformatted files and exits 0 either way. The threshold is empty *output*, not exit code. If it prints anything, run `gofmt -w .` and re-run.

**`golangci-lint run`** — if the project has no `.golangci.yml`, that is a finding. Report it. The default linter set is weaker than what `go/go-quality.md` assumes.

**`go test -race`** — race detection is not optional and not a separate gate to run "when concurrency is involved." Data races surface in code that looks single-threaded.

## Tier 2

Needs installation and a committed config. Run when the change touches parsers, decoders, money math, permission checks, or state machines.

| Gate | Command | Threshold |
|------|---------|-----------|
| Fuzz | `go test -fuzz=Fuzz -fuzztime=60s ./<pkg>` | no new crashers |
| Mutation | `gremlins unleash` | efficacy ≥ 70%, coverage ≥ 80% (defaults — the user's to change, not a task's) |

**Fuzzing** applies to anything that parses untrusted input. A fuzz target that finds nothing in 60s is a pass; commit any crasher it does find as a seed corpus entry.

**Mutation testing** via [`go-gremlins/gremlins`](https://github.com/go-gremlins/gremlins). It mutates the source and checks whether tests catch it. This is the gate that catches the failure mode coverage can't see: tests that execute a line without asserting anything about it. High coverage with low mutation efficacy means the tests run the code without checking its results.

Install: `go install github.com/go-gremlins/gremlins/cmd/gremlins@latest`. If it is not installed, report the gate as not run — do not silently drop it.

## What a passing gauntlet does not prove

The gates catch mechanical defects. They do not catch a correct implementation of the wrong requirement. That is what `capture-intent` captures up front and what `check-evidence` checks at the end.
