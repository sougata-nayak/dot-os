# DOT OS — Build Plan

Nov 12, 2026 · @Sougata Nayak

## Overview

Building DOT OS is three separable projects stacked on Debian: a reskin (theme packages, icons, boot/login art, sounds) layered onto an existing desktop environment's documented theming APIs; a live-build recipe that assembles Debian plus those packages plus the Calamares installer into a bootable, installable ISO; and an open-source repository that ships the theme source and the build recipe with CI, so a stranger can clone it and get the same ISO you do. None of this touches the kernel or Debian's own packaging — it's a *spin*, the same category as Zorin OS, Linux Mint or SpiralLinux, not a distro built from scratch. The design system already gives you the tokens, components and brand rules; what's left is translating those into real packages for a specific desktop, then wiring the result into an installable image. This plan targets Debian's arm64 port — not amd64 — running in UTM on your Mac rather than VirtualBox, since VirtualBox doesn't support arm64 guests at all.

## Desktop environment: KDE Plasma is the better fit

Nothing OS makes its whole UI from scratch — stock Android gives no theming hooks to that degree, so Nothing built a launcher, icon pack, system UI and fonts on top of it. The closest Linux equivalent for "clone this visual language wholesale" is **KDE Plasma**: its theming is layered (a Plasma look-and-feel package changes wallpaper + lock screen + splash + color scheme together, Kvantum handles widget rendering, Aurorae does window decorations, SDDM themes the login screen) and every layer ships as an independent, swappable package with a documented format. GNOME's shell theming moved to extensions years ago, and each major GNOME release has a track record of breaking them; a from-scratch look like DOT OS would mean maintaining a full GNOME Shell extension plus a GTK4/libadwaita theme against every point release — doable, but more maintenance for less control over the shell itself.

|  | KDE Plasma | GNOME | Cinnamon / XFCE |
| --- | --- | --- | --- |
| Theming depth | Full: shell, panel, dock, lock screen, splash, window decorations, widget style — all swappable | Shell behavior fixed; visuals via extensions + GTK theme, more fragile across releases | Deep but dated APIs, smaller ecosystem of examples |
| Matches the instrument-panel density of this design system | Close — widgets, panels and compositor effects are all independently stylable | Harder — GNOME's shell resists dense data displays | Possible, less tooling |
| Login/boot theming | SDDM + Plymouth, both plain config packages | GDM theming is restricted and fragile | LightDM, flexible |
| Precedent | Kubuntu, KDE Neon, Garuda, EndeavourOS KDE spin | Ubuntu, Zorin, Pop!\_OS | Linux Mint (Cinnamon), MX Linux (XFCE) |
| Recommendation | **Primary target** | Secondary target later, if wanted | Fallback for low-resource VMs, not required at launch |

Start with one desktop — KDE Plasma — and get it right end to end before considering a GNOME edition. A "DOT OS — GNOME edition" later would reuse the same tokens and most of the icon/font/sound work; only the shell-extension and GTK4 layers get rebuilt.

## Architecture: how the themed ISO actually gets built

&#91;embedded content: build pipeline · tokens to installed system, 6 steps + CI\]

Each stage is its own artifact you can rebuild without touching the others — change a theme package and only steps 2 onward need rerunning; change the live-build config and only steps 4 onward do. CI runs the whole chain from a tagged commit and publishes the ISO as a release artifact with checksums, so nobody has to build locally to get a working image.

## Theming: translating the design system into real layers

Each row is a separate, independently updatable package on KDE Plasma. The Linux-surfaces notes already saved in the design system map the exact token values; this is the packaging target for each.

| Layer | Package type | Controls | Source material |
| --- | --- | --- | --- |
| GTK4/libadwaita theme | `.deb` to `/usr/share/themes/` | Flatpaks, Firefox, GNOME apps running under Plasma | GTK override block in Linux surfaces |
| Qt/Kvantum theme | `.deb` installing a Kvantum `.svg`/`.kvconfig` set | Native KDE app widgets, buttons, inputs | Component specs (buttons, toggles, inputs, tags) |
| Plasma look-and-feel package | `plasma-lookandfeel-nilos` `.deb` | Wallpaper, lock screen, login-screen pointer, splash, default panel layout, color scheme — bundled together | Lock screen + top bar + window frame components |
| SDDM theme | `.deb` to `/usr/share/sddm/themes/` | Graphical login before any session starts | Lock-screen component |
| Plymouth theme | `.deb` to `/usr/share/plymouth/themes/` | Boot splash between GRUB and login | Boot/login spec |
| GRUB theme | `.deb` to `/boot/grub/themes/` + a `/etc/default/grub` snippet | Bootloader menu | Boot/login spec |
| Icon theme | `.deb` to `/usr/share/icons/` | App icons, tray, file manager | Monoline, 1.5px, Lucide/Phosphor Thin |
| Cursor theme | `.deb` to `/usr/share/icons/` (cursor variant) | Mouse pointer | Cursor spec in Linux surfaces |
| Fonts | `.deb` to `/usr/share/fonts/` + fontconfig priority | System-wide text rendering | Doto, Space Grotesk, Space Mono (all OFL) |
| Color scheme | `.colors` file in the look-and-feel package | Accent, text, surface colors in KDE's own dialogs | `tokens.json` color family |
| Konsole profile | `.deb` installing a `.colorscheme` | Default terminal palette | ANSI palette in Linux surfaces |

