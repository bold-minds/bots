# Go Wisdom

Distilled from Dave Cheney, 100 Go Mistakes, Grug Brained Developer, and Worse Is Better.
Only practices NOT covered in sibling reference files (error-handling.md, go-quality.md, testing.md, performance.md).

---

## Design Philosophy

### Worse Is Better (Richard Gabriel)
- **Implementation simplicity > interface simplicity.** When forced to choose, keep the implementation simple even if the interface becomes slightly harder. Simple implementations are portable, debuggable, and spreadable.
- **50% shipped beats 100% unshipped.** Get half the right thing available so it spreads. Improve to 90% once adopted. The last 20% takes 80% of the effort and delays everything.
- **Simple systems force composition.** Because a simple language/system can't build monolithic software, a tradition of integration and reuse emerges naturally. This is a feature, not a bug.
- **Viral adoption requires being "basically good."** The initial version must be fundamentally sound, even if incomplete. Correctness in the core path matters; completeness at the edges does not.

### Grug Brain Principles
- **Complexity is the apex predator.** Every abstraction, feature, and indirection is a complexity cost. The default answer to "should we build this?" is "no."
- **Say "ok" and build the 80/20 version.** When you can't say no, find the solution that delivers 80% of the value with 20% of the code. Sometimes don't tell the project manager.
- **Don't factor too early.** Early in a project, everything is abstract and fluid. Wait for cut points to emerge from the code naturally. Premature abstraction is worse than duplication.
- **Good cut points have narrow interfaces.** A small number of functions that hide internal complexity, like a demon trapped in crystal. You know a cut point when you see it; it takes experience to see them.
- **Chesterton's Fence applies to code.** Before removing code you don't understand, figure out why it exists. If you can't explain the purpose of the fence, you don't get to tear it down.
- **Refactors go off the rails when they're too large.** Keep refactors small enough that the system works the entire time. Each step finishes before the next begins. Large refactors with too much abstraction are the ones that fail.
- **Prefer integration tests over unit tests.** Unit tests break as implementation changes and test your mocks, not your system. End-to-end tests are hard to debug when they break. Integration tests hit the sweet spot: high-level enough to test correctness, low-level enough to debug.
- **Type systems: enough to help, not so much they hinder.** Generics, complex type hierarchies, and elaborate type-level programming create more complexity than they prevent. Use types to catch real bugs, not to satisfy a type-theoretic ideal.
- **Closures are the enemy of readability.** Prefer simple, named functions. When closures are nested or capture mutable state, they become impossible to reason about.

### Go Gets Exceptions Right By Not Having Them
- **Exceptions conflate control flow with error signaling.** Go's multiple return values force you to handle errors at the call site, which is where you have the most context.
- **Panic is not throw.** Panic means "I can't continue" and is your own problem. Throw means "this is the caller's problem." Use panic only for truly unrecoverable states (programmer bugs, violated invariants), never for expected error conditions.
- **Checked exceptions failed in Java** because they became so commonplace that developers reflexively `catch (Exception e) { // ignore }`. Error values in Go are harder to accidentally swallow because they're explicit return values.

---

## Logging (Dave Cheney)

- **Only two log levels matter: Info and Debug.** Info is for things operators need to know ("listening on port 8080", "connected to database"). Debug is for developers during development. Warn and Error are redundant -- if it's an error, handle it (return it); if it's a warning, it's either info or it shouldn't be logged.
- **Log OR return, never both.** (See also error-handling.md.) The logging-specific addition: the error gets reported at every level of the stack that logs-and-returns, creating noise that drowns out the actual origin.
- **Logging is the last resort.** Before adding a log line, ask: can I use a metric instead? Can I use tracing? Can I return an error? Logs are expensive to store, search, and maintain. Every log line is technical debt.
- **No log.Fatal in libraries.** Fatal calls `os.Exit(1)`, which skips deferred functions. Only `main()` decides when to exit.
- **Structured logging with key-value pairs.** Never `log.Printf("failed to connect to %s", host)`. Always structured: `log.Info("connection failed", "host", host, "error", err)`.

---

## Concurrency (Dave Cheney + 100 Go Mistakes)

### Leave Concurrency to the Caller (Dave Cheney)
- **Never start a goroutine in a function the caller doesn't expect to be concurrent.** If your API returns a result, compute it synchronously. Let the caller wrap it in `go` if they want concurrency. Starting hidden goroutines violates the principle of least surprise and makes resource management impossible.
- **Keep yourself busy or do the work yourself.** If the main goroutine has nothing to do but wait for other goroutines, it should do the work itself instead of spawning goroutines. `go func() { result <- work() }()` followed by `<-result` is pointless -- just call `work()` directly.
- **Never start a goroutine without knowing when it will stop.** Every goroutine must have a clear shutdown path: a `context.Done()` channel, a `quit` channel, or a bounded operation. Leaked goroutines are memory leaks that don't show up in `runtime.MemStats`.

