# 0009. Modrinth release

Date: 2026-09-29
Status: Accepted

Amends 0005 (release).

## Context

The Modrinth project `billy-boarding` (`bTh8rCOa`) exists, and Mode 13h
2.1.2, the matching shader side, is out. Mode 13h already releases with one
command, `tools/release.sh`, and keeps its Modrinth page in README.md.

## Decision

- `tools/release.sh X.Y.Z` does the whole release, as Mode 13h's does:
  checks (main, clean, pushed, tag free, a `## [X.Y.Z]` changelog section),
  `tools/check.sh`, `tools/build.sh`, tag `vX.Y.Z`, GitHub release with the
  zip, Modrinth version, and the Modrinth page body from README.md.
  `--dry-run` prints every payload and sends nothing.
- `tools/modrinth.json` holds what the version upload needs: loader
  `minecraft` (a resource pack), `game_versions` 1.20.1 to 26.3 (every
  release the one zip supports, per 0008; 1.20 is left out), and Mode 13h
  as an **optional** dependency, because the pack works without it.
- README.md is the page body. The page is edited in the repo, never on the
  site.
- The gallery and the page metadata (summary, license CC-BY-SA-4.0,
  categories, client required / server unsupported, source and issues
  links) are set once by hand through the API, not by release.sh. They
  rarely change, and screenshots don't belong in the repo.

## Consequences

- A release is: changelog section, commit, push, `tools/release.sh X.Y.Z`.
- The Modrinth changelog is the CHANGELOG.md section, reformatted.
- New gallery shots or metadata changes are one-off API calls.
