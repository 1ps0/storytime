---
name: storytime
description: "This skill should be used when the user asks to \"storytime\", \"run storytime\", \"build a spec\", \"assemble a team\", \"persona discussion\", \"design a feature\", \"spec this out\", or wants to plan a feature through structured team conversation with domain-expert personas. Runs the full Storytime workflow: survey codebase, assemble persona team, run icebreaker, execute breakouts, and produce a plan with ASCII visual aids. v1.0+ operates as a continuity system where the spec workflow is one surface on a deeper consolidation loop."
argument-hint: "<problem-statement>"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch]
---

<!-- version-echo: display "storytime v1.0.1" at start of execution -->
# Storytime — Continuity System + Spec Workflow

Storytime is a continuity system for LLM–harness collaboration. The spec
workflow (survey → assemble → icebreaker → breakout → converge → plan)
is one surface. Underneath is the consolidation loop: context →
consolidation events → document structure → continuity across
compactions, sessions, and time.

## Arguments

The user's problem statement: $ARGUMENTS

## Process

Follow this state machine in order, but **collapse phases that have no
real work**. Phase sequence defines the maximum workflow; actual sessions
use only the gears they need.

### Entry: Route

- **No arguments** (bare `/storytime`) → scan `_thread.md` files, present
  a topic picker. Auto-resume if only one thread exists and is incomplete.
- **Arguments provided** → derive `<topic>` (kebab-case) from the problem.
  Check `sessions/<topic>/_thread.md`:
  - Thread found → **Warm entry** (load remembrance if staged)
  - No thread → **Cold Start**

### Warm entry (thread exists)

1. Check `specs/.storytime/remembrance.md` — if present and
   `compact_staged: true`, load it and synthesize as current context.
   See `references/remembrance-format.md`.
2. Read the thread: episodes, decisions, last_consolidation, drift.
3. Compute git delta since `last_commit`; cross-reference with last
   survey fingerprint; check citation staleness.
4. Present "Previously on..." card with options: Continue · Retro ·
   New sub-topic · Reset. Personas skip intros — they speak from
   accumulated context.

### Cold Start (no thread)

Detect landscape: `specs/.storytime/` exists → native; own doc structure →
adapt-in-place; fresh repo → propose native. Ask if ambiguous. Never
create `.storytime/` without user knowledge.
→ Modes and decision tree: `references/output-modes.md`; or delegate
  to `/storytime-bootstrap`.

### Phase 0: SURVEY

Explore agent scoped to problem. Check for prior runs (prior art, never
overwrite). Scan artifacts, classify `[team] [spec] [config]`, present
inventory. Default: consolidate into storytime structure.

Write `sessions/<topic>/survey.md` — codebase context, inventory,
**coverage fingerprint** (REQUIRED: commit, paths, ratios,
classifications). Schema: `schema_version: 1`.

→ Scan targets: `references/artifact-scan.md`; fingerprint:
  `references/survey-fingerprint.md`; non-storytime mapping:
  `references/import-adapters.md`.

### Phase 1: ASSEMBLE

Load cohort from `cohort/_roster.md`. Review team-like artifacts as
rehire candidates. Recruit specialists for uncovered domains.

**Default core:** OWNER, OPERATOR, CRITIC ×2. Additional lenses: DOMAIN,
SYSTEMS, PLATFORM, SKEPTIC, EDUCATOR.

**Team size project-appropriate.** Bias small. Tiny problem → 1-2.
Default core → 3-4. Architectural → 6-8. Ceiling 12 (override).
Duplicate archetypes allowed with distinct focus.

**Codenames non-human** (`anchor`, `lattice`, `kestrel`, `ember`). Role
is load-bearing; codename is ornament. Human names only if user picks.

Write `sessions/<topic>/team.md`.
→ Full detail: `references/team-assembly.md`.

### Phase 2: ICEBREAKER

Introductions. Review prior spec-like artifacts (keep hot / archive
warm / rollup / cold / skip). Establish status quo with code citations.
Identify sub-problems. Agree on constraints.

