---
type: icebreaker
created: 2026-04-13T11:10
schema_version: 1
session: v1-consolidation
episode: 001
driver: "@owner [anchor]"
supporters: ["@operator [tide]", "@domain [arbor]", "@skeptic [drift]", "@platform [compass]", "@critic [forge]", "@critic [lattice]", "@educator [beacon]"]
---

# Icebreaker — v1-consolidation / 001

## Status quo

`@owner [anchor]` framing:

We're at v0.9.0. The main SKILL is 410 lines, references/ carry 16
topic files (2284 lines), lint is two-tier (mechanical script +
estimator agent), conventions are enforced via
`scripts/check-conventions.sh`, and `agents/estimator.md` handles
reasoning-tier checks. The framework works. It's *composed* but not
yet *unified*. The proposal at `docs/proposals/v1-consolidation.md`
names what the unification looks like: consolidation as the primary
loop, spec workflow as one surface on top.

13 decisions already resolved (V1-001..V1-013). Five calibration
questions remain. Our job here is to:

1. Confirm the status quo is understood and not challenged by a
   dissenting lens
2. Turn the 5 open questions into breakouts, plus one breakout on
   migration path
3. Produce a plan that sequences MVP → dogfood → full v1.0

## Team reads on the proposal

`@skeptic [drift]` — I accept the framing. One concern: **V1-002's
shift from threshold to self-introspection is big.** If the LLM
decides pauses on its own judgment, the user loses predictability.
We should make sure "model detects degradation" has concrete signals
documented, not vibes. Otherwise pauses become arbitrary.

`@critic [forge]` — The T=21 on warm-start preamble is correct —
remembrance genuinely replaces it, not shims it. But T=8 on
phase-boundary compaction is **optimistic**. Phase boundaries are
currently described across 3+ sections of main SKILL; unifying them
into a single consolidation format means touching every skill that
writes a phase artifact. More like T=13. Don't underestimate the
sprawl.

`@critic [lattice]` — The cost math on dreams: if dreams fire on
every commit and each dream is ~15 lines written by an agent call,
that's a non-trivial per-commit cost. A 30-commit day = 30 agent
invocations. Dreams need to be **cheap to write or rare**. If every
commit fires a dreamer, users will turn dreams off, and then V1-004
is a mainly-off feature. Propose: dreams are only written when the
commit crosses a threshold of interestingness — file-count ≥ 3, OR
decision sealed, OR phase boundary. Boring commits skip.

`@domain [arbor]` — On V1-003 (thread IS decision log): I agree with
the merge but we need the callout format (V1-011) resolved before
implementation, because cross-topic decisions currently live in
`history/decisions.md` as a single stream. Merging to per-topic threads
without callouts orphans cross-topic references.

`@operator [tide]` — Hook reliability concern: post-commit hooks can
fail for many reasons (git config, permissions, disk full, shell
differences). V1-006 says dreams live at `.storytime/dreams/` — but
if the hook fails mid-write, we get partial files. Need atomic write
(tmp + mv) and a "skipped dream" mechanism so the failure doesn't
block the commit itself. Already noted in error-recovery.md but needs
explicit call-out in the v1.0 hook contract.

`@platform [compass]` — V1-007 tutorial mode is good but V1-013
adaptive exit needs careful calibration. If friction signals are
too sensitive, users who just want to learn get graduated; too lax,
users stay in hand-holding mode forever. This is UX-critical. Should
be its own breakout.

`@educator [beacon]` — **Migration is underspecified.** The proposal
says "existing sessions/artifacts migrate to v1.0 shapes" — but
HOW? Do we write migration scripts? Opt-in migration per session?
Silent adapter that reads old formats and writes new? This is the
MVP's adoption blocker if we don't specify it.

## Sub-problems identified

From the discussion, six breakouts warrant parallel investigation:

| # | Sub-problem                         | Driver              | Supporters                      |
|---|-------------------------------------|---------------------|---------------------------------|
| 1 | Commit confirmation learning speed  | @platform [compass] | @operator [tide], @skeptic [drift] |
| 2 | Pause detection (model self-signals) | @operator [tide]   | @critic [lattice], @skeptic [drift] |
| 3 | Callout format for cross-topic refs | @domain [arbor]     | @critic [forge]                 |
| 4 | Global decisions index necessity    | @domain [arbor]     | @skeptic [drift]                |
| 5 | Tutorial friction signal calibration | @platform [compass] | @educator [beacon]             |
| 6 | Migration path v0.9.2 → v1.0        | @educator [beacon]  | @owner [anchor], @operator [tide] |

## Constraints agreed before breakouts

1. **Main SKILL line count target: 280 max.** Anything that grows
   it past 280 needs explicit justification or goes to references/.
2. **No mechanism without a kill switch** (tide's rule). Every hook
   is disablable. Every new skill is optional.
3. **Earning-its-keep test** (drift's rule). Each breakout must
   propose either an absorption of existing capability or a clear
   value-add not otherwise available. No pure additions.
4. **Atomic artifact writes** (tide's rule). Every hook writing to
   disk uses tmp + atomic mv, so partial failures don't corrupt state.
5. **Complexity ≥ 13 decomposes.** If any breakout's recommendation
   is C≥13, it gets further split before going into the plan.
6. **Migration is a first-class concern** (beacon's rule). Breakout 6
   produces a concrete migration artifact, not a "left as an exercise."

## Exit condition for breakouts

Each breakout writes `breakout-<N>-<subtopic>.md` with:
- Frontmatter (type: breakout, driver, supporters, schema_version: 1)
- Problem framing
- Options considered
- Recommendation (with Complexity + Scale in prose)
- Citations to proposal sections, existing code/references, or external docs
- Open questions returned to CONVERGE

Post-breakout pause is mandatory. User directs proceed / dig / revise /
add before CONVERGE runs.
