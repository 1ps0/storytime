---
name: storytime-qa
description: "This skill should be used for **explicit formal queries** to the Storytime team about past decisions, prior session history, or cohort consultation — \"ask the team\", \"check with the team\", \"what did we decide about\", \"team, what's your read on\", \"@team what about\". Also triggers when a user asks a persona a question that requires loading their accumulated context and grounding the answer in session history — e.g., \"@operator, given our prior decisions about kill switches, is this safe?\". **Do NOT trigger this skill for casual `@role` lens directives** — `@critic look at this function`, `@skeptic worth it?`, `@owner your take?` should be answered inline by the current model applying the role's perspective, without launching the formal QA workflow. Use QA only when the query needs persona context loading, decision log lookup, or multi-persona team response."
argument-hint: "@persona <question> or @role <question> or <question for full team>"
allowed-tools: [Read, Glob, Grep, Agent, WebSearch, WebFetch]
---

<!-- version-echo: display "storytime v1.0.0" at start of execution -->
# Storytime QA — Persona Query

Route a **formal query** to a Storytime persona, role, or the full team.
This is the "load context, ground in history, respond" workflow — use
when the answer needs the persona's accumulated context from prior
sessions and decisions.

**Not every `@role` invocation needs this skill.** `@role` is primarily
a **lens directive** — the model can apply a persona's perspective to
whatever follows without launching QA. Launch QA only when:

- The user is asking about **past decisions** or **prior session state**
- The user wants the **full team** to weigh in (`@team` explicitly)
- The response needs the persona's accumulated context from the cohort
- The user invokes the skill by name or with an unambiguous query form
  ("ask the team", "check with the team", "what did we decide")

For casual lens directives — `@critic does this duplication bother you?`,
`@owner your take on this approach?`, `@skeptic worth building?` — the
current model should respond inline by applying the role's perspective.
No files loaded, no skill dispatch, no ceremony.

## Arguments

The user's question: $ARGUMENTS

## Addressing

Roles are the functional anchor. Names are ornaments that resolve to roles.

**By role** (preferred — strongest model attention anchor):
  `@operator is this safe to deploy?`
  `@skeptic do we need this?`
  `@critic:architecture is this the right boundary?`
  Finds the persona(s) with that archetype. If multiple share the archetype,
  qualify with focus: `@critic:architecture` vs `@critic:performance`.
  If unqualified and multiple match, all respond.

**By name** (shorthand — resolves to role via roster):
  `@reva what do you think?` → resolves to `@owner`
  `@pike do we need this?` → resolves to `@skeptic`
  Loads their accumulated context and decisions.

**By team:** `@team what did we decide about caching?` / "ask the team"
All active cohort personas respond from their perspectives.

**Implicit:** If the user's message mentions a persona name or role without @,
and the context makes it clear they're asking that persona, route to them.
"What would the operator think about this?" → routes to @operator.

## Process

1. **Identify the target**:
   - Parse `@name` → exact persona match in cohort
   - Parse `@role` → match against archetypes (owner, operator, critic, domain, systems, platform, skeptic, educator)
   - Parse `@role:explain` → the named role responds in explain-mode (teaching, not deciding)
   - Parse `@team` → all active personas
   - No match in cohort → suggest assembling a team first
2. **Load persona context**:
   - Read the persona file from `specs/.storytime/cohort/<name>*.md`
   - Read their `decisions_participated` entries
   - Read relevant prior session artifacts they contributed to
3. **Load relevant history**:
   - Check `specs/.storytime/history/decisions.md` for related decisions
   - Read the session artifacts referenced in the persona's file
4. **Respond from the persona's lens**:
   - Answer drawing on the persona's expertise and accumulated context
   - Ground claims: code citations (`file:line`), doc citations, web if needed
   - Reference prior decisions by ID (e.g., "per RATE-001, we chose...")
   - If the question requires checking current code, use Grep/Read
   - If it requires external knowledge, use WebSearch/WebFetch
5. **If the question is complex**:
   - Suggest a `/storytime-breakout` for a focused investigation
   - Or suggest a full `/storytime` session if the question is broad enough
6. **If the answer changes a prior decision**:
   - Flag it: "This would supersede RATE-002. Want to update the decision log?"
   - Only update with explicit user approval

## Output

Response is inline — no files written unless the user approves a decision
update. The conversation stays lightweight. This is the "tap a colleague
on the shoulder" interaction, not a formal session.
