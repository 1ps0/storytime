---
type: breakout
schema_version: 1
created: 2026-04-26T14:25
session: cross-platform-port
episode: 001
subtopic: mvp-soul-elements
driver: "@owner [anchor]"
supporters: ["@skeptic [drift]", "@critic [forge]"]
supporters_who_spoke: ["@skeptic [drift]", "@critic [forge]"]
status: complete
---

# Breakout 3 — MVP Soul Elements (Tiering the 10)

## Question

The cross-platform proposal lists 10 "soul priorities" — concepts that
must come through to the OpenCode adapter for the port to count as a
paradigm extension rather than a thin translation. The proposal's
recommendation (`docs/proposals/cross-platform-storytime.md:333-335`)
puts items 1, 2, 3, 5, 7 in the minimum set; the icebreaker constraint
(`icebreaker.md:96-97`) ratifies that as a working assumption.

This breakout's job: ratify or revise that tiering with explicit,
item-by-item rationale, identify any composites that should split,
and produce a day-one deliverable per item.

The two challenges driving the breakout:
- `@skeptic [drift]`: "If we cut to MUST-only, what does the OpenCode
  adapter v1 actually look like?"
- `@critic [forge]`: "Are any of these items secretly composites that
  should split into 2-3?"

## Findings

### Calibrating "soul"

`@owner [anchor]`: SKILL.md line 9 names what soul is —

> "Storytime is a continuity system for LLM–harness collaboration. The
> spec workflow (survey → assemble → icebreaker → breakout → converge
> → plan) is one surface. Underneath is the consolidation loop:
> context → consolidation events → document structure → continuity
> across compactions, sessions, and time."

So soul = continuity-system + spec-workflow over personas-as-lenses. The
proposal frames the adapter as paradigm extension, not translation
(`cross-platform-storytime.md:27-29`). That raises the bar on MUST: not
"behaves like storytime" but "feels like storytime to an OpenCode user
who's never used Claude Code."

### The differentiator test (forge's frame for MUST)

`@critic [forge]`: For each item, ask — without this, is the adapter
still recognizably storytime, or is it just "OpenCode with markdown
loaded"? If the latter, MUST. Otherwise, lower-tier.

### The cut-to-MUST experience (drift's frame)

`@skeptic [drift]`: For each item that lands MUST, what does day-one
delivery cost? The smaller the cost, the easier to keep at MUST. Items
that don't make MUST should still give the user something *value-add*
relative to default OpenCode — otherwise drop them entirely.

### Composite decomposition (forge's frame for splits)

`@critic [forge]`: Most of the 10 items are composites. The split-or-not
choice for each:

| Item | Composite? | Decomposition |
|------|-----------|---------------|
| 1 | yes | (a) ephemeral spawn capability, (b) lifecycle (hire/fire/bench), (c) acquired_context across sessions |
| 2 | atomic | the principle of one-driver-per-leg |
| 3 | yes | 6 scales: phase, commit, nap, shift, session, compact |
| 4 | yes | (a) frontmatter v2.1 fields, (b) read-side queries, (c) callouts as edges |
| 5 | yes | (a) frontmatter conventions, (b) V1-NNN IDs, (c) callouts, (d) artifact types |
| 6 | yes | (a) phase-collapse rule, (b) tutorial mode, (c) automation tiers |
| 7 | yes | (a) inline lens behavior, (b) @role:focus, (c) @codename resolution, (d) paradigm-extension interception |
| 8 | atomic | already a split sub-pattern of #2 |
| 9 | atomic | generation-time default |
| 10 | yes | (a) remembrance, (b) thread checkpoints, (c) callouts — but emergent from items 3 and 5 |

Splits taken into account in day-one deliverable per item (Phase 1 of
the adapter delivers the MUST sub-elements only; full composites land
in v1.1+).

### Item-by-item tiering

#### Item 1 — Personas as fluid lenses, not static agents — **MUST**

`@owner`: This is THE differentiator. OpenCode's static agent system is
exactly what storytime extends. If personas are static, the adapter is
"OpenCode with prettier names."

`@drift`: Cut-test: without ephemeral spawn (item 1a), the adapter has
nothing material to offer over default OpenCode. Day-one MUST = (a)
only. (b) lifecycle and (c) acquired_context can land in v1.1.

