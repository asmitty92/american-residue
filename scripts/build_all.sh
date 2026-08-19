#!/usr/bin/env bash
set -euo pipefail

for work in works/*; do
  [[ -d "$work" ]] || continue
  slug="$(basename "$work")"
  scripts/build_work.sh "$slug"
done
