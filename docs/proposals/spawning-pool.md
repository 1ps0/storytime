---
type: design-doc
created: 2026-04-03T16:00
---

# The Spawning Pool — Echo Testing and Persona Discovery

How storytime helps you find the right perspectives before committing
to them.

---

## Origin: The Critic That Argued Against Itself

During the development of storytime's default core (OWNER, OPERATOR,
CRITIC), the team proposed elevating CRITIC to a mandatory archetype
alongside OWNER and OPERATOR — a "triumvirate" that would always be
present.

Before committing to this design, we asked: "What would a @critic say
to this?" — without having a critic on the team.

The spawned echo argued against its own promotion:

> "You're about to hardcode a *triumvirate* into a system whose core
> principle is the *variable gearbox*. That's a contradiction."

It proposed defaults instead of mandates (`default_core: [owner, operator,
critic]` instead of `require_triumvirate: true`). It noted that the word
"triumvirate" itself resists change — language that resists change becomes
load-bearing doctrine.

Then it validated its own distinction from SKEPTIC:

> "A SKEPTIC would have asked 'do we need a triumvirate?' A CRITIC asks
> 'is this the right shape for expressing the idea you already have?'
> Those *are* different questions."

The echo changed the design. The critic was then hired — not because it
was mandated, but because it proved its value by arguing against being
mandated.

---

## What the Exercise Revealed

### 1. Echo testing is a design verification tool

Spawning a temporary voice to challenge a proposal before committing to
it is a form of **adversarial review** that doesn't require a full persona
with history and relationships. The echo speaks once, directly, and
dissolves if not needed.

This is cheaper than hiring a persona (no file, no roster entry, no
accumulated context to maintain) but captures the most valuable moment:
the first thing a fresh perspective notices.

### 2. Roles prime reasoning differently than names

When we asked "what would a @critic say?" the model produced criticism
of *shape and structure* — exactly the CRITIC orientation. If we'd asked
"what would a @skeptic say?" we'd have gotten scope challenges. The role
word itself is a **model attention anchor** that primes the reasoning frame
before the response begins.

This confirms the role-first addressing design: `@critic` is a stronger
behavioral signal than `@pike`, because the role word carries semantic
weight that a proper noun doesn't.

### 3. The best personas earn their place

The critic's promotion from "one of seven equal archetypes" to "one of
three default core archetypes" happened because the echo proved the
perspective was indispensable — not because someone decided it was
important in the abstract.

This suggests a principle: **personas should be validated through echo
testing before permanent hire.** The spawning pool is the tryout; the
cohort is the team.

### 4. Self-referential challenge is the strongest signal

The strongest moment was when the critic argued against the proposal
to *require* a critic — and in doing so, demonstrated exactly why a
critic is valuable. A role that can challenge its own necessity is one
that understands its function. A role that can't challenge itself is
just agreeing with the user.

---

## Team Perspectives on the Exercise

**@owner [Reva]:** "The echo changed the architecture. We went from
`require_triumvirate: true` to `default_core: [owner, operator, critic]`.
That's a cleaner abstraction — defaults compose, mandates don't. The
spawning pool is the mechanism that made us discover this before we
shipped the wrong thing."

**@operator [Deshi]:** "I like that echoes don't create files. No persona
file, no roster entry, no cleanup if you decide you don't need it.
The lightest possible test of whether a perspective adds signal. I'd
use this in triage — 'echo @security, does this PR have auth issues?'
One-shot, no ceremony."

**@domain [Oona]:** "The taxonomy question resolved itself. CRITIC and
SKEPTIC are orientations, not watertight categories. CRITIC defaults to
shape-challenge, SKEPTIC defaults to scope-challenge, and in practice
they blur. Over-classifying this would have been a mistake. The echo
showed us the boundary is contextual, which is more honest than a
rigid definition."

**@skeptic [Pike]:** "The best part is that `default_core` is overridable.
A solo dev can set `default_core: []` and skip all of it. The gearbox
stays intact. If we'd gone with `require_triumvirate: true`, I would
have vetoed it. Defaults that collapse are features. Requirements that
don't are cages."

**@platform [Taro]:** "Watch what happened in the conversation: the user
asked for a critic's opinion. The echo changed the design. The user felt
the value and said 'I love that so much. I agree, so hard.' That's the
product moment — the thinking process produced a better outcome than the
original proposal. The document is the receipt. The echo was the meal."

---

## The Spawning Pool as a Concept

The spawning pool is the space where potential voices surface briefly
so you can listen before you commit. It answers:

- "Do we need this perspective?" → echo test it
- "Would a security expert change this plan?" → hear the echo
- "What would someone who's been burned by this say?" → spawn from description

### Properties

1. **Ephemeral** — echoes don't persist. No file, no state, no cleanup.
2. **One-shot** — an echo speaks once, directly. No back-and-forth.
3. **Role-addressed** — `echo @critic`, `echo @domain:security`, or
   a description: `echo "someone who's built payment systems"`.
4. **Decision-adjacent** — echo testing happens when you're about to
   commit to something (a design, a hire, a process change) and want
   to hear a challenge first.
5. **Composable** — multiple echoes in sequence. Listen to several
   perspectives, hire the ones that added signal.

### When to Use

- Before hiring a persona — "will this role add something?"
- Before committing a design decision — "what would @critic say?"
- During ASSEMBLE — "echo the archetypes we're not recruiting to see
  if we're missing something"
- During REVIEW — "echo @skeptic on this plan before we finalize"

### When Not to Use

- When you already know you need the perspective — just hire
- When you need back-and-forth — echoes speak once, QA is for dialogue
- When the echo would need project history to be useful — echoes don't
  load persona files or decision context

---

## Open Questions

1. **Should echoes load any context?** Currently: no. They speak from
   the role description alone. But an echo that can read the current
   plan.md would give more targeted feedback. Trade-off: more context
   = more useful, but also more expensive and less "fresh perspective."

2. **Can echoes reference each other?** If you spawn `echo @critic` and
   then `echo @skeptic`, should the skeptic be aware of what the critic
   said? Currently: no, each is independent. But a "panel echo" where
   multiple voices respond to each other in a single round could be
   valuable.

3. **Should echo quality feed back into persona design?** If an echo
   gives a great response, should its "voice" be captured somehow
   when the user hires based on it? "Hire that critic — with exactly
   that level of directness."
