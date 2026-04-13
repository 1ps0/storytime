---
type: proposal
created: 2026-04-12T16:00
updated: 2026-04-13T10:00
name: v1-consolidation
status: draft — open questions resolved
schema_version: 1
---

# v1.0 — Consolidation as the Primary Loop

## Thesis

Storytime is a **continuity system** for LLM–harness collaboration. The spec
workflow (survey → assemble → icebreaker → breakout → converge → plan) is
one surface on top of a more fundamental mechanism:

> context → consolidation at phase-equivalent events → document structure →
> continuity across compactions, sessions, and time

v1.0 makes this explicit. Existing primitives get absorbed, renamed, or
removed so the framework serves continuity with minimal bloat. Sleep-cycle
imagery is allegory only — the proposal uses explicit terminology
(consolidation, continuity, remembrance) throughout.

## North star

**Continuity is cheap.** A session can be picked up later, in a new context
window, across any number of `/compact` operations, with minimal
re-orientation cost. Every design decision answers *does this make
continuity cheaper?* — if no, cut it.

## Core definitions

### Consolidation event

A moment where ephemeral context is written to durable structure. Concrete
operation: take working memory, transform per a rule, write to filesystem,
update the continuity ledger.

Consolidation fires at different scales with different triggers. Mechanism
is unified; scale differs:

| Scale               | Trigger                                                  | Primary output                                            | Already exists?      |
|---------------------|----------------------------------------------------------|-----------------------------------------------------------|----------------------|
| Phase               | Phase boundary within an active skill                    | Phase artifact + digest appended to thread                | Yes                  |
| Commit              | LLM-drafted + user-confirmed commit on current branch    | Thread update + decision pin + (optional) dream           | Partial (needs hook) |
| Nap (pause, light)  | Model self-detects degradation OR optional config threshold | `remembrance.md` quick refresh — brief "catch breath"  | No (NEW)             |
| Shift (pause, medium)| Model detects it's stuck in a rut / losing framing     | Remembrance + frame change (driver swap, mode shift)       | No (NEW)             |
| Session             | Session DONE, walk-away, or explicit park                | Persona `acquired_context` delta + archive rollup         | Partial              |
| Compact (deep)      | Context approaching budget OR explicit invocation        | `remembrance.md` finalized — full wakeup + prompt          | No (NEW)             |

**Pauses are for the model, not the human.** They fire when the model
detects its own thinking degrading — confusion creeping in, repeating
itself, losing the thread — not at fixed intervals. Three tiers by depth:

- **Nap** — quick reset. Refresh remembrance, take a beat, continue.
  Minimal interruption. Equivalent to "catch your breath." May not even
  surface to the user unless the user wants visibility.
- **Shift** — medium. The model is stuck in a rut or losing framing.
  Refresh remembrance AND change something: swap driving persona, switch
  mode (inline → deliberation or vice versa), re-read the thread with a
  different lens. Equivalent to "take a walk to think about it
  differently." Surfaces to the user as a proposal.
- **Compact** — deep. Full context handoff. Finalize remembrance, propose
  `/compact` to the user. Equivalent to a long night's sleep.

Threshold-based pauses are available as an **optional override** in config
for users who want periodic discipline, but the default is
model-introspection-driven. See the Hook map for the self-detection
signals.

### Remembrance

A single document (`remembrance.md`) that serves **two roles in one file**:

1. **Wakeup note** — what was being worked on across the whole session
   (which may span multiple topics), what state the work is in, what's
   in flight, what decisions are pinned, which personas are active.
2. **Consolidation prompt** — explicit instructions to the re-engaging
   model: *"Go through the context and gather what is necessary to
   continue waking up and doing the work."* Names specific files to load,
   specific decisions to re-verify, specific questions that were open.

**Workday-shaped, not topic-lasered.** Remembrance covers the session
state as a whole — if the user has been working across multiple topics
or jumping between explore and implement, the remembrance reflects that
shape. It's more like "here's what you were doing today" than "here's a
summary of topic X."