### Common Concurrency Mistakes (100 Go Mistakes)
- **Channels vs mutexes decision framework.** Use channels for: ownership transfer, signaling, orchestration. Use mutexes for: protecting shared state where there's no transfer of ownership. Don't default to channels for everything.
- **Nil channels are useful.** A nil channel blocks forever on send and receive. Use this to disable a `select` case dynamically by setting the channel to nil.
- **Notification channels should be `chan struct{}`.** A channel used only for signaling (not data transfer) should send `struct{}{}` (zero bytes) not `bool` or `int`.
- **`sync.Cond` exists and solves broadcast problems.** When multiple goroutines need to wake up on the same condition, `sync.Cond.Broadcast()` is cleaner than closing and recreating channels.
- **`errgroup` for goroutine lifecycle management.** Use `golang.org/x/sync/errgroup` to manage groups of goroutines that can fail. It handles context cancellation and error propagation.
- **Don't copy sync types.** `sync.Mutex`, `sync.WaitGroup`, `sync.Cond`, etc. must not be copied (pass by pointer). The compiler won't catch this; use `go vet`.
- **`time.After` leaks in loops.** Each call to `time.After` creates a timer that isn't garbage collected until it fires. In a `select` loop, use `time.NewTimer` and `timer.Reset()`.

---

## Data Type Pitfalls (100 Go Mistakes)

- **Variable shadowing with `:=` in inner blocks.** Declaring `err` with `:=` inside an `if` block creates a new variable; the outer `err` remains nil. Use `go vet -shadow` to catch this.
- **Slice append can mutate the underlying array.** When a slice has spare capacity, `append` modifies the original backing array. After `s2 := append(s1, x)`, `s1` and `s2` may share memory. Use `slices.Clone()` or full slice expressions `s1[:len(s1):len(s1)]` to prevent this.
- **Substring memory leaks.** `s2 := s1[10:20]` keeps the entire backing array of `s1` alive. For long-lived substrings from large strings, use `strings.Clone()` (Go 1.20+) or `string([]byte(s1[10:20]))`.
- **Slice-of-pointers prevents GC of pointed-to objects.** When shrinking a slice of pointers, nil out the removed elements so the GC can collect the objects they point to.
- **Maps never shrink.** Go maps only grow; deleting keys doesn't free bucket memory. If a map grows large temporarily, recreate it or use a map of pointers with periodic compaction.
- **Integer overflow is silent in Go.** No runtime panic on overflow. If overflow matters (financial calculations, size computation), check explicitly before the operation.
- **`any` interface says nothing.** Using `any`/`interface{}` as a parameter type opts out of the type system. It should be a last resort, not a first choice. If you need flexibility, define a small interface with the methods you actually need.

---

## API Design Pitfalls (100 Go Mistakes + Dave Cheney)

- **Accept `io.Reader`, not `string` or `*os.File`.** Functions that take a filename are untestable. Functions that take `io.Reader` can be tested with `strings.Reader`, `bytes.Buffer`, or any other reader.
- **Named result parameters: use for documentation, not for naked returns.** Named return values are useful for godoc clarity but naked `return` statements (without arguments) hide what's being returned. Always return explicitly.
- **Returning a nil receiver is not returning nil.** `func f() error { var p *MyError = nil; return p }` returns a non-nil interface (type is `*MyError`, value is nil). The caller's `if err != nil` check will be true. Always return `nil` explicitly for the zero error case.
- **Don't use `init()` for complex initialization.** `init()` runs implicitly, can't return errors, can't be tested, and creates ordering dependencies between packages. Use explicit initialization in `main()` or constructors.
- **Functional options pattern for complex constructors.** When a constructor has more than 3-4 optional parameters, use `func WithTimeout(d time.Duration) Option` style. It's self-documenting, backward-compatible, and zero-value safe.
- **Returning interfaces creates coupling.** Return concrete types; accept interfaces. The caller decides what interface the concrete type satisfies, not the producer.

---

## Testing Additions (100 Go Mistakes + Dave Cheney)

### Test Execution Modes
- **Always run tests with `-race`.** Data races are undefined behavior in Go. The race detector catches them at runtime but only during test execution. `-race` should be in CI by default.
- **Use `-shuffle=on` to catch order-dependent tests.** Go 1.17+ supports randomizing test execution order. Tests that pass in order but fail when shuffled have hidden dependencies.
- **Use `-count=1` to bypass test caching** when debugging flaky tests. Go caches test results by default.

