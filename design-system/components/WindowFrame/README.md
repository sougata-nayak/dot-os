A window is a flat `surface` panel with a 1px outline and a title bar. Focus is shown by the outline and the title, never by a shadow.

**You provide:** the title (app — document) and the body content.

- Classes `nil-window`, `nil-window__bar`, `nil-window__title`, `nil-window__controls`, `nil-window__body`; add `nil-window--inactive` to unfocused windows.
- Focused: `border-visible` outline, `text-primary` title, a filled `text-display` close dot. Unfocused: `border` outline, `text-disabled` title, hollow controls.
- Controls sit on the right in the order minimise, maximise, close: three 12px circles. Close turns `accent` only on hover.
- Title is `label` type, left-aligned. Do not centre it and do not put an app icon beside it.
- Corners are `radius-card`; in a tiling layout separate windows by `space-sm`.
- Give each control a 24px or larger hit area in the real toolkit; the circle is the mark, not the target.
