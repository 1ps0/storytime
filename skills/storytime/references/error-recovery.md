---
type: reference
name: error-recovery
description: "What to do when a phase fails mid-run — tool denied, agent error, file missing, git failure, user interrupt. The recovery pattern: checkpoint first, preserve partial state, document the failure, offer resume or retry. Load when a skill hits an unexpected failure mode."
---

# Error Recovery

Storytime runs are long. Failures happen. This file documents the
single recovery pattern every skill should follow when something
breaks mid-phase.

## The Pattern

```
Detect failure
  → Write partial state
  → Update _thread.md with failure marker
  → Log failure to episode/errors.md
  → Present recovery options to user
  → User picks: retry, skip, rollback, or escalate
```

Never silently fail. Never overwrite partial work with an empty retry.
Never proceed to the next phase assuming the current one succeeded.

## Failure Modes (and what to do)

### Agent call fails (sub-agent errored or returned nothing)

1. Capture the sub-agent's last output (even if truncated)
2. Write it to `<episode>/breakout-<subtopic>-partial.md` with
   frontmatter `status: incomplete, reason: agent-error`
3. Update `_thread.md`: `last_failed_phase: BREAKOUT`,
   `last_failed_at: <timestamp>`
4. Present: "Breakout on <subtopic> failed at step X. Options:
   retry with smaller scope / skip this breakout / escalate to inline /
   abort session"

### Tool call denied by user

1. **Don't retry the same call.** The user denied it for a reason.
2. Preserve the phase state at the point of denial
3. Ask: "I need to <action> to continue <phase>. Options:
   grant this call / describe what you want instead / skip this step /
   pause the session"
4. If pause, write current state to `_thread.md` and exit cleanly

### File missing when expected

Common cases: expected prior artifact, persona file, config, referenced
code file.

1. Don't assume it was never created. Check git history:
   `git log --all --full-history -- <path>`
2. If it existed and was deleted, flag to user: "Expected `<path>` but
   it was deleted in commit X. Was that intentional?"
3. If it never existed, flag to user: "Expected `<path>` for <purpose>
   but it's not in the repo. Options: create it / skip the feature
   that needed it / investigate why"
4. Never silently create a missing file. The absence is information.

### Git operation fails (conflict, lock, permission, detached state)

1. **Never force** (`--force`, `reset --hard`, etc.) without explicit
   user approval — see main CLAUDE.md git safety rules
2. Diagnose: `git status`, `git log`, read the error message carefully
3. Present the situation to the user with the options that preserve
   the most work
4. If the storytime operation was the cause (e.g., trying to `git mv`
   an artifact during consolidation), roll back the storytime operation,
   not the user's repo state

### Explore/Grep returns nothing when expected

1. Verify the search was scoped correctly
2. Try broader scope before concluding "not there"
3. If genuinely absent, proceed but mark the finding:
   "Could not locate expected pattern X — surveyed <paths>, scope may
    be wrong or the assumption is stale"
4. Flag to the team/user so personas can challenge the assumption
   ("we assumed there was a middleware chain but survey found none —
   is this a different architecture than we thought?")

### User walks away / context limit hit

Handled by auto-checkpointing. Every phase boundary writes `_thread.md`.
The next `/storytime` invocation detects the incomplete thread and
offers to resume. No special recovery needed — this is the happy path
for interruption.

### Phase produces corrupted output (malformed frontmatter, invalid YAML, truncated)

1. Don't delete the corrupted file
2. Move it aside: `<file>.corrupted`
3. Flag to user: "Phase output at `<path>` is malformed (<reason>).
   Moved to `.corrupted`. Options: retry phase / hand-edit / skip"
4. If retry: regenerate the phase's output from the preserved phase
   inputs (e.g., re-synthesize the breakout from the already-written
   findings)

## Checkpoint Format

When a failure happens, append to `_thread.md`:

```yaml
failures:
  - phase: BREAKOUT
    subtopic: caching
    timestamp: 2026-04-10T14:23
    reason: agent-error
    partial_artifact: 001/breakout-caching-partial.md
    recovery_action: pending-user-direction
```

And write `<episode>/errors.md` if it doesn't exist:

```markdown
---
type: errors
created: <timestamp>
session: <session-id>
episode: <NNN>
---

# Errors — Episode <NNN>

## 2026-04-10T14:23 — BREAKOUT (caching) — agent-error

Sub-agent returned empty output after 3 retries. Partial state at
`breakout-caching-partial.md`. User directed: retry with narrower scope.

## 2026-04-10T14:45 — BREAKOUT (caching) — resolved

Retry succeeded. Original partial preserved as reference.
```

The errors log is another form of tracking-everything. Failures are
data, not embarrassment.

## Rules

1. **Checkpoint first, always.** Before surfacing a failure to the
   user, make sure `_thread.md` reflects current state and partial
   work is on disk.
2. **Preserve partial work.** Never delete, never overwrite. Move aside
   with a suffix if needed.
3. **Document the failure.** Write to `errors.md` so the next session
   knows what went wrong.
4. **Present options, don't decide.** The user picks the recovery path.
5. **Rollback storytime, not the user's repo.** If the plugin's own
   operation caused a failure, undo the plugin's change — never touch
   the user's code or commits without explicit approval.
6. **Never silently skip.** A phase that can't complete must be
   surfaced, not smoothed over.
