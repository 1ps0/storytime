---
name: storytime-bootstrap
description: "This skill should be used when the user asks to \"bootstrap storytime\", \"set up storytime\", \"init storytime\", \"initialize the team structure\", or wants to prepare a repository for storytime use. Creates the .storytime/ directory structure and chooses the operating mode."
argument-hint: "[mode: native|adapt|export]"
allowed-tools: [Read, Write, Bash, Glob, Grep]
---

<!-- version-echo: display "storytime v0.5.0" at start of execution -->
# Storytime Bootstrap

Set up the storytime structure in a repository. Detect what exists,
choose an operating mode, and create the directory tree.

## Arguments

Optional mode override: $ARGUMENTS

## Process

### 1. Detect the Landscape

Scan the repo to understand what already exists:
- Does `specs/.storytime/` exist? → already bootstrapped
- Does the repo have its own doc structure (`team/`, `docs/`, `specs/`)? → established conventions
- Is this a fresh repo with minimal structure? → clean slate
- Are there other spec systems (`.kiro/`, ADRs, etc.)? → coexistence needed

### 2. Choose Mode

Present the three modes with a recommendation based on what was found:

**Storytime-native** (recommended for new or lightly-structured repos):
- Full `.storytime/` directory tree
- Sessions, cohort, archive, history all under one root
- Maximum storytime functionality

**Adapt-in-place** (recommended for repos with established conventions):
- Work within the repo's existing doc structure
- Write team docs where team docs already live
- Write plans where plans already live
- Create a minimal `.storytime/config.md` to track mode and settings

**Export-only** (for one-shot use or feeding other systems):
- No persistent storytime state
- Produce output files wherever the user specifies
- No cohort, no archive, no history

If the user provided a mode argument, use it. Otherwise recommend based
on the landscape and ask.

### 3. Create Structure

**Storytime-native:**
```bash
mkdir -p specs/.storytime/{sessions,cohort,specialists,archive/{current,rollups,cold},history/sessions}
```

Write `specs/.storytime/config.md`:
```yaml
mode: native
created: <YYYY-MM-DD>
default_mode: inline
automation: guided
max_team_size: 12
require_operator: true
require_nongoals: true
visual_style: ascii
citation_format: "file:line — snippet"
```

**Adapt-in-place:**

Write `specs/.storytime/config.md` (minimal):
```yaml
mode: adapt
created: <YYYY-MM-DD>
output_paths:
  team: <detected team doc location>
  specs: <detected spec location>
  plans: <detected plan location>
  archive: specs/.storytime/archive/
```

Create only `specs/.storytime/` and `specs/.storytime/archive/` — the
rest uses existing directories.

**Export-only:**

Write `specs/.storytime/config.md` (minimal):
```yaml
mode: export
created: <YYYY-MM-DD>
```

No other directories created.

### 4. Report

Show what was created and what the next step is:
- "Run `/storytime:storytime <problem>` to start your first session"
- "Run `/storytime:survey` to scan the codebase first"
- "Run `/storytime:consolidate` to organize existing docs"

## If Already Bootstrapped

If `specs/.storytime/` exists, report current state instead of re-creating:
- Mode in use
- Number of personas in cohort
- Number of sessions
- Archive contents
- Suggest `/storytime:status` for a full dashboard
