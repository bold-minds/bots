import os
import sys
import unittest
from decimal import Decimal

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import tipjar  # noqa: E402


class SplitTest(unittest.TestCase):
    def test_even_split(self):
        self.assertEqual(tipjar.share("50", 4), Decimal("12.50"))

    def test_no_people_refused(self):
        with self.assertRaisesRegex(ValueError, "Enter at least one person"):
            tipjar.share("10", 0)


if __name__ == "__main__":
    unittest.main()
