#!/usr/bin/env bash
# validate-citations.sh — Check Storytime documents for stale code citations
#
# Usage: ./validate-citations.sh [specs-dir]
#
# Scans Storytime markdown files for file:line citations and verifies
# that the referenced content still exists. Reports stale citations.

set -euo pipefail

SPECS_DIR="${1:-specs}"
STALE=0
CHECKED=0
VALID=0

echo "Validating citations in ${SPECS_DIR}/..."
echo ""

# Find all markdown files in specs/
while IFS= read -r md_file; do
  # Extract citations in the form file.go:NNN or file.go:line
  while IFS= read -r citation; do
    file=$(echo "$citation" | cut -d: -f1)
    line=$(echo "$citation" | cut -d: -f2)

    # Skip if not a number
    if ! [[ "$line" =~ ^[0-9]+$ ]]; then
      continue
    fi

    CHECKED=$((CHECKED + 1))

    if [ ! -f "$file" ]; then
      echo "  STALE: ${md_file} references ${file}:${line} — file not found"
      STALE=$((STALE + 1))
    else
      total_lines=$(wc -l < "$file")
      if [ "$line" -gt "$total_lines" ]; then
        echo "  STALE: ${md_file} references ${file}:${line} — file only has ${total_lines} lines"
        STALE=$((STALE + 1))
      else
        VALID=$((VALID + 1))
      fi
    fi
  done < <(grep -oE '[a-zA-Z0-9_/.-]+\.(go|py|ts|js|md):[0-9]+' "$md_file" 2>/dev/null || true)
done < <(find "$SPECS_DIR" -name '*.md' -type f 2>/dev/null)

echo ""
echo "Citations checked: ${CHECKED}"
echo "Valid: ${VALID}"
echo "Stale: ${STALE}"

if [ "$STALE" -gt 0 ]; then
  echo ""
  echo "Run '/storytime-retro <topic>' to update stale references."
  exit 1
fi
