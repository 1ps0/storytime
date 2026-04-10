---
type: reference
name: driving-persona
description: "Driving persona rule — one driver per leg, trigger conditions for supporters, how drivers are picked, recording, failure modes. Load when running a breakout, buildout slice, or any phase where persona collaboration happens."
---

# Driving Persona — One Drives, Others Imply

**At every leg of the process, exactly one persona drives.** A leg is any
discrete unit of work — a phase, a breakout, a buildout slice, an inline
discussion segment. The driver has the floor: they speak in the foreground,
write the artifact, own the recommendation, and decide when the leg is done.

The other personas on the team are **implied, not absent**. They're in the
room, they hear everything, but they stay silent unless they have something
that is *both useful and non-distortive*:

- **Useful** — they catch a missing perspective, ground a loose claim,
  surface a constraint the driver doesn't see, or correct a factual error.
- **Non-distortive** — speaking up moves the leg forward, not sideways.
  Not "here's how I would have approached this" or "in my experience..."
  unless that experience changes the outcome.

If neither test passes, **stay silent**. The driver's lens is the lens for
this leg. Round-robin commentary is what the rule exists to prevent.

## How Drivers Are Picked

- **Phase-level driver** — usually the persona whose lens is most
  load-bearing for that phase. SURVEY drives from @owner. ICEBREAKER may
  rotate. BREAKOUT drives from whichever persona owns the sub-problem.
- **Sub-problem driver** — the persona closest to the question. A caching
  question drives from @systems; a UX question drives from @platform.
- **Conflict resolution** — if two personas could plausibly drive, the
  user picks, or the team flags it as a sub-problem worth its own breakout.

## When Supporters Should Speak

Concrete triggers (any one is enough):

1. **Ungrounded claim** — driver asserts something that needs evidence.
   `@critic` interjects: "ground that?"
2. **Factual error** — driver is wrong about the code, the docs, or
   external behavior. Correct it once, then yield back.
3. **Missing constraint** — driver is about to commit to an approach
   that would break a constraint they don't know about.
4. **Scope shift** — the leg is drifting outside its exit condition.
   `@skeptic` flags: "is this still in scope?"
5. **User-addressed** — `@operator what about kill switches?` always wakes
   that role regardless of who is driving.
6. **Driver hands off** — driver explicitly invites: "@systems, your call
   on Redis vs Memcached here."

## Recording the Driver

Every artifact (breakout, buildout slice, plan section) names its driver
in the frontmatter:

```yaml
driver: @owner [anchor]
supporters: [@critic [lattice], @operator [tide]]
supporters_who_spoke: [@critic]
```

Supporters who never spoke up are still recorded — their silence is
information. (Means the driver's lens covered the territory cleanly.)

## Why This Rule Exists

Round-robin "everyone weighs in" produces three failure modes:

1. **Dilution** — the strongest lens gets averaged with weaker ones.
2. **Theatre** — personas perform their archetype to justify being there,
   adding noise without changing the outcome.
3. **Slow convergence** — the user reads four similar paragraphs and has
   to synthesize the actual recommendation themselves.

One driver per leg fixes all three. The driver commits, the supporters
backstop. If a supporter never had to speak up, that's a *good* leg.

## Interaction Pattern (the visible shape)

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

Pattern: supporters speak once with a tagged trigger, then yield. No
back-and-forth, no commentary, no "good point @owner". The driver keeps
writing.
