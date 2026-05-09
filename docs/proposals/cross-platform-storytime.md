---
type: proposal
schema_version: 1
created: 2026-04-26T13:00
name: cross-platform-storytime
status: exploration
session: null
---

# Cross-Platform Storytime — Core + Harness Adapters

User-directed strategy: refactor main storytime to a platform-agnostic
core, with adapters per LLM-coding harness. Claude Code adapter mirrors
current behavior. OpenCode adapter is the second target. Future harnesses
get adapters as needed.

## Scope decision (from user)

> "Cross-platform abstraction — refactor main storytime first."
>
> "Capture the soul of storytime and bring opencode into a more flexible
> paradigm perspective/role/persona-wise."

This is the slowest to first OpenCode user, but the strategy that doesn't
trap us into either (a) maintaining two codebases or (b) shipping a thin
shim that loses storytime's programmatic features. **And critically, the
adapter is not a translation layer that accommodates OpenCode's
limitations — it's a paradigm extension that brings storytime's
fluidity to OpenCode users.**

## The soul — what we're actually porting

The non-negotiable parts of storytime, in priority order:

1. **Personas as fluid lenses, not static agents.** A persona has a
   codename, an archetype, an acquired_context, and a relationship to
   sessions over time. They can be spawned ephemerally (echo), promoted
   from specialist to cohort, evolved across sessions, fired, benched,
   re-hired. They are not config-time declarations. **OpenCode's static
   agent system must wrap a persona runtime, not replace it.**

2. **Driver-per-leg discipline.** At every leg of work, exactly one
   persona drives. Supporters stay silent unless their interjection is
   useful AND non-distortive. This is a *runtime conversation
   discipline*, not a static role assignment. Maps to neither OpenCode
   agent nor Claude Code Agent tool directly — it's a layer above both.

3. **The consolidation loop.** Six scales (phase, commit, nap, shift,
   session, compact). All consolidation events write a unified artifact
   shape. Atomic tmp+fsync+mv writes. Remembrance is a workday-shaped
   wakeup document staged before compactions. This is the continuity
   spine.

4. **The intent graph.** Decisions are nodes in a typed DAG with edges
   for refines/specializes/implements/co-implies/tensions/supersedes/
   links. Read-side queries (orphans, unrealized, tensions, paths)
   surface the structure. Composition (distillation, naming) is the
   v1.2+ direction.

5. **The narrative grammar.** Phases, breakouts, plans, threads,
   callouts (Callout->/Callout<-), decisions (V1-NNN), remembrance,
   dreams. All as markdown with frontmatter.

6. **The gearbox principle.** Phases collapse when empty. No mandatory
   ceremony. Tutorial mode for fresh users; adaptive graduation.
   Automation tiers from tutorial→manual→guided→auto.

7. **`@role` as a lens directive.** The `@role` prefix is a model
   attention anchor and a lens declaration, not a skill trigger.
   Personas address each other with it; users address personas with
   it; the model reasons differently when it's present.

8. **The driver-per-leg and supporters-silent-unless-useful pattern**
   shapes how multi-persona work flows. Round-robin commentary is the
   anti-pattern. This must hold in OpenCode the same as in Claude Code.

9. **Codenames non-human by default.** Personas are lenses, not people.
   `anchor` and `lattice` and `kestrel`, not Sarah and Mike.

10. **Continuity is cheap.** Walking away mid-session and returning
    later costs near-zero re-orientation. Remembrance + thread
    checkpoints + callouts make this work.

These are the seams that have to come through. Everything else is
implementation detail per harness.

## OpenCode's paradigm gets *extended*, not accommodated

OpenCode today: static agents declared in `opencode.json`, invoked by
`@name`. Each agent has fixed mode, model, prompt, tools.

OpenCode after the storytime adapter:

- **Persona runtime** above the static agent layer. The plugin's
  `chat.message` hook intercepts agent invocations and applies the
  current driver/supporters context. Personas can be spawned
  ephemerally (echo) without `opencode.json` edits.
