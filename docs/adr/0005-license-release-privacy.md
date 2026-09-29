# 0005. License, release and privacy

Date: 2026-09-29
Status: Accepted

## Context

The pack is going public alongside Mode 13h (AGPL-3.0) and Flatter Signs.
It is mostly art, which software licenses fit badly. Textures are by
damikdevv, models by HandLock_; both agree to the license.

## Decision

- License: CC BY-SA 4.0 for the whole pack. Vanilla textures the models
  reference are not shipped.
- SemVer tags `vX.Y.Z` on `main`. Patch = fixes and art tweaks, minor =
  newly covered blocks or visible look changes, major = a changed 10990
  contract or a dropped Minecraft version.
- `CHANGELOG.md` in Keep a Changelog format. `tools/build.sh` zips from
  `git archive`. `tools/release.sh` is written with the Modrinth project.
- Releases happen only when the user says "release".
- The only committed identity is `HandLock_` with the GitHub noreply email.
  The Modrinth token lives in the macOS Keychain (`modrinth-token`) or
  `$MODRINTH_TOKEN`, never in a file. `tools/check.sh` greps for emails and
  local paths.

## Consequences

- Zips contain only `pack.mcmeta`, `pack.png`, `assets/`, `credits.txt` and
  `LICENSE`.
- Forks and modpacks may reuse the art with credit, under the same license.
