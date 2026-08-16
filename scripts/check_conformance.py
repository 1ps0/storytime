#!/usr/bin/env python3
"""Run foldboard's behavioral conformance suite against this repo's fold.

Local half of the cross-CI tether (board episode 014): until foldboard
is published, the suite comes from a local checkout — FOLDBOARD_DIR or
the default sibling path. Exit codes pass through from the suite;
exits 3 with a plain message when no checkout is found (a skip, not a
failure — CI treats absence as skip until the published tether lands).
"""

import os
import subprocess
import sys

DEFAULT_FOLDBOARD = os.path.expanduser("~/workspace/projects/foldboard")
REDUCER = "python3 scripts/fold.py"


def main():
    fb = os.environ.get("FOLDBOARD_DIR", DEFAULT_FOLDBOARD)
    suite = os.path.join(fb, "conformance", "reducer_suite.py")
    if not os.path.isfile(suite):
        print("check_conformance: foldboard not found at %s — "
              "set FOLDBOARD_DIR (skipping)" % fb)
        return 3
    repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    return subprocess.call(
        [sys.executable, suite, "--repo", repo, "--reducer", REDUCER])


if __name__ == "__main__":
    sys.exit(main())
