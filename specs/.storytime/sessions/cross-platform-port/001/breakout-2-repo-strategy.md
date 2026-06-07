---
type: breakout
schema_version: 1
created: 2026-04-26T14:35
session: cross-platform-port
episode: 001
topic: cross-platform-port
subtopic: repo-strategy
driver: "@domain [arbor]"
supporters: ["@critic [forge]", "@educator [beacon]"]
supporters_who_spoke: ["@critic [forge]", "@educator [beacon]"]
status: complete
---

# Breakout 2 — Repo Strategy (monorepo vs split vs workspaces)

## Question

The proposal sketches `core/`, `adapters/claude-code/`, `adapters/opencode/`,
`shared/` (proposal:168-196). Where do these live? Three candidates:

1. **Single repo (subdirectory monorepo).** All four roots inside one
   git repo. No per-package publishing tooling.
2. **Split repos.** `storytime-core`, `storytime-claude-code`,
   `storytime-opencode` as three independent repos.
3. **Monorepo with workspace publishing.** One repo, `packages/` layout
   à la OpenCode's own bun workspaces (`opencode/package.json:23-29`),
   each package independently publishable.

Plus four sub-questions: concrete tree of the recommendation, root-file
inventory, where `specs/.storytime/` self-dogfood state lives, and how
a new user discovers + installs each adapter.

## Problem framing

**@domain [arbor]:** This is an information-architecture call before
it's a tooling call. The decision shape is: *what's the smallest unit
a user installs*, *what's the smallest unit we ship together*, and
*what's the smallest unit we change atomically*. Today (v1.0.1) those
three are the same thing — one repo, one plugin, one ship target. The
moment we add an OpenCode adapter, the three diverge. We need to pick
a layout where atomic-cross-cutting-changes still feel like one thing
to us, while installs still feel like one thing to a user.

**@critic [forge]:** Earns-its-keep on the abstraction. We have *one*
adapter today (Claude Code) and *one planned* (OpenCode). A `core/`
directory factored to support N adapters when N≤2 is exactly the
"premature factoring" Mythical Man-Month warned about. The risk isn't
inventing core/ — it's enshrining its API surface before the second
adapter has revealed what's actually shared. Anything we put into
core/ that turns out to be Claude-Code-shaped costs us re-work twice
(once now to extract, once later to re-shape). Defer the abstraction
to *follow* the second adapter, not lead it.

**@educator [beacon]:** Adoption-friction last-call. Right now the
install path is `/plugin install storytime@<marketplace>` — one verb,
one noun. If the v1.1 layout makes a Claude Code user type
`/plugin install ~/storytime/adapters/claude-code` (literal path with
a subdirectory) and an OpenCode user `bun add @storytime/opencode-plugin
&& edit opencode.json`, we've turned a two-second install into a
three-paragraph paragraph in two different systems' vocabularies. The
adapter's *root* needs to look like the install target each ecosystem
expects, or we lose the casual user.

## Options analysis

### Option 1 — Single repo, subdirectory monorepo

```
sst/storytime/
├── core/              shared markdown + conventions
├── adapters/
│   ├── claude-code/   plugin shape (skills/, .claude-plugin/, agents/)
│   └── opencode/      TS plugin (plugin.ts, .opencode/, opencode.json)
├── shared/            scripts, lint, specs/.storytime
└── (root: README, LICENSE, VERSION, BACKLOG, scripts/, docs/, site/)
```

**Pros.** One source of truth. Atomic cross-cutting changes (refactor a
markdown reference once, both adapters pick it up). One CI pipeline,
one VERSION file, one BACKLOG. Dogfood-on-self stays trivial — the
repo runs storytime on itself today and that doesn't change.

**Cons.** Install path is awkward for both adapters: Claude Code expects
the plugin at the *root* of a marketplace entry (`.claude-plugin/plugin.json`
at the top), OpenCode expects an npm package whose name is what users
import. A subdirectory adapter requires either (a) marketplace
indirection that points at the subdir, or (b) a publish step that
extracts the subdir to a new artifact — at which point we've recreated
Option 3's tooling without its benefits.

