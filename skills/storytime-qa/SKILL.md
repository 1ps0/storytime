---
name: storytime-qa
description: "This skill should be used when the user addresses a Storytime persona or role using @ syntax — e.g., \"@kim what about...\", \"@operator is this safe?\", \"@skeptic do we need this?\", \"@team what did we decide about...\". Also triggers on \"ask the team\", \"check with the team\", \"what did we decide about\", or any query about past Storytime decisions. Works in any conversation where a storytime cohort exists — no active session required."
argument-hint: "@persona <question> or @role <question> or <question for full team>"
allowed-tools: [Read, Glob, Grep, Agent, WebSearch, WebFetch]
---

<!-- version-echo: display "storytime v0.3.0" at start of execution -->
# Storytime QA — Persona Query

Route a direct question to a Storytime persona, role, or the full team.
Works in any conversation — no active storytime session required. Just
`@name` or `@role` and ask.

## Arguments

The user's question: $ARGUMENTS

## Addressing

**By name:** `@noa what do you think about the middleware approach?`
Routes to the named persona. Loads their accumulated context and decisions.

**By role/archetype:** `@operator is this safe to deploy?` / `@skeptic do we need this?`
Finds the persona with that archetype in the active cohort and routes to them.
If multiple personas share the archetype, all respond.

**By team:** `@team what did we decide about caching?` / "ask the team"
All active cohort personas respond from their perspectives.

**Implicit:** If the user's message mentions a persona name without @,
and the context makes it clear they're asking that persona, route to them.
"What would noa think about this?" → routes to Noa.

## Process

1. **Identify the target**:
   - Parse `@name` → exact persona match in cohort
   - Parse `@role` → match against archetypes (operator, skeptic, owner, domain, systems, platform)
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
