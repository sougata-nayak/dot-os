#!/usr/bin/env python3
"""Regenerate every token-derived theme file under packages/.

    python3 tools/generate.py            # write files
    python3 tools/generate.py --check    # exit 1 if the committed files are stale

The single source of truth is design-system/tokens.json. Change a colour
there, run this, rebuild the packages.
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import gen_colors  # noqa: E402
import gen_cursors  # noqa: E402
import gen_gtk  # noqa: E402
import gen_icons  # noqa: E402
import gen_kvantum  # noqa: E402
import tokens  # noqa: E402


def main():
    t = tokens.load()
    made = []
    for module in (gen_colors, gen_gtk, gen_kvantum, gen_cursors, gen_icons):
        files = module.run(t)
        print("%-12s %d files" % (module.__name__.replace("gen_", ""), len(files)))
        made += files
    if "--check" in sys.argv:
        dirty = subprocess.run(["git", "status", "--porcelain", "--", "packages"], cwd=tokens.ROOT,
                               capture_output=True, text=True).stdout.strip()
        if dirty:
            print("Generated files are out of date:\n" + dirty)
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
