---
type: remembrance
schema_version: 1
topic: storm-and-verification
staged: 2026-08-02
ingested: 2026-08-14
source: "claude.ai design session, operator thread ii"
---

# storm mode + verification craft

staged: 2026-08-02 · source: claude.ai design session, operator thread ii
placement: docs/proposals/storm-and-verification.md, or absorb per topic
cross-refs: operator-model-user.md (OP-001..010), remembrance-board-x-storytime.md
(BOARD-002/003/010), storytime-fix-todos.md (FIX-003 event hooks are the
substrate storm signals ride on)
maturity: architecture sealed · thresholds and shed tiers are Alex's
calm-time worksheet, marked open

---

# part i — storm mode

premise: OP-003 says memory fails at overload, always. therefore the
system's most important mode is degraded mode, and it has never been
designed. this is a circuit breaker for the operator.

## STORM-001 · decisions hot, execution cold (sealed)

All storm policy is authored in calm, with evidence of past storms in
hand, because in-storm Alex is the failure condition and cannot also be
the designer. The storm plan is a versioned board artifact — freely
editable in calm. In storm, changing the plan costs one deliberate
override step ("override storm plan"): never locked out (the design law
forbids requesting faith, including from himself), but the default path
is the pre-committed one.

## STORM-002 · breaker states and trip signals (sealed; thresholds open)

States: closed (normal) → open (storm) → half-open (recovery probation).
Hysteresis: trip high, release low, no flapping.

Signals — all from exhaust already emitted, no new tracking (OP-003):
- prompt fragmentation and intent-map disorder score rising
- correction latency rising, or corrections stopping entirely (worse)
- loop-opening rate outrunning loop-closing over a window
- stated asks never re-referenced (dropped-ask rate)
- context churn: commits and sessions touching unrelated areas
- manual declare — "storm" or "calm" spoken by Alex is honored
  instantly and outranks every signal

open (worksheet): threshold values, window sizes, which signals weight
highest. Needs two or three observed storms to calibrate; until then,
manual declare is the primary trigger.

## STORM-003 · the shed order (structure sealed; tiers are the worksheet)

Tier 0 — never sheds: safety-critical loops; human-waiter loops (these
  cannot be silently dropped, only renegotiated — see STORM-005);
  capture (see STORM-004).
Tier 1 — sheds first: exploration, candidates-tray intake (directive
  pumps pause), idea-garden tending, nonessential review.
Tier 2 — degrades: verification budget reallocates to top-risk only
  (VERIF-007); everything else renders honestly unverified.

worksheet (calm-time, Alex only): enumerate current loops, assign
tiers, name the two or three deep-flow items that are Tier 0 by
identity, not by urgency. This is the one artifact nobody else can
write.

## STORM-004 · capture never sheds (sealed)

In storm, capture gets cheaper, not rarer: voice-only, zero triage,
zero routing decisions. Triage debt accrues to the recovery queue.
Losing the flood's ideas during storm is the compounding failure;
holding them untriaged is merely deferred work.

## STORM-005 · honest degradation, outward and on the board (sealed)

The board in storm: amber and red only, tray closed, lenses to micro,
delta chips suppressed except alarms, zero new asks, decisions queue
unless Tier 0. Unverified work renders gray — the board must show
degraded verification rather than pretend. A board that lies under
load lies exactly when it matters.

Outward: a legible degraded-mode broadcast — "shed mode until ~Thu;
escalation path X; decisions queued except emergencies." In a
no-prior team this teaches the priors deliberately: Alex's silence
acquires semantics, slipped dates arrive as renegotiations instead of
mysteries. One message per affected human-waiter loop, drafted by the
system, sent by Alex.

## STORM-006 · pre-authorized autonomy — the partial-release proving
ground (sealed; scope open)

In calm, specific Tier-1 mundane classes are pre-authorized for agent
autonomy during storm, each with: scope boundary, receipt requirement,
guaranteed post-storm audit. This answers the operator file's open
item — what a partial release ceremony looks like: scoped in calm,
exercised by necessity, audited with receipts, revocation permanently
visible. Vigilance deferred with a receipt, never surrendered.
Necessity is how trust gets its reps.

