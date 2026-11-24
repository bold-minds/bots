package list

var ticked = map[string]bool{}

// Tick marks an item ticked; it stays on the list.
func Tick(item string) { ticked[item] = true }

// ClearTicked removes every ticked item.
func ClearTicked() {
	kept := Items[:0]
	for _, it := range Items {
		if !ticked[it] {
			kept = append(kept, it)
		}
	}
	Items, ticked = kept, map[string]bool{}
}
