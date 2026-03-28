#!/usr/bin/env bash
# bootstrap-cohort.sh — Initialize Storytime state in a project
#
# Usage: ./bootstrap-cohort.sh [project-root]
#
# Creates the specs/.storytime/ directory structure with an empty
# roster, decision log, and default config. Safe to run multiple
# times (won't overwrite existing files).

set -euo pipefail

PROJECT_ROOT="${1:-.}"
STORYTIME_DIR="${PROJECT_ROOT}/specs/.storytime"

echo "Bootstrapping Storytime in ${PROJECT_ROOT}..."

# Create directory structure
mkdir -p "${STORYTIME_DIR}/cohort/_alumni"
mkdir -p "${STORYTIME_DIR}/specialists"
mkdir -p "${STORYTIME_DIR}/history/sessions"

# Roster (only if not exists)
ROSTER="${STORYTIME_DIR}/cohort/_roster.md"
if [ ! -f "$ROSTER" ]; then
  cat > "$ROSTER" << 'ROSTER_EOF'
# Storytime Cohort Roster

| Name | File | Archetype | Status | Since | Sessions | Last Active |
|------|------|-----------|--------|-------|----------|-------------|
ROSTER_EOF
  echo "  Created ${ROSTER}"
else
  echo "  Roster exists, skipping"
fi

# Decision log (only if not exists)
DECISIONS="${STORYTIME_DIR}/history/decisions.md"
if [ ! -f "$DECISIONS" ]; then
  cat > "$DECISIONS" << 'DECISIONS_EOF'
# Storytime Decision Log

Append-only. Decisions can be superseded but not deleted.

---
DECISIONS_EOF
  echo "  Created ${DECISIONS}"
else
  echo "  Decision log exists, skipping"
fi

# Config (only if not exists)
CONFIG="${STORYTIME_DIR}/config.md"
if [ ! -f "$CONFIG" ]; then
  cat > "$CONFIG" << 'CONFIG_EOF'
---
default_mode: guided
automation: guided
max_team_size: 7
max_concurrent_breakouts: 3
max_deliberation_rounds: 3
require_operator: true
require_nongoals: true
visual_style: ascii
citation_format: "file:line — snippet"
auto_update_personas: true
---

# Storytime Configuration

## Automation
# manual | guided | auto
# See README.md for explanation of each level.

## Cohort Defaults
# List permanent personas loaded for every session:
# default_cohort:
#   - name-archetype-specialty
CONFIG_EOF
  echo "  Created ${CONFIG}"
else
  echo "  Config exists, skipping"
fi

echo "Done. Run '/storytime-cohort hire <name> <archetype> <background>' to add personas."
