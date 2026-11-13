Inputs are a label above an underlined field. Entered text is Space Mono, because on this system most entered values are data.

**You provide:** a label, the value, and optionally one line of inline status beneath.

- Classes `nil-field` (the wrapper), `nil-label`, `nil-input`, `nil-field__msg`; add `nil-field--error` for an invalid value.
- The underline is `border-visible`; on focus it becomes `text-display`; on error, `accent`.
- Status beneath is bracket text in `caption` caps: `[SAVED]`, `[ERROR: EXCEEDS DISK]`. The error message stays `text-secondary` with an `accent` dot before it, so it reads in both themes.
- Placeholders are `text-disabled` and only ever show a format (`00:00`), never an instruction.
- Use a full `border-visible` box with `radius-compact` only for multi-line text.
