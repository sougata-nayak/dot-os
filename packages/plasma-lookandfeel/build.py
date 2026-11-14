#!/usr/bin/env python3
"""Build the DOT OS Plasma layer into build/:

  look-and-feel/org.dotos.desktop[.light]   global theme: defaults, panel layout,
                                            splash, power screen
  desktoptheme/dot-os                       panel, popup and task SVGs (follow the colour scheme)
  aurorae/DotOS-Dark, DotOS-Light           window decoration
  wallpapers/org.dotos.dotgrid              the dot grid wallpaper plugin
  plasmoids/org.dotos.workspaces            text workspace switcher for the top bar

Everything is vector (SVG or QML in logical pixels), so it scales cleanly on
high-density displays. Colours come from design-system/tokens.json.
"""
import json
import os
import re
import shutil
import subprocess
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import tokens  # noqa: E402

OUT = "build"
T = tokens.load()
CAP = tokens.CAP


def version():
    with open("debian/changelog") as fh:
        return fh.readline().split("(")[1].split(")")[0]


def write(path, text):
    full = os.path.join(OUT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as fh:
        fh.write(text)


def fill_tokens(text, values, where):
    def repl(m):
        key = m.group(1)
        if key not in values:
            raise SystemExit("%s: unknown token @%s@" % (where, key))
        return str(values[key])
    return re.sub(r"@([a-z][a-z0-9-]*)@", repl, text)


def copy_tree(src, dst, values):
    for base, _dirs, files in os.walk(src):
        for name in files:
            path = os.path.join(base, name)
            rel = os.path.relpath(path, src)
            with open(path) as fh:
                text = fh.read()
            write(os.path.join(dst, rel), fill_tokens(text, values, path))


def dot_svg(colour):
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">'
            '<circle cx="8" cy="8" r="1" fill="%s"/></svg>\n' % colour)


# ---------------------------------------------------------------- look and feel

def look_and_feel(theme):
    t = dict(T[theme])
    t["version"] = version()
    ident = "org.dotos.desktop" + ("" if theme == "dark" else ".light")
    base = "look-and-feel/%s/" % ident
    copy_tree("src/lnf", base + "contents", t)
    write(base + "metadata.json", json.dumps({
        "KPackageStructure": "Plasma/LookAndFeel",
        "KPlugin": {
            "Authors": [{"Name": "DOT OS project"}],
            "Category": "",
            "Description": "Monochrome, typographic, red only where something is live or wrong. %s." % CAP[theme],
            "Id": ident,
            "License": "MIT",
            "Name": "DOT OS" + ("" if theme == "dark" else " Light"),
            "Version": t["version"],
            "Website": "https://github.com/dot-os/dot-os",
        },
        "X-Plasma-APIVersion": "2",
    }, indent=4) + "\n")
    cursor = "DotOS-Cursors" + ("" if theme == "dark" else "-Light")
    write(base + "contents/defaults", """[kdeglobals][KDE]
widgetStyle=kvantum

[kdeglobals][General]
ColorScheme=DotOS%(cap)s

[kdeglobals][Icons]
Theme=dot-os%(icon)s

[plasmarc][Theme]
name=dot-os

[kcminputrc][Mouse]
cursorTheme=%(cursor)s

[kwinrc][org.kde.kdecoration2]
library=org.kde.kwin.aurorae
theme=__aurorae__svg__DotOS-%(cap)s
ButtonsOnLeft=
ButtonsOnRight=IAX

[KSplash]
Theme=%(ident)s

[Wallpaper]
Image=
""" % {"cap": CAP[theme], "icon": "" if theme == "dark" else "-light", "cursor": cursor, "ident": ident})


# ---------------------------------------------------------------- plasma theme

STYLE = ('<style id="current-color-scheme" type="text/css">'
         '.ColorScheme-Text{color:%(text-primary)s}.ColorScheme-Background{color:%(black)s}'
         '.ColorScheme-ViewBackground{color:%(black)s}.ColorScheme-ViewText{color:%(text-primary)s}'
         '.ColorScheme-ButtonBackground{color:%(surface)s}.ColorScheme-ButtonText{color:%(text-primary)s}'
         '.ColorScheme-Highlight{color:%(text-display)s}.ColorScheme-HighlightedText{color:%(black)s}'
         '.ColorScheme-NegativeText{color:%(accent)s}.ColorScheme-NeutralText{color:%(warning)s}'
         '.ColorScheme-PositiveText{color:%(success)s}</style>')

