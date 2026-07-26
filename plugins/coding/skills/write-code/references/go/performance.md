# Performance in Go

## Measurement First
- "If you think it's slow, prove it with a benchmark." Never assume. (Dave Cheney)
- Compare benchmarks before and after changes using `benchstat`.
- Use `-gcflags=-m` to inspect escape analysis and inlining decisions. (Dave Cheney)
- `b.ReportAllocs()` in benchmarks to track heap allocations.

## Allocation
- Pre-allocate slices when size is known.
- Use `sync.Pool` for frequently allocated objects.
- `strings.Builder` not concatenation in loops.
- Assigning non-pointer values to interfaces forces heap allocation. In hot paths, keep concrete types. (Dave Cheney)
- Go allocations round up to predefined size classes — 9-byte alloc may consume 12 bytes. (Dave Cheney)
- Stack allocation is always faster than heap. Avoid unnecessary pointer escapes. (Dave Cheney)

## Data Structures
- Compact data structures improve cache performance. Go stores values inline (not pointers) which improves locality. (Dave Cheney)
- Pass large structs by pointer, small structs by value.

## I/O & Network
- Use prepared statements for repeated database queries.
- Configure HTTP client transport: `MaxIdleConns`, `MaxIdleConnsPerHost`, `IdleConnTimeout`.
- Drain and close response bodies to enable HTTP connection reuse.

## Mechanical Sympathy (Martin Thompson / LMAX)

Write software that works with the hardware, not against it. The best developers understand how CPUs, caches, and memory actually work.

### Cache Lines & False Sharing
- CPUs move memory in cache-line chunks (typically 64 bytes). Design data layouts accordingly.
- **False sharing:** When different goroutines write to different fields in the same cache line, they trigger expensive cache coherency protocols across cores. Pad independent, concurrently-accessed fields to cache-line boundaries.
- Favor arrays and slices over linked structures (maps of pointers, linked lists). Contiguous memory enables CPU prefetching; pointer chasing causes cache misses that are orders of magnitude slower.

### Single-Writer Principle
- Design so only one goroutine writes to any given memory location. This eliminates mutual exclusion entirely -- no locks, no CAS loops, just memory barriers for visibility.
- Use `atomic` operations or channel-based ownership transfer rather than shared mutable state under mutex.
- When coordination is needed, prefer sequence counters with volatile semantics over lock-based queues.

### Memory Barriers
- Go's `sync/atomic` operations implicitly include memory barriers. Use them for coordination points.
- Minimize barrier usage -- they're cheaper than locks but not free. Batch work between synchronization points.

### The Disruptor Insight (applicable to Go channel design)
- Traditional queues conflate three concerns: storage, producer coordination, and consumer notification. This creates contention at head/tail.
- The LMAX Disruptor achieved 160M+ ops/sec by separating these concerns: pre-allocated ring buffer for storage, sequence counters for coordination, busy-spin for notification.
- **Go application:** When a channel becomes a bottleneck, consider whether you're conflating concerns. A pre-allocated ring buffer with atomic sequence coordination can outperform channels by 10-50x in hot paths. Use channels for orchestration; use lock-free structures for throughput.

### In-Memory-First Design
- LMAX processes 6M orders/sec on commodity hardware by keeping the entire working set in memory with a single-threaded event loop.
- Sequential in-memory processing eliminates concurrency overhead AND database I/O. Consider whether your "distributed microservice" problem is actually a "keep it in memory on one machine" problem.
- Basic implementations: 10K TPS. Well-factored code: 100K TPS. Custom cache-friendly structures: 1M+ TPS. Know where you are on this curve and whether you need to move.

## Budgets
- Define performance budgets per operation type: API p95 < 100ms, DB query < 50ms, cache lookup < 5ms.
