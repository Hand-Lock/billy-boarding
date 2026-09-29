#!/bin/sh
# Offline checks: parse every JSON file; check pack.mcmeta and its overlays;
# for each Minecraft version, build the effective pack (base plus the
# overlays active at its format) and resolve its model, texture and item refs
# against it and tools/vanilla-<version>.txt, and check every blockstate and
# item file names a block or item of that version; check "shade" has its
# 26.3 twin; check the flower pot generator is in sync; scan for private
# data. Exits non-zero on any failure.
# Usage: tools/check.sh
set -u

cd "$(dirname "$0")/.." || exit 1
# version:resource pack format. 26.3 is 97.1; overlay ranges use whole numbers.
VERSIONS="1.20.1:15 1.21.1:34 1.21.4:46 26.1:84 26.3:97"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
fail=0
err() { printf 'FAIL %s\n' "$*"; fail=1; }

command -v jq >/dev/null || { echo "jq missing: brew install jq"; exit 1; }
for vf in $VERSIONS; do
    [ -f "tools/vanilla-${vf%:*}.txt" ] || { echo "tools/vanilla-${vf%:*}.txt missing: run tools/vanilla.sh ${vf%:*}"; exit 1; }
done

# Every JSON file parses.
json=$(find . -path ./.git -prune -o -path ./dist -prune -o \
    \( -name '*.json' -o -name '*.mcmeta' \) -type f -print | sed 's|^\./||' | sort)
for f in $json; do
    jq empty "$f" 2>/dev/null || err "$f: invalid JSON"
done

# pack.mcmeta: pack_format 15, each range written both ways, overlay
# directories on disk match the list.
jq -e '.pack.pack_format == 15' pack.mcmeta >/dev/null 2>&1 || err "pack.mcmeta: pack_format is not 15"
jq -e '.pack | .supported_formats == [.min_format, .max_format]' pack.mcmeta >/dev/null 2>&1 ||
    err "pack.mcmeta: supported_formats does not match min_format/max_format"
for d in $(jq -r '.overlays.entries[]? | select(.formats != [.min_format, .max_format]) | .directory' pack.mcmeta 2>/dev/null); do
    err "pack.mcmeta: overlay $d: formats does not match min_format/max_format"
done
listed=$(jq -r '.overlays.entries[]?.directory' pack.mcmeta 2>/dev/null | sort)
ondisk=$(find . -maxdepth 1 -name 'overlay_*' -type d | sed 's|^\./||' | sort)
[ "$listed" = "$ondisk" ] || err "pack.mcmeta: overlays listed ($(echo $listed)) differ from those on disk ($(echo $ondisk))"

# 26.3 ignores "shade": false; every one needs "shade_direction_override".
for f in $(find assets overlay_* -path '*/models/*.json' 2>/dev/null | sort); do
    jq -e '[.. | objects | select(.shade == false and (has("shade_direction_override") | not))] | length == 0' "$f" >/dev/null 2>&1 ||
        err "$f: \"shade\": false without \"shade_direction_override\""
done

# resolve KIND REF SOURCE: KIND is models or textures. Refs without a
# namespace are minecraft:. A ref resolves to a file of the effective pack
# $A or a path in $VANILLA.
resolve() {
    case $2 in
        builtin/*|minecraft:builtin/*) return ;;
        *:*) ns=${2%%:*}; path=${2#*:} ;;
        *) ns=minecraft; path=$2 ;;
    esac
    case $1 in models) ext=json ;; *) ext=png ;; esac
    [ "$ns" = minecraft ] || { err "$v: $3: $1 ref $2: namespace $ns is not in this pack"; return; }
    [ -f "$A/$1/$path.$ext" ] && return
    grep -qxF "$1/$path.$ext" "$VANILLA" || err "$v: $3: $1 ref $2 not in the pack or vanilla"
}

for vf in $VERSIONS; do
    v=${vf%:*} fmt=${vf#*:}
    VANILLA=tools/vanilla-$v.txt
    jq -e --argjson f "$fmt" '.pack.min_format <= $f and $f <= .pack.max_format' pack.mcmeta >/dev/null 2>&1 ||
        err "pack.mcmeta: $v (format $fmt) is outside min_format/max_format"
    P=$TMP/pack-$v A=$P/assets/minecraft
    mkdir -p "$P"
    cp -R assets "$P/"
    for o in $(jq -r --argjson f "$fmt" '.overlays.entries[]? | select(.min_format <= $f and $f <= .max_format) | .directory' pack.mcmeta 2>/dev/null); do
        [ -d "$o/assets" ] && cp -R "$o/assets" "$P/"
    done

    for f in $(cd "$A" && find blockstates items -name '*.json' 2>/dev/null | sort); do
        grep -qxF "$f" "$VANILLA" || err "$v: $f: no such block or item in $v"
    done
    for f in $(cd "$A" && find blockstates -name '*.json' 2>/dev/null | sort); do
        for m in $(jq -r '[.. | objects | .model? | strings] | unique[]' "$A/$f" 2>/dev/null); do
            resolve models "$m" "$f"
        done
    done
    for f in $(cd "$A" && find items -name '*.json' 2>/dev/null | sort); do
        for m in $(jq -r '[.. | objects | select(.type == "minecraft:model" or .type == "model") | .model | strings] | unique[]' "$A/$f" 2>/dev/null); do
            resolve models "$m" "$f"
        done
    done
    for f in $(cd "$A" && find models -name '*.json' | sort); do
        p=$(jq -r '.parent // empty' "$A/$f" 2>/dev/null)
        [ -n "$p" ] && resolve models "$p" "$f"
        for t in $(jq -r '.textures // {} | .[] | strings | select(startswith("#") | not)' "$A/$f" 2>/dev/null); do
            resolve textures "$t" "$f"
        done
    done
done

# Generated flower pot files match tools/gen_flower_pots.sh.
mkdir -p "$TMP/orig" "$TMP/gen/tools"
cp -R assets overlay_* "$TMP/orig/" 2>/dev/null
cp -R "$TMP/orig/." "$TMP/gen/"
cp tools/gen_flower_pots.sh "$TMP/gen/tools/"
if ! "$TMP/gen/tools/gen_flower_pots.sh" >/dev/null 2>&1; then
    err "tools/gen_flower_pots.sh failed"
elif ! d=$(cd "$TMP" && diff -r -x tools orig gen); then
    err "flower pot files differ from tools/gen_flower_pots.sh output (run it):"
    printf '%s\n' "$d" | grep -E '^(diff|Only)' | sed 's/^/    /'
fi

# Private data: emails other than GitHub noreply, local home paths.
priv=$(git ls-files -co --exclude-standard | grep -v '^tools/check\.sh$' | while IFS= read -r f; do
    [ -f "$f" ] || continue
    grep -HnoIE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|/Users/[A-Za-z0-9._-]+|/home/[a-z][A-Za-z0-9._-]*' "$f"
done | grep -vE ':[0-9]+:([^:]*@users\.noreply\.github\.com|noreply@anthropic\.com)$')
[ -n "$priv" ] && { err "private data:"; printf '%s\n' "$priv" | sed 's/^/    /'; }

[ "$fail" = 0 ] && echo "check: ok"
exit "$fail"
