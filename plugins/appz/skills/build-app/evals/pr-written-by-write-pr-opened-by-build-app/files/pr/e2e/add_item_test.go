//go:build e2e

package e2e

import "testing"

func TestE2EJourney(t *testing.T)   { journey(t, "milk", "eggs") }
func TestE2EEmptyItem(t *testing.T) { emptyItem(t) }
