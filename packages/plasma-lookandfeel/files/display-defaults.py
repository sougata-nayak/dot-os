#!/usr/bin/env python3
"""Print kscreen-doctor arguments that set 3840x2160 at 250% on every enabled
output offering that mode. Prints nothing if none do; exits 1 if KScreen
cannot be read yet (so the login script tries again next time)."""
import json
import subprocess
import sys

WIDTH, HEIGHT, SCALE = 3840, 2160, 2.5

try:
    raw = subprocess.run(["kscreen-doctor", "-j"], capture_output=True, text=True, timeout=10).stdout
    outputs = json.loads(raw)["outputs"]
except Exception:
    sys.exit(1)

args = []
for out in outputs:
    if not out.get("enabled"):
        continue
    modes = [m for m in out.get("modes", []) if m["size"]["width"] == WIDTH and m["size"]["height"] == HEIGHT]
    if not modes:
        continue
    best = max(modes, key=lambda m: m.get("refreshRate", 0))
    name = out["name"]
    args += ["output.%s.mode.%s" % (name, best["name"]), "output.%s.scale.%s" % (name, SCALE)]
print(" ".join(args))