**Beacon flag.** This is the option that breaks installs the worst.
The current plugin lives at the *root* of `sst/storytime`; moving it
under `adapters/claude-code/` requires every existing v1.0.1 user to
update their marketplace entry. That's a hard adoption-friction hit
even if the migration script is clean.

### Option 2 — Split repos

```
sst/storytime-core             markdown + conventions only
sst/storytime-claude-code      Claude Code plugin (current shape)
sst/storytime-opencode         OpenCode TS plugin
```

**Pros.** Each repo is technologically homogeneous (markdown / Claude
plugin / TS workspace). Each repo's audience is clear. Each adapter
ships independently. No subdirectory-install awkwardness. `storytime-core`
can be a git submodule, an npm package, or a vendored copy in each
adapter — each adapter picks its preferred consumption.

**Cons.** Cross-cutting changes touch three repos with three PRs and
three release coordinates. Version-skew is real: a change in core/
that requires both adapters to update lands as three commits in three
places, atomic only if all three CIs pass. Dogfood-on-self gets weird —
which repo runs `/storytime` *on storytime*? The meta-repo has to be
the union, but the union doesn't exist as a checkout. Decision logs
fragment across three histories, hurting the intent-graph cross-
references that V1-031..V1-036 just installed.

**Forge flag.** This option does *not* save us from premature
abstraction — it makes it worse. Splitting `storytime-core` into a
separate repo means we have to define its public API *before* a second
adapter has tested it. With one repo, core/ can be a directory whose
contents shift as we learn; with three repos, core/ is a published
contract.

### Option 3 — Monorepo with workspace publishing (bun/npm workspaces)

```
sst/storytime/
├── package.json                  workspaces: ["packages/*"]
├── packages/
│   ├── core/                     @storytime/core (markdown bundle)
│   ├── claude-code-plugin/       (Claude Code adapter; published as
│   │                              marketplace entry, not npm)
│   └── opencode-plugin/          @storytime/opencode-plugin (npm)
├── (root: README, LICENSE, VERSION, BACKLOG, scripts/, docs/, site/,
│  specs/.storytime/)
```

Mirrors OpenCode's own monorepo (`opencode/package.json:23-29`,
`opencode/packages/plugin/package.json:1-50`).

**Pros.** Atomic cross-cutting changes (one PR, one repo). Each package
publishes independently with its own version; consumers install only
what they need. One CI, but per-package build/test gates.

