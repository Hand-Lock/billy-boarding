# 0002. Platform: vanilla resource pack for 1.20.1

Date: 2026-09-29
Status: Accepted

## Context

Mode 13h targets 1.20.1 and 1.21.1 on Iris and Oculus, across Fabric, Forge
and NeoForge. Changing a block's geometry needs a model swap, which any
resource pack can do. OptiFine CEM/CTM and mod-specific model formats only
work for part of that audience.

## Decision

- A plain resource pack: blockstates, block and item models, textures.
- Minecraft 1.20.1 first, `pack_format` 15. 1.21.1 comes later (SPEC.md, R2).
- No OptiFine features and no mod. The Forge/NeoForge `render_type` hint is
  allowed in models, but nothing may depend on it: Fabric and vanilla ignore
  it.

## Consequences

- The pack loads everywhere, with or without Mode 13h.
- Blocks with a block entity (the bell) can't be changed by models alone;
  their entity textures are made transparent instead (ADR 0003).
- On Fabric, blocks drawn in the solid layer ignore sprite transparency
  unless the shader discards it. Unverified; listed in SPEC.md.
