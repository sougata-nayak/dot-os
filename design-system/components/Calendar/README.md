The calendar is the popover that opens from the top bar's clock: a month grid and the day's events.

**You provide:** the month, today, and up to three events as List rows beneath the grid.

- Class `dot-cal` for the seven-column grid inside a `dot-pop` popover.
- Numerals in Space Mono; days outside the month in `text-disabled`; weekday heads in `label`.
- Today is the live marker: an `accent` disc with `on-accent` text. A selected day that is not today inverts instead.
- Weeks start on Monday unless the locale says otherwise.
