---
type: breakout
schema_version: 1
created: 2026-04-13T11:35
session: v1-consolidation
episode: 001
topic: v1-consolidation
subtopic: pause-detection
driver: "@operator [tide]"
supporters: ["@critic [lattice]", "@skeptic [drift]"]
supporters_who_spoke: ["@critic [lattice]", "@skeptic [drift]"]
status: complete
---

# Breakout 2 — Pause Detection (Model Self-Signals)

## Problem framing

V1-002 and V1-010 commit us to model-driven pauses over threshold-driven pauses. The proposal (`docs/proposals/v1-consolidation.md:284-304`) names five candidate signals and three tiers (nap / shift / compact), but is intentionally thin on: operational mechanics, tier discrimination, false-positive handling, user-pause composition, and atomic reliability for mid-session remembrance writes.

drift's icebreaker concern (`icebreaker.md:38-41`) is acute: if "model detects degradation" is vibes, pauses become arbitrary. This breakout makes the signals concrete enough that buildout can implement them without re-deciding what "degradation" means.

### What we know
- Pauses are for the model, not the human (`v1-consolidation.md:58-60`).
- Three tiers: nap / shift / compact (`v1-consolidation.md:62-69`).
- Signals named: context-delta, repetition/confusion, rut, framing loss, token budget (`v1-consolidation.md:286-300`).
- Context-delta is one *input*, never a trigger alone (V1-012).
- Optional threshold config is a fallback (`v1-consolidation.md:306-316`).
- Atomic writes are constraint 4 of the icebreaker (`icebreaker.md:108-109`) and built into the error-recovery pattern (`skills/storytime/references/error-recovery.md:141-146`).

