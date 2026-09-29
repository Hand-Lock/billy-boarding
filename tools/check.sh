#!/bin/sh
# Offline checks: parse every JSON file, resolve model and texture refs
# against the pack and vanilla 1.20.1, check the flower pot generator is in
# sync, scan for private data. Exits non-zero on any failure.
# Usage: tools/check.sh
set -u

cd "$(dirname "$0")/.." || exit 1
A=assets/minecraft
VANILLA=tools/vanilla-1.20.1.txt
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
fail=0
err() { printf 'FAIL %s\n' "$*"; fail=1; }

command -v jq >/dev/null || { echo "jq missing: brew install jq"; exit 1; }
[ -f "$VANILLA" ] || { echo "$VANILLA missing: run tools/vanilla.sh"; exit 1; }

# Every JSON file parses.
json=$(find . -path ./.git -prune -o -path ./dist -prune -o \
    \( -name '*.json' -o -name '*.mcmeta' \) -type f -print | sed 's|^\./||' | sort)
for f in $json; do
    jq empty "$f" 2>/dev/null || err "$f: invalid JSON"
done

[ "$(jq -r '.pack.pack_format' pack.mcmeta 2>/dev/null)" = 15 ] || err "pack.mcmeta: pack_format is not 15"

# resolve KIND REF SOURCE: KIND is models or textures. Refs without a
# namespace are minecraft:. A ref resolves to a pack file or a vanilla path.
resolve() {
    case $2 in
        builtin/*|minecraft:builtin/*) return ;;
        *:*) ns=${2%%:*}; path=${2#*:} ;;
        *) ns=minecraft; path=$2 ;;
    esac
    case $1 in models) ext=json ;; *) ext=png ;; esac
    [ "$ns" = minecraft ] || { err "$3: $1 ref $2: namespace $ns is not in this pack"; return; }
    [ -f "$A/$1/$path.$ext" ] && return
    grep -qxF "$1/$path.$ext" "$VANILLA" || err "$3: $1 ref $2 not in the pack or vanilla"
}

for f in "$A"/blockstates/*.json; do
    for m in $(jq -r '[.. | objects | .model? | strings] | unique[]' "$f" 2>/dev/null); do
        resolve models "$m" "$f"
    done
done
for f in $(find "$A/models" -name '*.json' | sort); do
    p=$(jq -r '.parent // empty' "$f" 2>/dev/null)
    [ -n "$p" ] && resolve models "$p" "$f"
    for t in $(jq -r '.textures // {} | .[] | strings | select(startswith("#") | not)' "$f" 2>/dev/null); do
        resolve textures "$t" "$f"
    done
done

# Generated flower pot files match tools/gen_flower_pots.sh.
mkdir -p "$TMP/gen/tools"
cp -R assets "$TMP/gen/"
cp tools/gen_flower_pots.sh "$TMP/gen/tools/"
if ! "$TMP/gen/tools/gen_flower_pots.sh" >/dev/null 2>&1; then
    err "tools/gen_flower_pots.sh failed"
elif ! d=$(diff -r assets "$TMP/gen/assets"); then
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
