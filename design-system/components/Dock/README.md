The dock is a pill of circular app slots, centred at the bottom edge of the screen, `space-md` clear of it.

**You provide:** up to eight apps as monoline icons, and which are running and focused.

- Classes `nil-dock`, `nil-dock__app`; state classes `is-running`, `is-focused`.
- Slots are `control-min` circles. Icons are `text-secondary`, and `text-display` when focused or hovered.
- A running app has a 4px dot beneath its icon. The focused app's dot is `accent` — this is usually the screen's one red element, so nothing else on the desktop should compete with it.
- Icons are 1.5px monoline at `icon` size. Never full-colour vendor icons, badges with counts, or magnification on hover.
- Do not auto-hide with a slide; fade it.
