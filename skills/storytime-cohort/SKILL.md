---
name: storytime-cohort
description: "This skill should be used when the user asks to \"fire\", \"hire\", \"bench\", \"promote\", \"evolve\", \"list the team\", \"show roster\", \"add a specialist\", \"manage the cohort\", or any persona lifecycle management. Manages the permanent Storytime cohort and temporary specialists."
argument-hint: "<action> <persona> [details]"
allowed-tools: [Read, Write, Edit, Glob, Grep]
---

<!-- version-echo: display "storytime v0.6.0" at start of execution -->
# Storytime Cohort Management

Manage the Storytime persona roster — hiring, firing, benching,
promoting, and evolving personas across sessions.

## Arguments

The management action: $ARGUMENTS

## Actions

### list / roster / show
- Read `specs/.storytime/cohort/_roster.md`
- Display all active, inactive, and specialist personas
- Show each persona's session count and last active date

### hire / recruit <name> <archetype> <background>
- Create a new persona file: `specs/.storytime/cohort/<name>-<archetype>-<specialty>.md`
  - Example: `raj-domain-dsp.md`, `mira-platform-asr.md`
- Add to the roster with status: active, include the filename
- Include: name, archetype, background, role, personality

### fire / release <name>
- Move persona file to `specs/.storytime/cohort/_alumni/`
- Update roster: status → alumni, with reason and date
- Preserve all decision history (decisions are never deleted)

### bench / deactivate <name>
- Update persona status to inactive in roster
- Persona retains all context, just excluded from new sessions
- Still @mentionable in QA mode

### activate / unbenCH <name>
- Update persona status back to active

### evolve <name> <new-expertise-or-changes>
- Update the persona's background, expertise, or personality
- Log the evolution in their file with date and reason

### promote <specialist-name>
- Move from `specs/.storytime/specialists/` to `specs/.storytime/cohort/`
- Update roster, mark as permanent
- Transfer all accumulated context

### echo <role or description>
**Spawning pool echo test.** Before committing to a hire, spawn a
temporary voice from the pool to hear how a perspective *sounds* on
the current problem. No persona file created — this is a tryout, not
a commitment.

Process:
1. User says: `echo @critic` or `echo "someone who's built payment systems"`
2. Generate a one-shot response from that perspective on the current
   context — recent session topic, latest decisions, active problem
3. The echo speaks once, directly. No name, no backstory, just the lens.
4. User evaluates: does this perspective add something the team is missing?
5. If yes → `hire` with the role and let the user give it a name and shape
6. If no → the echo dissolves. Nothing written, nothing persisted.

Echo testing helps answer "do we need this perspective?" before investing
in a full persona with history and relationships. It's the spawning pool —
a place where potential voices surface briefly so you can listen before
you commit.

Multiple echoes can run in sequence: `echo @skeptic`, `echo @domain:security`,
`echo "someone who's been burned by this exact pattern"`. Each speaks once.
The user picks who to hire from what they heard.

## Persona File Format

```markdown
---
type: persona
created: <YYYY-MM-DDTHH:MM>
name: <name>
archetype: <domain|systems|platform|owner|operator|skeptic|critic|educator>
focus: <specific sub-focus, if sharing archetype with another persona>
status: <active|inactive|alumni>
inception: <YYYY-MM-DD>
last_active: <YYYY-MM-DD>
sessions: [<session-ids>]
evolved:
  - date: <YYYY-MM-DD>
    change: "<what changed>"
    session: <session-id>
expertise_acquired:
  - "<expertise>"
decisions_participated:
  - id: <TOPIC-NNN>
    decision: "<summary>"
    role: "<their role in the decision>"
    date: <YYYY-MM-DD>
---

# <Name> — <Title>

## Background
<2-3 sentences>

## Role
<What they own>

## Personality
<How they push back, what they care about>

## Acquired Context
<Updated after each session>

## Relationships
<How they work with other team members>
```

## Roster Format

```markdown
# Storytime Cohort Roster

| Name | File                     | Archetype | Status | Since      | Sessions | Last Active |
|------|--------------------------|-----------|--------|------------|----------|-------------|
| Kim  | kim-owner-architect.md   | owner     | active | 2026-03-24 | 1        | 2026-03-24  |
```
