#!/bin/sh
# intent-graph-query.sh — read-only queries over the implicit intent graph
#
# Usage:
#   ./scripts/intent-graph-query.sh <op> [args]
#
# Operations (v1.0.1):
#   get_node <id>              Return one node with all fields
#   get_children <id>          Direct children (parent: matches id)
#   get_parents <id>           Direct parents (from this node's parent: field)
#   get_path <id>              Walk up to root via parents
#   get_subtree <id>           All descendants
#   get_orphans [<topic>]      Sealed nodes with no parent
#   get_unrealized [<topic>]   Sealed but no realized_at
#   get_tensions [<topic>]     All tension pairs
#   get_supersedes <id>        What this node supersedes / what supersedes it
#   list_nodes [<topic>]       All nodes (one per line, with topic)
#
# Reads from specs/.storytime/sessions/*/_thread.md.
# Per V1-032, V1-033. Opt-in fields per references/intent-graph.md.

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"

SESSIONS="$ROOT/specs/.storytime/sessions"
[ ! -d "$SESSIONS" ] && { echo "No sessions directory."; exit 0; }

OP="${1:-help}"
shift 2>/dev/null || true

# ─── Helpers ────────────────────────────────────────────────────────

extract_decisions() {
  # Args: optional topic filter
  # Output TSV: topic \t id \t title \t status \t parent \t edge_type \t realized_at
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
        status = ""; parent = ""; edge_type = ""; realized_at = ""
        next
      }
      /^  Status: /       { status = $0; sub(/^  Status: */, "", status); next }
      /^  Parent: /       {
        parent = $0
        sub(/^  Parent: */, "", parent)
        sub(/[ ]*\(.*$/, "", parent)
        sub(/[ \t]+$/, "", parent)
        next
      }
      /^  Edge_type: /    { edge_type = $0; sub(/^  Edge_type: */, "", edge_type); next }
      /^  Realized_at: /  { realized_at = $0; sub(/^  Realized_at: */, "", realized_at); next }
      /^  Supersedes: /   {
        supersedes = $0
        sub(/^  Supersedes: */, "", supersedes)
        sub(/[ ]*\(.*$/, "", supersedes)
        next
      }
      /^  Tensions: /     { tensions = $0; sub(/^  Tensions: */, "", tensions); next }
      END { if (id) emit() }
      function emit() {
        if (status == "") status = "unknown"
        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", topic, id, title, status, parent, edge_type, realized_at
      }
    ' "$thread"
  done
}

# ─── Operations ─────────────────────────────────────────────────────

op_help() {
  sed -n '2,20p' "$0"
}

op_list_nodes() {
  local topic="${1:-}"
  printf "%-30s %-10s %-10s %s\n" "TOPIC" "ID" "STATUS" "TITLE"
  printf "%-30s %-10s %-10s %s\n" "-----" "--" "------" "-----"
  extract_decisions "$topic" | awk -F'\t' '{
    printf "%-30s %-10s %-10s %s\n", $1, $2, $4, $3
  }'
}

op_get_node() {
  local id="$1"
  [ -z "$id" ] && { echo "Usage: get_node <id>"; exit 1; }
  extract_decisions | awk -F'\t' -v id="$id" '$2==id {
    printf "ID:           %s\n", $2
    printf "Topic:        %s\n", $1
    printf "Title:        %s\n", $3
    printf "Status:       %s\n", $4
    printf "Parent:       %s\n", ($5 ? $5 : "(none)")
    printf "Edge_type:    %s\n", ($6 ? $6 : "(none)")
    printf "Realized_at:  %s\n", ($7 ? $7 : "(none)")
  }'
}

op_get_children() {
  local id="$1"
  [ -z "$id" ] && { echo "Usage: get_children <id>"; exit 1; }
  printf "Children of %s:\n" "$id"
  extract_decisions | awk -F'\t' -v id="$id" '$5 ~ id {
    printf "  %s (%s) — %s [%s]\n", $2, $1, $3, $6
  }'
}

