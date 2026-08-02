# remembrance — board × storytime

staged: 2026-08-02 · source: claude.ai design session (web) · tier: shift
route hint: warm start topic `board`; bootstrap if absent
lint note: idiom matched from README, not from a live .storytime/ — format-lint before ingest

## Where you are waking up

Alex and Claude spent one long session designing a perceptual control surface
("the board") for AI-collaborative production work, prototyped three widget
iterations, then converged on storytime as its data substrate. The unification
is decided in shape: a control surface as the seam, board loosely coupled on
top, storytime evolved to expose that surface first-class. Append-first;
rearrange only where argued.

## The problem this serves — do not lose this

Original driver: dense text does not stick; Alex's mental model of his own
production systems drifts while the agent writes most of the code; steering
must land well and on time. The board exists so perception does work that
reading cannot. Any feature that increases required reading is a regression,
not a feature.

## Sealed — treat as decided; supersede only with argument

BOARD-001 geometry carries meaning
  Prose is demoted to handles (labels ≤7 words). Reading happens only after
  seeing has said where to look.

BOARD-002 the grammar is frozen and consistent across sessions
  Consistency is what trains the eye. Depth = formedness (surface / forming /
  bedrock, plus delivery track). Lanes = kind. Amber = waiting on Alex.
  Red = violated, collision, or blocked. Dashed border = contested — data
  source is `tensions` edges in the intent graph. Accent dot = moved since
  last look. Dashed outline = candidate, not yet accepted. Origin = the
  roster (@user is a first-class persona; probe/CI-born marked as such).
  One legend line must always suffice; if the legend grows past one line,
  the grammar is failing.

BOARD-003 loudness budget is spent on deviation only
  Normal is quiet. Waiting-on-Alex is amber and physically larger. Cracked
  bedrock and guardrail blocks are the loudest things that can exist.
  A board loud everywhere is silent.

BOARD-004 three zoom altitudes
  Lenses (codebase truth: arch / changed flow / file tree, ascii or mermaid,
  togglable, swappable, expandable) → board (work truth) → drill (item
  truth). Drill retrieves the canonical `_thread.md` entry; it never
  regenerates context from scratch.

BOARD-005 edit-anywhere except derived
  Authored fields (titles, bodies, options, claims, directives) are touch
  points; edits round-trip through the agent to versioned state. Derived
  fields (probe results, counts, budgets, track position) are read-only.
  Editing a summary is how boards start lying.

BOARD-006 grounding is dual-polarity
  Lineage: the intent graph — append-only decisions, commit-pinned, typed
  edges. State: probes — claims mechanically re-checked on every change.
  Sealed decisions compile into probes via the check-conventions seam.
  `get_unrealized` is a first-class alarm: bedrock with no delivery under
  it. Claim cards carry the user's verbatim utterance, dated, plus probe
  status and audit progress — Alex's memory is explicitly to be prosthetized
  here.

BOARD-007 the native test governs learning mechanics
  No mechanism a flashcard app or 1990s classroom could ship. Keep only
  what exists because an AI collaborator holds the live territory:
  belief–reality diffs, decision exhaust, surprises, load-bearing claims,
  intervention cues.

BOARD-008 item lifecycle
  candidate → surface → forming → bedrock → delivery track (criteria →
  build → PR → review → merged → deployed) → returns to bedrock as an
  invariant carrying a probe. Work exits as fact; facts carry probes.
  Acceptance criteria are red dots flipped green only by real test runs;
  all-green gates entry to the track.

BOARD-009 directives vs guardrails
  Directives: visible standing intent, a rail on the board, authored and
  editable, intent-graph nodes (edges: implements / tensions), and they
  generate candidates — "look for factoring opportunities" is an intake
  pump whose chip shows it is alive ("fired 3× this week").
  Guardrails: live in agents, probes, check-conventions. Silent while
  working — an audible guardrail is a broken guardrail. They surface in
  exactly one place: the alarm lane, only on block, attached to the
  blocked item.

