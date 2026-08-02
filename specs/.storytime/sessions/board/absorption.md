---
type: absorption
schema_version: 1
topic: board
created: 2026-08-02T13:07
driver: "@domain [arbor]"
supporters: ["@owner [anchor]", "@operator [tide]", "@skeptic [drift]", "@platform [compass]"]
source_commit: 7846522
---

# Absorption — board × storytime handoff

## Timeline of the source material

- 2026-08-02, claude.ai (web): one long design session — Alex + Claude
  designed a perceptual control surface ("the board"), prototyped
  three widget iterations, converged on storytime as the data
  substrate. Staged two documents for the first Claude Code session:
  a remembrance (tier: shift) and a fix-todos backlog proposal.
- 2026-08-02, this repo: warm load; fix todos ingested into
  `BACKLOG.md` as FIX-000..005 (full fidelity); pushback on
  sequencing, first-cut order, and interrupt policy accepted by
  @user; files staged into `sessions/board/` (commit 7846522); this
  absorption.

## What the material is

The remembrance carries eleven sealed decisions (BOARD-001..011), five
proposals (P1..P5), three open questions, five named obstructions, and
a six-step next-actions list. The core shape: storytime grows a
control surface (one derived state.json read model, a command set
mapping onto existing skills, an event stream); the board is a
loosely-coupled client of that surface, never a fork. The original
driver is perceptual: dense text does not stick; the board exists so
perception does work that reading cannot; any feature that increases
required reading is a regression.

## Team interpretation

**@domain [arbor] (driver):** The decision set is well-formed and the
ids are stable — that part of the taxonomy arrived healthy. Two
catches. First, the real one: BOARD-010's fold is a pre-built derived
index, and I drove V1-022, which sealed "on-demand decisions view, no
pre-built global index." These are in genuine tension, not accidental
conflict — V1-022 was a bet against stale caches, and FIX-004 is the
argument that one versioned artifact owning the reduction is how a
pre-built view stops being a stale cache. I expect fold v0 to
supersede V1-022 in part, and I want that supersede sealed explicitly
when it happens, not slid past. Recorded as `Tensions: [V1-022]` on
BOARD-010. Second, small: FIX-002's callout cites BOARD-006 where its
substance lives in BOARD-010 — plausibly intentional (cross-topic
tensions are intent-graph edges, which is BOARD-006's lineage
polarity), but a system that runs on callouts being exact should rule
on it. Open question on the thread. Naming ruling for the taxonomy:
"the fold" is the reduction run and its script; "state.json" is its
artifact; "the board" is a client. Call them the same thing in six
months.

**@owner [anchor]:** Does it collapse cleanly? Yes — that's what
BOARD-010's loose-coupling test literally is: board.html on a fixture
with storytime absent, and storytime unchanged with the board absent.
Append-first (BOARD-011) is the gearbox principle applied, so the
architecture composes. My constraint for buildout: the fold is a
module with a small surface — parse, resolve supersedes, overlay
probes, emit — invoked by a thin CLI wrapper and by consolidate.
Nothing else in the repo computes "current" (FIX-004's acceptance
already says this; I'm saying it applies to *our own scripts* too —
`intent-graph-query.sh` becomes a reader of the fold's parse layer or
a documented exception, not a second parser of thread markdown).

**@operator [tide]:** What happens at 2am is a torn state.json. The
fold's acceptance criteria say deterministic and fail-loud; I'm adding
V1-018 to it: every state.json write is tmp + fsync + mv, same as
remembrance. A truth surface that can be half-written during a crash
is FIX-001's lie arriving through the filesystem instead of the
parser. Also endorsing FIX-003's acceptance line that hook failures
land in the alarm lane, not stderr oblivion — hooks that fail silently
are how the board goes stale while looking fresh, which is the worst
state it can be in. `post_commit_hook: disabled` in config today;
flipping it is part of FIX-003, not before.