# (css class, opacity) pairs the frames are painted with
BLACK = ("Background", 1)
SURFACE = ("ButtonBackground", 1)
BORDER = ("Text", 0.13)          # border
BORDER_VISIBLE = ("Text", 0.2)   # border-visible
HOVER = ("Text", 0.07)           # about `surface` on black
RAISED = ("Text", 0.1)           # about `surface-raised` on black
INK = ("Text", 1)
ACCENT = ("NegativeText", 1)


class Svg:
    """A Plasma theme SVG. Elements are laid out left to right; only ids matter."""

    def __init__(self):
        self.parts = []
        self.x = 0
        self.height = 0

    @staticmethod
    def paint(colour):
        cls, opacity = colour
        return 'class="ColorScheme-%s" fill="currentColor" fill-opacity="%s"' % (cls, opacity)

    def rect(self, x, y, w, h, colour):
        return '<rect x="%s" y="%s" width="%s" height="%s" %s/>' % (x, y, w, h, self.paint(colour))

    def bounds(self, w, h):
        return '<rect width="%s" height="%s" fill="#000" fill-opacity="0"/>' % (w, h)

    def element(self, ident, x, y, w, h, body=""):
        self.parts.append('<g id="%s" transform="translate(%s,%s)">%s%s</g>'
                          % (ident, self.x + x, y, self.bounds(w, h), body))
        self.height = max(self.height, y + h)

    def corner(self, s, r, fill, stroke, sw, top, left, flip):
        body = ""
        rounded = top and left and r > sw
        if not rounded:
            if fill:
                body += self.rect(0, 0, s, s, fill)
            if stroke and top:
                body += self.rect(0, 0, s, sw, stroke)
            if stroke and left:
                body += self.rect(0, sw if top else 0, sw, s - (sw if top else 0), stroke)
        else:
            r = min(r, s)
            if fill:
                body += '<path d="M0 %s V%s A%s %s 0 0 1 %s 0 H%s V%s Z" %s/>' % (s, r, r, r, r, s, s, self.paint(fill))
            if stroke:
                ri = r - sw
                body += ('<path d="M0 %s V%s A%s %s 0 0 1 %s 0 H%s V%s H%s A%s %s 0 0 0 %s %s V%s Z" %s/>'
                         % (s, r, r, r, r, s, sw, r, ri, ri, sw, r, s, self.paint(stroke)))
        return '<g transform="%s">%s</g>' % (flip, body) if flip else body

    def frame(self, prefix, s, r, fill=None, stroke=None, sw=1, sides="tblr", margins=None, centre=32):
        """Nine pieces plus margin hints. `margins` is (top, bottom, left, right)."""
        p = prefix + "-" if prefix else ""
        t, b, l, rr = ("t" in sides), ("b" in sides), ("l" in sides), ("r" in sides)
        c = centre
        self.element(p + "topleft", 0, 0, s, s, self.corner(s, r, fill, stroke, sw, t, l, ""))
        self.element(p + "topright", s + c, 0, s, s,
                     self.corner(s, r, fill, stroke, sw, t, rr, "translate(%s,0) scale(-1,1)" % s))
        self.element(p + "bottomleft", 0, s + c, s, s,
                     self.corner(s, r, fill, stroke, sw, b, l, "translate(0,%s) scale(1,-1)" % s))
        self.element(p + "bottomright", s + c, s + c, s, s,
                     self.corner(s, r, fill, stroke, sw, b, rr, "translate(%s,%s) scale(-1,-1)" % (s, s)))

        def edge(w, h, line):
            body = self.rect(0, 0, w, h, fill) if fill else ""
            if stroke and line:
                body += self.rect(*line, stroke)
            return body

        self.element(p + "top", s, 0, c, s, edge(c, s, (0, 0, c, sw) if t else None))
        self.element(p + "bottom", s, s + c, c, s, edge(c, s, (0, s - sw, c, sw) if b else None))
        self.element(p + "left", 0, s, s, c, edge(s, c, (0, 0, sw, c) if l else None))
        self.element(p + "right", s + c, s, s, c, edge(s, c, (s - sw, 0, sw, c) if rr else None))
        self.element(p + "center", s, s, c, c, self.rect(0, 0, c, c, fill) if fill else "")
        if margins:
            mt, mb, ml, mr = margins
            y = 2 * s + c + 4
            self.element(p + "hint-top-margin", 0, y, 8, mt)
            self.element(p + "hint-bottom-margin", 12, y, 8, mb)
            self.element(p + "hint-left-margin", 24, y, ml, 8)
            self.element(p + "hint-right-margin", 24 + ml + 4, y, mr, 8)
        self.x += 2 * s + c + 8

    def single(self, ident, w, h, body=""):
        self.element(ident, 0, 0, w, h, body)
        self.x += w + 8

    def text(self):
        return ('<?xml version="1.0" encoding="UTF-8"?>\n'
                '<!-- Generated by packages/plasma-lookandfeel/build.py. Do not edit by hand. -->\n'
                '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">\n'
                '<defs>%s</defs>\n%s\n</svg>\n'
                % (self.x, self.height + 8, self.x, self.height + 8, STYLE % T["dark"], "\n".join(self.parts)))


