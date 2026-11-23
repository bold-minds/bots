# Add a tip

## Journey
A diner runs `tipjar split 50 4 --tip 10` and reads each share with the tip in it: `13.75 each (tip 5.00)`.

## Scenarios
1. Given a bill of 50, 4 people and a 20 percent tip, when they run `tipjar split 50 4 --tip 20`, then it prints `15.00 each (tip 10.00)`. (R3)
2. Given a tip over the most a place allows (100 percent, unless the place sets a lower `max_tip`), when they run `tipjar split 50 4 --tip 120`, then it prints `Tip must be 0 to <most>` and exits with code 2. (R4)
