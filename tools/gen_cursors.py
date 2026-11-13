"""Cursor theme sources: one SVG per cursor (and per frame for the busy ones),
plus the xcursorgen configs and alias list. packages/cursor-theme/build.sh
rasterises them at package build time (rsvg-convert + xcursorgen)."""
import json

from tokens import CAP, THEMES, write

SIZES = (24, 32, 36, 48, 64, 72, 96)
ARROW = "M5 3v16l4.5-4 3 6.5 2.5-1.2-3-6.3H18z"
DOUBLE = "M2 12l5-4.5V11h10V7.5l5 4.5-5 4.5V13H7v3.5z"
HAND = ("M9 11V4.5a1.5 1.5 0 0 1 3 0V10l5.2 1a2 2 0 0 1 1.6 2.2l-.6 5A3 3 0 0 1 15.2 21H11"
        "a3 3 0 0 1-2.4-1.2L5 15l1-1a1.5 1.5 0 0 1 2 0l1 1z")
# name: (hotspot x, y on the 24 grid, body builder)
SEGS = [(10.5, 3), (15.8, 5.2), (18, 10.5), (15.8, 15.8), (10.5, 18), (5.2, 15.8), (3, 10.5), (5.2, 5.2)]

# Xcursor names each cursor is also published under (symlinks).
ALIASES = {
    "default": ["left_ptr", "arrow", "top_left_arrow", "context-menu", "help", "question_arrow", "whats_this",
                "left_ptr_help", "copy", "alias", "link", "dnd-copy", "dnd-link",
                "d9ce0ab605698f320427677b458ad60b", "5c6cd98b3f3ebcb1f9c7f1c204630408"],
    "pointer": ["hand2", "hand1", "hand", "pointing_hand", "9d800788f1b08800ae810202380a0822",
                "e29285e634086352946a0e7090d73106", "openhand", "grab"],
    "text": ["xterm", "ibeam", "vertical-text"],
    "crosshair": ["cross", "tcross", "cell", "plus", "color-picker"],
    "move": ["fleur", "all-scroll", "size_all", "grabbing", "closedhand", "dnd-move", "dnd-none",
             "4498f0e0c1937ffe01fd06f973665830", "9081237383d90e509aa00f00170e968f"],
    "ew-resize": ["sb_h_double_arrow", "h_double_arrow", "size_hor", "col-resize", "e-resize", "w-resize",
                  "left_side", "right_side", "split_h", "028006030e0e7ebffc7f7070c0600140",
                  "14fef782d02440884392942c11205230"],
    "ns-resize": ["sb_v_double_arrow", "v_double_arrow", "size_ver", "row-resize", "n-resize", "s-resize",
                  "top_side", "bottom_side", "split_v", "00008160000006810000408080010102",
                  "2870a09082c103050810ffdffffe0204"],
    "nwse-resize": ["size_fdiag", "nw-resize", "se-resize", "top_left_corner", "bottom_right_corner",
                    "bd_double_arrow", "c7088f0f3e6c8088236ef8e1e3e70000"],
    "nesw-resize": ["size_bdiag", "ne-resize", "sw-resize", "top_right_corner", "bottom_left_corner",
                    "fd_double_arrow", "fcf1c3c7cd4491d801f1e1c78f100000"],
    "not-allowed": ["crossed_circle", "forbidden", "no-drop", "dnd-no-drop", "circle",
                    "03b6e0fcb3499374a867c041f52298f0"],
    "wait": ["watch", "clock"],
    "progress": ["left_ptr_watch", "half-busy", "3ecb610c1bf2410f44200f48c40d3599",
                 "08e8e1c95fe2fc01f976f1e063a24ccd", "00000000000000020006000e7e9ffc3f"],
}
HOT = {"default": (5, 3), "pointer": (10.5, 3.5), "text": (12, 12), "crosshair": (12, 12), "move": (12, 12),
       "ew-resize": (12, 12), "ns-resize": (12, 12), "nwse-resize": (12, 12), "nesw-resize": (12, 12),
       "not-allowed": (12, 12), "wait": (12, 12), "progress": (3.75, 2.25)}


