---
type: proposal
schema_version: 1
created: 2026-08-31T20:00
name: living-specs-transfer-lifecycle
status: exploration
session: null
---

# Living Specs — a first-class system-as-is surface and the transfer lifecycle

Storytime is an excellent PLAN engine and a poor AS-IS engine. It
captures what a team decided and why — superbly, across breakout →
converge → plan → buildout → retro, threads, dreams, remembrance — but
it has no first-class surface for "what the system currently IS," and no
lifecycle that moves durable truth out of session-shaped docs into a
maintained current-state description. The result, observed in the field:
the as-is picture drifts behind the code while session archives accrete,
and "what is the system now?" becomes archaeology across dozens of
session breakouts plus the code itself.

This proposal adds the missing half: a **living-spec document class**, a
**transfer step** that closes the loop from session to as-is, and a
**drift detector** that makes the as-is library's currency measurable.

## The gap, stated precisely

Storytime's consolidation loop is decision-shaped. Every artifact it
writes answers "what happened, what did we decide, why":

- **Breakouts** are investigations → recommendations. Session-scoped.
- **Threads** are append-only decision logs, commit-pinned. "What we
  decided," in order.
- **Plans** describe one intended change. Ephemeral by design.
- **Buildout traces** map decisions → code. Point-in-time.
- **Retro** compares plan-vs-built. A comparison, not a description.
- **Dreams / remembrance** capture the journey and the wakeup state.

Every one of these is *the right shape for its job* — and none of them is
the shape of "here is the spine subsystem as it exists today: its
invariants, its interfaces, its sealed decisions, what is proven sound
and what is known broken." That document — permanent, present-tense,
kept current — does not exist as a storytime primitive. Projects that
need it invent it ad hoc (see the worked example), and because it is not
a first-class surface with a lifecycle, it rots the moment the code moves
past it.

## Why the existing pieces don't close it

- **Consolidation writes unified artifacts per event** — but they are
  session/decision-shaped snapshots, not a maintained as-is view. Ten
  consolidations about the spine do not sum to a current spine spec;
  they sum to a history a reader must replay.
- **Retro** is the closest existing loop-closer, but it produces a
  *comparison* (plan vs built) and disperses. It does not emit or
  maintain an as-is spec.
- **Threads are decision logs.** Append-only and commit-pinned is
  exactly wrong for as-is: you cannot read the current state off an
  append-only log without folding the whole history in your head — the
  same reason a bank shows a balance, not just a transaction list.
- **A project can bolt on a feature-map/index** (some do), but an index
  of "what exists" is not the specs themselves, and it is a project
  convention, not a storytime surface with a transfer lifecycle behind
  it.

The soul point: storytime treats the *session* as the durable unit. But
the durable unit a maintainer actually needs is the *system-as-is*, and
sessions are how you get there — not the destination. Storytime is
missing the destination as a first-class thing.

## The proposal

### 1. A living-spec document class

