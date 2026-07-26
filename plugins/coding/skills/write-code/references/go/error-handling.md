# Error Handling in Go

## Core Rules
- Every error must be handled. Never `_ = someFunc()` unless documented safe to ignore.
- Wrap errors with context: `fmt.Errorf("operation description: %w", err)`. Name the operation, not the error.
- No panic in library code. Only in `main()` for unrecoverable startup failures.
- Lowercase error strings, no trailing period.
- Use `errors.Is` and `errors.As` for error inspection; never `==` on wrapped errors.
- Custom error types with struct fields when callers need to inspect details.
- Document which specific errors a function can return in godoc.

## Dave Cheney's Error Strategy (ranked, prefer top)
1. Opaque errors (preferred). Return errors without exposing internal structure. Callers check `err != nil` and nothing more. Maximum decoupling.
2. Behavior assertion. Assert errors for behavior, not type — define small interfaces (e.g., `Temporary() bool`). Decouples producers from consumers.
3. Error types (use sparingly). `if err, ok := err.(*MyError); ok` — avoid in public API. Creates tight coupling.
4. Sentinel errors (avoid). `if err == io.EOF` — creates public API coupling, breaks when wrapped, risks import cycles. If you must, use `type Error string` (constant) not `var`.

## Eliminating Errors (Dave Cheney)
Instead of "how do I handle this better?", ask "how can I design the API so this error doesn't arise?"
- Use `bufio.Scanner` instead of manual `ReadString`+EOF checking.
- Use an `errWriter` wrapper type that defers error checking to the end.
- Handle each error exactly once — either handle (act on it) or return. Never log AND return.
- Never inspect `error.Error()` string output for program decisions. Strings belong in logs, not branching logic.
