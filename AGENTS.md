# Billy Boarding — agent guide

Billy Boarding is a Minecraft 1.20.1 resource pack and an add-on for the
Mode 13h shader pack (`Hand-Lock/mode-13h`). It swaps the models of cakes,
flower pots, anvils, bells, brewing stands, cactus, crops and fire for flat
cross geometry with sprite textures; Mode 13h billboards them as block ID
10990. Product direction lives in [SPEC.md](SPEC.md); decisions and their
reasons live in [docs/adr/](docs/adr/). Read both before changing models,
the look or compatibility.

## Hard constraints

- `pack.mcmeta` has `pack_format` 15 (1.20.1).
- Vanilla JSON only: blockstates, models, textures. No OptiFine CEM/CTM, no
  mod-only files.
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
  `potted_*_plant.json` are generated. Never edit them by hand: edit
  `tools/gen_flower_pots.sh`, run it, and commit both. `tools/check.sh`
  fails if they drift.
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
tools/
  check.sh                offline checks (see below)
  build.sh                dist/billy-boarding-<version>.zip from git archive
  gen_flower_pots.sh      generates the flower pot and potted-plant files
  vanilla.sh              writes vanilla-1.20.1.txt from the client jar
  vanilla-1.20.1.txt      vanilla model and texture paths, for check.sh
```

`tools/check.sh` checks that every JSON file parses, `pack_format` is 15,
every blockstate model, model parent and literal texture ref resolves to a
pack file or a vanilla path, the flower pot files match the generator, and
no private data is committed. Rerun `tools/vanilla.sh` only for a new
Minecraft version.

## Adding a billboarded block

1. **Here.** Point the blockstate at a model with parent
   `minecraft:block/cross` and a `cross` texture: the item icon if it reads
   well, else a new 16×16 sprite in `textures/block/`. For state-dependent
   parts, use a multipart of several crosses (see `brewing_stand.json`).
   Wall-mounted variants stay flat plates, not crosses.
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
`tools/release.sh` doesn't exist yet; it comes with the Modrinth project
(SPEC.md, R3). Until then, `tools/build.sh X.Y.Z` builds the zip. SemVer:
patch = fixes and art tweaks; minor = newly covered blocks or visible look
changes; major = a changed 10990 contract or dropped Minecraft version.

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
