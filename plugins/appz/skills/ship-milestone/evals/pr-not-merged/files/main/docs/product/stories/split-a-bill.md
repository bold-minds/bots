# Split a bill

## Journey
A diner at a shared table runs `tipjar split 30 3` and reads what each person pays: `10.00 each`.

## Scenarios
1. Given a bill of 50 and 4 people, when they run `tipjar split 50 4`, then it prints `12.50 each`. (R1)
2. Given no people, when they run `tipjar split 10 0`, then it prints `Enter at least one person` and exits with code 2. (R2)