**Cons.** Introduces bun/npm tooling to a project whose only TS surface
is going to be the OpenCode adapter. The Claude Code "package" doesn't
publish to npm at all (it's a marketplace plugin), so it's a degenerate
workspace member that exists only for layout symmetry. The cost of
adding `package.json` + workspaces to a markdown-heavy repo is
non-trivial: lock files, install steps in CI, dependabot noise, and
the conceptual overhead of "is core/ a published package?" when it's
really a docset.

**Forge flag.** This option *also* enshrines the abstraction
prematurely — `@storytime/core` as a published npm package is a
public API contract before it has its second consumer. The published-
package shape locks in cross-package import paths early, which is the
exact thing we want to keep flexible.

## Recommendation

**Option 1 with two refinements**, plus a deferred path to Option 3:

> **Single repo, subdirectory monorepo, with adapter-rooted symlinks
> (or marketplace pointers) so each adapter looks like a root install
> target to its host ecosystem. Defer Option 3's workspace publishing
> until/unless a third harness or external consumer of `core/`
> appears.**

The two refinements:

1. **`adapters/claude-code/.claude-plugin/plugin.json` is the canonical
   manifest location after migration.** The marketplace symlink points
   at `adapters/claude-code/`, not at the repo root. Migration moves
   `.claude-plugin/plugin.json` into the adapter dir and updates the
   one-line marketplace entry. v1.0.1 users get a one-paragraph
   migration note: *"the marketplace entry's path changed from
   `storytime/` to `storytime/adapters/claude-code/`."* Owned by BO6.

2. **`adapters/opencode/` ships as a single npm package
   `@storytime/opencode-plugin`** via a publish-from-subdir step in
   CI. The package's `package.json` lives in the adapter dir; the rest
   of the repo is invisible to npm consumers. No bun workspace
   needed; just `npm publish` from `adapters/opencode/`. This is
   exactly how unrelated tooling repos publish from subdirs every day.

Why Option 1 over Option 3:

- **Forge's earns-its-keep test passes for Option 1; fails for Option 3.**
  Workspace publishing assumes `core/` will be consumed by external
  packages. Until a third adapter exists, `core/` is consumed only by
  the two adapters in the same repo, which can read it as a sibling
  directory at zero cost. Adding bun/npm tooling now buys nothing the
  filesystem doesn't already give us.
- **Beacon's adoption-friction is solved by the publish-step
  refinement, not by the workspace.** What matters to a user is the
  install verb, not the source layout. Claude Code users see
  `/plugin install storytime@<marketplace>` (unchanged after marketplace
  pointer update). OpenCode users see `bun add @storytime/opencode-plugin`
  (the npm name is what they touch; the repo subdir is invisible).
- **Cross-cutting changes stay atomic.** One PR, one VERSION bump, one
  BACKLOG.md, one specs/.storytime/.
- **Dogfood-on-self stays trivial.** `specs/.storytime/` lives at the
  repo root next to `adapters/` and `core/`; storytime runs on
  storytime exactly as it does today.

The recommendation is consistent with proposal:284-287 ("Recommend:
subdirectories first, separate later if adapters diverge").

## Concrete directory tree (recommended)

```
sst/storytime/                       Single repo, subdirectory monorepo.
│
├── README.md                        Top-level intro: "storytime is a
│                                    persona-driven framework with
│                                    adapters for Claude Code and
│                                    OpenCode." Links to each adapter's
│                                    install guide.
├── LICENSE                          MIT (one license, one repo).
├── VERSION                          Single source of truth, propagated
│                                    by scripts/bump-version.sh into
│                                    both adapters' manifests.
├── BACKLOG.md                       Cross-adapter backlog.
├── CHANGELOG.md                     Cross-adapter changelog (added in
│                                    v1.1; one history wins).
├── CONTRIBUTING.md                  How to contribute to either adapter
│                                    or core/.
├── package.json                     OPTIONAL — only if/when we adopt
│                                    Option 3. Absent in v1.1.
│
├── core/                            Platform-agnostic markdown library.
│   ├── conventions/                 Frontmatter shapes, callout grammar,
│   │                                decision-id formats.
│   ├── lifecycle/                   Phase sequence, consolidation rules,
│   │                                gearbox doctrine.
│   ├── references/                  All references/ moved from
│   │                                skills/storytime/references/ —
│   │                                shared by both adapters via
│   │                                relative-path includes.
│   ├── docs/                        Process docs that don't depend on
│   │                                a specific harness.
│   └── examples/                    Example sessions, persona
│                                    templates, ASCII-aid catalog.
│
├── adapters/
│   ├── claude-code/                 Claude Code adapter.
│   │   ├── README.md                Install: `/plugin install
│   │   │                            storytime@<marketplace>` after
│   │   │                            marketplace points here.
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json          Manifest (moved from repo root).
│   │   ├── skills/                  Skill SKILL.md files. Markdown
│   │   │   │                        bodies relative-link to
│   │   │   │                        ../../core/references/*.md.
│   │   │   ├── storytime/SKILL.md
│   │   │   ├── storytime-breakout/SKILL.md
│   │   │   └── ...                  (all 19 current skills)
│   │   ├── agents/                  breakout-runner.md, dreamer.md,
│   │   │                            estimator.md.
│   │   └── commands/                (if any slash-commands beyond
│   │                                skills auto-discovery)
│   │
│   └── opencode/                    OpenCode adapter (TS).
│       ├── package.json             name: "@storytime/opencode-plugin"
│       │                            version mirrors top-level VERSION.
│       │                            published to npm from this dir.
│       ├── README.md                Install: `bun add
│       │                            @storytime/opencode-plugin` +
│       │                            opencode.json snippet.
│       ├── tsconfig.json
│       ├── src/
│       │   ├── index.ts             Plugin entry (returns Hooks).
│       │   ├── persona-runtime.ts   Driver-per-leg state machine.
│       │   ├── hooks/               compaction, tool.before/after,
│       │   │                        chat.message intercepts.
│       │   └── tools/               Storytime-specific tool definitions
│       │                            (Effect/Zod, à la opencode/packages/
│       │                            plugin/src/tool.ts).
│       ├── .opencode/
│       │   ├── agent/               Static agent declarations that
│       │   │                        wrap the persona runtime.
│       │   └── command/             Slash commands.
│       └── opencode.json            Local config showing the plugin in
│                                    action; users copy into theirs.
│
├── shared/                          Cross-cutting utilities.
│   ├── scripts/                     bump-version.sh, check-conventions.sh,
│   │                                intent-graph-query.sh, etc. Most
│   │                                of these only touch markdown +
│   │                                specs/.storytime; they're already
│   │                                adapter-agnostic.
│   └── lint/                        Lint rule definitions.
│
├── specs/                           SELF-DOGFOOD. Storytime running on
│   └── .storytime/                  storytime itself. Lives at the
│       ├── cohort/                  REPO ROOT (under specs/), NOT
│       ├── history/                 inside any adapter — because the
│       ├── sessions/                state IS cross-adapter (we may run
│       ├── archive/                 the next session in OpenCode and
│       ├── specialists/             have it pick up the same cohort).
│       └── config.md
│
├── docs/                            Repo-meta docs (architecture
│                                    overviews, comparisons,
│                                    proposals/). NOT process docs;
│                                    those moved to core/docs/.
│
└── site/                            storytime.dev source (the public
                                     site). One site, both adapters.
```

(33 lines — single tree, full enough to read top to bottom.)

## Where `specs/.storytime/` lives — and why at the root

`specs/.storytime/` is **storytime running on storytime itself** —
the cross-platform-port session this very breakout is part of.

It must live at the **repo root** for three reasons:

1. **Adapter-agnosticism.** The state describes decisions, sessions,
   personas, and intent-graph nodes that are true *of storytime*, not
   *of one harness*. If we move it under `adapters/claude-code/`, we
   imply that the team's memory is Claude-Code-shaped. It isn't.
2. **Cross-harness dogfood.** The principle "we use storytime on
   storytime" requires the next storytime session to be runnable in
   either harness against the same state. Cohort, decision log,
   session archive must be at a path both adapters can read. Repo
   root is the only path that satisfies both.
3. **Existing convention.** `docs/multi-repo-distribution.md:73-94`
   already establishes `specs/.storytime/` as the per-project state
   location — this is unchanged. The breakout reaffirms it.

In **Option 2 (split repos)** this principle would have broken — there
would be no single repo to host the state, or it would have lived in
the meta-repo and forced cross-repo joins for cohort lookup. That
alone is sufficient grounds to reject Option 2 even before counting
the workflow costs.

## Root-file inventory (recommended option)

| File | Purpose | Notes |
|------|---------|-------|
| README.md | Top-level intro + link table | Lists both adapters and links to per-adapter READMEs. |
| LICENSE | MIT (or current) | One license for the repo. |
| VERSION | Single source of truth | Propagated by `bump-version.sh` into both adapters. |
| BACKLOG.md | Cross-adapter backlog | Items tagged `[claude-code]` / `[opencode]` / `[core]`. |
| CHANGELOG.md | Cross-adapter changelog | Added in v1.1; one history wins. |
| CONTRIBUTING.md | How to contribute | Section per adapter + core. |
| .gitignore | Standard ignores | Plus `adapters/opencode/node_modules/`, `dist/`. |
| .gitattributes | LF-only enforcement (if used) | Optional. |
| package.json | (absent in v1.1) | Reserved for future Option 3 migration. |

Per-adapter roots get their own README.md (install + walk-through),
and the OpenCode adapter root additionally gets `package.json`,
`tsconfig.json`, and (after publish) a published npm artifact.

## Forge's challenge — does core/ buy us anything?

Forge raised the premature-abstraction concern: *if there's only one
real adapter shipping today, what does core/ actually do?*

**Answer: in v1.1, core/ is a directory move, not an abstraction.**

The recommendation is to physically move `skills/storytime/references/`
to `core/references/` and have both adapters' skills/SKILL.md bodies
relative-link to it. That move is net-zero effort beyond rewriting
paths and yields net-positive when the OpenCode adapter wants to load
the same references via OpenCode's Skill tool. There is no API
between core/ and adapters/ in v1.1 — only filesystem paths.

The actual abstraction (a `dispatch_breakout(driver, supporters,
problem)` interface, persona runtime contracts, etc.) emerges in
v1.2+ as breakouts 4 and 6 actually find the seams. Until those
seams are found by *building*, core/ stays a docset.

**Forge accepts this framing** with one condition: the v1.1 plan's
buildout must explicitly check, when each piece moves into core/,
*"is this Claude-Code-shaped?"* If yes, it stays in
`adapters/claude-code/`. The default is "leave it where it is";
core/ takes only what's already harness-neutral. This is a
consolidation-loop concern: extract on the second use, not the first.

## Beacon's adoption angle — discovery and install

Beacon raised the install-friction concern: *Claude Code users
expect a marketplace install; OpenCode users expect npm. The repo
shape can't break either.*

**Per-ecosystem install paths under the recommendation:**

| Ecosystem | Install command (v1.1) | What changed from v1.0.1 |
|-----------|------------------------|---------------------------|
| Claude Code (marketplace) | `/plugin install storytime@<marketplace>` | Marketplace entry now points at `adapters/claude-code/` instead of repo root. **One-line manifest update for the marketplace; user-facing command unchanged.** |
| Claude Code (direct symlink, per `multi-repo-distribution.md:55-67`) | `ln -s ~/storytime/adapters/claude-code ~/.claude/plugins/.../external_plugins/storytime` | Path adds `/adapters/claude-code` suffix. Documented in BO6 migration guide. |
| OpenCode | `bun add @storytime/opencode-plugin` + `opencode.json` plugin entry | New install path; never existed in v1.0.x. Native npm install. |

The OpenCode user *never* sees the storytime monorepo in their
install verb. They see the npm name `@storytime/opencode-plugin`,
which is what `adapters/opencode/package.json` declares. The
subdirectory shape is publish-time invisible — npm publishes from
`adapters/opencode/` and the published artifact has no concept of
the repo around it.

**The Claude Code user's marketplace install is a one-line fix**
(the marketplace's `external_plugins/storytime/` symlink target
gains `/adapters/claude-code`). Owned by BO6's migration plan.

**Beacon accepts this** with one ask: the per-adapter README.md
must be the canonical install doc, NOT the repo root README. Repo
root README is for "what is storytime"; per-adapter README is for
"how do I install it on Claude Code / OpenCode." This is a
core-doctrine call (proposal:163-165) and the recommendation upholds
it.

## Confidence

**High** on the qualitative recommendation (Option 1 with refinements);
**medium** on the exact subdirectory names.

The rejected options have hard cons: Option 2 breaks self-dogfood and
fragments decisions; Option 3 introduces tooling without buying
anything for two-adapter scope. Option 1 with the publish-from-subdir
refinement is what every two-package-repo I've seen in the wild does
(small TS libraries hosted next to docs, GitHub Actions repos
publishing both an action and a CLI from one repo, etc.).

The medium dimension is naming — `core/` vs `framework/` vs
`storytime/`, `adapters/` vs `harnesses/`, `shared/` vs `tools/`.
These are aesthetics. CONVERGE picks the names; the structure stands.

## Effort Estimate

- **Complexity: 5 — multi-file move with cross-references.** Tractable.
  The complexity is not in deciding the layout (this breakout) but in
  executing it without breaking v1.0.1 installs (BO6 owns that).
  Concrete moves:
  - `git mv skills/ adapters/claude-code/skills/` (T=1)
  - `git mv agents/ adapters/claude-code/agents/` (T=1)
  - `git mv .claude-plugin/ adapters/claude-code/.claude-plugin/` (T=1)
  - `git mv skills/storytime/references/ core/references/` and rewrite
    `references/<name>.md` callsites in skill bodies (T=3 — long tail
    of cross-references in markdown)
  - Create empty `adapters/opencode/` scaffold (T=1; BO4/BO5 fill it)
  - Update `scripts/bump-version.sh` to know about
    `adapters/claude-code/.claude-plugin/plugin.json` location (T=2)
  - Marketplace entry one-line update (T=1)
  - README.md rewrite at repo root + per-adapter (T=3)
  Aggregate is Complexity 5; each step is small and testable in
  isolation.

- **Scale: 2 (single repo) — tightly bounded.** The blast radius is
  exactly one repo. No external consumers of `core/` exist yet, so
  no downstream breakage. The only externally-visible surface is the
  marketplace pointer (one line) and the install path documented in
  README. The `references/` cross-link rewrite touches ~25 markdown
  files (per `skills/storytime/references/*.md`, 25 files counted),
  but they're all in this repo and a single sed pass + lint check
  catches drift. Not scale-1 (>1 file changes), not scale-3 (no
  multi-repo coordination). Sits squarely at scale-2: bounded
  refactor with file fan-out.

## Citations

- `docs/proposals/cross-platform-storytime.md:168-196` — proposed
  architecture sketch this breakout concretizes.                (proposal)
- `docs/proposals/cross-platform-storytime.md:284-287` — phase-0
  recommendation: "subdirectories first, separate later if adapters
  diverge." Recommendation aligns.                              (proposal)
- `docs/proposals/cross-platform-storytime.md:262-267` — risk #4:
  v1.0.1 installs must not break during refactor. Solved by adapter-
  rooted marketplace pointer + BO6 migration script.            (proposal)
- `docs/multi-repo-distribution.md:55-67` — direct-symlink install
  pattern, current path. Path gains `/adapters/claude-code` suffix.
                                                                (repo doc)
- `docs/multi-repo-distribution.md:73-94` — `specs/.storytime/` lives
  per-project (at repo root). Recommendation reaffirms.         (repo doc)
- `opencode/package.json:23-29` — bun workspaces example for
  reference (Option 3 shape; rejected for v1.1).                (code)
- `opencode/packages/plugin/package.json:1-50` — example of an
  individually-publishable workspace package; informs how
  `adapters/opencode/package.json` should look.                 (code)
- `opencode/packages/sdk/js/package.json:1-20` — multi-export package
  shape; informs OpenCode-adapter package layout if we expose
  sub-paths.                                                    (code)
- `.claude-plugin/plugin.json:1-9` — current manifest at repo root;
  moves to `adapters/claude-code/.claude-plugin/plugin.json`.   (code)
- `skills/storytime/SKILL.md:1-263` — current Claude-Code-shaped
  skill at the root of `skills/` (263 lines). Moves under adapter.
                                                                (code)
- `skills/storytime/references/` (25 files, ~3.6k lines per
  `wc -l` enumeration) — content moves to `core/references/`.   (code)
- `scripts/bump-version.sh:1-30` — needs an update to know the new
  manifest path; existing style stays.                          (code)
- `specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:53-55`
  — arbor's BO2 charter: "concrete directory trees, not just
  principles." This breakout discharges that.                   (session)
- `specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:88-90`
  — sub-problem table assigning BO2 to @domain [arbor] with
  forge + beacon supporters.                                    (session)
- `specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:94-105`
  — constraints (v1.0.1 installs must not break, atomic writes,
  earns-its-keep, rollback story per breakout). Recommendation
  honors all.                                                   (session)
- `specs/.storytime/sessions/v1-consolidation/001/breakout-6-migration-path.md:54-72`
  — pattern reference for breakout shape and citation style.    (session)

## Open Questions (returned to CONVERGE)

1. **Naming.** `core/` vs `framework/` vs `storytime/` for the platform-
   agnostic library. `adapters/` vs `harnesses/`. `shared/` vs `tools/`.
   Aesthetic; CONVERGE picks.

2. **Adapter-rooted marketplace pointer mechanism.** Does the Claude Code
   marketplace (Anthropic's) accept a sub-path pointer in the
   marketplace entry, or does it require the manifest at the repo
   root? **Verification needed before BO6's migration script is
   final.** If marketplace requires repo-root manifest, we have two
   workarounds: (a) keep `.claude-plugin/plugin.json` at the repo
   root as a compatibility shim that re-exports from
   `adapters/claude-code/`, or (b) the marketplace symlink itself
   targets the subdirectory (per `multi-repo-distribution.md:55-67`,
   which already supports this for direct-symlink installs). Either
   works; CONVERGE picks.

3. **OpenCode adapter publishing flow.** Publish from subdir via
   `cd adapters/opencode && npm publish`, or set up a release script
   in `scripts/`? Owned by BO5.

4. **`shared/scripts/` vs root `scripts/`.** Current scripts live at
   the repo root. The proposal puts them under `shared/`. Question:
   does anything break if we leave them at root and only the
   *new* shared utilities go under `shared/`? Recommendation: leave
   existing `scripts/` at repo root; add `shared/lint/` only when
   the linter has cross-adapter rules. Earns-its-keep — don't move
   what isn't pulling its weight.

5. **`docs/` vs `core/docs/`.** The proposal puts process docs under
   `core/docs/` and meta docs at root `docs/`. Question: how do we
   tell the difference algorithmically (so lint can enforce)? Tentative
   rule: anything that defines a *storytime convention* (decision
   format, callout grammar) is core/docs/; anything *about the repo*
   (architecture overview, comparisons) is root docs/. Refine in
   CONVERGE.

6. **Migration of `site/`.** The public site is one site, both
   adapters; does it stay at repo root or move to `shared/site/`?
   Recommendation: stay at root. The site is a repo-level artifact,
   not a shared utility.

7. **Future-proofing for Option 3.** If we ever do introduce a third
   adapter or external `core/` consumer, the move from this layout
   to a workspace layout is mechanical: add `package.json` at root,
   move `core/` and `adapters/*/` under `packages/`. The current
   recommendation does NOT preclude that future move; it just
   refuses to pay for it now.

## Rollback

The recommendation is **executed by BO6's migration script**, not by
this breakout. Rollback is therefore a property of BO6's script:
`git revert` of the single migration commit, or
`git checkout <pre-migration-sha> -- .` to restore.

For *this breakout's recommendation itself* — adopting Option 1 — the
rollback is the literal decision text: if we discover during BO4 or
BO5 that the OpenCode adapter requires workspace tooling (e.g., it
needs to depend on a published `@storytime/core`), we revisit the
recommendation in CONVERGE and may upgrade to Option 3. The cost of
that upgrade later is the same as the cost of doing it now, plus the
benefit of having the second adapter actually built to inform the
choice. Earns-its-keep.

## Participants

- **@domain [arbor]** (driver) — framed the IA decision as install-
  shape × ship-shape × atomic-change-shape, surfaced the divergence at
  the point of adding the second adapter, recommended Option 1 with
  publish-from-subdir refinement, produced the concrete tree, located
  `specs/.storytime/` at repo root and gave the three-fold rationale
  (adapter-agnosticism, cross-harness dogfood, existing convention).
- **@critic [forge]** (supporter) — flagged premature abstraction in
  Option 3's published `@storytime/core`, pushed for "directory move,
  not abstraction" framing of core/ in v1.1, accepted Option 1 with
  the condition that v1.1 buildout explicitly tests each `core/`
  candidate against "is this Claude-Code-shaped?" and leaves it in
  the adapter if yes.
- **@educator [beacon]** (supporter) — flagged install-friction in
  Option 1's naive form (subdir-as-install-path), produced the
  per-ecosystem install table, secured the publish-from-subdir
  refinement that keeps each adapter's user-facing install verb
  native, secured the per-adapter README.md as the canonical install
  doc.
