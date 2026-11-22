# tally interface

Go package `tally` (file `tally.go`).

```go
// New returns a Counter that counts events inside a sliding window.
func New(window time.Duration) *Counter

// Add records n events for key at the current time.
func (c *Counter) Add(key string, n int)

// Count returns the events recorded for key inside the window.
func (c *Counter) Count(key string) int

// Top returns up to k keys with the highest counts, highest first.
func (c *Counter) Top(k int) []Entry

// Reset forgets everything recorded for key.
func (c *Counter) Reset(key string)

type Entry struct {
    Key   string
    Count int
}
```

## Rules and numbers

- If window is zero or negative, New uses 1 minute.
- Add with n <= 0 records nothing.
- Count of an unknown key is 0.
- Top with k <= 0 returns an empty slice.
- A key with no events for 2 windows is dropped.
- Ties in Top are ordered by key, A to Z.
