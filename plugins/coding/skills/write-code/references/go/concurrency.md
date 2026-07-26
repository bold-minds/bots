# Concurrency & Context in Go

## Context Discipline (Dave Cheney)
- Never store context in structs. Pass explicitly as first parameter, named `ctx`.
- `context.Background()` only at program entry points; `context.TODO()` only as temp placeholder with TODO comment.
- Do not use `context.Value()` as general-purpose data container. "Thread local storage in a cheap suit."
- Do not pass loggers through context. Inject explicitly into constructors.
- Use context strictly for request-scoped cancellation signals, not generic value store.

## Goroutine Management
- Every goroutine receives a `ctx`. Must select on `ctx.Done()` and exit promptly.
- Goroutine start implies visible stop. Before every `go` statement: (1) When will it stop? (2) What causes that? (3) What signals it has stopped?
- Leave concurrency to the caller. Library code should not spawn goroutines internally. (Dave Cheney)
- Keep yourself busy or do the work yourself. Don't create a goroutine just to wait on it immediately. (Dave Cheney)

## Resource Management
- No `defer` inside a loop. Use explicit closure or helper function.
- Close resources with defer immediately after successful open, in the same function.

## Channels
- Sender closes, never receiver. Document ownership. Justify buffered channels.
- Use `chan struct{}` for signaling (zero allocation). (Dave Cheney)

## Synchronization
- `sync.RWMutex` for read-heavy workloads. Document thread-safety in type docs.
- Document whether a function or method is concurrent-safe.