Day-one deliverable: persona runtime layer in `plugin.ts` that wraps
OpenCode's static `Agent` system; `@role:codename` resolution that
creates an ephemeral context without `opencode.json` edit
(`cross-platform-storytime.md:96-99,111-115`).

#### Item 2 — Driver-per-leg discipline — **MUST**

`@owner`: `references/driving-persona.md` is explicit: "exactly one
persona drives" at every leg. This is the conversation discipline that
prevents round-robin and is named in process rule 23 of SKILL.md.

`@drift`: Cut-test: without it, the adapter can claim "personas" but
every multi-persona discussion devolves to round-robin. The
conversational cut-through gain disappears. MUST.

Day-one deliverable: the OpenCode `chat.message` hook stamps current
driver into the system prompt per leg; breakout dispatch passes driver
as plugin state.

#### Item 3 — Consolidation loop (six scales) — **MUST (scoped)**

`@owner`: This is the *spine* of v1.0+. SKILL.md positions this as the
foundation — the spec workflow is one surface, the consolidation loop
is the underneath.

`@forge`: Composite — six scales. Day-one MUST is **phase + compact +
session** (three of six). Commit/nap/shift can ship in v1.1. The
sophistication of pause-detection is finishing-touch.

`@drift`: Cut-test on the full 6: if we ship only phase + compact +
session, the user still gets the continuity story. Walk away, come
back, find a remembrance. Walk through phases. Close session. That's
soul-preserving even without nap/shift detection.

Day-one deliverable: `experimental.session.compacting` hook writes
remembrance.md atomically (tmp+fsync+mv per V1-018); phase artifacts
are written with consolidation-format frontmatter
(`references/consolidation-format.md:14-35`); session-DONE writes
archive rollup.

#### Item 4 — Intent graph (decisions as typed DAG) — **CAN-DEFER**

`@owner`: V1.0.1 just shipped this. It's nascent — sparse but
legitimate. References explicitly defer write-side mutations and
composition to v1.2+.

`@forge`: Composite — (a) frontmatter v2.1 fields, (b) read-side query
script, (c) callouts as cross-topic edges. (a) is markdown convention
(adapter-portable for free, rides on item 5). (b) is bash script
(already adapter-agnostic per `icebreaker.md:50-51` — operates on
`specs/.storytime/`). (c) is also markdown convention (rides on item 5).

`@drift`: Cut-test: an OpenCode user can ship without ever using
`parent:` field. The graph is sparse-but-legitimate even on Claude
Code today. Day-one delivery for the adapter is "the convention works
when the user uses it." No adapter-specific code needed.

Day-one deliverable: nothing beyond item 5's frontmatter pass-through;
v1.1 adds OpenCode-specific decision-pinning UI if dogfood demands it.

#### Item 5 — Narrative grammar (markdown frontmatter) — **MUST**

`@owner`: This is the actual storage format for everything storytime
produces. Without this, no breakouts, no plans, no threads, no
decisions — just free-form markdown.

`@forge`: Composite — (a) frontmatter conventions (schema_version: 1,
type: ...), (b) decision IDs (V1-NNN), (c) callouts (`Callout->`/
`Callout<-`), (d) artifact types. All four are markdown conventions —
adapter only needs to *generate* and *consume* them, not interpret
semantically. Bundle them as one MUST.

`@drift`: Cut-test: if the adapter doesn't write breakouts in this
grammar, the shared corpus across adapters disappears. Lint scripts
break. Cross-topic callouts break. MUST — and this is the cheapest
MUST because the adapter mostly has to just NOT FIGHT IT.

Day-one deliverable: skill prompts in OpenCode produce frontmatter-
prefixed markdown; the unified consolidation shape is enforced; lint
scripts in `shared/lint/` work across adapter outputs.

#### Item 6 — Gearbox principle (phases collapse, automation tiers) — **CAN-DEFER**

`@owner`: This is a *runtime behavior* — phases that have no real work
get skipped. The skill text is explicit: "collapse phases that have no
real work" (SKILL.md Process line 24).

`@forge`: Composite — (a) phase-collapse rule (markdown-rule, adapter-
portable for free), (b) tutorial mode (needs new-user detection), (c)
automation tiers (runtime config story).

