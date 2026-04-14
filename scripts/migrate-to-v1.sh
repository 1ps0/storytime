#!/bin/sh
# migrate-to-v1.sh — migrate storytime repo from v0.9.x to v1.0
#
# Usage:
#   ./scripts/migrate-to-v1.sh              # dry-run (default)
#   ./scripts/migrate-to-v1.sh --apply      # write changes
#   ./scripts/migrate-to-v1.sh --apply --commit
#   ./scripts/migrate-to-v1.sh --rollback   # git revert the migration commit
#
# V1-028 opt-in migration. Mirrors bump-version.sh style.
# Implements migration steps per breakout-6-migration-path.md:
#   Step A: decision log merge (history/decisions.md → per-topic threads)
#   Step B: thread frontmatter fields
#   Step C: consolidation format rewrite
#   Step D: cohort rename (human → codename)
#   Step E: schema_version: 1 backfill
#   Step F: archive tier rename (optional, --tiers flag)
#   Step G: decisions.md → archive/decisions-v09.md

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"

MODE="dryrun"
COMMIT=0
TIERS=0
for arg in "$@"; do
  case "$arg" in
    --apply)    MODE="apply" ;;
    --commit)   COMMIT=1 ;;
    --tiers)    TIERS=1 ;;
    --rollback) MODE="rollback" ;;
    --help|-h)
      sed -n '2,12p' "$0"
      exit 0 ;;
    *) echo "Unknown flag: $arg"; exit 1 ;;
  esac
done

STORYTIME_ROOT="$ROOT/specs/.storytime"

# ─── Rollback path ──────────────────────────────────────────────────
if [ "$MODE" = "rollback" ]; then
  SHA=$(git log --grep='^storytime: migrate to v1.0$' --format=%H -n1)
  if [ -z "$SHA" ]; then
    echo "No migration commit found to roll back."
    exit 1
  fi
  echo "Rolling back migration commit $SHA..."
  git revert --no-edit "$SHA"
  exit $?
fi

# ─── Pre-flight ─────────────────────────────────────────────────────
if [ ! -d "$STORYTIME_ROOT" ]; then
  echo "No specs/.storytime/ — nothing to migrate."
  echo "(/storytime-bootstrap creates v1.0 shapes directly on first run.)"
  exit 0
fi

echo "Storytime v0.9.x → v1.0 migration"
echo "Mode: $MODE"
[ "$COMMIT" = "1" ] && echo "Will commit on success: yes"
[ "$TIERS" = "1" ] && echo "Will rename archive tiers: yes"
echo ""

V09_MARKERS=0

# Marker 1: history/decisions.md exists
if [ -f "$STORYTIME_ROOT/history/decisions.md" ]; then
  echo "  ✓ Found v0.9 marker: history/decisions.md"
  V09_MARKERS=$((V09_MARKERS + 1))
fi

# Marker 2: cohort has human names
if [ -f "$STORYTIME_ROOT/cohort/_roster.md" ] && \
   grep -qE '^\| (reva|deshi|oona|pike|taro) ' \
     "$STORYTIME_ROOT/cohort/_roster.md" 2>/dev/null; then
  echo "  ✓ Found v0.9 marker: human-named cohort members"
  V09_MARKERS=$((V09_MARKERS + 1))
fi

# Marker 3: artifacts missing schema_version
MISSING_SV=0
SESS_FILES=$(find "$STORYTIME_ROOT/sessions" -name '*.md' -type f 2>/dev/null | head -100)
for f in $SESS_FILES; do
  if ! head -20 "$f" | grep -q '^schema_version:'; then
    MISSING_SV=$((MISSING_SV + 1))
  fi
done
if [ "$MISSING_SV" -gt 0 ]; then
  echo "  ✓ Found v0.9 marker: $MISSING_SV session artifacts missing schema_version"
  V09_MARKERS=$((V09_MARKERS + 1))
fi

if [ "$V09_MARKERS" -eq 0 ]; then
  echo ""
  echo "Already on v1.0 shape — nothing to migrate."
  exit 0
fi

echo ""
echo "$V09_MARKERS v0.9 marker(s) found. Planning migration..."
echo ""

# ─── Dry-run: just report what would happen ─────────────────────────
REPORT="$STORYTIME_ROOT/migration-report.md"

