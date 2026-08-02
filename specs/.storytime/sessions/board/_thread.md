---
type: thread
schema_version: 1
topic: board
created: 2026-08-02T13:07
last_consolidation:
  scale: session
  event: ABSORB
  at: 2026-08-02T13:07
last_completed_phase: ABSORB
last_commit: 7846522
remembrance_staged: false
remembrance_path: null
open_questions:
  - "heartbeat granularity: which ambient events beyond the six scales fire the fold (every commit? every test run? every N minutes?)"
  - "item update ownership: which persona maintains a given item's freshness (FIX-005 ownership half, v1.2)"
  - "FIX-002 callout target: cites BOARD-006 as authored; substance lives in BOARD-010 — confirm intent or amend"
---

# Thread — board

Topic founded by absorption of an external remembrance
(`remembrance-board-x-storytime.md`, staged 2026-08-02 from a claude.ai
design session, tier: shift). The remembrance is the canonical full text
for BOARD-001..011 and BOARD-P1..P5; entries below are the operative
record. Companion artifacts: widget iteration 3
(`full_project_board_transport_v2_cutover.html`, fixture scenario
"transport v2 cutover" — demo data, not real work) and the Board
Unification Debts section of `BACKLOG.md` (FIX-000..005).

## Episodes

- 000 (ABSORB, 2026-08-02) — full cohort absorbed the board × storytime
  handoff. Eleven external seals recorded (BOARD-001..011), three
  session seals added from accepted warm-load pushback (BOARD-012..014),
  five proposals registered (BOARD-P1..P5; P5 retired by BOARD-012).
  Board debts appended to BACKLOG.md as FIX-000..005. One cross-topic
  tension caught: BOARD-010's fold vs V1-022's no-pre-built-index.
  Ingest commit: 7846522. Seal commit: the commit introducing this
  thread.
- 001 (BUILD, in progress, 2026-08-02) — V1-022 superseded in full
  (BOARD-015, @user: "stateful capture, not hot index"); user-local
  operator state convention sealed (BOARD-016). Buildout begins per
  BOARD-013: schema v0, fold v0 (decisions-first), board.html v0
  against labeled fixture. @user priority: the board is how they stay
  on top of what is actually happening — prose medium is the bottleneck.

## Decisions (append-only, pinned to commit)

_BOARD-001..011 sealed externally (claude.ai design session,
2026-08-02) by @user; absorbed and recorded by the full cohort.
Pinned: 7846522 (ingest commit carrying the canonical remembrance).
Full text: remembrance §Sealed._

### BOARD-001 — Geometry carries meaning
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed

Prose is demoted to handles (labels ≤7 words). Position, depth, lane,
size, and color do the communicating; reading happens only after
seeing has said where to look.

### BOARD-002 — The grammar is frozen and consistent across sessions
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Parent: BOARD-001
  Edge_type: refines

Depth = formedness (surface / forming / bedrock, plus delivery track).
Lanes = kind. Amber = waiting on user. Red = violated, collision, or
blocked. Dashed border = contested (data source: `tensions` edges in
the intent graph). Accent dot = moved since last look. Dashed outline
= candidate. Origin = the roster (@user first-class; probe/CI-born
marked). One legend line must always suffice — a legend past one line
means the grammar is failing.

### BOARD-003 — Loudness budget is spent on deviation only
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Parent: BOARD-001
  Edge_type: refines

Normal is quiet. Waiting-on-user is amber and physically larger.
Cracked bedrock and guardrail blocks are the loudest things that can
exist. A board loud everywhere is silent.

### BOARD-004 — Three zoom altitudes
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Parent: BOARD-001
  Edge_type: refines

Lenses (codebase truth: arch / changed flow / file tree; ascii or
mermaid; togglable, swappable, expandable) → board (work truth) →
drill (item truth). Drill retrieves the canonical `_thread.md` entry;
it never regenerates context from scratch.

### BOARD-005 — Edit-anywhere except derived
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Parent: BOARD-010
  Edge_type: co-implies

