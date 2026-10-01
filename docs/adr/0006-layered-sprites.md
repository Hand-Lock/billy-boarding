# 0006. Layered sprites for multi-part blocks

Date: 2026-09-29
Status: Accepted — not yet implemented
Amended by 0007, 0010.

## Context

Candles come in 17 colors, 1–4 per block, lit or unlit; candle cakes combine
a cake with any candle; sea pickles and turtle eggs come in counts; campfires
add fire when lit. One sprite per state would mean hundreds of drawings. The
brewing stand already solves the same problem for its bottles.

## Decision

- Multi-part and multi-count blocks are drawn as 16×16 sprites and composed
  in the blockstate as a multipart stack of full-size `minecraft:block/cross`
  models, one per layer, like the brewing stand bottles.
- Layers may only move vertically (ADR 0003): every layer keeps the full
  0.8–15.2 cross and full-width UVs, so the shader billboards each one around
  the same center.
- Shared overlays are their own layers: candle flames (one per candle count,
  on top of any color) and campfire fire (the animated vanilla textures).
  This keeps the sprite count to what SPEC.md's "Art needed" lists.

## Consequences

- Candle colors multiply candle sprites, not flame or cake sprites.
- Layers drawn at the same depth can z-fight if their opaque pixels overlap;
  sprites of one block are drawn so their pixels don't overlap.
- Blocks with no art yet stay vanilla and out of 10990.
