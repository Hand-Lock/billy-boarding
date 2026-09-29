# 0003. Cross-model contract with Mode 13h

Date: 2026-09-29
Status: Accepted
Amended by 0007.

## Context

Shaders can move vertices but can't change a block's model. Mode 13h already
billboards vanilla cross plants: in `gbuffers_terrain.vsh` it keeps one face
of each cross, rotates it around its center to face the camera, and hides
the rest. Anything that should billboard has to arrive as that same geometry.

## Decision

- Billboarded blocks use vanilla `block/cross` geometry: two vertical planes
  from 0.8 to 15.2, rotated 45° around y with `rescale`, horizontal normals.
  The shader keeps the face whose normal points to (+x, +z).
- The shader finds the quad center from UVs, so faces map the full sprite
  (uv 0–16) and sprites are 16×16. Vertical offsets are allowed.
- Mode 13h lists these blocks under ID 10990, gated by `BILLY_BOARDING`
  (off by default), as its ADR 0005 reserves.
- Sprites are the vanilla item icon when one fits, new art otherwise.
- Blocks drawn partly by a block entity (the bell) get transparent entity
  textures, so only the cross model shows.
- Wall-mounted blocks (wall bells) are flat plates against the wall, not
  crosses, and are left out of 10990. A billboard hanging off a wall would
  turn through it.

## Consequences

- Without the shader, blocks are static crosses and still read correctly.
- Every block here needs a 10990 entry in Mode 13h and the other way round;
  a 10990 block without a cross model here gets its vanilla geometry
  mangled.
- Renumbering 10990 breaks both packs: a major version on each side.
