---
type: proposal
created: 2026-04-02T10:00
session: 2026-04-02-git-archaeology
status: draft
---

# Proposal: Git Archaeology as First-Class Capability

Git history is the original lore store. It's always available, requires no
auth, no API keys, no MCP servers. Making it a first-class investigation
tool in storytime sessions.

---

## Thesis

Every codebase has a story written in its git history. Commits tell you
what changed. Blame tells you who owns what. Log patterns reveal implicit
decisions — code that was added then reverted, functions that migrated
between files, ownership transfers between authors. This lore is free and
always present. Storytime should mine it systematically.

---

## Three Integration Levels

```
+------------------------------------------------------------+
|  LEVEL 1: SURVEY ENHANCEMENT (automatic)                   |
|  +---------------------------------------------------------+
|  |  During Phase 0: SURVEY, automatically run:             |
|  |                                                         |
|  |  git log --oneline --since="6 months" -- <scanned-paths>|
|  |  git shortlog -sn -- <scanned-paths>                    |
|  |  git log --diff-filter=D -- <scanned-paths>             |
|  |                                                         |
|  |  Produce:                                               |
|  |  - Recent change velocity per path                      |
|  |  - Top contributors (potential persona sources)         |
|  |  - Deleted files (things that were tried and abandoned) |
|  |  - Churn hotspots (frequently changed files)            |
|  |                                                         |
|  |  Append to survey.md fingerprint:                       |
|  |    git_archaeology:                                     |
|  |      window: 6 months                                   |
|  |      commits_analyzed: 142                              |
|  |      contributors: 5                                    |
|  |      hotspots: [pkg/enhance/enhance.go: 23 commits]     |
|  |      deletions: [pkg/old-audio/: removed 2026-02-15]    |
|  +---------------------------------------------------------+
|                                                            |
|  LEVEL 2: STANDALONE SKILL (/storytime-archaeology)        |
|  +---------------------------------------------------------+
|  |  Deep investigation of a specific path, file, or topic. |
|  |  Produces a narrative history from git evidence.        |
|  |                                                         |
|  |  Input: path, file, function name, or topic             |
|  |  Process:                                               |
|  |  1. Commit harvest — gather all relevant commits        |
|  |  2. Pattern extraction — identify implicit decisions    |
|  |  3. Contributor mapping — who drove what changes        |
|  |  4. Timeline synthesis — chronological narrative        |
|  |  5. Report generation — narrative + evidence            |
|  |                                                         |
|  |  Output: archaeology-report.md with timeline, patterns, |
|  |          contributor map, implicit decisions, citations  |
|  +---------------------------------------------------------+
|                                                            |
|  LEVEL 3: BREAKOUT INTEGRATION (mid-session)               |
|  +---------------------------------------------------------+
|  |  During any phase, a persona can invoke git archaeology |
|  |  as a breakout skill:                                   |
|  |                                                         |
|  |  Kim: "Let me check the history of this function..."    |
|  |  → git blame <file>                                     |
|  |  → git log -p --follow <file>                           |
|  |  → "This was rewritten 3 times. The current version     |
|  |     was authored by @dana in commit abc123. The prior    |
|  |     version was reverted because..."                    |
|  |                                                         |
|  |  Available as ARCHAEOLOGY breakout type alongside       |
|  |  VERIFY, RESEARCH, DISCOVERY, PROTOTYPE.                |
|  +---------------------------------------------------------+
+------------------------------------------------------------+
```

---

## Git Commands for Investigation

### Core Commands

| Command | What it reveals |
|---------|----------------|
| `git log --oneline --since="6m" -- <path>` | Recent change velocity |
| `git blame <file>` | Per-line ownership and age |
| `git log -p --follow <file>` | Full history including renames |
| `git shortlog -sn -- <path>` | Contributor ranking |
| `git log --diff-filter=D -- <path>` | Deleted files (abandoned approaches) |
| `git log --all --oneline --graph -- <path>` | Branch/merge topology |
| `git log --format='%H %s' --grep='<keyword>'` | Commits mentioning a topic |
| `git diff <sha1>..<sha2> -- <path>` | What changed between two points |

### Pattern Detection Commands

