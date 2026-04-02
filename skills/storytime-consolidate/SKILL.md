---
name: storytime-consolidate
description: "This skill should be used when the user asks to \"consolidate\", \"organize docs\", \"sort documents\", \"clean up specs\", \"archive old docs\", \"triage the docs\", \"roll up\", \"backfill timestamps\", \"add timestamps\", \"fix metadata\", or wants to organize, archive, restructure, or add missing timestamps to existing documents. File operations — moving, archiving, rolling up, and timestamp backfill."
argument-hint: "[specific files or directories to consolidate]"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

<!-- version-echo: display "storytime v0.2.0" at start of execution -->
# Storytime Consolidate — Document Organization

Sort, triage, archive, and roll up documents into the storytime structure.
This is a file-operations skill — it moves and organizes, it doesn't
interpret or generate new content (that's absorb's job).

## Arguments

Optional scope: $ARGUMENTS (specific files, directories, or "everything")

## Process

### 1. Inventory

If a recent survey exists, use its artifact inventory. Otherwise, run a
quick scan (same targets as the survey artifact scan) to find documents.

Present the inventory as a checklist with disposition options per item:
```
Documents found (18 files):

 [x] [consolidate] team/ICEBREAKER.md → .storytime/archive/current/
 [x] [consolidate] team/DECISIONS.md → .storytime/history/decisions.md
 [x] [consolidate] team/log.md → .storytime/archive/current/
 [ ] [leave]       docs/GDD.md — game design doc, referenced externally
 [x] [rollup]     team/adaptive-music-discussion.md ─┐
 [x] [rollup]     team/visual-stem-feedback-brainstorm.md ─┤→ rollup: audio-design.md
 [x] [rollup]     team/bounce-audio-sync-discussion.md ─┘
 [x] [archive]    docs/IMPLEMENTATION_PLAN.md → .storytime/archive/current/
 [x] [cold]       archive/deprecated/ → .storytime/archive/cold/
```

### 2. User Curation

The user controls everything:
- Toggle items on/off
- Change disposition per item (consolidate / leave / rollup / archive / cold)
- Group items for rollup: "roll up all the music-related discussions"
- Bulk operations: "consolidate all", "leave everything", "archive everything under team/"
- Ask about any item before deciding

### 3. Execute Moves

For each item based on its disposition:

**Consolidate** — `git mv` to the storytime structure:
- Team-like → `specs/.storytime/cohort/`
- Spec-like → `specs/.storytime/archive/current/` or `sessions/`
- Decision logs → `specs/.storytime/history/`
- Preserve git history with `git mv`

**Rollup** — create a rollup artifact:
- Read all source documents
- Produce a rollup with: key decisions carried forward, timeline, context
  summary, source pointers (see `references/artifact-tiers.md` for format)
- Write rollup to `specs/.storytime/archive/rollups/`
- Move originals to `specs/.storytime/archive/cold/`

**Archive (warm)** — move to `specs/.storytime/archive/current/`
**Cold** — move to `specs/.storytime/archive/cold/`
**Leave** — no file operation, just note the reference

### 4. Update Index

After all moves, write or update `specs/.storytime/archive/_index.md`
with the current state of all archived artifacts:

```markdown
# Storytime Archive Index

Last updated: <YYYY-MM-DD>

## Current (warm)
| File | Source | Archived | Summary |
|------|--------|----------|---------|

## Rollups (warm)
| File | Sources | Created | Covers |
|------|---------|---------|--------|

## Cold Storage
| File | Source | Archived | Reason |
|------|--------|----------|--------|
```

### 5. Timestamp Backfill

For every file that was moved, archived, rolled up, or left in place,
check if it has the universal frontmatter minimum (`type`, `created`,
`session`). If not, backfill from available evidence.

See `${CLAUDE_PLUGIN_ROOT}/docs/timestamps.md` for the full timestamp
principle, evidence sources, and confidence markers.

**Evidence sources (in priority order):**
1. `git log -1 --format=%aI -- <path>` — first commit adding the file (for `created`)
2. `git log -1 --format=%aI -- <path>` — last commit touching the file (for last modified)
3. Existing frontmatter dates — parse any YAML dates already present
4. Filename dates — parse `YYYY-MM-DD` from filename if present
5. Filesystem mtime — `stat` command (medium confidence)
6. Adjacent file dates — files created around the same time (low confidence)
7. Content references — "as of March" or date mentions in body text (low confidence)

**Backfill process per file:**
1. Read the file
2. Check for existing frontmatter. If `type`, `created`, `session` all present → skip
3. For each missing field, search evidence sources in priority order
4. Add or update frontmatter with inferred values
5. Mark confidence: `git-derived`, `approximate`, or `estimated`
6. Present backfilled files to the user for approval before writing

**Coarseness rules:**
- Git evidence → exact date, `git-derived` confidence
- Filename evidence → exact date, `git-derived` confidence
- Filesystem evidence → exact date, `approximate` confidence
- Adjacent/content evidence → use `~YYYY-MM` or `~YYYY-Qn`, `estimated` confidence
- No evidence → mark as `unknown`, don't guess

**Example backfill:**
```yaml
# Before (no frontmatter):
# team/ICEBREAKER.md — just a markdown file

# After backfill:
---
type: icebreaker
created: 2026-03-20
created_confidence: git-derived
session: null
---
```

**Bulk backfill:** The user can say "backfill timestamps on everything" to
run backfill across all storytime-managed documents. Present a summary:
```
Timestamp backfill results (18 files):

  Already complete:  4 files
  Backfilled:        11 files (8 git-derived, 2 approximate, 1 estimated)
  No evidence:       3 files (marked unknown)

  Review backfilled files? [y/n]
```

### 6. Report

Show what was done:
- Files moved (with old → new paths)
- Rollups created (with source count)
- Files left in place
- Timestamps backfilled (with confidence breakdown)
- New archive index state

## Rules

1. **`git mv` is preferred** over copy-and-delete. Preserves history.
2. **Never delete source files** — move to cold at minimum.
3. **Rollups are opinionated summaries**, not mechanical concatenation.
   Extract what matters, note what's stale, cite sources.
4. **The user approves every move** before execution. No silent file ops.
5. **External-system artifacts** (Slack threads, Google Docs links) get
   a citation stub in the archive, not a full copy.
6. **Backfill is additive** — add timestamps, never remove existing metadata.
7. **Coarse-and-honest over precise-and-wrong** — `~2026-02` beats a guess
   of `2026-02-15`. Mark confidence on every inferred timestamp.
8. **Universal frontmatter on every file** — `type`, `created`, `session`.
   See `${CLAUDE_PLUGIN_ROOT}/docs/timestamps.md` for the full spec.
