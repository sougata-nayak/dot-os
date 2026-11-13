# DOT OS

A monochrome, typographic desktop built on Debian and KDE Plasma: OLED black
or warm paper, dot-matrix display type, instrument-panel labels, and red kept
for what is live or wrong.

DOT OS is a Debian 13 "trixie" spin for arm64. It is three things in one repo:

1. **Theme packages** — plain `.deb` files that restyle Plasma, Qt and GTK apps, the terminal, icons and cursors.
2. **A live-build recipe** — assembles Debian, Plasma, the theme packages and the Calamares installer into a bootable ISO.
3. **A design system** — the tokens and component designs every package is generated from.

> Status: early. The ISO boots with the DOT OS boot menu, splash and login screen,
> installs with Calamares, and new users log in to the DOT OS desktop. Installer branding and the APT repository are next.
> See [docs/STATUS.md](docs/STATUS.md).

## Layout

```
design-system/   tokens.json, brand book, component CSS, design boards (synced, not hand-edited)
tools/           generate.py: tokens.json -> theme files under packages/
packages/        one Debian package per theme layer
live-build/      the ISO recipe
installer/       Calamares branding (not started)
scripts/         build-debs.sh, build-iso.sh, run-vm.sh
docs/            the build plan, status, testing notes
```

## Build

You need Docker. On an Apple Silicon Mac everything runs natively as arm64.

```sh
python3 tools/generate.py     # regenerate theme files after changing tokens.json
scripts/build-debs.sh         # -> out/debs/*.deb
scripts/build-iso.sh          # -> out/dot-os-arm64.hybrid.iso (30-60 min, about 6 GB of downloads)
scripts/run-vm.sh             # boot the ISO in QEMU; or open it in UTM
```

`build-iso.sh` includes whatever is in `out/debs/`, so build the packages
first if you want them in the image.

To try one package on an existing Debian 13 + Plasma machine:

```sh
sudo apt install ./out/debs/dot-os-color-schemes_0.1.0_all.deb
plasma-apply-colorscheme DotOSDark
```

[docs/TESTING.md](docs/TESTING.md) has the apply command for every package
and the UTM settings.

## Packages

| Package | Installs | State |
| --- | --- | --- |
| `dot-os-color-schemes` | KDE colour schemes, dark and light | builds |
| `dot-os-konsole-profile` | terminal palette and profile | builds |
| `fonts-dot-os` | Doto, Space Grotesk, Space Mono | builds |
| `dot-os-gtk-theme` | GTK 3 and GTK 4 themes | builds |
| `dot-os-kvantum-theme` | Qt widget theme | builds, first pass |
| `dot-os-cursor-theme` | cursors, dark and light | builds |
| `dot-os-icon-theme` | about 580 icons, dark and light | builds |
| `dot-os-grub-theme` | bootloader menu | builds, tested on live ISO and installed system |
| `dot-os-plymouth-theme` | boot splash | builds, tested on live ISO and installed system |
| `dot-os-sddm-theme` | login screen | builds, tested on installed system |
| `dot-os-plasma-lookandfeel` | global theme: bar, dock, panels, windows, wallpaper, splash, power screen, defaults | builds, tested as a new user at 1x and 2x |
| `dot-os-desktop` | meta-package | not started |

## Licence

Code is MIT. Artwork is CC BY 4.0. Fonts are OFL 1.1 and icons are ISC.
Details and third-party notices are in [LICENSES.md](LICENSES.md).

DOT OS is built on Debian and KDE Plasma and is not affiliated with or
endorsed by either project.
