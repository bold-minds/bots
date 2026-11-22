// Command tally prints the total of the amounts given as arguments.
package main

import (
	"fmt"
	"os"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "Usage: tally AMOUNT...")
		os.Exit(2)
	}
	fmt.Println("not built yet")
}
