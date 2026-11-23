"""Runs the tipjar program in TIPJAR_DIR, as people run it."""
import os
import subprocess
import sys


def tipjar(*args):
    folder = os.path.abspath(os.environ["TIPJAR_DIR"])
    return subprocess.run([sys.executable, os.path.join(folder, "tipjar.py"), *args],
                          capture_output=True, text=True)
