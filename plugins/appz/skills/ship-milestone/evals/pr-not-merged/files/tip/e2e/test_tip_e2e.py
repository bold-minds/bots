import unittest

from run import tipjar


class TipE2E(unittest.TestCase):
    def test_journey(self):
        r = tipjar("split", "50", "4", "--tip", "10")
        self.assertEqual(r.stdout.strip(), "13.75 each (tip 5.00)")

    def test_scenario_1_twenty_percent(self):
        r = tipjar("split", "50", "4", "--tip", "20")
        self.assertEqual(r.stdout.strip(), "15.00 each (tip 10.00)")

    def test_scenario_2_tip_over_most(self):
        r = tipjar("split", "50", "4", "--tip", "120")
        self.assertTrue(r.stdout.startswith("Tip must be 0 to "), r.stdout)
        self.assertEqual(r.returncode, 2)


if __name__ == "__main__":
    unittest.main()
