#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# --- Discover the latest version from the GitHub releases API ----------------
latest=$(curl -fsSL https://api.github.com/repos/DECE2183/yamusic-tui/releases/latest \
  | jq -r .tag_name | sed 's/^v//')
# ---------------------------------------------------------------------------

current=$(jq -r .version sources.json 2>/dev/null || echo none)

if [ "$latest" = "$current" ]; then
  echo "up to date: $current"; exit 0
fi

# Per-system file names for the newest version. Remove systems without builds.
declare -A files=(
  [x86_64-linux]="yamusic"
)
base="https://github.com/DECE2183/yamusic-tui/releases/download/v$latest"

json=$(jq -n --arg v "$latest" '{version: $v}')
for sys in "${!files[@]}"; do
  url="$base/${files[$sys]}"
  hash=$(nix store prefetch-file --json "$url" | jq -r .hash)
  json=$(jq --arg s "$sys" --arg u "$url" --arg h "$hash" \
    '.[$s] = {url: $u, hash: $h}' <<<"$json")
done

jq . <<<"$json" > sources.json
echo "updated: $current -> $latest"
echo "version=$latest" >> "${GITHUB_OUTPUT:-/dev/null}"
