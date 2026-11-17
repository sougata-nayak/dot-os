# Workflows

This folder is for the workflow files. (GitHub shows a `README.md` in the
`.github/` folder itself instead of the one at the root of the repository, so
this note lives here and not one level up.)

- `build-packages.yml`: builds every theme `.deb` under `packages/` on pushes
  and pull requests that touch `packages/`, `tools/`, `design-system/tokens.json`
  or `scripts/build-debs.sh`, and checks that the generated theme files are up
  to date.
- `build-iso.yml` (Release): on a `v*` tag, builds the packages and the
  patched Debian packages, signs the APT archive, builds the ISO and attaches
  the ISO and `SHA256SUMS` to a GitHub Release. A tag with a hyphen
  (`v0.1.0-rc1`) is published as a prerelease. If the repository variable
  `DOTOS_PUBLISH_REPO` is `true`, it also publishes the archive.
- `publish-apt.yml`: builds and signs the APT archive and publishes it to the
  `gh-pages` branch, without building an ISO. Run it from the Actions tab
  ("Run workflow") or by pushing a tag that starts with `apt-`.

See `docs/RELEASING.md` for the secrets and settings these need.
