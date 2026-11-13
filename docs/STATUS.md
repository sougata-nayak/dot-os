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
| Plasma global theme (Phase 3) | defaults for new users, top bar and dock, panel and popup theme, window decoration, dot grid wallpaper, session splash, power screen | Installed system in QEMU, as brand-new users: first login gives the full desktop with no manual steps. Screenshots 13-15, 20-22. |
| High-density displays | vector cursors, 2x/3x icon folders, 2x boot splash, self-scaling login screen, vector wallpaper | 2560x1600 display at 2x scale: desktop, splash and login. Screenshots 16-18. |
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
- **Lock screen and volume OSD replace Plasma's own files.** In Plasma 6.3 both live in the desktop shell package, so the package diverts those two files (`dpkg-divert`) and restores them on removal. If the DOT OS lock screen ever fails to load, kscreenlocker falls back to its built-in screen, so nobody is locked out (tested).
- **Windows have square corners.** KWin's SVG decoration engine squeezes corner artwork to the 1px border, so the 12px radius on the Windows board is not possible; the frame is a 1px outline with a 40px title bar.
- **Window titles are not uppercase** (KWin's decoration engine has no text-case option).
- **The dock marks apps with a short bar, not a dot** (Plasma's task frames are stretched pieces). Red still means the focused app.
- **The launcher's account picture** is the system default (a Debian logo from desktop-base) until Phase 5 sets a DOT OS default.
- **KDE's Welcome Center** opens at first login; Phase 5 decides whether DOT OS replaces or disables it.
- **The launcher and KRunner** are stock layouts in DOT OS colours; the selected KRunner row has no red edge.

## Phase 2 findings

- **Serial consoles hide the splash.** arm64 VMs and most boards have one, and Plymouth then drops to text. The live ISO and the plymouth package both add `plymouth.ignore-serial-consoles` to the kernel command line.
- **SDDM's on-screen keyboard** popped up over the form on Wayland. The theme's config turns it off (`InputMethod=`).
- **The greeter kept an old copy of the theme** after an upgrade, because package builds pin file times and Qt's QML cache trusts them. The package clears the cache on install.
- **GRUB ignores a progress bar's height** (it always drew 28px), so the countdown is text only.
- **GRUB can't put brackets around the selected entry** (its highlight spans the whole menu width), so the selection inverts, like a menu's current item. The GRUB board was updated to match.
- **Installed GRUB entries say "Debian GNU/Linux".** Renaming them means changing `GRUB_DISTRIBUTOR`, which also renames the EFI boot directory. That needs to be done together with the installer's `efiBootloaderId` in Phase 5.
- **Debian's plymouth has no `plymouth-set-default-theme`**; the package writes `/etc/plymouth/plymouthd.conf` directly.

## Phase 3 findings

- **A new panel takes its minimum height from the theme's default panel artwork.** With the dock's 30px pill corners as the default, the top bar came out 60px tall. The pill is now only the bottom-edge variant.
- **Plasma's GTK bridge defaults to Breeze.** A one-time login step sets the DOT OS GTK theme.
- **At 2x, small icons were looked up as 48px** and got the thin large-icon cut. The icon theme now declares 2x and 3x folders.
- **SDDM gets no scale factor before a session starts**, so the login theme scales itself on large panels.
- **Not checked:** the light global theme (`org.dotos.desktop.light` is built but untested), fractional scales, multi-monitor, the X11 session, the session splash on screen.

## Refinement pass

- Calendar: custom month grid; today is a red disc, as on the Panels board.
- Desktop: dot-matrix clock with a red colon, CPU and memory cards, placed as on the Main board and kept across logins.
- Top bar: `NET`, `VOL` and `BAT` readings instead of tray icons; the tray keeps everything one click away under its arrow. Scroll on `VOL` to change volume, click to mute.
- Lock screen and volume OSD: DOT OS versions, as on the Lock and Switcher boards.

## Readability and control center pass

- **Text was rendering in Space Grotesk Light.** The variable font's default instance is Light (300) and fontconfig handed it to the whole interface; Doto's default was Black. `fonts-dot-os` now ships static Light/Regular/Medium/Bold cuts, so every toolkit gets the weight it asks for.
- **Anti-aliasing is greyscale with slight hinting** (fontconfig, KDE and GTK settings): no colour fringes on black, and right for high-density panels.
- **Control center** from the Quick settings board opens from the NET/VOL/BAT readout: Wi-Fi, Bluetooth, Night light and Do not disturb tiles (on inverts), brightness, volume and battery meters you can click or drag, and Settings, Lock and Power. Screenshot 23.

## Default display

- **3840x2160 at 250%** is set at a user's first login on any screen that offers that mode (`/usr/share/dot-os/display-defaults.py`). Screens without it keep the mode and scale KWin picks, so a 1080p panel is never set to 250%. Users can change it in System Settings afterwards; the default is not reapplied.
- The login screen scales itself to 250% on 4K panels, and desktop widget positions are saved for the 4K logical size so they don't move when the mode changes. Screenshots 24-26.
- `scripts/run-vm.sh` now starts the VM with a 3840x2160 display. In UTM, set the display to 3840x2160 (see TESTING.md).

## Next

1. Phase 4: `dot-os-desktop` meta-package and a signed APT repository.
2. Phase 5: Calamares branding, "DOT OS" boot entries, live session matching the installed system.
3. Phase 6: CI release on tag.
