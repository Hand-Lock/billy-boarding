# 0010. Candles out of scope

Date: 2026-10-01
Status: Accepted

Amends 0006 (candles).

## Context

ADR 0006 planned candles as layered crosses and used them as its example:
1–4 candles in 17 colors, lit or unlit. That needs 68 candle sprites and 4
flame sprites, and billboards every candle of the block around the one
block center.

Golden Days' "Flat Candles" option (Polytone) already draws one cross per
candle, for every count, color and lit state. Mode 13h's "Golden Days 2D
Candles" option billboards each of those crosses around its own center
(ID 10991, on the flora cross path). Billy Boarding's candles would
duplicate that work and look worse.

## Decision

- Billy Boarding ships no candle blockstate, block model, item model, item
  definition or texture that overrides a vanilla candle file, now or later.
  Vanilla candle files stay untouched, so Golden Days' flat
  `template_*candle*` models apply with Billy Boarding loaded above Golden
  Days.
- Candle cakes stay in scope and in 10990. Their new sprites get
  `candle_cake_*` names, clear of vanilla `block/*candle*.png`.
- Mode 13h's 10990 list never had candles; nothing changes there.

## Consequences

- ADR 0006 still applies to candle cakes, sea pickles, turtle eggs and
  campfires.
- The candle art needed shrinks to 18 sprites, for candle cakes only.
- Without Golden Days, candles stay vanilla 3D.
