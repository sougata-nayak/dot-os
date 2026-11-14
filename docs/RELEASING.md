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

## Cutting a release

1. Bump the version in each changed package's `debian/changelog`.
2. Commit, then tag: `git tag v0.1.0 && git push origin v0.1.0`.
3. The Release workflow builds the packages, signs the archive, builds the
   ISO and attaches the ISO and `SHA256SUMS` to a GitHub Release.

## Publishing the APT archive (off for now)

The archive is served from GitHub Pages at
`https://sougata-nayak.github.io/dot-os/apt`. To turn it on:

1. Add the `DOTOS_SIGNING_KEY` secret (above).
2. Settings → Secrets and variables → Actions → Variables: add
   `DOTOS_PUBLISH_REPO` = `true`.
3. Settings → Pages: deploy from the `gh-pages` branch, folder `/`.
4. In `packages/dot-os-archive-keyring/files/dot-os.sources`, change
   `Enabled: no` to `Enabled: yes`, bump that package's version, and release.

Until step 4, installed systems carry the entry switched off, so `apt update`
never fails on an archive that does not exist yet.
