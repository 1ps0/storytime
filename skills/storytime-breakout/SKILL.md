---
name: storytime-breakout
description: "This skill should be used when the user asks to \"breakout on\", \"deep dive\", \"investigate\", \"focus on\", \"drill into\", or wants to run a focused investigation on a specific sub-problem with 2-3 personas without running the full storytime pipeline. Standalone breakout that produces a recommendation."
argument-hint: "<sub-problem>"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch]
---

<!-- version-echo: display "storytime v0.6.0" at start of execution -->
# Storytime Breakout — Standalone

Run a focused investigation on a specific sub-problem with a small persona
team. Produces a recommendation without the full storytime pipeline.

## Arguments

The sub-problem to investigate: $ARGUMENTS

## When to Use

- Mid-conversation when a specific question needs depth
- When the user has a focused question that doesn't need full SURVEY → PLAN
- When an existing session raises a sub-problem worth isolating
- When the user says "what about X?" and X deserves its own investigation

## Process

### 1. Context Check

**If inside an active storytime session** (thread exists for a related topic):
- Read `_thread.md` for the parent topic — load team, decisions, state
- The breakout inherits the session's team context
- Output goes in the current episode: `<episode>/breakout-<subtopic>.md`

**If standalone** (no related thread):
- Quick codebase scan (Explore agent, scoped to the sub-problem)
- Assemble a minimal team: 2-3 personas, draw from the default core (owner, operator, critic) unless the problem suggests otherwise
- The user can name specific personas or archetypes, or let the system pick
- Output goes wherever makes sense: `specs/.storytime/sessions/<topic>/001/`
  for a new topic, or a location the user specifies

### 2. Synopsis + User Direction

Before investigating, the subteam presents what they plan to do:

```
Breakout: is Redis or Memcached better for rate limit counters?

  @systems: I'll check our existing Redis setup and compare sorted set
            ops vs Memcached increment semantics for sliding windows.
  @operator: I'll evaluate operational complexity — monitoring, failure
             modes, connection pooling for each option.

  What we know: Redis already in stack (src/config/redis.ts:5)
  What we don't: whether sorted set ops are fast enough at our scale
  Exit condition: clear recommendation with latency evidence

  [approve / join / defer / pause / cancel]
```

- **Approve** — subteam investigates autonomously, reports back
- **Join** — user participates, can steer the investigation
- **Defer** — skip for now, come back later
- **Pause** — stop, checkpoint thread
- **Cancel** — remove this breakout

### 3. Frame the Investigation

State the question clearly. Identify:
- What we know (cite code, prior decisions, or prior session artifacts)
- What we don't know (the gap this breakout fills)
- Constraints (time, scope, dependencies)
- Exit condition (what does "answered" look like?)

### 4. Investigate

The breakout team works the problem. Available mid-breakout skills:

| Skill | Use |
|-------|-----|
| VERIFY | Grep/Read to check a claim against code |
| GROUND | Read repo docs (README, ADRs, specs) to verify context |
| RESEARCH | WebSearch/WebFetch for external docs, RFCs, benchmarks |
| DISCOVERY | Explore agent for code mapping |
| PROTOTYPE | Write draft code for illustration |

Each persona contributes from their domain lens. The investigation is
a focused conversation, not a monologue.

### 5. Produce Recommendation

The breakout converges on a recommendation:

- **Finding:** What did the investigation discover?
- **Recommendation:** What should we do?
- **Confidence:** How sure are we? (high/medium/low with rationale)
- **Complexity estimate:** How hard is the recommended work?
- **Scale estimate:** How big is the blast radius?
- **Open questions:** What couldn't we resolve?
- **Citations:** Code, doc, web, or git references grounding the recommendation

### 6. Output

**Write `breakout-<subtopic>.md`** with universal frontmatter:

```yaml
---
type: breakout
created: <YYYY-MM-DDTHH:MM>
session: <session-id or null>
topic: <parent-topic or null>
subtopic: <subtopic>
personas: [<names>]
---
```

If inside an active session, update `_thread.md` with the breakout as a
completed step.

## Rules

1. Minimum 2 personas, maximum 3. Breakouts are small and focused.
2. At least one persona must be able to verify claims against code.
3. Every finding must cite evidence (code, docs, or research).
4. The recommendation must include Complexity and Scale with prose.
5. If the breakout reveals the problem is bigger than expected, say so
   and recommend escalating to a full storytime session.
6. Breakouts are fast. If investigation exceeds the sub-problem scope,
   stop, document what you found, and flag the scope creep.
