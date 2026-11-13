DOT OS is a monochrome, typographically driven skin for the Linux desktop: OLED black or warm paper, dot-matrix display type, instrument-panel labels, and red kept for what is live or wrong. Build every surface — shell, apps, boot, terminal — from the tokens and components here.

## Principles

- **Subtract first.** Every element earns its pixel. If a panel works without a border, a divider or an icon, remove it.
- **Structure is the ornament.** Show the grid, the data and the hierarchy. No illustrations, wallpapers with scenery, or decorative gradients.
- **Monochrome is the canvas; colour is an event.** `accent` does two jobs and no others: it marks the one live point of a part, and it flags what needs attention now.
- **Three layers per screen, never more.** One primary (a number, a state, a clock), its supporting context, and metadata pushed to the edges.
- **Percussive, not fluid.** Things click into place. They do not swoosh, bounce or blur.

## Colour

- Paint the desktop, panels and terminal on `black`. Raise cards, windows and popovers on `surface`; use `surface-raised` only for a selected row or a second level inside a `surface`.
- Separate with `border` (decorative hairlines between rows) and `border-visible` (edges of windows, controls and popovers — anything whose outline carries meaning).
- The grey scale is the hierarchy. Use at most four levels on a screen: `text-display` for the one hero value, `text-primary` for content, `text-secondary` for labels and metadata, `text-disabled` for disabled controls and decorative marks only.
- `accent` as an **interrupt**: a critical notification, an error, an over-limit reading, a destructive outline. An interrupt always carries words beside the colour (`[ERROR: DISK FULL]`), and a screen shows at most one.
- `accent` as a **live marker**: the text caret, the clock's colon, today in the calendar, the current workspace's brackets, the focused app's dot, the leading segment of a running progress bar, an unread dot. A live marker is a mark, never text; at most one per part, and never larger than 36px.
- Never use `accent` for selection, links, buttons at rest, branding or decoration. Selection and "on" states invert instead: `text-display` fill with `black` text. Text on an accent fill is `on-accent`.
- Encode data status on the **value**, never the label or the row: `success` in range, `warning` attention, `accent` over limit. Always keep the number or a word beside the colour.
- `interactive` is for inline links only, never for buttons.
- Dark is the first theme; light is its equal. Light reads as a printed manual: `black` becomes off-white paper and `surface` becomes white, so cards lift without shadows.
- In the light theme `success`, `warning` and `interactive` do not reach 4.5:1 as small text. There, use them for bars, dots and text 24px or larger, and set the reading itself in `text-primary`.

## Type

- Three families, two per screen plus one display moment: `display` (Doto) for a single hero — a clock, a boot percentage, the lock screen; `sans` (Space Grotesk) for content; `mono` (Space Mono) for labels, numbers, the panel and the terminal.
- Doto only at 36px and above (`display-md`, `display-lg`, `display-xl`). Never for body text, never twice on a screen.
- Labels are always `label`: Space Mono, ALL CAPS, 0.08em tracking, `text-secondary`. Write them like an instrument panel: `CPU`, `MEM`, `NET`, `VOL`.
- Numbers are always Space Mono. Set the unit in `label` size, raised, 4px after the value: `36`<sup>GB/S</sup>.
- Budget per screen: three sizes, two weights. Reach for spacing before reaching for a new size.

## Voice

- Terse, technical, lower-drama. Sentence case in content; ALL CAPS only in `label` and buttons.
- System status is inline bracket text in Space Mono, next to what triggered it: `[SAVED]`, `[LOADING...]`, `[ERROR: DISK FULL]`, `[ OK ]`. No toasts, no exclamation marks, no emoji.
- Empty states are one `text-secondary` headline and at most one sentence: "No devices." Not "Looks like there's nothing here yet!"
- Address the user as "you"; the system never says "I" or "we".

## Space and layout

- 8px base. `space-xs`–`space-sm` binds things that belong together, `space-md` separates items in a group, `space-xl`–`space-2xl` starts a new group, `space-3xl`–`space-4xl` gives the hero its room.
- Group by proximity first, then a single `border` divider, then a `border-visible` outline, then a `surface` card. Use the lightest that works. Never box the hero.
- Compose asymmetrically: hero large and left, metadata small and right or pinned to the bottom edge. Leave large areas of `black` empty.
- Break the pattern in exactly one place per screen — the Doto clock, one circular control among rectangles, the red dot.

## Shape, borders, depth

- No shadows, no blur, no translucency, no gradients. Depth is `black` → `surface` → `surface-raised` plus a 1px border.
- `radius-pill` for buttons, tags, toggles and the dock; `radius-card` for windows, notifications and tiles; `radius-widget` for widgets, the launcher and popovers; `radius-compact` for menus and inputs with a full border; `radius-technical` for technical tags. Progress segments and terminal cells are square.
- Focus is a 2px solid `text-display` ring, 2px outside the control, in both themes.
- The dot grid (`dot-pitch`, 1px dots in `border-visible`) is the only texture. Use it behind the lock screen and empty states, never as a border or inside a button.

## Motion

- 150–250ms for hover, press and toggle; 300–400ms for a window or popover appearing. Easing `cubic-bezier(0.25, 0.1, 0.25, 1)` everywhere.
- Fade; do not slide, scale, wobble or bounce. Windows open by opacity; workspaces switch by a cut or a short cross-fade.
- Hover brightens a border or a text colour. Nothing grows.
- Loading is a segmented bar with a percentage, or `[LOADING...]`. No skeletons, no spinners with trails.

## Iconography

- Monoline, 1.5px stroke, no fill, round caps and joins, 24px box with a 20px live area, at most five or six strokes. Icons inherit the text colour.
- The icon set is Lucide, redrawn at the 1.5px stroke. Never filled, duotone or multi-colour icons, never emoji.
- In the top bar prefer a three-letter `label` and a value (`BAT 84%`) to an icon.

## Wordmark

- There is no logo. Set the name as `DOT OS` in `display` (Doto, weight 700) on `black`, with nothing beside it.

## Intentional additions

- `ansi-magenta` and `ansi-cyan` exist only to complete the terminal's 16-colour palette; do not use them in the shell.
- `bar-height`, `titlebar-height`, `control-min`, `icon` and `dot-pitch` fix the shell's recurring measurements.
