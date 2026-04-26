---
type: reference
name: prompt-yield
description: "Prompt-yield documents — when a complex user ask becomes a structured artifact that the cohort hydrates into utility. @user is the originating driver; cohort lenses are supporters. Lifecycle: seeded → hydrating → maturing → crystallized. Load when a user prompt is complex enough to warrant explicit decomposition before session work."
---

# Prompt Yield

Some user prompts are too complex to answer inline and too underspecified
to feed straight into a `/storytime` session. They are *seeds* — they
contain an ask, a vision, a tangle of intent — but they need cohort
support to **hydrate** into something useful.

A **prompt-yield document** is the artifact that captures this hydration
work. Per V1-036 (v1.0.1+).

## When to use

A prompt is a yield candidate when at least one of these is true:

- It contains multiple intents braided together
- It implies decisions the user hasn't named explicitly
- It would benefit from each cohort lens's read before action
- The user wants the team to develop the idea, not just execute it
- It's a "thought" rather than a "task"

A prompt is NOT a yield candidate when:

- It's a clear directive ("ship v1.0", "commit and push")
- It's a verification ("is X up to date?")
- It's a small refinement ("change Y to Z")

The cheapest fast-path stays available. Yield is opt-in for the cases
that earn it.

## Document structure

Filename: `specs/.storytime/yields/<short-slug>.md` or
inside an active session: `sessions/<topic>/yield-<slug>.md`.

```yaml
---
type: prompt-yield
schema_version: 1
created: <YYYY-MM-DDTHH:MM>
originating_user: "@user [codename]"
status: hydrating              # seeded | hydrating | maturing | crystallized
crystallized_into: null        # path to session / breakout / decision when crystallized
parent: null                   # if part of an active session
---

# Yield — <short title>

## Origin (verbatim or lightly edited)

> [The user's original prompt, captured as the seed.]

## Cohort hydration

### @owner [anchor]

(architect's read — what's the structural shape of the ask?)

### @operator [tide]

(operator's read — what mechanics and reliability concerns are implied?)

### @critic [forge]

(architecture critic's read — what's load-bearing? what's questionable?)

### @skeptic [drift]

(skeptic's read — do we actually need this? what's the simpler version?)

### @educator [beacon]

(educator's read — what would a reader need to understand this?)

(other lenses contribute as relevant; some lenses may stay silent if not
useful and non-distortive — driver-per-leg rule applies even here)

## Sub-problems surfaced

- (questions raised during hydration that need resolution before action)
- (gaps the user didn't fill that the team can name)
- (assumptions the team detected and wants to confirm)

## Crystallized form

(only filled when status: crystallized)

The matured ask, restated as a structured artifact ready for action.
This is the *output* of yield. Often becomes:

- A new session topic ("/storytime <topic>")
- A focused breakout ("/storytime-breakout <sub-problem>")
- A direct decision ready to seal as V1-NNN
- A series of sealed decisions

Cross-references:
- yields-into: <path-to-resulting-artifact>
```

## Lifecycle

```
seeded         User has dropped a complex ask. Document exists, only the
               Origin section is filled.
   │
   ▼
hydrating      Cohort lenses are contributing reads. Each persona may add
               a section per their lens. Driver-per-leg still applies —
               only one persona writes at a time, others stay silent
               unless their interjection is useful and non-distortive.
   │
   ▼
maturing       Sub-problems have been surfaced. The original ask is now
               structured: what's clear, what's not, what's contested.
               Decisions about scope can be made.
   │
   ▼
crystallized   The yield has produced something actionable. The original
               complex ask has become a clear next-action: a session, a
               breakout, a decision, or a set of them. The yield document
               links to the crystallized result.
```

The lifecycle is similar to a focused breakout but **inverted**: a
breakout takes one sub-problem and 1 driver + silent supporters; a yield
takes one user-originated ask and N lens contributions.

## Differences from related artifacts

| Artifact | Origin | Driver | Output |
|----------|--------|--------|--------|
| icebreaker | session start | @owner [anchor] | sub-problems for breakouts |
| breakout | sub-problem | one lens | recommendation |
| plan | converge phase | @owner [anchor] | sequenced action |
| **prompt-yield** | **complex user ask** | **@user [codename]** | **crystallized actionable form** |

## How yield connects to user-as-role

Per V1-031, `@user [codename]` is a first-class persona. Prompt-yield is
**the primary place where @user is the document's originating driver**.

When @user appears as `driver:` on a prompt-yield, it's not metaphorical
— the document originated from their actual prompt, captured verbatim or
lightly edited in the Origin section. The cohort hydrates *around* the
user's voice; they don't replace it.

`acquired_context` for `@user` accumulates from yields too — each yield
documents which lenses the user invoked or which sub-problems they
implicitly surfaced.

## Skill invocation (deferred to v1.1)

In v1.0.1, prompt-yield is a **convention**, not a skill. To create one,
the user (or the model) hand-writes the document and proceeds.

In v1.1+, propose `/storytime-yield <ask>`:

- Captures the user prompt as Origin
- Spawns sub-agents per lens (similar to parallel breakouts)
- Each lens contributes their hydration section
- Surfaces sub-problems
- Pauses at maturing → asks user: "crystallize as session / breakout /
  decision / set aside?"

This makes yield a first-class entry point alongside `/storytime` and
`/storytime-breakout`, scoped specifically for the "complex thought
needs team development" case.

## Examples that would benefit from yield

From this repo's history:

- *"heres a thought, lets discuss moving to a more sleep-function-like
  approach..."* — became the v1-consolidation proposal eventually, but
  was first hydrated through conversational back-and-forth. A yield
  document would have captured that hydration explicitly.
- *"now i want to raise and challenge the idea of intent gradient..."*
  — produced the four intent-* proposals in `docs/proposals/`. A yield
  could have been the precursor that sequenced them.
- *"id also say @user can appear as part of a prompt yield..."*
  — meta. This very prompt is a yield seed; this reference doc is its
  crystallization.

## Interaction with intent extraction

Each yield contributes entries to `.storytime/intents.md`:

- The Origin section's distilled intent (one entry, source=prompt-yield)
- Each lens's hydration as a sub-intent (entries, lens=@<role>)
- The crystallized form's resulting intent (entry, type=resolve)

Over time, the yield documents become the most intent-dense artifacts in
storytime — a complex prompt-yield can produce 5-10 intent entries
versus a typical breakout's 1-3.

## Lint

Mechanical (PY class):

| # | Check |
|---|-------|
| PY1 | Frontmatter `type: prompt-yield` present |
| PY2 | `originating_user` is a `@user [codename]` reference |
| PY3 | `status` in {seeded, hydrating, maturing, crystallized} |
| PY4 | If status=crystallized, `crystallized_into` resolves to a real path |

Reasoning (deferred to v1.2+):

| # | Check |
|---|-------|
| PY-R1 | Cohort hydration sections are substantive (not placeholder) |
| PY-R2 | Sub-problems surfaced are specific (not generic) |
| PY-R3 | Crystallized form actually represents the original ask |

## Companion documents

- `references/user-as-role.md` — @user as a first-class persona
- `references/intents-format.md` — where yield-derived intents go
- `references/intent-graph.md` — yields produce nodes that fit the graph
- `references/team-assembly.md` — driver-per-leg applies inside hydration
