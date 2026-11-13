#!/usr/bin/env python3
"""Render a line of text, or a solid rectangle, to a PNG with no font setup.

Glyph outlines come straight from the TTF through fontTools and are written as
SVG paths, so rsvg-convert never needs fontconfig. Boot-time surfaces (GRUB,
Plymouth) use these PNGs instead of fonts, because the initramfs and GRUB
cannot be trusted to have ours.

    textpng.py text OUT.png --font F.ttf --size 16 --color '#FFFFFF' [--tracking 0.08]
                            [--upper] [--height H] [--width W] [--align left|right|center]
                            [--axes wght=700,ROND=0] TEXT
    textpng.py rect OUT.png W H COLOR [--radius R]

Needs python3-fonttools and rsvg-convert (librsvg2-bin).
"""
import argparse
import os
import subprocess
import sys
import tempfile

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont


def load(path, axes):
    font = TTFont(path)
    if axes and "fvar" in font:
        from fontTools.varLib import instancer
        loc = {k: float(v) for k, v in (a.split("=") for a in axes.split(","))}
        font = instancer.instantiateVariableFont(font, loc)
    return font


def svg_to_png(svg, out):
    with tempfile.NamedTemporaryFile("w", suffix=".svg", delete=False) as fh:
        fh.write(svg)
        name = fh.name
    try:
        subprocess.run(["rsvg-convert", name, "-o", out], check=True)
    finally:
        os.unlink(name)


def text(args):
    font = load(args.font, args.axes)
    upem = font["head"].unitsPerEm
    scale = args.size / upem
    hhea = font["hhea"]
    ascent, descent = hhea.ascent * scale, -hhea.descent * scale
    cmap = font.getBestCmap()
    glyphs = font.getGlyphSet()
    hmtx = font["hmtx"]
    s = args.text.upper() if args.upper else args.text
    track = args.tracking * args.size
    paths, x = [], 0.0
    for i, ch in enumerate(s):
        name = cmap.get(ord(ch), ".notdef")
        pen = SVGPathPen(glyphs)
        # font units, y up -> pixels, y down, baseline at `ascent`
        glyphs[name].draw(TransformPen(pen, (scale, 0, 0, -scale, x, ascent)))
        d = pen.getCommands()
        if d:
            paths.append(d)
        x += hmtx[name][0] * scale + (track if i < len(s) - 1 else 0)
    natural_h = ascent + descent
    height = args.height or int(round(natural_h + 0.4999))
    width = args.width or int(round(x + 0.4999))
    dx = {"left": 0, "right": width - x, "center": (width - x) / 2}[args.align]
    dy = (height - natural_h) / 2
    svg = ('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d">'
           '<g transform="translate(%.3f %.3f)" fill="%s"><path d="%s"/></g></svg>'
           % (width, height, dx, dy, args.color, " ".join(paths)))
    svg_to_png(svg, args.out)


def rect(args):
    svg = ('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d">'
           '<rect width="%d" height="%d" rx="%s" fill="%s"/></svg>'
           % (args.w, args.h, args.w, args.h, args.radius, args.color))
    svg_to_png(svg, args.out)


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)
    t = sub.add_parser("text")
    t.add_argument("out")
    t.add_argument("text")
    t.add_argument("--font", required=True)
    t.add_argument("--size", type=float, required=True)
    t.add_argument("--color", default="#FFFFFF")
    t.add_argument("--tracking", type=float, default=0.0, help="letter spacing in em")
    t.add_argument("--upper", action="store_true")
    t.add_argument("--height", type=int)
    t.add_argument("--width", type=int)
    t.add_argument("--align", default="left", choices=("left", "right", "center"))
    t.add_argument("--axes", default="")
    r = sub.add_parser("rect")
    r.add_argument("out")
    r.add_argument("w", type=int)
    r.add_argument("h", type=int)
    r.add_argument("color")
    r.add_argument("--radius", default="0")
    a = p.parse_args()
    (text if a.cmd == "text" else rect)(a)


if __name__ == "__main__":
    sys.exit(main())
