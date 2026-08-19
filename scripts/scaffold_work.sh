#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat << EOF
Usage: ./scripts/scaffold_work.sh <snake_case_slug>

Creates a new work scaffold under works/<slug> with:
  - manuscript/
  - metadata/
  - assets/
  - revisions/
  - compiled/

Also creates:
  - works/<slug>/metadata/book.yaml
  - works/<slug>/manuscript/<slug>.md

Examples:
  ./scripts/scaffold_work.sh prairie_echoes
EOF
}

if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]] || [[ -z "${1:-}" ]]; then
  show_help
  exit 0
fi

slug="$1"

if [[ ! "$slug" =~ ^[a-z0-9_]+$ ]]; then
  echo "Error: slug must be snake_case using lowercase letters, numbers, and underscores only."
  exit 1
fi

work_dir="works/$slug"
meta_dir="$work_dir/metadata"
meta_file="$meta_dir/book.yaml"
manuscript_dir="$work_dir/manuscript"
manuscript_file="$manuscript_dir/$slug.md"

if [[ -e "$work_dir" ]]; then
  echo "Error: Work already exists at $work_dir"
  exit 1
fi

read -r -p "Title: " title
while [[ -z "$title" ]]; do
  echo "Title is required."
  read -r -p "Title: " title
done

read -r -p "Status [draft]: " status
status="${status:-draft}"

read -r -p "Type [short-story]: " work_type
work_type="${work_type:-short-story}"

mkdir -p "$manuscript_dir" "$meta_dir" "$work_dir/assets" "$work_dir/revisions" "$work_dir/compiled"

cat > "$meta_file" << EOF
slug: $slug
title: $title
status: $status
type: $work_type
source: works/$slug/manuscript/$slug.md
EOF

touch "$manuscript_file"
touch "$work_dir/compiled/.gitkeep"

echo "Scaffold created: $work_dir"
echo "Metadata: $meta_file"
echo "Manuscript: $manuscript_file"
