#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")/.."

ASSETS_DIR="assets/minecraft"
MODELS_DIR="$ASSETS_DIR/models/block"
BLOCKSTATES_DIR="$ASSETS_DIR/blockstates"

mkdir -p "$MODELS_DIR" "$BLOCKSTATES_DIR"

write_cross_model_yshift() {
  # Args: <filepath> <texture> <y_from> <y_to> <render_type>
  local path="$1"
  local texture="$2"
  local y0="$3"
  local y1="$4"
  local rtype="$5"

  cat > "$path" <<EOF
{
  "parent": "minecraft:block/cross",
  "render_type": "$rtype",
  "ambientocclusion": false,
  "textures": {
    "cross": "$texture",
    "particle": "#cross"
  },
  "elements": [
    {
      "from": [0.8, $y0, 8],
      "to": [15.2, $y1, 8],
      "rotation": { "origin": [8, 8, 8], "axis": "y", "angle": 45, "rescale": true },
      "shade": false,
      "faces": {
        "north": { "uv": [0, 0, 16, 16], "texture": "#cross" },
        "south": { "uv": [0, 0, 16, 16], "texture": "#cross" }
      }
    },
    {
      "from": [8, $y0, 0.8],
      "to": [8, $y1, 15.2],
      "rotation": { "origin": [8, 8, 8], "axis": "y", "angle": 45, "rescale": true },
      "shade": false,
      "faces": {
        "west": { "uv": [0, 0, 16, 16], "texture": "#cross" },
        "east": { "uv": [0, 0, 16, 16], "texture": "#cross" }
      }
    }
  ]
}
EOF
}

write_potted_blockstate_multipart() {
  # Args: <filepath> <plant_model_name>
  local path="$1"
  local plant_model="$2"

  cat > "$path" <<EOF
{
  "multipart": [
    { "apply": { "model": "minecraft:block/flower_pot_layer_back" } },
    { "apply": { "model": "minecraft:block/$plant_model" } },
    { "apply": { "model": "minecraft:block/flower_pot_layer_front" } }
  ]
}
EOF
}

# Empty flower pot: item texture shifted DOWN 3px => y: -3..13
write_cross_model_yshift "$MODELS_DIR/flower_pot.json" "minecraft:item/flower_pot" -3 13 "minecraft:cutout"

cat > "$BLOCKSTATES_DIR/flower_pot.json" <<'EOF'
{
  "variants": {
    "": { "model": "minecraft:block/flower_pot" }
  }
}
EOF

# Pot layers for potted variants: NOT lowered (0..16), both cutout
# You provide:
#   assets/minecraft/textures/block/flower_pot_layer_back.png
#   assets/minecraft/textures/block/flower_pot_layer_front.png
write_cross_model_yshift "$MODELS_DIR/flower_pot_layer_back.json"  "minecraft:block/flower_pot_layer_back"  0 16 "minecraft:cutout"
write_cross_model_yshift "$MODELS_DIR/flower_pot_layer_front.json" "minecraft:block/flower_pot_layer_front" 0 16 "minecraft:cutout"

# Plant layer: raised 5px => y: 5..21, ONLY this uses tripwire
while read -r pot_id plant_texture; do
  [ -z "${pot_id:-}" ] && continue
  plant_model="${pot_id}_plant"

  write_cross_model_yshift "$MODELS_DIR/${plant_model}.json" "$plant_texture" 5 21 "minecraft:tripwire"
  write_potted_blockstate_multipart "$BLOCKSTATES_DIR/${pot_id}.json" "$plant_model"
done <<'EOF'
potted_acacia_sapling minecraft:block/acacia_sapling
potted_allium minecraft:block/allium
potted_azure_bluet minecraft:block/azure_bluet
potted_bamboo minecraft:block/bamboo_stalk
potted_birch_sapling minecraft:block/birch_sapling
potted_blue_orchid minecraft:block/blue_orchid
potted_brown_mushroom minecraft:block/brown_mushroom
potted_cactus minecraft:block/cactus_side
potted_cherry_sapling minecraft:block/cherry_sapling
potted_cornflower minecraft:block/cornflower
potted_crimson_fungus minecraft:block/crimson_fungus
potted_crimson_roots minecraft:block/crimson_roots
potted_dandelion minecraft:block/dandelion
potted_dark_oak_sapling minecraft:block/dark_oak_sapling
potted_dead_bush minecraft:block/dead_bush
potted_fern minecraft:block/fern
potted_jungle_sapling minecraft:block/jungle_sapling
potted_lily_of_the_valley minecraft:block/lily_of_the_valley
potted_mangrove_propagule minecraft:block/mangrove_propagule
potted_oak_sapling minecraft:block/oak_sapling
potted_orange_tulip minecraft:block/orange_tulip
potted_oxeye_daisy minecraft:block/oxeye_daisy
potted_pink_tulip minecraft:block/pink_tulip
potted_poppy minecraft:block/poppy
potted_red_mushroom minecraft:block/red_mushroom
potted_red_tulip minecraft:block/red_tulip
potted_spruce_sapling minecraft:block/spruce_sapling
potted_torchflower minecraft:block/torchflower
potted_warped_fungus minecraft:block/warped_fungus
potted_warped_roots minecraft:block/warped_roots
potted_white_tulip minecraft:block/white_tulip
potted_wither_rose minecraft:block/wither_rose
potted_azalea_bush minecraft:block/potted_azalea_bush_plant
potted_flowering_azalea_bush minecraft:block/potted_flowering_azalea_bush_plant
EOF

echo "Done."
echo "Add:"
echo "  $ASSETS_DIR/textures/block/flower_pot_layer_back.png"
echo "  $ASSETS_DIR/textures/block/flower_pot_layer_front.png"
