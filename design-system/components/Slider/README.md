A slider sets a continuous value where the exact number matters less than the feel: pointer speed, scale, balance.

**You provide:** a `label` above it, the current value in `caption` at the right, and the range.

- Class `dot-slider` wrapping an `<i>` (the filled part, width as a percentage) and an `input type="range"`.
- 2px groove in `border-visible`, filled part and 16px round handle in `text-display`.
- Volume and brightness are levels, not feels: show them as a Segmented progress bar and step them from the keyboard.
- Never tint the fill with a status colour.