Add an explicit as-is document type, distinct from session docs:
`type: spec`, present-tense, one per subsystem/area
(`specs/architecture/<area>.md` in a native layout; the adapter maps it
to a project's convention). It describes the area **as it currently is**:
purpose, architecture, interfaces/contracts, invariants, the sealed
decisions that shaped it (with pointers back to the thread entries that
sealed them, not the rationale re-litigated), and — critically — a
**status ledger**: what is proven sound, what is known broken, what is
unverified. Never future tense; never changelog; never task list (those
are plans/threads). A `feature-map` index over the specs is the entry
point. Storytime-lint gains a spec-shape check (present-tense, has a
status ledger, no future-tense/task-list smells).

### 2. The transfer step (the missing loop-closer)

A new consolidation step — a `storytime-transfer` skill, or a mandatory
phase at buildout/retro completion — that walks a completed session's
durable claims and, for each, MOVES it into the relevant living spec in
the **same commit that lands the code**. A durable claim is anything
still true after merge: a new behavior, a changed invariant, a decision
and its why, a component newly proven sound or found broken, a rejected
approach worth keeping. The session doc is then archived, not deleted —
it remains the provenance; the spec becomes the truth. This is the
storytime-native form of "specs are living, plans are ephemeral": the
plan/breakout was the journey, the spec is where the destination lands.

The transfer step is where a persona (owner/systems for the area) does a
deliberate write — NOT an auto-dump from code. The spec is a human-grade
description a maintainer reads to understand the system; generating it
from the diff would recreate the very "replay the history yourself"
problem this fixes.

### 3. The drift detector

Storytime-status/lint gains a **spec-currency check**: for each living
spec, compare its last-updated commit against git churn in the code paths
it describes (the spec declares its `covers:` globs). A spec older than
the code it covers is flagged as drifted — the as-is library's currency
becomes a measurable, surfaced signal instead of an invisible slow rot.
This is the enforcement that keeps the transfer step from being
skipped: drift is visible in `storytime-status`, so a stale spec is a
lint finding, not a silent lie.

## How it fits the existing loop (nothing removed)

```
  breakout ─▶ converge ─▶ plan ─▶ buildout ─▶ retro
     │            │         │         │          │
   (journey: threads, dreams, remembrance — UNCHANGED)
                                       │
                                       ▼
                              ┌── TRANSFER (new) ──┐
                              │ durable claims →   │
                              │ living specs, same │
                              │ commit as the code │
                              └────────┬───────────┘
                                       ▼
                          specs/architecture/<area>.md   ◀── drift
                          (as-is, present tense,              detector
                           status ledger, feature-map index)  (status/lint)
```

Threads still log decisions. Plans still describe intended change and
still get deleted on merge. Retro still compares. The ONLY additions are
the as-is document class, the transfer step that feeds it, and the drift
check that keeps it honest. Storytime keeps its strength (plan/decision
capture) and gains the half it lacks (a maintained system-as-is).

## Worked example — the kickbox project

Kickbox is a heavy storytime user and the clearest evidence of the gap.
Over a multi-wave buildout (a resident agent: append-only spine, seal,
an engine/scheduler, a trust plane, an action-queue + maintenance role,
GPU lifecycle, substrate-sight digests), the durable truth ended up
living in ~20 session breakouts (`sessions/domovoi/*`,
`sessions/action-queues/*`) — session-shaped decision archives — plus
the code. The project maintained ONE as-is index (a feature-map with an
indicator rule) religiously, which proves the appetite; but
`specs/architecture/` — the actual as-is specs — lagged the code by
several waves. When the system was adversarially reviewed, the review
had to reconstruct the as-is picture from the code, because no living
spec captured "here is the spine / engine / trust plane as it is now."
That reconstruction cost is exactly what a maintained as-is layer buys
back — and exactly what storytime, as-is, does not provide.

Under this proposal, each buildout wave's transfer step would have moved
its durable claims (the single-writer invariant, the bless/grant/area
authority layering, the idle-gate discipline, each component's
proven-sound/known-broken status) into `specs/architecture/{spine,
engine,trust-plane,action-queues}.md` as the code landed. The drift
detector would have flagged the lag after the first wave that skipped
it. The review would have started from the specs.

## Non-goals

- **Not replacing threads/sessions.** Decision/plan capture is
  storytime's strength; it stays. This adds a destination, not a
  substitute for the journey.
- **Not a spec for every change.** Trivial/mechanical changes carry no
  durable claim; the transfer step is a no-op for them. The lint drift
  check only fires on areas that HAVE a living spec.
- **Not a doc generator.** The living spec is a deliberate human-grade
  write by the area's persona, grounded in the code — not an
  auto-summary of the diff.
- **Not future-state.** Living specs are strictly present-tense.
  Roadmaps and intended changes stay in plans/proposals (like this one).

## Phased plan

- **P1 — the document class + lint shape.** Define `type: spec`, the
  status ledger, the `covers:` field; add the storytime-lint shape check.
  Ships value immediately: projects can start writing living specs by
  hand. (Complexity 3.)
- **P2 — the transfer step.** A `storytime-transfer` skill (or a
  buildout/retro completion phase) that walks durable claims and moves
  them into specs in the landing commit; archives the session doc.
  (Complexity 5.)
- **P3 — the drift detector.** The spec-currency check in
  storytime-status/lint (spec last-touched vs `covers:` code churn).
  Makes currency measurable and keeps P2 from being skipped.
  (Complexity 3.)

Sequencing: P1 alone is useful (hand-written living specs + a shape
lint). P2 closes the loop. P3 enforces it. Nothing reaches Complexity 13.

## Open questions (for the storytime team's own breakout)

1. Transfer as a standalone skill vs. a mandatory phase inside
   buildout/retro? (A phase guarantees it runs; a skill is composable.)
2. Should `retro` and `transfer` merge — retro compares plan-vs-built,
   transfer writes the as-is — or stay distinct steps run back-to-back?
3. The `covers:` mechanism for drift: glob paths, or a lighter "areas"
   tag reconciled against a project map? Globs are precise but couple
   the spec to the layout.
4. Native layout puts living specs in `specs/architecture/`; how does the
   adapter model map this onto a project's existing convention without
   forcing a move?
