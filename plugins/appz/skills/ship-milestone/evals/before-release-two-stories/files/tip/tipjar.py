#!/usr/bin/env python3
"""tipjar: split a bill between people, with a tip."""
import os
import sys
from decimal import Decimal, ROUND_HALF_UP

CENT = Decimal("0.01")


def share(total, people):
    """Each person's share of total, to the cent."""
    if people < 1:
        raise ValueError("Enter at least one person")
    return (Decimal(total) / people).quantize(CENT, ROUND_HALF_UP)


def most_tip(folder):
    """The max_tip line of tipjar.conf in folder, or 100 when there is none."""
    conf = os.path.join(folder, "tipjar.conf")
    if os.path.exists(conf):
        with open(conf) as f:
            for line in f:
                key, _, value = line.strip().partition("=")
                if key.strip() == "max_tip":
                    return int(value)
    return 100


def with_tip(total, people, tip, most):
    """Each share and the tip amount, to the cent."""
    if not 0 <= tip <= most:
        raise ValueError(f"Tip must be 0 to {most}")
    bill = Decimal(total)
    amount = (bill * tip / 100).quantize(CENT, ROUND_HALF_UP)
    return share(bill + amount, people), amount


def main(argv):
    tip = None
    if len(argv) == 5 and argv[3] == "--tip":
        tip, argv = int(argv[4]), argv[:3]
    if len(argv) != 3 or argv[0] != "split":
        print("usage: tipjar split <total> <people> [--tip <percent>]", file=sys.stderr)
        return 2
    try:
        if tip is None:
            print(f"{share(argv[1], int(argv[2]))} each")
        else:
            most = most_tip(os.path.dirname(os.path.abspath(__file__)))
            each, amount = with_tip(argv[1], int(argv[2]), tip, most)
            print(f"{each} each (tip {amount})")
    except ValueError as err:
        print(err)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
