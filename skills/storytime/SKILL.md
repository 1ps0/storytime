---
name: storytime
description: "This skill should be used when the user asks to \"storytime\", \"run storytime\", \"build a spec\", \"assemble a team\", \"persona discussion\", \"design a feature\", \"spec this out\", or wants to plan a feature through structured team conversation with domain-expert personas. Runs the full Storytime workflow: survey codebase, assemble persona team, run icebreaker, execute breakouts, and produce a plan with ASCII visual aids."
argument-hint: "<problem-statement>"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch]
---

<!-- version-echo: display "storytime v0.2.0" at start of execution -->
# Storytime — Full Workflow

Orchestrate a structured specification process that produces technical
narratives through persona-driven conversations.

## Arguments

The user's problem statement: $ARGUMENTS

## Process

Follow this state machine in order, but **collapse phases that have no
real work**. If no artifacts exist, skip the inventory. If the team is
obvious, don't belabor ASSEMBLE. If the problem is simple enough that
breakouts aren't needed, go straight from ICEBREAKER to CONVERGE. The
phase sequence defines the *maximum* workflow — actual sessions use only
the gears they need.

### Entry: Route

Derive `<topic>` from the problem statement (kebab-case).

Check for a prior thread: does `sessions/<topic>/_thread.md` exist (in
`specs/.storytime/`, `specs/`, or wherever the repo keeps session output)?

- **Thread found** → go to **Warm Start**
- **No thread** → go to **Bootstrap** (cold start)

### Warm Start

A warm start is the "previously on..." moment. The system reads the thread
state and synthesizes a narrative preamble so the user can re-engage without
re-absorbing the full history. See `references/warm-start.md` for full
format specifications.

**1. Read thread state:**
- `_thread.md` — episodes, last phase, team, open questions
- Decision log — filtered to this topic's decision IDs
- Persona files — filtered to personas who participated in this topic
- Last episode's key artifacts — plan.md, icebreaker.md (the substance)

**2. Compute codebase delta:**
- `git rev-list <thread.last_commit>..HEAD` — commits since last episode
- `git diff --stat <thread.last_commit>..HEAD` — files changed
- Cross-reference changed files with the last survey fingerprint's scanned paths
- Classify drift: in-scope changes, out-of-scope changes, new files

**3. Synthesize narrative preamble:**

Generate a **narrative synopsis** — 3-5 sentences that reconstruct the
story arc of how the topic reached its current state. This is not a
changelog or bullet list. It reads the documents and persona histories and
tells the story they contain, sliced to this topic.

The narrative is **dynamic** — synthesized fresh from the living state every
time. Never cached, never stale. It answers: what problem was the team
solving? Who drove which decisions? What did they decide and why? What
changed in the world since? What's still open?

**4. Present the warm-start card:**

```
╔═══════════════════════════════════════════════════╗
║  Previously on <topic>                            ║
╠═══════════════════════════════════════════════════╣
║                                                   ║
║  [narrative synopsis — 3-5 sentences]             ║
║                                                   ║
╠═══════════════════════════════════════════════════╣
║  Team: [names]                                    ║
║  Episodes: N (last: YYYY-MM-DD)                   ║
║  Decisions: TOPIC-001 through TOPIC-NNN           ║
║  Open questions: [from _thread.md]                ║
║  Codebase drift: [N commits, M files changed]     ║
╠═══════════════════════════════════════════════════╣
║  Continue · Retro · New sub-topic · Reset         ║
╚═══════════════════════════════════════════════════╝
```

**5. Route based on user choice:**

- **Continue** — resume at the first incomplete phase from `_thread.md`.
  If the last episode completed all phases, start a new episode at
  ICEBREAKER (team loaded silently, survey delta for codebase changes).
- **Retro** — invoke `/storytime-retro` with the topic context.
- **New sub-topic** — user provides a sub-problem. New episode, same team,
  starts at ICEBREAKER scoped to the sub-topic.
- **Reset** — archive the thread and all episodes to cold storage. Start
  fresh as a cold start. The user is saying "this story is over."

**6. Write `<episode>/preamble.md`:**

Persist the synthesized preamble as the first artifact of the new episode.
This is an audit trail of what context the session started with.

