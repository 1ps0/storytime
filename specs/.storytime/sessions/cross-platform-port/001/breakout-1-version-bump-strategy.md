---
type: breakout
schema_version: 1
created: 2026-04-26T14:30
session: cross-platform-port
episode: 001
topic: cross-platform-port
subtopic: version-bump-strategy
driver: "@owner [anchor]"
supporters: ["@educator [beacon]", "@skeptic [drift]"]
status: complete
---

# Breakout: version-bump-strategy

## Question

Cross-platform refactor + first OpenCode adapter is significant. Should
this ship as **v1.1.0** (incremental, "additive feature"), **v2.0.0**
(structural change, may need migration), or some staged variant
(e.g. **v2.0.0-alpha.N → v2.0.0**)?

The decision is purely *communication*: which version number sets the
correct expectations for upgraders (currently just future-Alex) and
new users (Claude Code today, OpenCode after the adapter ships)?
`bump-version.sh` is mechanical — it propagates whatever number we
hand it. No engineering blocker.

### What we know

- Current version: `1.0.1`
  (`/Users/alexevers/workspace/projects/storytime/VERSION:1`,
   `/Users/alexevers/workspace/projects/storytime/.claude-plugin/plugin.json:3`).
- The cross-platform-storytime proposal's scope: directory restructure
  to `core/` + `adapters/claude-code/` + `adapters/opencode/`,
  plugin manifest moves, OpenCode plugin TS code added, distribution
  via npm proposed for the OpenCode adapter
  (`docs/proposals/cross-platform-storytime.md:168-218`).
- The proposal's own scoping note: "This is a v1.1 or v2.0 effort, not
  a v1.0.x patch" — the question is left explicit and unresolved
  (`docs/proposals/cross-platform-storytime.md:282`,
   `docs/proposals/cross-platform-storytime.md:325-329`).
- Constraint #1 from icebreaker: existing v1.0.1 Claude Code installs
  MUST keep working through the refactor — automated, reversible
  migration is required either way
  (`specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:96-97`).
- Migration precedent: `scripts/migrate-to-v1.sh` was the v0.9 → v1.0
  migration. It supports `--apply`, `--commit`, `--rollback`,
  dry-run-by-default, marker-based pre-flight detection, positive
  version stamping. The pattern is reusable — a `migrate-to-v1.1.sh`
  or `migrate-to-v2.0.sh` would mirror it
  (`scripts/migrate-to-v1.sh:1-242`).
- Bump tooling is layout-aware: `bump-version.sh` updates `VERSION`,
  `.claude-plugin/plugin.json`, `README.md`, every
  `skills/*/SKILL.md`'s `version-echo` block, and `site/*.html`
  (`scripts/bump-version.sh:30-58`). After the refactor, the SKILL.md
  glob target moves to `adapters/claude-code/skills/*/SKILL.md`. The
  script needs an update either way — but that's adapter-aware
  bookkeeping, not version-number-driven.
- Soul priorities (10 items in the proposal,
  `docs/proposals/cross-platform-storytime.md:33-86`) are unchanged
  by this refactor. Personas, driver-per-leg, consolidation loop,
  narrative grammar, intent graph — all preserved. What changes is
  the *plumbing*: where files live, how the harness invokes them,
  what install command users run.

### What we don't know

- How many real Claude Code installs exist beyond the proposal author
  (icebreaker estimates "just me, but still" —
  `docs/proposals/cross-platform-storytime.md:265`). If the answer is
  truly N=1, the *adoption* arguments collapse to "what discipline
  does future-Alex want?"
- Whether storytime will be published to a marketplace (npm, Claude
  Code Plugin marketplace, OpenCode plugin registry) inside this
  refactor cycle. If yes, the version number is also a marketplace
  semver contract; if no, it's an internal coordination signal only.

### Constraints

- v1.0.1 installs cannot break — automated migration script with
  rollback is non-negotiable
  (`specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:96-97`,
   `scripts/migrate-to-v1.sh:42-51` for the rollback pattern).
