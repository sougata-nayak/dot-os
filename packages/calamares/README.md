# calamares (patched)

DOT OS ships Debian's Calamares with three patches, so the installer can match
`design-system/boards/Installer.dc.html` and `Installing.dc.html`. There is no
`debian/` folder here: `scripts/build-patched.sh calamares` fetches Debian's source
package, adds `patches/` to its quilt series, versions it `+dotos1`, and
builds it. The result goes to `out/debs/` with the other packages, and
`dot-os-installer` depends on it.

| Patch | Why |
| --- | --- |
| `0001-qml-step-ready-before-connect` | A QML page that finished loading before Calamares connected to it stayed on "Loading…". Seen on the Finish page, where Restart then did nothing. |
| `0002-execution-state-for-qml` | Publishes install progress, the status message and a log toggle to QML as `Execution` (in `io.calamares.ui`), and hides the widget progress bar when the slideshow is QML. `show.qml` then draws the whole Install step and the navigation shows "Show log". |
| `0003-partition-step-greys` | The Disk step in design-system greys (system white, EFI grey, swap dark grey), a flat segmented bar, a readable legend, and no option artwork. |

Calamares is GPL-3.0-or-later; the patches are under the same licence.
Upstream: <https://codeberg.org/Calamares/calamares>.
