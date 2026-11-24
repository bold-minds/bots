package list

import "errors"

// ErrEmpty is returned for an empty item.
var ErrEmpty = errors.New("Type an item to add it.")

// Add puts item at the end of the list.
func Add(item string) error {
	if item == "" {
		return ErrEmpty
	}
	Items = append(Items, item)
	return nil
}