- Decisions seal as `V1.1-NNN` for this session — the numbering
  convention itself implies a v1.1 line, but is intentionally
  ambiguous about whether the *release* lands as v1.1 or v2.0
  (`specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:105-106`).
- The version number is a *one-shot communication artifact*: once
  shipped, the next users see only that number. It should set
  expectations that match the actual upgrade experience.

### Exit condition

A version-and-staging recommendation, with explicit rationale tied to
each of the seven angles in the breakout prompt, plus a citation to
the proposal section that triggered the question.

## Findings

### Angle 1 — SemVer strict reading

The cross-platform refactor moves `skills/`, `agents/`, and
`.claude-plugin/` into `adapters/claude-code/`. Today users install via
the Claude Code plugin marketplace by pointing at this repo root; the
manifest at `.claude-plugin/plugin.json` is the install entry point. If
the manifest moves to `adapters/claude-code/.claude-plugin/plugin.json`,
the install command path changes — which is a breaking change to the
install surface. Strict SemVer says *any* break to the public surface
is MAJOR, regardless of whether the migration is automated.

Counter: if the repo root retains a stub manifest or symlink during
transition (constraint #1 mandates a non-breaking transition window),
then the *practical* break is deferred — users at v1.0.1 keep working
even after v2.0 ships, until they explicitly run the migration.
Migration-soft-landed breaks are still breaks; SemVer scores intent
("we changed the API") not just immediacy.

**Drift challenges:** "Is the install path actually the public API,
or is the *content* (skills, agents, narrative grammar) the public
API?" — The narrative grammar and persona model are stable. But
SemVer scopes APIs, not concepts. The install path is the API.
**Conclusion: strict SemVer favors v2.0.**

### Angle 2 — Migration burden

Both v1.1 and v2.0 require the same migration script. Same files
moved, same symlinks created, same lint rules updated, same git
history. The work is identical.

The *signaling* differs:

- **v1.1.0 says:** "We added OpenCode support. Existing usage continues
  unchanged." A user reading just the version number reasonably skips
  the migration step. Then their v1.0.1 install breaks at next plugin
  reload.
- **v2.0.0 says:** "Read the upgrade guide before installing. Expect
  changes." A user reading just the version number pauses and reads.

Given that both versions require running a migration script,
v2.0 sets accurate expectations for the upgrader's actual experience.

**Beacon (adoption angle):** The release-notes paragraph at v1.1 buries
"BREAKING: install path changed, run migrate-to-v1.1.sh." The same
information at v2.0 is in the version number itself.

**Conclusion: v2.0 sets correct expectations for the migration burden.**

### Angle 3 — Soul vs plumbing

The 10 soul priorities are unchanged
(`docs/proposals/cross-platform-storytime.md:33-86`). Storytime as a
*concept* — personas as fluid lenses, driver-per-leg, consolidation
loop, intent graph, narrative grammar — survives the refactor intact.
Only plumbing changes: file paths, plugin manifest location,
distribution model.

This is anchor's strongest argument for v1.x: SemVer for *concepts*
would call this minor. The concept hasn't changed; only the
implementation has.

**Counter-argument:** SemVer is explicitly an API contract, not a
concept contract. The Linux kernel ships v6.x without claiming each
release is a new operating system; the *concept* "Linux" is constant.
Version numbers track API evolution, not philosophical evolution.

**Tension this leaves:** v1.x communicates "soul preserved" but
under-communicates "install path moved." v2.x communicates "install
path moved" but over-communicates if a reader interprets it as "the
soul changed." There is no version number that says both.

**Resolution path:** Pair v2.0 with a release announcement and README
that *explicitly* foregrounds soul-continuity:

> storytime 2.0 — cross-platform release. **The soul is unchanged**:
> personas, driver-per-leg, the consolidation loop, the intent graph,
> the narrative grammar. What's new is the platform model: storytime
> now runs on Claude Code *and* OpenCode, with a portable core and
> per-harness adapters. v1.0 users: run
> `./scripts/migrate-to-v2.sh --apply --commit`.

The version number's signaling weakness is offset by docs framing.

**Conclusion: v2.0 is honest if framed correctly; v1.x would mislead
upgraders about the install path.**

### Angle 4 — Adoption (lower version = lower friction)

For new users discovering storytime today, the version number on the
README badge is one of several signals (last-commit date, star count,
docs quality). v1.x and v2.x both read as "1.0+" maturity to a casual
viewer. The friction differential is near-zero.

**For deliberate evaluators**, v2.0 reads as "they made a structural
decision and committed to it." v1.x reads as "still iterating, may
break later." For a tool whose value proposition includes
"durable, atomic, continuity-preserving," v2.0 is *more* trustworthy,
not less.

**Counter:** v2.0 from a one-user project can read as version theater
("we shipped a 2.0 because we moved files"). This is the failure mode
drift is rightly watching for.

**Resolution:** v2.0 is *not* theater here because the cross-platform
adapter model is a real paradigm shift, not just file moves. OpenCode
users will install storytime via npm with `opencode.json` plugin
references — fundamentally different from Claude Code's marketplace
manifest. That's two install paths, two harness models, one shared
soul. v2.0 announces a real change.

**Conclusion: v2.0 is more trustworthy for new users than v1.1 would
be, *given* the framing in angle 3.**

### Angle 5 — Beacon's README/install message

Concrete prose comparison:

**v1.1.0 README excerpt:**
> Storytime v1.1 — Now with OpenCode support! Same persona-driven
> spec workflow, now available on both Claude Code and OpenCode. To
> install on Claude Code, run `/plugin install
> github.com/1ps0/storytime`. To install on OpenCode, add to your
> `opencode.json`. **Upgraders from v1.0.x:** run
> `./scripts/migrate-to-v1.1.sh --apply --commit` before next plugin
> reload.

**v2.0.0 README excerpt:**
> Storytime v2.0 — Cross-platform release. Persona-driven spec
> workflow on Claude Code, OpenCode, and (eventually) other LLM
> coding harnesses. Pick your harness:
> - **Claude Code:** `/plugin install
>   github.com/1ps0/storytime/adapters/claude-code`
> - **OpenCode:** `npm install @storytime/opencode-plugin`
>
> **Upgrading from v1.0.x?** This release moves files into adapter
> directories. Existing installs continue to work in a compatibility
> window; run `./scripts/migrate-to-v2.sh --apply --commit` when
> ready. v1.0.x continues to receive critical fixes through 2026Q3.

The v2.0 README treats cross-platform as the headline. The v1.1
README treats OpenCode as a feature. Beacon's read: **v2.0 README
is more accurate to what shipped, more useful for new users picking a
harness, and less likely to trip an upgrader.**

### Angle 6 — Drift's challenge: do we need to bump yet?

This is the most legitimate challenge. The refactor is in-progress.
Until the OpenCode adapter actually works, claiming v1.1 (or v2.0)
final is premature.

**Pre-release tags exist for exactly this situation.** SemVer
specifies `MAJOR.MINOR.PATCH-PRERELEASE` (e.g. `2.0.0-alpha.1`).
Pre-release versions sort before their final counterpart and signal
"work in progress, do not depend on stability."

A staged rollout:

1. **`v2.0.0-alpha.0`** — Phase 1 of the proposal (`core/` extracted,
   no behavior change yet). Refactor in progress, dogfood internally.
2. **`v2.0.0-alpha.N`** (incrementing) — Subsequent commits during
   Phase 2 (Claude Code adapter migration).
3. **`v2.0.0-beta.0`** — Phase 2 complete: Claude Code adapter is
   functionally equivalent to v1.0.1. v1.0.1 still the recommended
   stable install.
4. **`v2.0.0-rc.0`** — Phase 3 done: OpenCode adapter scaffolded and
   passes basic round-trip session.
5. **`v2.0.0`** — Phase 4 done: bidirectional dogfood complete.
   Becomes the recommended install. v1.0.1 receives security fixes
   only.

This honors drift's "earns its keep" rule — the pre-release tags
match the actual phase boundaries in the proposal
(`docs/proposals/cross-platform-storytime.md:281-323`). It also
gives anchor a discipline gate: each promotion is an explicit
go/no-go decision, not a passive version drift.

**Conclusion: yes, bump — but stage it via pre-release tags
matching proposal phases. v1.1.0-alpha → v1.1.0 would also work
mechanically, but v2.0.0-alpha → v2.0.0 is the right *destination*
per angles 1, 2, and 5.**

### Angle 7 — Tooling precedent

`bump-version.sh` (`scripts/bump-version.sh:30-58`) is mechanical: it
takes a string argument and propagates it across `VERSION`,
`.claude-plugin/plugin.json`, `README.md`, all `SKILL.md` version-echo
blocks, and `site/*.html`. It does not care if the number is
`1.1.0`, `2.0.0`, `2.0.0-alpha.0`, or `99.0.0-rainbow`. The script
will need a layout update (paths to SKILL.md change after the
refactor) regardless of which version number we choose. The
update-layout work is independent of the version-number decision.

`migrate-to-v1.sh` (`scripts/migrate-to-v1.sh:1-242`) is the migration
precedent. It demonstrates the right shape: dry-run by default,
`--apply` for write mode, `--commit` for atomic git commit,
`--rollback` via git revert, marker-based detection so reruns are
safe, dry-run report written to `migration-report.md`. A
`migrate-to-v2.sh` should mirror this shape verbatim.

**Conclusion: tooling is ready for whichever number we pick. The
decision is purely communication.**

## Recommendation

**Bump to `v2.0.0`, staged via pre-release tags matching the proposal's
phase boundaries:**

| Stage              | Phase trigger                                  | Stable install recommendation |
|--------------------|------------------------------------------------|-------------------------------|
| `v2.0.0-alpha.0`   | `core/` extraction begins (Phase 1 starts)     | v1.0.1                        |
| `v2.0.0-alpha.N`   | Phase 2 in progress                            | v1.0.1                        |
| `v2.0.0-beta.0`    | Claude Code adapter passes equivalence dogfood | v1.0.1                        |
| `v2.0.0-rc.0`      | OpenCode adapter passes a real session         | v1.0.1                        |
| `v2.0.0`           | Bidirectional dogfood (Phase 4) complete       | v2.0.0                        |
| `v2.0.x` patches   | Bug fixes, lint additions                      | v2.0.x                        |

Migration is automated via a new `scripts/migrate-to-v2.sh` mirroring
`scripts/migrate-to-v1.sh`'s shape. v1.0.1 receives critical fixes
only, through a defined sunset window (recommend 2 quarters past
v2.0.0 GA).

### Why v2.0 not v1.1

1. **Install path changes** — Claude Code marketplace install path
   moves from repo root to `adapters/claude-code/`. SemVer-strictly,
   this is a breaking API change (angle 1).
2. **Migration is mandatory for upgraders** — even though it's
   automated and reversible, it must be run. The version number
   should match the upgrader's actual experience (angle 2).
3. **OpenCode is a new platform model, not a feature** — npm
   distribution, plugin TS code, hook system, multi-provider — these
   are fundamentally different from Claude Code's marketplace model.
   v1.1 ("we added a feature") under-states the change (angles 4, 5).
4. **README at v2.0 is more accurate** than at v1.1 (angle 5).
5. **Pre-release tags resolve the "soul unchanged" tension** —
   v2.0.0-alpha says "structurally we're working on a new line; the
   soul is preserved (see release notes); v1.0.1 is still the stable
   install." This is honest framing.

### Why pre-release tags

1. **Refactor is multi-phase** — declaring v2.0.0 final at the start
   of the work would mislead. Declaring v2.0.0-alpha.0 at the start
   announces "intent to ship v2.0, currently unstable."
2. **Drift's earns-its-keep rule** — each promotion (alpha → beta →
   rc → final) is an explicit gate. No passive version drift.
