#!/usr/bin/env python3
"""Build the DOT OS Plymouth theme into build/dot-os/.

Every piece of text is a pre-rendered PNG, so the splash never depends on
which fonts made it into the initramfs. Layout follows
design-system/boards/Plymouth.dc.html: wordmark, a 20-segment bar and a
percentage, anchored to the bottom-left at a 32px margin.
"""
import os
import shutil
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import boottokens as b  # noqa: E402

OUT = "build/dot-os"


def main():
    shutil.rmtree("build", ignore_errors=True)
    os.makedirs(OUT)
    t = b.T
    p = lambda name: os.path.join(OUT, name)  # noqa: E731

    b.text(p("wordmark.png"), "DOT OS", b.DOTO, 72, "text-display", -0.03, axes=b.DOTO_AXES, height=72)
    for name, s in (("starting", "Starting"), ("stopping", "Shutting down"), ("restarting", "Restarting"),
                    ("updating", "Updating"), ("password", "Password")):
        b.label(p("label-%s.png" % name), s)
    b.label(p("footer.png"), "arm64   built on Debian 13")
    # Percentage: Space Mono 12 in text-display; every digit is the same width.
    for d in "0123456789%":
        b.text(p("digit-%s.png" % ("pct" if d == "%" else d)), d, b.MONO, 12, "text-display")
    # Segments, 14 x 16 with 2px gaps; the leading lit segment is the live marker.
    b.rect(p("seg-on.png"), 14, 16, "text-display")
    b.rect(p("seg-off.png"), 14, 16, "border-visible")
    b.rect(p("seg-live.png"), 14, 16, "accent")
    # Disk-unlock prompt, the Input component at boot.
    b.svg(p("bullet.png"), 10, 16, '<circle cx="5" cy="9" r="3" fill="%s"/>' % t["text-primary"])
    b.rect(p("underline.png"), 280, 1, "text-display")
    b.rect(p("caret.png"), 2, 18, "accent")

    with open(p("dot-os.plymouth"), "w") as fh:
        fh.write("""[Plymouth Theme]
Name=DOT OS
Description=Wordmark and a segmented progress bar on black.
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/dot-os
ScriptFile=/usr/share/plymouth/themes/dot-os/dot-os.script
""")
    shutil.copyfile("dot-os.script", p("dot-os.script"))


if __name__ == "__main__":
    main()
