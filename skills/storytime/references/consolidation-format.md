---
type: reference
name: consolidation-format
description: "Unified frontmatter and artifact shape for all consolidation events — phase, commit, nap, shift, session, compact. Load during any consolidation write. Central reference for V1-008."
---

# Consolidation Format — Unified Event Shape

Every consolidation event in v1.0 writes an artifact with the same
frontmatter shape. Scale differs (phase/commit/nap/shift/session/compact);
mechanism is unified.

## Frontmatter schema

```yaml
---
type: consolidation           # REQUIRED — always "consolidation"
schema_version: 1             # REQUIRED
scale: phase                  # REQUIRED — phase | commit | nap | shift | session | compact
at: 2026-04-14T10:00          # REQUIRED — ISO 8601
event: <scale-specific>       # REQUIRED — phase name, commit sha, or "user-requested"
session: <session-id>         # REQUIRED if inside an active storytime session; null otherwise
topic: <topic>                # REQUIRED if inside an active session; null otherwise
commit: <sha>                 # REQUIRED for scale=commit; optional for others if known
driver: "@role [codename]"    # REQUIRED for phase/shift; optional for nap/commit
supporters: [...]             # OPTIONAL
signals: [repetition, rut]    # REQUIRED for nap/shift/compact (which pause signals fired)
pause_posture: ok             # REQUIRED — ok | nap-proposed | shift-proposed | compact-proposed
prior_consolidation:          # OPTIONAL — pointer to preceding consolidation at any scale
  scale: phase
  at: 2026-04-14T09:30
files_touched: [...]          # OPTIONAL — for scale=commit, mirror of git diff --name-only
decisions_pinned: [V1-030]    # OPTIONAL — decisions sealed at this event
---
```

## Body shape per scale

### scale: phase

Standard phase artifact (survey.md, team.md, icebreaker.md, breakout-*.md,
plan.md, buildout-*.md). The phase's own content fills the body; the
consolidation event is the frontmatter + an optional closing "digest" block:

```markdown
## Digest (5-line consolidation snapshot)

- What this phase produced: <1 line>
- Key decisions sealed: <list or "none">
- Drivers active: <list>
- Open questions returned: <count>
- Links to read next: <paths>
```

### scale: commit

Written to `_thread.md` as a new consolidation entry, not as a standalone
file. Shape:

```markdown
## Consolidation — commit <short-sha>
  At: 2026-04-14T10:15
  Event: commit <sha>
  Files: [src/foo.ts, src/bar.ts]
  Decisions pinned: —
  Pause posture: ok
  Dream: dream-<sha>.md  (if dreams enabled and commit crossed interest threshold)
```

### scale: nap

Minimal. Written to `_thread.md` AND `remembrance.md.tmp` (which atomically
becomes `remembrance.md`). Body in thread:

```markdown
## Consolidation — nap
  At: 2026-04-14T10:30
  Signals: [repetition]
  Pause posture: nap-proposed (user: accepted)
  Remembrance refreshed: remembrance.md
```

The remembrance refresh captures the workday state (see
`references/remembrance-format.md` — reserved for Phase I.3).

### scale: shift

Like nap, but with driver/mode change recorded:

```markdown
## Consolidation — shift
  At: 2026-04-14T11:00
  Signals: [rut, framing-loss]
  Pause posture: shift-proposed (user: accepted)
  Driver change: @domain [arbor] -> @critic [forge]
  Mode change: inline -> deliberation
  Remembrance refreshed: remembrance.md
```

### scale: session

Written at session DONE. Same as current session-close behavior, now
formalized:

```markdown
## Consolidation — session DONE
  At: 2026-04-14T12:00
  Episode: 001
  Last commit: <sha>
  Decisions sealed this session: [V1-014..V1-030]
  Archive rollup: (paths updated)
  Persona acquired_context deltas: (cohort files updated)
```

### scale: compact

Finalizes `remembrance.md`. Written to `_thread.md` as the final consolidation
entry before compaction:

```markdown
## Consolidation — compact
  At: 2026-04-14T12:30
  Trigger: user-requested       # or: token-budget | shift-escalation
  Remembrance finalized: remembrance.md
  Loader directive: first-read post-/compact
```

## Atomic write protocol

All consolidation writes use tmp+fsync+mv (V1-018):

1. Write to `<target>.tmp`.
2. fsync (or shell equivalent).
3. `mv <target>.tmp <target>` — atomic on same filesystem.
4. On failure: `.tmp` left in place, continuity ledger flagged
   `consolidation_write_failed: <timestamp>`, existing target untouched.

`/storytime-lint` checks: orphan `.tmp` older than 5 minutes → warning.

## Signal vocabulary (V1-016)

For scale ∈ {nap, shift, compact}, `signals` must be drawn from:

- `repetition` — same claim/question/revisit within last 3-5 turns
- `confusion` — contradictory context OR ungrounded claim
- `rut` — ≥3 attempts at same sub-problem without convergence
- `framing-loss` — driver drift without explicit swap OR no clear lens
- `context-delta` — large "what happened since last consolidation" footprint
- `token-budget` — compact-tier only; threshold crossing per config

## Tier mapping (V1-017)

Combination logic, not intensity:

- **nap** — exactly 1 signal, localized and recent
- **shift** — ≥2 signals simultaneously, OR 1 signal persistent across
  ≥2 consolidation events, OR `framing-loss` alone
- **compact** — `token-budget` (authoritative), OR `shift` that didn't
  resolve degradation, OR explicit `/storytime-remember` invocation

## Validation

Mechanical checks (scripts/check-conventions.sh extension):

| Check ID | Check |
|----------|-------|
| CF1 | `type: consolidation` present |
| CF2 | `schema_version: 1` present |
| CF3 | `scale` in allowed vocabulary |
| CF4 | `at` parseable as ISO 8601 |
| CF5 | `pause_posture` in {ok, nap-proposed, shift-proposed, compact-proposed} |
| CF6 | `signals` present when scale ∈ {nap, shift, compact} |
| CF7 | `signals` drawn from allowed vocabulary |
| CF8 | `commit` resolves via `git cat-file -e <sha>` when scale = commit |
| CF9 | `driver` is `@role` or `@role [codename]` pattern |
| CF10 | No orphan `.tmp` files older than 5 minutes |

Reasoning-tier checks (estimator agent):

| Check ID | Check |
|----------|-------|
| CF-R1 | Digest is substantive (not placeholder text) for phase scale |
| CF-R2 | Signals chosen match the event description (cross-check) |