3. **SemVer-native mechanism** — pre-release tags are exactly the
   feature designed for this case. Not theater; correct usage.
4. **Phase-aligned** — alpha/beta/rc tags map cleanly to proposal
   phases 1/2/3/4 (`docs/proposals/cross-platform-storytime.md:281-323`),
   which gives every commit a clear "what stage am I in" answer.

### Beacon's adoption gate

The README must lead with **soul-continuity**, not feature-flash. The
v2.0 announcement says: "Storytime 2.0 — same soul, two harnesses."
This neutralizes the version-theater risk by making the framing
honest: the cross-platform model *is* a real change worth signaling,
*and* the soul *is* preserved.

### Drift's deferral check

Drift asked: "Could we ship a smaller v1.1 and defer the OpenCode
adapter?" — Yes, *if* the cross-platform refactor were optional. But
the proposal frames OpenCode as the second target *driving* the
core/adapters split. Without OpenCode, there's no reason to extract
`core/`. The refactor exists *because of* OpenCode. Deferring OpenCode
defeats the refactor's purpose. **The smaller v1.1 isn't a smaller
version of this — it's a different project (intent-graph maturation,
gearbox-collapse-rules tightening, etc.). Those should ship as v1.0.x
patches against the existing layout, not as a wrapper for this
refactor.**