### What we don't know (the gap)
- Shape of the self-check: prose rule? Tool call? Structured reflection?
- Signal → tier mapping logic.
- Measurable per-action cost (lattice's domain).
- Whether false-positive pauses leave any learnable signal.

### Exit condition
Signals concrete; mechanism named; tier mapping specified; false-positive plan stated; user/model pause composition defined; atomic write protocol specified.

## Options considered

### Option A — Rule in main SKILL, self-enforced at natural boundaries
Model carries the pause rule in SKILL context and self-applies at each response turn or phase boundary. No extra agent calls.

- **Pros:** Zero per-action cost; uses the model's natural introspection; scales with model capability.
- **Cons:** Depends on prose-rule compliance; no logged "check happened" event; drift's "vibes pauses" concern stays alive if signals aren't crisp.

### Option B — Periodic self-prompt via orchestrator
Every N turns or N tool calls, orchestrator injects a self-check. Model returns a structured judgment; orchestrator routes tier.

- **Pros:** Predictable cadence; auditable; false positives are logged events.
- **Cons:** **Per-action cost** — lattice's dreams objection (`icebreaker.md:52-58`) transplanted. 30-turn session = 30 checks. "Every N turns" *is* a threshold dressed as a check, contradicting V1-002. Users will disable.

### Option C — Hybrid: rule-carried + lightweight markers at phase boundaries (RECOMMENDED)
Self-check rule lives in SKILL (like A), AND at existing consolidation events (phase boundaries, post-commit) the consolidation step writes a one-line `pause_posture` field in its frontmatter. No new boundaries, no polling.

- **Pros:** Uses boundaries that already exist; lattice-safe (zero new per-action cost); drift-safe (signals spelled out and logged); tide-safe (atomic write lands inside existing consolidation tmp+mv); composes with user-proposed pauses; falls back gracefully.
- **Cons:** Couples to V1-008 consolidation format; long ruts between boundaries could be missed (mitigated by Option A style self-enforcement *between* boundaries). One more field for lint.

## Recommendation — Option C

### Concrete signals (finalized)

| Signal | Observable indicator |
|---|---|
| Repetition | Same claim / question / revisit within the current response or last 3–5 turns |
| Confusion | Contradictory context OR a claim without a citable source |
| Rut | ≥ 3 attempts at the same sub-problem without convergence |
| Framing loss | Driver drift without explicit swap OR response without clear lens |
| Context-delta | Large "what happened since last remembrance" footprint (files, decisions, tool calls) |
| Token-budget | (compact tier only) threshold from `v1-consolidation.md:310-316` |

### Operational check mechanism

Pause self-check is a **rule the model carries** (main SKILL), not a scheduled agent call. It fires at three moments:

1. **Between response turns** — model reflects on the just-completed turn; if signal fires, proposes tier next turn.
2. **At phase boundaries** — consolidation event writes `pause_posture: ok | nap-proposed | shift-proposed` into its frontmatter. Non-`ok` pivots the orchestrator.
3. **At post-commit hook** — same field in commit consolidation event. Safety net for runs that didn't cross a phase boundary.

No polling. No every-N-turn prompts. Rule is *carried*; it *fires* at natural boundaries.

### Signal → tier mapping (combination logic, not intensity)

- **Nap** — exactly one signal, localized and recent.
- **Shift** — ≥ 2 signals simultaneously, OR one signal persistent across ≥ 2 phase boundaries, OR framing loss alone.
- **Compact** — token-budget signal (authoritative), OR shift that didn't resolve degradation, OR explicit `/storytime-remember`.

### False-positive handling (data-driven, retroactive)

Every proposed pause logs to the consolidation ledger:

```yaml
pause:
  proposed_at: <timestamp>
  tier: nap | shift | compact
  signals: [repetition, rut]
  user_response: accepted | deferred | rejected
  post_pause_outcome: resolved | persisted | n/a
```

Retro reads this ledger. Patterns like "7 naps last week, 5 deferred, work completed fine" surface as a tuning signal to the user. Cheaper and more honest than trying to prevent false positives at detection time; fits the "failures are data" posture of `error-recovery.md:139-140`.

### User-proposed pauses compose with model-detected ones

1. User says "pause" — same tier-decision path; user specifies tier or model infers.
2. Logged `pause_posture: user-requested` in next consolidation event.
3. If model has an in-flight proposal when user pauses: **user supersedes** and the tier becomes the *higher* of the two (user+nap → shift; user+shift → compact). User intent dominates.

### Atomic remembrance write protocol (tide's non-negotiable)

Every remembrance write — nap, shift, compact — uses tmp+mv per constraint 4 (`icebreaker.md:108-109`) and `error-recovery.md:141-146`:

1. Write `remembrance.md.tmp`.
2. fsync (or equivalent flush).
3. `mv remembrance.md.tmp remembrance.md` — atomic on same filesystem.
4. On failure: `.tmp` is left, `_thread.md` flagged `remembrance_write_failed: <timestamp>`, existing `remembrance.md` untouched.
5. `/storytime-lint` gains a check: orphan `remembrance.md.tmp` older than 5 minutes → lint warning.

**Invariant:** a partial remembrance never replaces a good one.

### Complexity — T = 8

Not a new subsystem. It's a SKILL rule, a field in the V1-008 consolidation format, and reuse of the atomic-write pattern. Hard parts are already solved elsewhere. Genuinely new work: (a) tight signal definitions, (b) wiring `pause_posture` through consolidation format, (c) lint check for orphan `.tmp`. T=8 rather than T=5 because signal thresholds need *actual dogfood testing* (`v1-consolidation.md:519-521`) before we know if the tier mapping is calibrated — that test loop is part of delivery, not an optional follow-up.

### Scale — S = 2 (surfaces touched)

1. `skills/storytime/SKILL.md` — Consolidation section gains pause self-check subsection (~20 lines).
2. `skills/storytime/references/consolidation-format.md` (new per V1-008) — reserves `pause_posture` and `pause` log fields.

Lint gains one check (orphan `.tmp`) — single script edit. No new skill, no new agent, no new hook beyond what V1-002/V1-010 already require.

## Citations

- `docs/proposals/v1-consolidation.md:47-73` — consolidation event table and tier definitions
- `docs/proposals/v1-consolidation.md:284-304` — model-driven pause signals
- `docs/proposals/v1-consolidation.md:306-316` — optional threshold fallback
- `docs/proposals/v1-consolidation.md:318-324` — context-delta staleness check
- `docs/proposals/v1-consolidation.md:432-469` — V1-002, V1-008, V1-010, V1-012
- `docs/proposals/v1-consolidation.md:488-492` — the open question this breakout answers
- `specs/.storytime/sessions/v1-consolidation/001/icebreaker.md:38-41` — drift's vibes-pauses concern
- `specs/.storytime/sessions/v1-consolidation/001/icebreaker.md:52-58` — lattice's per-action-cost precedent
- `specs/.storytime/sessions/v1-consolidation/001/icebreaker.md:68-72` — tide's atomic-write concern, extended from dreams to remembrance
- `specs/.storytime/sessions/v1-consolidation/001/icebreaker.md:104-113` — constraints 2, 4, 5
- `skills/storytime/references/error-recovery.md:14-26` — detect-failure pattern
- `skills/storytime/references/error-recovery.md:141-146` — atomic write + preserve partial rules

## Open questions returned to CONVERGE

1. **Signal sensitivity tuning.** Thresholds ("3–5 turns," "≥ 3 attempts") are first guesses. Dogfood revises. CONVERGE should note these as v1.0 starting values, not baked-in.
2. **Pause-posture field placement in V1-008 format.** Breakout 3 (callout format) may affect this; reconcile at CONVERGE.
3. **Cross-session false-positive learning.** Retro-reads-ledger only works if retros happen. Should `/storytime-lint` surface pause-proposal-deferred patterns proactively? Deferred to CONVERGE.
4. **Interaction with tutorial mode (V1-007).** Tutorial users probably want *every* nap surfaced, contradicting the "may not surface" default (`v1-consolidation.md:62-66`). Breakout 5 (tutorial friction) is the natural owner; flag the dependency at CONVERGE.

## Participants

- **@operator [tide]** (driver) — Drove the recommendation. Insisted on atomic remembrance writes. Framed the pause rule as "carried, not scheduled" to dodge always-on cost.
- **@critic [lattice]** (broke silence) — Objected to Option B on per-action cost grounds. Ruled Option C acceptable (one field on already-scheduled writes, not a new cost center). Silent on tier mapping.
- **@skeptic [drift]** (broke silence) — Verified signal definitions are concrete enough to not be vibes. Pushed back on "intensity" framing; driver adopted combination logic instead. Confirmed scope held to pause detection — no creep into remembrance format beyond the atomic protocol tide already owned.
