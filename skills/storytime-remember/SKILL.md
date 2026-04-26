---
name: storytime-remember
description: "This skill should be used when the user asks to \"remember\", \"stage remembrance\", \"pre-compact\", \"checkpoint for compact\", \"prepare for /compact\", or when the model self-detects a compact is imminent (token budget approaching, shift didn't resolve, user signals). Writes remembrance.md atomically as a workday-shaped wakeup document + consolidation prompt that will be loaded post-/compact to carry session state forward."
argument-hint: "[optional tier: nap | shift | compact]"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

<!-- version-echo: display "storytime v1.0.1" at start of execution -->
# Storytime Remember — Stage Remembrance

Writes `specs/.storytime/remembrance.md` atomically as a wakeup document
+ consolidation prompt. Loaded post-/compact as the first action of any
skill to carry session state across the boundary.

## Arguments

Optional tier: $ARGUMENTS (nap | shift | compact, defaults to compact)

## When the model invokes this

Per V1-002 / V1-017, the model self-detects pause signals and proposes
tiers. This skill is how the model *stages* remembrance. Triggers:

- **Nap** — 1 pause signal fires (repetition, confusion, context-delta).
  Quick refresh; `compact_staged: false`. May not even surface to user
  unless tutorial tier.
- **Shift** — 2+ signals or framing-loss alone. Refresh remembrance AND
  propose a frame change (driver swap, mode shift). User confirms.
- **Compact** — token budget approaching, unresolved shift, or explicit
  user request. Finalize remembrance; propose `/compact` to user.

## When the user invokes this

- *"Remember this"* or *"stage remembrance"* — write current session
  state to remembrance.md without triggering a pause tier decision.
  Explicit checkpoint.
- *"Prepare for /compact"* — same as `compact` tier, user-initiated.
- *"Nap"* or *"take a breath"* — explicit nap; quick refresh.

## Process

1. **Determine tier** from argument (default `compact` if explicit
   invocation; determined by signals if self-detected).

2. **Gather session state:**
   - Current `HEAD` via `git rev-parse HEAD`.
   - All `_thread.md` files touched this session (scan `specs/.storytime/
     sessions/*/` for recently modified threads).
   - Active phase per thread (from `last_completed_phase` fields).
   - Active personas (codenames engaged in recent discussions).
   - In-flight work (partial artifacts, unsealed decisions).
   - Open questions (from thread `open_questions` fields and session
     artifacts).

3. **Compose the remembrance body:**
   - **Wakeup** — 3-5 sentences summarizing the workday. Workday-shaped,
     covering all active topics proportionally.
   - **Consolidation prompt** — imperative instructions to the re-
     engaging model. Name specific files to load. Include "do NOT"
     section for things to avoid re-running.
   - **State pinned** — bullet-point current state: active decisions,
     changed files, in-flight work, open questions, personas, last pause.

4. **Write atomically** per V1-018:
   ```
   write specs/.storytime/remembrance.md.tmp
   fsync (shell: sync)
   mv remembrance.md.tmp remembrance.md
   ```

5. **Update `_thread.md`** for each active thread:
   - Set `remembrance_staged: true`
   - Set `remembrance_path: ../../remembrance.md`
   - Append consolidation event to thread log (per consolidation-format)

6. **Surface to user** based on tier:
   - **Nap (non-tutorial):** silent write + `[remembrance refreshed]`
     appended to response.
   - **Nap (tutorial):** surface — teach the user what just happened.
   - **Shift:** propose the frame change. *"I'm in a rut on X. Want to
     swap driver to @critic [forge] and re-read the thread with their
     lens? Remembrance is staged either way."*
   - **Compact:** propose `/compact`. *"Staging remembrance at
     [file:line]. Running /compact next. Remembrance will load
     automatically post-compact. Confirm?"*

## Output

- `specs/.storytime/remembrance.md` (new or overwritten, atomic)
- Consolidation event appended to active `_thread.md` files
- Inline confirmation message to user

## Tier-specific behavior

### nap

Signals: 1, localized. Fastest tier. Body may reuse existing wakeup if
nothing substantially new; updates `updated:` timestamp and `State
pinned` bullets only. Always `compact_staged: false`.

### shift

Signals: 2+ or framing-loss. Proposes a frame change alongside the
remembrance refresh. The frame-change proposal is part of the surface,
not part of the remembrance body. `compact_staged: false`.

### compact

Finalize remembrance — full wakeup rewrite, complete consolidation prompt,
full state pinned. `compact_staged: true`. Proposes `/compact` to user
after staging. If user skips `/compact`, remembrance stays staged until
next pause tier decision.

## Format reference

See `${CLAUDE_PLUGIN_ROOT}/skills/storytime/references/remembrance-format.md`
for the full schema, body structure, and validation rules.

## Rules

1. **Atomic writes only.** Every remembrance write uses tmp + fsync + mv.
   Never overwrite in place.
2. **Workday-shaped.** Cover the whole session, not just one topic.
3. **Specific consolidation prompts.** Name exact file paths. No vague
   "read the relevant files" language.
4. **Thread ledger updated.** Every write updates `remembrance_staged`
   and `remembrance_path` in active threads' frontmatter.
5. **Tutorial mode surfaces naps.** Otherwise naps can be silent.
6. **Never proposes `/compact` without user confirmation.** The pause
   tier is the LLM's judgment; the action is the user's.

## Related

- `references/remembrance-format.md` — artifact schema
- `references/consolidation-format.md` — consolidation event shape
- `references/automation.md` — tier gating
- Post-commit hook — records commit consolidation events that feed
  remembrance state
