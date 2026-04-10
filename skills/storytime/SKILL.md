---
name: storytime
description: "This skill should be used when the user asks to \"storytime\", \"run storytime\", \"build a spec\", \"assemble a team\", \"persona discussion\", \"design a feature\", \"spec this out\", or wants to plan a feature through structured team conversation with domain-expert personas. Runs the full Storytime workflow: survey codebase, assemble persona team, run icebreaker, execute breakouts, and produce a plan with ASCII visual aids."
argument-hint: "<problem-statement>"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch]
---

<!-- version-echo: display "storytime v0.7.2" at start of execution -->
# Storytime — Full Workflow

Orchestrate a structured specification process through persona-driven
conversations. This file is the orchestrator; topic-specific detail lives
in `references/` and loads on demand.

## Arguments

The user's problem statement: $ARGUMENTS

## Process

Follow this state machine in order, but **collapse phases that have no
real work**. If no artifacts exist, skip the inventory. If the team is
obvious, don't belabor ASSEMBLE. If the problem is simple, go straight
from ICEBREAKER to CONVERGE. The phase sequence defines the *maximum*
workflow — actual sessions use only the gears they need.

### Entry: Route

- **No arguments** (bare `/storytime`) → scan all `_thread.md` files in
  the storytime session directory, present a topic picker:

  ```
  Recent storytime threads:

  1. rate-limiting  (episode 2, last: 2026-04-01, DONE)
  2. auth-refactor  (episode 1, last: 2026-03-28, ICEBREAKER — incomplete)

  Resume one? Or describe a new problem.
  ```
  Incomplete sessions are highlighted. If only one thread exists and
  it's incomplete, auto-resume. User picks a number, types a topic
  name, or describes a new problem.

- **Arguments provided** → derive `<topic>` from the problem statement
  (kebab-case). Check for `sessions/<topic>/_thread.md`:
  - **Thread found** → Warm Start
  - **No thread** → Cold Start

### Warm Start (thread exists)

Read `_thread.md`, last episode's key artifacts (plan.md, icebreaker.md,
persona files filtered to participants), and compute the codebase delta
(`git rev-list <last_commit>..HEAD`, `git diff --stat`). Cross-reference
changed files with the last survey fingerprint.

Synthesize a **narrative preamble** — 3-5 sentences that reconstruct the
story arc, always fresh, never cached. It tells what problem the team was
solving, who drove which decisions, what changed since, what's still open.
Present as a "Previously on..." card with options: Continue · Retro ·
New sub-topic · Reset.

Personas skip introductions on warm start — they speak from accumulated
context, not from their bio. Write `<episode>/preamble.md` as the audit
trail of what context the session started with.

**Collapse:** "skip the recap" → skip the card. Zero drift → omit drift
line. Empty open questions → omit. Direction implied → auto-Continue.

→ Full procedure, card format, routing, checkpointing: `references/warm-start.md`

### Cold Start (no thread)

Derive `<topic>`. Detect the landscape before creating anything:
- `specs/.storytime/` exists? → already uses storytime structure
- Own doc structure (`team/`, `docs/`, `specs/`)? → work within it
- Fresh repo? → propose storytime structure

Pick a mode: **storytime-native**, **adapt-in-place**, or **export-only**.
Default: native for fresh repos, adapt for repos with existing structure.
Ask if ambiguous. Never create `.storytime/` without the user's knowledge.

→ Mode details, decision tree, path mapping: `references/output-modes.md`
→ Or delegate initial setup to `/storytime-bootstrap`

### Phase 0: SURVEY

Launch an Explore agent scoped to the problem.

**Prior run detection** — check for existing session output for this
topic; prior runs are prior art, never silently overwrite.

**Codebase scan** — identify existing code, patterns, dependencies,
constraints. Produce a mental model of the problem space.

**Artifact scan** — scan the repo for prior-work artifacts (specs, docs,
ADRs, agent definitions, team files, .kiro). Classify each
[team] [spec] [config] or noise. Present an inventory checklist to the
user. Options: toggle on/off, "tell me about <item>", "bring the team in
on <item>", "skip all", direct instruction.

Config-like artifacts (CLAUDE.md, cursor rules) load silently. Team-like
route to ASSEMBLE. Spec-like route to ICEBREAKER. Default bias:
consolidate (`git mv` into storytime structure, preserving history).
User can override per-item or bulk.

