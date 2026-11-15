# systemsettings (patched)

DOT OS ships Debian's System Settings with one patch, so it can match
`design-system/boards/Settings.dc.html`. There is no `debian/` folder here:
`scripts/build-patched.sh systemsettings` fetches Debian's source package (`source`),
adds `patches/` to its quilt series, versions it `+dotos$(cat rev)`, builds
it, and keeps the binary packages named in `debs`. The result goes to
`out/debs/` with the other packages, and `dot-os-desktop` depends on it.

What the patch changes is described in its header and in `docs/STATUS.md`.

System Settings is GPL-2.0-or-later; the patch is under the same licence.
Upstream: <https://invent.kde.org/plasma/systemsettings>.
