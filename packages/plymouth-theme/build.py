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

    # Every asset at 1x and, under 2x/, at double size for high-density panels.
    for k, sub in ((1, ""), (2, "2x/")):
        os.makedirs(os.path.join(OUT, sub), exist_ok=True)
        q = lambda name: os.path.join(OUT, sub + name)  # noqa: E731
        b.text(q("wordmark.png"), "DOT OS", b.DOTO, 72 * k, "text-display", -0.03, axes=b.DOTO_AXES, height=72 * k)
        for name, s in (("starting", "Starting"), ("stopping", "Shutting down"), ("restarting", "Restarting"),
                        ("updating", "Updating"), ("password", "Password")):
            b.text(q("label-%s.png" % name), s, b.MONO, 11 * k, "text-secondary", 0.08, True)
        b.text(q("footer.png"), "arm64   built on Debian 13", b.MONO, 11 * k, "text-secondary", 0.08, True)
        for d in "0123456789%":
            b.text(q("digit-%s.png" % ("pct" if d == "%" else d)), d, b.MONO, 12 * k, "text-display")
        b.rect(q("seg-on.png"), 14 * k, 16 * k, "text-display")
        b.rect(q("seg-off.png"), 14 * k, 16 * k, "border-visible")
        b.rect(q("seg-live.png"), 14 * k, 16 * k, "accent")
        b.svg(q("bullet.png"), 10 * k, 16 * k, '<circle cx="%d" cy="%d" r="%d" fill="%s"/>'
              % (5 * k, 9 * k, 3 * k, t["text-primary"]))
        b.rect(q("underline.png"), 280 * k, k, "text-display")
        b.rect(q("caret.png"), 2 * k, 18 * k, "accent")

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
