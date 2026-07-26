# Testing in Go

## Conventions
- Table-driven tests for multiple cases. Use `[]struct{ name, input, want }` and `t.Run(tc.name, ...)`. Consider `map[string]struct{...}` — randomized iteration catches order-dependent bugs. (Dave Cheney)
- External test package by default (`package foo_test`). Use `package foo` only when unexported access needed (with comment explaining why). Place `Example` functions in external test files for godoc. (Dave Cheney)
- No network or real filesystem in unit tests. Use `t.TempDir()`. Tag external deps with `//go:build integration`.
- Test the invariant, not the implementation. Assert on observable outputs and error types. "Write tests to lock in the behaviour of your package's API." (Dave Cheney)
- Regression tests for every correctness fix.
- `t.Helper()` in all test helper functions.
- `t.Parallel()` for parallel execution.
- Arrange-Act-Assert structure consistently.
- Descriptive names: `TestX_Method_ReturnsY_WhenZ`.
- Prefer fakes for complex deps, stubs for simple returns, mocks only when verifying interactions.
- Property-based testing for parsers, serializers, invariants.
- Golden files for complex output validation.
- Coverage targets: 90%+ critical logic, 80%+ handlers, 70%+ infra.
- Fix flaky tests within 24 hours; never `t.Skip()` as permanent solution.
- `b.ReportAllocs()` in benchmarks; compare with `benchstat`.
- Use `cmp.Diff` from `google/go-cmp` instead of `reflect.DeepEqual`. (Dave Cheney)
- Prefer `t.Errorf` over `t.Fatalf` for pure functions — report all failures at once. (Dave Cheney)

## Build Tags
| Tag | Purpose |
|---|---|
| (none) | Unit tests — fast, no external deps, every build |
| `//go:build integration` | Real databases, network, external services |
| `//go:build security` | Adversarial/security tests |
| `//go:build e2e` | Full end-to-end workflow tests |

## What Tests Must NOT Do
- Start goroutines without `t.Cleanup` or context cancellation
- Write to real filesystem outside `t.TempDir()`
- Call real external APIs — use mocks
- Use `time.Sleep` — use channels or `sync.WaitGroup`
