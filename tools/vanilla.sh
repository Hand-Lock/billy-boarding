#!/bin/sh
# List the vanilla model and texture paths of a Minecraft version into
# tools/vanilla-<version>.txt, which tools/check.sh reads to resolve refs.
# Only file names are recorded; no Mojang assets are committed.
# Usage: tools/vanilla.sh [version]   (default: 1.20.1)
set -eu

cd "$(dirname "$0")/.."
ver=${1:-1.20.1}
out=tools/vanilla-$ver.txt
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

manifest=https://piston-meta.mojang.com/mc/game/version_manifest_v2.json
meta=$(curl -fsS "$manifest" | jq -r --arg v "$ver" '.versions[] | select(.id == $v) | .url')
[ -n "$meta" ] || { echo "vanilla: unknown version $ver" >&2; exit 1; }
curl -fsS "$meta" | jq -r '.downloads.client.url' | xargs curl -fsS -o "$TMP/client.jar"

unzip -Z1 "$TMP/client.jar" 'assets/minecraft/models/*' 'assets/minecraft/textures/*' |
    grep -E '^assets/minecraft/(models/.*\.json|textures/.*\.png)$' |
    sed 's|^assets/minecraft/||' | LC_ALL=C sort > "$out"
echo "$out: $(wc -l < "$out" | tr -d ' ') paths"