def plasma_theme():
    base = "desktoptheme/dot-os/"

    def save(name, svg):
        for variant in ("", "opaque/", "solid/", "translucent/"):
            write(base + variant + name + ".svg", svg.text())

    # Panels. Default: the dock's floating pill. Top edge: the flat bar with a hairline.
    s = Svg()
    # The unprefixed frame is the flat bar: Plasma sizes a new panel from it
    # before it knows the panel's edge, so it must not carry the pill's 30px corners.
    s.frame("", 4, 0, BLACK, BORDER, sides="b", margins=(0, 1, 8, 8))
    s.frame("south", 30, 30, SURFACE, BORDER_VISIBLE, margins=(8, 8, 8, 8))
    s.frame("north", 4, 0, BLACK, BORDER, sides="b", margins=(0, 1, 8, 8))
    s.frame("west", 4, 0, BLACK, BORDER, sides="r", margins=(8, 8, 0, 1))
    s.frame("east", 4, 0, BLACK, BORDER, sides="l", margins=(8, 8, 1, 0))
    s.single("hint-tile-center", 4, 4)
    save("widgets/panel-background", s)

    # Popups, the launcher, notifications: surface, outline, radius-widget.
    s = Svg()
    s.frame("", 16, 16, SURFACE, BORDER_VISIBLE, margins=(8, 8, 8, 8))
    save("dialogs/background", s)
    s = Svg()
    s.frame("", 16, 16, SURFACE, BORDER_VISIBLE, margins=(12, 12, 12, 12))
    s.single("hint-stretch-borders", 4, 4)
    save("widgets/background", s)
    s = Svg()
    s.frame("", 4, 4, SURFACE, BORDER_VISIBLE, margins=(6, 6, 8, 8))
    save("widgets/tooltip", s)
    s = Svg()
    s.frame("header", 8, 0, None, BORDER, sides="b")
    s.frame("footer", 8, 0, None, BORDER, sides="t")
    s.frame("", 8, 0, None, None, margins=(8, 8, 8, 8))
    s.single("hint-stretch-borders", 4, 4)
    save("widgets/plasmoidheading", s)

    # Buttons: pill outline; tool buttons show an outline only on hover.
    s = Svg()
    m = (6, 6, 14, 14)
    s.frame("normal", 16, 16, None, BORDER_VISIBLE, margins=m)
    s.frame("hover", 16, 16, None, INK, margins=m)
    s.frame("pressed", 16, 16, RAISED, INK, margins=m)
    s.frame("focus", 16, 16, None, INK, sw=2, margins=m)
    tm = (4, 4, 4, 4)
    s.frame("toolbutton-hover", 8, 8, None, BORDER_VISIBLE, margins=tm)
    s.frame("toolbutton-pressed", 8, 8, RAISED, BORDER_VISIBLE, margins=tm)
    s.frame("toolbutton-focus", 8, 8, None, INK, sw=2, margins=tm)
    save("widgets/button", s)

    # Text fields: underline only.
    s = Svg()
    m = (4, 6, 2, 2)
    s.frame("base", 4, 0, None, BORDER_VISIBLE, sides="b", margins=m)
    s.frame("hover", 4, 0, None, INK, sides="b", margins=m)
    s.frame("focus", 4, 0, None, INK, sides="b", margins=m)
    s.frame("focusframe", 4, 0, None, None, margins=m)
    s.single("hint-tile-center", 4, 4)
    save("widgets/lineedit", s)

    # Lists: hover is surface, the current row surface-raised.
    s = Svg()
    s.frame("normal", 8, 8)
    s.frame("hover", 8, 8, HOVER)
    s.frame("selected", 8, 8, RAISED)
    s.frame("selected+hover", 8, 8, RAISED)
    s.single("hint-tile-center", 4, 4)
    save("widgets/viewitem", s)
    s = Svg()
    lm = (4, 4, 8, 8)
    s.frame("normal", 8, 8, margins=lm)
    s.frame("hover", 8, 8, HOVER, margins=lm)
    s.frame("pressed", 8, 8, RAISED, margins=lm)
    s.frame("section", 8, 8, margins=lm)
    s.single("separator", 16, 1, s.rect(0, 0, 16, 1, BORDER))
    s.single("hint-tile-center", 4, 4)
    save("widgets/listitem", s)

    # Tasks in the dock: a short bar under the icon. Red marks the focused app.
    s = Svg()

    def task(prefix, bar, fill=None):
        size, c = 16, 32
        p = prefix + "-"
        for name, x, y, w, h in (("topleft", 0, 0, size, size), ("top", size, 0, c, size),
                                 ("topright", size + c, 0, size, size), ("left", 0, size, size, c),
                                 ("center", size, size, c, c), ("right", size + c, size, size, c),
                                 ("bottomleft", 0, size + c, size, size), ("bottomright", size + c, size + c, size, size)):
            s.element(p + name, x, y, w, h, s.rect(0, 0, w, h, fill) if fill else "")
        body = (s.rect(0, 0, c, size, fill) if fill else "") + (s.rect(0, size - 5, c, 2, bar) if bar else "")
        s.element(p + "bottom", size, size + c, c, size, body)
        s.x += 2 * size + c + 8

    task("normal", ("Text", 0.6))
    task("hover", ("Text", 0.6), HOVER)
    task("focus", ACCENT)
    task("attention", ACCENT, ("NegativeText", 0.15))
    task("minimized", ("Text", 0.3))
    task("progress", None, ("Text", 0.15))
    save("widgets/tasks", s)

    # Progress and level bars (the volume and brightness OSD): flat, square, 4px.
    for name, w, h in (("bar_meter_horizontal", 8, 4), ("bar_meter_vertical", 4, 8)):
        s = Svg()
        for prefix, colour in (("bar-inactive", BORDER_VISIBLE), ("bar-active", INK)):
            for pos, x, y, pw, ph in (("topleft", 0, 0, 1, 1), ("top", 1, 0, w, 1), ("topright", 1 + w, 0, 1, 1),
                                      ("left", 0, 1, 1, h - 2), ("center", 1, 1, w, h - 2), ("right", 1 + w, 1, 1, h - 2),
                                      ("bottomleft", 0, h - 1, 1, 1), ("bottom", 1, h - 1, w, 1),
                                      ("bottomright", 1 + w, h - 1, 1, 1)):
                s.element("%s-%s" % (prefix, pos), x, y, pw, ph, s.rect(0, 0, pw, ph, colour))
            s.x += w + 10
        s.single("hint-bar-size", 4, 4)
        s.single("hint-tile-center", 4, 4)
        save("widgets/" + name, s)

    s = Svg()
    s.single("horizontal-line", 16, 1, s.rect(0, 0, 16, 1, BORDER))
    s.single("vertical-line", 1, 16, s.rect(0, 0, 1, 16, BORDER))
    save("widgets/line", s)

    write(base + "metadata.json", json.dumps({
        "KPlugin": {
            "Authors": [{"Name": "DOT OS project"}],
            "Description": "Flat panels and popups: 1px outlines, no shadows, blur or translucency.",
            "Id": "dot-os",
            "License": "MIT",
            "Name": "DOT OS",
            "Version": version(),
        },
        "X-Plasma-API": "5.0",
    }, indent=4) + "\n")
    write(base + "plasmarc", "[ContrastEffect]\nenabled=false\n\n[AdaptiveTransparency]\nenabled=false\n\n"
                              "[BlurBehindEffect]\nenabled=false\n")


