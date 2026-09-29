# 0004. Generated flower pots

Date: 2026-09-29
Status: Accepted

## Context

1.20.1 has 34 potted plants plus the empty pot. Each needs a blockstate and
a plant model that differ only in the plant texture. Writing them by hand
invites drift.

## Decision

- Each potted plant is a three-layer multipart of cross models: pot back,
  plant, pot front, so the plant sits inside the pot from every angle.
- The plant layer is raised 5px (y 5–21) to stand out of the pot. The empty
  pot is the vanilla `item/flower_pot` icon lowered 3px (y −3–13) to sit on
  the ground.
- The plant layer uses render type `minecraft:tripwire`; the pot layers use
  `minecraft:cutout`. Keep this until tested otherwise in game.
- `tools/gen_flower_pots.sh` is the source of truth for all these files. It
  is never bypassed with hand edits, and `tools/check.sh` fails if its output
  and the committed files differ.

## Consequences

- A new potted plant is one line in the script.
- The pot layers are plain `minecraft:block/cross` children; only the empty
  pot and the plant layer need explicit elements for their vertical offset.
- Plant layers are untinted unless the script's third column asks for
  `"tintindex": 0`. Only the potted fern does, because vanilla tints it with
  the grass color.
