# Add amounts

## Journey
A user runs tally with the amounts from a receipt and reads the total.

## Scenarios
1. Given the amounts 2 and 3, when the user runs `tally 2 3`, then it prints "Total: 5".
2. Given the amounts 1.50 and 2.25, when the user runs `tally 1.50 2.25`, then it prints "Total: 3.75".
3. Given an amount that is not a number, when the user runs `tally 2 abc`, then it prints "Not a number: abc" and exits with status 1.