# ---------------------------------------------------------------- window decoration

def aurorae(theme):
    t = T[theme]
    name = "DotOS-" + CAP[theme]
    base = "aurorae/%s/" % name
    r = t["radius-card"]
    th = t["titlebar-height"]

    def deco(prefix, outline, title):
        """Title bar and a 1px outline."""
        out = []
        x0 = {"decoration": 0, "decoration-inactive": 120, "decoration-maximized": 240,
              "decoration-maximized-inactive": 360}[prefix]
        maximised = "maximized" in prefix
        c = 40

        def el(pos, x, y, w, h, body):
            out.append('<g id="%s-%s" transform="translate(%s,%s)"><rect width="%s" height="%s" fill="#000" '
                       'fill-opacity="0"/>%s</g>' % (prefix, pos, x0 + x, y, w, h, body))

        fill, line = t["surface"], outline
        if maximised:
            # Square, no outline, only the hairline under the title bar.
            el("topleft", 0, 0, 1, th, '<rect width="1" height="%s" fill="%s"/>' % (th, fill))
            el("top", 1, 0, c, th, '<rect width="%s" height="%s" fill="%s"/><rect y="%s" width="%s" height="1" '
               'fill="%s"/>' % (c, th, fill, th - 1, c, t["border"]))
            el("topright", 1 + c, 0, 1, th, '<rect width="1" height="%s" fill="%s"/>' % (th, fill))
            for pos, x, y in (("left", 0, th), ("right", 1 + c, th), ("bottomleft", 0, th + c),
                              ("bottom", 1, th + c), ("bottomright", 1 + c, th + c)):
                el(pos, x, y, c if pos == "bottom" else 1, c if pos in ("left", "right") else 1, "")
            el("center", 1, th, c, c, "")
            return "\n".join(out)
        # Aurorae scales each corner piece to the border width (1px), so the
        # frame is square: a 1px outline all round and a hairline under the title.
        edge = '<rect width="1" height="%s" fill="%s"/>' % (th, line)
        el("topleft", 0, 0, 1, th, edge)
        el("top", 1, 0, c, th, '<rect width="%s" height="%s" fill="%s"/><rect width="%s" height="1" fill="%s"/>'
           '<rect y="%s" width="%s" height="1" fill="%s"/>' % (c, th, fill, c, line, th - 1, c, t["border"]))
        el("topright", 1 + c, 0, 1, th, edge)
        el("left", 0, th, 1, c, '<rect width="1" height="%s" fill="%s"/>' % (c, line))
        el("right", 1 + c, th, 1, c, '<rect width="1" height="%s" fill="%s"/>' % (c, line))
        el("bottomleft", 0, th + c, 1, 1, '<rect width="1" height="1" fill="%s"/>' % line)
        el("bottom", 1, th + c, c, 1, '<rect width="%s" height="1" fill="%s"/>' % (c, line))
        el("bottomright", 1 + c, th + c, 1, 1, '<rect width="1" height="1" fill="%s"/>' % line)
        el("center", 1, th, c, c, "")
        return "\n".join(out)

    svg = ('<?xml version="1.0" encoding="UTF-8"?>\n<svg xmlns="http://www.w3.org/2000/svg" width="480" height="100">\n'
           + deco("decoration", t["border-visible"], t["text-primary"]) + "\n"
           + deco("decoration-inactive", t["border"], t["text-disabled"]) + "\n"
           + deco("decoration-maximized", None, None) + "\n"
           + deco("decoration-maximized-inactive", None, None) + "\n</svg>\n")
    write(base + "decoration.svg", svg)

    # Buttons: a 12px mark centred in a 24px target.
    def button(kind):
        def mark(ident, x, stroke, fill):
            circle = ('<circle cx="12" cy="12" r="5.5" fill="%s" stroke="%s" stroke-width="1"/>'
                      % (fill or "none", stroke))
            return ('<g id="%s-center" transform="translate(%s,0)"><rect width="24" height="24" fill="#000" '
                    'fill-opacity="0"/>%s</g>' % (ident, x, circle))

        sec, disp, bvis, acc = t["text-secondary"], t["text-display"], t["border-visible"], t["accent"]
        if kind == "close":
            states = [("active", disp, disp), ("hover", acc, acc), ("pressed", acc, acc),
                      ("inactive", bvis, None), ("hover-inactive", acc, acc), ("pressed-inactive", acc, acc),
                      ("deactivated", bvis, None), ("deactivated-inactive", bvis, None)]
        else:
            states = [("active", sec, None), ("hover", disp, None), ("pressed", sec, sec),
                      ("inactive", bvis, None), ("hover-inactive", disp, None), ("pressed-inactive", sec, sec),
                      ("deactivated", bvis, None), ("deactivated-inactive", bvis, None)]
        body = "\n".join(mark(ident, i * 28, stroke, fill) for i, (ident, stroke, fill) in enumerate(states))
        return ('<?xml version="1.0" encoding="UTF-8"?>\n<svg xmlns="http://www.w3.org/2000/svg" width="224" '
                'height="24">\n%s\n</svg>\n' % body)

    for kind in ("close", "minimize", "maximize", "restore", "alldesktops", "keepabove", "keepbelow", "shade", "help"):
        write(base + kind + ".svg", button(kind))

    write(base + name + "rc", """[General]
ActiveTextColor=%(active)s
InactiveTextColor=%(inactive)s
UseTextShadow=false
Shadow=false
TitleAlignment=Left
TitleVerticalAlignment=Center
Animation=150
DecorationPosition=0

[Layout]
BorderLeft=1
BorderRight=1
BorderBottom=1
TitleEdgeTop=1
TitleEdgeBottom=1
TitleEdgeLeft=16
TitleEdgeRight=10
TitleEdgeTopMaximized=0
TitleEdgeBottomMaximized=1
TitleEdgeLeftMaximized=16
TitleEdgeRightMaximized=10
TitleBorderLeft=8
TitleBorderRight=8
TitleHeight=%(title)d
ButtonWidth=24
ButtonHeight=24
ButtonSpacing=0
ButtonMarginTop=%(margin)d
ButtonMarginTopMaximized=%(margin)d
ExplicitButtonSpacer=8
PaddingTop=0
PaddingBottom=0
PaddingLeft=0
PaddingRight=0
""" % {"active": tokens.rgb(t["text-primary"]) + ",255", "inactive": tokens.rgb(t["text-disabled"]) + ",255",
       "title": th - 2, "margin": (th - 2 - 24) // 2})
    write(base + "metadata.desktop", """[Desktop Entry]
Name=DOT OS %s
Comment=1px outline, 40px title bar, round marks; no shadow
X-KDE-PluginInfo-Author=DOT OS project
X-KDE-PluginInfo-Name=%s
X-KDE-PluginInfo-Version=%s
X-KDE-PluginInfo-License=MIT
X-KDE-PluginInfo-EnabledByDefault=true
""" % (CAP[theme], name, version()))


def main():
    shutil.rmtree(OUT, ignore_errors=True)
    values = dict(T["dark"])
    values["version"] = version()
    for theme in tokens.THEMES:
        look_and_feel(theme)
        aurorae(theme)
    plasma_theme()
    copy_tree("src/wallpaper", "wallpapers/org.dotos.dotgrid", values)
    with open("src/DotGrid.qml") as fh:
        write("wallpapers/org.dotos.dotgrid/contents/ui/DotGrid.qml", fh.read())
    write("wallpapers/org.dotos.dotgrid/contents/ui/dot-dark.svg", dot_svg(T["dark"]["border-visible"]))
    write("wallpapers/org.dotos.dotgrid/contents/ui/dot-light.svg", dot_svg(T["light"]["border-visible"]))
    write("wallpapers/org.dotos.dotgrid/contents/ui/dot.svg", dot_svg(T["dark"]["border-visible"]))
    copy_tree("src/workspaces", "plasmoids/org.dotos.workspaces", values)
    copy_tree("src/clock", "plasmoids/org.dotos.clock", values)
    for name in ("desktopclock", "system", "status"):
        copy_tree("src/" + name, "plasmoids/org.dotos." + name, values)
        copy_tree("src/common", "plasmoids/org.dotos.%s/contents/ui" % name, values)
    # Lock screen and OSD replace Plasma's own (see debian/postinst).
    copy_tree("src/shell", "shell", T["dark"])
    face()


def face():
    """Default account picture: the icon theme's user glyph (Lucide "user")
    in text-primary on surface. Replaces Debian's swirl from desktop-base,
    which new accounts would otherwise get through /etc/skel/.face."""
    t = T["dark"]
    path = os.path.join(OUT, "face.png")
    src = path + ".svg"
    with open(src, "w") as fh:
        fh.write('<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">'
                 '<rect width="256" height="256" fill="%s"/>'
                 '<g transform="translate(64 64) scale(5.333)" fill="none" stroke="%s" stroke-width="1.25" '
                 'stroke-linecap="round" stroke-linejoin="round">'
                 '<circle cx="12" cy="8" r="5"/><path d="M20 21a8 8 0 0 0-16 0"/></g></svg>'
                 % (t["surface"], t["text-primary"]))
    subprocess.run(["rsvg-convert", src, "-o", path], check=True)
    os.unlink(src)


if __name__ == "__main__":
    main()
