---
name: storytime-buildout
description: "This skill should be used when the user asks to \"build it\", \"implement the plan\", \"buildout\", \"execute the plan\", \"start coding\", \"pair on this\", \"let's build\", or wants to take an approved storytime plan and implement it with persona-driven pair programming. Turns plans into code with full traceability."
argument-hint: "<topic> or <plan-item-number>"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch]
---

<!-- version-echo: display "storytime v1.0.0" at start of execution -->
# Storytime Buildout — Plan to Code

Take an approved plan and implement it. Personas who designed it now build
it — pair programming with full traceability from decision to code.

## Arguments

What to build: $ARGUMENTS

## How Buildout Differs from Breakout

**Breakout** = investigate a question, produce a recommendation (words).
**Buildout** = implement a plan item, produce working code (files).

Breakouts are discussions. Buildouts are coding sessions. The team shifts
from "what should we do?" to "let's do it."

## Process

### 1. Load the Plan

Find the approved plan:
- `specs/.storytime/sessions/<topic>/<episode>/plan.md`
- Or the user specifies a plan file

Read it. Extract the implementation steps. Each step becomes a potential
**work slice** — a unit of buildout work.

### 2. Slice the Work

Present the plan items as buildout slices:

```
Plan: rate-limiting (episode 001)

Work slices:

1. Create src/middleware/rate-limit.ts — sliding window logic
   Complexity 3 | @owner + @systems | Decision: RATE-001, RATE-002

2. Add tier config to src/config/rate-limits.ts
   Complexity 2 | @owner | Decision: RATE-003

3. Mount middleware in src/server.ts between auth and routes
   Complexity 2 | @owner + @operator | Decision: RATE-003

4. Add Prometheus counters to src/monitoring/metrics.ts
   Complexity 2 | @operator | Decision: RATE-004

5. Add response headers (Retry-After, X-RateLimit-*)
   Complexity 1 | @owner | Decision: RATE-003

6. Add RATE_LIMIT_ENABLED env var kill switch
   Complexity 1 | @operator | Decision: RATE-004

7. Write integration tests
   Complexity 3 | @owner + @critic | All decisions

Build all? Pick specific slices? Reorder?
```

The user can:
- **Build all** — sequential execution of all slices
- **Pick N** — build specific slices (for partial implementation)
- **Reorder** — change the sequence (dependencies permitting)
- **Split** — break a slice into smaller pieces
- **Merge** — combine related slices into one coding session

### 3. Pre-Slice Synopsis

Before starting each slice, the assigned subteam presents a **synopsis**
of what they're about to do:

```
Slice 1: Create rate limiter middleware

  @owner: I'll write the sliding window logic in src/middleware/rate-limit.ts.
          Redis sorted sets for counters, atomic pipeline for the check.
  @systems: I'll review the Redis interaction — making sure the pipeline
            is correct and we handle connection failures.

  Decisions driving this: RATE-001, RATE-002
  Files: src/middleware/rate-limit.ts (create), src/config/redis.ts (read)
  Estimated scope: ~60 lines of middleware + tests

  [approve / join / defer / pause / deprioritize / cancel]
```

The user directs:
- **Approve** — proceed, the subteam runs the slice
- **Join** — user participates inline, pair programming with the team
- **Inline** — like join, but user drives and team advises
- **Defer** — skip this slice for now, come back to it later
- **Pause** — stop the buildout entirely, checkpoint the thread
- **Deprioritize** — move this slice to the end of the queue
- **Cancel** — remove this slice from the buildout (with confirmation)
- **Adjust** — change team composition, scope, or approach before starting

If the user approves without comment, the subteam proceeds autonomously
and reports back with the trace document. If the user joins, the session
becomes interactive pair programming.

### 4. Execute a Slice (the coding session)

Each slice is a **persona-driven coding session** with **one driver**.
The driver writes the code; supporters watch and only speak when their
perspective is useful and non-distortive. This is pair programming with
a clear lead — not round-robin commentary. See "Driving Persona" in the
main SKILL for the trigger conditions.

**How personas collaborate in code:**

The **driver** (usually @owner or the domain-closest persona) writes the
primary implementation. **Supporters** (often @critic or @operator)
hold a watching brief and challenge in real-time *only when* a trigger
fires — ungrounded claim, factual error, missing constraint, scope drift,
or driver handoff:

```
Driver: @owner [anchor]
Supporters (watching brief): @systems [lattice], @critic [forge]

@owner: Creating the rate limiter middleware. The sliding window needs
        a Redis sorted set per client key...
        [writes src/middleware/rate-limit.ts]

@systems: [trigger: factual risk] ZADD + ZRANGEBYSCORE needs to be atomic
          here. Use a Redis pipeline or Lua script — otherwise race
          conditions under concurrent requests.
          [redis.io/topics/transactions] — Redis transactions docs

@owner: Good catch. Wrapping in a pipeline:
        [edits src/middleware/rate-limit.ts:23-35]
        [@systems silent — issue resolved, yields back]

@critic: [trigger: missing constraint] Key format `ratelimit:${clientId}`
         loses tier-change semantics. Per RATE-003, key on clientId+tier.
         [@critic silent — flagged, yields back]
```

Note the pattern: supporters speak once with a tagged trigger, then
yield. No back-and-forth, no commentary, no "good point @owner". The
driver keeps writing.

**What gets written:**
- The actual code files (created or modified)
- The trace document (see below)

### 5. Trace Document

Every buildout slice produces a **trace** — a structured record that maps
plan decisions to code changes. This is the traceability backbone.

**Write `specs/.storytime/sessions/<topic>/<episode>/buildout-<slice>.md`:**

