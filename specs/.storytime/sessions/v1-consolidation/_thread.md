---
type: thread
schema_version: 1
topic: v1-consolidation
created: 2026-04-13T11:00
last_consolidation:
  scale: session
  event: DONE
  at: 2026-04-14T09:00
last_completed_phase: DONE
last_commit: c2df6c107026ee6b5d58a3729c09abb402a3102d
remembrance_staged: false
remembrance_path: null
open_questions: []
---

# Thread — v1-consolidation

## Episodes

- 001 (DONE, 2026-04-14) — full cold-start spec on the v1.0 consolidation
  proposal. 6 breakouts, 17 new decisions sealed, 28-item implementation
  plan approved by user ("make it so"). Moving to buildout.

## Decisions (append-only, pinned to commit)

_Seal commit pending — this thread records them at approval time; the
sealing commit is the one that captures the plan._

### V1-014 — Commit learning: edit-distance, 7 samples / 6-of-7 clean
  At: 2026-04-13
  Drivers: @platform [compass]
  Supersedes: —
  Status: active

### V1-015 — Quieter commit mode is shorter prompt, not skipped
  At: 2026-04-13
  Drivers: @platform [compass]
  Status: active

### V1-016 — Six pause signals
  At: 2026-04-13
  Drivers: @operator [tide]
  Status: active
  (repetition, confusion, rut, framing-loss, context-delta, token-budget)

### V1-017 — Pause tier mapping by combination logic
  At: 2026-04-13
  Drivers: @operator [tide]
  Status: active
  (nap=1 signal; shift=2+ or persistent or framing-loss alone; compact=token-budget or unresolved shift)

### V1-018 — Atomic tmp+fsync+mv for remembrance writes
  At: 2026-04-13
  Drivers: @operator [tide]
  Status: active

### V1-019 — Callout syntax: Callout-> / Callout<- sigil lines
  At: 2026-04-13
  Drivers: @domain [arbor]
  Status: active

### V1-020 — Forward callouts authoritative, reverse is lint-cached
  At: 2026-04-13
  Drivers: @domain [arbor]
  Status: active

### V1-021 — Closed 5-kind callout vocabulary (MVP)
  At: 2026-04-13
  Drivers: @domain [arbor]
  Status: active
  (depends-on, affects, supersedes, superseded-by, related)

### V1-022 — On-demand decisions view, no pre-built global index
  At: 2026-04-13
  Drivers: @domain [arbor]
  Status: active

### V1-023 — Delete history/decisions.md in V1-003 migration
  At: 2026-04-13
  Drivers: @domain [arbor]
  Status: active

### V1-024 — Friction calibration hybrid (proposal + visible progress)
  At: 2026-04-13
  Drivers: @platform [compass]
  Status: active

### V1-025 — Tutorial graduation per-skill, not global
  At: 2026-04-13
  Drivers: @platform [compass]
  Status: active

### V1-026 — Retain signals → tutorial-plus (not demotion)
  At: 2026-04-13
  Drivers: @platform [compass], @educator [beacon]
  Status: active

### V1-027 — Initial friction thresholds ship as dogfood-tunable guesses
  At: 2026-04-13
  Drivers: @platform [compass]
  Status: active

### V1-028 — Opt-in migration script (dry-run default, apply/commit/rollback)
  At: 2026-04-13
  Drivers: @educator [beacon]
  Status: active

### V1-029 — v1.0 skills pre-flight-gate on unmigrated state
  At: 2026-04-13
  Drivers: @educator [beacon], @operator [tide]
  Status: active

### V1-030 — Cohort rename default mapping + per-row _migration.yaml override
  At: 2026-04-13
  Drivers: @educator [beacon]
  Status: active

## Cohort state

- **Rehired (session codename → cohort file):**
  - @owner [anchor] ← reva-owner-architect.md
  - @operator [tide] ← deshi-operator-reliability.md
  - @domain [arbor] ← oona-domain-infoarch.md
  - @skeptic [drift] ← pike-skeptic-devex.md
  - @platform [compass] ← taro-platform-interaction.md
- **Specialists recruited (session-scoped):**
  - @critic [forge] — architecture critic. Contract: release at DONE
    unless promoted. **Release at DONE.**
  - @critic [lattice] — performance critic. Contract: release at DONE.
    **Release at DONE.**
  - @educator [beacon] — migration & onboarding. Contract: release at
    DONE unless migration becomes a permanent concern. **Release at
    DONE** — migration is bounded to Phase IV of buildout.

Cohort file renames (migration step D) will formalize codenames during
Phase IV of buildout. Until then, the session codenames are session-local.

## Dreams

(none — dreams were not enabled during this session)

## Next action

Buildout begins with Phase M (4 prerequisite references). On DONE commit,
the buildout cycle starts.
