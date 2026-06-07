---
type: breakout
schema_version: 1
created: 2026-04-26T15:30
session: cross-platform-port
episode: 001
subtopic: npm-distribution
driver: "@educator [beacon]"
supporters: ["@platform [compass]"]
status: complete
---

# Breakout 5 — npm distribution + install UX

## Question

OpenCode plugins are distributed through npm and resolved at startup
(`Npm.add(pkg)` in `opencode/packages/opencode/src/plugin/shared.ts:211`).
Storytime today ships as a Claude Code plugin via
`claude install-plugin ~/path` (README.md:41) with content split between
markdown skills, agents, scripts, and a `.claude-plugin/plugin.json`
manifest at v1.0.1.

For OpenCode the install path needs to be a normal npm dependency that
appears in `opencode.json`'s `plugin` array. This breakout decides:
package name, single-vs-split publishing, version-sync strategy, install
UX, first-run experience, how the markdown content travels, and the
update story.

## What we know

1. **OpenCode plugin loading is npm-native.** Strings in
   `opencode.json`'s `plugin` array are resolved via
   `parsePluginSpecifier` (`shared.ts:22-34`); non-path specs hit
   `Npm.add()` and get cached at `~/.cache/opencode/node_modules/`
   (`plugins.mdx:48`). Path-style specs (`./plugin.ts`,
   `file://...`) load from disk instead (`config/plugin.ts:54-69`).

2. **Both regular and scoped names work.** `opencode-helicone-session`
   and `@my-org/custom-plugin` are both shown as valid in
   `plugins.mdx:36`. The ecosystem heavily favors unscoped
   `opencode-<thing>` (28+ packages in `ecosystem.mdx`); scoped is
   used by orgs like `@plannotator/opencode` and `@openspoon/subtask2`.

3. **OpenCode has a real compatibility gate.** `checkPluginCompatibility`
   in `shared.ts:194-205` reads `engines.opencode` (semver range) from
   the plugin's `package.json` and refuses to load if the running
   OpenCode version doesn't satisfy it. This is the canonical
   compatibility channel — not a custom field.

4. **OpenCode's own plugin SDK uses `@opencode-ai/plugin`.**
   `opencode/packages/plugin/package.json:2` — that scope belongs to
   OpenCode itself. We won't put our adapter under it.

5. **`exports` map drives install behavior.** `installPlugin` in
   `install.ts` walks `pkg.json.exports` for `./server` and `./tui`
   subpaths to figure out what kind of plugin it is, then patches the
   user's `opencode.json` with the right entry. A storytime plugin
   needs `exports["./server"]` to register as a server-side plugin.

6. **There is a CLI install flow.** `installPlugin` (`install.ts:259`)
   plus `patchPluginConfig` (`install.ts:421`) implement
   `opencode plugin install <spec>` — it resolves the package,
   reads its manifest targets, then atomically (`Flock.acquire`)
   patches the user's config to add the plugin to the `plugin: []`
   array. Users don't have to hand-edit JSON.

7. **GitHub org is `1ps0/storytime`** per repo memory. There is no
   established `@1ps0` npm scope, no `@storytime` scope (likely
   taken or unclear), no `@storytime-ai` scope yet established.

8. **Storytime's value-mass is markdown.** 19 skills, references,
   docs, examples — all `.md`. The TS plugin is the harness layer;
   the markdown is the soul. Distribution must ship both.

## What we don't know (and will commit to verify before publish)

- Whether the literal npm names below are claimed. The recommendation
  picks names that are highly likely available based on ecosystem
  scan but the actual `npm view` happens at publish time, not in
  this breakout.
- Whether OpenCode's `Skill` tool can resolve markdown paths inside
  an installed npm package's `node_modules` directory at runtime.
  BO4 (persona runtime) needs to confirm.

## Options considered

### Option A — Single unscoped package: `opencode-storytime`

One npm package. Bundles TS plugin code + all markdown skills + scripts.
User runs `bun add opencode-storytime` (or `opencode plugin install
opencode-storytime`) and is done.

- Pro: matches the dominant OpenCode ecosystem convention
  (`opencode-helicone-session`, `opencode-wakatime`,
  `opencode-skillful`, etc.).
