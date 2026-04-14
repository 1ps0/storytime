---
type: breakout
schema_version: 1
created: 2026-04-13T11:55
session: v1-consolidation
episode: 001
topic: v1-consolidation
subtopic: migration-path
driver: "@educator [beacon]"
supporters: ["@owner [anchor]", "@operator [tide]"]
supporters_who_spoke: ["@owner [anchor]", "@operator [tide]"]
status: complete
---

# Breakout 6 — Migration Path v0.9.x → v1.0

## Question

How do existing v0.9.x storytime repos migrate to v1.0 shapes? Specifically V1-003 (thread-as-decision-log merge), V1-008 (unified consolidation format), and the cohort rename from human names (Reva, Deshi, Oona, Pike, Taro) to non-human codenames (anchor, tide, arbor, drift, compass). Plus secondary concerns: `_thread.md` frontmatter field additions, optional archive-tier rename (hot/warm/cold → working/consolidated/archived), and `schema_version: 1` backfill on pre-v0.7.2 artifacts.

## Problem framing

**@educator [beacon]:** Migration is a teaching moment made concrete. A user with six months of storytime history cannot lose continuity the moment we ship v1.0 — that would violate the north star itself ("continuity is cheap"). But a migration that is silent, forever-dual-mode, or hand-wavey also fails teaching. We want migration to be **explicit, observable, and reversible** — the user runs a command, sees a diff, and can walk it back with git.

**@owner [anchor]:** Architecturally the hard constraint is **one reader, one writer, one format per version**. Carrying v0.9 readers indefinitely turns the codebase into an archaeology layer. Every v1.x release that still parses v0.9 formats is a release where we cannot refactor the reader. Architect's last-call: clean break with a migration artifact, not a silent adapter that never dies.

**@operator [tide]:** Migration is **reliability-critical** because it rewrites durable state. Two catastrophic failure modes: partial rewrite (inconsistent state) and destructive rewrite (overwriting source). Tide's rule (icebreaker.md:108-111): atomic writes, tmp+mv, every mechanism has a kill switch. The script needs dry-run, rollback, and a re-run-preflight verification gate.

## Migration scope

| # | Item | From (v0.9.x) | To (v1.0) | Scope per repo | T |
|---|------|---------------|-----------|----------------|---|
| A | Decision log merge | `specs/.storytime/history/decisions.md` (cross-topic stream) | Per-topic `_thread.md` `## Decisions` append-only | 1 → N threads | 13 |
| B | Thread frontmatter fields | `last_completed_phase`, `last_commit`, `episodes`, `open_questions` | + `last_consolidation{scale,event,at}`, `dreams[]`, `remembrance_staged`, `remembrance_path` | N threads | 5 |
| C | Consolidation format | Ad-hoc 5-line digests scattered per skill | One frontmatter shape per `references/consolidation-format.md` | All phase artifacts | 8 |
| D | Cohort rename | `reva`, `deshi`, `oona`, `pike`, `taro` | `anchor`, `tide`, `arbor`, `drift`, `compass` | 1 roster + 5 persona files + all `@<name>` back-refs | 8 |
| E | `schema_version: 1` backfill | Missing on pre-v0.7.2 files | Present on every storytime-owned file | All artifacts | 3 |
| F | Archive tier rename (optional) | hot / warm / cold | working / consolidated / archived | `archive/_index.md` + tier refs | 2 |
| G | `decisions.md` disposition | Live file | `archive/decisions-v09.md` (cold) via `git mv` | 1 file | 1 |
| H | Non-storytime repos | No `specs/.storytime/` | Bootstrap creates v1.0 shapes — **nothing to do** | 0 | 0 |

A dogfood repo with a few active topics touches 50–150 files. Sharp edges are A (merge) and D (rename with back-refs).

## Strategy options

**Option 1 — Silent adapter (reader polymorphism forever).** Storytime reads v0.9 + v1.0, writes v1.0 only. Pros: zero user burden. Cons: codebase carries both readers forever; violates anchor's clean-break constraint; user never *sees* migration. **Rejected** on architecture and teaching grounds.