- **Driver-per-leg context** flows through tool calls via plugin state.
  The model sees "currently driving: @owner [anchor]" in its system
  prompt, dynamically updated per turn.
- **Breakouts as scoped sub-conversations** dispatched via OpenCode's
  subagent mechanism, but wrapped with driver/supporters discipline.
  The breakout's tool calls and message stream get the storytime layer.
- **Compaction is remembrance.** The adapter hooks
  `experimental.session.compacting` and rewrites the compaction prompt
  to emit storytime's remembrance format. OpenCode users get
  workday-shaped wakeup docs for free, just by installing the adapter.
- **Decisions and callouts persist alongside OpenCode's session SQLite.**
  The adapter doesn't fight OpenCode's session model — it adds a
  storytime layer of markdown artifacts in `.storytime/` that
  cross-reference OpenCode session IDs.
- **`@role` flexibility.** OpenCode's `@name` invokes static agents.
  The adapter intercepts `@role` (where role is an archetype, not a
  registered agent name) and creates an ephemeral context. Same for
  `@role:focus` and `@codename` resolution.

OpenCode users who install this adapter get more than storytime — they
get a **flexible persona paradigm** their default OpenCode workflow
doesn't have. That's the value proposition.

## What's actually platform-specific

### Claude Code (current home)

- `skills/<name>/SKILL.md` directory layout + frontmatter convention
- `.claude-plugin/plugin.json` manifest
- `Agent` tool with `subagent_type` parameter
- Specific tool names (Read, Write, Edit, Bash, Grep, Glob, Agent,
  WebSearch, WebFetch)
- Slash-command auto-discovery
- Hook surface (post-commit hook proposed in v1.0)

### OpenCode (target)

- `.opencode/` directory (plugin/, agent/, command/, skills paths in
  `opencode.json`)
- Plugin model: TS function returning `Hooks` object
- Static agents declared in config with `mode: subagent`
- Skills as markdown loaded via the `Skill` tool
- Effect-based typed tools with Zod schemas
- Rich hook system: `chat.message`, `command.execute.before`,
  `tool.execute.before/after`, `experimental.session.compacting`,
  `experimental.compaction.autocontinue`, `permission.ask`, others
- Multi-provider via Vercel `ai` SDK

## What's platform-agnostic (the actual storytime)

This is **most of storytime**:

- The narrative grammar — decisions (V1-NNN), breakouts, plans, threads,
  callouts (`Callout->`/`Callout<-`), dreams, remembrance
- The persona model — lenses, archetypes, codenames, driver-per-leg
- The phase sequence — SURVEY → ASSEMBLE → ICEBREAKER → BREAKOUT →
  CONVERGE → REVIEW → DONE
- The consolidation loop — six scales (phase, commit, nap, shift,
  session, compact)
- The intent graph (V1-031..V1-036) — frontmatter v2.1, sigil callouts,
  read-side queries, adherence visualization
- All artifact frontmatter conventions
- The `references/` progressive-disclosure pattern
- The driver-per-leg rule and @role addressing convention
- The decision log format
- The remembrance.md format
- Most of the documentation
- Most of the lint rules

## Proposed architecture

```
storytime/
├── core/                         Platform-agnostic library (the actual storytime)
│   ├── conventions/              Grammar specs (frontmatter, callouts, decisions)
│   ├── lifecycle/                Phase sequence, consolidation rules
│   ├── references/               All references (markdown, shared by all adapters)
│   ├── docs/                     Documentation
│   └── examples/                 Example sessions, persona templates
│
├── adapters/
│   ├── claude-code/              Adapter for Claude Code harness
│   │   ├── .claude-plugin/       Plugin manifest
│   │   ├── skills/               Skill files (or symlinks/wrappers to core/)
│   │   ├── agents/               Sub-agent definitions
│   │   └── README.md             Install instructions
│   │
│   └── opencode/                 Adapter for OpenCode harness
│       ├── opencode.json         OpenCode config
│       ├── plugin.ts             The plugin function (registers tools, hooks)
│       ├── .opencode/agent/      Agent definitions
│       ├── .opencode/command/    Commands
│       └── README.md             Install instructions
│
└── shared/                       Cross-cutting utilities
    ├── scripts/                  Already platform-agnostic (bash)
    ├── lint/                     Lint rules (mostly platform-agnostic)
    └── specs/.storytime/         Self-dogfood state (runs in either harness)
```

