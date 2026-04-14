---
name: storytime-status
description: "This skill should be used when the user asks \"storytime status\", \"where are we\", \"show the team\", \"what sessions exist\", \"what's in the archive\", \"how's storytime set up\", or wants a dashboard view of storytime state in the current repository."
argument-hint: ""
allowed-tools: [Read, Glob, Grep, Bash]
---

<!-- version-echo: display "storytime v1.0.0" at start of execution -->
# Storytime Status — Dashboard

Show the current state of storytime in this repository. Quick read-only
snapshot — no changes, no file operations.

## Arguments

None required. $ARGUMENTS

## Process

### 1. Detect Storytime Presence

Check for `specs/.storytime/`. If not found, check for storytime artifacts
elsewhere in the repo (adapt-in-place mode may not use `.storytime/`).

If no storytime presence found:
```
Storytime is not set up in this repo.
Run /storytime:bootstrap to get started, or
Run /storytime:survey to scan the codebase first.
```

### 2. Read Configuration

Read `specs/.storytime/config.md` for mode and settings.

### 3. Gather State

**Cohort:**
- Read `specs/.storytime/cohort/_roster.md`
- List active, inactive, and specialist personas
- Show session count and last active date per persona

**Sessions:**
- List all directories under `specs/.storytime/sessions/`
- For each: topic, date, which phases completed (by checking which files exist)
- Flag incomplete sessions (missing plan.md = didn't finish)

**Archive:**
- Read `specs/.storytime/archive/_index.md` if it exists
- Count: current (warm), rollups, cold items
- Flag any index staleness (files in archive/ not in index)

**History:**
- Read `specs/.storytime/history/decisions.md`
- Count total decisions, most recent decision date
- List sessions from `specs/.storytime/history/sessions/`

**Survey Coverage:**
- Find the most recent survey.md with a fingerprint
- Show: coverage ratio, commit drift since last survey, gap paths

### 4. Present Dashboard

```
╔══════════════════════════════════════════════════╗
║  STORYTIME STATUS — <repo-name>                  ║
╠══════════════════════════════════════════════════╣
║                                                  ║
║  Mode: native | Created: 2026-03-28              ║
║                                                  ║
║  COHORT                                          ║
║  ├── Kim (owner) — active, 3 sessions            ║
║  ├── Dana (systems) — active, 2 sessions         ║
║  └── Leo (operator) — benched since 2026-03-25   ║
║                                                  ║
║  SESSIONS                                        ║
║  ├── agc — complete (survey→plan) 2026-03-24     ║
║  ├── visual-identity — in progress (survey+team) ║
║  └── auth-consolidation — complete 2026-03-27    ║
║                                                  ║
║  ARCHIVE                                         ║
║  ├── Current (warm): 4 items                     ║
║  ├── Rollups: 1 item                             ║
║  └── Cold: 7 items                               ║
║                                                  ║
║  DECISIONS                                       ║
║  └── 12 total, last: AUTH-003 (2026-03-27)       ║
║                                                  ║
║  SURVEY COVERAGE                                 ║
║  ├── Last survey: 2026-03-26 (commit abc123f)    ║
║  ├── Coverage: 43% (38/89 files)                 ║
║  ├── Drift: 5 commits since survey               ║
║  └── Gaps: test/, pkg/legacy/                    ║
║                                                  ║
╚══════════════════════════════════════════════════╝
```

### 5. Suggest Next Actions

Based on state, suggest relevant next steps:
- Stale survey → "Run `/storytime:survey` to update coverage"
- Incomplete session → "Resume with `/storytime:storytime <topic>`"
- No archive index → "Run `/storytime:consolidate` to organize"
- Benched personas → "Consider activating or releasing via `/storytime:storytime-cohort`"
- High commit drift → "Codebase has changed significantly since last survey"
