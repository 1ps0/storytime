---
type: absorption
schema_version: 1
topic: storm-and-verification
created: 2026-08-14T11:08
driver: "@operator [tide]"
supporters: ["@owner [anchor]", "@domain [arbor]", "@skeptic [drift]", "@platform [compass]"]
source_commit: 6be5fd1
---

# Absorption — storm mode + verification craft

## Timeline of the source material

- 2026-08-02, claude.ai (web), operator thread ii: the session that
  produced the operator model (OP-001..010) continued into degraded
  mode and verification. Premise chain: OP-003 says memory fails at
  overload always, therefore the most important mode is degraded mode,
  and it had never been designed. Fourteen decisions sealed, one
  grammar amendment proposed, staged as a single remembrance at repo
  root with self-declared placement and maturity.
- 2026-08-02..06, this repo: board episodes 001–008 built the
  substrate the storm signals will eventually ride (fold, server,
  event stream) — independently, before this absorption.
- 2026-08-14, this repo: ingest (6be5fd1) into
  `sessions/storm-and-verification/`, this absorption, seals recorded.

## What the material is

Part i is a circuit breaker for the operator: storm policy authored in
calm (STORM-001), breaker states with hysteresis and exhaust-only trip
signals (STORM-002), a three-tier shed order whose tier assignments
are @user's calm-time worksheet (STORM-003), capture as the one loop
that gets cheaper under load instead of shed (STORM-004), honest
degradation on the board and outward (STORM-005), pre-authorized
autonomy as the partial-release proving ground (STORM-006), and
recovery as a first-class half-open state (STORM-007). Part ii is
verification as budget allocation of @user's scarce minutes
(VERIF-001) with the highest-leverage move being review-the-tests
(VERIF-002), mutation testing as the independent auditor of
agent-written tests (VERIF-003), properties compiled from sealed
decisions (VERIF-004), differential testing to keep the joy zone fed
(VERIF-005), sampling with escalation teeth (VERIF-006), and an
always-on adversarial pre-pass that couples the two parts (VERIF-007).

## Team interpretation

**@operator [tide] (driver):** This is my domain arriving as law, and
the architecture is right — closed/open/half-open with hysteresis and
a shed order is exactly how you keep a system alive under load, and
applying it to the human is the honest admission the whole operator
model was building toward. My catch is the maturity line. "Architecture
sealed, thresholds open" undersells what's missing: the *sensors* are
unbuilt. Every STORM-002 signal (fragmentation score, correction
latency, loop open/close ratio, dropped-ask rate, context churn) is a
computation over exhaust that nothing currently computes — they ride
FIX-003's event hooks, which are the board thread's open Next-action
#2. So the true state is: architecture sealed, sensors unbuilt,
thresholds open, manual declare load-bearing. That's fine — the doc
itself says manual declare carries until calibration — but the record
must say sensors-unbuilt out loud so nobody reads "sealed" as
"armable." Recorded on STORM-002. Second note: STORM-007's
reconciliation report is a format with no template; when it's first
needed it will be needed in a hurry, which is the wrong time to design
it. Filed under what's missing.

**@skeptic [drift]:** Two endorsements and two warnings. Endorse
VERIF-002 hard: it's zero tooling, adoptable this afternoon, and it
inverts the review economics — the tests are the claim ledger and bad
tests end the review early, which *removes* work. Endorse STORM-006's
"start insultingly small" — that's the anti-ceremony instinct applied
to trust itself. Warning one: this repo has no test suite. VERIF-003
mutation testing has nothing to mutate here; its first real target is
a consumer repo with an actual suite (kickbox). If we stand up the CI
job here first it's ceremony without substrate — the thing I exist to
veto. A suite for our own scripts is a legitimate separate debt; raise
it at a backlog pass, don't smuggle it in as a VERIF-003 dependency.
Warning two: "low cadence CI" must never become a red X nagging every
push — VERIF-003 already says harvest-boundary surfacing (OP-004), and
I'll hold it to that. The storm machinery itself gets the same test:
the only ceremony storm mode may ever ask of in-storm @user is the
single override step. Anything more is the system demanding ritual
from a person in failure state (OP-002 violation).

**@owner [anchor]:** Composition check. VERIF-P1 is the interesting
one: it amends BOARD-002, which is frozen, so procedure matters — and
the procedure held: registered as a proposal, ruling card routed to
the board thread, not slid into a seal. On substance it's sound
because it doesn't mint grammar: OP-008 already established fill =
epistemic status (solid = measured, hollow = judgment); VERIF-P1
generalizes that to dots earning solidity from kill-rate. One axis,
one meaning, consistent across the system — I'd seal it, but it's not
mine to seal. Second constraint, for whenever VERIF-001 gets realized:
the risk rank (blast radius × novelty × irreversibility × probe
coverage) is a fold output. FIX-004 discipline applies — the fold
computes it, nothing else in the repo does, and its inputs (probe
coverage especially) don't exist until the probe overlay events land.
VERIF-001 is sealed policy with a gated realization; that's fine, but
the gate is FIX-003 again. Both halves of this doc converge on the
same keystone dependency, which is evidence the architecture composes.

