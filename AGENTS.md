# Billy Boarding — agent guide

Billy Boarding is a Minecraft 1.20.1–26.3 resource pack and an add-on for the
Mode 13h shader pack (`Hand-Lock/mode-13h`). It swaps the models of cakes,
flower pots, anvils, bells, brewing stands, cactus, crops and fire for flat
cross geometry with sprite textures; Mode 13h billboards them as block ID
10990. Product direction lives in [SPEC.md](SPEC.md); decisions and their
reasons live in [docs/adr/](docs/adr/). Read both before changing models,
the look or compatibility.

## Hard constraints

- One zip for 1.20.1 to 26.3 (ADR 0008). `pack.mcmeta` has `pack_format`
  15, and every range is written both ways: `supported_formats` /
  `formats` [min, max] and `min_format` / `max_format`. Raise `max_format`
  only for a version `tools/check.sh` covers.
- The base `assets/` is the exact 1.20.1 pack. What only newer versions
  have (`items/` definitions, newer blocks) goes in `overlay_<version>/`,
  the overlay of its first release, active up to `max_format`.
- Every `"shade": false` has `"shade_direction_override": "up"` next to it:
  26.3 only reads the second, older versions only the first.
- Vanilla JSON only: blockstates, item definitions, models, textures. No
  OptiFine CEM/CTM, no mod-only files.
- `render_type` in a model is a Forge/NeoForge extension. Fabric and vanilla
  ignore it and use the block's own render layer, so never rely on it to
  make a block look right.
- Billboarded models follow the cross contract in SPEC.md: vanilla
  `block/cross` planes, horizontal normals, full-width UVs, 16×16 sprites.
- Keep the 10990 contract in sync with `mode-13h/shaders/block.properties`:
  a block gets a cross model here and a 10990 entry there, or neither.

## Hygiene

- Suckless: the smallest change that works. No new tools, formats or
  abstractions without a reason.
- `flower_pot.json`, `flower_pot_layer_*.json`, `potted_*.json` and
  `potted_*_plant.json` are generated, in `assets/` and the overlays. Never
  edit them by hand: edit `tools/gen_flower_pots.sh`, run it, and commit
  both. `tools/check.sh` fails if they drift.
- Refs without a namespace are `minecraft:`; the pack uses `minecraft:`
  everywhere. Match it.

## File map

```
pack.mcmeta, pack.png, credits.txt    pack metadata and credits
assets/minecraft/
  blockstates/            which model each block state uses
  models/block/           cross models (and the flat wall-bell plates)
  models/item/            flat anvil item models
  textures/block/         new sprites: cake bites, candle cakes, pot layers,
                          bottles, bell legs and stems
  textures/item/          new anvil sprites
  textures/entity/bell/   transparent, to hide the bell block entity
overlay_1_21_4/assets/minecraft/
  items/                  flat anvil item definitions (1.21.4+)
  blockstates/, models/   pale oak and eyeblossom pots
overlay_26_1/…            golden dandelion pot
overlay_26_3/…            poplar sapling pot
tools/
  check.sh                offline checks (see below)
  build.sh                dist/billy-boarding-<version>+1.20.1-26.3.zip
                          from git archive
  release.sh              tags, GitHub release, Modrinth version and page
  modrinth.json           Modrinth project id, loader, game versions,
                          dependencies
  gen_flower_pots.sh      generates the flower pot and potted-plant files
  vanilla.sh              writes vanilla-<version>.txt from the client jar
  vanilla-<version>.txt   vanilla blockstate, item, model and texture
                          paths of 1.20.1, 1.21.1, 1.21.4, 26.1 and 26.3
```

`tools/check.sh` checks that every JSON file parses; pack.mcmeta's formats
and overlays are consistent and match the `overlay_*` directories; every
`"shade": false` has its 26.3 twin. Then, for each version in its table, it
builds the effective pack (base plus active overlays) and checks that every
blockstate and item model, model parent and literal texture ref resolves to
a pack file or a vanilla path, and every blockstate and item file names a
block or item of that version. It also checks the flower pot files match the
generator and no private data is committed. For a new Minecraft version, run
`tools/vanilla.sh <version>` and add it to check.sh's version table.