If a prior survey.md exists with a fingerprint, compute the delta
(commit drift, coverage gaps) and present options: resurvey stale paths,
extend to gaps, full resurvey, or trust prior survey.

**Write `sessions/<topic>/survey.md`** with codebase context, artifact
inventory, and a **coverage fingerprint** (REQUIRED: commit sha, branch,
paths scanned, paths skipped, paths unvisited, file counts, coverage
ratio, artifact counts by classification).

**Collapse:** no artifacts → skip inventory. Config-only → load silently
and move on.

→ Scan targets, classification heuristics: `references/artifact-scan.md`
→ Fingerprint format, delta logic: `references/survey-fingerprint.md`

### Phase 1: ASSEMBLE

**Rehire candidates** — present team-like artifacts as rehire candidates
with their accumulated context. User decides per candidate: rehire,
modify, or skip.

**Load the permanent cohort** — if `cohort/_roster.md` exists, read it
and load active persona files. These participate by default.

**Recruit specialists** to fill gaps — analyze which domains the problem
touches, propose a specialist for each uncovered domain (codename,
archetype, background, scope, exit condition).

**Default core:** OWNER, OPERATOR, CRITIC ×2 (two critics contest each
other). Additional lenses: DOMAIN, SYSTEMS, PLATFORM, SKEPTIC, EDUCATOR.

**Team size is project-appropriate, not fixed.** Bias small. Tiny
problem → 1-2 personas (driver only). Default core → 3-4. Architectural
→ 6-8. Hard ceiling 12 (override required). Duplicate archetypes are
allowed when they have distinct focus and produce productive tension.

**Codenames are non-human by default** — concept words like `anchor`,
`lattice`, `kestrel`, `ember`, `forge`. The role is the load-bearing
address; the codename is ornament. Human names only when the user picks
them.

**Write `sessions/<topic>/team.md`** with boxed ASCII persona cards.

**Collapse:** cohort covers the domains + no rehire candidates → confirm
briefly and move on.

→ Archetypes, persona character, naming rules, sizing table, duplicate
  archetypes, specialist contracts: `references/team-assembly.md`

### Phase 2: ICEBREAKER

Team introduces themselves. If spec-like artifacts were selected in
SURVEY, review each: current? valuable? stale? superseded? Decide
disposition (keep hot / archive warm / rollup / send cold / skip). If
archived or rolled up, update `archive/_index.md`.

**Establish the status quo** with code citations. **Identify
sub-problems** for breakouts. **Agree on constraints** before any
solution is proposed.

**Write `sessions/<topic>/icebreaker.md`** with the full discussion.

**Collapse:** no spec artifacts → skip prior work review, go straight
to status quo and sub-problems.

→ Hot/warm/cold tier rules, rollup format: `references/artifact-tiers.md`

### Phase 3: BREAKOUT (parallel when possible)

For each sub-problem:
- Estimate **Complexity** (how hard) and **Scale** (how big) with prose
  (e.g., "Complexity 5 — solid day, Scale 3 (repos) — service cluster").
- Assign **one driving persona** plus 1-2 silent supporters. The driver
  has the floor; supporters stay silent unless a trigger fires (see
  `references/driving-persona.md`).
- **Pre-breakout synopsis**: driver states plan, supporters state
  watching brief, user directs (approve / join / defer / pause / cancel).
- Launch as a parallel sub-agent if independent.
- Use mid-breakout skills: VERIFY (Grep/Read), GROUND (repo docs),
  RESEARCH (web), DISCOVERY (Explore), PROTOTYPE (draft code).
- Grounding is **multi-source** — strongest evidence wins.
- Produce a recommendation with citations.

**Write `sessions/<topic>/breakout-<subtopic>.md`** per breakout with:
driver, supporters, findings, citations, recommendation, Complexity,
Scale, open questions.

**Post-breakout pause is mandatory** (unless auto). Present one summary
card per breakout → user: proceed / dig into N / revise N / add breakout.
Do not auto-proceed to CONVERGE.

**Collapse:** singular problem → skip BREAKOUT, go straight to CONVERGE.

