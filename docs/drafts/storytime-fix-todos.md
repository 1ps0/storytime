# storytime major fixes — board unification debts

status: proposed backlog entries · source: claude.ai design session 2026-08-02
placement: append to BACKLOG.md, or stand alone as docs/proposals/board-surface-fixes.md
cross-refs: BOARD-NNN ids live in remembrance-board-x-storytime.md (topic `board`)
lint: sigil and frontmatter syntax approximated from README — normalize on ingest

severity: blocking = the board cannot be trusted until fixed ·
structural = the board works but degrades or lies at the edges

---

## FIX-000 · stable identity at creation
prerequisite · rearrangement · Callout-> board/BOARD-P1

problem: only decisions carry ids (TOPIC-NNN). dreams, questions,
candidates, and directives are anonymous prose blocks.

consequence: no fold can track an item across events; the board loses
object permanence — items teleport instead of migrate, which destroys
the perceptual training the whole grammar exists to produce.

fix: every item kind mints an immutable id at creation (topic-scoped
counter or ulid). ids are never reused and never renamed.

acceptance: lint fails on any id-less item; two folds spanning a
retitle resolve to the same id.

target: v1.1 — blocks FIX-001, FIX-002, FIX-004.

---

## FIX-001 · markdown-as-database
blocking · containment is append, full fix is rearrangement ·
Callout-> board/BOARD-010, board/BOARD-P3

problem: truth is stored as prose conventions — sigil lines, ascii
boxes, frontmatter — and read back by grep. format drift is a live
threat; the lint exists because of it.

consequence: a truth surface that parses prose can silently lie. one
off-format persona line and an item drops or misstates. a board that
can lie is worse than no board.

fix, near (append): the board reads only the derived read model
(state.json). zero grep of session markdown anywhere in the board
path. the fold owns all parsing and fails loudly — it never emits
partial state.

fix, far (rearrangement): BOARD-P3 — invert selected files to
data-first with prose rendered from them. decisions and items first;
narrative (breakouts, icebreakers, dreams) stays prose-canonical.

acceptance: board.html renders from a fixture state.json with the repo
absent; the fold on malformed input exits nonzero with file and line,
never partial output.

target: near v1.1 · far v1.2+.

---

## FIX-002 · topic silos vs the global glance
structural · Callout-> board/BOARD-006

problem: sessions/<topic>/ makes cross-topic state second-class;
reverse callouts are lint-cached, i.e. eventually consistent.

consequence: collisions, tensions, and shared bedrock live between
topics — exactly what the board must show first. the global glance is
the product.

fix: the fold is global by construction — one state.json across all
topics. reverse callouts are materialized inside every fold run; the
lint cache is demoted to an optimization. cross-topic tensions and
collisions become first-class fold outputs.

acceptance: a tensions edge spanning two topics renders dashed on the
board within one fold cycle, with no lint invocation required.

target: v1.1.

---

## FIX-003 · ceremony-shaped triggers
blocking for freshness · Callout-> board/BOARD-010 (event stream)

problem: state updates on skill invocation; the phase machine is the
only clock.

consequence: drift accumulates during ordinary hacking between
storytime runs — the board is stalest exactly when it matters most.

fix (append): event hooks beyond the six consolidation scales —
post-commit, post-test-run, PR state change, and an idle heartbeat —
each firing fold-then-render. hooks are guardrail-grade: silent while
working, surfaced only on failure.

acceptance: a commit made outside any storytime session updates
state.json within one hook cycle; a hook failure lands in the alarm
lane, not stderr oblivion.

target: v1.1.

---

## FIX-004 · append-only without a first-class fold
blocking · keystone · Callout-> board/BOARD-010 (read model)

problem: "current state" is derived by convention and on-demand
scripts from append-only logs. no canonical artifact owns the
reduction — supersedes resolution, latest-wins, adherence and probe
overlays.

consequence: every consumer re-derives or trusts a cache, and a stale
cache on a truth surface is the cardinal failure.

fix: the fold becomes a versioned artifact — one script, one output,
schema version from day one. consolidate invokes it. supersedes,
adherence, and probe overlays are applied inside the fold and nowhere
else in the repo.

acceptance: the fold is deterministic — two runs with no intervening
events produce byte-identical state.json; schema changes require an
explicit version bump; nothing else in the repo computes "current."

target: v1.1. this is the keystone: FIX-001-near and FIX-002 land
inside it.

---

## FIX-005 · voice-shaped output, unowned freshness
structural · Callout-> board/BOARD-P2

problem: outputs are persona conversation — the original complaint,
worn by the human. remembrance is model-shaped with no machine twin.
one-driver-per-leg assigns speech, not maintenance: no persona owns
keeping an item's state fresh.

consequence: the record grows while the readable surface starves;
items rot with nobody accountable.

fix: consolidation dual-emits — remembrance for the model, state delta
for the surface, same event, same commit. add owner: to item
frontmatter, a cohort member accountable for freshness; lint flags
items untouched by their owner across N consolidations. threads remain
the record, the board is the read surface, and personas keep their
voices in the drill-down — never in the glance.

acceptance: every consolidation commit contains both artifacts; every
item carries an owner; staleness surfaces as an amber age marker on
the board, not a lint lecture.

target: dual-emit v1.1 · ownership v1.2.

---

ordering: FIX-000 → FIX-004 (keystone) → FIX-001-near, FIX-002,
FIX-003 in any order → FIX-005 → FIX-001-far alongside the v1.2
command-set work.