- Pro: discoverable — `npm search opencode` finds it.
- Pro: one version, no sync problem.
- Pro: existing OpenCode `opencode plugin install` UX works as-is.
- Con: name doesn't telegraph that the same project has a Claude Code
  side. A fresh user reading the npm page won't know they're getting
  half of a cross-platform thing.
- Con: locks the npm name to the OpenCode adapter. If we later want
  `storytime-cli` or `storytime-vscode` we need new names.

### Option B — Scoped umbrella: `@storytime-ai/opencode`

Establish a `@storytime-ai` (or `@1ps0`) npm scope. The OpenCode
adapter lives under it, with sibling packages possible later
(`@storytime-ai/core`, `@storytime-ai/claude-code` if that ever
makes sense as an npm artifact, future `@storytime-ai/cli`).

- Pro: scope reservation gives us a coherent surface as the project
  expands cross-harness.
- Pro: telegraphs the project shape — `@storytime-ai/opencode` reads
  as "the OpenCode adapter for Storytime".
- Pro: scope ownership is one npm-org claim; namespaces are cheap.
- Con: scopes are slightly less searchable than unscoped names —
  a casual `npm search opencode` still finds it but ecosystem lists
  curated by `awesome-opencode` may default to unscoped.
- Con: requires one more thing to set up (the npm org) before first
  publish.

### Option C — Multi-package: `@storytime-ai/core` + `@storytime-ai/opencode`

Split the markdown content into a peer package. `@storytime-ai/core`
ships the markdown skills, references, examples. `@storytime-ai/opencode`
depends on `core` and provides the plugin glue. Future
`@storytime-ai/claude-code` would also depend on `core`.

- Pro: the markdown is genuinely shared; this models that.
- Pro: a future Claude Code adapter package could pull the same
  `core` and stay synced.
- Pro: matches the proposed architecture
  (`docs/proposals/cross-platform-storytime.md:166-196`) where
  `core/` is platform-agnostic.
- Con: real maintenance cost. Two packages, two version bumps, two
  release tracks, peer-dependency range to maintain. v1.x is too
  early for this.
- Con: OpenCode users still install one thing; the second package is
  a transitive dep they don't see. Splitting it into a separate
  publishable package adds cost without surfacing benefit.

### Option D — Unbundled markdown, fetch from GitHub

Plugin package is small TS. Markdown content is fetched on first run
from the storytime GitHub repo and cached locally.

- Pro: smallest npm tarball.
- Pro: markdown updates without re-publishing the plugin.
- Con: violates icebreaker constraint #6 — "no external network
  dependencies in the OpenCode adapter itself"
  (`icebreaker.md:101-103`). Disqualified.

## Recommendation

**Adopt a hybrid: scope reservation + single primary package.**

- Reserve npm scope `@storytime-ai` (preferred) or fall back to
  `@1ps0` (matches existing GitHub org). Whichever resolves first.
- Publish a single package: **`@storytime-ai/opencode`** (full name).
  Also reserve the unscoped `opencode-storytime` and either
  publish-mirror it or leave it as a deprecated alias pointer to
  the scoped package — claim the name so nobody else takes it.
- `@storytime-ai/opencode` bundles **both** the TS plugin and the
  full markdown content (skills, references, docs/, examples/) as
  package files. The plugin code resolves markdown paths relative
  to its own `import.meta.dir` so the `Skill` tool can find them
  inside `node_modules`.
- Do **not** split into `@storytime-ai/core` for v1.1. Defer the
  multi-package shape until a second adapter actually publishes
  (then refactor — earns-its-keep).

This satisfies:
- **compass's UX concern (clarity).** The scoped name tells users
  what they're installing; install completes via OpenCode's existing
  `opencode plugin install` flow.
- **discoverability.** Both `npm search opencode` and the
  `awesome-opencode` ecosystem listing surface us. Squatting the
  unscoped name prevents a future name collision.
- **icebreaker constraint #6** (no external network deps): the
  whole markdown payload ships in the tarball.
- **drift's earns-its-keep rule:** the multi-package split is
  deferred until a second publish target proves the cost.

### Compatibility / version-sync answer

Use OpenCode's native `engines.opencode` field plus a project-internal
`storytimeCompat` block:

