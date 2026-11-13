"""Load design-system/tokens.json and resolve it into flat per-theme dictionaries."""
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
THEMES = ("dark", "light")
# Capitalised form used in file and theme names: DotOSDark, DotOS-Light ...
CAP = {"dark": "Dark", "light": "Light"}


def load():
    with open(os.path.join(ROOT, "design-system", "tokens.json")) as fh:
        data = json.load(fh)
    out = {}
    for theme in THEMES:
        raw = {t["name"]: t["value"][theme] for t in data["color"]["tokens"]}
        flat = {}
        for name, value in raw.items():
            seen = set()
            while isinstance(value, str) and value.startswith("{"):
                ref = value.strip("{}")
                if ref in seen:
                    raise ValueError("token loop at " + name)
                seen.add(ref)
                value = raw[ref]
            flat[name] = value
        for group in ("spacing", "radius", "size"):
            for t in data[group]["tokens"]:
                flat[t["name"]] = int(re.sub(r"[^0-9]", "", t["value"]))
        # Text that sits on an accent fill. White in both themes (4.9:1 on accent).
        flat["on-accent"] = "#FFFFFF"
        out[theme] = flat
    return out


def rgb(hex_colour):
    """'#D71921' -> '215,25,33' (the form KDE and Konsole config files use)."""
    h = hex_colour.lstrip("#")
    return ",".join(str(int(h[i:i + 2], 16)) for i in (0, 2, 4))


def write(path, text):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as fh:
        fh.write(text)
    return path
