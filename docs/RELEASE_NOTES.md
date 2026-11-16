## DOT OS 0.1.0

A monochrome, typographic desktop built on Debian 13 "trixie" and KDE Plasma, for arm64.
OLED black or warm paper, dot-matrix display type, instrument-panel labels, and red kept for what is live or wrong.

### Try it

1. Download `dot-os-arm64.hybrid.iso` and check it: `shasum -a 256 -c SHA256SUMS`.
2. **UTM on an Apple Silicon Mac:** New VM → Virtualize → Linux, leave "Use Apple Virtualization" off, boot the ISO, 4096 MB or more of memory, 4 cores, 20 GB disk or more. Set the display to `virtio-gpu-pci` and untick "Resize display to window size automatically".
3. Pick "Live system (arm64)", then double-click "Install DOT OS". The live user is `user`, password `live`.

### What is in it

- The DOT OS desktop: top bar, dock, dot-grid wallpaper, widgets, lock screen, login screen, boot menu and splash.
- A DOT OS Calamares installer, and DOT OS builds of Dolphin, System Settings, the KDE file widgets and Calamares (Debian's source plus patches in `packages/`).
- Dark and Light, switched in System Settings → Quick Settings. Other theme settings are locked.
- A lightweight image: no Konqueror, KDE Connect, Welcome Center and similar extras.

### Known gaps

- The signed APT archive is built but not published yet, so installed systems do not get DOT OS updates. Debian updates to Dolphin, System Settings, KIO or Calamares replace the DOT OS builds with stock ones.
- Settings pages keep KDE's form layout; the Disk step of the installer keeps Calamares' own layout.
- Dolphin's status bar does not show the free-space label.
- Not tested yet: GTK and libadwaita apps, multi-monitor, the X11 session, fractional scaling.

DOT OS is built on Debian and KDE Plasma and is not affiliated with or endorsed by either project.
Code is MIT, artwork CC BY 4.0, fonts OFL 1.1, icons ISC (see LICENSES.md). Patched Calamares, Dolphin, KIO and System Settings keep their upstream licences.
