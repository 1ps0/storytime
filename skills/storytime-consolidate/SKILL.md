---
name: storytime-consolidate
description: "This skill should be used when the user asks to \"consolidate\", \"organize docs\", \"sort documents\", \"clean up specs\", \"archive old docs\", \"triage the docs\", \"roll up\", or wants to organize, archive, or restructure existing documents into the storytime structure. File operations — moving, archiving, rolling up."
argument-hint: "[specific files or directories to consolidate]"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

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

### 5. Report

Show what was done:
- Files moved (with old → new paths)
- Rollups created (with source count)
- Files left in place
- New archive index state

## Rules

1. **`git mv` is preferred** over copy-and-delete. Preserves history.
2. **Never delete source files** — move to cold at minimum.
3. **Rollups are opinionated summaries**, not mechanical concatenation.
   Extract what matters, note what's stale, cite sources.
4. **The user approves every move** before execution. No silent file ops.
5. **External-system artifacts** (Slack threads, Google Docs links) get
   a citation stub in the archive, not a full copy.