`@drift`: Cut-test: an adapter that always runs full ceremony is
annoying but functional. (a) rides for free as a SKILL.md rule. (b) and
(c) can wait. Defer the explicit work; ride (a) for free.

Day-one deliverable: none required beyond inheriting the SKILL.md
collapse rule via the shared core/lifecycle/ content; v1.1 adds
tutorial mode and automation-tier config.

#### Item 7 — `@role` as a lens directive — **MUST**

`@owner`: `references/addressing.md` is explicit — `@role` is a lens
directive, not a skill trigger. This is the *cheap* tactile feature
that makes storytime feel different from agent dispatch.

`@forge`: Composite — (a) inline lens behavior in the model, (b)
`@role:focus` qualified addressing, (c) `@codename` resolution to role
via roster, (d) interception of `@codename` not in `opencode.json`.
(a) and (b) are prompt-shaped. (c) and (d) need plugin code (the
`chat.message` hook intercepts and rewrites the prompt).

`@drift`: Cut-test: without (a), the model wouldn't know to apply
`@critic look at this function` as a lens — it'd try to dispatch a
non-existent agent. This is the most user-visible soul element. MUST.

Day-one deliverable: plugin's `chat.message` hook intercepts `@role`
and `@role:codename`, registers ephemeral context if not in
`opencode.json`; system prompt teaches the inline-lens behavior per
addressing.md.

#### Item 8 — Driver-per-leg + supporters-silent-unless-useful — **MUST**

`@owner`: This is the *runtime conversation pattern* that
operationalizes item 2. Item 2 is the principle ("one driver"); item 8
is the supporter discipline ("silent unless useful AND non-distortive"
per `references/driving-persona.md:13-26`).

`@forge`: Already a split sub-pattern. The proposal flagged this
explicitly. Splits no further. **But — does it warrant separate MUST
status from item 2?** Yes: item 2 without item 8 = "driver writes" but
supporters still chatter. Item 8 is what *prevents* round-robin in
practice. Same MUST gravity, lighter cost — it's a system-prompt
addendum, not new plugin code.

`@drift`: Cut-test: if item 2 ships (driver stamped) but item 8 is
deferred, the adapter ships with personas chiming in randomly. The
*experience* of cutting through to a coherent recommendation is lost.
MUST.

Day-one deliverable: the same `chat.message` system prompt that stamps
driver also includes the six concrete supporter triggers from
`driving-persona.md:36-53`. Zero additional plugin code beyond item 2.

#### Item 9 — Codenames non-human by default — **SHOULD**

`@owner`: From `team-assembly.md:103-109`, codenames invite reasoning;
human names invite role-play. This is a generation-time default, not
runtime behavior.

`@forge`: Atomic — single concept. No further decomposition.

`@drift`: Cut-test: a persona named `Sarah` works just as well at
runtime as `anchor`. The behavioral difference is upstream — at the
moment of *creating* personas. The adapter teaches this default in its
persona-generation prompts: literally three lines of system prompt.
SHOULD because it's so cheap that cutting it is silly, but skipping it
doesn't break the adapter. Bundle with item 1's persona runtime.

Day-one deliverable: persona-generation prompts in the adapter favor
codenames (`anchor`, `lattice`, `kestrel`...); user override always
allowed.

#### Item 10 — Continuity is cheap — **CAN-DEFER**

`@owner`: This is the *experience claim* that comes from item 3
(consolidation) + item 5 (narrative grammar) + the remembrance.md
format. It's a user-visible promise, not a separate work item.

`@forge`: Heavy composite — (a) remembrance writes atomically, (b)
thread checkpoints (commit-pinned), (c) callouts cross-reference. (a)
is item 3's compact-scale output. (b) is item 3 again. (c) is item 5.
**Item 10 is emergent — it's how we test items 3 and 5 working
together.**

`@drift`: Cut-test: if items 3 and 5 ship as MUSTs, item 10's behavior
emerges. There is no separate adapter code. The "walk away and return"
test is a Phase 4 dogfood criterion, not an adapter feature.

Day-one deliverable: nothing — emergent property tested in Phase 4
dogfood. Walk away from a session, run `/compact`, return, verify
re-entry costs near-zero. Pass = items 3 and 5 are correctly delivered.