```yaml
---
type: buildout
created: <YYYY-MM-DDTHH:MM>
session: <session-id>
topic: <topic>
slice: <slice-name>
plan_items: [1, 2]
decisions: [RATE-001, RATE-002]
driver: @owner [anchor]
supporters: [@systems [lattice], @critic [forge]]
supporters_who_spoke: [@systems, @critic]
files_created: [src/middleware/rate-limit.ts]
files_modified: [src/server.ts]
tests_added: [test/rate-limit.test.ts]
---

# Buildout: <slice-name>

## Plan Reference
Items 1-2 from plan.md: Create rate limiter middleware with sliding window.
Decisions: RATE-001 (sliding window algorithm), RATE-002 (Redis sorted sets).

## Implementation Trace

### src/middleware/rate-limit.ts (created)
- Lines 1-15: Module setup, Redis client import, tier config import
  Per RATE-002: using existing Redis connection from src/config/redis.ts:5
- Lines 17-45: slidingWindowCheck() — atomic pipeline with ZADD + ZRANGEBYSCORE
  Per RATE-001: 60s window, sorted set per client key
  @systems flagged race condition risk — resolved with Redis pipeline
- Lines 47-68: rateLimit() middleware function — extracts tier from JWT,
  calls slidingWindowCheck, returns 429 with headers on exceeded
  Per RATE-003: key format ratelimit:${tier}:${clientId}
  @critic caught tier-change edge case — included tier in key

### src/server.ts (modified)
- Line 22: Added rate-limit middleware mount between auth and routes
  Per RATE-003: position after auth (needs JWT), before routes

## Discussion Notes
- @systems: "The pipeline approach adds ~0.1ms per request vs individual
  commands. Acceptable given our 1ms budget." [redis.io/topics/pipelining]
- @critic: "Consider extracting the key format to config for testability."
  Deferred — added to open questions for next slice.

## Open Questions
- Should key format be configurable? (deferred from @critic)
- TTL cleanup: relying on ZRANGEBYSCORE pruning vs explicit EXPIRE

## Test Coverage
- test/rate-limit.test.ts: 4 tests added
  - Allows requests under limit
  - Returns 429 when limit exceeded
  - Respects tier-specific limits
  - Returns correct Retry-After header
```

### 6. Testing

Every buildout slice ends with testing. This is not optional.

- **Run existing tests** to verify no regressions
- **Write new tests** for the implemented functionality
- **Verify against plan success criteria** — does the code satisfy them?

If tests fail, the team investigates and fixes in the same session.
The trace document records what failed and how it was resolved.

### 7. Slice Boundaries

Slices end when one of these is true:
- **The plan item is complete** — all code written, tests passing
- **A blocker is hit** — needs a decision not covered by the plan, or
  reveals an assumption was wrong. Flag it, checkpoint, move to next slice
  or escalate back to a breakout
- **Scope creep** — the slice is growing beyond its plan item. Stop,
  document what was done and what remains, suggest splitting

Slices do NOT end because of artificial phase gates. If the work flows
naturally from items 1→2→3 without stopping, that's one slice. If item 2
reveals a blocker that item 3 depends on, that's where to stop.

### 8. Buildout Completion

When all slices are done (or the user stops):

- **Update `_thread.md`** with buildout progress: which slices completed,
  which are pending, which hit blockers
- **Update persona files** — the team learned things during implementation
  that weren't in the plan
- **Run full test suite** — final verification
- **Run `/storytime-lint`** on the session — catch any trace docs missing
  driver, decisions, or citations before closing out
- **Present summary + loop-closing suggestion:**

```
Buildout complete: rate-limiting

Slices: 7/7 complete
Files created: 3 (rate-limit.ts, rate-limits.ts, rate-limit.test.ts)
Files modified: 2 (server.ts, metrics.ts)
Tests: 12 added, all passing
Decisions implemented: RATE-001 through RATE-004
Lint: clean (21 passed, 0 warnings, 0 failed)

Trace documents:
  buildout-middleware.md
  buildout-config.md
  buildout-integration.md
  buildout-monitoring.md
  buildout-tests.md

──────────────────────────────────────────────────────────
Recommended next step: /storytime-retro rate-limiting

  Reconvene the team to compare plan vs built. Closes the
  feedback loop so personas learn from this implementation
  before the next session.

Other options: PR (ship it), next topic, pause
──────────────────────────────────────────────────────────
```

The retro suggestion is **not optional advice** — it's the documented
loop closure. Without it, personas don't learn from implementation
divergence, decisions don't get verified against reality, and the
next session starts with a stale mental model. Skip it only if the
user explicitly says "not this time."

## Rules

1. **Plan first.** Buildout requires an approved plan. No plan → suggest
   running `/storytime` first.
2. **Trace everything.** Every code change maps back to a plan item and
   decision. The trace document is the proof that implementation matches
   design.
3. **One driver per slice.** The driver writes the code; supporters hold
   a watching brief and only interject on a trigger (factual error,
   missing constraint, scope drift, ungrounded claim, driver handoff).
   Supporters who never spoke are recorded — silence is information.
   See "Driving Persona" in main SKILL.
4. **Test every slice.** No buildout slice is complete without tests.
5. **Blockers are signal, not failure.** If implementation reveals the plan
   was wrong, that's valuable. Flag it, trace it, escalate if needed.
6. **Slices are natural, not prescribed.** The plan suggests boundaries but
   the code decides where the real seams are. Merge or split as needed.
7. **Commit per slice.** Each completed slice should be a committable unit.
   The trace document goes in the commit or alongside it.
8. **The plan is the contract.** Implementation should match the plan. If
   it diverges, the trace must explain why. "We discovered X during
   implementation" is valid. Silent divergence is not.
9. **Close the loop with retro.** Every completed buildout suggests
   `/storytime-retro` as the next action. Feedback loops that don't
   close don't teach. See the completion summary in step 8.