### Benchmark Traps (100 Go Mistakes)
- **Compiler can optimize away benchmark targets.** If the result of the benchmarked operation isn't used, the compiler may eliminate the call entirely. Assign results to a package-level `sink` variable.
- **Beware observer effects.** Running a function in a tight loop may benefit from CPU cache warming that doesn't reflect real-world performance. Use `b.StopTimer()`/`b.StartTimer()` to exclude setup, but be aware that repeated stopping/starting has its own overhead.
- **Don't use `b.N` as input size.** `b.N` is the iteration count the framework controls. If you use it as input size (e.g., creating a slice of `b.N` elements), you're benchmarking different workloads each iteration.

### Testing Utilities
- **`httptest.NewServer` for integration tests.** Creates a real HTTP server on a random port. Better than mocking `http.Client` because it tests real serialization and HTTP semantics.
- **`iotest.ErrReader` and `iotest.HalfReader` for I/O edge cases.** The `testing/iotest` package provides readers that simulate errors, one-byte reads, and other adversarial I/O behavior.
- **Fuzzing for parsing code.** Go 1.18+ native fuzzing finds inputs that crash parsers, deserializers, and validators. Add fuzz tests for any function that takes `[]byte` or `string` from external input.

---

## Performance Additions (Harry Marr + 100 Go Mistakes)

### Profiling Workflow
- **Profile before optimizing. Always.** `go tool pprof` with CPU and memory profiles. The bottleneck is never where you think it is.
- **Use `runtime/pprof` for CLI tools, `net/http/pprof` for servers.** Import `_ "net/http/pprof"` and hit `/debug/pprof/` to get live profiles from running services.
- **Read the flame graph, not the flat profile.** Flat profiles show where time is spent; flame graphs show why. The "why" is almost always more actionable.

### Allocation Reduction Patterns (extending performance.md)
- **Pre-size `sync.Pool` buffers and `strings.Builder` with `Grow(n)`.** The basics are in performance.md; the key addition: if you know the approximate output size, pre-grow to avoid repeated reallocations.
- **Avoid `fmt.Sprintf` in hot paths.** `fmt.Sprintf` allocates and uses reflection. For simple string concatenation, `+` or `strings.Builder` is faster. For number formatting, `strconv.AppendInt` writes directly to a buffer.
- **Struct field ordering affects memory usage.** Go aligns struct fields to their natural alignment boundaries. Ordering fields from largest to smallest reduces padding. Use `fieldalignment` linter.

### CPU-Level Optimizations
- **Instruction-level parallelism matters.** Modern CPUs execute multiple independent instructions simultaneously. Code with data dependencies between adjacent operations (e.g., `x = f(x); y = g(x)`) serializes the pipeline. When possible, compute independent values in separate statements.
- **Data alignment affects performance.** Misaligned atomic operations can panic on some architectures (32-bit ARM). Even on x86, misaligned access is slower. The `atomic.Int64` type (Go 1.19+) handles alignment automatically.

### GC Awareness (100 Go Mistakes)
- **Understand GOGC and GOMEMLIMIT.** `GOGC=100` (default) means GC triggers when heap doubles. Lower values reduce peak memory but increase GC frequency. `GOMEMLIMIT` (Go 1.19+) sets a soft memory ceiling that prevents OOM without constant GC pressure.
- **Large heap ≠ slow GC.** GC time scales with the number of pointers, not heap size. A 10GB heap of `[]byte` with no pointers is nearly free to scan. A 100MB heap of pointer-heavy structs can be expensive.
- **Running Go in containers: set `GOMAXPROCS` and `GOMEMLIMIT`.** By default, Go sees all host CPUs, not the container's CPU limit. Use `automaxprocs` or set `GOMAXPROCS` explicitly. Set `GOMEMLIMIT` to ~90% of the container's memory limit.

---

## Probabilistic Data Structures

### HyperLogLog (for Cardinality Estimation)
- **Problem it solves:** Counting unique items (unique visitors, distinct IPs, unique queries) where exact counting requires O(n) memory.
- **How it works:** Hash each item, use the position of the leftmost 1-bit as an estimator of how many items you've seen. Split items into buckets using some hash bits, track the maximum leading-zero count per bucket, combine estimates using harmonic mean.
- **Tradeoffs:** ~1.6KB of memory for ~2% error rate on billions of items. Error is configurable by adjusting the number of buckets (registers). Cannot enumerate the items, only estimate the count.
- **When to use:** Unique visitor counting, distinct value estimation in analytics, cardinality estimation in database query planners, deduplication estimation before expensive exact computation.
- **When NOT to use:** When you need exact counts, when you need to know which items were seen, or when the cardinality is small enough that a set fits in memory.
- **Available in:** Redis (`PFADD`/`PFCOUNT`), PostgreSQL (`hll` extension), most analytics databases natively. Go implementations: `axiomhq/hyperloglog`, `clarkduvall/hyperloglog`.