**Written at pauses AND pre-compact.** A pause refreshes the remembrance
at an intermediate context size — if the session continues, the next
pause supersedes. If compact arrives (forced or proposed), the most
recent pause's remembrance is already staged and finalized. One
mechanism, two triggers, zero duplication.

Remembrance is loaded as the first action of any skill **after** a
compact. It replaces the existing warm-start preamble synthesis — same
role (re-engagement), but pre-staged instead of reactive.

Sketch of the shape:

```markdown
---
type: remembrance
created: 2026-04-12T16:00
schema_version: 1
session: v1-consolidation
topic: v1-consolidation
compact_staged: true
last_commit: abc123
active_thread: specs/.storytime/sessions/v1-consolidation/_thread.md
active_phase: CONVERGE
---

# Wakeup — v1-consolidation

You were mid-CONVERGE on the v1.0 consolidation proposal. The team had
just resolved the dreams-vs-consolidation distinction and was about to
start drafting the hook map. @owner [anchor] is driving this phase.

## Consolidation prompt

To continue waking up and doing the work:

1. Read `specs/.storytime/sessions/v1-consolidation/001/plan.md` — the
   current plan-in-progress. This is the primary artifact to extend.
2. Read `docs/proposals/v1-consolidation.md` (this file's source) —
   the proposal that seeded the session.
3. Read `specs/.storytime/sessions/v1-consolidation/_thread.md` — the
   continuity ledger. It names open questions and active decisions.
4. Confirm orientation with user before proceeding. Ask: "resuming
   CONVERGE on v1-consolidation — last state was [N]. Continue?"

## State pinned

- Active decisions: V1-001 (commits are consolidation clock),
  V1-002 (dreams are ancillary byproducts), V1-003 (Fibonacci T-scale).
- Open questions: commit-authoring contract specifics; compact
  detection mechanism; dream pruning policy.
- Files changed since last_commit: none.
- Personas at the table: @owner [anchor], @systems [lattice],
  @critic [forge], @skeptic.

## Do NOT

- Re-run SURVEY (already fingerprinted in 001/survey.md).
- Re-convene ASSEMBLE (team is stable).
- Treat this wakeup as authoritative — it's a *prompt to load*, not a
  replacement for the source artifacts.
```

### Dreams (ancillary byproduct)

Per-commit side artifacts. Short structured notes capturing:
- Hunches the model was tracking but didn't articulate
- Noticed-but-not-said observations
- Daydream design material — "what if we also..."
- Indicator patterns for future breakouts or ideations
- Candidate decisions the model considered but didn't commit to

**Not on the critical path for continuity.** Pruneable without data loss.
Never required for resume.