Authored fields (titles, bodies, options, claims, directives) are
touch points; edits round-trip through the agent to versioned state.
Derived fields (probe results, counts, budgets, track position) are
read-only. Editing a summary is how boards start lying.

### BOARD-006 — Grounding is dual-polarity
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Callout-> v1.0.1-intent-graph-nascent/V1-032 (depends-on)

Lineage: the intent graph — append-only decisions, commit-pinned,
typed edges. State: probes — claims mechanically re-checked on every
change. Sealed decisions compile into probes via the check-conventions
seam. `get_unrealized` is a first-class alarm: bedrock with no
delivery under it. Claim cards carry the user's verbatim utterance,
dated, plus probe status and audit progress.

### BOARD-007 — The native test governs learning mechanics
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed

No mechanism a flashcard app or a 1990s classroom could ship. Keep
only what exists because an AI collaborator holds the live territory:
belief–reality diffs, decision exhaust, surprises, load-bearing
claims, intervention cues.

### BOARD-008 — Item lifecycle
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Parent: BOARD-002
  Edge_type: refines

candidate → surface → forming → bedrock → delivery track (criteria →
build → PR → review → merged → deployed) → returns to bedrock as an
invariant carrying a probe. Work exits as fact; facts carry probes.
Acceptance criteria are red dots flipped green only by real test
runs; all-green gates entry to the track.

### BOARD-009 — Directives vs guardrails
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Parent: BOARD-003
  Edge_type: refines

Directives: visible standing intent — a rail on the board, authored
and editable, intent-graph nodes (edges: implements / tensions), and
they generate candidates; a directive's chip shows it is alive
("fired 3× this week"). Guardrails: live in agents, probes,
check-conventions; silent while working — an audible guardrail is a
broken guardrail; they surface in exactly one place, the alarm lane,
only on block, attached to the blocked item.

### BOARD-010 — The seam is a control surface
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Tensions: []  # resolved 2026-08-02 — V1-022 superseded by BOARD-015
  Callout-> v1-consolidation/V1-022 (affects)

Read model: one derived state.json — the fold of threads, intent
graph, dreams, adherence, probes into current state; the only thing
the board reads. Command set: seal, add-option, accept-candidate,
edit-item, add-directive, park, request-review — each mapping onto
existing skills and scripts; the board is a client of storytime's
authority, never a fork. Event stream: the six consolidation scales
plus commit, test, and PR events; each triggers fold-then-render.
Contract carries a schema version. Loose-coupling test: board.html
runs against a fixture state.json with storytime absent, degrades
gracefully when a producer supplies less.

Tension (caught at absorb by @domain [arbor]): V1-022 sealed
"on-demand decisions view, no pre-built global index"; the fold is a
pre-built derived index. Resolved same day, ahead of fold v0: @user
sealed BOARD-015 superseding V1-022 in full — "it's not a hot index,
it's a stateful capture."

### BOARD-011 — Append-first
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Callout-> v1-consolidation/V1-028 (related)

Pure additions: board/ directory, fold script, consolidation hook,
schema doc, directives file. Rearrangements require the argument
ledger (BOARD-P1..P3 are the registered rearrangements).

### BOARD-012 — First cut: the board supersedes the /storytime-status surface
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Parent: BOARD-010
  Edge_type: implements

Resolves BOARD-P5 (raised twice in the source session, never ruled;
ruled here from warm-load pushback, accepted by @user). Rationale:
status is the most-seen surface, and BOARD-002's consistency-trains-
the-eye favors training on it; dreams are off by default (V1-004), so
a dreams → candidates tray would render an empty stream and train
nothing; status-as-board exercises the full seam — fold → state.json
→ render — with zero new item kinds.

### BOARD-013 — Fold v0 is decisions-first; identity widens per kind
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Parent: BOARD-010
  Edge_type: implements

Amends FIX-000's "blocks FIX-004" to a partial block. Decisions
already carry identity (TOPIC-NNN) and the intent graph is queryable
(`scripts/intent-graph-query.sh`); fold v0 builds over decisions +
probe/adherence output and proves the seam end-to-end. FIX-000 id
minting for dreams, questions, candidates, and directives lands as
each kind enters the fold — a widening loop, not a big-bang
prerequisite. Sequencing: schema v0 → fold v0 (decisions-first) →
board.html v0 (fixture) → FIX-000 widening.

