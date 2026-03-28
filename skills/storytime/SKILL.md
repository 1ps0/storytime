---
name: storytime
description: "This skill should be used when the user asks to \"storytime\", \"run storytime\", \"build a spec\", \"assemble a team\", \"persona discussion\", \"design a feature\", \"spec this out\", or wants to plan a feature through structured team conversation with domain-expert personas. Runs the full Storytime workflow: survey codebase, assemble persona team, run icebreaker, execute breakouts, and produce a plan with ASCII visual aids."
argument-hint: "<problem-statement>"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch]
---

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

### Phase 0: SURVEY

Launch an Explore agent to survey the codebase relevant to the problem.

**Prior run detection:** Check if `specs/<topic>/` already exists. If it does,
a prior storytime run produced output for this topic. That output enters the
artifact scan as prior art — never silently overwrite it. The user decides
whether to update, archive, or start fresh.

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

**If a prior survey.md exists with a fingerprint**, compute the delta:
- Commit drift: `git rev-list <prior-commit>..HEAD` — what changed?
- Coverage gaps: what paths were unvisited last time?
- Present the delta to the user: resurvey stale paths, extend to gaps,
  full resurvey, or trust prior survey. See `references/survey-fingerprint.md`.

**Write `specs/<topic>/survey.md`** with:
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

**Write `specs/<topic>/team.md`** with persona definitions in boxed ASCII format.

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

**Write `specs/<topic>/icebreaker.md`** with the full discussion, including
any artifact review decisions.

**Collapse rule:** If no spec-like artifacts were selected, skip prior work
review entirely — go straight to status quo and sub-problem identification.

### Phase 3: BREAKOUT (parallel when possible)

For each sub-problem identified in the icebreaker:
- Estimate **CIU** (Complexity Integration Units) per breakout — see
  `references/complexity-units.md` for the scale. Use CIU to decide
  whether to parallelize or serialize. Always pair the number with
  its human-readable analog (e.g., "CIU 5 — solid day of work").
- Assign 2-3 personas
- Launch as a parallel sub-agent if independent
- Each breakout can invoke skills mid-conversation:
  - VERIFY: Grep/Read to check a claim
  - RESEARCH: WebSearch/WebFetch for external info
  - DISCOVERY: Explore agent for code mapping
  - PROTOTYPE: Write draft code for illustration
- Produce a recommendation
- **Write `specs/<topic>/breakout-<subtopic>.md`** for each breakout

**Collapse rule:** If the problem is singular (no sub-problems identified),
skip BREAKOUT entirely and proceed to CONVERGE. Not every problem needs
decomposition.

### Phase 4: CONVERGE + PLAN

Reconvene the full team. Merge breakout findings. Resolve conflicts.

**Write `specs/<topic>/plan.md`** with:
- ASCII slide deck (use box-drawing for slides)
- Problem visualization
- Solution architecture diagram
- Implementation steps (numbered, sequential)
- Code changes summary (files touched, lines added)
- Risk matrix
- Non-goals section (REQUIRED — each with "why skip" + "when to revisit")
- Success criteria (REQUIRED — measurable)
- Roadmap sketch (now / soon / later) with **CIU per item** and human analog
  (e.g., "CIU 3 — a morning's work"). CIU ≥ 13 must be decomposed.

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
19. Effort uses CIU (Complexity Integration Units), never time estimates.
    Always pair CIU with its human-readable analog. CIU ≥ 13 must decompose.

## Output Format

All output files go in `specs/<topic>/` where `<topic>` is derived from
the problem statement (kebab-case, e.g., `agc`, `opus-negotiation`,
`websocket-backpressure`).

Archive output goes in `specs/.storytime/archive/` with subdirectories:
`current/` (warm), `rollups/` (warm), `cold/` (deep history).

## Conversation Modes

- **Inline** (default): User is present, can interject any time
- **Deliberation**: If user says "go figure this out", team works
  autonomously and returns with findings + questions
- **QA**: If user says "@persona question", route to that persona

## Additional Resources

For detailed format specifications and scan targets, consult:
- **`references/artifact-scan.md`** — Scan targets, classification, inventory presentation
- **`references/artifact-tiers.md`** — Hot/warm/cold tiers, rollup format, archive structure
- **`references/survey-fingerprint.md`** — Coverage fingerprint format, incremental survey logic
- **`references/complexity-units.md`** — CIU scale, signals, usage in plans and breakouts
- **`${CLAUDE_PLUGIN_ROOT}/docs/process-reference.md`** — Events, skills, rules, automation levels
- **`${CLAUDE_PLUGIN_ROOT}/docs/architecture.md`** — Runtime model and agent dispatch
- **`${CLAUDE_PLUGIN_ROOT}/docs/historical-absorption.md`** — Archaeology and interface mapping
- **`${CLAUDE_PLUGIN_ROOT}/examples/agc-session.md`** — Real session walkthrough
- **`${CLAUDE_PLUGIN_ROOT}/examples/persona-template.md`** — Persona starter template
