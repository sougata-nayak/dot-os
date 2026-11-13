A list row pairs a label on the left with a value on the right, divided from its neighbours by a hairline. It is the workhorse of settings and system info.

**You provide:** a label and a value; optionally a unit and a status.

- Classes `nil-list`, `nil-row`, `nil-row__value`; `nil-row--sub` indents a child row by `space-lg`.
- Label is `label` type; value is Space Mono 14px in `text-primary`. Units use `nil-unit`.
- Status colours the value only (`is-good`, `is-warn`, `is-bad`), and the number stays.
- Dividers are 1px `border`. No zebra striping, no tree lines, no chevrons unless the row navigates.
- Indentation is the hierarchy; there is no expand or collapse.
