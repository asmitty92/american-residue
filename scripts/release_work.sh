#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: scripts/release_work.sh <work-slug> <version>"
  echo "Example: scripts/release_work.sh loyalty 1.0.0"
  exit 1
fi

slug="$1"
version="$2"
tag="${slug}-v${version}"

scripts/build_work.sh "$slug"

echo "Create release tag: $tag"
echo "git tag \"$tag\""
echo "git push origin \"$tag\""
echo "Then attach artifacts from works/$slug/compiled/ to a GitHub Release."
