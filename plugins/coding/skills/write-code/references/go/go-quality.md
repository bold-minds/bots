# Go Code Quality

## Naming (Dave Cheney)
- Clarity over brevity. Greater distance between declaration and use → longer name. Short names (1-2 letters) fine when close.
- Never include type info in variable names. No `usersMap`, `configStruct`, `usersList`.
- Use `var` for intentional zero-value; `:=` for declare-and-initialize. `var count int` signals "I want the zero value."
- Reserve `i`, `j`, `k` for loop indices only.
- Single-letter receiver names, consistent across all methods on a type. Use `ctx` for `context.Context`.
- Package name is part of the identifier — `http.Get` not `http.HTTPGet`. Don't stutter.
- Use blank lines to break up function flow like paragraphs in prose.

## Comments (Dave Cheney)
- A comment explains exactly one of: WHAT, HOW, or WHY. Never mix.
- Write the comment BEFORE the code. If you can't describe it, you don't understand it yet.
- Don't comment bad code; rewrite it.
- Always document every exported symbol.
- Don't write "implements X interface" on methods — that's what the compiler checks.
- Annotate TODO comments with the username of the person who can explain or fix it.
- Extract heavily-commented code blocks into separate functions with descriptive names.

## Style
- Max 4 function parameters; use options struct beyond that.
- Named struct fields mandatory; positional fields forbidden.
- Getter naming: `Name()` not `GetName()`; booleans: `IsExpired()`.
- Pointer receivers when mutating or receiver is large; value receivers for small immutable accessors. Careful with value receivers on concurrent types — copies the struct.
- Line length: target ≤100, hard limit ≤120.
- Cyclomatic complexity: refactor at >10, hard limit 15.
- Avoid magic numbers; use named constants.
- Replace `if/else if` chains with `switch` for mutually exclusive paths.
- Use `goimports` for import organization beyond `gofmt`.

## Package Design (Dave Cheney)
- Name packages for what they PROVIDE, not what they contain. The name is an elevator pitch.
- Avoid catch-all names: `base`, `common`, `util`, `helpers`, `server`, `private`.
- Prefer fewer, larger packages over many small ones. Go's package hierarchy has no special meaning.
- Avoid the `pkg/` directory. Use `internal/` to share code without committing to public API.
- Name source files by responsibility using nouns (`messages.go`, `client.go`), not by type.
- Don't create `client`/`server` subpackages — use files within the package.
- Start with one `.go` file named after the package, then split when import sets diverge.
- Every package except `cmd/` and `internal/` should contain `.go` source files — no empty taxonomy directories.

## Architecture & Package Boundaries
- Consumer-side interfaces only. Define in the package that USES them.
- Package SQL ownership. Each package owns SQL for its own tables only.
- No reaching through layers. Dependency flows inward only.
- No utility/helper packages.
- Inject all dependencies via constructor. No package-level global mutable state.
- Avoid mutable package-level variables. Immutable, unexported lookup tables are acceptable.
- Function size: ≤ 50 lines. File size: ≤ 400 lines.
- Keep `main.main()` as small as possible. Move business logic out.
- Prefer wide, flat import graphs over tall, narrow ones.

## Zero Values (Dave Cheney)
- Make zero values useful. Types should work without explicit initialization (`sync.Mutex`, `bytes.Buffer`).
- Nil slices are functional — can `append` without `make()`.
- Nil pointer receivers can return sensible defaults.

## Security
- Path traversal prevention: `filepath.Clean` + verify expected prefix.
- No secrets in logs or error returns.
- Parameterised SQL only. Never `fmt.Sprintf` for SQL.
- No `http.DefaultClient`. All HTTP clients must have explicit timeouts.

## Common Mistakes
- Don't hardcode configurables.
- Don't `io.ReadAll` on large files; stream with `io.Copy`.
- Don't send raw internal errors to external channels.
- Don't create expensive resources multiple times in startup.

## Cgo (Dave Cheney)
- Avoid unless absolutely necessary (graphics drivers, OS windowing, mobile).
- Cgo sacrifices: fast builds, cross-compilation, race detector, pprof, coverage, fuzz, single binary.
