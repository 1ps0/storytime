---
type: icebreaker
schema_version: 1
session: cross-platform-port
episode: 001
created: 2026-04-26T14:10
driver: "@owner [anchor]"
supporters: ["@operator [tide]", "@domain [arbor]", "@skeptic [drift]", "@platform [compass]", "@critic [forge]", "@critic [lattice]", "@educator [beacon]", "@systems [opcode]"]
---

# Icebreaker — cross-platform-port / 001

## Status quo

`@owner [anchor]` framing:

We're at v1.0.1. The intent graph is nascent (sparse but legitimate),
user-as-role is a convention, prompt-yield is documented. v1.0 main SKILL
sits at 262 lines with 19 skills, 3 agents, 9 scripts. All Claude Code-
specific.

User direction is clear: refactor to platform-agnostic core + per-harness
adapters; OpenCode is target #2. The framing is "soul-first paradigm
extension," not accommodating translation. The proposal at
`docs/proposals/cross-platform-storytime.md` captures 10 soul priorities
and 6 open questions. Our job in this session: turn those 6 questions
into sealed decisions and a buildout plan.

## Team reads on the proposal

`@skeptic [drift]` — One concern up front: this is a real refactor of
a working v1.0.1 system. We just shipped intent graph last week. The
risk of triple-regression (Claude Code path breaks, OpenCode path
incomplete, intent-graph nascent) is real. I want every breakout to
weigh "could we defer this to v1.2+ and ship a smaller v1.1?" against
its proposed scope.

`@critic [forge]` — The "soul priorities" list has 10 items. Some of
these are *non-negotiable* (driver-per-leg, consolidation loop, the
narrative grammar). Others are *implementation-shaped* (codenames
non-human is a default, not a hard requirement). Don't conflate.
BO3 should explicitly tier the 10.

`@critic [lattice]` — The OpenCode plugin runs as a function that
produces hooks. Every hook firing has a cost. Storytime's persona
runtime as proposed (driver-per-leg, supporters listening) means
*every tool call* gets intercepted and rewritten with persona context.
At 50-100 tool calls per session, that's a real overhead. BO4 needs to
budget cost.

`@domain [arbor]` — The core/ vs adapters/ vs shared/ shape is
load-bearing. If we get the layout wrong now we'll feel it for the
life of the project. I want BO2 to produce concrete directory trees,
not just principles.

`@operator [tide]` — Existing v1.0.1 Claude Code installs MUST keep
working through this refactor. The migration story for "I have a
working storytime install today; what changes when v1.1 ships?" is the
adoption-blocker if we don't get it right. BO6 owns this.

`@platform [compass]` — From an OpenCode user's perspective, the
adapter has to feel native. If installing the storytime adapter
fundamentally changes how OpenCode behaves in confusing ways, users
churn. The persona runtime needs to be *unobtrusive when not engaged*
and *valuable when invoked*. UX matters per BO4.

`@systems [opcode]` — OpenCode's plugin model is rich but specific.
The hook surface is async TS functions with typed inputs/outputs.
Persona runtime is doable via plugin closure state, but the design
trade-offs (where state lives, how it persists across restarts, how
it interacts with OpenCode's session SQLite) need real work. BO4 is
where I drive.

`@educator [beacon]` — npm packaging for OpenCode plugins is the
standard distribution path. We need to decide: published from this
repo monorepo-style, or separate publishing setup. BO5 owns this and
the install-guide story.

## Sub-problems identified

Six breakouts. Aligned with the proposal's six open questions:

| # | Sub-problem                              | Driver               | Supporters                        |
|---|------------------------------------------|----------------------|-----------------------------------|
| 1 | Version bump — v1.1.0 vs v2.0.0          | @owner [anchor]      | @educator [beacon], @skeptic [drift] |
| 2 | Repo strategy — monorepo vs split        | @domain [arbor]      | @critic [forge], @educator [beacon] |
| 3 | MVP soul-elements (tier the 10)          | @owner [anchor]      | @skeptic [drift], @critic [forge] |
| 4 | Persona runtime in TS for OpenCode       | @systems [opcode]    | @critic [lattice], @platform [compass] |
| 5 | npm distribution + install UX            | @educator [beacon]   | @platform [compass]               |
| 6 | Claude Code adapter migration safety     | @operator [tide]     | @owner [anchor], @critic [forge]  |

## Constraints agreed before breakouts

1. **v1.0.1 Claude Code installs must not break.** Atomic moves; old
   layout works alongside new during transition; lint catches drift.
2. **Soul priorities 1, 2, 3, 5, 7 are non-negotiable for OpenCode MVP**
   per the proposal's recommendation. Other items can defer.
3. **Earns-its-keep test** on every new mechanism (drift's rule).
4. **Atomic writes** for any cross-adapter operations (tide's rule).
5. **Each breakout's recommendation must include a rollback story** if
   it touches the existing v1.0.1 surface.
6. **No external network dependencies** in the OpenCode adapter
   itself. Ship as pure code; users provide their own provider keys.
7. **Decisions seal as V1.1-NNN** for this session (not V1-NNN — those
   are reserved for v1.0 line). New numbering convention.

## Exit condition for breakouts

Each breakout writes `breakout-<N>-<subtopic>.md` with: frontmatter
(driver, supporters, schema_version: 1), problem framing, options
considered, recommendation with Complexity + Scale prose, citations to
proposal sections + opencode/packages source where relevant, open
questions returned. Post-breakout pause is mandatory.