The skills' markdown content lives in `core/`. Adapters either symlink,
copy, or wrap — whichever the harness prefers.

## Mapping table — storytime concept ↔ each harness

| Storytime concept       | Claude Code             | OpenCode                                  |
|-------------------------|-------------------------|--------------------------------------------|
| Skill (markdown SKILL)  | `skills/<name>/SKILL.md`| Skill markdown loaded via `Skill` tool     |
| Persona (lens)          | (concept; no native)    | `Agent` (mode: subagent), declared in config |
| Breakout-runner agent   | `Agent` tool dispatch   | Static agent + `tool.execute.before` hook  |
| Plugin manifest         | `.claude-plugin/plugin.json` | implicit (Plugin function type)       |
| Slash commands          | Auto-discovered skills  | `.opencode/command/*.ts` or `Skill` tool   |
| Tool definitions        | Built-in (Read, Bash, etc.) | `Tool.define(id, init)` with Zod        |
| Custom tool registration| via skill `allowed-tools` | via plugin `hooks.tool` map              |
| Hooks                   | (limited; user shell hooks)| Rich plugin hook system                 |
| Compaction              | `/compact` (no pre-hook) | `experimental.session.compacting` hook    |
| Remembrance staging     | Manual via `/storytime-remember` | Plugin can hook compaction directly |
| Session state           | In-memory + thread file  | SQLite (Drizzle ORM) + thread file         |
| Permission gates        | User approves tools      | `Permission.Ruleset` per agent + `permission.ask` hook |
| Provider                | Anthropic only           | Multi-provider via Vercel `ai` SDK        |

## Where OpenCode is actually *better* for storytime

A few hooks make storytime fit OpenCode more cleanly than Claude Code:

1. **Compaction hook is a direct match for remembrance.** v1.0
   currently has no hook for `/compact`; storytime has to estimate or
   ask. OpenCode's `experimental.session.compacting` hook lets the
   plugin own the compaction prompt — which is exactly what
   remembrance is supposed to do.

2. **Tool hooks (`tool.execute.before/after`)** make commit-drafting
   adaptation (V1-014) and pause detection (V1-016) implementable as
   real intercepts, not as prose conventions.

3. **Built-in compaction template can be replaced.** OpenCode's default
   compaction template (Goal/Constraints/Progress/...) can be swapped
   for storytime's remembrance-format via the hook. Direct port.

4. **Permission ruleset per agent.** Maps cleanly to per-persona
   capability scoping if we want it later.

5. **Multi-provider out of the box.** Storytime stops being
   Anthropic-only without effort.

## Risks and tensions

1. **Skill content is markdown today.** Markdown lives in `core/` and
   is portable. Good.

2. **Skill *behavior* is described in markdown today.** Claude Code
   models read the markdown; OpenCode models read the markdown via
   the Skill tool too. Mostly portable. The risk is when behavior
   needs to be more programmatic (e.g., commit-learning state machine)
   — that becomes adapter-specific TS in OpenCode but stays markdown
   in Claude Code. Keep this rare.

3. **Sub-agent dispatch is structurally different.** Claude Code's
   `Agent` tool spawns ephemeral sub-agents. OpenCode's agents are
   static, declared in config. The breakout-runner pattern needs an
   abstraction: `dispatch_breakout(driver, supporters, problem)` →
   each adapter implements it differently. Probably the largest
   per-adapter code surface.

