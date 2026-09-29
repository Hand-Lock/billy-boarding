#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")/.."

ASSETS_DIR="assets/minecraft"
MODELS_DIR="$ASSETS_DIR/models/block"
BLOCKSTATES_DIR="$ASSETS_DIR/blockstates"

mkdir -p "$MODELS_DIR" "$BLOCKSTATES_DIR"

# write_plane <from> <to> <faces>: one cross plane element, rotated 45°.
write_plane() {
  cat <<EOF
    {
      "from": [$1],
      "to": [$2],
      "rotation": { "origin": [8, 8, 8], "axis": "y", "angle": 45, "rescale": true },
      "shade": false,
      "faces": {
$3
      }
    }
EOF
}

write_cross_model_yshift() {
  # Args: <filepath> <texture> <y_from> <y_to> <render_type> [tint] [depth]
  # tint: any non-empty value adds "tintindex": 0 to every face.
  # depth: pushes every face that many pixels along its own normal, so it
  #   draws in front of (or, negative, behind) a depth 0 cross from every
  #   side (ADR 0007). Each face then gets its own element.
  local path="$1"
  local texture="$2"
  local y0="$3"
  local y1="$4"
  local rtype="$5"
  local tint=""
  [ -n "${6:-}" ] && tint=', "tintindex": 0'
  local d="${7:-0}"
  local face='{ "uv": [0, 0, 16, 16], "texture": "#cross"'"$tint"' }'
  local elements
  if [ "$d" = 0 ]; then
    elements="$(write_plane "0.8, $y0, 8" "15.2, $y1, 8" "        \"north\": $face,
        \"south\": $face"),
$(write_plane "8, $y0, 0.8" "8, $y1, 15.2" "        \"west\": $face,
        \"east\": $face")"
  else
    local lo hi
    lo=$(awk "BEGIN { print 8 - ($d) }")
    hi=$(awk "BEGIN { print 8 + ($d) }")
    elements="$(write_plane "0.8, $y0, $lo" "15.2, $y1, $lo" "        \"north\": $face"),
$(write_plane "0.8, $y0, $hi" "15.2, $y1, $hi" "        \"south\": $face"),
$(write_plane "$lo, $y0, 0.8" "$lo, $y1, 15.2" "        \"west\": $face"),
$(write_plane "$hi, $y0, 0.8" "$hi, $y1, 15.2" "        \"east\": $face")"
  fi

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
$elements
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

# Pot layers for potted variants: crosses (0..16), cutout, pushed 0.05px
# behind and in front of the plant so they don't z-fight with it.
write_cross_model_yshift "$MODELS_DIR/flower_pot_layer_back.json" "minecraft:block/flower_pot_layer_back" 0 16 "minecraft:cutout" "" -0.05
write_cross_model_yshift "$MODELS_DIR/flower_pot_layer_front.json" "minecraft:block/flower_pot_layer_front" 0 16 "minecraft:cutout" "" 0.05

# Plant layer: raised 5px => y: 5..21, ONLY this uses tripwire
# A third column tints the plant with the vanilla block color (grass).
while read -r pot_id plant_texture tint; do
  [ -z "${pot_id:-}" ] && continue
  plant_model="${pot_id}_plant"

  write_cross_model_yshift "$MODELS_DIR/${plant_model}.json" "$plant_texture" 5 21 "minecraft:tripwire" "$tint"
  write_potted_blockstate_multipart "$BLOCKSTATES_DIR/${pot_id}.json" "$plant_model"
done <<'EOF'
potted_acacia_sapling minecraft:block/acacia_sapling
potted_allium minecraft:block/allium
potted_azure_bluet minecraft:block/azure_bluet
potted_bamboo minecraft:item/bamboo
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
potted_fern minecraft:block/fern tint
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

