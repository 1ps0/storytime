---
type: thread
schema_version: 1
topic: v1.0.1-intent-graph-nascent
created: 2026-04-25T11:30
last_consolidation:
  scale: session
  event: DONE
  at: 2026-04-25T12:30
last_completed_phase: DONE
last_commit: 5cea39ad
remembrance_staged: false
remembrance_path: null
open_questions: []
---

# Thread — v1.0.1-intent-graph-nascent

## Episodes

- 001 (DONE, 2026-04-25) — minor release shipping three nascent intent-graph
  primitives: user-as-role persona, read-side graph query, adherence
  visualization. Five decisions sealed (V1-031..V1-035).

## Decisions

### V1-031 — User-as-role becomes first-class
  At: 2026-04-25
  Drivers: @owner [anchor]
  Status: active
  Parent: V1-005 (workday-shaped remembrance)
  Edge_type: refines

The user has a lens that drives intents, just as cohort personas do.
Make it visible: `@user [codename]` is a valid persona reference.
Lives at `cohort/_user.md`. `acquired_context` accumulates lens
distribution. Intents extracted to `.storytime/intents.md` (append-only,
opt-in via config).

### V1-032 — Read-side intent graph query
  At: 2026-04-25
  Drivers: @owner [anchor]
  Status: active
  Parent: V1-022 (on-demand decisions view)
  Edge_type: specializes

`scripts/intent-graph-query.sh` exposes read-only operations over the
implicit graph: get_node, get_children, get_parents, get_orphans,
get_unrealized, get_tensions, get_path. Operates on existing
`_thread.md` files; new fields below make it richer.

### V1-033 — Decision frontmatter v2 (intent-graph fields)
  At: 2026-04-25
  Drivers: @owner [anchor], @domain [arbor]
  Status: active
  Parent: V1-008 (unified consolidation format)
  Edge_type: refines

New decisions written under v1.0.1+ may include:
  parent: V1-NNN              # the coarser intent this refines
  edge_type: refines | specializes | implements | co-implies | tensions
  tensions: [V1-NNN]          # symmetric; lint reconciles
  realized_at: <commit-sha>   # promotes sealed → realized
  lifecycle_state: sealed     # proposed | focused | sealed | realized | retired

All fields opt-in. Existing decisions are valid as-is; the graph is
sparse but legitimate.

### V1-034 — Adherence visualization
  At: 2026-04-25
  Drivers: @owner [anchor], @platform [compass]
  Status: active
  Parent: V1-022 (decisions view)
  Edge_type: specializes

`scripts/intent-adherence.sh` renders the sealed-vs-realized grid for
all decisions in a topic (or repo-wide). Status markers per decision:
✓ realized | ◐ partial | · pending. Cheap, ASCII, greppable.

### V1-035 — Lint IG class (mechanical only)
  At: 2026-04-25
  Drivers: @operator [tide], @owner [anchor]
  Status: active
  Parent: V1-029 (pre-flight gate)
  Edge_type: refines

Mechanical-tier lint additions for the intent graph:
  IG1 — every sealed decision with parent: has a resolvable target
  IG2 — every supersedes: has a resolvable target
  IG3 — tensions are symmetric (X tensions Y ↔ Y tensions X)

Reasoning-tier checks (IG4-IG5 for adherence judgments) deferred.

### V1-036 — Prompt yield documents
  At: 2026-04-26
  Drivers: @user, @owner [anchor]
  Status: active
  Parent: V1-031 (user-as-role)
  Edge_type: refines

A complex user ask can become a **prompt-yield document** — the cohort
hydrates it into a structured artifact before any further session work.
@user is the originating driver of the document; cohort personas are
supporters that water the seed by contributing their lens reads.

Lifecycle: seeded → hydrating → maturing → crystallized. Crystallized
form is actionable (feeds a session, a breakout, or becomes its own
deliverable). v1.0.1 establishes the convention via
`references/prompt-yield.md`. Skill (`/storytime-yield` or
`/storytime-hydrate`) deferred to v1.1.

## Cohort state

- @owner [anchor] — drove all 5 decisions
- @domain [arbor] — co-drove V1-033 (info-architecture for graph fields)
- @platform [compass] — co-drove V1-034 (adherence UX)
- @operator [tide] — co-drove V1-035 (lint reliability)

No specialists recruited; scope was small and within cohort competence.

## Next action

v1.0.1 ships with this commit set. Future work in v1.1+:
- Composition / distillation skill (`/storytime-coarsen`)
- Active-attention window viz (needs commit consolidation hook)
- Reasoning-tier IG4-IG5 (drift detection)