| Pattern | How to detect | What it means |
|---------|--------------|---------------|
| **Add-then-remove** | File appears in `--diff-filter=A` then `--diff-filter=D` | Approach was tried and abandoned |
| **Revert clusters** | Commit messages matching "revert" near each other | Instability — something keeps breaking |
| **Ownership transfer** | `git blame` shows author change across large blocks | Someone took over this code |
| **Dead research** | Branch exists but never merged | Exploration that didn't pan out |
| **Coupled files** | Files that always change together in commits | Hidden dependency |
| **Churn hotspots** | Files with high commit count relative to age | Active development or instability |

---

## Implicit Decision Extraction

The most valuable archaeology output: decisions that were made through
code changes but never documented.

```
+------------------------------------------------------------+
|  IMPLICIT DECISION DETECTION                               |
|                                                            |
|  Pattern: Add-then-remove                                  |
|  Evidence:                                                 |
|    commit abc123 (2026-02-20): "Add Opus decoder support"  |
|    commit def456 (2026-03-05): "Revert Opus decoder"       |
|  Implicit decision: Opus was tried and rejected.           |
|  Probable reason: (check commit messages, PR comments)     |
|                                                            |
|  Pattern: Coupled files                                    |
|  Evidence:                                                 |
|    config.go and main.go change together in 8/10 commits   |
|  Implicit decision: Config is tightly coupled to startup.  |
|  Architecture signal: may need decoupling.                 |
|                                                            |
|  Pattern: Ownership transfer                               |
|  Evidence:                                                 |
|    pkg/enhance/ was 100% @raj until 2026-03-24             |
|    Now 60% @kim after AGC implementation                   |
|  Implicit decision: Kim took over audio enhancement.       |
|  Org signal: Kim is now the domain expert here.            |
+------------------------------------------------------------+
```

---

## Contributor-to-Persona Bridge

Git authors are real people. Storytime personas are lenses. The bridge:

```
+------------------------------------------------------------+
|  CONTRIBUTOR MAPPING                                       |
|                                                            |
|  git shortlog -sn -- pkg/enhance/                          |
|    15  Kim Chen                                            |
|     8  Raj Patel                                           |
|     3  Dana Systems                                        |
|     1  dependabot[bot]                                     |
|                                                            |
|  Mapping:                                                  |
|    Kim Chen    → kim-owner-architect (cohort persona)      |
|    Raj Patel   → raj-domain-dsp (specialist, completed)    |
|    Dana Systems → dana-systems-voip (cohort persona)       |
|    dependabot  → (noise, skip)                             |
|                                                            |
|  When assembling a team for work in pkg/enhance/:          |
|  "Git history shows Kim owns 60% of this code, Raj wrote   |
|   the original DSP logic, and Dana contributed the VoIP    |
|   integration. Loading their personas with this context."  |
+------------------------------------------------------------+
```

This bridges the gap between "who actually wrote this" and "who should
the team consult." Real authorship informs persona selection.

---

## Survey Fingerprint Extension

Add archaeology fields to the existing survey fingerprint:

```yaml
fingerprint:
  commit: <sha>
  branch: <branch>
  paths_scanned: [...]
  # ... existing fields ...

  archaeology:
    window: "6 months"
    commits_in_window: 142
    contributors:
      - name: "Kim Chen"
        commits: 45
        paths: ["pkg/enhance/**", "cmd/v1/**"]
      - name: "Raj Patel"
        commits: 23
        paths: ["pkg/enhance/**"]
    hotspots:
      - path: "pkg/enhance/enhance.go"
        commits: 23
        last_changed: "2026-03-28"
      - path: "cmd/v1/main.go"
        commits: 18
        last_changed: "2026-03-24"
    deletions:
      - path: "pkg/old-audio/"
        deleted: "2026-02-15"
        commit: "abc123"
    implicit_decisions:
      - type: "add-then-remove"
        subject: "Opus decoder"
        add_commit: "abc123"
        remove_commit: "def456"
```

---

## Standalone Skill: /storytime-archaeology

```
Trigger: "dig into the history of", "who wrote this",
         "how did this evolve", "git archaeology",
         "investigate the history", "what happened to"

Input: path, file, function name, time range, or topic

Process:
  1. HARVEST   — gather commits, blame, contributor data
  2. EXTRACT   — identify patterns (churn, reverts, transfers)
  3. MAP       — connect contributors to personas
  4. SYNTHESIZE — build chronological narrative
  5. REPORT    — produce archaeology-report.md

Output:
  - Timeline of significant changes
  - Implicit decisions extracted from patterns
  - Contributor map with persona connections
  - Narrative history (human-readable story)
  - Evidence citations (commit shas, blame ranges)
```