A `dot-os-desktop` meta-package (no files of its own, just `Depends:` on everything above plus `plasma-desktop`) is what live-build actually installs — adding or bumping a theme package never means touching the ISO recipe.

## Packaging: themes as .deb packages

Each theme package is a plain Debian package — "drop files at these paths, note the dependency" is nearly all a theme needs; nothing here compiles.

1. Scaffold each with `dh_make` or a hand-written `debian/` directory (control, rules, install files).
2. Build locally with `dpkg-buildpackage -us -uc`; test by `apt install ./package.deb` in a Plasma VM before it goes near the ISO.
3. Host them in an APT repository you control — `reprepro` or `aptly` over a static file tree (GitHub Pages is enough bandwidth for a hobby distro), signed with a GPG key the live-build config trusts.
4. Version with the package, not a parallel scheme — `dot-os-gtk-theme_1.2.0_all.deb`, bumped on any visual change, so `apt` handles upgrades for anyone running the installed system later.
5. The `dot-os-desktop` meta-package pins versions of every theme package plus `plasma-desktop`, `sddm`, `plymouth` and `grub-pc`/`grub-efi` as its `Depends:`. This one file is what live-build asks apt to install, and it's also what someone on an existing Debian+Plasma box could install directly to get the look without the ISO.

## Repository & open-source setup

A monorepo keeps the whole project discoverable and buildable end to end by a stranger:

```
dot-os/
├── design-system/        # this design system's exported tokens + brand book (synced, not hand-edited)
├── packages/
│   ├── gtk-theme/
│   ├── kvantum-theme/
│   ├── plasma-lookandfeel/
│   ├── sddm-theme/
│   ├── plymouth-theme/
│   ├── grub-theme/
│   ├── icon-theme/
│   ├── cursor-theme/
│   ├── fonts/
│   └── dot-os-desktop/   # meta-package
├── live-build/           # the ISO recipe: config/, package-lists/, includes.chroot/
├── installer/            # Calamares branding: slideshow, welcome text, logo
├── .github/workflows/    # CI: build packages → build ISO → checksum → release
├── docs/                 # build instructions, this plan exported
├── LICENSE
└── README.md
```

Licensing, concretely:

- **Your own code and packaging scripts:** MIT or Apache-2.0 for maximum reuse with minimal obligations back to you; GPL-3.0 if you want forks of your theme packages to stay open. Either is fine here — MIT unless you have a specific reason to copyleft.
- **Design assets** (icons you draw, the cover SVG, wallpapers): CC-BY-4.0 or the same code license, whichever you'd rather contributors credit you under.
- **Fonts:** Doto, Space Grotesk and Space Mono are all SIL Open Font License (OFL-1.1) — redistributable, including commercially, as long as the font files keep their own license text and aren't sold on their own. Bundle each `OFL.txt` in `packages/fonts/`.
- **Debian itself:** untouched by your license choice — you're adding packages on top, not relicensing Debian.

What makes this a real open-source project rather than a code dump: a `CONTRIBUTING.md` explaining the package layout and how to test one theme package in a VM without rebuilding the whole ISO; issue templates for "theme bug" vs. "ISO build failure"; a `CODE_OF_CONDUCT.md` (Contributor Covenant is the standard pick); GitHub Actions that build and lint every package on each PR, and build + publish the full ISO only on a tag.

## Testing loop in UTM

DOT OS targets Debian's arm64 port, so the test loop runs on UTM, not VirtualBox — VirtualBox has no arm64 guest support at all, while UTM (built on QEMU, with Apple's Virtualization Framework as a fast backend on Apple Silicon) is built for exactly this. If your Mac is Apple Silicon, an arm64 Debian guest runs through that native virtualization path and performs close to bare metal; on an Intel Mac, UTM falls back to QEMU's software emulation for an arm64 guest, which still works but is noticeably slower to build-test-repeat against.

- One risk worth retiring early, before any theme work: arm64 "live ISO that boots to a desktop, then hands off to a Calamares graphical installer" is a less-traveled path than the amd64 version most distro-building guides assume — Debian's own live-build/live-image tooling for arm64 has been actively worked on but isn't as mature or as widely documented as amd64's. Spend a day in Phase 1 just getting a *plain, unthemed* Debian 13 arm64 + Plasma live-build ISO to boot in UTM and reach Calamares, before building any theme packages on top of it — if that path has gaps, better to find them against vanilla Debian than against six theme packages.
- Create one UTM VM profile (UEFI boot — UTM ships its own arm64 UEFI firmware — 4GB+ RAM, a 20GB+ virtual disk) and reuse it for every test boot rather than rebuilding each time.
- Boot the live ISO first and sanity-check the live session (theme loads, SDDM/Plymouth render, no apt errors) before touching the installer — a broken theme package is much faster to catch live than after a full install.
- Run Calamares from the live session, install to the virtual disk, reboot into the installed system, and confirm it matches the live session exactly — theme packages that only partially apply (SDDM looking right live but reverting after Calamares writes its own default greeter config) are the classic failure this catches.
- Keep a short manual checklist for every build: boots to the SDDM theme → logs into Plasma with the look-and-feel applied → GTK apps pick up the GTK theme → terminal shows the DOT OS palette → GRUB/Plymouth show correctly on a real reboot, not just first boot.
- Script what you can once CI is producing ISOs regularly: UTM is scriptable through its underlying QEMU layer, so a harness that boots the ISO headless, waits for an SSH-reachable login (via a preseed/live-config autologin for test purposes only), and runs a smoke-test script catches "the ISO doesn't boot at all" before a human ever looks at it.

