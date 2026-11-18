# Releasing

## The signing key

The APT archive is signed with the key in `keys/` (created once by
`scripts/make-signing-key.sh`). `keys/` is gitignored.

- `keys/dot-os-archive.private.asc` is **secret**. Anyone holding it can push
  updates to every DOT OS machine. Keep a backup offline.
- Its public half is `packages/dot-os-archive-keyring/files/dot-os-archive-keyring.asc`,
  shipped in `dot-os-archive-keyring`.

For CI, add the private key as a repository secret:
Settings → Secrets and variables → Actions → New repository secret,
name `DOTOS_SIGNING_KEY`, value the whole contents of
`keys/dot-os-archive.private.asc`.

## Building locally

```sh
scripts/build-debs.sh      # -> out/debs/
scripts/build-repo.sh      # -> out/repo/apt/ (signed)
scripts/build-iso.sh       # -> out/dot-os-arm64.hybrid.iso
```

## Building the ISO with the archive enabled

The ISO ships the DOT OS archive as a package source. live-build ends its
chroot stage with `apt-get dist-upgrade -y`, and with the archive present apt
sees two copies of each DOT OS package (live-build's local one and the
archive's) and reports swapping them as a downgrade, which stops the build.
`live-build/config/apt/apt.conf` allows downgrades for the build only;
live-build deletes it at the end, so it is not in the shipped image. If an ISO
build ever fails with "Packages were downgraded", look there first.

## Cutting a release

1. Bump the version in each changed package's `debian/changelog`.
2. Commit, then tag: `git tag v0.1.1 && git push origin v0.1.1`.
3. The Release workflow builds the packages, signs the archive, builds the
   ISO and attaches the ISO and `SHA256SUMS` to a GitHub Release.

## Publishing the APT archive

The archive is served from GitHub Pages at
`https://sougata-nayak.github.io/dot-os/apt`.

1. Add the `DOTOS_SIGNING_KEY` secret (above).
2. Publish it: Actions → "Publish APT archive" → Run workflow, or push a tag
   such as `git tag apt-0.1.0 && git push origin apt-0.1.0`. This builds the
   packages, signs the archive and pushes it to the `gh-pages` branch (about
   40 minutes). To have every release publish it too, add the repository
   variable `DOTOS_PUBLISH_REPO` = `true` (Settings → Secrets and variables →
   Actions → Variables).
3. Settings → Pages: deploy from the `gh-pages` branch, folder `/` (the branch
   exists after step 2).
4. The archive entry is on by default (`Enabled: yes` in
   `packages/dot-os-archive-keyring/files/dot-os.sources`), and
   `files/dot-os.pref` pins it above Debian (priority 990), so the DOT OS
   builds of Dolphin, System Settings, KIO and Calamares always win.

Run "Publish APT archive" again whenever packages change, and after Debian
updates one of the four patched packages once they have been rebuilt.
Tag `apt-<version>` to do it from the command line.
