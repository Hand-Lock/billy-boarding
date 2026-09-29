# 0007. Flat faces and layer depth in 10990 models

Date: 2026-09-29
Status: Accepted

Amends 0003 (wall bells, faces) and 0006 (layers at the same depth).

## Context

The 1.20.1 Fabric + Iris test round showed two problems with the contract:

- Wall bells are brown rectangles. Fabric ignores `render_type`, so bells
  are in the solid layer, where nothing discards transparent pixels. Mode
  13h only discards them for 10990, and wall bells are not in 10990 because
  the shader would billboard their plates through the wall.
- Potted plants z-fight, with and without the shader. The back layer, plant
  and front layer are the same cross planes at the same depth, and the
  shader recenters and turns every layer the same way, so they stay
  coplanar there too.

The pitcher crop wants both: a 3D bulb box that must stay put and leaf
planes that should billboard.

## Decision

- **Flat faces.** In a 10990 model, only faces whose normal is horizontal
  and diagonal are billboarded: the shader keeps the (+x, +z) one and culls
  the other three, as before. Faces with axis-aligned or vertical normals
  are drawn as they are, and still get the 10990 alpha discard. Wall bell
  plates and the pitcher bulb are such faces, so every bell state and the
  pitcher crop join 10990.
- **Layer depth.** A cross face pushed `d` pixels along its own normal is
  drawn in front of the depth 0 cross (behind, for negative `d`), from every
  side. Shaders off, each face is only seen from its own side (backface
  culling), so the order holds from all four sides. Shader on, Mode 13h
  measures the kept face's offset from the block center along its normal,
  reads it in 0.05 px steps as an integer depth rank, recenters the quad,
  and moves it toward the camera along the view ray by its rank: depth
  changes, screen position doesn't. So `d` must be a whole multiple of
  0.05; other values are rounded to the nearest one.
- Pot layers use `d` = −0.05 (back) and +0.05 (front); the plant stays at 0.
  Kept small so the layers show no parallax with shaders off.
  `tools/gen_flower_pots.sh` writes one element per face when `d` ≠ 0.
- Wall bell plates are 1px thick (7.5–8.5) so the bell sits 0.25px in front
  of its stem plate from both sides.

## Consequences

- Compatible both ways: an old Mode 13h with this pack shows sub-pixel
  shifts; a new Mode 13h with an old pack changes nothing. A minor version,
  not major.
- Layered blocks (ADR 0006) can overlap their sprites freely, as long as
  each layer gets its own depth.
- Overlapping layers with identical geometry (the same cross planes and y
  range) can share a depth: they draw in multipart order, like vanilla
  overlays (brewing stand bottles). Overlapping layers with different
  geometry (pots, later candles raised onto cakes) each need their own depth.
- Mode 13h's 10990 list gets `minecraft:bell` (all states) and
  `minecraft:pitcher_crop`.
- Blocks drawn through the entity path (falling anvils) don't go through
  `gbuffers_terrain`. Mode 13h billboards them in the entity path (its ADR
  0015), around their own center and without layer depth.
