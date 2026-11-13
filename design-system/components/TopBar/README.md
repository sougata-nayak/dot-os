The top bar is the system's instrument strip: workspaces and the focused app on the left, the clock in the centre, status readouts on the right.

**You provide:** the workspace list (current, occupied, empty), the focused app's name, and up to four status readouts as a three-letter label plus a value.

- Class `nil-bar`; height `bar-height`, `black` ground, a single `border` rule beneath. It never floats, blurs or goes translucent.
- Everything is `label` type. The clock is the only `text-display` item; values are `text-primary`; labels are `text-secondary`.
- The current workspace is bracketed and `text-display` (`[ 1 ]`); occupied ones are `text-secondary`; empty ones `text-disabled`.
- Prefer `BAT 84%` to a battery icon. When a reading needs attention, colour the value only (`is-warn`, `is-bad`).
- Do not add a system tray of coloured app icons; fold them into a single status menu.
