A toggle is a physical switch: a pill track and a round thumb that moves, for a setting that applies immediately.

**You provide:** a text label to its left naming the setting, and the state via `aria-checked`.

- Class `nil-toggle` on a `button role="switch"`.
- On: `text-display` track, `black` thumb on the right. Off: `border-visible` track, `text-secondary` thumb on the left. The off thumb is `text-secondary`, not `text-disabled`, so it stays 3:1 against its track in both themes.
- Never colour the on state green or red.
- Give it a `control-min` hit area. The thumb moves in 200ms; nothing else animates.
- If the change needs a restart or a confirm, use a button, not a toggle.