Write `sessions/<topic>/icebreaker.md`.
→ Artifact tiers: `references/artifact-tiers.md`.

### Phase 3: BREAKOUT (parallel when possible)

For each sub-problem: assign **one driving persona** + 1-2 supporters
(silent unless trigger fires). Pre-breakout synopsis (driver states
plan; supporters state watching brief; user directs approve / join /
defer / pause / cancel). Launch as parallel sub-agent if independent.
Mid-breakout skills: VERIFY, GROUND, RESEARCH, DISCOVERY, PROTOTYPE.
Grounding multi-source — strongest evidence wins.

Write `sessions/<topic>/breakout-<subtopic>.md` per breakout (driver,
supporters, findings, citations, Complexity, Scale, recommendation).

**Post-breakout pause mandatory** (unless auto). Present summary cards
with all options considered, not just recommendations. User directs:
proceed / dig / revise / add.

→ Complexity scale: `references/complexity-units.md`; Scale dimensions:
  `/Users/alexevers/workspace/projects/storytime/docs/scale-impact.md`;
  driver details: `references/driving-persona.md`.

### Phase 4: CONVERGE + PLAN

Reconvene. Merge findings. Resolve conflicts. Each plan section has
one driver.

Write `sessions/<topic>/plan.md`: ASCII slide deck, numbered
implementation steps with breakout cross-refs, code changes summary,
risk matrix, **non-goals** (why skip + when revisit) REQUIRED,
**success criteria** (measurable) REQUIRED, roadmap with Complexity +
Scale per item in prose. Complexity ≥ 13 must decompose.

### Phase 5: REVIEW

Present inline. User challenges, revises, or approves.

### Phase 6: DONE

Update persona `acquired_context`. Log in `history/`. Evaluate
specialist contracts. Finalize thread (append episode, record
`last_commit`, clear open questions).

## Consolidation

Storytime's core loop. Every consolidation event writes a unified
artifact (see `references/consolidation-format.md`). Six scales:

| Scale   | Trigger                                              | Output                                                |
|---------|------------------------------------------------------|-------------------------------------------------------|
| phase   | Phase boundary                                       | Phase artifact + digest appended to thread            |
| commit  | LLM-drafted + user-confirmed commit                  | Thread update + decision pin + optional dream         |
| nap     | Model self-detects 1 signal, localized               | Quick remembrance refresh (may not surface)           |
| shift   | 2+ signals or framing-loss alone                     | Remembrance refresh + proposed frame change           |
| session | Session DONE or walk-away                            | `acquired_context` delta + archive rollup             |
| compact | Token-budget or unresolved shift or explicit request | Remembrance finalized; user confirms `/compact`       |

**Pauses are for the model, not the human.** Signals:
`repetition | confusion | rut | framing-loss | context-delta |
token-budget`. Tier is combination-logic (not intensity):
- **nap** = 1 signal
- **shift** = 2+, persistent, or framing-loss alone
- **compact** = token-budget (authoritative) or unresolved shift

**All remembrance writes are atomic** (tmp + fsync + mv). Orphan
`.tmp` older than 5 min → lint warning.

Remembrance is **workday-shaped** (covers session state across topics),
written at nap/shift/compact, loaded post-`/compact` as first action.
See `references/remembrance-format.md`.

**Commits are the LLM's clock.** LLM drafts every commit; user confirms
every one. No auto-commit. Confirmation learns patterns (V1-014, see
`references/commit-drafting.md`). Explicit stage: `/storytime-remember`.

## Process Rules

