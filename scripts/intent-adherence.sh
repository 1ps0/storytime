#!/bin/sh
# intent-adherence.sh — render sealed-vs-realized grid for storytime decisions
#
# Usage:
#   ./scripts/intent-adherence.sh                 # all topics
#   ./scripts/intent-adherence.sh <topic>         # one topic
#   ./scripts/intent-adherence.sh --csv [topic]   # CSV output
#
# Per V1-034. Reads decisions from _thread.md and classifies each as:
#   ✓  realized   — has realized_at, OR commit messages mention the ID
#   ◐  partial    — referenced in code/docs but not all lifecycle markers met
#   ·  pending    — sealed but no evidence of realization
#   ✗  superseded — explicitly retired

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"

SESSIONS="$ROOT/specs/.storytime/sessions"
[ ! -d "$SESSIONS" ] && { echo "No sessions directory."; exit 0; }

FORMAT="text"
TOPIC=""
for arg in "$@"; do
  case "$arg" in
    --csv) FORMAT="csv" ;;
    --help|-h) sed -n '2,11p' "$0"; exit 0 ;;
    *) TOPIC="$arg" ;;
  esac
done

extract_decisions() {
  local topic_filter="${1:-}"
  for thread in $(find "$SESSIONS" -name '_thread.md' -type f 2>/dev/null); do
    topic=$(echo "$thread" | sed -E "s|$SESSIONS/([^/]+)/.*|\1|")
    [ -n "$topic_filter" ] && [ "$topic" != "$topic_filter" ] && continue

    LC_ALL=C awk -v topic="$topic" '
      /^### +[A-Z][A-Z0-9.-]+ +/ {
        if (id) emit()
        sub(/^### +/, "")
        line = $0
        split_at = index(line, " \xe2\x80\x94 ")
        if (split_at == 0) split_at = index(line, " - ")
        if (split_at == 0) { id = line; title = "" }
        else {
          id = substr(line, 1, split_at - 1)
          title = substr(line, split_at + 5)
        }
        gsub(/[ \t]+$/, "", id)
        gsub(/[ \t]+$/, "", title)
        status = ""; realized_at = ""
        next
      }
      /^  Status: /      { status = $0; sub(/^  Status: */, "", status); next }
      /^  Realized_at: / { realized_at = $0; sub(/^  Realized_at: */, "", realized_at); next }
      END { if (id) emit() }
      function emit() {
        if (status == "") status = "unknown"
        printf "%s\t%s\t%s\t%s\t%s\n", topic, id, title, status, realized_at
      }
    ' "$thread"
  done
}

classify() {
  local id="$1"
  local status="$2"
  local realized_at="$3"

  # Superseded → ✗
  if [ "$status" = "superseded" ] || [ "$status" = "retired" ]; then
    echo "✗"
    return
  fi

  # Has realized_at → ✓
  if [ -n "$realized_at" ]; then
    echo "✓"
    return
  fi

  # Mentioned in commit messages → ✓ (heuristic)
  commit_count=$(git log --grep="$id" --format=%h 2>/dev/null | wc -l | tr -d ' ')
  if [ "$commit_count" -ge 1 ]; then
    # Check for substantive code references
    code_refs=$(git grep -l "$id" -- ':!specs/' 2>/dev/null | wc -l | tr -d ' ')
    doc_refs=$(git grep -l "$id" -- 'specs/' 2>/dev/null | wc -l | tr -d ' ')

    if [ "$code_refs" -ge 1 ] && [ "$commit_count" -ge 2 ]; then
      echo "✓"
    elif [ "$code_refs" -ge 1 ] || [ "$doc_refs" -ge 2 ]; then
      echo "◐"
    else
      echo "·"
    fi
    return
  fi

  # No evidence → ·
  echo "·"
}

# ─── Render ────────────────────────────────────────────────────────

DECISIONS=$(extract_decisions "$TOPIC")

if [ -z "$DECISIONS" ]; then
  echo "(no decisions found)"
  exit 0
fi

case "$FORMAT" in
  csv)
    echo "topic,id,title,status,classification,realized_at"
    echo "$DECISIONS" | while IFS=$'\t' read -r topic id title status realized_at; do
      cls=$(classify "$id" "$status" "$realized_at")
      printf '"%s","%s","%s","%s","%s","%s"\n' "$topic" "$id" "$title" "$status" "$cls" "$realized_at"
    done
    ;;
  text|*)
    [ -n "$TOPIC" ] && echo "Adherence — $TOPIC" || echo "Adherence — all topics"
    echo ""
    printf "%-3s  %-10s  %-30s  %s\n" "MARK" "ID" "TOPIC" "TITLE"
    printf "%-3s  %-10s  %-30s  %s\n" "----" "--" "-----" "-----"

    realized=0
    partial=0
    pending=0
    superseded=0
    total=0

    echo "$DECISIONS" | while IFS=$'\t' read -r topic id title status realized_at; do
      cls=$(classify "$id" "$status" "$realized_at")
      printf "%-3s  %-10s  %-30s  %s\n" "$cls" "$id" "$topic" "$title"
    done

    counts=$(echo "$DECISIONS" | while IFS=$'\t' read -r topic id title status realized_at; do
      classify "$id" "$status" "$realized_at"
    done | sort | uniq -c)

    echo ""
    echo "────────────────────────────────────────────────────────────────"
    echo "Legend:  ✓ realized   ◐ partial   · pending   ✗ superseded"
    echo ""
    echo "$counts" | while IFS= read -r line; do
      n=$(echo "$line" | awk '{print $1}')
      m=$(echo "$line" | awk '{print $2}')
      case "$m" in
        ✓) echo "  Realized:   $n" ;;
        ◐) echo "  Partial:    $n" ;;
        ·) echo "  Pending:    $n" ;;
        ✗) echo "  Superseded: $n" ;;
      esac
    done
    ;;
esac
