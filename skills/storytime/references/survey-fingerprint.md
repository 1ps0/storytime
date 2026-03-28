# Survey Coverage Fingerprint

Every survey produces a fingerprint that records what it covered, what it
skipped, and where in git history it sits. This makes surveys composable
and incrementally extensible.

---

## Why Fingerprint

A survey is a snapshot of *part* of the codebase at *one point in git
history*. Without a fingerprint, subsequent runs can't know:

- What was already surveyed (avoiding redundant work)
- What changed since the last survey (commit drift)
- What was never looked at (coverage gaps)

The fingerprint makes these questions answerable.

---

## Fingerprint Format

Every `survey.md` includes a fingerprint block in its frontmatter:

```yaml
---
type: survey
session: <session-id>
created: <YYYY-MM-DD>
fingerprint:
  commit: <HEAD sha at survey time>
  branch: <branch name>
  paths_scanned:
    - cmd/**
    - pkg/enhance/**
    - specs/**
  paths_skipped:
    - vendor/**
    - node_modules/**
  paths_unvisited:
    - pkg/config/**
    - pkg/sip/**
    - test/**
  files_examined: 23
  files_total: 87
  coverage_ratio: 0.26
  artifacts_found: 8
  artifacts_classified:
    team: 2
    spec: 4
    config: 2
    noise: 0
---
```

### Field Definitions

| Field              | Description                                           |
|--------------------|-------------------------------------------------------|
| `commit`           | Git HEAD sha when the survey ran                      |
| `branch`           | Branch name at survey time                            |
| `paths_scanned`    | Glob patterns of paths actually read/analyzed         |
| `paths_skipped`    | Paths explicitly excluded (vendor, build output, etc) |
| `paths_unvisited`  | Paths that exist but weren't examined — coverage gaps |
| `files_examined`   | Count of files the survey actually read               |
| `files_total`      | Total files in repo (minus skipped paths)             |
| `coverage_ratio`   | files_examined / files_total                          |
| `artifacts_found`  | Count of prior work artifacts discovered              |
| `artifacts_classified` | Breakdown by classification type                 |

---

## Incremental Surveys

When SURVEY detects a prior `survey.md` with a fingerprint, it computes
the delta before deciding what to do.

### Delta Computation

```
Prior survey fingerprint:
  commit: abc123f
  paths_scanned: [cmd/**, pkg/enhance/**, specs/**]
  coverage_ratio: 0.26

Current state:
  HEAD: def456a
  commits since prior: git rev-list abc123f..HEAD → 12 commits

Delta analysis:
  ┌─────────────────────────────────────────────────────────────┐
  │  COMMIT DRIFT                                               │
  │  12 commits since prior survey                              │
  │                                                             │
  │  Files changed in drift:                                    │
  │    cmd/v1/main.go          — in scanned paths (STALE)       │
  │    pkg/config/config.go    — in unvisited paths (NEW+STALE) │
  │    pkg/enhance/enhance.go  — in scanned paths (STALE)       │
  │    docs/new-rfc.md         — new file (NEW)                 │
  │                                                             │
  │  COVERAGE GAPS                                              │
  │  Unvisited paths from prior survey:                         │
  │    pkg/config/**           — 4 files, never surveyed        │
  │    pkg/sip/**              — 6 files, never surveyed        │
  │    test/**                 — 5 files, never surveyed         │
  └─────────────────────────────────────────────────────────────┘
```

### Presentation to User

```
Prior survey found (2026-03-28, commit abc123f):
  Covered: cmd/, pkg/enhance/, specs/        (23 files, 26%)
  Stale:   3 files changed in 12 commits since survey
  Gaps:    pkg/config/, pkg/sip/, test/      (15 files, never surveyed)

  Options:
  [x] Resurvey stale paths (cmd/, pkg/enhance/)
  [x] Extend to gap paths (pkg/config/, pkg/sip/)
  [ ] Full resurvey (all 87 files)
  [ ] Trust prior survey, skip resurvey
```

### Merge Behavior

An incremental survey produces a new `survey.md` that merges the prior
fingerprint with new findings:

```yaml
fingerprint:
  commit: def456a                    # updated to current HEAD
  prior_commit: abc123f              # preserves lineage
  paths_scanned:
    - cmd/**                         # from prior + resurveyed
    - pkg/enhance/**                 # from prior + resurveyed
    - pkg/config/**                  # newly scanned
    - pkg/sip/**                     # newly scanned
    - specs/**                       # from prior, not stale
  paths_unvisited:
    - test/**                        # still unvisited (user skipped)
  files_examined: 38                 # increased
  files_total: 89                    # may have changed
  coverage_ratio: 0.43              # improved
```

---

## Fingerprint in Other Surveys

The fingerprint concept applies to any survey-like operation, not just
the storytime SURVEY phase:

| Context              | What's fingerprinted                          |
|----------------------|-----------------------------------------------|
| SURVEY phase         | Codebase coverage + artifact inventory        |
| ARCHAEOLOGY session  | Git history depth + contributor coverage      |
| RECONSTRUCT session  | External source coverage (which Slack channels, which PRs) |
| RETRO                | Implementation coverage vs plan               |

Each context tracks what was examined vs what exists, making it possible
to extend coverage incrementally rather than starting over.

---

## Rules

1. **Every survey writes a fingerprint.** No exceptions. Even a minimal
   survey records what it looked at.
2. **Fingerprints are append-friendly.** A new survey extends the prior
   fingerprint, it doesn't replace it. The `prior_commit` field preserves
   lineage.
3. **Coverage gaps are explicit.** `paths_unvisited` is not "stuff we
   forgot" — it's "stuff that exists that we chose not to examine yet."
4. **Commit drift is cheap to compute.** `git rev-list` and `git diff
   --name-only` are fast operations. Always compute drift when a prior
   fingerprint exists.
5. **The user decides what to resurvey.** The fingerprint presents the
   delta; the user picks the scope. Default: resurvey stale + extend gaps.