### Cut-to-MUST adapter v1 picture (drift's recurring challenge)

If we ship MUST-only, an OpenCode user installs
`@storytime/opencode-plugin`, types `/storytime cross-platform-port`,
and gets:

1. A persona runtime where `@critic [lattice] look at this function`
   works without static `opencode.json` registration — paradigm
   extension. (item 1)
2. Driver/supporters stamped per leg in system prompt; supporters know
   when to stay silent. (items 2 + 8)
3. Phase artifacts written with frontmatter to
   `.storytime/sessions/<topic>/` per the consolidation format. (items
   3 + 5)
4. `/compact` intercepted; `remembrance.md` staged automatically;
   loaded post-compact as first action. (item 3)
5. Session DONE writes archive rollup. (item 3)
6. `@role` works inline as lens directive everywhere. (item 7)

That is recognizably storytime. The differentiator test passes: this
is meaningfully different from "OpenCode with markdown loaded."

What the user does NOT get day one (deferred to v1.1+): nap/shift
auto-pause detection, intent-graph frontmatter v2.1 in OpenCode-
generated artifacts (still works if user hand-writes), tutorial mode,
automation tier config beyond default.

### Composite-split summary (forge's recurring challenge)

Items found compound and scoped down for day-one:

- **Item 1** — keep ephemeral spawn (a); defer lifecycle (b) and
  acquired_context (c) to v1.1
- **Item 3** — keep phase + compact + session; defer commit + nap +
  shift to v1.1
- **Item 7** — all four sub-behaviors needed at MUST (lens + focus +
  codename-resolve + paradigm-extension)

Items 5 and 8 are also compounds but bundle as single deliverables.
Items 2 and 9 are atomic.

## Recommendation

**Tier the 10 soul priorities as follows:**

| # | Item | Tier |
|---|------|------|
| 1 | Personas as fluid lenses | **MUST** |
| 2 | Driver-per-leg discipline | **MUST** |
| 3 | Consolidation loop (six scales) | **MUST** (scoped: phase + compact + session) |
| 4 | Intent graph | **CAN-DEFER** |
| 5 | Narrative grammar | **MUST** |
| 6 | Gearbox principle | **CAN-DEFER** |
| 7 | `@role` as lens directive | **MUST** |
| 8 | Driver-per-leg + supporters-silent | **MUST** |
| 9 | Codenames non-human default | **SHOULD** |
| 10 | Continuity is cheap | **CAN-DEFER** (emergent from 3+5) |

**Net change from proposal recommendation (1, 2, 3, 5, 7):**
- **Add item 8 to MUST** — runtime supporter discipline is the
  mechanism that operationalizes item 2; deferring it loses the
  "cut-through" experience. Cost is zero (system-prompt addendum to
  item 2).