open: the first two or three classes to pre-authorize. Start
insultingly small.

## STORM-007 · recovery is first-class (sealed)

Release: saturation below the low threshold for N hours, or declared.
Half-open runs the reconciliation report: what was shed, what
auto-proceeded (receipts attached for audit), which humans are owed
follow-ups (messages pre-drafted), the triage-debt queue, and a
verification catch-up pass ranked by what changed during the storm.
Storm cost is reported once, harvest-style, then out of sight
(OP-004) — storms are countable at boundaries, never trended
ambiently.

---

# part ii — verification craft

premise: the agent writes most of the code; Alex's minutes are the
scarce resource; dots must be honest; joy requires the view (OP-007).

## VERIF-001 · verification is budget allocation (sealed)

Spend minutes by expected loss: blast radius × novelty ×
irreversibility × (1 − probe coverage). The fold computes a risk rank
per change; the review queue orders by it. The low-risk tail is
sampled, never skimmed.

## VERIF-002 · review the tests, not the code (sealed — highest leverage)

The code is the agent's claim; the tests are the specification of what
was actually verified. Reading tests answers "what does this change
promise" in a fraction of the time. Red flags legible from tests
alone: tautological asserts, mocks all the way down, missing negative
cases, tests mirroring implementation. Good tests demote code review
to sampling; bad tests end the review — the tests are the finding.

## VERIF-003 · mutation testing as dot QA (sealed; cadence open)

The native failure of agent-written code is self-confirming tests —
the same author wrote the claim and the check. Mutation testing is the
independent auditor neither wrote: mutate (flip conditionals,
off-by-ones, deleted statements), run the suite, count survivors.
Every surviving mutant is a mechanical measurement that a green dot
asserts nothing.

grammar amendment (proposed, amends BOARD-002): dots earn solidity.
Kill-rate high → solid green. Kill-rate low or unmeasured → hollow
green. A dot's fill is its honesty, rendered.

Surviving mutants auto-file as candidates ("test gap: limiter.acquire
survives boundary mutation"). Runs in CI at low cadence — expensive —
and surfaces at harvest boundaries, never ambiently (OP-004).

## VERIF-004 · properties from sealed decisions (sealed where applicable)

Important interfaces get property-based tests: invariants plus
generated inputs, not example lists. Sealed decisions and bedrock
claims compile into properties ("retries safe iff idempotency key
present") — one readable line each, which makes VERIF-002 cheaper
still. The claim-card probe and the property are often the same
artifact at two altitudes.

## VERIF-005 · differential testing for refactors (sealed)

Factoring work — the joy zone — gets old-vs-new behavioral diff on
recorded fixtures: equivalence verified mechanically. The split that
keeps code sense fed: machines verify equivalence; Alex verifies
elegance. His minutes go entirely to shape, which is the part that
needs taste and the part he loves.

## VERIF-006 · sampling with teeth (sealed)

For the low-risk tail: deep-review a random k%, and a failed sample
escalates its whole class to full review. Skimming everything is the
illusion of review; deep-sampling some is calibrated trust with a
tripwire.

## VERIF-007 · adversarial pre-pass and storm coupling (sealed)

Before Alex's minutes are spent, the agent attacks its own diff —
hunting the stomped clean option, the missing edge, the unraised
objection — and emits structured residue (OP-008 format: solid dots
for measured findings, hollow for judgment). Cheap filter, runs
always. In storm: the budget steepens to top-risk only; everything
else goes honestly gray; recovery includes the catch-up pass
(STORM-007).

---

ordering: STORM-003 worksheet is the gate — it is calm-time work and
calm is perishable. VERIF-002 and VERIF-006 are adoptable tomorrow
with zero tooling. VERIF-003 needs one CI job and pays for the dot
grammar forever. STORM-002 thresholds wait for observed storms;
manual declare carries until then.
