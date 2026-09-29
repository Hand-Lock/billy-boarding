#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")/.."

ASSETS_DIR="assets/minecraft"
MODELS_DIR="$ASSETS_DIR/models/block"
BLOCKSTATES_DIR="$ASSETS_DIR/blockstates"

mkdir -p "$MODELS_DIR" "$BLOCKSTATES_DIR"

# write_plane <from> <to> <faces> [light]: one cross plane element, rotated
# 45°. 26.3 dropped "shade" for "shade_direction_override"; each version
# ignores the field it doesn't know (ADR 0008). light adds "light_emission".
write_plane() {
  local light=""
  [ -n "${4:-}" ] && light='
      "light_emission": '"$4"','
  cat <<EOF
    {
      "from": [$1],
      "to": [$2],
      "rotation": { "origin": [8, 8, 8], "axis": "y", "angle": 45, "rescale": true },
      "shade": false,
      "shade_direction_override": "up",$light
      "faces": {
$3
      }
    }
EOF
}

write_cross_model_yshift() {
  # Args: <filepath> <texture> <y_from> <y_to> <render_type> [tint] [depth] [emissive]
  # tint: any non-empty value adds "tintindex": 0 to every face.
  # emissive: a texture drawn as a second, identical cross at light level 15
  #   (like vanilla flower_pot_cross_emissive); depth 0 only.
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
  local emissive="${8:-}"
  local face='{ "uv": [0, 0, 16, 16], "texture": "#cross"'"$tint"' }'
  local glow='{ "uv": [0, 0, 16, 16], "texture": "#emissive" }'
  local elements textures='"cross": "'"$texture"'",'
  if [ "$d" = 0 ]; then
    elements="$(write_plane "0.8, $y0, 8" "15.2, $y1, 8" "        \"north\": $face,
        \"south\": $face"),
$(write_plane "8, $y0, 0.8" "8, $y1, 15.2" "        \"west\": $face,
        \"east\": $face")"
    if [ -n "$emissive" ]; then
      textures="$textures
    \"emissive\": \"$emissive\","
      elements="$elements,
$(write_plane "0.8, $y0, 8" "15.2, $y1, 8" "        \"north\": $glow,
        \"south\": $glow" 15),
$(write_plane "8, $y0, 0.8" "8, $y1, 15.2" "        \"west\": $glow,
        \"east\": $glow" 15)"
    fi
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
    $textures
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

# pots <dir>: reads "pot_id texture [tint|-] [emissive]" lines and writes
# each potted plant's blockstate and plant model under <dir>. The plant
# layer is raised 5px => y: 5..21, ONLY this uses tripwire. tint tints the
# plant with the vanilla block color (grass). Blocks newer than 1.20.1 go in
# the overlay of their first version (ADR 0008).
pots() {
  local dir="$1/assets/minecraft" pot_id plant_texture tint emissive
  mkdir -p "$dir/models/block" "$dir/blockstates"
  while read -r pot_id plant_texture tint emissive; do
    [ -z "${pot_id:-}" ] && continue
    [ "${tint:-}" = - ] && tint=""
    write_cross_model_yshift "$dir/models/block/${pot_id}_plant.json" "$plant_texture" 5 21 "minecraft:tripwire" "${tint:-}" 0 "${emissive:-}"
    write_potted_blockstate_multipart "$dir/blockstates/${pot_id}.json" "${pot_id}_plant"
  done
}

pots . <<'EOF'
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

pots overlay_1_21_4 <<'EOF'
potted_pale_oak_sapling minecraft:block/pale_oak_sapling
potted_closed_eyeblossom minecraft:block/closed_eyeblossom
potted_open_eyeblossom minecraft:block/open_eyeblossom - minecraft:block/open_eyeblossom_emissive
EOF

pots overlay_26_1 <<'EOF'
potted_golden_dandelion minecraft:block/golden_dandelion
EOF

pots overlay_26_3 <<'EOF'
potted_poplar_sapling minecraft:block/poplar_sapling
EOF
