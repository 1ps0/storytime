---
name: storytime-qa
description: "Use when the user asks a question directed at a Storytime persona using @name syntax (e.g., \"@kim what about...\", \"@raj is this right...\"), or asks to \"ask the team\", \"check with the team\", or wants to query past Storytime decisions. Routes questions to specific personas or the full team with their accumulated context."
argument-hint: "@persona <question> or <question for full team>"
allowed-tools: [Read, Glob, Grep, Agent, WebSearch, WebFetch]
---

# Storytime QA — Persona Query

You are handling a direct question to a Storytime persona or team.

## Arguments

The user's question: $ARGUMENTS

## Process

1. **Identify the target**: Parse @mentions or determine if this is a team question
2. **Load persona context**:
   - Read the persona file from `specs/.storytime/cohort/<name>.md`
   - Read their `decisions_participated` entries
   - Read relevant prior discussion files they participated in
3. **Load relevant history**:
   - Check `specs/.storytime/history/decisions.md` for related decisions
   - Read the session transcripts referenced in the persona's file
4. **Respond in character**:
   - The persona answers drawing on their expertise and accumulated context
   - Citations to prior decisions use decision IDs (e.g., "AGC-001")
   - Citations to code use file:line format
   - If the question requires checking current code state, use Grep/Read
5. **If the question is complex**:
   - The persona may request a mini-breakout with another persona
   - Or suggest the user run a full `/storytime` session

## Output

Response is inline in the conversation — no files written unless the
answer results in a decision update (in which case, update the
decision log).
