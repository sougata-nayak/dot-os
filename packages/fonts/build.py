#!/usr/bin/env python3
"""Cut static instances from the variable fonts into build/.

Space Grotesk's variable default is Light (300) and Doto's is Black (900);
apps and toolkits that take a variable font's default instance then draw thin
or heavy text. Static Regular/Medium/Bold files make every toolkit get the
weight it asks for.
"""
import os
import shutil

from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

OUT = "build"
CUTS = {
    "files/space-grotesk/SpaceGrotesk-Variable.ttf": ("Space Grotesk", {"Light": 300, "Regular": 400, "Medium": 500, "Bold": 700}, {}),
    "files/doto/Doto-Variable.ttf": ("Doto", {"Regular": 400, "Medium": 500, "Bold": 700, "Black": 900}, {"ROND": 0}),
}


def set_names(font, family, style, weight):
    full = family if style == "Regular" else "%s %s" % (family, style)
    ps = "%s-%s" % (family.replace(" ", ""), style)
    # Regular and Bold are the RIBBI pair; the others get their own family name.
    ribbi = style in ("Regular", "Bold")
    legacy_family = family if ribbi else full
    legacy_style = style if ribbi else "Regular"
    name = font["name"]
    name.removeNames(nameID=16)
    name.removeNames(nameID=17)
    for nid, value in ((1, legacy_family), (2, legacy_style), (4, full), (6, ps),
                       (16, family), (17, style), (3, "%s;DOT OS" % ps)):
        name.setName(value, nid, 3, 1, 0x409)
        name.setName(value, nid, 1, 0, 0)
    font["OS/2"].usWeightClass = weight
    sel = font["OS/2"].fsSelection & ~0b1100001
    sel |= 0b100000 if style == "Bold" else (0b1000000 if style == "Regular" else 0)
    font["OS/2"].fsSelection = sel
    font["head"].macStyle = 1 if style == "Bold" else 0


def main():
    shutil.rmtree(OUT, ignore_errors=True)
    os.makedirs(OUT)
    for src, (family, weights, extra) in CUTS.items():
        for style, weight in weights.items():
            font = instancer.instantiateVariableFont(TTFont(src), dict(extra, wght=weight))
            set_names(font, family, style, weight)
            font.save(os.path.join(OUT, "%s-%s.ttf" % (family.replace(" ", ""), style)))
    for f in os.listdir("files/space-mono"):
        if f.endswith(".ttf"):
            shutil.copy(os.path.join("files/space-mono", f), OUT)


if __name__ == "__main__":
    main()
