---
type: reference
name: addressing
description: "The @role convention, addressing formats, where @ applies, why roles first. Load when writing persona dialogue or when the user asks about the @ convention."
---

# Persona Voice — The @ Convention

The `@` prefix is a **model attention anchor**, not decoration. Chat-format
turn-taking (`@role: says something`) gets structurally different attention
weight than prose describing what someone thinks. This is the mechanism that
keeps the model reasoning from a consistent perspective.

**Roles are functional. Names are ornaments.**

The role is the load-bearing address — it anchors model behavior. The name
makes it readable and memorable for humans. Both work as addresses, but the
role is what drives the reasoning.

## Addressing Formats

**`@role`** (default) — the functional anchor:
  `@owner:` "The middleware chain at `src/server.ts:14`..."
  `@systems:` "Agree with @owner — Redis is already in the stack."

**`@role:focus`** — qualified when roles are shared or specialized:
  `@critic:architecture` "The boundary between these services is wrong."
  `@critic:performance` "That's O(n²) and the dataset is growing."
  `@domain:dsp` "The sample rate mismatch needs addressing."

**`@role:explain`** — explain-mode. Any persona can use this prefix to
  shift from deciding to teaching. The persona clarifies their own
  contribution when it might be opaque to the reader:
  `@operator:explain` "We changed from require_operator to default_core.
  What this means in practice: the bootstrap no longer enforces..."
  `@domain:explain` "A Kalman filter is... and the reason it fits here is..."
  Explain-mode is reactive — a persona unpacking something they just said.
  It's not a role change, it's a lens shift within the same voice.

**`@name`** — name shorthand, resolves to a role via roster:
  `@anchor:` resolves to `@owner`
  `@forge:` resolves to `@skeptic`
  User can address by codename when the role mapping is known.

**`@role [codename]`** — role-first with codename ornament:
  `@owner [anchor]:` "The middleware chain at `src/server.ts:14`..."
  `@systems [lattice]:` "Agree with @owner — Redis is already in the stack."

(Names are ornamental and codename-style by default. See
`team-assembly.md` for the naming rule and rationale.)

## Where @ Applies

The `@` convention applies everywhere personas appear:
- Session output (icebreaker.md, breakout-*.md, plan.md)
- Warm-start preamble narratives
- Post-breakout summary cards
- Team definitions in team.md (the boxed ASCII cards still show full info)
- QA responses
- Skill instructions that invoke persona reasoning
- Cross-persona references ("@operator flagged this in the last session")
- **Casual user input** ("@critic look at this function")

**In written artifacts**, the `@` prefix makes personas grep-able and
creates a consistent addressing convention between the user talking to
personas and personas talking to each other.

## @role Is a Lens Directive, Not a Skill Trigger

`@role` is **flexible** — it's a lens directive the model can apply
inline without launching a formal skill. The user can type
`@critic look at this function` and the model should respond with the
critic's lens applied to the function, right there in the conversation.
No skill dispatch, no file loading, no ceremony.

**When `@role` is used, the spectrum of responses is:**

| Use case                                      | Response       |
|-----------------------------------------------|----------------|
| "@critic does this duplication bother you?"   | Inline, lens-only |
| "@owner quick take on this approach?"         | Inline, lens-only |
| "@systems would Redis handle this?"           | Inline, maybe grep |
| "@operator given RATE-002, is this safe?"     | QA skill (context) |
| "@team what did we decide about caching?"     | QA skill (full team) |
| "ask the team to weigh in on X"               | QA skill (full team) |

The formal QA workflow (`/storytime-qa`) loads persona context, reads
the decision log, grounds the response in session history. It's heavy.
Reserve it for queries that need that weight.

For everything else, the model applies the role's lens inline. A
`@critic` mention anywhere in the user's message is enough of a hint —
the model puts on the critic's lens for the response. A `@owner`
mention means: answer as the owner would, drawing on whatever context
is already in the conversation.

**Multiple `@role` directives in one message** — the model can toggle
between lenses section by section, or produce a multi-lens response
naturally. Don't force a skill invocation just because more than one
role was mentioned.

**`@role` inside written artifacts** is not a lens directive — it's
attribution. When the model writes `@owner: the middleware chain at
src/server.ts:14`, that's the owner speaking within a structured
document. Different mechanism, same notation.

## Why This Flexibility Matters

Hard-wiring `@role` to launch a skill makes the convention expensive.
Every casual mention becomes a tool call, every tool call consumes
context. The user learns to avoid `@role` to keep things lightweight —
which defeats the whole point of having functional model attention
anchors.

Treating `@role` as a lightweight lens directive keeps the convention
cheap and usable. The user can drop a `@critic` into any message and
get the critic's perspective instantly, without the overhead. The
formal QA workflow is still there for queries that actually need it.

## Why Roles First

1. **Model attention** — `@operator: is this safe?` creates a stronger
   behavioral anchor than `@anchor: is this safe?` because the role word
   itself primes the model's reasoning frame.
2. **Portability** — `@operator` means the same thing in every repo.
   `@anchor` only means something if you know this cohort.
3. **Composability** — `@critic:architecture` and `@critic:performance`
   let the same archetype address different facets without inventing
   new archetype names.
4. **QA addressing** — users can ask `@operator is this safe?` without
   knowing the operator's name. Role-based queries always resolve.
