# Testing

## Boot the ISO

**QEMU** (scripted, what CI-style checks use):

```sh
brew install qemu
scripts/run-vm.sh
```

**UTM** (by hand):

1. Create a new VM → Virtualize → Linux. Leave "Use Apple Virtualization" off so the VM uses QEMU with UEFI.
2. Boot ISO image: `out/dot-os-arm64.hybrid.iso`.
3. Memory 4096 MB or more, 4 cores, 20 GB disk or more.
4. Display: `virtio-gpu-pci`. Network: Shared.
5. Start, pick "Live system (arm64)" in GRUB.

## Apply each package in a Debian 13 + Plasma session

Install first: `sudo apt install ./out/debs/*.deb qt6-style-kvantum`

| Package | Apply |
| --- | --- |
| Colour scheme | `plasma-apply-colorscheme DotOSDark` (or `DotOSLight`) |
| Cursors | `plasma-apply-cursortheme DotOS-Cursors` (or `DotOS-Cursors-Light`) |
| Icons | `/usr/lib/aarch64-linux-gnu/libexec/plasma-changeicons dot-os` (or `dot-os-light`) |
| Qt widgets | `mkdir -p ~/.config/Kvantum && printf '[General]\ntheme=DotOSDark\n' > ~/.config/Kvantum/kvantum.kvconfig && kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum` then restart the app. `kvantumpreview` shows every widget. |
| Fonts | `kwriteconfig6 --file kdeglobals --group General --key font "Space Grotesk,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"` and the same for `fixed` with `Space Mono` |
| Terminal | `kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile DotOSDark.profile`, then open a new Konsole |
| GTK | `qdbus6 org.kde.GtkConfig /GtkConfig org.kde.GtkConfig.setGtkTheme DotOS-Dark` |
| libadwaita | `mkdir -p ~/.config/gtk-4.0 && ln -sf /usr/share/dot-os/gtk-4.0/dark.css ~/.config/gtk-4.0/gtk.css` |
| GRUB | Installing `dot-os-grub-theme` runs `update-grub`; reboot to see it. |
| Boot splash | Installing `dot-os-plymouth-theme` sets it and rebuilds the initramfs; reboot to see it. |
| Login screen | Installing `dot-os-sddm-theme` sets it; log out to see it. Preview without logging out: `sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/dot-os` |

The boot splash only appears with `splash` on the kernel command line. On a
machine or VM with a serial console it also needs `plymouth.ignore-serial-consoles`,
which the package adds through `/etc/default/grub.d/`.

## Checklist for every build

- [ ] Boots to the login theme.
- [ ] Logs in to Plasma with the global theme applied.
- [ ] Qt apps: buttons are pill outlines, selection inverts, no shadows.
- [ ] GTK apps pick up the GTK theme.
- [ ] A new terminal shows the DOT OS palette and a red block cursor.
- [ ] GRUB and Plymouth show correctly on a real reboot, not only the first boot.
- [ ] The installed system matches the live session.
- [ ] Red appears only as a live marker or an error.