1. SURVEY before ASSEMBLE. Never build a team blind.
2. ICEBREAKER before BREAKOUT. Shared understanding first.
3. CONVERGE before showing the user. Internal consensus first.
4. Every claim grounded — code, docs, web, or git.
5. Default core: OWNER, OPERATOR, CRITIC ×2 (two critics contest).
6. Non-goals + success criteria required on every plan.
7. Visuals use ASCII box-drawing. No external tools.
8. Personas are lenses, not characters. No role-play.
9. Team size project-appropriate. Bias small. Ceiling 12.
10. User has veto power everywhere.
11. Phases collapse when empty.
12. Every phase writes output — run is a complete snapshot.
13. Prior runs are prior art — never silently overwrite.
14. Survey writes a coverage fingerprint.
15. Effort = Complexity + Scale (never time). ≥13 decomposes.
16. Evaluation hygiene: observe metrics and conclusions separately.
17. Warm entry detected, not requested. If thread exists, warm.
18. Remembrance is pre-staged (at pause/compact), never reactive.
19. Post-breakout pause mandatory unless auto. Present options considered, not just recommendations.
20. Grounding multi-source: code > git > repo > library > standards > web.
21. `@role` is a lens directive, not a skill trigger. See `references/addressing.md`.
22. Codenames non-human by default.
23. **One driving persona per leg.** Supporters silent unless useful AND non-distortive.
24. LLM drafts every commit. User confirms every one. No auto-commit.
25. Pauses are model-driven, not threshold-driven (threshold is opt-in fallback).
26. All consolidation writes atomic (tmp+fsync+mv). V1-018.
27. Cross-topic decisions use callouts, not merging. See `references/callouts.md`.
28. Thread IS decision log — per-topic, append-only, commit-pinned.
29. Dreams ancillary and disablable. Never on critical path.

## Driving Persona (summary)

One driver per leg. Driver writes artifact, owns recommendation.
Supporters silent unless **useful** (catches miss, grounds claim,
corrects error) AND **non-distortive** (moves leg forward). Silence
from a supporter is information — the driver's lens covered it.
→ `references/driving-persona.md`

## @role Addressing (summary)

`@` is a model attention anchor. `@role` (default), `@role:focus`,
`@role:explain` (teaching), `@role [codename]`. `@role` is a **lens
directive**, not a skill trigger — inline use answered inline by the
current model. Formal QA (persona context + decision log lookup)
via `/storytime-qa`.
→ `references/addressing.md`

## Citations (summary)

Evidence hierarchy: **Code > Git > Repo > Library > Standards > Web**.
Personas reach for strongest available. Ungrounded claims get
challenged ("ground that?"). Web-search proactively for external
systems.
→ `references/citations.md`

## Output Paths (summary)

- **Storytime-native** — `specs/.storytime/` with full tree
- **Adapt-in-place** — writes into existing repo conventions
- **Export-only** — unified plan for another system, no persistent state

→ `references/output-modes.md`

## Conversation Modes

- **Inline** (default): user present, can interject
- **Deliberation**: "go figure this out" → autonomous return
- **QA**: `@persona question` → inline unless formal (see `/storytime-qa`)

## Additional Resources

**Phase-adjacent** (load when phase fires):
- `warm-start.md` · `artifact-scan.md` · `survey-fingerprint.md` ·
  `artifact-tiers.md` · `complexity-units.md` · `team-assembly.md` ·
  `output-modes.md` · `import-adapters.md` · `consolidation-format.md` ·
  `remembrance-format.md`

**Cross-cutting** (load when topic comes up):
- `addressing.md` · `driving-persona.md` · `citations.md` ·
  `error-recovery.md` · `automation.md` · `artifact-types.md` ·
  `evaluation-scorecard.md` · `callouts.md` · `tutorial-signals.md` ·
  `commit-drafting.md`

**Project docs:** `docs/scale-impact.md` · `docs/process-reference.md` ·
`docs/architecture.md` · `examples/agc-session.md` ·
`examples/persona-template.md`

**Related skills:**
- `/storytime-breakout` · `/storytime-converge` · `/storytime-buildout` ·
  `/storytime-bootstrap` · `/storytime-cohort` · `/storytime-echo` ·
  `/storytime-lint` · `/storytime-retro` · `/storytime-remember`
