#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
  cat << EOF
Usage: ./scripts/build_work.sh <snake-cased-title> [format]

Arguments:
  snake-cased-title  Work title slug (e.g., loyalty, one_cell_rural)
  format             Output format: pdf, docx, epub, html (default: pdf)

Examples:
  ./scripts/build_work.sh loyalty
  ./scripts/build_work.sh one_cell_rural docx
  ./scripts/build_work.sh quantum_leap epub
EOF
}

if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]] || [[ -z "${1:-}" ]]; then
  show_help
  exit 0
fi

input_slug="$1"
format="${2:-pdf}"

normalized_slug="${input_slug//_/-}"
if [[ -d "works/$input_slug" ]]; then
  work_slug="$input_slug"
elif [[ -d "works/$normalized_slug" ]]; then
  work_slug="$normalized_slug"
else
  echo "Error: Could not find work directory for title '$input_slug'"
  exit 1
fi

work_dir="works/$work_slug"
meta="$work_dir/metadata/book.yaml"
manuscript_dir="$work_dir/manuscript"
output_file="$work_dir/compiled/${work_slug}.${format}"
cover_file="$work_dir/assets/cover.png"
cover_stub=""

if [[ ! -f "$meta" ]]; then
  echo "Error: Missing metadata file: $meta"
  exit 1
fi

if [[ ! -d "$manuscript_dir" ]]; then
  echo "Error: Manuscript directory not found: $manuscript_dir"
  exit 1
fi

shopt -s nullglob
markdown_files=("$manuscript_dir"/*.md)
shopt -u nullglob

chapter_count="${#markdown_files[@]}"
if [[ "$chapter_count" -eq 0 ]]; then
  echo "Error: No markdown files found in $manuscript_dir"
  exit 1
fi

# Ensure deterministic ordering across macOS and Linux while avoiding bash 4-only features.
IFS=$'\n' markdown_files=($(printf '%s\n' "${markdown_files[@]}" | sort))
unset IFS

if [[ -f "$cover_file" ]]; then
  cover_stub="$(mktemp)"
  cat > "$cover_stub" << EOF
![Cover image]($cover_file)

\\newpage
EOF
  markdown_files=("$cover_stub" "${markdown_files[@]}")
fi

mkdir -p "$work_dir/compiled"

cleanup() {
  if [[ -n "$cover_stub" ]] && [[ -f "$cover_stub" ]]; then
    rm -f "$cover_stub"
  fi
}
trap cleanup EXIT

echo -e "${BLUE}Compiling ${work_slug}...${NC}"
echo "  Chapters: $chapter_count"
echo "  Format: $format"
echo "  Output: $output_file"
if [[ -f "$cover_file" ]]; then
  echo "  Cover: $cover_file"
else
  echo "  Cover: none"
fi

case "$format" in
  pdf)
    pandoc "${markdown_files[@]}" \
      -o "$output_file" \
      --pdf-engine=xelatex \
      --toc \
      --toc-depth=1 \
      -V geometry:margin=1in \
      -V fontsize=12pt
    ;;
  docx)
    pandoc "${markdown_files[@]}" \
      -o "$output_file" \
      --toc \
      --toc-depth=1
    ;;
  epub)
    if [[ -f "$cover_file" ]]; then
      pandoc "${markdown_files[@]}" \
        -o "$output_file" \
        --toc \
        --toc-depth=2 \
        --epub-cover-image="$cover_file"
    else
      pandoc "${markdown_files[@]}" \
        -o "$output_file" \
        --toc \
        --toc-depth=2
    fi
    ;;
  html)
    pandoc "${markdown_files[@]}" \
      -o "$output_file" \
      --toc \
      --toc-depth=2 \
      --standalone \
      --embed-resources
    ;;
  *)
    echo "Error: Unknown format '$format'"
    echo "Supported formats: pdf, docx, epub, html"
    exit 1
    ;;
esac

word_count="$(pandoc "${markdown_files[@]}" -t plain | wc -w | tr -d ' ')"

echo -e "${GREEN}Compilation complete.${NC}"
echo "  Word count: ~$word_count"
echo "  File: $output_file"
