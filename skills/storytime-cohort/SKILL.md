---
name: storytime-cohort
description: "This skill should be used when the user asks to \"fire\", \"hire\", \"bench\", \"promote\", \"evolve\", \"list the team\", \"show roster\", \"add a specialist\", \"manage the cohort\", or any persona lifecycle management. Manages the permanent Storytime cohort and temporary specialists."
argument-hint: "<action> <persona> [details]"
allowed-tools: [Read, Write, Edit, Glob, Grep]
---

<!-- version-echo: display "storytime v0.9.0" at start of execution -->
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

### hire / recruit <codename> <archetype> <background>
- Create a new persona file: `specs/.storytime/cohort/<codename>-<archetype>-<specialty>.md`
  - Example: `lattice-domain-dsp.md`, `tide-platform-asr.md`
- **Codenames are non-human by default.** Use abstract concept words —
  natural-world (`tide`, `kestrel`, `ember`), structural (`lattice`,
  `anchor`, `forge`), instruments (`compass`, `pulse`, `arbor`), or simple
  identifiers (`alpha`, `n1`). Personas are lenses, not people.
  See "Naming" in `${CLAUDE_PLUGIN_ROOT}/skills/storytime/SKILL.md`.
- The user can override and pick a human name if they want — it's a
  default, not a mandate. Unprompted hires generate codenames.
- Add to the roster with status: active, include the filename
- Include: codename, archetype, background, role, personality

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
temporary voice to hear how a perspective sounds on the current problem.

Echo is now its own skill: **`/storytime:storytime-echo`**. Invoke it
directly for one-shot voices without going through cohort management.
See `${CLAUDE_PLUGIN_ROOT}/skills/storytime-echo/SKILL.md` for full
invocation forms (`@role`, `@role:scope`, descriptive, `:session` context).

Workflow integration:
- `/storytime:storytime-echo @critic` — hear the voice
- Decide if the perspective adds something the team is missing
- If yes → `/storytime:storytime-cohort hire` to formalize based on what you heard
- If no → the echo dissolves, nothing persisted

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

# <Codename> — <Title>

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

## Cohort Sizing

The permanent cohort should be **sized to the project**, not to a
template. A small focused repo may need only 2-3 personas; a multi-
subsystem platform may justify 8-10. Bias small — recruit specialists
on demand for individual breakouts rather than carrying unused lenses
in the cohort. Hard ceiling 12 (override required). See "Team size" in
the main SKILL.

## Roster Format

```markdown
# Storytime Cohort Roster

| Codename | File                       | Archetype | Status | Since      | Sessions | Last Active |
|----------|----------------------------|-----------|--------|------------|----------|-------------|
| anchor   | anchor-owner-architect.md  | owner     | active | 2026-03-24 | 1        | 2026-03-24  |
```
