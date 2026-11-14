#!/usr/bin/env python3
"""Build the DOT OS Calamares branding into build/dot-os/: copy src/, fill the
@token@ markers from design-system/tokens.json, and render the few images the
stylesheet and branding.desc point at."""
import os
import re
import shutil
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import boottokens as b  # noqa: E402

OUT = "build/dot-os"
DEST = "/usr/share/calamares/branding/dot-os"


def main():
    shutil.rmtree("build", ignore_errors=True)
    shutil.copytree("src", OUT)
    values = dict(b.T)
    values["version"] = b.version()
    values["dir"] = DEST

    def fill(m):
        key = m.group(1)
        if key not in values:
            raise SystemExit("unknown token @%s@" % key)
        return str(values[key])

    for root, _, files in os.walk(OUT):
        for name in files:
            if name.endswith((".qml", ".qss", ".desc")):
                path = os.path.join(root, name)
                with open(path) as fh:
                    text = fh.read()
                with open(path, "w") as fh:
                    fh.write(re.sub(r"@([a-z-]+)@", fill, text))

    t = b.T
    p = lambda name: os.path.join(OUT, name)  # noqa: E731
    # Wordmark: there is no logo, only the name in Doto (design-system/README.md).
    b.text(p("logo.png"), "DOT OS", b.DOTO, 48, "text-display", -0.03, axes=b.DOTO_AXES, height=48)
    # One empty segment and its 2px gap, tiled under the install progress bar.
    b.svg(p("seg-off.png"), 16, 16, '<rect width="14" height="16" fill="%s"/>' % t["border-visible"])

    def write(name, body):
        with open(p(name), "w") as fh:
            fh.write('<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 18 18">%s</svg>\n' % body)

    write("radio-off.svg", '<circle cx="9" cy="9" r="8.5" fill="none" stroke="%s"/>' % t["text-secondary"])
    write("radio-on.svg", '<circle cx="9" cy="9" r="8.5" fill="none" stroke="%s"/><circle cx="9" cy="9" r="5" fill="%s"/>'
          % (t["text-display"], t["text-display"]))
    write("check-off.svg", '<rect x=".5" y=".5" width="17" height="17" rx="3.5" fill="none" stroke="%s"/>' % t["text-secondary"])
    write("check-on.svg", '<rect x=".5" y=".5" width="17" height="17" rx="3.5" fill="none" stroke="%s"/>'
          '<rect x="4" y="4" width="10" height="10" rx="1" fill="%s"/>' % (t["text-display"], t["text-display"]))
    with open(p("chevron.svg"), "w") as fh:
        fh.write('<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">'
                 '<path d="M4 6l4 4 4-4" fill="none" stroke="%s" stroke-width="1.5" stroke-linecap="round" '
                 'stroke-linejoin="round"/></svg>\n' % t["text-secondary"])


if __name__ == "__main__":
    main()
