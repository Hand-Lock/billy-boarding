#!/bin/sh
# Zip the committed pack into dist/billy-boarding-<version>.zip.
# Built from `git archive HEAD`, so uncommitted changes and Finder junk never
# get in.
# Usage: tools/build.sh [version]   (default: git describe)
set -eu

cd "$(dirname "$0")/.."
ver=${1:-$(git describe --tags --always)}
out=dist/billy-boarding-$ver.zip
files="pack.mcmeta pack.png assets credits.txt LICENSE"

[ -z "$(git status --porcelain -- $files)" ] ||
    echo "build: warning: uncommitted pack changes are not included" >&2

mkdir -p dist
rm -f "$out"
git archive --format=zip -o "$out" HEAD $files
echo "$out"
