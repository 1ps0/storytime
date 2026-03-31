---
name: storytime-undo
description: "This skill should be used when the user asks to \"undo\", \"cancel\", \"abort\", \"roll back\", \"revert\", \"stop storytime\", \"scratch that\", \"back up\", \"that's wrong\", or wants to reverse storytime output at any granularity — from a single phase to an entire thread."
argument-hint: "<scope> (e.g., 'last step', 'last episode', 'entirely', 'the breakout')"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# Storytime Undo

Reverse storytime output at any granularity. From "scratch that last
breakout" to "burn the whole thread and start over."

## Arguments

What to undo: $ARGUMENTS

## Granularity Levels

### Fine: Undo Last Phase

**Trigger phrases:** "undo last step", "scratch that", "redo the breakout",
"that icebreaker was wrong", "back up one"

**What it does:**
1. Identify the most recently completed phase from `_thread.md`
   (or from the files present if no thread yet)
2. Show the user what will be removed:
   ```
   Undo: icebreaker.md (written 5 minutes ago)
   Thread will rewind to: ASSEMBLE complete
   Continue? [y/n]
   ```
3. On confirmation:
   - Delete the phase's output file(s)
   - If `_thread.md` exists, rewind `last_completed_phase` to the prior phase
   - Update `open_questions` if relevant

**Special cases:**
- Undoing a breakout: delete only that specific `breakout-<subtopic>.md`,
  not all breakouts
- Undoing SURVEY: also invalidates the coverage fingerprint
- Undoing ASSEMBLE: team context is cleared — next phase will re-assemble
- Undoing DONE: reopens the episode, reverts persona file updates and
  decision log entries added in DONE (uses git to identify the changes)

### Medium: Undo Last Episode

**Trigger phrases:** "undo last episode", "scratch episode 2", "that whole
session was off", "start this episode over"

**What it does:**
1. Identify the last (or specified) episode from `_thread.md`
2. Show the user what will be removed:
   ```
   Undo episode 002:
     - preamble.md
     - survey-delta.md
     - icebreaker.md
     - plan.md
   Thread will rewind to: episode 001 (DONE)
   Continue? [y/n]
   ```
3. On confirmation:
   - Delete the episode directory entirely
   - Rewind `_thread.md` to the prior episode's state
   - Remove the episode from the episode log
   - Revert any persona file updates and decision log entries from this episode

### Coarse: Abort Thread

**Trigger phrases:** "cancel storytime", "abort entirely", "burn it",
"start over", "this whole thread is wrong"

**What it does:**
1. Show the user what will be removed:
   ```
   Abort thread: <topic>
     Episodes: 3 (001, 002, 003)
     Decisions: TOPIC-001 through TOPIC-008
     Persona updates from these sessions

   Options:
     [archive] — move thread to cold storage (recoverable)
     [delete]  — remove all files (git history preserves them)
     [cancel]  — never mind, keep going
   ```
2. On confirmation:
   - **Archive:** move `sessions/<topic>/` to `archive/cold/<topic>/`,
     update `archive/_index.md`. Decisions get `status: superseded` in
     the decision log. Persona updates stay (they learned something).
   - **Delete:** `git rm -r sessions/<topic>/`. Revert decision log
     entries. Revert persona file updates from these sessions.

### Surgical: Undo Specific Artifact

**Trigger phrases:** "undo the plan", "remove breakout-caching",
"delete the survey", "that team file is wrong"

**What it does:**
1. Identify the specific file from the user's description
2. Show what will be removed and any downstream effects:
   ```
   Remove: 002/breakout-caching.md
   Note: plan.md references this breakout's findings
   Continue? [y/n]
   ```
3. On confirmation:
   - Delete the specific file
   - Warn about (but don't auto-fix) downstream references

### Redo: Undo + Retry

**Trigger phrases:** "redo the icebreaker", "redo that breakout with
different constraints", "try the plan again"

**What it does:**
1. Undo the specified phase (same as Fine)
2. Immediately re-enter that phase with the user's new constraints
3. The user can provide new direction: "redo the icebreaker but focus on
   performance, not correctness"

## Process

### 1. Parse Scope

Determine the granularity from the user's request:
- Mentions a specific file or phase → **Surgical** or **Fine**
- Mentions "episode" or "session" → **Medium**
- Mentions "entirely", "cancel", "abort", "start over" → **Coarse**
- Mentions "redo" or "try again" → **Redo** (undo + retry)
- Ambiguous → ask the user

### 2. Inventory Impact

Before doing anything, show the user exactly what will change:
- Files to be deleted
- Thread state changes
- Decision log entries affected
- Persona file updates affected
- Downstream artifacts that reference the undone work

### 3. Confirm

Always confirm before destructive operations. The confirmation shows the
full impact inventory. The user can adjust scope ("actually just undo the
breakout, keep the icebreaker").

### 4. Execute

- Delete files as specified
- Update `_thread.md` (or delete it for coarse abort)
- Update decision log if decisions are being reversed
- Update persona files if persona context is being reversed
- For archive operations, update `archive/_index.md`

### 5. Report

After execution, confirm what was done:
```
Done. Rewound to: ASSEMBLE complete (episode 002)
Next step: re-run ICEBREAKER when ready
```

## Rules

1. **Always confirm before deleting.** Show the full impact first.
2. **Git is the safety net.** Even after deletion, `git log` and
   `git checkout` can recover files. Remind the user if they're nervous.
3. **Prefer archive over delete for coarse operations.** Default to
   archive; delete only if the user explicitly asks.
4. **Persona learning persists by default.** Even when undoing sessions,
   what personas learned stays in their files unless the user explicitly
   asks to revert persona state. Personas don't forget.
5. **Redo is undo + immediate retry.** Don't make the user invoke two
   separate commands.
6. **Downstream warnings, not auto-fixes.** If undoing a breakout that
   the plan references, warn about it but don't auto-rewrite the plan.
   The user decides how to handle cascading effects.
7. **No undo of undo.** If the user undoes an undo, that's just a normal
   storytime operation (re-running the phase). Don't build undo stacks.
