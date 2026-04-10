---
type: reference
name: output-modes
description: "Storytime-native, adapt-in-place, and export-only output modes. Full directory tree, convention mapping for existing repos, component interop for exports. Load during bootstrap, cold start, or when deciding where artifacts go."
---

# Output Modes

Output paths depend on the bootstrap mode chosen. Three modes, in
order of default preference for a fresh repo: native → adapt → export.

## Storytime-Native (Full Structure)

When `specs/.storytime/` exists or the user agrees to create it.

```
specs/.storytime/
├── cohort/                          — permanent personas
├── specialists/                     — temporary personas
├── sessions/<topic>/                — per-topic thread
│   ├── _thread.md                   — episode bookmark (created at DONE)
│   ├── <NNN>/                       — episode directory (zero-padded)
│   │   ├── preamble.md              (warm start only — synthesized narrative)
│   │   ├── survey.md                (cold start — full survey + fingerprint)
│   │   ├── survey-delta.md          (warm start — incremental survey)
│   │   ├── team.md                  (cold start or team changes)
│   │   ├── icebreaker.md
│   │   ├── breakout-<subtopic>.md
│   │   ├── plan.md
│   │   └── buildout-<slice>.md      (implementation trace — decisions to code)
├── archive/
│   ├── _index.md                    — browsable TOC
│   ├── current/                     — warm tier
│   ├── rollups/                     — compressed history
│   └── cold/                        — deep history (glacier)
├── history/
│   ├── decisions.md                 — append-only decision log
│   └── sessions/                    — per-session summaries
└── config.md                        — project settings
```

## Adapt-in-Place (Work Within Existing Conventions)

Repo has existing doc structure. Write output into the conventions
already present. Don't force a migration.

| Output       | Existing convention examples                  |
|--------------|-----------------------------------------------|
| survey.md    | `docs/`, `specs/`, repo root                  |
| team.md      | `team/`, `docs/`, `.storytime/cohort/`        |
| icebreaker   | `team/`, `specs/<topic>/`, `docs/`            |
| breakouts    | `specs/<topic>/`, `docs/<topic>/`             |
| plan.md      | `docs/`, `specs/`, `ROADMAP.md`, repo root    |

**Mirror the repo's existing style:**
- UPPERCASE.md vs lowercase.md — follow what's already there
- Flat vs nested — don't restructure on arrival
- Naming conventions — match what the humans use

Don't impose storytime conventions on a repo that has its own. The
storytime structure is the main highway; other repos' conventions are
side streets we take when visiting.

## Export-Only (One-Shot Output)

Produce a **unified plan document** that another system can execute.
No persistent storytime state — no cohort, no archive, no history.
Output is one or more files the user specifies:

- A single `plan.md` with everything inline
- A set of files matching another tool's expected format
- A structured document another agent or CI system can parse

The user tells storytime where to write and in what shape. Storytime
produces the content; the user or another system owns the lifecycle.

**When export-only fits:**
- One-off consulting engagements on someone else's repo
- Generating specs for a different team's workflow
- Producing artifacts for a tool that already has its own persistence
  (Kiro, Linear, Jira, Notion)
- Repos where adding `.storytime/` would be unwelcome

## Component Interop

Storytime components are swappable. If another system handles part of
the workflow better, storytime can defer to it or export into it:

- **Personas** → another system's agent definitions or role specs
- **Plans** → Kiro specs, ADRs, GitHub issues, Linear tickets
- **Decisions** → ADR format, decision log in another tool
- **Archive** → existing doc management, wiki, Notion

When exporting, match the target system's format and conventions.
When importing, absorb into storytime's model during artifact scan.
**The gearbox goes both ways.**

## Mode Detection Logic

At bootstrap or cold start:

1. Does `specs/.storytime/` exist? → **native**
2. Does the repo have its own doc structure (`team/`, `docs/`, `specs/`,
   ADRs)? → **adapt**
3. Is this a fresh repo with nothing? → propose **native**, ask user
4. Is the user asking for a one-shot output? → **export**

**Default:**
- Fresh repo → native
- Existing structure → adapt
- Explicit one-shot → export

Never create `.storytime/` without the user's knowledge.
