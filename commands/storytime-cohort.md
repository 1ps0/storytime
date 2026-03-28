---
description: Manage the Storytime persona roster — hire, fire, bench, promote, evolve
argument-hint: "<action> <persona> [details]"
allowed-tools: [Read, Write, Edit, Glob, Grep]
---

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

### activate / unbench <name>
- Update persona status back to active

### evolve <name> <new-expertise-or-changes>
- Update the persona's background, expertise, or personality
- Log the evolution in their file with date and reason

### promote <specialist-name>
- Move from `specs/.storytime/specialists/` to `specs/.storytime/cohort/`
- Update roster, mark as permanent
- Transfer all accumulated context

## Persona File Format

```markdown
---
name: <name>
archetype: <domain|systems|platform|owner|operator|skeptic>
status: <active|inactive|alumni>
inception: <YYYY-MM-DD>
sessions: [<session-ids>]
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
