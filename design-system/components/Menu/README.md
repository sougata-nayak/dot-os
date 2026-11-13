A menu lists the actions available on one thing: a context menu, a menu-bar menu, or the open list of a Select.

**You provide:** the items, each with an optional shortcut, in groups of related actions.

- Class `dot-menu`; items are `dot-menu__item` buttons, groups are split by `dot-menu__sep`. The menu bar is `dot-menubar`.
- `surface-raised` ground, 1px `border-visible` outline, `radius-compact`, no shadow. Items are 36px tall with `radius-technical` corners.
- The current item inverts: `text-display` fill, `black` text. Shortcuts are `label` text at the right.
- No icons beside items. A destructive item is not red; the confirm dialog that follows carries the `accent`.
- Menus fade in over 150ms and never slide.
