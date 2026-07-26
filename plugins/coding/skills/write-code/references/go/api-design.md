# API & Interface Design in Go

## Interface Rules
- Accept interfaces, return concrete types.
- Narrow interfaces. 1-method ideal. `io.Reader` is the exemplar. (Dave Cheney)
- Progressively narrow: `*os.File` → `io.ReadWriteCloser` → `io.WriteCloser` → `io.Writer`. "Require no more, promise no less." (Dave Cheney)
- `context.Context` is always the first parameter for I/O, blocking, or cancellable functions.
- No returning `interface{}` or `any` from domain functions.

## API Design (Dave Cheney)
- Functional options pattern for configurable constructors: `func NewServer(opts ...Option) *Server`. Gives backward compatibility, clear defaults, no nil parameters, self-documenting names.
- Beware functions with multiple params of the same type — easy to swap silently.
- Prefer `func DoThing(first T, rest ...T)` over `func DoThing(items []T)` — prevents empty-call bugs at compile time.
- APIs should be easy to use and hard to misuse. Don't require callers to provide parameters they don't care about.

## Framework: Fiber v3 Only
- Must use: `github.com/gofiber/fiber/v3`. Prohibited: Fiber v2, chi, gin, echo, gorilla/mux.
- Handler signatures use `fiber.Ctx` (interface), NOT `*fiber.Ctx` (pointer — v2).
- Use `c.Bind().Body(&target)` not `c.BodyParser(&target)` (v2).
- Use `app.ShutdownWithContext(ctx)` not `app.ShutdownWithTimeout(duration)` (v2).
- Middleware: `github.com/gofiber/fiber/v3/middleware/*`.

## Logging: slog Only (Dave Cheney)
- Use `slog` exclusively. Never `fmt.Print*`, `log.Print*`, `log.Fatal*`.
- Key-value pairs, not format strings.
- Log levels: Error (operator must know), Warn (use sparingly — Cheney: "nobody reads warnings"), Info (lifecycle events, always visible), Debug (per-request, off in prod).
- One log per error at handling site. Log OR return, not both.
- Don't log handled errors as Error level — if handled, it's not an error anymore.
- Never use `log.Fatal` in library code — calls `os.Exit`, no cleanup.
