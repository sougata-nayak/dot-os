Buttons are Space Mono, ALL CAPS, and pill-shaped. There are four: primary, secondary, ghost, destructive.

**You provide:** a label of one or two words — a verb, or verb plus object.

- Classes `nil-btn` plus `nil-btn--primary`, `--secondary`, `--ghost` or `--destructive`.
- **Primary** inverts (`text-display` fill, `black` text): one per view, for the action that moves the user forward.
- **Secondary** is a `border-visible` outline; **ghost** is bare `text-secondary` text for dismissals and inline actions.
- **Destructive** is an `accent` outline with an `accent` dot and `text-display` label. Use it only on the confirming step of something irreversible.
- Minimum height `control-min`; padding 12px by `space-lg`. Disabled is 40% opacity.
- Hover brightens the border or text. Never a shadow, a scale or a fill animation.
- No icons-only buttons in content; if space is tight, shorten the label.
