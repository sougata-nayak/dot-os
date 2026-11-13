The launcher is a keyboard-first command line for apps, files and system commands, centred in the upper third of the screen.

**You provide:** the result list, each with a name and a type label (`APP`, `COMMAND`, `FILE`, `SETTING`).

- Classes `nil-launcher`, `nil-launcher__prompt`, `nil-launcher__item` (with `aria-selected`).
- The query is Space Mono in `text-display` after a `>` prompt. Results are `body-sm`, one line each, `control-min` tall.
- The selected row is `surface-raised` with a 2px `accent` bar on its left edge. While the launcher is open this is the screen's red element.
- Show at most six results. No icons, no categories headers, no preview pane.
- Backdrop is `black` at 80% opacity, never a blur. Empty query shows nothing below the prompt.