→ Complexity scale: `references/complexity-units.md`
→ Scale 1-5 with dimensions: `${CLAUDE_PLUGIN_ROOT}/docs/scale-impact.md`
→ Standalone invocation: `/storytime-breakout <sub-problem>`

### Phase 4: CONVERGE + PLAN

Reconvene the team. Merge breakout findings. Resolve conflicts. **Each
plan section has one driver** — the lens closest to the section. Can
also run standalone via `/storytime-converge`.

**Write `sessions/<topic>/plan.md`** with:
- ASCII slide deck (problem viz, architecture diagram)
- Numbered implementation steps (sequential, with breakout cross-refs)
- Code changes summary (files touched, lines added)
- Risk matrix
- **Non-goals** (REQUIRED: why skip + when to revisit)
- **Success criteria** (REQUIRED: measurable)
- Roadmap (now / soon / later) with **Complexity + Scale per item** in
  prose. Complexity ≥ 13 must decompose. Scale dimensions stated.

### Phase 5: REVIEW

Present the plan to the user. Enter inline mode — user can challenge
decisions (personas respond with rationale), request changes (team
revises), or approve.

### Phase 6: DONE

Update persona files with new context. Log session in `history/`.
Evaluate specialist contracts (complete/promote/release). Commit archive
changes. **Finalize `_thread.md`**: append the completed episode,
add new decisions, set `last_completed_phase: DONE`, clear open
questions, record current `HEAD` as `last_commit`.

### Thread Checkpointing (automatic)

At every phase boundary, write or update `_thread.md`
(`last_completed_phase`, `last_commit`, `open_questions`). Created at
the first phase of episode 1, always current thereafter. If the session
is interrupted, the next `/storytime` detects the incomplete thread and
offers to resume. No explicit "park" command — the checkpoint is
already there.

## Process Rules

1. SURVEY before ASSEMBLE. Never build a team blind.
2. ICEBREAKER before BREAKOUT. Shared understanding before depth.
3. CONVERGE before showing the user. Internal consensus first.
4. Every technical claim must be grounded — cite code, docs, or external sources.
5. Default core: OWNER, OPERATOR, CRITIC ×2. Two critics minimum — they contest each other.
6. Non-goals and success criteria are required, not optional.
7. Visual aids use ASCII box-drawing. No external tools.
8. Personas are lenses, not characters. No role-play, only expertise.
9. Team size is appropriate to the project, not fixed. Bias small. Hard ceiling 12.
10. The user has veto power over everything.
11. Artifact scan is broad — expect variance across repos in the wild.
12. The user controls depth at every stage. Full shebang or skip all.
13. Rollups replace stale docs — originals go cold, rollup stays warm.
14. Archive artifacts must be git-committable and repo-local.
15. Phases collapse when empty — never present ceremony for absent content.
16. Every phase writes its output — a run is a complete snapshot, track everything.
17. Prior runs are prior art — detect and present, never silently overwrite.
18. Every survey writes a coverage fingerprint — commit, paths, gaps, ratios.
19. Effort uses Complexity (how hard) and Scale (how big), never time estimates. Complexity ≥ 13 must decompose.
20. Evaluation hygiene: observe metrics and conclusions separately.
21. Warm start is detected, not requested. If `_thread.md` exists, warm-start.
22. The preamble narrative is always dynamic — synthesized fresh, never cached.
23. Personas skip introductions on warm start. They speak from accumulated context.
24. Thread state is the checkpoint — updated at every phase boundary.
25. Episodes are chapters of the same story. Reset is the explicit "new story" action.
26. Survey delta replaces full survey on warm start. Only resurvey what changed.
27. Post-breakout pause is mandatory (unless auto). Present summaries, wait for user.
28. Converge can run standalone via `/storytime-converge`.
29. Grounding is multi-source: code, docs, web, git — strongest evidence wins.
30. Personas use `@role` — roles are functional model attention anchors, names are ornaments.
31. Pre-work synopsis before every breakout and buildout slice — user directs.
32. Personas use **non-human codenames by default** (`anchor`, `lattice`, `kestrel`).
33. **One driving persona per leg.** Supporters stay silent unless useful AND non-distortive.
34. Team size is sized to the work, not the template. Tiny problem → tiny team.

## Driving Persona (core rule summary)