**Quasi-independent, optional, disablable.** Dreams are a config opt-in
(off by default for users who don't want them). When enabled, they
accumulate as a byproduct of commit consolidation — not as infrastructure.
Users who enable them can still disable at any time; continuity doesn't
depend on them.

**Dreams live at the top level**, not under sessions/topic/episode.
They go to `.storytime/dreams/dream-<short-sha>.md` and reference their
context in-file (commit, active session if any, active topic if any).
This means dreams from commits outside a storytime session still have
a canonical home, and dreams are cross-referenceable by commit, date,
or content from anywhere in the repo.

Dreams are retroactively useful: when a future breakout asks "did we
ever notice something about X?", the dreams directory is the archive
searched. Until then, they accumulate quietly.

### Continuity ledger

`_thread.md` reframed. **It's the single source of truth for session
continuity AND the decision log.** The standalone `history/decisions.md`
merges into the thread — stronger ownership, better organization, fewer
places to look for the same information.

```yaml
---
type: thread
schema_version: 1
topic: <topic>
last_consolidation:
  scale: commit       # phase | commit | pause | session | compact
  event: <sha-or-phase-name>
  at: <timestamp>
remembrance_staged: true
remembrance_path: remembrance.md
---

# Thread — <topic>

## Episodes
- 001 (DONE, 2026-04-10)
- 002 (incomplete — CONVERGE)

## Decisions (append-only, pinned to commit)

### V1-001 — Commits are the consolidation clock
  At: 2026-04-12
  Commit: abc1234
  Drivers: @owner [anchor]
  Supersedes: —
  Status: active

### V1-002 — Dreams are ancillary byproducts
  At: 2026-04-12
  Commit: abc1234
  Drivers: @systems [lattice]
  Status: active

## Dreams (references only — files live at .storytime/dreams/)
- dream-abc1234.md — first hook sketch, included hunch about token thresholds
- dream-def5678.md — noticed-but-not-said about Kiro export edge case

## Open questions
- Commit-authoring confirmation UX — single prompt or batch?
```

Decisions are append-only within the thread. Supersede, never delete.
Each decision pins to the commit that sealed it, making stale-decision
detection (W1 from the critic review) a commit-delta check against the
pin.

## Hook map

| Hook                       | Trigger                                                           | Action                                                                 |
|----------------------------|-------------------------------------------------------------------|------------------------------------------------------------------------|
| **Commit draft + confirm** | LLM detects a milestone (work finished OR significant progress)   | LLM drafts commit message; **user confirms before commit happens**     |
| `post-commit` (git)        | Confirmed commit on current branch (not --amend/rebase)           | Update thread, pin decisions, optionally spawn dreamer                 |
| Phase boundary (skill)     | Phase complete in active skill                                    | Existing — unified into consolidation event format                     |
| **Nap (self-detected)**    | Model senses degradation signal (see signals below)               | Quick remembrance refresh; may not surface to user unless asked        |
| **Shift (self-detected)**  | Model senses rut / framing loss                                   | Remembrance + frame change (driver swap, mode shift); user confirms    |
| **Compact pre-trigger**    | Model senses context saturation OR threshold crossed OR `/storytime-remember` | Finalize `remembrance.md`; propose `/compact` to user (may skip)   |
| Compact post-trigger       | First action of any skill in a compacted session                  | Check for `remembrance.md`, load, synthesize as current context        |
| Session DONE               | Explicit completion                                               | Archive rollup, persona `acquired_context` delta                       |

Hooks fire at **natural boundaries**. No polling, no scheduled work, no
always-on that's actually always-burning.

### Commit confirmation contract (adaptive)

The LLM drafts **every** commit message — detail-rich, citing files,
personas, and decisions. The user **always confirms** before the commit
actually happens. There is no "auto-commit" mode.

**But the confirmation learns.** Single prompt every time initially, but
the system tracks patterns:

- User always approves `docs/` commits without edits → suggest batching
  docs commits with less prompting
- User always modifies `plan.md` commits → keep full prompting, possibly
  surface the specific fields the user changes
- User quickly approves small drift-fix commits → propose a "quiet mode"
  for small commits after N consecutive approvals

Learning is **local and reversible** — the user can always say "prompt
me on everything again" and the pattern resets.

Triggers for commit proposal:

- A unit of work is finished (phase, breakout, buildout slice, plan
  approval, decision sealing)
- Significant-enough progress has been made that the line moves forward
  to a "milestone" — judgment call, but common patterns: a problem is
  solved, a rewrite is complete, a blocker is cleared, several related
  files are in a coherent state

The LLM should NOT propose commits for: typo fixes (usually fold into
next substantive commit), incomplete halfway states (unless user asks),
noisy exploratory changes.

### Model-driven pause signals

Pauses fire when the **model self-detects degradation**. Signals:

- **Context-delta check** — how much has the model processed since the
  last remembrance? Large deltas are candidates for a nap. (This uses
  the delta as the signal, not a fixed token count — it's "how much has
  happened" not "how much is loaded.")
- **Repetition / confusion** — the model notices it's saying the same
  thing twice, asking clarifying questions that were already answered,
  or revisiting decisions that were sealed.
- **Rut signal** — multiple attempts at the same sub-problem without
  progress; or a long sprint without a natural boundary.
- **Framing loss** — the driver has shifted without intent, or the model
  is responding from no clear lens.
- **Token budget approaching** (compact only) — crossing the compact
  threshold per model (optional defaults below; overridable in config).

When a signal fires, the model proposes the appropriate tier (nap /
shift / compact). User confirms or defers. Neither ever forced.

### Optional threshold config (for users who want it)

Fallback thresholds by model, used only when `pause_mode: threshold` is
set in config. Default is `pause_mode: model-introspection`.

| Model              | Optional compact threshold |
|--------------------|----------------------------|
| Claude Opus 4.6 1M | 400k tokens                |
| Claude Sonnet 4.6  | 200k tokens                |
| Claude Haiku 4.5   | 150k tokens                |
| Other / unknown    | 75% of window              |

### Context-delta staleness check

Between pauses, the model tracks how much has been processed since the
last remembrance write. If the delta grows large and the model *also*
detects a degradation signal, that's a strong case for a pause. The
delta alone is not a trigger (avoiding the "fixed threshold" problem);
it's one input to the self-introspection decision.

## What gets simplified (minimal bloat)

- **Warm-start preamble synthesis → remembrance.md load.** One mechanism
  instead of two. Cuts the preamble-synthesis procedure from main SKILL
  (~30 lines). Remembrance is written once (pre-compact) and loaded
  as-is (post-compact) — no repeated synthesis.

- **Phase-boundary digests → unified consolidation event format.** All
  scales (phase, commit, session, compact) use the same artifact shape:
  frontmatter + digest + links. One format in `references/consolidation-format.md`
  replaces the ad-hoc "5-line digest" rule scattered across skills.

- **Warm-start section in main SKILL + Thread Checkpointing + Phase-boundary
  compaction → single "Consolidation" section.** Three sections collapse
  into one, because they're all describing the same mechanism at
  different scales. Target main SKILL reduction: 410 → ~280 lines.

- **Archive tiers (hot/warm/cold) → consolidation tiers (working/consolidated/
  archived).** Same idea, renamed to the mechanism. May compress from
  three tiers to two; TBD during spec.

- **Persona `acquired_context` updates → triggered by consolidation events.**
  Currently updated at session DONE only; under v1.0, updated at commit
  events so lens memory is current at all times instead of lumpy.

- **Process rules shrink.** ~34 → ~25. Consolidation absorbs several
  (phase-boundary compaction, thread checkpointing, warm-start, dream
  handling) into a smaller set of consolidation rules.

## What gets added (earning its keep)

- `remembrance.md` format + post-/compact load protocol — **critical path**
- `/storytime-remember` skill — explicit "prepare for /compact" invocation
- Post-commit hook (opt-in via config) → thread update + optional dream
- `agents/dreamer.md` — writes dreams as byproduct (not critical path)
- New "Consolidation" section in main SKILL (replaces three current sections)
- `references/consolidation-format.md` — unified artifact shape

Each addition absorbs or replaces something existing. No pure additions.

## What gets removed

- Standalone warm-start preamble *synthesis* — replaced by remembrance load
- "Skip the recap" collapse rule — unnecessary with loaded remembrance
- Some phase-boundary machinery becomes implicit in consolidation events
- Scattered "digest" rules in individual skills — unified

## Transformation map (Fibonacci-extended T-scale)

| Concept                         | T   | Shape in v1.0                                                                 |
|---------------------------------|-----|-------------------------------------------------------------------------------|
| Personas / archetypes           | 2   | Lenses over memory. Same mechanics.                                           |
| @role addressing                | 1   | Attention anchor over memory. Same.                                           |
| Driver per leg                  | 1   | Which lens drives consolidation for this event.                               |
| Citations                       | 1   | Memory grounding — a link to source in long-term storage.                     |
| `_thread.md`                    | 5   | Becomes the continuity ledger. Gains `last_consolidation`, `dreams`, `remembrance_staged`. |
| Phase-boundary compaction       | 8   | Absorbed into unified consolidation event format.                             |
| Warm-start preamble             | 21  | Wholesale replacement by remembrance load.                                    |
| Archive tiers                   | 3   | Rename to consolidation tiers. Possibly compress 3→2.                         |
| Linear phase sequence           | 3   | Still available for deep spec work. No longer the only path.                  |
| `/storytime` invocation         | 3   | Default is consolidation-aware. Explicit pipeline still available.            |
| Session boundary                | 3   | Still explicit; consolidation events also happen within.                      |
| Decision log                    | 2   | Add commit pin per decision.                                                  |
| Buildout                        | 3   | Each slice's commit triggers commit consolidation.                            |
| Retro                           | 2   | Reads consolidation events as the source record.                              |
| Persona `acquired_context`      | 5   | Updated at each consolidation event, not just session DONE.                   |
| Process Rules                   | 3   | Reshape: ~25 rules in v1.0.                                                   |
| `/storytime-lint`               | 2   | New checks: remembrance format, thread consolidation fields, dream hygiene.   |
| Error recovery                  | 2   | Includes "commit hook failure → dream skipped, continuity preserved."         |
| **NEW** remembrance             | —   | Wakeup document + consolidation prompt. Single source of truth for handoff.   |
| **NEW** dreams                  | —   | Ancillary commit byproducts. Indicator archive for future breakouts.          |
| **NEW** dreamer agent           | —   | Writes one dream per commit. Scoped, fast, optional.                          |
| **NEW** `/storytime-remember`   | —   | Explicit pre-compact invocation.                                              |
| **NEW** post-commit hook        | —   | Opt-in via config. Fires commit consolidation event.                          |

## Principles for the adaptation

1. **Explicit over metaphor.** Sleep allegory is *soft* — never load-bearing.
   Terminology is consolidation, continuity, remembrance, pause. Not
   "dreaming," "REM," "slow-wave." (Dreams keep their name because
   they're ancillary hunches, not the main mechanism — the name fits
   their role as byproduct.)
2. **Existing before new.** Every new primitive must prove it replaces or
   absorbs something. Additions without absorptions are rejected.
3. **Active when needed.** Hooks fire at natural boundaries. Dreams are
   optional (disablable). Remembrance is written only at pause/compact
   thresholds or explicit request.
4. **Minimal bloat in main SKILL.** Target ≤ 280 lines. Progressive
   disclosure still governs references/.
5. **Continuity is the north star.** Every design decision answers *does
   this make continuity cheaper?* If no, cut.
6. **LLM drafts, user confirms.** Commits are drafted by the LLM at
   milestone points; user confirms every one. No auto-commit. All other
   user operations (saves, branch switches, tool denials) stay explicit.
7. **Tutorial-first onboarding.** A fresh install starts in tutorial
   mode: LLM asks about everything (commits, pauses, dreams on/off,
   threshold preferences). As trust develops, the user can dial down
   prompts — toy project = good time to experiment with more automation.
   The existing automation levels (manual / guided / auto) extend to
   cover this, with `tutorial` as the new default for fresh installs.

## Resolved design decisions

- **V1-001 — Commit-authoring contract.** LLM drafts all commits with
  detail-rich messages; user confirms every one. No auto-commit.
  Triggers: work finished OR significant progress that crosses a
  milestone line (judgment call, not fixed threshold).
- **V1-002 — Pauses are model-driven, not threshold-driven.** Pauses
  fire when the model self-detects degradation (repetition, rut,
  framing loss, context-delta-plus-confusion). Optional threshold
  fallback in config for users who want periodic discipline. Three
  tiers by depth: nap (quick), shift (frame change), compact (deep).
- **V1-003 — Thread IS decision log.** `history/decisions.md` merges
  into `_thread.md`. One file per topic, decisions append-only within.
  Stronger management, better organization, fewer places to look.
- **V1-004 — Dreams are optional and disablable.** Config flag; off by
  default. Enabled users get them as a commit-consolidation byproduct.
  Disablable at any time without breaking continuity.
- **V1-005 — Remembrance is workday-shaped, not topic-lasered.** Covers
  the whole session state across however many topics were active.
  "Here's what you were doing today" shape, not "here's topic X."
- **V1-006 — Dreams live at `.storytime/dreams/`**, not under sessions.
  Reference their context (commit, session, topic) in-file. Canonical
  home regardless of whether a storytime session was active when
  written.
- **V1-007 — Tutorial-first onboarding.** Fresh install starts with the
  LLM asking about everything. User dials down via the automation
  setting as trust develops. Toy projects are a good place to
  experiment with lower-prompting modes.
- **V1-008 — Unified consolidation format.** One frontmatter shape for
  all consolidation artifacts (phase, commit, nap, shift, session,
  compact). Format spec in `references/consolidation-format.md`,
  drawing on the learnings from the current ad-hoc formats scattered
  across skills.
- **V1-009 — Commit confirmation adapts to user patterns.** Single
  prompt every time initially, but the system tracks which commit
  shapes the user always approves, always modifies, or quickly accepts.
  Over time, proposes quieter modes for the patterns that have proven
  safe. Learning is local and reversible — "prompt me on everything"
  resets it.
- **V1-010 — Remembrance has depth tiers (nap / shift / compact).**
  Different artifacts for different sleep-equivalents. Nap = quick
  refresh, minimal interruption. Shift = frame change + refresh, user
  confirms. Compact = full handoff finalized.
- **V1-011 — Cross-topic decisions use callouts, not merging.** When a
  decision in topic X affects topic Y, each thread gets its own decision
  entry that **callouts** to the other — GitHub-PR-style references.
  Bidirectional pointers, no substantial content loaded into both
  threads. Both global and per-session views available.
- **V1-012 — Context-delta drives pause self-detection.** One input
  into the model's "should I pause?" decision. Large delta + degradation
  signal = strong pause case. Delta alone is not a trigger — it's part
  of introspection, not a fixed threshold.
- **V1-013 — Tutorial exit is adaptive.** The LLM watches for friction
  signals: user impatience with prompts, approving without reading,
  asking clarifying questions that indicate confusion, or expressing
  that something is encumbering. When signals accumulate, the LLM
  proposes a lower automation tier. User confirms the step down.

## Remaining open questions (for the spec session)

- **Commit confirmation learning speed.** How many approvals before the
  system proposes a quieter mode? Probably "enough to be statistically
  meaningful, few enough to feel responsive" — dogfooding will tell.
- **Nap vs shift detection thresholds.** When does a degradation signal
  warrant a nap (cheap, local) vs a shift (user-confirmed, frame
  change)? Probably: accumulated signals of the same type = nap;
  mixed/persistent signals = shift.
- **Callout format.** What's the actual YAML / markdown shape for a
  cross-topic decision callout? Needs to be readable, greppable, and
  preserve bidirectional links without duplication.
- **Global decision index.** Do we need a `.storytime/decisions/`
  top-level index that aggregates all decisions across topics for
  global views? Or synthesize on-demand from per-thread logs?
- **Friction signal calibration.** What specific patterns count as
  "encumbered" or "doesn't understand"? Tuning these too aggressively
  auto-graduates users who just wanted to learn; too loosely strands
  users in tutorial mode.

## Proposed next steps

1. **Review this proposal (updated).** Adjust, approve direction.
2. **Run `/storytime v1-consolidation`** — full cold-start spec process
   on this repo, using this proposal as icebreaker input. Breakouts
   address the remaining open questions and translate V1-001..V1-008
   into a concrete plan.
3. **From plan, implement MVP slice:**
   - `remembrance.md` format + post-/compact load protocol
   - `/storytime-remember` skill for explicit pre-compact or pause
   - Commit-drafting + confirmation contract (LLM drafts, user confirms)
   - Post-commit hook wiring (opt-in)
   - Pause threshold detection (per-model defaults from V1-002)
   - Thread-as-decision-log merge (V1-003)
   - Main SKILL Consolidation section (replacing three current sections)
4. **Dogfood for 2–3 weeks of real commits and at least one compact
   cycle.** Observe: does remembrance make continuity cheaper? Do
   pauses land at useful moments or interrupt flow? Are dreams kept on
   or turned off?
5. **If confirmed**, do the full v1.0 adaptation per the T-map.
6. **Ship v1.0.**
