#!/usr/bin/env bash
# Re-vendor the florilegium runtime files from a GitHub release.
#
#   make vendor-florilegium TAG=v2.0.1
#   ./tools/vendor-florilegium.sh v2.0.1
#
# The package is kept as a small vendored copy (florilegium.sty, its Lua
# modules and the licence) so that builds work offline, from a GitHub ZIP and
# on Overleaf, without `tlmgr install`. This script replaces that copy with the
# files of one release and writes vendor/florilegium/VERSION, so the exact
# source can always be traced without the weight of a git submodule.
set -euo pipefail

usage() {
    echo "usage: $0 <release-tag>    e.g. $0 v2.0.1" >&2
    exit 2
}

[ $# -eq 1 ] || usage
tag=$1
[ -n "$tag" ] || usage

for tool in curl unzip; do
    command -v "$tool" >/dev/null 2>&1 || { echo "$0: needs $tool" >&2; exit 1; }
done

root=$(cd "$(dirname "$0")/.." && pwd)
dest="$root/vendor/florilegium"
case "$dest" in
    "$root"/vendor/florilegium) ;;
    *) echo "$0: refusing to write outside the repository ($dest)" >&2; exit 1 ;;
esac

url="https://github.com/kevinraymond/florilegium/releases/download/${tag}/florilegium.zip"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/florilegium.XXXXXX")
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $url"
curl -fsSL --retry 3 --proto '=https' --tlsv1.2 -o "$tmp/florilegium.zip" "$url"

if command -v sha256sum >/dev/null 2>&1; then
    digest=$(sha256sum "$tmp/florilegium.zip" | awk '{print $1}')
else
    digest=$(shasum -a 256 "$tmp/florilegium.zip" | awk '{print $1}')
fi

unzip -q "$tmp/florilegium.zip" -d "$tmp/x"
src="$tmp/x/florilegium"
[ -f "$src/florilegium.sty" ] || {
    echo "$0: unexpected archive layout: florilegium/florilegium.sty is missing" >&2
    exit 1
}

# v2.0.1 -> 2.0.1; the sty's own \ProvidesPackage line must agree.
want=${tag#v}
have=$(sed -n 's/^\\ProvidesPackage{florilegium}\[[^ ]* v\([^ ]*\).*/\1/p' "$src/florilegium.sty" | head -1)
if [ -n "$have" ] && [ "$have" != "$want" ]; then
    echo "warning: $tag ships florilegium v$have, not v$want (continuing)" >&2
fi

mkdir -p "$dest"
# The directory is managed by this script: drop the previous copy, including
# modules a new release may have renamed or removed.
find "$dest" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
cp "$src/florilegium.sty" "$src"/florilegium*.lua "$src/LICENSE" "$dest/"

cat > "$dest/VERSION" <<EOF
tag:      $tag
version:  ${have:-unknown}
source:   $url
sha256:   $digest
EOF

echo "Synced into vendor/florilegium:"
ls -1 "$dest"
echo "Rebuild with: make garden"