### BOARD-014 — Stale-belief flags spend the loudness budget
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Parent: BOARD-003
  Edge_type: refines

Resolves the source session's open question (interrupt in the moment
vs batch to session end) by applying BOARD-003 rather than minting
new policy: batch by default; interrupt only when a probe on a claim
touched by the change in flight flips red — which is already in the
loudest-tier. Everything else waits amber at session end.

### BOARD-015 — The fold supersedes V1-022: stateful capture, not hot index
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Parent: BOARD-010
  Edge_type: implements
  Supersedes: V1-022
  Callout-> v1-consolidation/V1-022 (supersedes)

Resolves the tension recorded on BOARD-010 at absorb. @user, verbatim:
"deprecate v1-022, this is the evolution that leaves it behind — its
not a hot index, its a stateful capture." V1-022's bet was against
stale caches masquerading as truth; FIX-004's fold answers it — one
versioned, deterministic, atomically-written artifact owns the
reduction, so the pre-built view is no longer a cache that can drift
but a capture re-folded on every event. V1-032's read-side query
script survives as a reader of the fold's parse layer (anchor's
constraint), not a second parser. V1-022's Status flipped to
superseded in its home thread.

### BOARD-016 — User-specific operator state is local-only
  At: 2026-08-02
  Drivers: @user
  Status: active
  Lifecycle_state: sealed
  Callout-> v1.0.1-intent-graph-nascent/V1-031 (affects)

Anything specific to the individual user never commits:
`cohort/operator-model-*.md`, `cohort/_user.md`, and `intents.md` are
gitignored. What commits is extracted structure — generic templates
built from the personal instances with the personal content removed.
First instance: `cohort/operator-model-user.md` (local only). Template
extraction deferred until the shape stabilizes.

## Proposals (registered, not sealed)

### BOARD-P1 — Stable IDs at creation for every item kind
  Lifecycle_state: focused
  Callout-> (backlog) FIX-000

Rearrangement. Dreams, questions, candidates, directives mint
immutable ids at creation. Next up after fold v0 per BOARD-013.

### BOARD-P2 — Consolidation dual-emits
  Lifecycle_state: proposed
  Callout-> (backlog) FIX-005

Remembrance for the model, state delta for the surface — same event,
same commit.

### BOARD-P3 — Data-first inversion for selected files
  Lifecycle_state: proposed
  Callout-> (backlog) FIX-001 (far)

Which files become data-first with prose rendered from them vs stay
prose-canonical. Decisions and items first; narrative stays prose.

### BOARD-P4 — `directive` as a node type in the intent graph
  Lifecycle_state: proposed

### BOARD-P5 — First cut order
  Lifecycle_state: retired
  Superseded-by: BOARD-012

## Cohort state

Full cohort absorbed; no specialists recruited — material is within
cohort competence. Per-persona reads recorded in `absorption.md`.
Notable: @domain [arbor] caught the V1-022 tension (she drove
V1-022); @operator [tide] extended FIX-004's acceptance with V1-018
atomicity for state.json writes; @skeptic [drift] endorsed BOARD-012
as a removal; @owner [anchor] set the constraint that the fold lands
as a module with a thin CLI wrapper, not a one-off script; @platform
[compass] holds the BOARD-007 native-test line.

## Dreams

(none — dreams_enabled: false)

## Next action

Schema v0 (docs/): items[], directives[], guardrail_blocks[],
candidates[], budget, lenses, teammates; version field from day one.
Then fold v0 per BOARD-013; then board.html v0 against a fixture
labeled as fixture (the widget's "transport v2 cutover" data is demo
fiction — provenance must be marked). Config flips deferred to their
FIX moments: `post_commit_hook: disabled` flips at FIX-003;
`dreams_enabled: false` unchanged until the tray (post-BOARD-012).