**Option 2 — In-place auto-upgrade on first v1.0 skill invocation.** Pros: automatic. Cons: surprising writes without explicit consent; tide flags as a reliability hazard ("write I didn't ask for"); huge diff appears on a Tuesday. **Rejected** on consent and observability grounds.

**Option 3 — Opt-in script (`scripts/migrate-to-v1.sh`).** Pros: explicit, observable, reversible; the commit IS the rollback; codebase carries only v1.0 readers after the cut. Cons: user must remember to run it. **Recommended.**

**Option 4 — Hybrid (short-lived adapter + script).** Storytime 1.0 reads v0.9 for one minor version, script writes new, lint warns until migrated. Pros: ergonomic bridge. Cons: still carries v0.9 reader for a minor. **Reasonable alternative** if broad release precedes dogfood migrations; given the current user count (effectively Alex's own repos), Option 3 without the reader is cleaner.

## Recommended approach

**Option 3 + lint gate from Option 4, in three layers:**

1. **Pre-flight check** in every v1.0 skill: if `specs/.storytime/` exists and any v0.9 marker is present (`history/decisions.md` file, missing `schema_version`, human cohort names in `_roster.md`), skill halts: *"Run `./scripts/migrate-to-v1.sh` or pin `storytime@0.9` in plugin.json."* No surprise writes; refuses to proceed on un-migrated state.
2. **`scripts/migrate-to-v1.sh`** — opt-in, shell style matching `scripts/bump-version.sh` (POSIX sh, `set -e`, `git rev-parse --show-toplevel`, per-step echo, end-of-run verification). Dry-run by default; `--apply` writes; `--commit` stages a commit; `--rollback` reverts.
3. **`/storytime-lint`** gains check class **M1–M5** (migration readiness). Advisory; the pre-flight is the gate.

**On cohort rename:** deterministic archetype-based default mapping, but **user-editable** via `cohort/_migration.yaml` written on dry-run. Users who want to keep human names set `keep: true` per row — the script still backfills `schema_version` but doesn't rename files or handles.

| v0.9 name | Archetype | v1.0 default |
|-----------|-----------|--------------|
| reva | owner | anchor |
| deshi | operator | tide |
| oona | domain | arbor |
| pike | skeptic | drift |
| taro | platform | compass |

## Concrete sketch — `scripts/migrate-to-v1.sh`

Shape follows `scripts/bump-version.sh:1-72` (verified): POSIX `sh`, `set -e`, repo-root detection, numbered step echoes, `sed -i ''` (macOS form), verification pass at end. Atomic writes via tmp + `mv`.

```sh
#!/bin/sh
# migrate-to-v1.sh — migrate storytime repo from v0.9.x to v1.0
# Usage:
#   ./scripts/migrate-to-v1.sh              # dry-run (default)
#   ./scripts/migrate-to-v1.sh --apply      # write changes
#   ./scripts/migrate-to-v1.sh --apply --commit
#   ./scripts/migrate-to-v1.sh --rollback   # git revert the migration commit

set -e
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"

MODE="dryrun"; COMMIT=0; TIERS=0
for arg in "$@"; do
  case "$arg" in
    --apply)    MODE="apply" ;;
    --commit)   COMMIT=1 ;;
    --tiers)    TIERS=1 ;;
    --rollback) MODE="rollback" ;;
    *) echo "Unknown flag: $arg"; exit 1 ;;
  esac
done

STORYTIME_ROOT="$ROOT/specs/.storytime"
[ ! -d "$STORYTIME_ROOT" ] && {
  echo "No specs/.storytime/ — nothing to migrate."; exit 0; }

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
REPORT="$STORYTIME_ROOT/migration-report.md"

# Rollback path
if [ "$MODE" = "rollback" ]; then
  SHA=$(git log --grep='^storytime: migrate to v1.0$' --format=%H -n1)
  [ -z "$SHA" ] && { echo "No migration commit found."; exit 1; }
  git revert --no-edit "$SHA"; exit 0
fi

# Pre-flight
echo "Storytime v0.9.x -> v1.0 migration ($MODE)"
V09=0
[ -f "$STORYTIME_ROOT/history/decisions.md" ] && V09=$((V09+1))
grep -q '@anchor\|@tide\|@arbor\|@drift\|@compass' \
  "$STORYTIME_ROOT/cohort/_roster.md" 2>/dev/null && V09=$((V09+1))
# (missing schema_version check: scan sessions/**/*.md)
[ "$V09" -eq 0 ] && { echo "Already on v1.0."; exit 0; }

# Step A: merge decisions.md → per-topic _thread.md ## Decisions
# Step B: add thread frontmatter fields (last_consolidation, dreams,
#         remembrance_staged, remembrance_path)
# Step C: unify phase artifact frontmatter to consolidation format
# Step D: cohort rename via cohort/_migration.yaml (git mv + sed back-refs)
# Step E: schema_version: 1 backfill
# Step F: archive tier rename (only if --tiers)
# Step G: git mv history/decisions.md archive/decisions-v09.md
# (each step: write to $TMP, mv into place only if MODE=apply)

# Re-run pre-flight after apply; warn if markers remain
# Write $REPORT with git diff --name-only
# If --commit: git add -A $STORYTIME_ROOT && git commit -m "storytime: migrate to v1.0"
```

**Properties grounded in existing conventions:**
- Mirrors `scripts/bump-version.sh` style (verified against `bump-version.sh:1-72`).
- Atomic tmp+mv honors tide's rule (icebreaker.md:108-111).
- Dry-run default + user-editable `_migration.yaml` — beacon's "explicit and observable."
- Rollback via `git revert` of a single migration commit; `git mv` in steps A and G preserves history.
- Pre-flight markers reuse grep patterns understood by `scripts/check-conventions.sh`.

## Rollback

1. **Primary:** `./scripts/migrate-to-v1.sh --rollback` → `git revert` of the migration commit.
2. **Fallback:** `git checkout <pre-migration-sha> -- specs/.storytime/` (subtree restore).
3. **Safety net:** `migration-report.md` + dry-run output together reconstruct intent.

Dry-run is itself pre-rollback: users can iterate without `--apply` indefinitely.

## Non-storytime repos

No `specs/.storytime/` → script exits 0 on pre-flight line 1 with *"Nothing to migrate — `/storytime-bootstrap` creates v1.0 shapes directly on first run."* Document in README under "Upgrading from v0.9.x."

## Confidence

**Medium-high.** Mechanics are shell + sed + git-mv, identical style to existing scripts. Open risks:
- **Step A** is hardest: routing decisions.md entries to correct topics. If v0.9 didn't label by topic, needs a heuristic (grep for topic-id patterns like `V1-`, `AGC-`) or user-confirm loop.
- **Step C** depends on `references/consolidation-format.md`, which doesn't yet exist. **Sequencing gate** for the overall v1.0 plan.
- **Step D** has a long tail of cross-references (`@anchor` in buildouts, persona cross-cites). Sed covers simple cases; lint should flag residual `@<human-name>` strings after migration.

## Effort Estimate

**Complexity: 13 — at the decompose-or-split threshold** (Rule 19, SKILL.md:295; icebreaker.md:110). Aggregate bundles seven independent transformations with distinct correctness criteria. Step A alone is T=8–13; B, E are T=3; D, F are T=5; C, G are T=3–5. End-to-end script + reference + tests against a real v0.9 repo + lint class is a multi-day effort. **Per Rule 19, this decomposes:**

- **B-1:** script scaffold + pre-flight + dry-run report + rollback (steps E, G) — Complexity 5
- **B-2:** cohort rename (D) with `_migration.yaml` — Complexity 5
- **B-3:** decision-log merge (A) with topic routing — Complexity 8
- **B-4:** thread frontmatter (B) + consolidation-format rewrite (C) — Complexity 5, **gated on `consolidation-format.md` existing**
- **B-5:** `/storytime-lint` M1–M5 check class — Complexity 3

**Scale: 3 (repos × artifacts).** Touches every bootstrapped storytime repo (today: ~1–3; at dogfood: 5–10); within each, rewrites 50–150 artifacts. Not scale-1 (not a single file), not scale-5 (not cross-org). The scale dimension that matters is *artifact fan-out within a repo*: one bad sed corrupts a hundred files, so atomic tmp+mv and dry-run are non-negotiable.

## Citations

- `docs/proposals/v1-consolidation.md:372-398` — T-scale map naming V1-003, V1-008, archive-tier rename, `_thread.md` field additions
- `docs/proposals/v1-consolidation.md:437-439` — V1-003 thread-is-decision-log merge
- `docs/proposals/v1-consolidation.md:454-458` — V1-008 unified consolidation format
- `docs/proposals/v1-consolidation.md:189-229` — target `_thread.md` shape with new frontmatter
- `skills/storytime/SKILL.md:258-266` — current hot/warm/cold tier table (source for item F)
- `skills/storytime/SKILL.md:308` — Rule 32 establishing non-human codenames as default (driver of item D)
- `skills/storytime/references/artifact-types.md:14-20` — schema version history; grounds item E's "pre-v0.7.2 = version 0" rule
- `specs/.storytime/cohort/_roster.md:14-28` — current human-name roster to be rewritten
- `scripts/bump-version.sh:1-72` — style reference (set -e, git rev-parse, sed form, verification pass)
- `scripts/validate-breakouts.sh:54-113` — section-check pattern the lint M-class should emulate
- `scripts/check-conventions.sh:1-30` — sibling invariant-check script style
- `specs/.storytime/sessions/v1-consolidation/001/icebreaker.md:80-84` — beacon's original "migration is underspecified"
- `specs/.storytime/sessions/v1-consolidation/001/icebreaker.md:108-114` — constraints agreed (atomic writes, kill switches, Complexity≥13 decomposes, migration first-class)

## Open Questions (returned to CONVERGE)

1. **Decision-log topic routing (step A).** If v0.9's `decisions.md` doesn't tag by topic, we need a heuristic (regex topic-ids) or per-decision user confirm. **Sequencing:** resolve breakout 3 (callout format, @domain [arbor]) before finalizing A's logic — callouts may change whether a decision lives in one topic or is referenced from many.

2. **`references/consolidation-format.md` is a migration prerequisite.** Step C cannot run until it exists. Plan must sequence: *write consolidation-format.md → write migration script → apply migration*.

3. **Cohort rename policy confirmation.** Default mapping is opinionated; the `keep: true` escape hatch is sufficient, but confirm Rule 32's "non-human by default" stands as a framework policy during CONVERGE (some users may prefer human names).

4. **Archive tier rename (item F) — ship with v1.0 or defer to v1.1?** Anchor: ship it so vocabulary settles. Tide: smaller migration = safer migration. Flag for CONVERGE.

5. **Plugin version pin.** If a user doesn't migrate, v1.0 storytime refuses to run. Escape hatch: pin `storytime@0.9` in `.claude-plugin/plugin.json`. Needs a README sentence + defines scope of lint M5 check.

6. **Positive version marker.** Pre-flight uses negative markers (absence of v0.9 signs). Should we also write a positive `.storytime/.version` file carrying `1.0`? Hygiene question for @platform [compass] / @systems [lattice].

## Participants

- **@educator [beacon]** (driver) — framed the problem as teaching-and-observability; insisted on "explicit, observable, reversible" as governing triad; recommended opt-in-script strategy; identified consolidation-format prerequisite as a sequencing gate.
- **@owner [anchor]** (supporter) — architect's last-call: one reader / one writer / one format per version. Rejected the silent adapter. Endorsed clean-break via Option 3 + user-editable `_migration.yaml`.
- **@operator [tide]** (supporter) — reliability last-call: atomic tmp+mv, dry-run default, `--apply` as explicit flag, rollback as first-class command, re-run-preflight-after-apply as verification gate. Vetoed Option 2 (surprise writes). Pushed for Complexity-13 decomposition into B-1..B-5.
