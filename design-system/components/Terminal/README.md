The terminal is the system's native surface: Space Mono on `black`, with a 16-colour palette muted to sit inside the monochrome shell.

**You provide:** the session. The palette, prompt and cursor are fixed.

- Class `nil-term` inside a window frame; span classes `p` (prompt), `c` (comment), `r` `g` `y` `b` `m` `cy` for the ANSI hues.
- Background `black` even inside a `surface` window; text `text-primary`, 14px, line-height 1.5; padding `space-md`.
- Prompt is `text-secondary` and ends in `>`. No powerline glyphs, no emoji, no right prompt.
- Cursor is a solid `text-display` block that does not blink.
- Colours come from the `ansi-*` tokens; bright and normal slots share a hue. See Linux surfaces for the full slot table.
- No transparency or background image.
