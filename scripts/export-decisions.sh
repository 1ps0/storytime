#!/usr/bin/env bash
# export-decisions.sh — Export Storytime decision log as structured output
#
# Usage: ./export-decisions.sh [decisions-file] [format]
#
# Formats: text (default), csv
# Parses decisions.md and outputs a structured summary.

set -euo pipefail

DECISIONS_FILE="${1:-specs/.storytime/history/decisions.md}"
FORMAT="${2:-text}"

if [ ! -f "$DECISIONS_FILE" ]; then
  echo "Error: ${DECISIONS_FILE} not found"
  echo "Run bootstrap-cohort.sh first or specify the path."
  exit 1
fi

case "$FORMAT" in
  csv)
    echo "id,date,session,decision,status"
    grep -E '^## ' "$DECISIONS_FILE" | while IFS= read -r header; do
      id=$(echo "$header" | sed 's/^## //' | cut -d: -f1)
      # Read the block after this header
      block=$(awk "/^## ${id}:/,/^##[^#]/" "$DECISIONS_FILE" | head -20)
      date=$(echo "$block" | grep '^\- \*\*Date:\*\*' | sed 's/.*\*\* //')
      session=$(echo "$block" | grep '^\- \*\*Session:\*\*' | sed 's/.*\*\* //')
      decision=$(echo "$block" | grep '^\- \*\*Decision:\*\*' | sed 's/.*\*\* //' | tr ',' ';')
      status=$(echo "$block" | grep '^\- \*\*Status:\*\*' | sed 's/.*\*\* //')
      echo "${id},${date},${session},${decision},${status}"
    done
    ;;
  *)
    echo "=== Storytime Decision Log ==="
    echo ""
    grep -E '^## |^\- \*\*Decision:\*\*|^\- \*\*Status:\*\*' "$DECISIONS_FILE" | \
      while IFS= read -r line; do
        if echo "$line" | grep -q '^## '; then
          echo ""
          echo "$line" | sed 's/^## //'
        elif echo "$line" | grep -q 'Decision'; then
          echo "  $(echo "$line" | sed 's/.*\*\* //')"
        elif echo "$line" | grep -q 'Status'; then
          echo "  [$(echo "$line" | sed 's/.*\*\* //')]"
        fi
      done
    ;;
esac