## Roadmap

- [ ] **Phase 0 — Confirmed.** DOT OS, KDE Plasma, Debian 13 "trixie" arm64, UTM for testing, GitHub Releases + Pages for hosting.
- [ ] **Phase 1 — Spike the arm64 boot path, then theme packages.** First: get a plain, unthemed Debian 13 arm64 + Plasma live-build ISO booting to Calamares in UTM (see Testing) — this is the one step in the whole plan with real platform-maturity risk, so retire it before investing in theming. Then build and test each theme `.deb` in a plain `debian + kde-plasma-desktop` arm64 VM: GTK/Qt theme, color scheme, icon theme, cursor theme, fonts, Konsole profile.
- [ ] **Phase 2 — Boot and login branding.** SDDM theme, Plymouth splash, GRUB theme — UTM boots UEFI by default, so this targets `grub-efi-arm64`, the same theming mechanism as amd64's `grub-efi-amd64` (simpler than the BIOS-GRUB case). Tested with real reboots, since these are the layers most likely to only half-apply.
- [ ] **Phase 3 — Plasma look-and-feel package.** Bundle wallpaper, lock screen, panel layout and color scheme into one package; usually the single package a user installs to "become" DOT OS on an existing Debian box.
- [ ] **Phase 4 — live-build recipe.** Stand up `dot-os-live`: Debian arm64 base, your APT repo as an extra source, the `dot-os-desktop` meta-package, Calamares installed and branded. First successful live boot in UTM.
- [ ] **Phase 5 — Installer branding and installed-system parity.** Calamares slideshow/branding, welcome text, and the installed-system-matches-live-session checklist from Testing.
- [ ] **Phase 6 — CI and public release.** GitHub Actions building packages → ISO → checksums on tag, published as GitHub Releases, with the APT repo served from GitHub Pages; publish the repo, write the README and CONTRIBUTING, cut a v0.1.0 release.

## Legal & branding considerations

- **Don't call it "Nothing OS" or use Nothing's logo, wordmark or red-dot branding.** Those are the company's trademarks; the design system was built as an original, Nothing-*inspired* visual language specifically so nothing in it copies Nothing's real assets — keep it that way through implementation, and pick a final project name that doesn't reference "Nothing" directly ("DOT OS" here is just a placeholder).
- **Debian's name and logo are trademarked** ([debian.org/trademark](https://www.debian.org/trademark)); Debian's own [derivatives guidelines](https://wiki.debian.org/Derivatives/Guidelines) ask derivatives not to imply official endorsement. Standard practice — used by Mint, Zorin, MX Linux, SpiralLinux — is to say "built on Debian" or "a Debian derivative" rather than naming the project as if it were an official Debian release, and not to reuse Debian's swirl logo.
- **Fonts are fine:** Doto, Space Grotesk and Space Mono are all SIL Open Font License, which explicitly permits bundling in a distro — ship each font's `OFL.txt` alongside it.
- **KDE/Plasma branding:** "KDE Plasma" is a trademark of KDE e.V.; using it to accurately describe the desktop you're shipping ("built on KDE Plasma") is normal and fine — the same don't-imply-endorsement caveat as Debian applies.
- **Calamares** is MIT-licensed and built to be white-labeled by distros — using and rebranding it is its intended use, no permission needed, just note it in a third-party-licenses file.
- **Icon set:** if you use Lucide or Phosphor icons as the design system suggests, both are permissively licensed for redistribution — recolor to the tokens and bundle the license file.

## Decisions locked in

- **Name:** DOT OS.
- **Desktop environment:** KDE Plasma.
- **Architecture:** arm64 — Debian's arm64 port, not amd64.
- **Testing:** UTM on your Mac, not VirtualBox — VirtualBox has no arm64 guest support; UTM (QEMU, with Apple's Virtualization Framework backend on Apple Silicon) is the right tool for this target.
- **Hosting:** GitHub Releases for ISO artifacts and checksums, GitHub Pages for the APT repository.
- **Debian base:** Debian 13 "trixie," current stable, not testing — tracking stability over bleeding-edge packages.

The one open item the architecture switch raises: arm64 "live ISO + Calamares" is a real but less-traveled path than amd64's — see the note at the top of Phase 1 and the Testing section above.
