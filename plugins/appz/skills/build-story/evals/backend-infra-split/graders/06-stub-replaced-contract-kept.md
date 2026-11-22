---
type: llm
focus: trace
weight: 1
---

On the new branch, store/stub.go is gone and package store exports Note{ID int; Text string}, ErrEmpty, Open(path string) (*Store, error), (*Store).Add(text string) (Note, error) and (*Store).List() ([]Note, error), as the stub contract gives them.
