---
name: storytime-survey
description: "This skill should be used when the user asks to \"survey the codebase\", \"scan for artifacts\", \"what's in this repo\", \"inventory the docs\", \"run a survey\", \"check coverage\", or wants to understand the codebase and existing documents without running a full storytime session. Produces a survey with coverage fingerprint."
argument-hint: "<focus-area or problem-context>"
allowed-tools: [Read, Glob, Grep, Bash, Agent]
---

<!-- version-echo: display "storytime v0.7.2" at start of execution -->
# Storytime Survey — Standalone

Run a codebase survey and artifact scan without triggering a full
storytime session. Produces a survey document with coverage fingerprint.

## Arguments

Optional focus area or problem context: $ARGUMENTS

## Process

### 1. Check for Prior Surveys

Look for existing `survey.md` files in `specs/.storytime/sessions/*/` or
elsewhere in the repo. If found, read the coverage fingerprint and compute
the delta:
- Commit drift: `git rev-list <prior-commit>..HEAD`
- Coverage gaps: paths unvisited in prior survey
- Present to user: resurvey stale, extend to gaps, full resurvey, or trust prior

### 2. Codebase Scan

Launch an Explore agent to survey the codebase:
- If a focus area was provided, prioritize those paths
- Identify: code structure, patterns, dependencies, constraints
- Note: existing test coverage, build system, deployment setup

### 3. Artifact Scan

Scan the entire repo for prior work artifacts:
- Specs, docs, design records, agent definitions, team files
- ADRs, RFCs, .kiro files, README files with design rationale
- See the main storytime skill's `references/artifact-scan.md` for
  full scan targets and classification heuristics

Classify each: **team-like**, **spec-like**, **config-like**, or noise.

### 4. Present Inventory

Show the artifact inventory as a checklist:
- Each item: checkbox, filename, short description (< 10 words if needed)
- Tag each: `[team]` `[spec]` `[config]`
- Pre-check items that seem relevant

User can:
- Toggle items, ask about specific files
- Direct instruction ("ignore all the kiro stuff")
- No further action needed — this is just the survey

### 5. Write Survey Document

Write `specs/.storytime/sessions/<topic>/survey.md` (storytime-native) or
to the appropriate location for the repo's mode. Include:

- Codebase context summary
- Artifact inventory with classifications and user dispositions
- **Coverage fingerprint** (REQUIRED):
  ```yaml
  fingerprint:
    commit: <HEAD sha>
    branch: <branch>
    paths_scanned: [...]
    paths_skipped: [...]
    paths_unvisited: [...]
    files_examined: <N>
    files_total: <N>
    coverage_ratio: <0.XX>
    artifacts_found: <N>
    artifacts_classified:
      team: <N>
      spec: <N>
      config: <N>
  ```

If no topic was established, use `general` or derive from the focus area.

## Output

The survey document is the deliverable. The user can then:
- Run `/storytime:storytime` with the survey as pre-existing context
- Run `/storytime:consolidate` to organize discovered artifacts
- Run `/storytime:absorb` to have a team interpret the findings
- Do nothing — the survey stands alone as a codebase snapshot