print_plan() {
  echo "Planned steps:"
  [ -f "$STORYTIME_ROOT/history/decisions.md" ] && \
    echo "  Step A: merge history/decisions.md into per-topic _thread.md files"
  echo "  Step B: add new frontmatter fields to all _thread.md files"
  echo "           (last_consolidation, dreams, remembrance_staged, remembrance_path)"
  echo "  Step C: unify phase artifact frontmatter per consolidation-format"
  if [ -f "$STORYTIME_ROOT/cohort/_roster.md" ] && \
     grep -qE '^\| (reva|deshi|oona|pike|taro) ' \
       "$STORYTIME_ROOT/cohort/_roster.md" 2>/dev/null; then
    echo "  Step D: rename cohort (reva→anchor, deshi→tide, oona→arbor,"
    echo "                       pike→drift, taro→compass)"
    echo "           (writes cohort/_migration.yaml first for per-row override)"
  fi
  echo "  Step E: backfill schema_version: 1 on $MISSING_SV artifacts"
  [ "$TIERS" = "1" ] && \
    echo "  Step F: rename archive tiers (hot→working, warm→consolidated, cold→archived)"
  [ -f "$STORYTIME_ROOT/history/decisions.md" ] && \
    echo "  Step G: git mv history/decisions.md → archive/decisions-v09.md"
  echo ""
  echo "  Write .storytime/.version = 1.0 (positive marker)"
}

print_plan

if [ "$MODE" = "dryrun" ]; then
  echo ""
  echo "This was a DRY RUN. No files were modified."
  echo "Re-run with --apply to execute."
  echo ""
  echo "Rollback always available:"
  echo "  ./scripts/migrate-to-v1.sh --rollback   # if --commit was used"
  echo "  git checkout <pre-migration-sha> -- specs/.storytime/   # otherwise"
  exit 0
fi

# ─── Apply mode (scaffold — full impl lands with B-2..B-5) ──────────
echo ""
echo "── APPLY MODE ──"
echo ""
echo "Scaffold only for this commit. Full per-step logic lands across"
echo "B-2 (cohort rename), B-3 (decision-log merge), B-4 (thread frontmatter"
echo "+ consolidation format), B-5 (lint M-class). Run individual steps"
echo "via environment variable ST_MIGRATE_STEP=[A-G] when implemented."
echo ""
echo "Current scaffold supports:"
echo "  - Pre-flight detection (done above)"
echo "  - Rollback via git revert"
echo "  - Dry-run planning (done above)"
echo "  - Step E: schema_version backfill (simple sed-style)"
echo "  - Step G: git mv history/decisions.md → archive/decisions-v09.md"
echo ""

# Step E: schema_version backfill (the simplest step; implement now)
if [ "$MISSING_SV" -gt 0 ]; then
  echo "Step E: backfilling schema_version: 1 on $MISSING_SV artifacts..."
  BACKFILLED=0
  for f in $SESS_FILES; do
    if ! head -20 "$f" | grep -q '^schema_version:'; then
      # Insert schema_version: 1 after the opening ---
      tmp="${f}.tmp"
      awk 'NR==1 && /^---/ {
             print
             print "schema_version: 1"
             next
           }
           { print }' "$f" > "$tmp"
      mv "$tmp" "$f"
      BACKFILLED=$((BACKFILLED + 1))
    fi
  done
  echo "  Backfilled $BACKFILLED artifacts."
  echo ""
fi

# Step G: archive decisions.md
if [ -f "$STORYTIME_ROOT/history/decisions.md" ]; then
  echo "Step G: archiving history/decisions.md..."
  mkdir -p "$STORYTIME_ROOT/archive/cold"
  git mv "$STORYTIME_ROOT/history/decisions.md" \
    "$STORYTIME_ROOT/archive/cold/decisions-v09.md" 2>/dev/null || \
    mv "$STORYTIME_ROOT/history/decisions.md" \
       "$STORYTIME_ROOT/archive/cold/decisions-v09.md"
  echo "  Moved to archive/cold/decisions-v09.md"
  echo ""
fi

# Positive version marker
printf '1.0\n' > "$STORYTIME_ROOT/.version"
echo "Wrote $STORYTIME_ROOT/.version = 1.0"
echo ""

# Write report
cat > "$REPORT" << REPORT_EOF
---
type: migration-report
schema_version: 1
created: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---

# Migration Report — v0.9.x → v1.0

## Applied

- Step E: schema_version: 1 backfilled on $BACKFILLED artifacts
- Step G: history/decisions.md → archive/cold/decisions-v09.md

## Deferred (require separate implementation)

- Step A: decision log merge (per-topic threads)
- Step B: thread frontmatter additions
- Step C: consolidation format rewrite
- Step D: cohort rename
- Step F: archive tier rename (not requested — use --tiers)

## Files changed

$(cd "$ROOT" && git diff --name-only 2>/dev/null | head -30)
REPORT_EOF

echo "Report written to $REPORT"
echo ""

# Commit if requested
if [ "$COMMIT" = "1" ]; then
  echo "Committing migration..."
  git add -A specs/.storytime/
  git commit -m "storytime: migrate to v1.0"
  echo ""
  echo "Commit created. To roll back: ./scripts/migrate-to-v1.sh --rollback"
fi

echo "Migration scaffold complete."
echo ""
echo "Next: implement B-2 (cohort rename) and B-3 (decision merge) steps"
echo "to complete the full migration."