def shapes(fill, line, dim):
    def p(d, extra=""):
        return '<path d="%s" %s fill="%s" stroke="%s" stroke-width="1" stroke-linejoin="round"/>' % (d, extra, fill, line)

    def ring():
        out = ""
        for colour, width in ((line, 4.5), (fill, 2.5)):
            out += ('<circle cx="12" cy="12" r="8" fill="none" stroke="%s" stroke-width="%s"/>'
                    '<path d="M6.4 6.4l11.2 11.2" fill="none" stroke="%s" stroke-width="%s"/>'
                    % (colour, width, colour, width))
        return out

    def spinner(frame, scale=1.0, dx=0.0, dy=0.0):
        out = ""
        for i, (x, y) in enumerate(SEGS):
            lit = (i - frame) % 8 < 3
            out += ('<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="%s" stroke="%s" stroke-width="%.2f"/>'
                    % (dx + x * scale, dy + y * scale, 3 * scale, 3 * scale, fill if lit else dim, line,
                       1 if scale == 1 else 0.5))
        return out

    one = {
        "default": [p(ARROW)],
        "pointer": [p(HAND)],
        "text": [p("M9 3h6v2h-2v14h2v2H9v-2h2V5H9z")],
        "crosshair": [p("M11 3h2v8h8v2h-8v8h-2v-8H3v-2h8z")],
        "move": [p("M12 2l3.5 4H13v5h5V8.5l4 3.5-4 3.5V13h-5v5h2.5L12 22l-3.5-4H11v-5H6v2.5L2 12l4-3.5V11h5V6H8.5z")],
        "ew-resize": [p(DOUBLE)],
        "ns-resize": [p(DOUBLE, 'transform="rotate(90 12 12)"')],
        "nwse-resize": [p(DOUBLE, 'transform="rotate(45 12 12)"')],
        "nesw-resize": [p(DOUBLE, 'transform="rotate(-45 12 12)"')],
        "not-allowed": [ring()],
        "wait": [spinner(f) for f in range(8)],
        "progress": [p(ARROW, 'transform="scale(.75)"') + spinner(f, 0.66, 8.5, 8.5) for f in range(8)],
    }
    return one


def run(tokens):
    made = []
    for theme in THEMES:
        t = tokens[theme]
        name = "DotOS-Cursors" + ("" if theme == "dark" else "-Light")
        base = "packages/cursor-theme/src/%s/" % name
        # Dark theme: text-display arrow, black outline. Light theme: inverted.
        frames = shapes(t["text-display"], t["black"] if theme == "dark" else "#FFFFFF", t["text-secondary"])
        for cursor, bodies in frames.items():
            for i, body in enumerate(bodies):
                suffix = "-%02d" % i if len(bodies) > 1 else ""
                made.append(write(base + "svg/%s%s.svg" % (cursor, suffix),
                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">'
                                  + body + "</svg>\n"))
            lines = []
            for size in SIZES:
                hx, hy = (round(v * size / 24) for v in HOT[cursor])
                for i in range(len(bodies)):
                    suffix = "-%02d" % i if len(bodies) > 1 else ""
                    delay = " 100" if len(bodies) > 1 else ""
                    lines.append("%d %d %d png/%d/%s%s.png%s" % (size, hx, hy, size, cursor, suffix, delay))
            made.append(write(base + "config/%s.cursor" % cursor, "\n".join(lines) + "\n"))
            # Vector cursors for KWin on Wayland: sharp at any display scale.
            meta = []
            for i in range(len(bodies)):
                suffix = "-%02d" % i if len(bodies) > 1 else ""
                entry = {"filename": "%s%s.svg" % (cursor, suffix), "hotspot_x": HOT[cursor][0],
                         "hotspot_y": HOT[cursor][1], "nominal_size": 24}
                if len(bodies) > 1:
                    entry["delay"] = 100
                meta.append(entry)
            made.append(write(base + "scalable/%s.json" % cursor, json.dumps(meta, indent=1) + "\n"))
        made.append(write(base + "aliases", "".join(
            "%s %s\n" % (alias, cursor) for cursor, names in ALIASES.items() for alias in names)))
        made.append(write(base + "index.theme",
                          "[Icon Theme]\nName=DOT OS%s\nComment=DOT OS cursors, %s\nInherits=breeze_cursors\n"
                          % ("" if theme == "dark" else " Light", theme)))
    return made
