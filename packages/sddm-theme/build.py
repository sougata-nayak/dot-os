#!/usr/bin/env python3
"""Build the DOT OS SDDM theme into build/dot-os/: fill the token markers in
Main.qml and write the theme metadata."""
import os
import re
import shutil
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import boottokens as b  # noqa: E402

OUT = "build/dot-os"


def main():
    shutil.rmtree("build", ignore_errors=True)
    os.makedirs(OUT)
    values = dict(b.T)
    values["version"] = b.version()
    with open("src/Main.qml") as fh:
        qml = fh.read()

    def fill(m):
        key = m.group(1)
        if key not in values:
            raise SystemExit("Main.qml: unknown token @%s@" % key)
        return str(values[key])

    qml = re.sub(r"@([a-z-]+)@", fill, qml.replace("@TOKENS@", "TOKENS"))
    with open(os.path.join(OUT, "Main.qml"), "w") as fh:
        fh.write(qml)
    with open(os.path.join(OUT, "metadata.desktop"), "w") as fh:
        fh.write("""[SddmGreeterTheme]
Name=DOT OS
Description=Clock, user and password on the dot grid.
Author=DOT OS project
License=MIT
Type=sddm-theme
Version=%s
Website=https://github.com/dot-os/dot-os
Screenshot=preview.png
MainScript=Main.qml
ConfigFile=theme.conf
Theme-Id=dot-os
Theme-API=2.0
QtVersion=6
""" % values["version"])
    with open(os.path.join(OUT, "theme.conf"), "w") as fh:
        fh.write("[General]\n")


if __name__ == "__main__":
    main()
