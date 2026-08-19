#!/bin/bash

# compile-manuscript.sh - Compile book manuscripts with multiple format support

set -e  # Exit on error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Help message
show_help() {
    cat << EOF
Usage: ./compile-manuscript.sh <book-number> [format]

Arguments:
  book-number    Number of book to compile (e.g., 01, 02)
  format         Output format: pdf, docx, epub, html (default: pdf)

Examples:
  ./compile-manuscript.sh 01           # Compile book 01 as PDF
  ./compile-manuscript.sh 01 docx      # Compile book 01 as DOCX
  ./compile-manuscript.sh 02 epub      # Compile book 02 as EPUB

EOF
}

# Parse arguments
if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ -z "$1" ]; then
    show_help
    exit 0
fi

BOOK_NUM=$1
FORMAT=${2:-pdf}

# Find the book directory
BOOK_DIR=$(find "$REPO_ROOT/books" -maxdepth 1 -type d -name "${BOOK_NUM}-*" | head -n 1)

if [ -z "$BOOK_DIR" ]; then
    echo "Error: Could not find book directory for number $BOOK_NUM"
    exit 1
fi

BOOK_NAME=$(basename "$BOOK_DIR")
MANUSCRIPT_DIR="$BOOK_DIR/manuscript"
OUTPUT_FILE="$BOOK_DIR/${BOOK_NAME}.${FORMAT}"

# Check if manuscript directory exists
if [ ! -d "$MANUSCRIPT_DIR" ]; then
    echo "Error: Manuscript directory not found: $MANUSCRIPT_DIR"
    exit 1
fi

# Count chapters
CHAPTER_COUNT=$(ls -1 "$MANUSCRIPT_DIR"/*.md 2>/dev/null | wc -l)
if [ "$CHAPTER_COUNT" -eq 0 ]; then
    echo "Error: No markdown files found in $MANUSCRIPT_DIR"
    exit 1
fi

echo -e "${BLUE}Compiling $BOOK_NAME...${NC}"
echo "  Chapters: $CHAPTER_COUNT"
echo "  Format: $FORMAT"
echo "  Output: $OUTPUT_FILE"

# Compile based on format
case $FORMAT in
    pdf)
        pandoc "$MANUSCRIPT_DIR"/*.md \
            -o "$OUTPUT_FILE" \
            --pdf-engine=xelatex \
            --toc \
            --toc-depth=1 \
            -V geometry:margin=1in \
            -V fontsize=12pt
        ;;
    docx)
        pandoc "$MANUSCRIPT_DIR"/*.md \
            -o "$OUTPUT_FILE" \
            --toc \
            --toc-depth=1
        ;;
    epub)
        pandoc "$MANUSCRIPT_DIR"/*.md \
            -o "$OUTPUT_FILE" \
            --toc \
            --toc-depth=2 \
            --epub-cover-image="$BOOK_DIR/cover.png" 2>/dev/null || \
        pandoc "$MANUSCRIPT_DIR"/*.md \
            -o "$OUTPUT_FILE" \
            --toc \
            --toc-depth=2
        ;;
    html)
        pandoc "$MANUSCRIPT_DIR"/*.md \
            -o "$OUTPUT_FILE" \
            --toc \
            --toc-depth=2 \
            --standalone \
            --self-contained
        ;;
    *)
        echo "Error: Unknown format '$FORMAT'"
        echo "Supported formats: pdf, docx, epub, html"
        exit 1
        ;;
esac

# Get word count
WORD_COUNT=$(pandoc "$MANUSCRIPT_DIR"/*.md -t plain | wc -w)

echo -e "${GREEN}✓ Compilation complete!${NC}"
echo "  Word count: ~$WORD_COUNT"
echo "  File: $OUTPUT_FILE"