```json
{
  "engines": {
    "opencode": ">=0.10.0 <2.0.0",
    "node": ">=20"
  },
  "storytime": {
    "coreVersion": "1.1.0",
    "schemaVersion": 1
  }
}
```

- `engines.opencode` is the runtime gate; OpenCode itself enforces
  it (`shared.ts:194`).
- `storytime.coreVersion` declares which storytime release line
  this plugin is from. Lint and `/storytime-status` compare against
  the user's optional `core/` checkout (if they have one).
- The plugin's npm package version follows storytime's main
  `VERSION` file. When storytime ships v1.1.0, the plugin publishes
  as `1.1.0` too. Sub-revisions of the plugin alone use a `-pluginN`
  suffix: `1.1.0-plugin2` if we ship a hotfix to the OpenCode
  adapter without bumping core.
- `bump-version.sh` (currently at
  `scripts/bump-version.sh:24-50`) gets a new step:
  `adapters/opencode/package.json` version field gets the same bump.

## Concrete `package.json` shape

```json
{
  "$schema": "https://json.schemastore.org/package.json",
  "name": "@storytime-ai/opencode",
  "version": "1.1.0",
  "description": "Storytime persona-driven narrative + continuity system as an OpenCode plugin. Driver-per-leg, breakouts, remembrance, decisions, callouts.",
  "type": "module",
  "license": "MIT",
  "author": { "name": "Alex Evers" },
  "homepage": "https://github.com/1ps0/storytime",
  "repository": {
    "type": "git",
    "url": "https://github.com/1ps0/storytime.git",
    "directory": "adapters/opencode"
  },
  "bugs": "https://github.com/1ps0/storytime/issues",
  "keywords": [
    "opencode",
    "opencode-plugin",
    "storytime",
    "personas",
    "specs",
    "narrative",
    "continuity",
    "remembrance",
    "decisions"
  ],
  "engines": {
    "opencode": ">=0.10.0 <2.0.0",
    "node": ">=20"
  },
  "exports": {
    ".": "./dist/index.js",
    "./server": "./dist/index.js",
    "./skills/*": "./skills/*.md",
    "./references/*": "./references/*.md"
  },
  "files": [
    "dist/",
    "skills/",
    "references/",
    "agents/",
    "scripts/",
    "examples/",
    "README.md",
    "CHANGELOG.md",
    "VERSION"
  ],
  "peerDependencies": {
    "@opencode-ai/plugin": ">=1.10.0"
  },
  "dependencies": {
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@opencode-ai/plugin": "^1.14.0",
    "typescript": "^5.4.0"
  },
  "storytime": {
    "coreVersion": "1.1.0",
    "schemaVersion": 1
  }
}
```

Notes on the shape:

- `exports["./server"]` is what makes
  `installPlugin` → `packageTargets` (`install.ts:145-166`)
  recognize this as a server-side plugin and patch
  `opencode.json` correctly.
- `exports["./skills/*"]` and `./references/*` give the plugin code
  programmatic access to its own bundled markdown via standard
  package-export resolution.
- `peerDependencies["@opencode-ai/plugin"]` keeps the SDK type
  surface external — typical pattern across the ecosystem.
- The custom `storytime` block at the end is a non-standard hint
  block — npm allows extra fields and OpenCode ignores them. Lint
  uses it to detect drift between plugin version and core.

## Install + first-run sequence

```text
$ opencode plugin install @storytime-ai/opencode
[opencode] resolving @storytime-ai/opencode@latest
[opencode] installing into ~/.cache/opencode/node_modules/
[opencode] reading manifest: 1 server target
[opencode] patching ~/.config/opencode/opencode.json
[opencode]   + plugin: ["@storytime-ai/opencode"]
[opencode] installed @storytime-ai/opencode@1.1.0

$ opencode
opencode v1.1.0
loading 1 plugin...
  @storytime-ai/opencode@1.1.0  (storytime)

[storytime] first run detected for this project.
[storytime]   .storytime/ not found at ./
[storytime]   run /storytime-bootstrap to initialize, or
[storytime]   /storytime "<problem statement>" to start a session.
[storytime]   skills available: /storytime, /storytime-survey,
[storytime]   /storytime-breakout, /storytime-converge, /storytime-buildout,
[storytime]   /storytime-cohort, /storytime-qa, /storytime-echo,
[storytime]   /storytime-pr-qa, /storytime-remember, /storytime-lint,
[storytime]   /storytime-bootstrap, /storytime-consolidate, /storytime-absorb,
[storytime]   /storytime-export, /storytime-status, /storytime-undo,
[storytime]   /storytime-retro
[storytime] hooks active: experimental.session.compacting,
[storytime]   tool.execute.before, command.execute.before
[storytime] persona runtime: 0 personas hired (cohort empty).
[storytime]   echo a voice with /storytime-echo "@<archetype> <prompt>"
[storytime]   bootstrap a starter cohort with /storytime-bootstrap

> _
```