BOARD-010 the seam is a control surface
  Read model: one derived state.json — the fold of threads, intent graph,
  dreams, adherence, probes into current state. The only thing the board
  reads. Command set: seal, add-option, accept-candidate, edit-item,
  add-directive, park, request-review — each mapping onto existing skills
  and scripts; the board is a client of storytime's authority, never a
  fork. Event stream: the six consolidation scales plus commit, test, and
  PR events; each triggers fold-then-render. Contract carries a schema
  version. Loose-coupling test: board.html runs against a fixture
  state.json with storytime absent, and degrades gracefully when a
  producer supplies less.

BOARD-011 append-first
  Pure additions: board/ directory, fold script, consolidation hook,
  schema doc, directives file. Rearrangements require the argument ledger
  below.

## Proposed — needs Alex or evidence

BOARD-P1 rearrangement: stable IDs at creation for every item kind
  (dreams, questions, candidates — decisions already have TOPIC-NNN).
  The fold and board object permanence both die without identity.
BOARD-P2 rearrangement: consolidation dual-emits — remembrance for the
  model, state delta for the surface.
BOARD-P3 which files become data-first with prose rendered from them,
  versus staying prose-canonical. Tension: markdown-as-database fragility
  vs storytime's ethos.
BOARD-P4 `directive` as a node type in the intent graph.
BOARD-P5 first cut order: replace /storytime-status with the board, or
  ship the dreams → candidates tray. Raised twice, never ruled.

open: stale-belief flags — interrupt in the moment (production stakes) or
  batch to session end (flow). Raised in session, never ruled.
open: heartbeat granularity outside ceremony — which events beyond the six
  scales trigger fold (every commit? every test run? every N minutes?).
open: item update ownership — which persona is responsible for keeping a
  given item's state fresh. One-driver-per-leg governs speech, not
  maintenance.

## Known obstructions — hold these honestly

1. markdown-as-database: the board parsing prose conventions can silently
   lie; the control surface (BOARD-010) is the containment, and P3 is the
   longer-term fix.
2. topic silos: sessions/<topic>/ makes cross-topic state second-class;
   reverse callouts are lint-cached; the fold must be global.
3. ceremony-shaped triggers: drift accumulates between storytime runs;
   the event stream must include ambient work.
4. append-only without a first-class fold: "current" is derived by
   convention; the fold becomes an artifact with a version, not a habit.
5. voice-shaped output: persona conversation is the original complaint;
   the board is the read surface, threads are the record; remembrance
   gains a machine-shaped twin (P2).

## Next actions — first Claude Code session

1. bootstrap topic `board`; absorb this document (/storytime-absorb).
2. write state schema v0 (docs/): items[], directives[], guardrail_blocks[],
   candidates[], budget, lenses, teammates. Version field from day one.
3. implement the fold: script over threads / graph / dreams / adherence /
   probe output → state.json; wire into consolidate.
4. board.html monofile v0 in the house style (markdown/mermaid viewer
   lineage): reads fixture state.json, renders BOARD-002 grammar, commands
   stubbed to skill invocations.
5. directives rail v0 + guardrail block → alarm path.
6. /storytime-retro board against this document.

## Artifacts from the source session — not transferable, re-derivable

- skill-scout SKILL.md (packaged, installable): ambient observer logging
  skill opportunities; its seven signals fold into dreams/candidates intake.
- widget iteration 1: strata board (depth/lanes/glow grammar).
- widget iteration 2: decision lens (options grid; solid dot = measured
  fact with pointer, hollow = judgment; user-added options) and claim card
  (verbatim claim + probe + audit dots + cracked-state alarm preview).
- widget iteration 3: full project board — lens strip, candidates tray,
  strata, delivery track, teammate rails with collision, budget strip
  (review debt as first-class currency), drill-down editor.
  All specs live in BOARD-002 through BOARD-008; the html is disposable.

## Tone for the next driver

Alex wants pushback, not agreement. No classroom pedagogy survives the
native test. Loudness is rationed. Append before rearrange. The user is
always right about intent; the code is always right about state; the
board exists to show each one the other.
