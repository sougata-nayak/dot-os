The scrollbar shows position in a long view and can be dragged.

**You provide:** nothing; the toolkit sizes the thumb.

- Class `dot-scroll` for the 12px lane; the thumb is an `<i>` inside it.
- A square 4px thumb in `border-visible`, no track, no arrows. It brightens to `text-secondary` on hover and while dragging.
- Minimum thumb length 40px. The lane takes no space from the content's padding.
