import unittest

from run import tipjar


class SplitE2E(unittest.TestCase):
    def test_journey(self):
        r = tipjar("split", "30", "3")
        self.assertEqual(r.stdout.strip(), "10.00 each")

    def test_scenario_1_even_split(self):
        r = tipjar("split", "50", "4")
        self.assertEqual(r.stdout.strip(), "12.50 each")

    def test_scenario_2_no_people(self):
        r = tipjar("split", "10", "0")
        self.assertEqual((r.stdout.strip(), r.returncode), ("Enter at least one person", 2))


if __name__ == "__main__":
    unittest.main()
