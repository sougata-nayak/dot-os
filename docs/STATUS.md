# Status

Last updated 13 November 2026.

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
| GRUB theme (Phase 2) | wordmark, inverted selection, countdown | Live ISO menu and installed system, after a Calamares install and reboot. Screenshots 09, 12. |
| Plymouth splash (Phase 2) | wordmark, 20 segments with a red leading segment, percentage, disk-unlock prompt | Live ISO and installed system, real boots. Screenshot 10. The unlock prompt is not tested (no encrypted disk). |
| SDDM greeter (Phase 2) | clock with red colon, user and password, session, layout, power | Installed system: wrong password shows the error state, right password logs in. Screenshots 08, 11. |
| Calamares install | erase disk, ext4, UEFI | Ran end to end in QEMU; the installed system boots with all three boot themes. |

## Not checked yet

- Booting the ISO in UTM (it was booted in QEMU, which UTM is built on).
- Every light theme.
- GTK and libadwaita apps.
- The cursor theme on screen.

## Known gaps

- **Qt control height is 36px**, not the design system's 44px. 44px makes Qt dialogs overflow; the 44px minimum is kept for the shell, greeter and installer.
- **Qt spin boxes** take the underline field style, not the outlined box on the Controls board.
- **Button labels in Qt and GTK apps are not uppercase mono**; toolkits cannot restyle label case or family per widget.
- **A default button** gets a `text-display` outline and bold label, not the inverted fill on the board.
- Kvantum parts not drawn yet fall back to Kvantum's default look: toolbox tabs, MDI sub-window title bars, the vertical toggle button.
- The splitter between a sidebar and a view draws wider than the 1px hairline in the design.
- Icons outside the mapped set fall back to Breeze.
- libadwaita apps need `/usr/share/dot-os/gtk-4.0/dark.css` linked to `~/.config/gtk-4.0/gtk.css`; the global theme package will do this.
- The panel, window decorations, lock screen and splash are still Breeze. They belong to `plasma-lookandfeel` (Phase 3).

## Phase 2 findings

- **Serial consoles hide the splash.** arm64 VMs and most boards have one, and Plymouth then drops to text. The live ISO and the plymouth package both add `plymouth.ignore-serial-consoles` to the kernel command line.
- **SDDM's on-screen keyboard** popped up over the form on Wayland. The theme's config turns it off (`InputMethod=`).
- **The greeter kept an old copy of the theme** after an upgrade, because package builds pin file times and Qt's QML cache trusts them. The package clears the cache on install.
- **GRUB ignores a progress bar's height** (it always drew 28px), so the countdown is text only.
- **GRUB can't put brackets around the selected entry** (its highlight spans the whole menu width), so the selection inverts, like a menu's current item. The GRUB board was updated to match.
- **Installed GRUB entries say "Debian GNU/Linux".** Renaming them means changing `GRUB_DISTRIBUTOR`, which also renames the EFI boot directory. That needs to be done together with the installer's `efiBootloaderId` in Phase 5.
- **Debian's plymouth has no `plymouth-set-default-theme`**; the package writes `/etc/plymouth/plymouthd.conf` directly.

## Next

1. Phase 3: Plasma global theme — panel layout, Aurorae window decoration, lock screen, session splash, wallpapers, defaults for every package above.
3. Run a full Calamares install in the VM and compare the installed system with the live session.
4. `dot-os-desktop` meta-package and a signed APT repository.
