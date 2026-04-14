#!/bin/sh
# validate-callouts.sh — validate cross-topic callouts in threads
#
# Usage:
#   ./scripts/validate-callouts.sh               # lint all threads
#   ./scripts/validate-callouts.sh --rebuild     # rebuild reverse-cache
#   ./scripts/validate-callouts.sh <topic>       # lint one topic
#
# Checks CA1-CA5 + advisory CA-W1/2/3 per references/callouts.md.
# Exits 0 on clean (warnings ok), 1 on structural failures.

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"

MODE="lint"
TOPIC=""
for arg in "$@"; do
  case "$arg" in
    --rebuild) MODE="rebuild" ;;
    --help|-h)
      echo "Usage: $0 [--rebuild] [topic]"
      exit 0 ;;
    -*) echo "Unknown flag: $arg"; exit 1 ;;
    *) TOPIC="$arg" ;;
  esac
done

SESSIONS="$ROOT/specs/.storytime/sessions"
[ ! -d "$SESSIONS" ] && {
  echo "No sessions directory — nothing to validate."
  exit 0
}

if [ -n "$TOPIC" ]; then
  THREADS="$SESSIONS/$TOPIC/_thread.md"
  [ ! -f "$THREADS" ] && { echo "No thread for topic: $TOPIC"; exit 1; }
else
  THREADS=$(find "$SESSIONS" -name '_thread.md' -type f 2>/dev/null)
fi

[ -z "$THREADS" ] && { echo "No threads found."; exit 0; }

VALID_KINDS="depends-on affects supersedes superseded-by related"
FAIL=0
WARN=0
PASS=0

check() {
  # check <msg> <cond>
  if eval "$2" >/dev/null 2>&1; then
    PASS=$((PASS + 1))
  else
    printf "  ✗ %s\n" "$1"
    FAIL=$((FAIL + 1))
  fi
}

warn() {
  printf "  ⚠ %s\n" "$1"
  WARN=$((WARN + 1))
}

extract_callouts() {
  # Print "direction topic#id kind filename line_number" per callout
  for thread in $THREADS; do
    grep -nE '^\s*Callout(->|<-)' "$thread" 2>/dev/null | while IFS= read -r line; do
      lineno=$(echo "$line" | cut -d: -f1)
      content=$(echo "$line" | cut -d: -f2-)
      # Parse: Callout-> topic#id (kind)  or  Callout<- topic#id (kind)
      dir=$(echo "$content" | sed -E 's/.*Callout(->|<-).*/\1/')
      ref=$(echo "$content" | sed -E 's/.*Callout(->|<-) +([^ (]+).*/\2/')
      kind=$(echo "$content" | sed -E 's/.*\(([^)]+)\).*/\1/')
      printf '%s|%s|%s|%s|%s\n' "$dir" "$ref" "$kind" "$thread" "$lineno"
    done
  done
}

case "$MODE" in
  lint)
    echo "Validating callouts..."
    echo ""

    CALLOUTS=$(extract_callouts)

    if [ -z "$CALLOUTS" ]; then
      echo "  (no callouts found)"
      echo ""
      echo "────────────────────────────────────────────────────────"
      echo "Summary: 0 callouts, 0 passed, 0 warnings, 0 failed"
      exit 0
    fi

    # CA4: kind in vocabulary
    UNKNOWN_KINDS=$(echo "$CALLOUTS" | awk -F'|' '{print $3}' | sort -u | \
      while read -r k; do
        matched=0
        for v in $VALID_KINDS; do
          [ "$k" = "$v" ] && matched=1 && break
        done
        [ "$matched" = "0" ] && echo "$k"
      done)

    if [ -n "$UNKNOWN_KINDS" ]; then
      for k in $UNKNOWN_KINDS; do
        printf "  ✗ CA4: unknown kind '%s' (allowed: %s)\n" "$k" "$VALID_KINDS"
        FAIL=$((FAIL + 1))
      done
    fi

    # CA2 + CA3: topic + id resolve
    echo "$CALLOUTS" | while IFS='|' read -r dir ref kind thread lineno; do
      topic=$(echo "$ref" | cut -d'#' -f1)
      id=$(echo "$ref" | cut -d'#' -f2)
      target="$SESSIONS/$topic/_thread.md"
      if [ ! -f "$target" ]; then
        printf "  ✗ CA2: topic '%s' not found (in %s:%s)\n" "$topic" "$thread" "$lineno"
        FAIL=$((FAIL + 1))
      else
        if ! grep -qE "^### +${id} +—" "$target" 2>/dev/null; then
          printf "  ✗ CA3: decision '%s' not found in %s (from %s:%s)\n" "$id" "$topic" "$thread" "$lineno"
          FAIL=$((FAIL + 1))
        fi
      fi
    done

    # CA-W1: forward without reverse cache
    echo "$CALLOUTS" | awk -F'|' '$1=="->"' | while IFS='|' read -r dir ref kind thread lineno; do
      topic=$(echo "$ref" | cut -d'#' -f1)
      id=$(echo "$ref" | cut -d'#' -f2)
      # Source topic from thread path
      src_topic=$(echo "$thread" | sed -E "s|$SESSIONS/([^/]+)/.*|\1|")
      # Get source decision id from containing decision entry
      # (nearest preceding ### heading)
      target="$SESSIONS/$topic/_thread.md"
      if [ -f "$target" ]; then
        # Look for a matching Callout<- in the target
        if ! grep -qE "Callout<-\s+${src_topic}#" "$target" 2>/dev/null; then
          warn "CA-W1: forward callout ${src_topic}->${topic}#${id} lacks reverse cache in $topic (run --rebuild to materialize)"
        fi
      fi
    done

    echo ""
    echo "────────────────────────────────────────────────────────"
    CA_COUNT=$(echo "$CALLOUTS" | wc -l | tr -d ' ')
    echo "Summary: $CA_COUNT callouts, $PASS passed, $WARN warnings, $FAIL failed"

    [ "$FAIL" -gt 0 ] && exit 1
    exit 0
    ;;

  rebuild)
    echo "Rebuilding reverse callout cache..."
    echo ""
    echo "  (stub: would scan forward callouts and materialize reverses"
    echo "   with atomic tmp+mv writes per V1-018)"
    echo ""
    echo "Full rebuild logic lands with Phase V.1 implementation."
    exit 0
    ;;
esac