op_get_parents() {
  local id="$1"
  [ -z "$id" ] && { echo "Usage: get_parents <id>"; exit 1; }
  parent=$(extract_decisions | awk -F'\t' -v id="$id" '$2==id {print $5}')
  if [ -z "$parent" ]; then
    echo "Node $id has no parent (or doesn't exist)."
    return 0
  fi
  printf "Parent of %s: %s\n" "$id" "$parent"
}

op_get_path() {
  local id="$1"
  [ -z "$id" ] && { echo "Usage: get_path <id>"; exit 1; }
  current="$id"
  depth=0
  printf "Path to root from %s:\n" "$id"
  while [ -n "$current" ] && [ "$depth" -lt 20 ]; do
    title=$(extract_decisions | awk -F'\t' -v id="$current" '$2==id {print $3}')
    if [ -z "$title" ]; then
      printf "  %s — (referenced as parent but not in any thread; possible IG1 violation)\n" "$current"
      break
    fi
    printf "  %s — %s\n" "$current" "$title"
    current=$(extract_decisions | awk -F'\t' -v id="$current" '$2==id {print $5}')
    depth=$((depth + 1))
  done
}

op_get_orphans() {
  local topic="${1:-}"
  printf "Orphans (sealed without parent):\n"
  extract_decisions "$topic" | awk -F'\t' '$4=="active" && $5=="" {
    printf "  %s (%s) — %s\n", $2, $1, $3
  }'
}

op_get_unrealized() {
  local topic="${1:-}"
  printf "Unrealized (sealed without realized_at):\n"
  extract_decisions "$topic" | awk -F'\t' '$4=="active" && $7=="" {
    printf "  %s (%s) — %s\n", $2, $1, $3
  }'
}

op_get_tensions() {
  local topic="${1:-}"
  printf "Tensions:\n"
  for thread in $(find "$SESSIONS" -name '_thread.md' -type f 2>/dev/null); do
    [ -n "$topic" ] && [ "$(echo "$thread" | sed -E "s|$SESSIONS/([^/]+)/.*|\1|")" != "$topic" ] && continue
    grep -B 5 'Tensions:' "$thread" 2>/dev/null | grep -E '^### |^  Tensions:' | \
      awk '/^### / { id=$2 } /^  Tensions: \[/ {
        gsub(/^  Tensions: \[|\]$/, "")
        if (length > 0) print "  " id " <-> " $0
      }'
  done
}

op_get_supersedes() {
  local id="$1"
  [ -z "$id" ] && { echo "Usage: get_supersedes <id>"; exit 1; }
  printf "Supersedes information for %s:\n" "$id"
  for thread in $(find "$SESSIONS" -name '_thread.md' -type f 2>/dev/null); do
    grep -B 3 -A 1 "^### $id —" "$thread" 2>/dev/null | grep -E '^  Supersedes:'
  done
  printf "\nThings that supersede %s:\n" "$id"
  for thread in $(find "$SESSIONS" -name '_thread.md' -type f 2>/dev/null); do
    grep -E "^  Supersedes:.*$id" "$thread" 2>/dev/null | while IFS= read -r line; do
      ctx=$(grep -B 5 "$line" "$thread" | grep -E '^### ' | tail -1)
      printf "  %s\n" "$ctx"
    done
  done
}

# ─── Dispatch ───────────────────────────────────────────────────────

case "$OP" in
  help|--help|-h) op_help ;;
  get_node)       op_get_node "$@" ;;
  get_children)   op_get_children "$@" ;;
  get_parents)    op_get_parents "$@" ;;
  get_path)       op_get_path "$@" ;;
  get_orphans)    op_get_orphans "$@" ;;
  get_unrealized) op_get_unrealized "$@" ;;
  get_tensions)   op_get_tensions "$@" ;;
  get_supersedes) op_get_supersedes "$@" ;;
  list_nodes)     op_list_nodes "$@" ;;
  *) printf "Unknown operation: %s\n\n" "$OP"; op_help; exit 1 ;;
esac
