# 0008. One zip for 1.20.1 to 26.3, with overlays

Date: 2026-09-29
Status: Accepted

Supersedes the version part of 0002. Amends 0005 (zip contents).

## Context

Mode 13h players are on 1.20.1 and 1.21.1, and some on newer releases.
Every blockstate, model and texture ref in the pack resolves in every
vanilla client from 1.20.1 to 26.3, and the covered blocks keep their state
keys. Only two changes break the pack:

- **1.21.4 (format 46):** item models are chosen by `items/*.json`. Vanilla
  `items/anvil.json` points at `block/anvil`, so the flat anvil item models
  are ignored.
- **26.3 (format 97.1):** model elements lost `shade`. `shade: false` is now
  written `"shade_direction_override": "up"`. Without it, pot and pitcher
  crosses get directional shading.

Newer releases also add potted plants (pale oak sapling, eyeblossoms, golden
dandelion, poplar sapling) that fit the pot layers with vanilla textures.

## Decision

- **One zip** for every version. The base `assets/` is the exact 1.20.1
  pack. `pack.mcmeta` keeps `pack_format` 15 and states the range twice,
  `supported_formats` [15, 97] and `min_format` 15 / `max_format` 97, so
  both the old and the new loaders read it (as the sibling packs do).
- **Overlays** hold what only newer versions have, one per first version,
  each active from its format to `max_format`, again written both ways:
  - `overlay_1_21_4` (46): `items/` for the flat anvils; the pale oak and
    eyeblossom pots.
  - `overlay_26_1` (84): the golden dandelion pot.
  - `overlay_26_3` (97): the poplar sapling pot.
  A block newer than 1.20.1 goes in the overlay of its first release (not
  its experimental one), so no version sees a blockstate for a block it
  lacks. Shared files (pot layers) stay in the base.
- **Dual shade fields.** Every `"shade": false` gets
  `"shade_direction_override": "up"` next to it. Each version ignores the
  field it doesn't know, like `render_type`, so no 26.3 overlay copy of the
  models is needed.
- **Emissive plants** (open eyeblossom) get a second, identical cross with
  `"light_emission": 15`, like vanilla `flower_pot_cross_emissive`. Identical
  geometry draws in element order (0007).
- `max_format` is raised only for a release that `tools/check.sh` covers:
  it builds the effective pack of each listed version and checks it against
  that version's vanilla file list, including that every blockstate and
  item file names a block or item that exists there.
- Zips are named `billy-boarding-<version>+1.20.1-26.3.zip` and include the
  `overlay_*` directories.

## Consequences

- One Modrinth file with a `game_versions` list, no per-version builds.
- 1.20.1 is tested in game; the other versions are checked offline only
  until the user tests them.
- The pale oak pot stays vanilla on 1.21.2–1.21.3, where pale oak was
  experimental.
- A new Minecraft release means: `tools/vanilla.sh <version>`, a line in
  check.sh's version table, and a new overlay or a `max_format` bump.