---

## Warm-Start Integration

Git archaeology enhances warm-start by scaling depth with drift:

| Drift magnitude | Archaeology depth |
|----------------|-------------------|
| 0-5 commits | Summary only: "5 minor commits, no structural changes" |
| 6-20 commits | Pattern scan: check for reverts, new contributors, hotspot changes |
| 21-50 commits | Full archaeology on changed paths: timeline, patterns, implicit decisions |
| 50+ commits | Deep investigation: suggest a standalone archaeology session first |

The warm-start preamble includes archaeology findings when drift is
significant: "Since last session, 23 commits landed. Notable: pkg/enhance
was refactored by @kim (ownership transfer from @raj), and a caching
attempt was added then reverted (implicit decision: caching doesn't fit
the hot path)."

---

## Cost Controls

Git archaeology can be expensive on large repos. Limits:

| Control | Default | Configurable |
|---------|---------|-------------|
| Time window | 6 months | `archaeology_window` in config.md |
| Max commits to analyze | 500 | `archaeology_max_commits` |
| Max blame files | 20 | `archaeology_max_blame_files` |
| Contributor threshold | 2+ commits | Skip drive-by contributors |
| Pattern detection | enabled | `archaeology_patterns: true/false` |

On repos with 10k+ commits, always use scoped paths rather than
repo-wide archaeology. The survey fingerprint's `paths_scanned` provides
natural scoping.

---

## Relationship to Existing Docs

| Document | Relationship |
|----------|-------------|
| `docs/historical-absorption.md` | Archaeology is the git-native implementation of historical absorption. Absorption covers all sources; archaeology is git-specific. |
| `docs/context-feelers.md` | Git is listed as a "trivial" feeler. This proposal promotes it from feeler to first-class capability — it deserves more than a feeler because it's always available. |
| `references/survey-fingerprint.md` | Extended with archaeology fields. |
| `references/warm-start.md` | Archaeology enhances warm-start preamble with drift analysis. |

---

## Implementation Phases

| Phase | Scope | Complexity | Scale |
|-------|-------|-----|-------|
| 1. Survey enhancement | Add git stats to SURVEY fingerprint | 3 — morning's work | 2 (repo) — storytime plugin |
| 2. Breakout type | Add ARCHAEOLOGY to breakout types | 2 — straightforward | 2 (repo) — skill + reference |
| 3. Standalone skill | Full `/storytime-archaeology` skill | 5 — solid day | 2 (repo) — new skill |
| 4. Warm-start integration | Depth-scaled archaeology in preamble | 3 — morning's work | 2 (repo) — warm-start reference |
| 5. Implicit decision extraction | Pattern detection engine | 5 — solid day | 3 (repos) — touches survey + plan |

Total: Complexity 18 — must decompose. The 5 phases above are the decomposition.

---

## Non-Goals

| Non-goal | Why not | Revisit when |
|----------|---------|-------------|
| Git bisect automation | Requires test harness, very project-specific | A project requests it with a test suite |
| Cross-repo archaeology | Investigating git history across siblings | Cross-repo interface is implemented |
| Real-time git monitoring | Watch for commits and trigger analysis | CI/CD integration is built |
| Rewriting git history | Never. Archaeology reads, never writes history. | Never. |

---

## Open Questions

1. **Should archaeology be opt-in or opt-out?** Adding git stats to every
   survey adds ~2-5 seconds. Worth it for the context, or should it
   require `archaeology: true` in config?

2. **How to handle monorepos?** A monorepo with 50k commits needs very
   tight path scoping. Should archaeology auto-detect monorepo patterns
   and adjust its window/scope?

3. **Implicit decision confidence?** An add-then-remove pattern strongly
   suggests an abandoned approach. But a file rename might look similar.
   How confident should archaeology be in its pattern detection?

4. **Should archaeology create personas?** If git shortlog reveals a
   contributor who isn't in the cohort, should archaeology suggest adding
   them as a persona? Or is that the user's call?