The first-run banner is the answer to compass's discoverability
concern: the user sees, in plain text immediately after the first
post-install run, exactly what changed and what's now available.

### What changes in the user's `opencode.json`

Before install:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-4-5"
}
```

After `opencode plugin install @storytime-ai/opencode`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-4-5",
  "plugin": ["@storytime-ai/opencode"]
}
```

If the user wants to pass options (e.g. disable the compaction hook
override during testing) they can convert the entry to the tuple form:

```json
{
  "plugin": [
    ["@storytime-ai/opencode", {
      "config": {
        "remembranceHook": false,
        "tutorialMode": "auto"
      }
    }]
  ]
}
```

This shape is supported natively — `ConfigPlugin.Spec`
(`config/plugin.ts:14-17`) accepts both a string and a
`[string, options]` tuple.

## First-run experience — what the user sees

The plugin's `chat.message` (or earliest available) hook detects "first
session in this project" by looking for `.storytime/` and emits a
non-blocking banner. The banner:

1. Names the new commands (so users know `/storytime` exists).
2. Names the active hooks (so users know what changed under the hood —
   compaction handling, tool intercepts).
3. Tells them how to opt-in (`/storytime-bootstrap`) and how to opt-out
   (set `tutorialMode: "off"` in plugin options).
4. Stays out of the way — no modal, no required action. Users can
   ignore it and OpenCode keeps working.

This is critical for compass's clarity bar: install must not feel
like the harness was hijacked. The first-run banner makes the
storytime layer **legible without being intrusive**.

## Update story

OpenCode's npm install runs at startup
(`plugins.mdx:48` — Bun-driven). `bun update` or
`opencode plugin install @storytime-ai/opencode@latest` re-resolves.
Three update paths:

