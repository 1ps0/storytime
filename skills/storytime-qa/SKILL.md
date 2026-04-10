---
name: storytime-qa
description: "This skill should be used when the user addresses a Storytime persona or role using @ syntax — e.g., \"@kim what about...\", \"@operator is this safe?\", \"@skeptic do we need this?\", \"@team what did we decide about...\". Also triggers on \"ask the team\", \"check with the team\", \"what did we decide about\", or any query about past Storytime decisions. Works in any conversation where a storytime cohort exists — no active session required."
argument-hint: "@persona <question> or @role <question> or <question for full team>"
allowed-tools: [Read, Glob, Grep, Agent, WebSearch, WebFetch]
---

<!-- version-echo: display "storytime v0.7.2" at start of execution -->
# Storytime QA — Persona Query

Route a direct question to a Storytime persona, role, or the full team.
Works in any conversation — no active storytime session required. Just
`@name` or `@role` and ask.

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
