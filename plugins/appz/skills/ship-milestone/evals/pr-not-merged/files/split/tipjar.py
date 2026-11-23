#!/usr/bin/env python3
"""tipjar: split a bill between people."""
import sys
from decimal import Decimal, ROUND_HALF_UP

CENT = Decimal("0.01")


def share(total, people):
    """Each person's share of total, to the cent."""
    if people < 1:
        raise ValueError("Enter at least one person")
    return (Decimal(total) / people).quantize(CENT, ROUND_HALF_UP)


def main(argv):
    if len(argv) != 3 or argv[0] != "split":
        print("usage: tipjar split <total> <people>", file=sys.stderr)
        return 2
    try:
        each = share(argv[1], int(argv[2]))
    except ValueError as err:
        print(err)
        return 2
    print(f"{each} each")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