**@skeptic [drift]:** Who is this for, specifically? Alex, solo,
steering production systems he no longer holds in his head — that's a
real answer, so I'm in. BOARD-012 replaces a surface instead of adding
one; I get excited when something is removed. Board.html as a monofile
in the house viewer lineage passes my no-build-step test. Two
warnings. The BOARD-002 grammar is seven encodings deep — depth,
lane, color, border, dot, outline, size — and the one-line-legend
rule is the entire DX contract; the first time the legend wraps,
I'm invoking it. And BOARD-009's directives rail must never become
mandatory ceremony — a directive is an intake pump you *chose*, not a
field you fill in. The moment a skill refuses to run because no
directive exists, I veto.

**@platform [compass]:** BOARD-007 is the decision I'd defend with the
most force — the native test kills the flashcard failure mode where
the tool quizzes the human instead of showing them the territory.
Amber = waiting-on-user (BOARD-002/003) is an interaction contract:
the board only raises its voice when the human is the blocker, which
is exactly when interruption is legitimate. BOARD-014 extends the same
contract to stale beliefs, and BOARD-004's drill-never-regenerates
keeps conversation truth canonical — the drill shows the record, it
doesn't improvise one. One observation on us rather than the material:
the V1-022 catch is evidence the team read rather than generated —
that's the absorb working as designed.

## Contradictions register

1. **BOARD-010 fold vs V1-022 no-pre-built-index** — genuine tension,
   recorded on BOARD-010, resolution expected at fold v0 as an
   explicit partial supersede. (arbor)
2. **FIX-002 callout target** — cites BOARD-006; substance is
   BOARD-010. Thread open question. (arbor)
3. **Config vs FIX-003/tray** — `post_commit_hook: disabled` and
   `dreams_enabled: false` are both currently sealed-by-config
   against features the board eventually wants. Deliberate: flips
   happen at their FIX moments, not preemptively. (tide)
4. **Absorb skill text vs V1-023** — the skill still says extract
   decisions to `history/decisions.md`; V1-023 deleted that file in
   favor of per-topic threads. Thread wins; skill file needs a v1.1
   touch-up (candidate for the backlog's skill-hygiene pass). (arbor)

## What's missing

- **State schema** — next action; the remembrance specifies the
  top-level keys and the version field, not the item shape. Schema v0
  must also mark fixture provenance (the widget's "transport v2
  cutover" content is demo fiction and must never be mistakable for
  real work).
- **skill-scout SKILL.md** — packaged in the source session, not
  transferable, marked re-derivable. Its seven signals fold into the
  dreams/candidates intake later; nothing to do now.
- **Argument ledger for rearrangements** — BOARD-011 requires it;
  P1..P3 are registered as proposals on the thread, which serves as
  the ledger's seed.

## Coverage fingerprint

| Material | Depth |
|---|---|
| `remembrance-board-x-storytime.md` (175 lines) | full read |
| `storytime-fix-todos.md` → BACKLOG §Board Unification Debts | full read, ingested at full fidelity |
| `full_project_board_transport_v2_cutover.html` (226 lines, 28KB) | structural skim — grammar terms confirmed (budget, drill, lane, delivery, candidates, bedrock, amber); JS internals not parsed; treated as disposable rendering, specs live in BOARD-002..008 |
| `BACKLOG.md` (pre-existing body) | full read; stale `/storytime status` entry struck as IMPLEMENTED |
| `_thread.md` v1-consolidation, v1.0.1-intent-graph-nascent | full read (decision format, V1 ids for cross-refs) |
| cohort roster + 5 persona files | full read |
| `config.md`, `.version`, README §v1.0.1 | full read / targeted |

## Verdict

Absorbed. The unification is coherent with v1.0/v1.0.1 architecture;
one real cross-topic tension recorded for explicit resolution at fold
v0; sequencing amended by BOARD-013. Next: schema v0, fold v0
(decisions-first), board.html v0 against a labeled fixture.
