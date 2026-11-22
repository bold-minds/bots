# tagset interface

## Normalize
`func Normalize(tag string) (string, error)` (already in tagset/normalize.go)

## Merge
`func Merge(lists ...[]string) []string`

Returns one list holding each normalized tag once, in the order first seen. Tags that Normalize rejects are left out. Never returns nil.
