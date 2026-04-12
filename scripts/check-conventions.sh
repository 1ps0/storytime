#!/bin/sh
# check-conventions.sh — Mechanical invariant checks for storytime
#
# Usage: ./scripts/check-conventions.sh [<topic>]
#
# Exits 0 if clean, 1 if any check fails. Designed for pre-commit
# hooks, CI, and /storytime-lint delegation. All checks are grep/file
# existence — zero model reasoning.

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"

FAIL=0
WARN=0
PASS=0

check() {
  # check <name> <condition-cmd>
  if eval "$2" >/dev/null 2>&1; then
    printf "  %-48s ✓\n" "$1"
    PASS=$((PASS + 1))
  else
    printf "  %-48s ✗\n" "$1"
    FAIL=$((FAIL + 1))
  fi
}

warn() {
  # warn <name> <condition-cmd>
  if eval "$2" >/dev/null 2>&1; then
    printf "  %-48s ✓\n" "$1"
    PASS=$((PASS + 1))
  else
    printf "  %-48s ⚠\n" "$1"
    WARN=$((WARN + 1))
  fi
}

## ─── Version consistency ─────────────────────────────────────────
echo "Version consistency:"
VERSION=$(cat VERSION 2>/dev/null | tr -d '[:space:]')
if [ -z "$VERSION" ]; then
  echo "  VERSION file missing or empty                    ✗"
  FAIL=$((FAIL + 1))
else
  check "VERSION file present (v$VERSION)" "test -n \"$VERSION\""
  check "plugin.json matches VERSION" \
    "grep -q '\"version\": \"$VERSION\"' .claude-plugin/plugin.json"
  check "README.md matches VERSION" \
    "grep -q \"v$VERSION\" README.md"
  SKILL_OK=$(grep -l "storytime v$VERSION" skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
  SKILL_ALL=$(ls skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
  check "All $SKILL_ALL SKILL.md files echo v$VERSION" \
    "test \"$SKILL_OK\" = \"$SKILL_ALL\""
  SITE_STALE=$(grep -l "v0\.[0-8]\." site/*.html 2>/dev/null | grep -v "bump-version" | wc -l | tr -d ' ')
  check "site/*.html at v$VERSION" "test \"$SITE_STALE\" = \"0\""
fi

## ─── Schema version on artifacts ─────────────────────────────────
echo ""
echo "Schema version on generated artifacts:"
SESSION_ARTIFACTS=$(find specs/.storytime/sessions -name '*.md' -type f 2>/dev/null | \
  grep -vE '_thread.md$|_alumni' | head -200)

if [ -z "$SESSION_ARTIFACTS" ]; then
  echo "  (no session artifacts to check)"
else
  MISSING=0
  for f in $SESSION_ARTIFACTS; do
    if ! head -20 "$f" | grep -q '^schema_version:'; then
      MISSING=$((MISSING + 1))
    fi
  done
  TOTAL=$(echo "$SESSION_ARTIFACTS" | wc -l | tr -d ' ')
  warn "$((TOTAL - MISSING))/$TOTAL session artifacts have schema_version" \
    "test \"$MISSING\" = \"0\""
fi

## ─── Type field on all storytime artifacts ───────────────────────
echo ""
echo "Type field presence:"
TYPED_ARTIFACTS=$(find specs/.storytime -name '*.md' -type f 2>/dev/null | \
  grep -vE '_alumni|_index|MEMORY|README' | head -200)

if [ -z "$TYPED_ARTIFACTS" ]; then
  echo "  (no artifacts to check)"
else
  MISSING=0
  for f in $TYPED_ARTIFACTS; do
    if ! head -20 "$f" | grep -q '^type:'; then
      MISSING=$((MISSING + 1))
    fi
  done
  TOTAL=$(echo "$TYPED_ARTIFACTS" | wc -l | tr -d ' ')
  check "$((TOTAL - MISSING))/$TOTAL artifacts have type field" \
    "test \"$MISSING\" = \"0\""
fi

## ─── Icebreaker presence per session episode ─────────────────────
echo ""
echo "Icebreaker presence per episode:"
EPISODES=$(find specs/.storytime/sessions -mindepth 2 -maxdepth 2 -type d 2>/dev/null | \
  grep -E '/[0-9]+$' || true)

if [ -z "$EPISODES" ]; then
  echo "  (no episodes to check)"
else
  MISSING_IB=0
  for ep in $EPISODES; do
    if [ -f "$ep/team.md" ] && ls "$ep"/breakout-*.md >/dev/null 2>&1; then
      if [ ! -f "$ep/icebreaker.md" ]; then
        echo "  missing icebreaker: $ep"
        MISSING_IB=$((MISSING_IB + 1))
      fi
    fi
  done
  TOTAL_EP=$(echo "$EPISODES" | wc -l | tr -d ' ')
  check "$((TOTAL_EP - MISSING_IB))/$TOTAL_EP episodes have icebreaker.md" \
    "test \"$MISSING_IB\" = \"0\""
fi

## ─── Driver field on breakouts and buildouts ─────────────────────
echo ""
echo "Driver field on collaborative artifacts:"
BO_ARTIFACTS=$(find specs/.storytime/sessions -name 'breakout-*.md' -o -name 'buildout-*.md' 2>/dev/null)

if [ -z "$BO_ARTIFACTS" ]; then
  echo "  (no breakouts/buildouts to check)"
else
  MISSING=0
  for f in $BO_ARTIFACTS; do
    if ! head -20 "$f" | grep -q '^driver:'; then
      MISSING=$((MISSING + 1))
    fi
  done
  TOTAL=$(echo "$BO_ARTIFACTS" | wc -l | tr -d ' ')
  check "$((TOTAL - MISSING))/$TOTAL breakouts/buildouts name a driver" \
    "test \"$MISSING\" = \"0\""
fi

## ─── Thread type field ───────────────────────────────────────────
echo ""
echo "Thread artifact hygiene:"
THREADS=$(find specs/.storytime/sessions -name '_thread.md' -type f 2>/dev/null)

if [ -z "$THREADS" ]; then
  echo "  (no thread files to check)"
else
  MISSING=0
  for f in $THREADS; do
    if ! head -10 "$f" | grep -q '^type: thread'; then
      MISSING=$((MISSING + 1))
    fi
  done
  TOTAL=$(echo "$THREADS" | wc -l | tr -d ' ')
  check "$((TOTAL - MISSING))/$TOTAL _thread.md files declare type: thread" \
    "test \"$MISSING\" = \"0\""
fi

## ─── Summary ─────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────────────────────────"
echo "Summary: $PASS passed, $WARN warnings, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