4. **v1.0 already shipped.** Existing v1.0.1 users (just me, but
   still) have working Claude Code installs. Refactor must not break
   them. Strategy: introduce `core/` and `adapters/claude-code/`
   alongside existing `skills/`; copy or symlink during migration;
   delete originals only after the adapter version proves equivalent.

5. **Lint and scripts need adapter awareness.** `check-conventions.sh`,
   `intent-graph-query.sh`, `validate-callouts.sh`, `decisions-view.sh`
   are mostly fine — they operate on `specs/.storytime/` which is
   adapter-agnostic. `bump-version.sh` needs adapter-specific
   propagation. `migrate-to-v1.sh` is adapter-specific (Claude Code
   only) and stays where it is or moves to the Claude Code adapter.

6. **Documentation has to fork.** Some docs are about Claude Code
   conventions specifically (skill SKILL.md, slash commands). Those
   move to the adapter doc set. The core docs (process, lifecycle,
   intent graph) stay shared.

## Plan shape (not yet sequenced)

This is a v1.1 or v2.0 effort, not a v1.0.x patch. Proposed order:

### Phase 0 — Decide naming + repo strategy

- This repo (sst/storytime equivalent) becomes the cross-platform home
- Adapters live in subdirectories OR separate repos
- Recommend: subdirectories first, separate later if adapters diverge

### Phase 1 — Pull what's portable into `core/`

- Move `skills/storytime/references/` → `core/references/`
- Move `docs/`, `examples/` → `core/docs/`, `core/examples/`
- Keep markdown content as-is; only paths change
- Update internal cross-references

### Phase 2 — Claude Code adapter

- Move `skills/`, `agents/`, `.claude-plugin/` → `adapters/claude-code/`
- Update `bump-version.sh` to handle the new layout
- Verify Claude Code install still works

### Phase 3 — OpenCode adapter scaffold

- Create `adapters/opencode/` with `plugin.ts`, `.opencode/`,
  `opencode.json`
- Plugin function registers core skills as Skill paths
- Hooks compaction → remembrance-format
- Hooks `tool.execute.before` for storytime's commit-drafting and
  pause-detection prose
- README with install + walk-through

### Phase 4 — Bidirectional dogfood

- Run a `/storytime` session in Claude Code
- Run a similar session in OpenCode using the adapter
- Diff the outputs; surface platform-driven divergences
- Capture findings in retro

### Phase 5 — Cross-platform refinements

- Whatever Phase 4 surfaces

## Questions to answer before starting

1. **Single repo or multi-repo?** (Recommend single for v1.1; split if
   adapters grow heavy.)
2. **What version is this?** v1.1.0 (incremental) or v2.0.0 (signals
   the directory restructure)?
3. **MVP soul-elements vs nice-to-have.** Which of the 10 soul items
   above MUST be in the OpenCode adapter day-one? Recommend: 1, 2, 3,
   5, 7 minimum — the persona runtime, driver-per-leg, consolidation
   loop, narrative grammar, @role lens directive. Items 4 (intent
   graph) and 8/9/10 (gearbox/codenames/continuity) follow naturally
   once those are working.
4. **Does this trigger a `/storytime` spec session on the port itself?**
   Eat-our-own-dogfood: spec the port using storytime's full pipeline.
   Recommend yes.
5. **What does "OpenCode's persona runtime" actually look like in TS?**
   Specifically: how does the plugin maintain driver-per-leg state
   across tool calls? Through plugin closure, an SQLite extension, or
   an opencode session annotation? This needs a real breakout.
6. **Does the adapter ship as `@storytime/opencode-plugin` on npm?**
   Distribution model affects how OpenCode users install. Recommend
   yes — first storytime npm package, makes adoption frictionless.

## Companion documents

- `intent-extraction-user.md` — user-as-persona reframe
- `intent-extraction-roles.md` — storytime as intent-flow system
- `intent-visualization.md` — adherence + attention-window viz
- `intent-gradient.md` — typed intent DAG, decomposition vs composition
- `v1-consolidation.md` — current architecture (the source for what
  needs to abstract)