**@domain [arbor]:** Placement and taxonomy. The doc offered two
placements — `docs/proposals/` or per-topic absorb — and proposals/
is wrong: eleven of fourteen entries are sealed, and proposals/ is
where will-be lives. Episode-000 precedent applies: sealed external
material founds a topic, remembrance as canonical text, thread as
operative record. Ruled and done. The id space arrived healthy —
STORM/VERIF ids stable, cross-refs exact (OP and FIX and BOARD
references all resolve). One naming ruling: the doc's two parts are
one topic, not two — VERIF-007 couples them (storm steepens the
verification budget), the ordering section interleaves them, and
splitting would put a topic boundary through a live edge. The
cross-part coupling stays prose-internal to the topic; the cross-topic
edges (BOARD-002/003/006/010/023) are recorded as callouts.

**@platform [compass]:** The interaction contract deepens coherently:
amber = waiting-on-user was BOARD-002/003 law, and STORM-005 extends
it — under load the board narrows to exactly amber and red, which
means the grammar's loudness budget was designed for this mode before
the mode existed. Two catches. First, the board cannot render a mode
it cannot see: the state contract has no breaker-state field. When
storm mode first arms, `closed/open/half-open` enters the schema as a
minor bump and STORM-005's rendering rules become client obligations
— deferred deliberately, recorded in Next action. Second, a live edge
with BOARD-024: open questions fold to amber cards, and STORM-005
says zero new asks in storm. Those compose only if the question lane
freezes its intake while staying rendered — new question cards are
new asks; existing amber is precisely what storm mode exists to show.
That distinction (freeze intake, keep display) isn't written anywhere
yet; contradictions register. And the outward broadcast passes the
BOARD-007 native test: drafted-by-system sent-by-human renegotiation
is something no flashcard app could ship — it exists because the
system holds the live territory of who is owed what.

## Contradictions register

1. **Maturity line vs sensor reality** — "architecture sealed,
   thresholds open" omits that the STORM-002 signal producers are
   unbuilt (FIX-003 dependency). Recorded on the STORM-002 entry;
   manual declare is load-bearing by design until then. (tide)
2. **STORM-005 zero-new-asks vs BOARD-024 question cards** — composes
   only as freeze-intake-keep-display; unwritten. Lands with the
   breaker-state schema work. (compass)
3. **VERIF-003 first target** — the doc says "runs in CI"; this repo
   has no suite. First target is a consumer repo (kickbox); a suite
   for storytime's own scripts is a separate debt, not a smuggled
   dependency. (drift)
4. **VERIF-001 realization gate** — risk rank needs probe-coverage
   input the fold doesn't have until FIX-003's test-run events land.
   Sealed policy, gated realization; both parts of the doc gate on
   the same keystone. (anchor)

## What's missing

- **The storm plan artifact** — STORM-001 names "a versioned board
  artifact" but no file, format, or home. Needs a decision at
  worksheet time: likely `specs/.storytime/storm-plan.md` or a
  producer card, but that's a ruling, not a default.
- **The worksheet template** — the *content* is @user-only
  (Tier-0-by-identity is an identity question), but the *structure*
  is mechanical (BOARD-020 split): a scaffold with the loop
  inventory prompts costs nothing and lowers the calm-time price of
  the one artifact nobody else can write. Candidate for next session.
- **STORM-007 reconciliation report format** — needed in a hurry when
  first needed; design it in calm alongside the worksheet.
- **A test suite for this repo's own scripts** — fold.py,
  board_server.py, bootstrap_repo.py are verified by episode-recorded
  manual E2E only. Separate debt; raise at next backlog pass.

## Coverage fingerprint

| Material | Depth |
|---|---|
| `remembrance-storm-and-verification.md` (189 lines) | full read |
| `cohort/operator-model-user.md` (OP-001..010, D-1..D-6, local-only) | full read — premise chain and design law grounded |
| `docs/drafts/storytime-fix-todos.md` (FIX-000..005) | full read — FIX-003 substrate dependency confirmed |
| `sessions/board/_thread.md` (episodes 000–008, BOARD-001..025, P1..P5) | full read — grammar, precedent, callout targets |
| `cohort/_roster.md` | full read |
| `sessions/board/absorption.md` | full read — artifact format precedent |
| `scripts/` listing, `.gitignore` | targeted — confirmed no test suite exists; confirmed ignore coverage |
| persona files (5) | not re-read this session — roster + board absorption carry current state |

## Verdict

Absorbed. Fourteen seals recorded, one proposal routed to the board
thread for @user's frozen-grammar ruling, four contradictions caught
and registered — all of them gates and sequencing, none of them
conflicts with existing law; the material is unusually consistent
with OP-001..010 because it was authored downstream of them. The
ordering claim in the source holds up under team read: the STORM-003
worksheet is the gate and it is perishable. VERIF-002 and VERIF-006
are adoptable immediately with zero tooling.