## Confidence

**high** — The version-number decision has clean rationale tied to
SemVer's intent (API contract), the proposal's actual scope (paradigm
extension, not feature), the migration burden (mandatory script run),
and the framing tools available (pre-release tags + soul-continuity
README). The pre-release staging matches existing tooling precedent
(`migrate-to-v1.sh` shape) and proposal phase boundaries verbatim.

The only remaining ambiguity is the user-count question (angle 4
counter): if there is genuinely one user, the discipline argument for
v2.0 is mostly internal. But that's an argument for *not* skipping the
discipline, not an argument against it.

## Effort Estimate

- **Complexity:** 2 — Decision is communication-only. The mechanical
  work (`bump-version.sh` invocations, `migrate-to-v2.sh` authoring,
  README rewrites) is bookkeeping. The recommendation requires no new
  infrastructure beyond what `bump-version.sh` and `migrate-to-v1.sh`
  already provide. Authoring the v2 migration script is the largest
  surface and it's a copy-modify of the v1 script.

- **Scale:** 2 (small) — Touches `VERSION`, `.claude-plugin/plugin.json`,
  `README.md`, every `skills/*/SKILL.md` version-echo block (19 files
  per icebreaker), `site/*.html`, `scripts/bump-version.sh` (path
  updates), and adds `scripts/migrate-to-v2.sh`. About 25-30 files
  touched per bump cycle, all via existing automation. The pre-release
  staging multiplies the bump invocations (5 stages: alpha → final)
  but each invocation is identical work. No design surface, no test
  suite changes, no doc-system rework.

