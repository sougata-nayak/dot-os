# Status

Last updated 12 November 2026.

## Done

| Step | Result | How it was checked |
| --- | --- | --- |
| Plain arm64 ISO (Phase 1a) | Debian 13 + Plasma live image, 2.3 GB, built with `scripts/build-iso.sh` | Booted in QEMU (HVF, UEFI): GRUB → Plasma desktop → Calamares opens. Screenshots 01 and 02. |
| Colour schemes | `DotOSDark.colors`, `DotOSLight.colors` | Applied in the live session; dark checked by eye. |
| Konsole profile | palette, Space Mono, red block cursor | Screenshot 07. |
| Fonts | Doto, Space Grotesk, Space Mono + fontconfig defaults | `fc-list` in the VM; visible in every screenshot. |
| Kvantum theme | Qt widgets, dark and light | Kvantum's preview app, all six tabs, dark. Screenshots 03–05. |
| Icon theme | about 580 names, two stroke weights | Panel, file manager. Screenshot 06. |
| Cursor theme | 12 cursors, 24/32/48 px, dark and light | Installs and applies; not checked by eye (the pointer is not in VM screenshots). |
| GTK theme | GTK 3, GTK 4, libadwaita colours | Installs and is set as the GTK theme; **not checked by eye** (no GTK app in the plain image). |

## Not checked yet

- The Calamares install itself, and the first boot of an installed system.
- Booting the ISO in UTM (it was booted in QEMU, which UTM is built on).
- Every light theme.
- GTK and libadwaita apps.
- The cursor theme on screen.

## Known gaps in the first pass

- **Qt control height is 36px**, not the design system's 44px. 44px makes Qt dialogs overflow; the 44px minimum is kept for the shell, greeter and installer.
- **Qt spin boxes** take the underline field style, not the outlined box on the Controls board.
- **Button labels in Qt and GTK apps are not uppercase mono**; toolkits cannot restyle label case or family per widget.
- **A default button** gets a `text-display` outline and bold label, not the inverted fill on the board.
- Kvantum parts not drawn yet fall back to Kvantum's default look: toolbox tabs, MDI sub-window title bars, the vertical toggle button.
- The splitter between a sidebar and a view draws wider than the 1px hairline in the design.
- Icons outside the mapped set fall back to Breeze.
- libadwaita apps need `/usr/share/dot-os/gtk-4.0/dark.css` linked to `~/.config/gtk-4.0/gtk.css`; the global theme package will do this.
- The panel, window decorations, lock screen and splash are still Breeze. They belong to `plasma-lookandfeel` (Phase 3).

## Next

1. Phase 2: SDDM, Plymouth and GRUB themes.
2. Phase 3: Plasma global theme — panel layout, Aurorae window decoration, lock screen, session splash, wallpapers, defaults for every package above.
3. Run a full Calamares install in the VM and compare the installed system with the live session.
4. `dot-os-desktop` meta-package and a signed APT repository.