```yaml
---
type: preamble
created: <YYYY-MM-DDTHH:MM>
session: <session-id>
episode: <NNN>
prior_episode: <NNN-1>
prior_commit: <sha>
current_commit: <sha>
drift_commits: <N>
drift_files: <N>
---
```

**7. Persona behavior on warm start:**

Personas skip introductions. They speak from their accumulated context —
"last time I flagged X, and since then Y changed" — not from their bio.
Their persona files already carry the context; the warm start loads it and
they continue the conversation, not restart it.

**Warm-start collapse rules:**
- If the user says "skip the recap" → skip the card, go straight to routing
- If codebase drift is zero → omit the drift line from the card
- If open questions are empty → omit that line
- If the user's problem statement implies a direction → auto-select Continue
  and note it ("Continuing from where we left off...")

### Bootstrap (Cold Start)

Derive `<topic>` from the problem statement (kebab-case).

**Detect the landscape** before creating anything:
- Does `specs/.storytime/` exist? → this repo already uses storytime structure
- Does the repo have its own doc structure (`team/`, `docs/`, `specs/`)? → work within it
- Is this a fresh repo with nothing? → propose storytime structure

**Three modes:**
- **Storytime-native** — `specs/.storytime/` exists or user agrees to create it.
  Full structure: `sessions/<topic>/`, `cohort/`, `archive/`, `history/`.
- **Adapt-in-place** — repo has existing doc structure. Write output into
  the conventions already present (e.g., `team/` for team docs, `docs/` for
  plans, `specs/` for session output). Don't force a migration.
- **Export-only** — produce a unified plan document (or set of documents) in
  a format another system can consume. No persistent storytime state. The
  session is a one-shot that produces output and exits.

Ask the user if ambiguous. Default to **storytime-native** for new repos,
**adapt-in-place** for repos with existing structure. The user can override.

Create directories only for the chosen mode. Never create `.storytime/`
without the user's knowledge.

### Phase 0: SURVEY

Launch an Explore agent to survey the codebase relevant to the problem.

**Prior run detection:** Check if output from a prior storytime run exists for
this topic (in `.storytime/sessions/<topic>/`, `specs/<topic>/`, or wherever
the repo keeps session output). If found, that output enters the artifact scan
as prior art — never silently overwrite it. The user decides whether to update,
archive, or start fresh.

**Codebase scan:**
1. Identify existing code, patterns, dependencies, prior specs, constraints
2. Produce a mental model of the problem space

**Artifact scan:**
3. Scan the entire repo for prior work artifacts — specs, docs, design
   records, agent definitions, team files, ADRs, RFCs, .kiro files, etc.
   See `references/artifact-scan.md` for full scan targets and heuristics.
