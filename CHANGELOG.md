# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions: [SemVer](https://semver.org/) (see `docs/adr/0005-license-release-privacy.md`).

## [Unreleased]

### Added

- Pitcher crop: the leaves billboard over the 3D bulb (with the matching
  Mode 13h).
- Minecraft 1.21.1 support, and best-effort support up to 26.3, in the same
  zip.
- Potted pale oak sapling, closed and open eyeblossom (1.21.4+), golden
  dandelion (26.1+) and poplar sapling (26.3+) become sprites (with the
  matching Mode 13h). The open eyeblossom keeps its glow.

### Removed

- Unused brewing stand block texture (the vanilla one is back for other
  packs and mods).

### Fixed

- Colored candle cakes no longer show missing textures (they use the plain
  candle until colored art lands).
- Potted fern is green again; potted bamboo shows a bamboo sprite instead of
  a green square.
- Wall bells no longer flicker against their stem. The brown background
  around them goes away with the matching Mode 13h.
- Potted plants no longer flicker against the pot, with or without the
  shader.
- Anvils are flat in the inventory on 1.21.4+ too.
- Potted plants and the pitcher crop get no directional shading on 26.3.