- Item 9 to SHOULD (cheap, ships with item 1's persona runtime).
- Items 4, 6, 10 explicitly tiered as CAN-DEFER with rationale.

**MUST count: 6** (items 1, 2, 3-scoped, 5, 7, 8).
**SHOULD count: 1** (item 9).
**CAN-DEFER count: 3** (items 4, 6, 10).

This tiering preserves the proposal's core (1, 2, 3, 5, 7) and adds the
single high-value, near-zero-cost addition (item 8) that the cut-to-
MUST cross-examination revealed.

## Confidence

**High** — the tiering is consistent with the proposal recommendation,
the icebreaker constraint, and SKILL.md's calibration of soul. The one
addition (item 8 to MUST) is grounded in the runtime mechanism reading
of `references/driving-persona.md` and survives the
"is-it-still-storytime-without-this" test by the differentiator
criterion.

Lower confidence on item 3's scope cut: nap/shift auto-detection is
clearly v1.1, but the boundary between "commit-scale consolidation
needed at v1" vs "v1.1" is judgment. Recommendation: ship v1 with
phase + compact + session and let dogfood (Phase 4) reveal whether
commit-scale consolidation is missed.

## Effort Estimate

- **Complexity:** ~13 — substantial scope. Persona runtime in TS
  (~5), `chat.message` hook with system-prompt scaffolding for items 2
  + 7 + 8 (~3), `experimental.session.compacting` hook writing
  remembrance with atomic semantics (~3), session-DONE archive rollup
  (~2). The TS plugin work for item 1 alone is several days; the rest
  is more contained.
- **Scale:** ~3 dimensions × medium — (1) plugin code surface in
  `adapters/opencode/plugin.ts`, (2) system-prompt content shipped
  with the plugin teaching the conversation rules, (3) artifact format
  emitters that write to `.storytime/sessions/`. Medium breadth across
  hooks (3-4 hook points), narrow depth per hook.

## Citations

- `docs/proposals/cross-platform-storytime.md:32-83` — the 10 soul
  priorities source list (proposal author's recommendation 1, 2, 3, 5,
  7 at line 333) (repo doc)
- `docs/proposals/cross-platform-storytime.md:27-29` — paradigm
  extension framing that raises the bar for MUST (repo doc)
- `docs/proposals/cross-platform-storytime.md:96-115` — what the
  OpenCode adapter looks like when the persona runtime, driver
  context, breakouts, compaction, and `@role` flexibility all ship
  (repo doc)
- `specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:96-97`
  — prior constraint declaring 1, 2, 3, 5, 7 non-negotiable for OpenCode
  MVP (this session, prior phase)
- `skills/storytime/SKILL.md:9` — the soul calibration (continuity
  system + spec workflow surface) (code)
- `skills/storytime/SKILL.md:23-24` — gearbox principle as Process
  rule (code)
- `skills/storytime/SKILL.md:194` — process rule 23 (one driver per
  leg, supporters silent unless useful AND non-distortive) (code)
- `skills/storytime/references/driving-persona.md:13-26` — the
  silent-unless-useful + non-distortive supporter discipline that
  makes item 8 a distinct deliverable (code)
- `skills/storytime/references/driving-persona.md:36-53` — the six
  concrete supporter trigger conditions that day-one ship as
  system-prompt content (code)
- `skills/storytime/references/team-assembly.md:103-109` — codenames
  non-human rationale for item 9 (code)
- `skills/storytime/references/addressing.md:68-103` — `@role` as
  lens directive, not skill trigger; multi-lens behavior (code)
- `skills/storytime/references/consolidation-format.md:14-35` — the
  unified frontmatter shape that item 3 + item 5 deliver together
  (code)
- `skills/storytime/references/consolidation-format.md:130-138` —
  atomic write protocol (V1-018) for remembrance writes (code)
- `skills/storytime/references/intent-graph.md:14-32` — intent-graph
  model showing nascent / sparse-but-legitimate v1.0.1 state that
  justifies CAN-DEFER for item 4 (code)
- `skills/storytime/references/intent-graph.md:122-152` — write-side
  and composition explicitly deferred to v1.2+, supporting CAN-DEFER
  for item 4 (code)
- `skills/storytime/references/remembrance-format.md:7-30` — the
  workday-shaped wakeup document that item 10's continuity claim
  rests on (code)
- `skills/storytime/references/callouts.md:7-54` — callouts as the
  cross-topic edge mechanism that item 10 leans on (rides on item 5)
  (code)
- commit `0e34425` — "v1.0.1 — Nascent intent graph + user-as-role +
  prompt-yield" — the just-shipped state of item 4 (git)

## Open Questions

- Where does the adapter-shipped persona-cohort state actually live in
  OpenCode runtime? Plugin closure vs SQLite annotation vs flat files
  in `.storytime/cohort/`. **Owner: Breakout 4 (Persona runtime in TS
  for OpenCode)**.
- For item 3's scoped MUST (phase + compact + session, deferring
  commit + nap + shift): does deferring commit-scale consolidation
  risk losing the "commits are the LLM's clock" property (process
  rule 24) for OpenCode users? **Owner: Phase 4 dogfood (Phase 4 of
  proposed plan).**
- For item 4 (intent graph CAN-DEFER): does deferring explicit
  adapter UX for decision pinning until v1.1 hurt OpenCode adoption?
  **Owner: Phase 4 dogfood.**
- For item 9 (SHOULD): is there any case where SHOULD silently
  becomes "did not ship"? Recommendation: bundle with item 1's MUST
  to eliminate the risk — three lines of prompt.