1. **Implicit update.** User has `"plugin": ["@storytime-ai/opencode"]`
   (no version pin). OpenCode resolves `@latest` at install time but
   caches the resolved version. To pull a new release the user runs
   `opencode plugin install @storytime-ai/opencode@latest --force`
   (uses `installPlugin`'s `force` parameter, `install.ts:259`).

2. **Pinned update.** User has `["@storytime-ai/opencode", { ... }]`
   with no version, or a string spec like
   `"@storytime-ai/opencode@1.1.0"`. They edit the spec to bump and
   restart OpenCode.

3. **Plugin-driven self-check.** On startup, the storytime plugin
   compares its own `package.json` version against the latest tag on
   `1ps0/storytime` (read-only fetch from GitHub releases — opt-in
   per `tutorialMode`). If a new version exists, it logs once:
   `[storytime] update available: 1.1.0 -> 1.2.0. run: opencode
   plugin install @storytime-ai/opencode@latest --force`. **Off by
   default** to honor "no external network deps" — only flips on if
   the user opts in via plugin options. compass: this is the
   "you'll know what's available without it being pushy" answer.

For breaking releases that change `engines.opencode` or
`storytime.schemaVersion`, the user gets a hard error from OpenCode's
own compatibility gate (`shared.ts:194-205`) and a soft error from
storytime lint comparing `storytime.schemaVersion` to existing
`.storytime/` artifacts. Both errors point at the same migration
script (or call out that one is coming).

## compass's interjection

> Two UX flags I want on record:
>
> 1. **Banner verbosity is a knob, not a constant.** The full
>    19-skill list above is right for *first run ever*; it's wrong
>    for *every project after that*. The plugin should detect
>    "user has used storytime in another project" via
>    `~/.config/opencode/storytime/seen.json` and show the short
>    form: `[storytime] active. /storytime-status to see state.`
>    Less noise as the user graduates.
>
> 2. **The post-install patch must be reversible.** OpenCode's
>    `patchPluginConfig` is atomic but not undoable from the user's
>    perspective. Document the literal one-line removal: edit
>    `opencode.json`, drop `"@storytime-ai/opencode"` from the
>    `plugin` array. The README must show this. Frictionless
>    install is great; frictionless *uninstall* is what builds
>    trust.

Both flags are accepted into the recommendation.

## Confidence

**High** on naming + single-package + bundled markdown + native
`engines.opencode` for compatibility. The OpenCode plugin loader code
directly supports every choice here.

**Medium** on the multi-package deferral. If buildout discovers that
markdown content needs to be *editable in place* by users (i.e. they
want to fork a skill), shipping it inside `node_modules` becomes
awkward and a `core/` package may be needed sooner. Watching for that
in BO4.

**Medium** on the implicit-update story. We're relying on users
either knowing OpenCode's plugin commands or noticing the optional
update banner. A buildout task should add `/storytime-status` output
to include "version: 1.1.0 (latest known: 1.2.0)" when network is
allowed.

## Effort estimate

- **Complexity: 2** — Set up npm org claim, add `package.json`,
  build script (TypeScript -> dist/), CHANGELOG. Most of the work
  is process (npm publish CI, version-sync hooks in
  `bump-version.sh`), not code. The plugin itself doesn't change
  to support distribution; only the surrounding metadata does.

- **Scale: 2 (artifact count)** — One new `package.json`, one
  `tsconfig.json`, one CHANGELOG, ~5-line addition to
  `bump-version.sh`, README rewrites for two adapters. Touches
  small number of files but they're load-bearing.

- **Scale: 1 (runtime cost)** — Distribution choice has zero runtime
  cost beyond what the plugin itself imposes (covered in BO4).

## Citations

- `/Users/alexevers/workspace/projects/storytime/README.md:38-49` — current Claude Code install instructions  (code)
- `/Users/alexevers/workspace/projects/storytime/.claude-plugin/plugin.json:1-9` — current Claude Code manifest at v1.0.1  (code)
- `/Users/alexevers/workspace/projects/storytime/VERSION:1` — current storytime version 1.0.1  (code)
- `/Users/alexevers/workspace/projects/storytime/scripts/bump-version.sh:24-50` — version propagation across files (will need OpenCode adapter step)  (code)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/plugin/package.json:1-49` — `@opencode-ai/plugin` shape we model after for `peerDependencies` and `exports`  (code)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/opencode/src/config/plugin.ts:14-17` — `ConfigPlugin.Spec` accepts string or `[string, options]` tuple  (code)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/opencode/src/plugin/shared.ts:22-34` — `parsePluginSpecifier` handles scoped + unscoped + version-suffixed names  (code)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/opencode/src/plugin/shared.ts:194-205` — `checkPluginCompatibility` reads `engines.opencode`; this is the canonical compatibility gate  (code)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/opencode/src/plugin/shared.ts:207-213` — `resolvePluginTarget` calls `Npm.add(pkg)` for non-path specs  (code)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/opencode/src/plugin/install.ts:128-166` — `packageTargets` walks `pkg.json.exports["./server"]` / `["./tui"]` to register plugin kind  (code)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/opencode/src/plugin/install.ts:259-281` — `installPlugin` resolves the package, prepares manifest  (code)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/opencode/src/plugin/install.ts:421-439` — `patchPluginConfig` atomically inserts the entry into user's `opencode.json`  (code)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/opencode/src/plugin/install.ts:181-257` — `patchPluginList` dedupes existing entries; supports `force` to overwrite  (code)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/web/src/content/docs/plugins.mdx:30-43` — official docs: both regular and scoped npm packages supported  (repo doc)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/web/src/content/docs/plugins.mdx:46-51` — npm cache at `~/.cache/opencode/node_modules/`, Bun-driven install  (repo doc)
- `/Users/alexevers/workspace/projects/storytime/opencode/packages/web/src/content/docs/ecosystem.mdx` — naming conventions across 28+ existing community plugins (`opencode-<thing>` dominates; scoped variants exist)  (repo doc)
- `/Users/alexevers/workspace/projects/storytime/docs/proposals/cross-platform-storytime.md:343-345` — proposal Q6: "Does the adapter ship as `@storytime/opencode-plugin` on npm?"  (repo doc)
- `/Users/alexevers/workspace/projects/storytime/docs/proposals/cross-platform-storytime.md:166-196` — proposed `core/` + `adapters/` directory layout  (repo doc)
- `/Users/alexevers/workspace/projects/storytime/specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:74-78` — beacon's framing: "BO5 owns this and the install-guide story"  (repo doc)
- `/Users/alexevers/workspace/projects/storytime/specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:101-103` — constraint #6: no external network deps in OpenCode adapter  (repo doc)
- `/Users/alexevers/workspace/projects/storytime/specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:60-65` — compass's clarity bar (UX matters)  (repo doc)

## Open questions returned

1. **npm scope ownership.** Reserve `@storytime-ai` (preferred) or
   `@1ps0` (matches GitHub org)? compass's lean: `@storytime-ai`
   reads more clearly to a fresh user; `@1ps0` is opaque without
   project context. Decision needs `@owner [anchor]`.

2. **Squat the unscoped name?** Should we publish a stub
   `opencode-storytime` (or claim it via empty placeholder) so the
   ecosystem listing entry is unambiguous and nobody else can take
   it? My recommendation: yes, but it's a 5-minute task that needs
   `@owner [anchor]` sign-off on registry hygiene.

3. **Markdown content access from inside `node_modules`.** Can the
   `Skill` tool resolve a path like
   `node_modules/@storytime-ai/opencode/skills/storytime/SKILL.md`?
   Or does it expect skills under `.opencode/skills/`? BO4 needs to
   answer because the install UX above assumes the former. If the
   latter, install must symlink/copy on first run — adding a real
   side effect to install that compass will scrutinize.

4. **CI publishing flow.** Who pushes to npm — the `bump-version.sh`
   script, a GitHub Actions release workflow, or a manual
   `npm publish` from the maintainer's machine? v1.1 launch can be
   manual; v1.2 should be CI. Owner's call but flagging now so
   buildout doesn't surprise us.

5. **Self-check banner network policy.** The opt-in update-check
   needs a clear privacy story. If it pings GitHub releases, we're
   sending one HTTPS request per OpenCode startup that has the
   plugin enabled. drift will have opinions. Default off; document
   what flipping it on entails.

## Rollback story

The OpenCode adapter is **additive-only** to the v1.0.1 surface. It
introduces:

- A new directory `adapters/opencode/` (does not touch existing
  `skills/`, `agents/`, `.claude-plugin/`).
- A new package published under `@storytime-ai/opencode`.
- A new step in `bump-version.sh` for the OpenCode `package.json`.

To roll back the npm distribution layer specifically:

1. **Unpublish or deprecate the npm package.**
   `npm deprecate @storytime-ai/opencode@1.1.0 "rolled back"`.
   Existing installs continue to work; new installs see the warning.
2. **Remove `adapters/opencode/` from main.** Single directory delete.
3. **Revert the `bump-version.sh` step.** Single line change.
4. **No changes needed in Claude Code adapter** — it never depended on
   the OpenCode npm layer.

User-side rollback: edit `opencode.json`, remove
`"@storytime-ai/opencode"` from the `plugin` array, restart. The plugin
cache at `~/.cache/opencode/node_modules/@storytime-ai/opencode/` can
be deleted or left; OpenCode ignores it once the config no longer
references it.

## Participants

- **@educator [beacon]** (driver) — framed npm packaging problem,
  surveyed OpenCode plugin loader internals, drafted the
  `package.json` shape and install/first-run sequence,
  evaluated single-vs-multi-package trade-offs against `core/`
  proposal, structured update story.
- **@platform [compass]** (supporter) — interjected on UX clarity:
  banner verbosity should graduate, install must be reversibly
  documented. Both flags accepted into the recommendation. Pushed
  for the explicit "what changes in `opencode.json`" diff.
