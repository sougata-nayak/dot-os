"""Shared helpers for the boot and login packages' build scripts.

Each of packages/{grub,plymouth,sddm}-theme/build.py imports this to read the
dark token values, find the font files and call textpng.py. They run inside
`dpkg-buildpackage`, with the repository checked out around them.
"""
import os
import struct
import subprocess
import sys

TOOLS = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(TOOLS)
sys.path.insert(0, TOOLS)

import tokens  # noqa: E402

FONTS = os.path.join(ROOT, "packages", "fonts", "files")
MONO = os.path.join(FONTS, "space-mono", "SpaceMono-Regular.ttf")
SANS = os.path.join(FONTS, "space-grotesk", "SpaceGrotesk-Variable.ttf")
DOTO = os.path.join(FONTS, "doto", "Doto-Variable.ttf")
DOTO_AXES = "wght=700,ROND=0"

T = tokens.load()["dark"]


def version():
    """Version from the package's own debian/changelog."""
    with open("debian/changelog") as fh:
        return fh.readline().split("(")[1].split(")")[0]


def text(out, s, font=MONO, size=11, colour="text-secondary", tracking=0.0, upper=False, axes="", **kw):
    cmd = [sys.executable, os.path.join(TOOLS, "textpng.py"), "text", out, s, "--font", font,
           "--size", str(size), "--color", T.get(colour, colour), "--tracking", str(tracking)]
    if upper:
        cmd.append("--upper")
    if axes:
        cmd += ["--axes", axes]
    for k, v in kw.items():
        cmd += ["--" + k, str(v)]
    subprocess.run(cmd, check=True)
    return png_size(out)


def label(out, s, colour="text-secondary", **kw):
    """The design system's `label`: Space Mono 11, caps, 0.08em tracking."""
    return text(out, s, MONO, 11, colour, 0.08, True, **kw)


def rect(out, w, h, colour, radius=0):
    subprocess.run([sys.executable, os.path.join(TOOLS, "textpng.py"), "rect", out, str(w), str(h),
                    T.get(colour, colour), "--radius", str(radius)], check=True)
    return w, h


def svg(out, w, h, body):
    """Rasterise a small hand-written SVG body."""
    src = out + ".svg"
    with open(src, "w") as fh:
        fh.write('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d">%s</svg>' % (w, h, body))
    subprocess.run(["rsvg-convert", src, "-o", out], check=True)
    os.unlink(src)
    return w, h


def png_size(path):
    with open(path, "rb") as fh:
        head = fh.read(24)
    return struct.unpack(">II", head[16:24])