## Adding a billboarded block

1. **Here.** Point the blockstate at a model with parent
   `minecraft:block/cross` and a `cross` texture: the item icon if it reads
   well, else a new 16×16 sprite in `textures/block/`. For state-dependent
   parts, use a multipart of several crosses (see `brewing_stand.json`).
   Wall-mounted variants stay flat plates, not crosses. A block newer than
   1.20.1 goes in the overlay of its first release (a new
   `overlay_<version>` needs a pack.mcmeta entry and a check.sh version);
   a potted plant is one line in that overlay's `pots` call in
   `tools/gen_flower_pots.sh`.
2. **In Mode 13h.** Add the block (with state filters if only some states
   are crosses) to the `block.10990` line in `shaders/block.properties`,
   following that file's rules (no comments inside `\` continuations,
   nothing after a trailing `\`). Commit and push in the `mode-13h` repo,
   under its own task loop.
3. Update the coverage table in SPEC.md and the list in README.md.

## Task loop

For every task:

1. Implement it.
2. Run `tools/check.sh` and fix everything it reports.
3. Add a line under `## [Unreleased]` in `CHANGELOG.md` (Added / Changed /
   Fixed / Removed) if a player would notice.
4. Write an ADR in `docs/adr/` if the change decides something about
   models, the look, compatibility or distribution (see ADR 0001).
5. Commit: imperative, concise subject; body only if the why isn't obvious;
   end with the co-author trailer your harness asks for.
6. `git push`. Don't wait for confirmation.

Don't ask for screenshots or wait for an in-game check. The user tests on
their own and tells you when something is wrong.

## Visual verification

Only when the user reports a problem, or asks you to look. You can't see the
game: ask them to reload resources in-game (F3+T) and press F2, then read the
newest screenshot:

```sh
sh -c '. ./.local.env; IFS=:; for d in $MC_DIRS; do
  ls -t "$d/screenshots"/*.png | head -1; done'
```

(`sh -c` because zsh doesn't split `$MC_DIRS` on `IFS`.)

`.local.env` is gitignored and holds `MC_DIRS`, a colon-separated list of
`.minecraft` directories of the dev instances. If it is missing, ask the user
for the paths and write it.

## Release

Only when the user says **release**. Never on your own initiative.

1. Pick the SemVer bump: patch = fixes and art tweaks; minor = newly covered
   blocks or visible look changes; major = a changed 10990 contract or a
   dropped Minecraft version.
2. In `CHANGELOG.md`, rename `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD`
   and add a fresh empty `## [Unreleased]` above it. Commit and push.
3. Run `tools/release.sh X.Y.Z` (use `--dry-run` first if unsure). It checks,
   builds the zip, tags, creates the GitHub release, uploads the version to
   Modrinth (`tools/modrinth.json`), and syncs the Modrinth page from
   README.md.

README.md is the Modrinth page body: change the page by editing README.md,
never on the site. The gallery and the page metadata (summary, license,
categories, sides, links) were set once through the API (ADR 0009).

## Privacy

- The only identity in this repo is `HandLock_` with
  `54068030+Hand-Lock@users.noreply.github.com`. Check `git config user.email`
  before the first commit.
- Never commit emails, real names, local paths (`/Users/…`), or tokens.
  `tools/check.sh` greps for them.
- The Modrinth token lives in the macOS Keychain (service `modrinth-token`)
  or `$MODRINTH_TOKEN`; never write it to a file.

## References

- Mode 13h (shader side of the contract): https://github.com/Hand-Lock/mode-13h
- Block and item models: https://minecraft.wiki/w/Model
- Resource pack format: https://minecraft.wiki/w/Resource_pack
- Pack format numbers: https://minecraft.wiki/w/Pack_format
- Modrinth API v2: https://docs.modrinth.com/api/