## Participants

- `@owner [anchor]` (driver) — owned the soul calibration via SKILL.md
  reading; called the differentiator test; wrote the
  recommendation.
- `@critic [forge]` (supporter who spoke) — challenged composites
  throughout; surfaced that items 1, 3, 5, 6, 7, 10 are all
  compounds; scoped the day-one deliverables for items 1 and 3;
  caught that item 8 is split-from-2 deliberately, not redundant.
- `@skeptic [drift]` (supporter who spoke) — challenged cut-to-MUST
  on every item; ran the "what does adapter v1 actually look like
  with only MUSTs?" test; argued item 4 / item 6 / item 10 are
  CAN-DEFER without harming the soul claim.

## Final Summary Table

| # | Item | Tier | Rationale (1-2 sentences) | Day-one deliverable |
|---|------|------|---------------------------|---------------------|
| 1 | Personas as fluid lenses, not static agents | **MUST** | The differentiator. OpenCode's static agent system is exactly what storytime extends; without ephemeral spawn, the adapter is "OpenCode with prettier names." | Persona runtime in `plugin.ts` wrapping OpenCode `Agent`; `@role:codename` resolution creates ephemeral context without `opencode.json` edit. |
| 2 | Driver-per-leg discipline | **MUST** | The conversation discipline that prevents round-robin. SKILL.md process rule 23. | `chat.message` hook stamps current driver into system prompt per leg; breakout dispatch passes driver as plugin state. |
| 3 | Consolidation loop (six scales) | **MUST (scoped)** | The continuity spine — SKILL.md positions this as the foundation. Day-one ships three scales (phase + compact + session); commit/nap/shift land in v1.1. | `experimental.session.compacting` hook writes `remembrance.md` atomically; phase artifacts emit consolidation frontmatter; session-DONE writes archive rollup. |
| 4 | Intent graph (decisions as typed DAG) | **CAN-DEFER** | Just shipped at v1.0.1; nascent and sparse-but-legitimate. The frontmatter convention rides for free with item 5; bash query scripts already adapter-agnostic. | None beyond item 5 frontmatter pass-through; v1.1 adds OpenCode-specific decision-pinning UI if dogfood demands. |
| 5 | Narrative grammar (markdown frontmatter) | **MUST** | The actual storage format for everything storytime produces — without it, the cross-adapter shared corpus disappears and lint scripts break. Cheapest MUST: the adapter mostly has to NOT FIGHT IT. | Skill prompts produce frontmatter-prefixed markdown; unified consolidation shape enforced; lint scripts work cross-adapter. |
| 6 | Gearbox principle (phases collapse, automation tiers) | **CAN-DEFER** | Phase-collapse rides for free as a SKILL.md rule via shared core. Tutorial mode and automation tiers are nice-to-have, not soul-defining. | None beyond inheriting the SKILL.md collapse rule via core; v1.1 adds tutorial mode and automation tier config. |
| 7 | `@role` as a lens directive | **MUST** | The cheap tactile feature that makes storytime feel different from static agent dispatch. Without inline-lens, `@critic look at this function` would try to dispatch a non-existent agent. | `chat.message` hook intercepts `@role` and `@role:codename`; system prompt teaches inline-lens behavior per `addressing.md`. |
| 8 | Driver-per-leg + supporters-silent-unless-useful | **MUST** | Item 2 without item 8 = drivers labeled but supporters still chatter. Operationalizes item 2; near-zero cost (system-prompt addendum). | Same `chat.message` system prompt also includes the six concrete supporter trigger rules from `driving-persona.md`. Zero additional plugin code beyond item 2. |
| 9 | Codenames non-human by default | **SHOULD** | Atomic generation-time default. Cheap to include (three lines of prompt) and consistent with team-assembly.md, but skipping doesn't break the adapter. Bundle with item 1. | Persona-generation prompts favor codenames; user override always allowed. |
| 10 | Continuity is cheap (remembrance + thread checkpoints + callouts) | **CAN-DEFER** | Not a separate work item — emergent from items 3 and 5 done correctly. The "walk away and return" test is a Phase 4 dogfood criterion, not adapter code. | None — verified in Phase 4 dogfood when items 3 and 5 ship. |
