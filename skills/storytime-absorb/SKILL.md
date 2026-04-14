---
name: storytime-absorb
description: "This skill should be used when the user asks to \"absorb this\", \"digest these docs\", \"have the team review\", \"interpret the history\", \"build context from\", \"understand this codebase\", or wants the team to read, interpret, and build shared understanding from existing documents or code. Team reads and discusses — consolidate moves files."
argument-hint: "<documents, directories, or topic to absorb>"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch]
---

<!-- version-echo: display "storytime v1.0.0" at start of execution -->
# Storytime Absorb — Team Interpretation

Have the storytime team read, interpret, and build shared understanding
from existing documents, code, or prior work. This is the thinking skill —
consolidate moves files, absorb builds understanding.

## Arguments

What to absorb: $ARGUMENTS

## Process

### 1. Load the Team

Load the permanent cohort from `specs/.storytime/cohort/_roster.md` if it
exists. If no cohort exists, recruit a temporary team appropriate for the
material being absorbed (follow the archetype checklist from the main
storytime skill).

### 2. Gather Material

Read the specified documents, directories, or code. If the user pointed
at a broad area ("absorb the team/ directory"), read everything in it.
If they pointed at specific files, read those.

For code absorption, launch an Explore agent for deeper understanding.

### 3. Team Discussion

The team reads and interprets the material. Each persona comments from
their vantage point:
- What does this tell us?
- What's still current vs outdated?
- What decisions were made and are they still valid?
- What's missing — what should have been documented but wasn't?
- What contradicts other things we know?

This is a structured discussion, not a summary. Personas should disagree
where their expertise leads them to different conclusions.

### 4. Produce Artifacts

Based on the discussion, write:

**If the material contains decisions:**
- Extract and log them in `specs/.storytime/history/decisions.md`
- Each with ID, rationale, date, and which persona identified it

**If the material reveals team knowledge:**
- Update persona files in `specs/.storytime/cohort/` with acquired context
- New expertise, new relationships, new domain knowledge

**If the material is a body of prior work:**
- Write an absorption summary: `specs/.storytime/sessions/<topic>/absorption.md`
- Timeline of what happened, team interpretation, open questions
- Coverage fingerprint of what was read

**If the material should be archived:**
- Suggest running `/storytime:consolidate` for the file operations
- Absorb builds understanding; consolidate handles the filing

### 5. Present to User

Share the team's interpretation. The user can:
- Challenge any interpretation (team responds with rationale)
- Ask follow-up questions ("@kim what about the auth decisions?")
- Direct further absorption ("now absorb the docs/ directory too")
- Accept and move on

## Difference from Consolidate

| | Absorb | Consolidate |
|---|--------|-------------|
| **Does** | Reads, interprets, builds understanding | Moves, archives, rolls up files |
| **Output** | Decisions, context, team knowledge | File operations, archive index |
| **Team** | Required — this is a team activity | Not required — this is file ops |
| **When** | "Help me understand what we have" | "Help me organize what we have" |

They pair well: absorb first to understand, consolidate after to organize.