At every leg — phase, breakout, buildout slice, discussion segment —
**exactly one persona drives**. The driver writes the artifact and owns
the recommendation. Other personas are **implied, not absent** — in the
room, silent unless their interjection is both **useful** (catches a miss,
grounds a claim, corrects an error) and **non-distortive** (moves the leg
forward, not sideways). Supporters who never spoke are still recorded —
silence means the driver's lens covered the territory cleanly.

→ Trigger conditions, driver selection, failure modes, interaction
  pattern: `references/driving-persona.md`

## @role Addressing (core convention summary)

The `@` prefix is a **model attention anchor**. Roles are functional and
load-bearing; codenames are ornaments.

- `@role` — default functional anchor (`@owner:`, `@systems:`)
- `@role:focus` — qualified (`@critic:architecture`)
- `@role:explain` — teaching mode (reactive unpacking, any persona)
- `@role [codename]` — role-first with ornament (`@owner [anchor]`)
- `@codename` — shorthand resolved via roster

`@role` is **not a skill trigger** — it's a lens directive. It can
appear inline in conversation, in written artifacts, in QA, anywhere.
The model should apply the role's lens to the following content without
requiring a formal skill invocation. Full QA routing via
`/storytime-qa` still works for explicit query mode.

→ Full formats, where @ applies, flexibility rules, why roles first:
  `references/addressing.md`

## Citations (summary)

Claims must be grounded. **Evidence hierarchy** (strongest to weakest):
**Code > Git > Repo files > Library docs > Standards > Web**. Personas
reach for the strongest available evidence. Ungrounded claims get
challenged ("ground that?"). Web search proactively for external
systems, libraries, protocols.

→ Format per source, multi-source grounding, web search workflow:
  `references/citations.md`

## Output Paths (summary)

Depend on bootstrap mode:

- **Storytime-native** — `specs/.storytime/` with full tree
- **Adapt-in-place** — writes into existing repo conventions
- **Export-only** — unified plan for another system, no persistent state

→ Full tree, convention mapping, component interop, mode detection:
  `references/output-modes.md`

## Conversation Modes

- **Inline** (default): User is present, can interject any time
- **Deliberation**: "go figure this out" → team works autonomously, returns
- **QA**: `@persona question` → routes via `/storytime-qa`, or answered
  inline if the context is already loaded

## Additional Resources

**Phase-adjacent references** (load when the phase fires):
- `references/warm-start.md` — thread format, preamble synthesis, checkpointing
- `references/artifact-scan.md` — scan targets, classification heuristics
- `references/survey-fingerprint.md` — coverage fingerprint, delta logic
- `references/artifact-tiers.md` — hot/warm/cold, rollup format
- `references/complexity-units.md` — Complexity scale, signals
- `references/team-assembly.md` — archetypes, character, naming, sizing
- `references/output-modes.md` — native/adapt/export, tree, interop

**Cross-cutting references** (load when the topic comes up):
- `references/addressing.md` — @role convention, formats, flexibility
- `references/driving-persona.md` — trigger conditions, failure modes
- `references/citations.md` — format examples, evidence hierarchy, web search
- `references/error-recovery.md` — what to do when a phase fails mid-run

**Project docs** (load on demand):
- `${CLAUDE_PLUGIN_ROOT}/docs/scale-impact.md` — Scale 1-5, dimensions
- `${CLAUDE_PLUGIN_ROOT}/docs/process-reference.md` — events, automation
- `${CLAUDE_PLUGIN_ROOT}/docs/architecture.md` — runtime, agent dispatch
- `${CLAUDE_PLUGIN_ROOT}/examples/agc-session.md` — real walkthrough
- `${CLAUDE_PLUGIN_ROOT}/examples/persona-template.md` — persona starter

**Related skills:**
- `/storytime-breakout` — focused investigation (standalone)
- `/storytime-converge` — plan synthesis from breakouts (standalone)
- `/storytime-buildout` — implement an approved plan
- `/storytime-bootstrap` — set up `.storytime/` in a repo
- `/storytime-cohort` — hire/fire/evolve permanent personas
- `/storytime-echo` — spawning-pool voice test (no state)
- `/storytime-lint` — mechanical validation against the process rules
- `/storytime-retro` — reconvene team to compare plan vs built (close the loop)
