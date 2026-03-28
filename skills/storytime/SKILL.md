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

## Process (follow this state machine strictly)

### Phase 0: SURVEY
1. Launch an Explore agent to survey the codebase relevant to the problem
2. Identify: existing code, patterns, dependencies, prior specs, constraints
3. Produce a mental model of the problem space (do not write a file yet)

### Phase 1: ASSEMBLE + ICEBREAKER

**Load the permanent cohort** if `specs/.storytime/cohort/_roster.md` exists:
- Read the roster, load each active persona's file
- These personas participate by default

**Recruit specialists** based on the problem's domain requirements:
- Analyze which domains the problem touches
- For each domain not covered by the cohort, propose a temporary specialist
- Each specialist gets: name, archetype, background, scope, exit condition

**Archetype checklist** (minimum 3 personas, at least one OPERATOR):
- DOMAIN: deep expertise in the problem domain
- SYSTEMS: knows the runtime, infra, failure modes
- PLATFORM: knows the product, user, business case
- OWNER: wrote the code, knows where everything lives
- OPERATOR: runs it in prod, wants observability and kill switches
- SKEPTIC: asks "what if this breaks?" and "do we actually need this?"

**Write `specs/<topic>/team.md`** with persona definitions in boxed ASCII format.

**Run the icebreaker** — a structured conversation where:
- Each persona states what they see from their vantage point
- The team establishes the status quo (with code citations)
- Sub-problems are identified for breakouts
- Constraints are agreed upon before any solution is proposed

**Write `specs/<topic>/icebreaker.md`** with the full discussion.

### Phase 2: BREAKOUT (parallel when possible)

For each sub-problem identified in the icebreaker:
- Assign 2-3 personas
- Launch as a parallel sub-agent if independent
- Each breakout can invoke skills mid-conversation:
  - VERIFY: Grep/Read to check a claim
  - RESEARCH: WebSearch/WebFetch for external info
  - DISCOVERY: Explore agent for code mapping
  - PROTOTYPE: Write draft code for illustration
- Produce a recommendation

### Phase 3: CONVERGE + PLAN

Reconvene the full team. Merge breakout findings. Resolve conflicts.

**Write `specs/<topic>/plan.md`** with:
- ASCII slide deck (use ╔═╗ box-drawing for slides)
- Problem visualization
- Solution architecture diagram
- Implementation steps (numbered, sequential)
- Code changes summary (files touched, lines added)
- Risk matrix
- Non-goals section (REQUIRED — each with "why skip" + "when to revisit")
- Success criteria (REQUIRED — measurable)
- Roadmap sketch (now / soon / later)

### Phase 4: REVIEW

Present the plan to the user. Enter inline mode — the user can:
- Challenge any decision (personas respond with rationale)
- Request changes (team revises)
- Approve (proceed to DONE)

### Phase 5: DONE

- Update persona files in `specs/.storytime/cohort/` with new context
- Log session in `specs/.storytime/history/`
- Evaluate specialist contracts (complete, promote, or release)

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

## Output Format

All output files go in `specs/<topic>/` where `<topic>` is derived from
the problem statement (kebab-case, e.g., `agc`, `opus-negotiation`,
`websocket-backpressure`).

## Conversation Modes

- **Inline** (default): User is present, can interject any time
- **Deliberation**: If user says "go figure this out", team works
  autonomously and returns with findings + questions
- **QA**: If user says "@persona question", route to that persona

## Additional Resources

For detailed event tables, breakout types, skill mappings, automation levels,
and file format specifications, consult:
- **`${CLAUDE_PLUGIN_ROOT}/docs/process-reference.md`** — Complete process reference
- **`${CLAUDE_PLUGIN_ROOT}/docs/architecture.md`** — Runtime model and agent dispatch
- **`${CLAUDE_PLUGIN_ROOT}/examples/agc-session.md`** — Real session walkthrough
- **`${CLAUDE_PLUGIN_ROOT}/examples/persona-template.md`** — Persona starter template
