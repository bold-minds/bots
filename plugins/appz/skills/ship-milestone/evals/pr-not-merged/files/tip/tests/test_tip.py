import os
import sys
import tempfile
import unittest
from decimal import Decimal

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import tipjar  # noqa: E402


class TipTest(unittest.TestCase):
    def test_twenty_percent_tip(self):
        self.assertEqual(tipjar.with_tip("50", 4, 20, 100), (Decimal("15.00"), Decimal("10.00")))

    def test_tip_over_most_refused(self):
        with self.assertRaisesRegex(ValueError, "Tip must be 0 to 100"):
            tipjar.with_tip("50", 4, 120, 100)

    def test_most_tip_from_conf(self):
        with tempfile.TemporaryDirectory() as d:
            self.assertEqual(tipjar.most_tip(d), 100)
            with open(os.path.join(d, "tipjar.conf"), "w") as f:
                f.write("max_tip=40\n")
            self.assertEqual(tipjar.most_tip(d), 40)


if __name__ == "__main__":
    unittest.main()
