# .github/workflows/

- `build-packages.yml` — builds every `.deb` under `packages/` on every
  push/PR touching `packages/**`. Fast, runs on native arm64 CI.
- `build-iso.yml` — builds and publishes the full ISO, only on a `v*` tag
  push. Both the local-APT-repo-staging step and the GitHub Pages publish
  step are still TODO placeholders (they `echo` and exit 0 rather than
  silently claiming success at something not yet built) -- see
  `docs/PLAN.md` Roadmap Phase 2/3 for the order to build these in.
