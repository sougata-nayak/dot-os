A segmented control picks one of two to four mutually exclusive options that are all worth seeing at once.

**You provide:** two to four one-word options and which is selected (`aria-pressed`).

- Class `nil-segmented` wrapping plain buttons.
- The selected segment inverts (`text-display` fill, `black` text); the rest are `text-secondary` on transparent. The container is a `border-visible` pill.
- Labels are `label` type. Segments are 36px tall.
- More than four options, or labels longer than a word: use a list with a selected row instead.
