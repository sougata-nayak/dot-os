A widget is a small desktop instrument: a category label, one large number, and a little supporting data.

**You provide:** a category, the hero value with its unit, and up to three stat rows or one segmented bar.

- Classes `nil-widget`, `nil-widget__hero` with `nil-data`, `nil-unit`.
- Category top-left in `label`. Hero in Space Mono 48px `text-display`, left-aligned, unit raised beside it.
- One widget on a desktop may set its hero in Doto (`nil-display`) instead — the clock, usually. The rest stay in Space Mono.
- Vary the form between neighbouring widgets (bar in one, stat rows in the next) but keep the voice identical.
- `surface` ground, 1px `border`, `radius-widget`, padding `space-lg`. Widgets sit on the desktop's dot grid at `dot-pitch` multiples.