## Citations

- `/Users/alexevers/workspace/projects/storytime/VERSION:1` —
  current version 1.0.1                                              (code)
- `/Users/alexevers/workspace/projects/storytime/.claude-plugin/plugin.json:3` —
  plugin manifest version field                                      (code)
- `/Users/alexevers/workspace/projects/storytime/scripts/bump-version.sh:30-58` —
  bump propagation surface (VERSION, plugin.json, README, SKILL.md
  version-echo blocks, site HTML)                                    (code)
- `/Users/alexevers/workspace/projects/storytime/scripts/migrate-to-v1.sh:1-242` —
  migration script precedent (dry-run/apply/commit/rollback shape,
  marker detection, positive version stamping)                       (code)
- `/Users/alexevers/workspace/projects/storytime/docs/proposals/cross-platform-storytime.md:33-86` —
  the 10 soul priorities preserved by the refactor                   (repo doc)
- `/Users/alexevers/workspace/projects/storytime/docs/proposals/cross-platform-storytime.md:168-218` —
  proposed directory restructure (core/, adapters/, shared/)         (repo doc)
- `/Users/alexevers/workspace/projects/storytime/docs/proposals/cross-platform-storytime.md:281-323` —
  proposal's phase plan (Phase 0-5) — basis for pre-release staging  (repo doc)
