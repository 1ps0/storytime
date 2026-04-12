---
type: reference
name: import-adapters
description: "How to interpret non-storytime artifacts encountered during survey. Maps foreign document formats to storytime's internal model. Load during SURVEY artifact scan when non-storytime docs are found."
---

# Import Adapters

When SURVEY encounters artifacts that aren't storytime-native, map them
to the internal model using these adapters. Each adapter answers: what
is this, what do we keep, and where does it go?

## ADR (Architecture Decision Record)

**Detect:** filename `adr-*`, `ADR-*`, or `docs/decisions/`
**Maps to:** spec-like (may fold into decision log)
**Extract:** decision ID, status (accepted/superseded), date, context,
decision, consequences
**Where:** reference in `history/decisions.md` or archive as-is

## Kiro Spec (`.kiro/specs/`)

**Detect:** `.kiro/` directory, `*.md` with `requirement:` in body
**Maps to:** spec-like (structured requirements)
**Extract:** requirements, tasks, acceptance criteria
**Where:** fold into icebreaker context or breakout input

## RFC / Design Doc

**Detect:** `rfc-*`, `design-*`, `proposals/`
**Maps to:** spec-like
**Extract:** problem statement, proposed solution, alternatives, status
**Where:** feed to icebreaker as prior art

## Agent / Persona Definition

**Detect:** `*-agent.md`, `*-persona.md`, `agents/`, `team/`
**Maps to:** team-like (rehire candidate)
**Extract:** name/role, expertise, background
**Where:** present as rehire candidate in ASSEMBLE

## CLAUDE.md / Cursor Rules

**Detect:** `CLAUDE.md`, `.cursorrules`, `.claude/`
**Maps to:** config-like (load silently)
**Extract:** project conventions, constraints, preferences
**Where:** load into session context, don't move

## Linear / GitHub Issues Export

**Detect:** `*.csv` or `*.json` with issue-shaped data
**Maps to:** spec-like (backlog context)
**Extract:** titles, labels, status, assignees
**Where:** present in SURVEY inventory for team review

## Unknown Format

If none of the above match and the artifact looks relevant (not noise):
1. Present to the user: "Found `<path>` — I can't classify it. Want the
   team to review it during icebreaker?"
2. Don't guess. Don't skip silently. Let the user or team decide.

## Adapter Rules

1. **Never modify** the source artifact. Read only.
2. **Don't convert formats** — just extract what storytime needs.
3. **Preserve the original path** in the storytime reference.
4. **Flag confidence** — if the classification is uncertain, say so.
5. **Non-storytime artifacts without schema_version** are always v0.
