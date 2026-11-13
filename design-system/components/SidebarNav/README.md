Sidebar navigation moves between the sections of an app: settings pages, places in the file manager.

**You provide:** the section names, the current one, and an optional short value or count at the right.

- Class `dot-nav` on the list; each row is a link, the current one marked `aria-current="page"`.
- Rows are 36px, `text-secondary`, `radius-compact`. The current row is `surface-raised` with `text-display` text; it does not invert, because it is a place, not a selection.
- A count that wants attention takes the `dot-unread` live marker: a 6px `accent` dot before the number. One per sidebar.
- No icons unless every row has one.
