---
name: storytime-echo
description: "This skill should be used when the user asks to \"echo\", \"spawn a voice\", \"hear from\", \"what would X say\", \"spawning pool\", \"try out a perspective\", or wants a one-shot response from a role/persona/description without hiring them. Ephemeral — no files written, no state persisted. The spawning pool for listening before committing."
argument-hint: "<@role | @role:scope | \"description\"> [— optional question or topic]"
allowed-tools: [Read, Glob, Grep]
---

<!-- version-echo: display "storytime v0.6.0" at start of execution -->
# Storytime Echo — Spawning Pool Voice

Spawn a temporary voice from the spawning pool. One-shot. Ephemeral.
No files, no state. The echo speaks once and dissolves.

## Arguments

The echo target: $ARGUMENTS

## The Spawning Pool Concept

The spawning pool is the space where potential voices surface briefly
so you can listen before you commit. Echoes answer questions like:

- "What would a critic say to this design?"
- "What would someone who's been burned by this pattern say?"
- "What does the creator of this project notice when they step back?"
- "Would a security expert change this plan?"

Echoes are not personas. They have no history, no persona file, no
roster entry. They are voices that appear, speak, and dissolve. If
an echo says something useful, you can then `hire` a persona shaped
by what you heard. The echo is the tryout; the cohort is the team.

## Invocation Forms

### By role
```
/storytime:storytime-echo @critic
/storytime:storytime-echo @operator
/storytime:storytime-echo @skeptic do we need this?
```
The role is the functional anchor. The echo speaks from the archetype's
default orientation without a specific personality.

### By role with scope
```
/storytime:storytime-echo @critic:architecture
/storytime:storytime-echo @domain:security
/storytime:storytime-echo @critic:performance is this O(n²)?
```
Qualified roles for shared archetypes or narrow specializations.

### By description
```
/storytime:storytime-echo "someone who's built payment systems at scale"
/storytime:storytime-echo "a game designer turned devtools person"
/storytime:storytime-echo "the creator of this project, stepping back"
```
Descriptive voices for perspectives that don't map cleanly to archetypes.

### With explicit context scope
```
/storytime:storytime-echo @critic :session
/storytime:storytime-echo @creator :session what should I do next?
```
The `:session` suffix means "load current session context" — the echo
can reference recent decisions, the active topic, specific files in play.
Without `:session`, the echo is generic — it speaks from the role/description
alone, with no conversation-specific knowledge.

**Default context scope is `:session`** when invoked inside an active
conversation where storytime state is visible. Outside that, echoes are
role-only.

## Process

### 1. Parse the target

- `@role` or `@role:scope` → resolve to archetype + optional focus
- `"description"` → use the description as the voice definition
- Trailing `:session` → load session context
- Trailing text → treat as the question/topic the echo should address

### 2. Load context (if `:session` specified)

If context scope includes session:
- Read the current session's thread state (if active storytime session)
- Read recent breakouts, plans, decisions from the active topic
- Read the cohort roster (to know what perspectives already exist)
- Read recent conversation turns for the current problem being discussed

If no session is active, or context is role-only, skip this step.

### 3. Generate the echo

Produce a one-shot response from the target voice:
- **If a role**: speak from that archetype's default orientation
- **If a description**: speak from that described perspective
- **In `:session` mode**: reference specifics from the loaded context
- **In role-only mode**: speak generically about the topic

The echo should:
- Speak in first person with the `@target:` prefix
- Be honest, not performative — if the echo would push back, it pushes back
- Not pretend to know more than it was given (role-only echoes don't
  know about specific files, decisions, or personas in the session)
- End with something actionable or a question, not a summary

### 4. No files written

The echo is output-only. Nothing persists. No files created, no
decisions logged, no personas added. If the user wants the echo's
reasoning preserved, they can explicitly save it or invoke
`/storytime:storytime-cohort hire` based on what they heard.

## Multiple Echoes

Echoes can be chained:

```
/storytime:storytime-echo @critic
/storytime:storytime-echo @skeptic
/storytime:storytime-echo "a former Redis maintainer"
```

Each is independent. An echo does not know what previous echoes said.
The user is the integrator — they listen to multiple voices and decide
which perspectives are worth hiring.

For echoes that should reference each other (a panel discussion),
consider running a real ICEBREAKER with temporary specialists instead.
The spawning pool is for listening, not for structured debate.

## When to Echo vs Hire

**Echo when:**
- You're not sure a perspective would add value
- You want to hear one take without investing in a persona
- You're designing the team and testing archetype combinations
- You want a fresh voice that isn't shaped by prior session history
- You need a sanity check from outside the existing cohort

**Hire when:**
- You know the perspective is needed for ongoing sessions
- You want the voice to accumulate context across episodes
- The role will participate in breakouts and decisions
- You need QA addressing (`@name`) to work across sessions

## Rules

1. Echoes are ephemeral. Nothing persists unless the user explicitly
   acts on what they heard.
2. Echoes cannot hire themselves. Promotion from echo to persona
   requires explicit user invocation of `/storytime:storytime-cohort hire`.
3. Role-only echoes don't fake specific knowledge. If asked about a
   specific file or decision, they answer from the archetype's orientation
   generically, not from loaded context they don't have.
4. Session echoes acknowledge their context scope. When the echo draws
   on session state, it should be clear the voice has read the thread —
   that's the whole point of `:session` mode.
5. Descriptive echoes ("someone who's built X") invent a plausible voice
   but should not claim specific biography as if it were real. The voice
   is a lens, not a fabricated person.

## See Also

- `${CLAUDE_PLUGIN_ROOT}/docs/proposals/spawning-pool.md` — the concept
  and origin of spawning pool echoes
- `${CLAUDE_PLUGIN_ROOT}/skills/storytime-cohort/SKILL.md` — persona
  lifecycle (hire, fire, bench, promote, evolve)
