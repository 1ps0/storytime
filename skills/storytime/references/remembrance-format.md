---
type: reference
name: remembrance-format
description: "The remembrance.md artifact shape — workday-shaped wakeup document plus consolidation prompt. Loaded as the first action of any skill post-/compact. Written at pauses and pre-compact. Load when producing or consuming remembrance."
---

# Remembrance Format

`remembrance.md` is the **pre-staged wakeup document plus consolidation
prompt** that carries session state across a `/compact` boundary. Two
roles in one file:

1. **Wakeup note** — what was being worked on across the whole session
   (potentially multiple topics), what state the work is in, what's in
   flight, what decisions are pinned, which personas are active.
2. **Consolidation prompt** — explicit instructions to the re-engaging
   model: *"Go through the context and gather what is necessary to
   continue waking up and doing the work."* Names specific files to
   load, specific decisions to re-verify, specific questions that were
   open.

Workday-shaped, not topic-lasered (V1-005). If the session jumped
between topics, the remembrance reflects that shape.

## Location

**Per-repo, single file:** `specs/.storytime/remembrance.md`

Not per-topic. Not per-episode. One at a time. Written fresh at each
pause; superseded by the next. The most recent pause's remembrance is
always the current one.

## Schema

```yaml
---
type: remembrance
schema_version: 1
created: 2026-04-14T10:00
updated: 2026-04-14T11:30        # latest pause refresh
compact_staged: true              # true if a compact is imminent or expected
last_commit: abc1234              # HEAD at time of most recent refresh
active_threads:                   # all threads touched during the session
  - topic: v1-consolidation
    path: specs/.storytime/sessions/v1-consolidation/_thread.md
    active_phase: CONVERGE        # or DONE, BUILDOUT, etc.
    driver: "@owner [anchor]"
  - topic: migration
    path: specs/.storytime/sessions/migration/_thread.md
    active_phase: null            # touched but not in-flight
    driver: null
active_personas:                  # codenames engaged this session
  - "@owner [anchor]"
  - "@operator [tide]"
  - "@critic [forge]"
tutorial_state_path: .storytime/tutorial-state.md
commit_patterns_path: .storytime/commit-patterns.md
---
```

## Body structure

Three sections. All three always present.

### 1. Wakeup — workday summary

3-5 sentences reconstructing the arc of the session. What was being
worked on, who drove which decisions, what changed since the last
compact, what's still open. Workday-shaped — if multiple topics were
active, cover them in proportion to attention spent.

This is the *content* of "previously on..." — the human-readable
narrative that lets the re-engaging model orient immediately.

### 2. Consolidation prompt — explicit instructions

A direct instruction to the re-engaging model. Names specific files to
load and in what order. Uses imperative voice. Example:

```markdown
## Consolidation prompt

You are continuing work on the v1.0 consolidation buildout, specifically
at Phase II (hooks). To re-engage:

1. Read `specs/.storytime/sessions/v1-consolidation/001/plan.md` for
   the implementation plan. Find the current active phase.
2. Read `specs/.storytime/sessions/v1-consolidation/_thread.md` to see
   the latest decisions and the current state of Phase II work.
3. Skim `skills/storytime/SKILL.md` — the Consolidation section is
   newly added in this session; familiarize yourself with its structure
   before extending it.
4. Do NOT re-run SURVEY or ASSEMBLE — team is stable, context is loaded.
5. Confirm orientation with user before proceeding: ask "resuming v1.0
   Phase II buildout at item II.2 (post-commit hook) — continue?"

## Do NOT

- Re-run the full consolidation spec session (already DONE).
- Treat this file as authoritative — it's a PROMPT TO LOAD, not a
  replacement for source artifacts.
- Assume the personas are already in context — reload them from
  cohort/_roster.md if they'll participate.
```

### 3. State pinned — current in-flight context

Bullet points capturing immediate state that isn't in any one document:

```markdown
## State pinned

- Active decisions sealed this session: V1-014..V1-030
- Files changed since last_commit: [src/foo.ts, src/bar.ts, docs/baz.md]
- In-flight work:
  - II.1 pause detection prose (WIP, not yet committed)
  - III.2 tutorial friction integration (blocked on II.1)
- Open questions:
  - Should II.2 hook be per-repo or per-user?
  - How do we detect rebase/amend for hook suppression?
- Personas at the table: @owner [anchor], @operator [tide]
- Last pause: 2026-04-14T11:30, signals=[rut, context-delta], tier=shift
```

## Write protocol (V1-018)

All remembrance writes are atomic:

1. Write `specs/.storytime/remembrance.md.tmp`.
2. fsync (or shell equivalent).
3. `mv remembrance.md.tmp remembrance.md` — atomic on same filesystem.
4. On failure: `.tmp` left; continuity ledger flagged
   `remembrance_write_failed: <timestamp>`; existing `remembrance.md`
   untouched.
5. Orphan `.tmp` older than 5 minutes → lint warning.

**Invariant: a partial remembrance never replaces a good one.**

## Load protocol (post-/compact)

First action of any storytime skill post-compaction:

1. Check `specs/.storytime/remembrance.md` exists.
2. If present AND `compact_staged: true`:
   - Read it.
   - Synthesize as current context ("previously on this workday...").
   - Follow the consolidation prompt's instructions (load named files).
   - Surface to the user: *"Loaded remembrance from [timestamp].
     Continuing from [active phase / topic]. Proceed?"*
3. If absent OR `compact_staged: false`:
   - Not a compacted session. Proceed as normal.
4. If present AND stale (older than 24h with no recent activity):
   - Surface: *"Found stale remembrance from [date]. Load, reset, or
     ignore?"*

## Trigger events (V1-002, V1-017)

Remembrance is written at three events:

- **nap** — quick refresh, minimal changes. `compact_staged: false`.
- **shift** — mid-session with frame change. `compact_staged: false`.
- **compact** — pre-compaction finalization. `compact_staged: true`.

Also on **explicit invocation** via `/storytime-remember` (user can call
at any time to stage).

## Workday-shape details

The "workday" framing means: remembrance covers the **session**, not a
single topic. If the user ran `/storytime v1-consolidation` then
`/storytime-buildout v1-consolidation` then asked `@critic look at this
file`, the remembrance covers all three activities proportionally.

The `active_threads` array lists every thread that received writes
during the session. Active phase is recorded per thread. Non-topic work
(like the `@critic` question) is captured in the wakeup narrative prose.

## Validation

Mechanical:

| Check ID | Check |
|----------|-------|
| RM1 | `type: remembrance`, `schema_version: 1` present |
| RM2 | All three body sections present (Wakeup, Consolidation prompt, State pinned) |
| RM3 | `last_commit` resolves via `git cat-file -e <sha>` |
| RM4 | `active_threads[].path` all exist as files |
| RM5 | No orphan `remembrance.md.tmp` older than 5 minutes |

Reasoning:

| Check ID | Check |
|----------|-------|
| RM-R1 | Wakeup narrative is substantive (not placeholder) |
| RM-R2 | Consolidation prompt names specific files, not vague pointers |
| RM-R3 | State pinned block captures actual in-flight work |

## v1.1 and beyond

- Multi-remembrance archive (`remembrance-<timestamp>.md` in a
  `.storytime/remembrances/` dir) for post-hoc review.
- User-initiated "remember this" for mid-session checkpointing outside
  pauses.
- Automatic remembrance replay for context-reset scenarios beyond
  `/compact` (e.g., terminal crash).