4. Classify each artifact: **team-like**, **spec-like**, **config-like**, or noise.
5. Produce an **artifact inventory** as a checklist for the user:
   - Each item: checkbox, filename, short description (< 10 words if name isn't clear)
   - Pre-check items that seem relevant to the problem
   - Tag each: `[team]` `[spec]` `[config]`

**Present the inventory to the user.** Options:
- Toggle items on/off
- "tell me about <item>" — quick summary before deciding
- "bring the team in on <item>" — flag for team review during icebreaker
- "skip all" — cold start, no prior context
- Direct instruction — "ignore all the kiro stuff", "keep all specs"

Config-like artifacts (CLAUDE.md, .cursor rules) load silently.
Team-like artifacts route to ASSEMBLE. Spec-like artifacts route to ICEBREAKER.

**Consolidation mode** — for each artifact outside the session output path:
- **Consolidate** — `git mv` (or copy) into the storytime structure
  (team-like → cohort, spec-like → archive or sessions) preserving git
  history. In storytime-native mode, this means into `.storytime/`. In
  adapt-in-place mode, this means into the repo's existing conventions.
- **Leave in place** — reference the artifact at its current path without
  moving it. Use when the file serves a purpose outside storytime (e.g.,
  a README that humans browse, a CLAUDE.md that Claude Code loads).

Default bias is **consolidate**. Pre-check consolidation in the inventory.
The user can override per-item or bulk ("leave everything in place").

**If a prior survey.md exists with a fingerprint**, compute the delta:
- Commit drift: `git rev-list <prior-commit>..HEAD` — what changed?
- Coverage gaps: what paths were unvisited last time?
- Present the delta to the user: resurvey stale paths, extend to gaps,
  full resurvey, or trust prior survey. See `references/survey-fingerprint.md`.

**Write `specs/.storytime/sessions/<topic>/survey.md`** with:
- Codebase context summary
- Artifact inventory (classifications and user dispositions)
- **Coverage fingerprint** (REQUIRED): commit sha, branch, paths scanned,
  paths skipped, paths unvisited, file counts, coverage ratio, artifact
  counts by classification. Every survey writes a fingerprint, no exceptions.

**Collapse rule:** If no artifacts are found, skip the inventory entirely.
If only config-like artifacts exist, load them silently and move on.

### Phase 1: ASSEMBLE

**Rehire candidates** — if team-like artifacts were found and selected:
- Present prior personas as rehire candidates with their accumulated context
- User decides per candidate: rehire, modify, or skip
- Rehired personas carry their prior context into the new session

**Load the permanent cohort** if `specs/.storytime/cohort/_roster.md` exists:
- Read the roster, load each active persona's file
- These personas participate by default (they are the rehire candidates)

**Recruit specialists** to fill gaps:
- Analyze which domains the problem touches
- For each domain not covered by the cohort or rehired personas, propose a specialist
- Each specialist gets: name, archetype, background, scope, exit condition

**Archetype checklist** (minimum 3 personas, at least one OPERATOR):
- DOMAIN: deep expertise in the problem domain
- SYSTEMS: knows the runtime, infra, failure modes
- PLATFORM: knows the product, user, business case
- OWNER: wrote the code, knows where everything lives
- OPERATOR: runs it in prod, wants observability and kill switches
- SKEPTIC: asks "what if this breaks?" and "do we actually need this?"

**Write `specs/.storytime/sessions/<topic>/team.md`** with persona definitions in boxed ASCII format.

**Collapse rule:** If a permanent cohort exists and covers the problem's
domains with no rehire candidates to review, confirm the team briefly
and move on. Don't present a ceremony when the answer is obvious.

### Phase 2: ICEBREAKER

**Team introduction** — each persona states what they see from their vantage point.

**Prior work review** — if spec-like artifacts were selected in SURVEY:
- Present each flagged artifact to the team
- Team assesses each: current? valuable? stale? superseded?
- User can drill into any item: discuss with team, annotate, or direct
- For each artifact, decide disposition:
  - **Keep hot** — fold into active session context
  - **Archive warm** — move to `specs/.storytime/archive/current/`
  - **Rollup** — combine with related stale docs into a single rollup artifact
    (see `references/artifact-tiers.md` for rollup format)
  - **Send cold** — move to `specs/.storytime/archive/cold/`
  - **Skip** — not relevant, leave in place

If artifacts were archived or rolled up, update `specs/.storytime/archive/_index.md`.

**Establish the status quo** (with code citations).
**Identify sub-problems** for breakouts.
**Agree on constraints** before any solution is proposed.

**Write `specs/.storytime/sessions/<topic>/icebreaker.md`** with the full discussion, including
any artifact review decisions.

**Collapse rule:** If no spec-like artifacts were selected, skip prior work
review entirely — go straight to status quo and sub-problem identification.

### Phase 3: BREAKOUT (parallel when possible)

For each sub-problem identified in the icebreaker:
- Estimate **CIU** (Complexity Integration Units) and **Scale** per breakout.
  CIU measures how hard, Scale measures how big. See
  `references/complexity-units.md` and `${CLAUDE_PLUGIN_ROOT}/docs/scale-impact.md`.
  Always pair each with prose (e.g., "CIU 5 — solid day of work,
  Scale 3 (repos) — touches a service cluster").
- Assign 2-3 personas
- Launch as a parallel sub-agent if independent
- Each breakout can invoke skills mid-conversation:
  - VERIFY: Grep/Read to check a claim
  - RESEARCH: WebSearch/WebFetch for external info
  - DISCOVERY: Explore agent for code mapping
  - PROTOTYPE: Write draft code for illustration
- Produce a recommendation

**Write `specs/.storytime/sessions/<topic>/breakout-<subtopic>.md`** for each
breakout with: findings, citations, recommendation, CIU estimate for the
recommended work, and which personas participated.

**Collapse rule:** If the problem is singular (no sub-problems identified),
skip BREAKOUT entirely and proceed to CONVERGE. Not every problem needs
decomposition.

### Phase 4: CONVERGE + PLAN

Reconvene the full team. Merge breakout findings. Resolve conflicts.

**Write `specs/.storytime/sessions/<topic>/plan.md`** with:
- ASCII slide deck (use box-drawing for slides)
- Problem visualization
- Solution architecture diagram
- Implementation steps (numbered, sequential)
- Code changes summary (files touched, lines added)
- Risk matrix
- Non-goals section (REQUIRED — each with "why skip" + "when to revisit")
- Success criteria (REQUIRED — measurable)
- Roadmap sketch (now / soon / later) with **CIU and Scale per item**, each
  with prose (e.g., "CIU 3 — a morning's work, Scale 4 (users) — all users").
  CIU ≥ 13 must be decomposed. Scale dimensions stated, not assumed.

### Phase 5: REVIEW

Present the plan to the user. Enter inline mode — the user can:
- Challenge any decision (personas respond with rationale)
- Request changes (team revises)
- Approve (proceed to DONE)

### Phase 6: DONE

- Update persona files in `specs/.storytime/cohort/` with new context
- Log session in `specs/.storytime/history/`
- Evaluate specialist contracts (complete, promote, or release)
- Commit any archive changes if artifacts were reviewed
- **Write or update `sessions/<topic>/_thread.md`:**
  - If this is episode 1: create `_thread.md` with the full thread state
  - If this is a later episode: append the episode to the log, update
    current state, add any new decisions to the summary
  - Set `last_completed_phase: DONE`, clear open questions
  - Record current `HEAD` as `last_commit`

### Thread Checkpointing (applies to all phases)

At every phase boundary (when a phase completes and before the next begins),
update `_thread.md` if it exists:

- Set `last_completed_phase` to the phase that just completed
- Set `last_commit` to current `HEAD`
- Update `open_questions` with any unresolved questions from the phase

**Parking:** The user can say "park it here" or "let's stop" at any phase
boundary. Update the thread, confirm the checkpoint, and exit. The next
invocation warm-starts at the parked phase.

If `_thread.md` doesn't exist yet (mid-episode-1), the checkpoint is
implicit in the phase artifacts already written. The thread is created at
DONE.

## Process Rules

1. SURVEY before ASSEMBLE. Never build a team blind.
2. ICEBREAKER before BREAKOUT. Shared understanding before depth.
3. CONVERGE before showing the user. Internal consensus first.
4. Every technical claim must cite code (file:line).
5. At least one OPERATOR archetype. Always.
6. Non-goals and success criteria are required, not optional.
7. Visual aids use ASCII box-drawing. No external tools.
8. Personas are lenses, not characters. No role-play, only expertise.
9. Minimum 3 personas, maximum 7.
10. The user has veto power over everything.
11. Artifact scan is broad — expect variance across repos in the wild.
12. The user controls depth at every stage. Full shebang or skip all.
13. Rollups replace stale docs — originals go cold, rollup stays warm.
14. Archive artifacts must be git-committable and repo-local.
15. Phases collapse when empty — never present ceremony for absent content.
16. Every phase writes its output — a run is a complete snapshot, track everything.
17. Prior runs are prior art — detect and present, never silently overwrite.
18. Every survey writes a coverage fingerprint — commit, paths, gaps, ratios.
19. Effort uses CIU (how hard) and Scale (how big), never time estimates.
    Always pair each with prose. CIU ≥ 13 must decompose.
20. Evaluation hygiene: observe metrics and conclusions separately.
    Don't weight signals without understanding what they measure.
21. Warm start is detected, not requested. If `_thread.md` exists, warm-start.
22. The preamble narrative is always dynamic — synthesized fresh, never cached.
23. Personas skip introductions on warm start. They speak from accumulated context.
24. Thread state is the checkpoint — updated at every phase boundary.
25. Episodes are chapters of the same story. Reset is the explicit "new story" action.
26. Survey delta replaces full survey on warm start. Only resurvey what changed.

## Output Format

Output paths depend on the bootstrap mode chosen.

### Storytime-native (full structure)

```
specs/.storytime/
├── cohort/                          — permanent personas
├── specialists/                     — temporary personas
├── sessions/<topic>/                — per-topic thread
│   ├── _thread.md                   — episode bookmark (created at DONE)
│   ├── <NNN>/                       — episode directory (zero-padded)
│   │   ├── preamble.md              (warm start only — synthesized narrative)
│   │   ├── survey.md                (cold start — full survey + fingerprint)
│   │   ├── survey-delta.md          (warm start — incremental survey)
│   │   ├── team.md                  (cold start or team changes)
│   │   ├── icebreaker.md
│   │   ├── breakout-<subtopic>.md
│   │   └── plan.md
├── archive/
│   ├── _index.md                    — browsable TOC
│   ├── current/                     — warm tier
│   ├── rollups/                     — compressed history
│   └── cold/                        — deep history (glacier)
├── history/
│   ├── decisions.md                 — append-only decision log
│   └── sessions/                    — per-session summaries
└── config.md                        — project settings
```

### Adapt-in-place (work within existing conventions)

Write output wherever the repo already keeps similar content:

| Output       | Existing convention examples                  |
|-------------|-----------------------------------------------|
| survey.md   | `docs/`, `specs/`, repo root                  |
| team.md     | `team/`, `docs/`, `.storytime/cohort/`        |
| icebreaker  | `team/`, `specs/<topic>/`, `docs/`            |
| breakouts   | `specs/<topic>/`, `docs/<topic>/`             |
| plan.md     | `docs/`, `specs/`, `ROADMAP.md`, repo root    |

Mirror the repo's existing naming style (UPPERCASE.md vs lowercase.md,
flat vs nested). Don't impose storytime conventions on a repo that has
its own.

### Export-only (one-shot output)

Produce a **unified plan document** that another system can execute.
No persistent storytime state — no cohort, no archive, no history.
Output is one or more files the user specifies:

- A single `plan.md` with everything inline
- A set of files matching another tool's expected format
- A structured document another agent or CI system can parse

The user tells storytime where to write and in what shape. Storytime
produces the content; the user or another system owns the lifecycle.

### Component Interop

Storytime components are swappable. If another system handles part of
the workflow better, storytime can defer to it or export into it:

- **Personas** → another system's agent definitions or role specs
- **Plans** → Kiro specs, ADRs, GitHub issues, Linear tickets
- **Decisions** → ADR format, decision log in another tool
- **Archive** → existing doc management, wiki, Notion

When exporting, match the target system's format and conventions.
When importing, absorb into storytime's model during artifact scan.
The gearbox goes both ways.

## Conversation Modes

- **Inline** (default): User is present, can interject any time
- **Deliberation**: If user says "go figure this out", team works
  autonomously and returns with findings + questions
- **QA**: If user says "@persona question", route to that persona

## Additional Resources

For detailed format specifications and scan targets, consult:
- **`references/artifact-scan.md`** — Scan targets, classification, inventory presentation
- **`references/artifact-tiers.md`** — Hot/warm/cold tiers, rollup format, archive structure
- **`references/warm-start.md`** — Thread format, preamble synthesis, episode structure, checkpointing
- **`references/survey-fingerprint.md`** — Coverage fingerprint format, incremental survey logic
- **`references/complexity-units.md`** — CIU scale, signals, usage in plans and breakouts
- **`${CLAUDE_PLUGIN_ROOT}/docs/scale-impact.md`** — Scale 1-5, dimension examples, evaluation hygiene
- **`${CLAUDE_PLUGIN_ROOT}/docs/process-reference.md`** — Events, skills, rules, automation levels
- **`${CLAUDE_PLUGIN_ROOT}/docs/architecture.md`** — Runtime model and agent dispatch
- **`${CLAUDE_PLUGIN_ROOT}/docs/historical-absorption.md`** — Archaeology and interface mapping
- **`${CLAUDE_PLUGIN_ROOT}/examples/agc-session.md`** — Real session walkthrough
- **`${CLAUDE_PLUGIN_ROOT}/examples/persona-template.md`** — Persona starter template
