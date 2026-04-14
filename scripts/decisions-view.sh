#!/bin/sh
# decisions-view.sh — on-demand view of decisions across all topic threads
#
# Usage:
#   ./scripts/decisions-view.sh                       # all active decisions
#   ./scripts/decisions-view.sh --status=active       # filter by status
#   ./scripts/decisions-view.sh --since=2026-04-01    # filter by date
#   ./scripts/decisions-view.sh --topic=<topic>       # one topic
#   ./scripts/decisions-view.sh --format=csv          # text (default) | csv
#
# V1-022: no pre-built global index; this script synthesizes on demand.
# Replaces scripts/export-decisions.sh; maintains CSV compatibility.

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"

STATUS_FILTER=""
SINCE_FILTER=""
TOPIC_FILTER=""
FORMAT="text"

for arg in "$@"; do
  case "$arg" in
    --status=*) STATUS_FILTER=$(echo "$arg" | cut -d= -f2) ;;
    --since=*)  SINCE_FILTER=$(echo "$arg" | cut -d= -f2) ;;
    --topic=*)  TOPIC_FILTER=$(echo "$arg" | cut -d= -f2) ;;
    --format=*) FORMAT=$(echo "$arg" | cut -d= -f2) ;;
    --help|-h)
      sed -n '2,10p' "$0"
      exit 0 ;;
    *) echo "Unknown flag: $arg"; exit 1 ;;
  esac
done

SESSIONS="$ROOT/specs/.storytime/sessions"
[ ! -d "$SESSIONS" ] && { echo "No sessions directory."; exit 0; }

if [ -n "$TOPIC_FILTER" ]; then
  THREADS="$SESSIONS/$TOPIC_FILTER/_thread.md"
  [ ! -f "$THREADS" ] && { echo "No thread for topic: $TOPIC_FILTER"; exit 1; }
else
  THREADS=$(find "$SESSIONS" -name '_thread.md' -type f 2>/dev/null)
fi

[ -z "$THREADS" ] && { echo "No threads found."; exit 0; }

# Extract decisions: ID, title, at, commit, drivers, status, topic
# Format per thread:
#   ### V1-NNN — Title
#     At: YYYY-MM-DD
#     Commit: sha
#     Drivers: ...
#     Status: active|superseded|...
#     ...

extract_decisions() {
  for thread in $THREADS; do
    topic=$(echo "$thread" | sed -E "s|$SESSIONS/([^/]+)/.*|\1|")

    # Use LC_ALL=C + byte-mode awk to handle UTF-8 em-dashes safely.
    # Decision header pattern: "### V1-NNN — Title" (em-dash is 3 bytes in UTF-8).
    LC_ALL=C awk -v topic="$topic" '
      /^### +[A-Z][A-Z0-9-]+ +/ {
        if (id) emit()
        sub(/^### +/, "")
        # Split on " — " (treat as bytes; em-dash is e2 80 94)
        line = $0
        # Find the em-dash byte sequence and split there; fall back to " - "
        split_at = index(line, " \xe2\x80\x94 ")
        if (split_at == 0) split_at = index(line, " - ")
        if (split_at == 0) { id = line; title = "" }
        else {
          id = substr(line, 1, split_at - 1)
          title = substr(line, split_at + 5)  # length of " — " in bytes
        }
        gsub(/[ \t]+$/, "", id)
        gsub(/[ \t]+$/, "", title)
        at = ""; commit = ""; drivers = ""; status = ""
        next
      }
      /^  At: /       { at = $0; sub(/^  At: */, "", at); next }
      /^  Commit: /   { commit = $0; sub(/^  Commit: */, "", commit); next }
      /^  Drivers: /  { drivers = $0; sub(/^  Drivers: */, "", drivers); next }
      /^  Status: /   { status = $0; sub(/^  Status: */, "", status); next }
      END { if (id) emit() }
      function emit() {
        if (status == "") status = "unknown"
        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", topic, id, title, at, commit, drivers, status
      }
    ' "$thread"
  done
}

DECISIONS=$(extract_decisions)

# Filters
if [ -n "$STATUS_FILTER" ]; then
  DECISIONS=$(echo "$DECISIONS" | awk -F'\t' -v s="$STATUS_FILTER" '$7==s')
fi
if [ -n "$SINCE_FILTER" ]; then
  DECISIONS=$(echo "$DECISIONS" | awk -F'\t' -v since="$SINCE_FILTER" '$4>=since')
fi

[ -z "$DECISIONS" ] && { echo "(no matching decisions)"; exit 0; }

case "$FORMAT" in
  csv)
    echo "topic,id,title,at,commit,drivers,status"
    echo "$DECISIONS" | awk -F'\t' '{
      gsub(/"/, "\"\"")
      printf "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n", $1, $2, $3, $4, $5, $6, $7
    }'
    ;;
  text|*)
    printf "%-24s %-12s %-10s %-8s %-10s %s\n" "TOPIC" "ID" "AT" "COMMIT" "STATUS" "TITLE"
    printf "%-24s %-12s %-10s %-8s %-10s %s\n" "-----" "--" "--" "------" "------" "-----"
    echo "$DECISIONS" | awk -F'\t' '{
      commit_short = substr($5, 1, 7)
      printf "%-24s %-12s %-10s %-8s %-10s %s\n", $1, $2, $4, commit_short, $7, $3
    }'
    ;;
esac
