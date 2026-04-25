---
type: proposal
schema_version: 1
created: 2026-04-19T10:00
name: intent-extraction-roles
status: exploration
session: null
---

# Intent Extraction — Role Lens (cross-reference)

Companion to `intent-extraction-user.md`. The same intent-extraction grammar
applied to **the storytime documents themselves** — what intents do roles
drive through breakouts, icebreakers, plans, and other artifacts? Cross-
referenced against the user-intent analysis to answer: do storytime
documents drive intent as much as the user does?

## Method

Each persona-driven utterance in v1-consolidation/001/ classified by intent
type using the same grammar as the user analysis: frame-setting, constraint-
setting, recommend, reject, question, defer.

## Per-document intent harvest

| Doc | Driver | Supporters who broke silence | Intents |
|-----|--------|------------------------------|---------|
| icebreaker.md | @owner [anchor] | all 7 spoke | 8 (each persona's read on the proposal) |
| breakout-1 | @platform [compass] | none | 1 driver intent (Option B + per-repo + shorter-prompt-only) |
| breakout-2 | @operator [tide] | @lattice, @drift | 3 (rule-carried + lattice's Option-B-veto + drift's signal-concreteness) |
| breakout-3 | @domain [arbor] | @forge | 2 (sigil syntax + forge's regex validation) |
| breakout-4 | @domain [arbor] | @drift sustained | 2 (on-demand view + drift's "do we need this") |
| breakout-5 | @platform [compass] | @beacon | 2 (Option D hybrid + beacon's "graduation must be a conversation") |
| breakout-6 | @educator [beacon] | @anchor, @tide | 3 (opt-in script + anchor's clean-break + tide's atomic-rollback) |
| plan.md | @owner [anchor] | (synthesis) | ~10 (sequencing, sealing 17 V1-NNN, decomposing C-13, 7 non-goals) |
| _thread.md | (meta) | — | 0 (record, not intent generator) |

**Total role intents in this session: ~31.** User intents in same session: ~12.

## Tally by role

```
@owner [anchor]      ~11   ████████████████████████████  framing + sealing + sequencing
@platform [compass]  ~5    █████████████  UX-shaped intents (commit + tutorial)
@operator [tide]     ~5    █████████████  reliability constraints
@domain [arbor]      ~5    █████████████  IA + decisions-as-graph reframe
@critic [forge]      ~3    ████████  architecture validation + adversarial
@critic [lattice]    ~3    ████████  cost framing + per-action-cost veto
@skeptic [drift]     ~3    ████████  signal-concreteness + earning-its-keep
@educator [beacon]   ~3    ████████  migration + tutorial-plus framing
```

## User-lens vs role-lens cross-reference

```
                     User    Roles
@owner               11      11
@platform             6       5
@critic               3       6  ← roles cover user's gap (forge + lattice)
@operator             3       5  ← roles add reliability concerns user didn't surface
@domain               1       5  ← roles bring IA depth user couldn't
@skeptic              0       3  ← entirely role-supplied (drift)
@educator             1       3  ← roles cover migration where user was thin
```

**Roles cover what the user doesn't.** The user's strong @owner + @platform
leaves gaps in @critic, @domain, @skeptic, @educator. The cohort fills
exactly those gaps. This is the cohort earning its keep, quantitatively.

## Intent flow analysis

```
USER intent            ROLE intents               ARTIFACT lines
("make it so")         (@owner: sequence)          (the plan.md sections)
                       (@critic: T=13 not T=8)     (breakout 6 decomposition)
                       (@operator: atomic mv)      (V1-018 + script lines)
                       (@drift: "do we need this") (BO4 reshape to Option B)

  ~12 user        →    ~31 role            →       ~3000 artifact lines
                       (~3× multiplier)           (~100× multiplier)
```

**User intents are directional** — they constrain shape (`@role` not skill
triggers, no humans, ship with confidence, swarm it).

**Role intents are substantive** — they fill in *how* (per-repo scope,
edit-distance threshold, sigil syntax, atomic write protocol, six pause
signals).

**Bidirectional flow:** the user's 12 intents → roles surface ~14 questions
or proposals → user resolves → V1-014..V1-030. The icebreaker's 8 concerns
shaped which 5 + 1 breakouts ran. The breakouts' 23 returned open questions
seeded plan.md's roadmap and the v1.1 backlog.

**Verdict: documents drive intent ~3× as much as the user does, by volume,
but in a different register.** User intents are load-bearing for *shape*.
Role intents are load-bearing for *content*. They are complementary, not
competitive.

## What kinds of intent each document type emits

| Document    | Intent type    | Intent grammar |
|-------------|----------------|----------------|
| icebreaker  | divergent      | "Each lens raises a concern" — opens the design space |
| breakout    | focused        | "Here are 3-4 options; we recommend X with rationale" — narrows it |
| plan        | convergent     | "Sequence: M→I→II→...; here are non-goals; success criteria" — commits to a path |
| _thread     | declarative    | "Decision V1-NNN sealed at commit X" — pins to history |
| dream       | speculative    | "Noticed-but-not-said hunch" — preserves potential intent |
| remembrance | imperative     | "Continue at phase X by reading file Y" — instructs the next-self |
| retro       | reflective     | "Promised vs delivered; what we'd change" — measures adherence |

This is structurally significant: **storytime is, among other things, an
intent grammar machine.** Different document types speak different intent
dialects. We have been building this without naming it.

## What fits in scope (not previously named)

22. **Intent statement as breakout frontmatter.** Add
    `intent: "shorter-prompt commit learning, per-repo, 7-of-7"` to each
    breakout's frontmatter. One line. Makes role-intent extraction cheap
    (it is just a grep).

23. **Adherence as a `/storytime-lint` reasoning check.** Estimator agent
    gets new check `IA1`: "for each sealed decision, does evidence in
    commits/code support delivery?" Returns PASS/PARTIAL/DRIFT/FAIL.
    Surfaces under retro.

24. **Attention-window emit point.** Every commit consolidation event
    records `active_intents: [V1-014, V1-018, V1-030]`. Cheap (LLM names
    them at draft time). Then the timeline visualization is just
    `git log --grep` + parse.

25. **Drift class as a lint warning.** ID1: "decision sealed >30 days ago,
    never touched in code." ID2: "decision touched once, then dormant 60+
    days." Advisory.

26. **Intent flow direction in retro.** Retro's evaluation scorecard already
    has plan-vs-built. Add: "of N user intents this session, how many were
    resolved? Of M role intents, how many drove a decision?" Both counts
    normalize the lens-balance question.

27. **Document-as-intent-emitter naming.** This is the conceptual one. The
    reference set should gain `references/intent-grammar.md` — names the
    seven document-types-by-intent-dialect. Codifies what we have been
    doing implicitly. Makes the framework's identity sharper.

28. **The retro becomes an intent-adherence ritual.** Currently retro is
    plan-vs-built. Reframed as intent-vs-action, the retro reads the intent
    ledger (user intents + role intents + sealed decisions) and asks "of
    everything you said you wanted, what shipped, what didn't, why?" Tighter,
    more honest.

29. **Persona evolution weighted by intent yield.** A supporter who broke
    silence twice and both times changed the recommendation has high signal.
    A supporter who never broke silence had a clean leg. A driver whose
    recommendations always shipped is durable. Persona acquired_context
    could carry an "intent-yield" score that shapes future recruitment/
    promotion decisions.

30. **The user-as-persona has a yield score too.** Their intents either get
    resolved or drift. Tracking it isn't surveillance — it is a mirror for
    "did I actually decide what I said I'd decide?"

## Load-bearing reframe

The previous round's reframe (in `intent-extraction-user.md`) was
**user-as-persona**. This round's reframe is **storytime is an intent-flow
system; documents are first-class intent emitters.**

Together they imply: storytime is *not* a spec tool that happens to track
intents. It IS an intent-flow system that happens to produce specs. The spec
is one shape intent takes. Plans, breakouts, decisions, threads, dreams —
all are different shapes of intent at different commitment levels.

## Lifecycle of intent

If the framework is named explicitly:

```
Loose intent       → daydream / dream         → maybe never sealed
Surfaced intent    → icebreaker concern       → may become a breakout
Focused intent     → breakout recommendation  → may become a decision
Sealed intent      → V1-NNN in thread         → committed
Realized intent    → code change              → delivered
Retired intent     → superseded or completed  → archived
```

This is a **lifecycle**. Visualizing it shows where intents are healthy
(loose → realized) and where they pool (sealed → never realized = drift,
or surfaced → never focused = analysis paralysis).

The visualizations in `intent-visualization.md` operate on this lifecycle.
They are not new charts — they are *projections of the intent state machine
onto time, lens, and adherence*.

## Cheapest path to ship (v1.1+)

1. Add `intent:` line to breakout/plan frontmatter (decision V1-031,
   low cost).
2. `scripts/intents-extract.sh` (greps frontmatter, outputs CSV).
3. `scripts/intent-adherence.sh` (cross-references decisions ↔ commits).
4. Surface adherence summary in `/storytime-status`.
5. v1.1+: timeline visualization (see `intent-visualization.md`).

v1.0 needs to first prove the *spec* loop closes. Once dogfood confirms
decisions actually get realized, the intent-tracking layer gives us the
*measurement* of that loop.

## Companion documents

- `intent-extraction-user.md` — user-intent extraction analysis
- `intent-visualization.md` — visualization sketches for adherence and
  active-attention window
- `intent-gradient.md` — coarse/fine structure, typed intent DAG model,
  decomposition vs composition asymmetry
