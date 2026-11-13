Quick settings is the popover behind the top bar's status group: a two-column grid of toggle tiles above segmented sliders.

**You provide:** four to eight tiles (a label and a current-state line each) and up to three sliders with a percentage.

- Classes `nil-qs`, `nil-qs__tile` (a button with `aria-pressed`), `nil-qs__wide` for full-width rows.
- An on tile inverts: `text-display` fill, `black` text. An off tile is an outline in `border-visible`. No coloured tiles, no icons required.
- The second line states the fact ("Studio 5G", "Until 18:00", "Off"), in sentence case.
- Sliders are segmented progress bars with the number beside the label; each step is one segment.
- The panel is a `surface` with a `border-visible` outline and `radius-widget` corners. It fades in below the bar, `space-sm` clear of it.
