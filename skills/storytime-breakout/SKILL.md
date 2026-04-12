---
name: storytime-breakout
description: "This skill should be used when the user asks to \"breakout on\", \"deep dive\", \"investigate\", \"focus on\", \"drill into\", or wants to run a focused investigation on a specific sub-problem with one driving persona (plus at most 1-2 silent supporters) without running the full storytime pipeline. Standalone breakout that produces a recommendation."
argument-hint: "<sub-problem>"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch]
---

<!-- version-echo: display "storytime v0.9.0" at start of execution -->
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
- Assemble a **minimal** team: one driver plus at most 1-2 supporters.
  Draw the driver from whichever lens owns the sub-problem. Supporters
  are present but silent unless they have something useful and
  non-distortive to add. (See "Driving Persona" in main SKILL.)
- The user can name specific personas or archetypes, or let the system pick
- Output goes wherever makes sense: `specs/.storytime/sessions/<topic>/001/`
  for a new topic, or a location the user specifies

### 2. Synopsis + User Direction

Before investigating, the **driver** presents what they plan to do.
Supporters announce their watching brief — what would make them speak up
during the breakout.

```
Breakout: is Redis or Memcached better for rate limit counters?

  Driver: @systems [lattice]
  Supporters: @operator [tide]

  @systems: I'll check our existing Redis setup and compare sorted set
            ops vs Memcached increment semantics for sliding windows.
            What we know: Redis already in stack (src/config/redis.ts:5)
            What we don't: whether sorted set ops are fast enough at scale
            Exit condition: clear recommendation with latency evidence
  @operator: Watching brief — I'll speak up if the recommendation has no
             kill switch or no monitoring story.

  [approve / join / defer / pause / cancel]
```

**The driver must be named in the synopsis.** If the synopsis doesn't
name a driver, it's not ready — the breakout cannot start. This is the
earliest structural gate for rule 33 (one driver per leg).
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

The **driver** works the problem. Available mid-breakout skills:

| Skill | Use |
|-------|-----|
| VERIFY | Grep/Read to check a claim against code |
| GROUND | Read repo docs (README, ADRs, specs) to verify context |
| RESEARCH | WebSearch/WebFetch for external docs, RFCs, benchmarks |
| DISCOVERY | Explore agent for code mapping |
| PROTOTYPE | Write draft code for illustration |

The driver speaks in the foreground. **Supporters stay silent** unless one
of the trigger conditions fires (ungrounded claim, factual error, missing
constraint, scope drift, user-addressed, or explicit handoff). When a
supporter does speak, they say their piece and yield back — no
conversational ping-pong. See "Driving Persona" in the main SKILL.

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

**Write `breakout-<subtopic>.md`** — `driver` is the FIRST required field
after type/created. Write it first, before the body:

```yaml
---
type: breakout
created: <YYYY-MM-DDTHH:MM>
driver: <@role [codename]>          ← FIRST (required, non-negotiable)
supporters: [<@role [codename]>, ...]
supporters_who_spoke: [<@role>, ...]
session: <session-id or null>
topic: <parent-topic or null>
subtopic: <subtopic>
schema_version: 1
---
```

If inside an active session, update `_thread.md` with the breakout as a
completed step.

## Rules

1. **One driver, at most 2 supporters.** Breakouts are small and focused.
   Driver works the problem in the foreground; supporters are silent
   backstops. See "Driving Persona" in main SKILL.
2. The driver (or a supporter who speaks up) must be able to verify
   claims against code.
3. Every finding must cite evidence (code, docs, or research).
4. The recommendation must include Complexity and Scale with prose.
5. If the breakout reveals the problem is bigger than expected, say so
   and recommend escalating to a full storytime session.
6. Breakouts are fast. If investigation exceeds the sub-problem scope,
   stop, document what you found, and flag the scope creep.
7. Supporters who never spoke up are still recorded in the trace —
   their silence is information (the driver's lens covered it cleanly).