- `/Users/alexevers/workspace/projects/storytime/docs/proposals/cross-platform-storytime.md:282` —
  "This is a v1.1 or v2.0 effort, not a v1.0.x patch"                (repo doc)
- `/Users/alexevers/workspace/projects/storytime/docs/proposals/cross-platform-storytime.md:325-329` —
  open question 2: "What version is this?"                           (repo doc)
- `/Users/alexevers/workspace/projects/storytime/specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:96-97` —
  constraint #1 (existing v1.0.1 installs must not break)            (repo doc)
- `/Users/alexevers/workspace/projects/storytime/specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:105-106` —
  V1.1-NNN decision numbering (separate from version number)         (repo doc)
- `/Users/alexevers/workspace/projects/storytime/skills/storytime/SKILL.md:1-15` —
  current Claude Code coupling (allowed-tools, version-echo)         (code)
- SemVer 2.0.0 spec, items 9 (pre-release identifiers) and 8 (MAJOR
  bump on backwards-incompatible changes) — basis for the alpha/beta/
  rc staging recommendation                                          (web/external)

## Open Questions

Returned to CONVERGE for plan-shaping:

1. **Sunset window for v1.0.x** — recommend "critical fixes through
   2 quarters past v2.0.0 GA" but the actual window depends on
   whether external adopters appear during the v2.0.0-alpha cycle.
   CONVERGE should set an explicit calendar date or commit-count
   threshold.

2. **Pre-release tag bump cadence** — should `v2.0.0-alpha.N`
   increment per-commit (noisy, accurate) or per-phase (quiet,
   summary)? Recommend per-phase-milestone with explicit
   `bump-version.sh` invocations on commits that change phase status.
   CONVERGE confirms.

3. **`migrate-to-v2.sh` design** — the migration is from v1.0.1's
   layout (root-level `skills/`, `agents/`, `.claude-plugin/`) to
   v2.0's layout (`adapters/claude-code/{skills,agents,.claude-plugin}/`
   plus `core/`). Should be a copy-of `migrate-to-v1.sh` with
   adjusted markers. **Owned by BO6** (Claude Code adapter migration
   safety) — version-bump-strategy hands this off cleanly.

4. **Compatibility window mechanism** — during v2.0.0-alpha/beta,
   users at v1.0.1 should still work. Does the repo root retain a
   stub `.claude-plugin/plugin.json` that points to
   `adapters/claude-code/`? Or do we ship a Claude Code marketplace
   tag for v1.0.x and the new layout becomes the v2.x install path
   only? **Owned by BO6** — version-bump-strategy flags the
   constraint.

5. **npm package name and scope** — beacon's BO5 owns npm distribution
   for the OpenCode adapter. Version-number coordination: when the
   npm package ships, does it ship as `@storytime/opencode-plugin@2.0.0`
   matching the repo, or does it have an independent version line?
   Recommend matched-version for the v2.0 line; revisit at v2.1+ if
   adapter cadence diverges.

## Participants

- **@owner [anchor]** (driver) — framed soul-vs-plumbing tension;
  weighed SemVer-strict reading vs concept-stability reading;
  proposed pre-release staging as the resolution that honors both
  framings; converged the recommendation.

- **@educator [beacon]** (supporter) — interjected on angle 5
  (concrete README/install-message comparison) showing v2.0 framing
  is more accurate to what shipped; flagged the soul-continuity
  framing as the antidote to version-theater risk.

- **@skeptic [drift]** (supporter) — challenged angle 6 ("do we need
  to bump yet?"); the challenge produced the pre-release-staging
  resolution. Drift's "earns its keep" rule is satisfied because each
  pre-release promotion is an explicit gate, not passive drift.
  Drift also stress-tested the deferral path ("could we ship a smaller
  v1.1?") and accepted the rebuttal: the refactor exists *because of*
  OpenCode, so deferring OpenCode invalidates the refactor itself —
  smaller v1.1 work is a different project (intent-graph patches,
  gearbox tightening) that ships as v1.0.x against the current layout.
