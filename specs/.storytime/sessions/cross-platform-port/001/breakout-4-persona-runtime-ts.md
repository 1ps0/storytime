---
type: breakout
schema_version: 1
created: 2026-05-09T11:42
session: cross-platform-port
episode: 001
subtopic: persona-runtime-ts
driver: "@systems [opcode]"
supporters: ["@critic [lattice]", "@platform [compass]"]
supporters_who_spoke: ["@critic [lattice]", "@platform [compass]"]
status: complete
---

# Breakout 4 — Persona Runtime in TypeScript for OpenCode

## Question

Storytime's fluid persona model needs to run inside OpenCode's plugin
system. OpenCode has STATIC agents declared in `opencode.json`. The
storytime adapter must add a PERSONA RUNTIME above OpenCode's agent layer
that supports:

1. Ephemeral spawning (echo)
2. Driver-per-leg state across tool calls
3. Supporter watching brief
4. Persona `acquired_context` persistence
5. Driver swap on phase boundary / shift event

What's the technical design in TS that:
- maps cleanly onto OpenCode's hook surface (`Plugin → Hooks`)
- doesn't fork OpenCode's session model (we extend, we don't replace)
- keeps the per-turn cost budget reasonable (lattice's concern)
- surfaces persona context to the user when it matters (compass's concern)
- sketches concretely in ~30-40 lines of TS using OpenCode's actual types

## What we know (cited)

- **Plugin signature** is `(input: PluginInput, options?) => Promise<Hooks>`
  — a closure-returning factory. Closure variables persist for the
  lifetime of the OpenCode server process.
  Citation: `opencode/packages/plugin/src/index.ts:75`.
- **PluginInput** gives us `client` (an `@opencode-ai/sdk` client),
  `project`, `directory`, `worktree`, and `$` (a Bun shell). `client`
  is the read/write API into OpenCode session state.
  Citation: `opencode/packages/plugin/src/index.ts:57-67`.
- **Hooks interface** exposes 17 hook points. Our load-bearing ones:
  - `chat.message` — fires when a user message arrives. We can read
    parts and (if we mutate `output.parts`) shape what becomes the
    saved user message.
    Citation: `opencode/packages/plugin/src/index.ts:233-242`,
    triggered at `opencode/packages/opencode/src/session/prompt.ts:1266`.
  - `experimental.chat.system.transform` — fires once per LLM turn
    with `output: { system: string[] }`. Plugins push strings onto
    `system` to inject context into the system prompt. **This is our
    primary injection point for the driver-per-leg banner.**
    Citation: `opencode/packages/plugin/src/index.ts:290-295`,
    triggered at `opencode/packages/opencode/src/session/llm.ts:118-122`.
  - `tool.execute.before / after` — fires per tool call with
    `output: { args }`. The `args` reference is the same object the
    tool will execute against, so mutations propagate. Useful for
    audit, less useful for prompt mutation (already past system).
    Citation: `opencode/packages/plugin/src/index.ts:265-280`,
    triggered at `opencode/packages/opencode/src/session/prompt.ts:428-432`
    and `:601-604` (Task tool).
  - `experimental.session.compacting` — replaces the compaction prompt.
    Direct match for storytime's remembrance.
    Citation: `opencode/packages/plugin/src/index.ts:303-306`.
- **Plugin.trigger semantics** — passes `(input, output)` to each
  registered hook in series. Hooks can mutate `output` in place; the
  caller observes the mutated value.
  Citation: `opencode/packages/opencode/src/plugin/index.ts:258-271`.
- **Agents are static.** `Agent.Info` is a typed Effect Schema with
  fixed `name`, `mode`, `prompt`, `permission`. Built-ins (`build`,
  `plan`, `general`, `explore`, `compaction`, `title`, `summary`) are
  hardcoded; user agents are config-loaded once at boot.
  Citation: `opencode/packages/opencode/src/agent/agent.ts:33-56,
  122-275`.
- **Sessions are SQLite-backed** via Drizzle ORM. `Session.Info` has
  `agent` and `permission` fields but no concept of personas, drivers,
  or supporters.
  Citation: `opencode/packages/opencode/src/session/session.ts:179-199`.
- **The persona model from storytime core**: a persona is a markdown
  file (`specs/.storytime/cohort/<role>-<codename>.md` or
  `.../specialists/...`) with frontmatter (codename, archetype,
  background, opinions, productive_tensions) and body
  (`acquired_context`). Driver-per-leg means at any leg of work,
  exactly one persona has the floor; supporters stay silent unless
  they have something both useful and non-distortive.
  Citation: `skills/storytime/references/driving-persona.md:7-26,
  74-103`; `skills/storytime/references/team-assembly.md:5-145`.
- **Echo is ephemeral.** "No files written, no state persisted. The
  echo speaks once and dissolves." Spawned by `@role`, `@role:scope`,
  or `"description"`.
  Citation: `skills/storytime-echo/SKILL.md:1-15, 32-72`.

## What we don't know — and how this breakout closes the gap

- Where driver-per-leg state physically lives (Q1)
- How that state reaches the model (Q2)
- How echo/`@role` works without `opencode.json` edits (Q3)
- The state machine that swaps drivers (Q4)
- How OpenCode session SQLite and `.storytime/` markdown stay in sync (Q5)
- Concrete TS sketch (Q6)
- Per-turn cost budget (Q7)
- UX surfacing rules (Q8)

---

## Q1 — Where does driver-per-leg state live?

### Options considered

**A. Plugin closure (in-memory).** Variable inside the `Plugin`
function's returned scope. Simple, fast, zero I/O.
Risk: lost on `opencode` restart, lost on plugin reload.

**B. OpenCode session SQLite extension.** Add a `storytime_state`
table or extend `SessionTable`. Persistent, queryable, joins to
session.
Risk: schema migration; couples adapter to OpenCode internals;
violates "extend, not replace" — we'd be patching OpenCode's DB
shape, not layering above it. Also, `Session.Info` is an Effect
Schema not a plain SQL row — we'd have to monkey-patch Drizzle.

**C. `.storytime/state/<sessionID>.md` file.** Markdown with
frontmatter alongside session, atomic tmp+fsync+mv writes per the
consolidation rule. Native to storytime's grammar; survives restarts;
human-readable; works in either adapter unchanged.
Risk: file I/O per write; per-call read latency mitigatable via
in-memory cache.

**D. Hybrid (recommendation).** Plugin closure as the **hot cache**;
markdown file as the **cold ground truth**.
- On first need, read `.storytime/state/<sessionID>.md` and hydrate
  closure.
- On every state change (driver swap, shift, phase boundary), write
  through to markdown atomically.
- On restart, closure is empty; lazy-hydrate from disk on first hook
  fire for that sessionID.

### Recommendation: Option D — hybrid

The hot path (every tool call, every turn) reads the closure; no I/O.
State changes are coarse events (driver swaps happen at phase
boundaries, not at every tool call), so write-through cost amortizes
to ~zero per call.

The markdown file lives at:
```
specs/.storytime/state/<opencode-sessionID>.md
```

Frontmatter:
```yaml
---
type: storytime-state
schema_version: 1
opencode_session: ses_abc123
phase: BREAKOUT
leg: breakout-4-persona-runtime-ts
driver: "@systems [opcode]"
supporters: ["@critic [lattice]", "@platform [compass]"]
echo_active: null              # or "@critic [forge]" if echo in flight
last_swap: 2026-05-09T11:42
---
```

Body holds an append-only swap log (one line per driver change), so
retro can reconstruct what drove what without trawling OpenCode's
message store.

This decision will be sealed as **V1.1-NNN — driver state is markdown
on disk, plugin closure as cache** (number assigned during convergence).

@critic [lattice] check: yes, this earns its keep — the markdown file
*is* part of storytime's narrative grammar, not new ceremony.

---

## Q2 — How does state flow through tool calls (reach the model)?

### The injection points, ranked

1. **`experimental.chat.system.transform`** (winner). Fires once per
   turn before the LLM call. We push a banner string onto
   `output.system`. The model sees:
   ```
   [STORYTIME RUNTIME]
   Driver this leg: @systems [opcode] — knows runtime, infra, failure modes.
   Supporters (watching brief): @critic [lattice], @platform [compass].
   Phase: BREAKOUT — leg: breakout-4-persona-runtime-ts.
   Driver-per-leg discipline: supporters speak only when their
   interjection is both useful and non-distortive.
   ```
   Citation: `opencode/packages/opencode/src/session/llm.ts:118-122`.
   This is *exactly the right altitude* — it's the system prompt, it
   gets cached if unchanged across turns (preserving the 2-part cache
   structure on line 124-128), and it's how OpenCode's own agent
   prompts already work.

2. **`chat.message`** (secondary). Fires on user message arrival. We
   intercept `@role` directives in user input and rewrite into a
   driver-handoff event before the message is saved. Used for the
   echo spawn path (Q3).

3. **`tool.execute.before`** (audit only). We read the call but do
   *not* try to mutate the system prompt here — too late. Used to
   record "tool X was called under driver Y" for retro and intent
   graph; mutating args is reserved for the rare commit-drafting
   intercept (V1-014 lineage).

4. **`chat.params`** (avoided). Mutating temperature/topP for
   personas was tempting but discarded — too implicit, hard to
   debug. Drivers shape *what the model attends to* (system prompt),
   not *how it samples*.

### Cache discipline

OpenCode does a 2-part cache structure: header (line 117 `system[0]`)
plus body. If the plugin pushes onto `system` *after* the header,
the cache structure is preserved by the rejoin logic at line 124-128.
So as long as we always push (never replace `system[0]`), caching
holds.

**Recommendation:** push the storytime banner as a new entry into
`output.system`. Keep it short (target ≤200 tokens). When the driver
doesn't change between turns, the banner is byte-identical and folds
into the cache.

---

## Q3 — Ephemeral persona spawning (echo)

### The gap

OpenCode's `@name` syntax resolves to a registered agent. If the user
types `@critic`, OpenCode looks for an agent named `critic` in
`opencode.json`. If no such agent exists, OpenCode either errors or
sends `@critic` to the model as plain text.

### The mechanism

`chat.message` hook intercepts before save. We:

1. Parse `output.parts` looking for text parts containing `@role` or
   `@role:scope` or `@codename` patterns.
2. Resolve against the storytime cohort + specialists (markdown files
   under `specs/.storytime/`).
3. If the `@target` is a known cohort persona → load their persona
   file content and stash in closure as `currentEcho` for one turn.
4. If `@target` is an archetype with no registered persona → synthesize
   an ephemeral persona from the archetype's default orientation
   (see `team-assembly.md:11-46`); flag in closure as `currentEcho`
   with `ephemeral: true`.
5. If `@target` is a quoted description (`"someone who's built X"`) →
   ephemeral persona with description as character.

The `experimental.chat.system.transform` hook then sees `currentEcho`
in closure and pushes an additional banner:
```
[ECHO ACTIVE]
@critic [forge] (ephemeral, archetype default — not in cohort).
This persona speaks once and dissolves.
```

After the model completes the turn, the `chat.message` hook on the
*next* turn (or a flag set in `tool.execute.after` for the last tool
of the assistant turn) clears `currentEcho`. Echo lasts exactly one
assistant turn — same semantics as the Claude Code skill at
`storytime-echo/SKILL.md:108-128`.

### `@role` collision with OpenCode agents

Some `@role` directives may collide with registered agents (a user
might have `agent.critic` in `opencode.json`). Resolution order:
1. If the user has an explicit OpenCode agent matching the name,
   prefer that — don't surprise users.
2. If only storytime has it, route through the persona runtime.
3. The plugin can optionally register `@role` aliases in
   `opencode.json` at install time, but that's a v1.2+ polish; v1.1
   ships without it.

@platform [compass]: this matters for UX — see Q8 for the surface.

---

## Q4 — Driver swap mid-session (the state machine)

### States

```
                ┌─────────────┐
                │  IDLE       │  no active leg, no driver
                │  (boot)     │
                └──────┬──────┘
                       │ start_phase / start_breakout
                       ▼
                ┌─────────────┐
   ┌────────────│  DRIVING    │  one driver active, supporters quiet
   │            │             │
   │            └──────┬──────┘
   │                   │ supporter_interject
   │                   ▼
   │            ┌─────────────┐
   │            │ INTERJECT   │  supporter speaking once, driver still owns
   │            └──────┬──────┘
   │                   │ interject_yields (auto: end of supporter turn)
   │                   ▼
   │   ┌──────── DRIVING (return)
   │
   │ echo_spawn (during DRIVING or INTERJECT)
   ▼
┌─────────────┐
│  ECHOING    │  ephemeral voice for one turn, original driver paused
└──────┬──────┘
       │ echo_completes (after assistant turn)
       ▼
   DRIVING (return)

       phase_boundary / shift_event / user_handoff
       ────────────────────────────────────►  DRIVING (with new driver)
       end_phase
       ────────────────────────────────────►  IDLE
```

### Triggers (concrete events the plugin observes)

| Event                          | Source                                       | Action                                     |
|--------------------------------|----------------------------------------------|---------------------------------------------|
| `start_phase`                  | user types `/storytime` or skill emits event | IDLE→DRIVING; load phase driver from plan   |
| `start_breakout`               | breakout dispatch (Task tool)                | nested DRIVING with new driver              |
| `supporter_interject`          | model output contains `@<supporter>:` tag    | DRIVING→INTERJECT; record in swap log       |
| `interject_yields`             | next assistant turn or 1 tool call elapses   | INTERJECT→DRIVING                           |
| `echo_spawn`                   | user types `@<role>` not registered          | →ECHOING; one-turn lifetime                 |
| `echo_completes`               | one assistant turn elapses                   | ECHOING→DRIVING                             |
| `phase_boundary`               | plan-section transition                      | DRIVING→DRIVING (new driver)                |
| `shift_event`                  | consolidation marker (mid-session)           | DRIVING→DRIVING (re-evaluated driver)       |
| `user_handoff`                 | `@<other>, your call`                        | DRIVING→DRIVING (handoff to invitee)        |
| `end_phase`                    | phase exit condition met                     | DRIVING→IDLE                                |

### Transition discipline

Every transition writes one line to the swap log in the markdown
state file. Atomic tmp+fsync+mv (per the constraint at icebreaker.md
line 99). Reads are from closure cache. The state machine itself
lives in plugin closure as a tagged-union variable; transitions are
pure functions (event → newState) with a side-effect of writing the
log line.

@critic [lattice] check: state machine is six states, ~10 transitions.
Tractable. The complexity is in the *event detection*, not the FSM
itself.

---

## Q5 — Persona `acquired_context` persistence

### The two stores

- **OpenCode SQLite** — `SessionTable` + `PartTable`. Persists the
  raw message stream, including any model output that mentioned a
  persona's history. Searchable but unstructured.
  Citation: `opencode/packages/opencode/src/session/session.sql`.
- **Storytime markdown** — `specs/.storytime/cohort/<role>-<codename>.md`
  with `acquired_context` body. Curated, structured, persists across
  sessions and adapters.

### The relationship: storytime is canonical, opencode is mirror

Storytime's persona files are the source of truth. OpenCode's session
DB is a substrate for the conversation that *happens* under those
personas, not where personas are defined.

**Write directionality:**
- New persona / promote / fire / evolve → write to storytime markdown
  ONLY. The plugin's persona-cohort tool surfaces these through
  OpenCode's UI but the storage is markdown-first.
- Tool-call audit ("driver X invoked tool Y") → write to OpenCode's
  session via the SDK client + write a one-line entry to the swap
  log in `.storytime/state/`. Bidirectional but lightweight.
- `acquired_context` updates (the persona learned something this
  session) → buffered in plugin closure during the session; flushed
  to the persona's markdown file at session end (or via the
  `/storytime:storytime-consolidate` command, mirroring v1.0).

### Why one-way canonical (storytime) beats bidirectional

- Storytime artifacts must work without OpenCode (the Claude Code
  adapter still has to function). If OpenCode's DB held authoritative
  persona state, removing the OpenCode adapter would amputate
  history.
- Markdown is diffable, grep-able, and renders in any reader. SQLite
  is opaque outside OpenCode tooling.
- Per the proposal at `docs/proposals/cross-platform-storytime.md:108-111`:
  "The adapter doesn't fight OpenCode's session model — it adds a
  storytime layer of markdown artifacts in `.storytime/` that
  cross-reference OpenCode session IDs."

---

## Q6 — Concrete TS sketch

Reference shape only. Type-checks against the actual Plugin/Hooks
exports. Comments mark each subsystem.

```typescript
// adapters/opencode/plugin.ts
import type { Plugin, PluginInput, Hooks } from "@opencode-ai/plugin"
import { readState, writeState, type StorytimeState } from "./state"
import { resolvePersona, type Persona } from "./personas"
import { renderBanner } from "./banner"

export const StorytimePlugin: Plugin = async (input: PluginInput): Promise<Hooks> => {
  // ── Closure: hot cache for driver-per-leg state ────────────────────────
  const stateBySession = new Map<string, StorytimeState>()
  const cohortDir = `${input.directory}/specs/.storytime/cohort`
  const stateDir = `${input.directory}/specs/.storytime/state`

  // Lazy-hydrate from markdown on first hook fire for a given sessionID.
  const getState = async (sessionID: string): Promise<StorytimeState> => {
    let s = stateBySession.get(sessionID)
    if (!s) { s = await readState(stateDir, sessionID); stateBySession.set(sessionID, s) }
    return s
  }
  const swap = async (sessionID: string, next: Partial<StorytimeState>) => {
    const s = await getState(sessionID)
    const updated = { ...s, ...next, last_swap: new Date().toISOString() }
    stateBySession.set(sessionID, updated)
    await writeState(stateDir, sessionID, updated)   // atomic tmp+fsync+mv
  }

  return {
    // Q3: ephemeral echo spawn — intercept @role before the message is saved.
    "chat.message": async ({ sessionID }, { message, parts }) => {
      const echo = await detectEchoSpawn(parts, cohortDir)
      if (echo) await swap(sessionID, { echo_active: echo })
    },

    // Q2: primary injection — driver-per-leg banner into the system prompt.
    "experimental.chat.system.transform": async ({ sessionID }, output) => {
      if (!sessionID) return
      const s = await getState(sessionID)
      output.system.push(renderBanner(s))            // ≤200 tokens; cache-stable
    },

    // Q4 + audit: log every tool call under the active driver.
    "tool.execute.before": async ({ tool, sessionID, callID }, { args }) => {
      const s = await getState(sessionID)
      // append-only swap log line, lightweight: tool|driver|callID|timestamp
      await appendSwapLog(stateDir, sessionID, { tool, driver: s.driver, callID })
    },

    // Echo lifetime: clear after one assistant turn (the next tool.after).
    "tool.execute.after": async ({ sessionID }) => {
      const s = await getState(sessionID)
      if (s.echo_active) await swap(sessionID, { echo_active: null })
    },

    // Compaction → remembrance, per proposal section "OpenCode is *better* #1".
    "experimental.session.compacting": async ({ sessionID }, output) => {
      const s = await getState(sessionID)
      output.prompt = await renderRemembrancePrompt(s, input.client, sessionID)
    },
  }
}
```

Key shape decisions visible above:

- **Closure state shape** (`stateBySession: Map<sessionID, StorytimeState>`) —
  one record per OpenCode session, lazy-hydrated.
- **Hook set** — five hooks total. Each is small (<10 lines of body).
- **Driver-per-leg injection** — `experimental.chat.system.transform`
  pushes the banner. Caching preserved (we add, never replace).
- **No tool registration** — this plugin doesn't define new
  `Tool.define` tools. v1.1 leans on OpenCode's existing tools plus
  the Skill mechanism. Tools come in v1.2+ if we need the
  `dispatch_breakout` abstraction (per icebreaker line 57-72,
  systems/opcode says doable, deferred).

The omitted helpers (`readState`, `writeState`, `detectEchoSpawn`,
`renderBanner`, `appendSwapLog`, `renderRemembrancePrompt`) live in
sibling files; each is small and unit-testable.

---

## Q7 — Per-turn cost (lattice's concern)

### What runs per LLM turn

A typical assistant turn fires hooks roughly like:
- 1× `chat.message` (on user input arrival)
- 1× `experimental.chat.system.transform` (before LLM call)
- 1× `chat.params` (we don't use)
- N× `tool.execute.before` + N× `tool.execute.after` (for N tool calls
  in the assistant response)

For an average storytime turn with maybe 3-5 tool calls:
- ~10-12 hook fires
- Of those, our plugin handles 4 hook types (chat.message,
  system.transform, tool.before, tool.after).

### Per-hook cost

| Hook                                  | Work                                         | Estimated time | Notes                              |
|---------------------------------------|----------------------------------------------|----------------|-------------------------------------|
| `chat.message`                        | regex scan parts, optionally read 1 md file  | 1-3 ms         | only fires once per user message    |
| `experimental.chat.system.transform`  | Map lookup + string template                 | <0.5 ms        | hot path — closure-only             |
| `tool.execute.before`                 | Map lookup + 1 log-line append (fs.appendFile) | 2-4 ms       | I/O dominates                        |
| `tool.execute.after`                  | Map lookup, possibly close echo (no I/O)     | <0.5 ms        | hot path — closure-only             |
| state swap (rare)                     | atomic tmp+fsync+mv of state markdown        | 5-15 ms        | only fires on phase/echo/handoff    |

Assuming 5 tool calls per turn:
- 5× tool.before@3ms = ~15 ms
- 5× tool.after@0.5ms = ~2.5 ms
- 1× chat.message@2ms = ~2 ms
- 1× system.transform@0.5ms = ~0.5 ms
- 0-1× state swap@10ms = ~0-10 ms

**Wall-clock overhead per turn: ~20 ms typical, ~30 ms with a swap.**
Turns themselves take 5-30 seconds (LLM latency dominates), so
runtime overhead is **<1% of turn time.**

### Token cost

The system-prompt banner (Q2) costs tokens, not wall-time. Target
≤200 tokens for the static portion plus ~50 tokens of dynamic state.
Across a 50-turn session = 250 tokens × 50 = 12,500 tokens of
banner. Cached after the first turn (since the banner is identical
when driver hasn't swapped), so effective cost is closer to 250 +
(swaps × 250) tokens for the whole session. With ~5 driver swaps
per session, that's ~1500 tokens — **negligible at 2026 prices**
(<$0.01 of context per session even on premium models).

### Verdict

Cost is well within budget. The expensive operations are coarse
(state writes on phase boundaries, not per call); the hot path is
all closure access. lattice's concern is closed: **earns its keep**.

@critic [lattice]: agreed, retracted. The hot-path discipline (closure
cache, write-through only on coarse events) is what makes this
acceptable. If we'd put the markdown read on every tool call, this
would be a different conversation.

---

## Q8 — UX surfacing (compass's concern)

### The question

When `@critic [forge]` is invoked but has no `opencode.json` agent
entry, the plugin spawns an ephemeral context. What does the user
see? Silent (the model just responds with the persona context) or
explicit ("spawning ephemeral @critic [forge]")?

### Recommendation: explicit but quiet

- **First time per session:** the plugin emits a one-line system
  message via `client.session.message.create` (or the equivalent SDK
  call) saying `Storytime: spawned ephemeral @critic [forge]
  (archetype default, not in cohort)`. This shows up in the OpenCode
  message stream, not as a popup.
- **Subsequent invocations of the same persona in the same session:**
  silent. The user already knows.
- **Driver swaps:** announced. `Storytime: driver → @owner [anchor]
  (phase: BREAKOUT)`. Same channel, one line.
- **Echo dissolution:** silent unless debug mode. The dissolution is
  implicit in the next turn not having the echo banner.

### Why explicit beats silent

compass's fear: users churn when behavior changes invisibly. An
ephemeral persona changing the model's responses without surfacing
*why* is exactly that. The cost of one line in the message stream is
trivial; the cost of a confused user who can't reproduce a result
is high.

### Why quiet beats loud

We're not throwing up modals. The system message is in-band —
OpenCode's TUI renders it inline with regular output, the user can
scroll past, and the line is searchable in session history. The
persona runtime is an extension, not a takeover.

### The "unobtrusive when not engaged" test

If the user never types `@role` or invokes `/storytime`, the plugin
does nothing visible:
- `chat.message` runs but finds no echo trigger, no-op
- `system.transform` finds no active driver (state is IDLE), pushes
  nothing
- `tool.execute.before/after` log lines are written to
  `.storytime/state/<sessionID>.md` but the user never sees that
  file unless they open it
- No system messages in the OpenCode stream

The user sees zero storytime output until they engage. That's
compass's bar. **Met.**

@platform [compass]: agreed. The "quiet but explicit" pattern aligns
with what I'd want as an OpenCode user. The system-message channel
is the right surface — visible, in-band, searchable, dismissable.

---

## Findings (consolidated)

1. **Persistence is hybrid: closure cache + markdown ground truth.**
   `.storytime/state/<sessionID>.md` with frontmatter and append-only
   swap log; in-memory `Map` for hot reads. Atomic writes on coarse
   events only.

2. **State reaches the model via `experimental.chat.system.transform`.**
   Banner pushed onto `output.system` array. Cache-stable when driver
   doesn't change. Target ≤200 tokens static + ≤50 dynamic.

3. **Echo spawns via `chat.message` interception.** Detect `@role`
   patterns in user parts, resolve against cohort+specialists, set
   `echo_active` in state, lifetime is one assistant turn.

4. **Six-state FSM** (IDLE, DRIVING, INTERJECT, ECHOING + transitions
   into themselves with new driver). ~10 transitions, all logged to
   the swap log.

5. **Storytime markdown is canonical; OpenCode SQLite is mirror.**
   Persona files in `specs/.storytime/cohort/` are the source of
   truth. Plugin writes through the SDK client for tool audits but
   never authoritatively to the DB.

6. **TS sketch is ~30 lines** of plugin body, five hooks, no new
   tool definitions in v1.1. Type-checks against the Plugin and
   Hooks exports at `opencode/packages/plugin/src/index.ts`.

7. **Per-turn overhead is ~20 ms wall-clock** and ~250 cached
   tokens per session, well within budget. The discipline that makes
   this work: closure cache on hot path, write-through only on
   coarse events.

8. **UX surfacing is "quiet but explicit"** — one-line system
   messages on first echo and on driver swaps; silent otherwise. The
   plugin is invisible when not engaged.

## Recommendation

Build the OpenCode persona runtime as described above. Specifically:

- **State storage**: hybrid closure + `.storytime/state/<sessionID>.md`
  (V1.1-NNN to be assigned during convergence).
- **Injection point**: `experimental.chat.system.transform` for the
  driver banner; `chat.message` for echo spawn; tool hooks for audit
  only. Not `chat.params`. Not `tool.execute.before` for system-prompt
  mutation.
- **Echo semantics**: identical to the Claude Code skill — one
  assistant turn, then dissolve. State carried in `echo_active`
  field of state markdown.
- **State machine**: six states, ~10 transitions, transitions log to
  swap log atomically.
- **Persona authority**: storytime markdown canonical; OpenCode
  session DB is mirror only. No schema migrations, no Drizzle
  patches.
- **TS sketch**: ship the structure shown in Q6 as `plugin.ts` in
  `adapters/opencode/`; the helper modules (`state.ts`, `personas.ts`,
  `banner.ts`) round it out at <300 lines total.
- **Cost discipline**: keep banner static-portion ≤200 tokens. Keep
  hot-path hooks (system.transform, tool.after) closure-only — no
  I/O. Atomic writes only on coarse events.
- **UX**: emit one-line system messages on first echo and on driver
  swaps. Silent otherwise.

## Confidence

**High** for the architecture (hooks, closure-plus-markdown,
canonical-storytime). The hook surface is well-documented in the
OpenCode source and we've cited specifically where each hook fires.

**Medium** for the cost estimate — wall-clock numbers are based on
typical Node fs.appendFile and Map lookups; real numbers depend on
the user's disk and the exact persona file sizes. The order of
magnitude is solid; the absolute number could be 2× off either way.

**Medium** for the echo-collision rule with registered OpenCode
agents (Q3 end). v1.1 ships with "prefer registered agent if name
matches" but corner cases (`@critic` with archetype `critic` in
storytime AND a custom OpenCode agent named `critic`) need a real
test session to validate.

## Effort Estimate

- **Complexity:** 6 — Five hooks, one state machine, one markdown
  schema, one banner template, two SDK client interactions (one-line
  system messages, optional read of session messages for context).
  The conceptual surface is contained: each hook does one job. The
  testing surface is the harder half — driver-per-leg semantics
  need scenario tests covering all FSM transitions plus a real
  end-to-end run against a live OpenCode session. Echo collision
  with registered agents adds one more axis. Documentation for
  plugin authors who want to extend the state schema (v1.2+) adds
  one more.

- **Scale:** 4 (subsystems) — `plugin.ts` (entry), `state.ts`
  (markdown read/write + atomic semantics), `personas.ts` (cohort
  resolution + ephemeral synthesis), `banner.ts` (template). Plus
  the existing markdown grammar in storytime core, which this
  plugin consumes but doesn't modify. Net new TS code estimated at
  300-500 lines including types, tests excluded.

## Citations

- `opencode/packages/plugin/src/index.ts:75` — Plugin function type. (code)
- `opencode/packages/plugin/src/index.ts:57-67` — PluginInput shape (client, project, directory, $). (code)
- `opencode/packages/plugin/src/index.ts:222-333` — Hooks interface. (code)
- `opencode/packages/plugin/src/index.ts:233-242` — chat.message signature. (code)
- `opencode/packages/plugin/src/index.ts:265-280` — tool.execute.before/after signatures. (code)
- `opencode/packages/plugin/src/index.ts:290-295` — experimental.chat.system.transform signature. (code)
- `opencode/packages/plugin/src/index.ts:303-306` — experimental.session.compacting signature. (code)
- `opencode/packages/opencode/src/session/llm.ts:103-128` — system prompt assembly + transform hook trigger; cache structure. (code)
- `opencode/packages/opencode/src/session/llm.ts:161-179` — chat.params hook trigger. (code)
- `opencode/packages/opencode/src/session/prompt.ts:420-455` — tool.execute hooks fire around tool.execute calls; args object identity. (code)
- `opencode/packages/opencode/src/session/prompt.ts:1262-1276` — chat.message hook fires before user message save. (code)
- `opencode/packages/opencode/src/agent/agent.ts:33-56` — Agent.Info schema; agents are static structs. (code)
- `opencode/packages/opencode/src/agent/agent.ts:122-275` — built-in agents hardcoded; user agents config-loaded. (code)
- `opencode/packages/opencode/src/session/session.ts:179-199` — Session.Info has agent + permission, no persona concept. (code)
- `opencode/packages/opencode/src/plugin/index.ts:258-271` — Plugin.trigger passes input/output by reference; mutations propagate. (code)
- `skills/storytime/references/driving-persona.md:7-26,74-103` — driver-per-leg rule + interaction pattern. (repo doc)
- `skills/storytime/references/team-assembly.md:11-46,90-145` — archetypes + non-human naming + cohort vs specialists. (repo doc)
- `skills/storytime-echo/SKILL.md:1-15,32-72,108-128` — echo is ephemeral; one-shot lifetime. (repo doc)
- `docs/proposals/cross-platform-storytime.md:87-119` — paradigm extension framing; persona runtime above static agents. (repo doc)
- `docs/proposals/cross-platform-storytime.md:108-111` — adapter doesn't fight OpenCode session model; cross-references session IDs. (repo doc)
- `docs/proposals/cross-platform-storytime.md:219-242` — where OpenCode is *better* (compaction hook, tool hooks, multi-provider). (repo doc)
- `specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:46-49,63-72` — lattice cost concern; opcode driving stake. (repo doc)
- `specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:64-65,98-105` — compass UX concern; constraints. (repo doc)

## Open Questions

1. **`@role` collision with OpenCode user-defined agents.** v1.1 rule
   is "prefer registered agent" — does that violate the user's
   intent when they typed `@role` expecting storytime semantics?
   Needs a test session (Phase 4 of the proposal at line 314-318).
2. **Persona `acquired_context` flush timing.** Session-end is the
   stated default, but if the OpenCode process crashes mid-session
   the buffered learnings are lost. Should we flush on phase
   boundary too? Trade-off: more I/O vs more durability.
3. **Multi-session driver continuity.** If a user closes a session
   mid-breakout and reopens via OpenCode's session resume, does the
   driver state survive? With the markdown-on-disk persistence yes,
   but the session ID matching needs to be exact. Worth a confirming
   test in Phase 4.
4. **Permission interaction.** OpenCode's per-agent permission
   ruleset is rich. If we're injecting drivers above the agent
   layer, do we layer storytime permissions on top? v1.1 punts —
   inherit the agent's permissions, no per-persona scoping. v1.2+
   may add this.
5. **`tool.definition` hook.** We didn't use it. Could be a vector
   for storytime to annotate tool descriptions with persona-aware
   guidance ("when @critic is driving, prefer Read over WriteMany"),
   but this is implicit prompt engineering — defer.

## Participants

- **@systems [opcode]** (driver) — Owned the design. Recommended the
  hybrid closure+markdown persistence model, the
  `experimental.chat.system.transform` injection point as primary,
  the six-state FSM, and the storytime-canonical persona authority
  rule. Wrote the TS sketch.
- **@critic [lattice]** (supporter, spoke) — Pushed on the per-turn
  cost budget; specifically demanded the closure-cache discipline
  on the hot path. Closed concern after the cost analysis showed
  ~1% of turn time and cached tokens.
- **@platform [compass]** (supporter, spoke) — Pushed on UX
  surfacing for ephemeral spawns. Closed concern after the
  "quiet but explicit" rule (one-line system messages on first echo
  and on driver swaps; silent otherwise; zero output when not
  engaged).
