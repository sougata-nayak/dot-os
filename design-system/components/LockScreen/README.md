The lock screen and login greeter. This is where the system spends its display moment: the time in Doto, alone on the dot grid.

**You provide:** the time and date, the user name, and up to two status readouts.

- Classes `nil-lock` with `nil-dot-grid`, `nil-lock__clock`, `nil-lock__foot`.
- The clock is Doto at 96px (never below `display-xl`), top-left, `space-xl` from the edges. The date sits `space-sm` beneath it in `label`.
- The password field is an underlined input pinned bottom-left; status readouts are pinned bottom-right. The centre stays empty.
- A wrong password turns the underline `accent` and writes `[ERROR: WRONG PASSWORD]` beneath; nothing shakes.
- No avatar, no wallpaper image, no blur of the desktop behind.
