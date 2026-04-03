---
type: reference
created: 2026-03-29T15:30
session: 2026-03-29-surface-area
---

# Storytime Surface Area

Everything storytime creates, exposes, points to, and manages.
This is the complete map of what the system touches.

---

## 1. Document Types (what storytime produces)

Every document storytime produces has universal frontmatter:
`type`, `created`, `session`. See `docs/timestamps.md`.

| Type | Produced by | Location | Frontmatter |
|------|------------|----------|-------------|
| `survey` | SURVEY phase, `/storytime-survey` | `sessions/<topic>/survey.md` | + coverage fingerprint (commit, paths, gaps, ratios) |
| `team` | ASSEMBLE phase | `sessions/<topic>/team.md` | + personas listed |
| `icebreaker` | ICEBREAKER phase | `sessions/<topic>/icebreaker.md` | + artifact review dispositions |
| `breakout` | BREAKOUT phase | `sessions/<topic>/breakout-<sub>.md` | + Complexity, Scale, participating personas |
| `plan` | CONVERGE phase | `sessions/<topic>/plan.md` | + roadmap with Complexity and Scale per item |
| `retrospective` | `/storytime-retro` | `sessions/<topic>/retrospective.md` | + timestamp audit results |
| `session-summary` | DONE phase | `history/sessions/<date>-<topic>.md` | + started, completed timestamps |
| `persona` | ASSEMBLE, `/storytime-cohort` | `cohort/<name>-<archetype>-<specialty>.md` | + inception, last_active, evolved[], decisions_participated[] |
| `rollup` | `/storytime-consolidate`, ICEBREAKER | `archive/rollups/<name>.md` | + last_reviewed, sources[].date |
| `absorption` | `/storytime-absorb` | `sessions/<topic>/absorption.md` | + coverage fingerprint of what was read |
| `config` | `/storytime-bootstrap` | `config.md` | + mode, created date |
| `decision` | Any session (DONE phase) | `history/decisions.md` (entries) | + date, last_reviewed, superseded_by |
| `archive-index` | `/storytime-consolidate`, ICEBREAKER | `archive/_index.md` | + last updated, per-item timestamps |

---

## 2. Directory Structures (what storytime creates on disk)

### Storytime-native mode

```
specs/.storytime/
├── config.md                          Project-level settings
├── cohort/                            Permanent personas
│   ├── _roster.md                     Team roster (table format)
│   └── <name>-<archetype>-<spec>.md   Individual persona files
├── specialists/                       Temporary personas (scoped contracts)
├── sessions/                          All session output
│   └── <topic>/                       One dir per topic
│       ├── survey.md
│       ├── team.md
│       ├── icebreaker.md
│       ├── breakout-<subtopic>.md
│       └── plan.md
├── archive/                           Tiered document storage
│   ├── _index.md                      Browsable TOC
│   ├── current/                       Warm — reviewed, still relevant
│   ├── rollups/                       Warm — compressed multi-doc summaries
│   └── cold/                          Deep history (glacier)
└── history/                           Append-only records
    ├── decisions.md                   All decisions, all sessions
    └── sessions/                      Per-session summaries
        └── <YYYY-MM-DD>-<topic>.md
```

### Adapt-in-place mode

Minimal footprint — only `specs/.storytime/config.md` and optionally
`specs/.storytime/archive/`. Output goes wherever the repo already
keeps similar content.

### Export-only mode

No persistent structure. Only `specs/.storytime/config.md` to record
that export mode was chosen.

---

## 3. Measurement Systems (concepts storytime applies)

| Concept | Measures | Scale | Documented in |
|---------|----------|-------|---------------|
| **Complexity** | How hard — cognitive complexity | Fibonacci: 1, 2, 3, 5, 8, 13, 21+ | `references/complexity-units.md` |
| **Scale Impact** | How big — magnitude across any dimension | 1-5 (contained → massive) | `docs/scale-impact.md` |
| **Timestamps** | When — semantic events vs file edits | Day / Minute / Approximate (~) | `docs/timestamps.md` |
| **Survey Fingerprint** | What was covered — codebase coverage snapshot | Commit SHA + paths + ratios | `references/survey-fingerprint.md` |
| **Artifact Tiers** | How accessible — temperature of stored docs | Hot / Warm / Cold | `references/artifact-tiers.md` |

### Where measurements appear

| Context | Complexity | Scale | Timestamps | Fingerprint | Tiers |
|---------|-----|-------|------------|-------------|-------|
| Plan roadmap items | per item | per item (with dimension) | created | — | — |
| Breakout scoping | per breakout | per breakout | created | — | — |
| Survey output | — | — | created | REQUIRED | artifact classification |
| Archive operations | — | — | archived_at, source dates | — | per artifact |
| Persona lifecycle | — | — | inception, last_active, evolved[] | — | — |
| Decision log | — | — | date, last_reviewed | — | — |
| Session summary | — | — | started, completed | — | — |
| Rollup artifacts | — | — | created, last_reviewed, source dates | — | sources tracked |

---

## 4. Skills (entry points into the system)

| Skill | Invocation | Reads | Writes | Modifies |
|-------|-----------|-------|--------|----------|
| **storytime** | `/storytime:storytime` | Codebase, all .storytime/ state, prior artifacts | survey, team, icebreaker, breakout, plan, session summary, decisions | Persona files, archive index |
| **storytime-survey** | `/storytime:storytime-survey` | Codebase, prior surveys | survey.md with fingerprint | — |
| **storytime-cohort** | `/storytime:storytime-cohort` | Roster, persona files | New persona files | Roster, existing persona files |
| **storytime-qa** | `/storytime:storytime-qa` | Persona files, decision log, session transcripts | — (inline response) | Decision log (if answer yields a decision) |
| **storytime-retro** | `/storytime:storytime-retro` | Session output, current codebase | retrospective.md, changelog.md | Persona files, decision log |
| **storytime-absorb** | `/storytime:storytime-absorb` | Specified documents, code, cohort | absorption.md, decisions | Persona files (acquired context) |
| **storytime-consolidate** | `/storytime:storytime-consolidate` | All repo docs, prior surveys | Rollups, archive index | File locations (git mv), frontmatter (backfill) |
| **storytime-bootstrap** | `/storytime:storytime-bootstrap` | Repo structure | config.md, directory tree | — |
| **storytime-export** | `/storytime:storytime-export` | Session output, decisions, personas | ADRs, issues, tickets, reports (external formats) | — |
| **storytime-status** | `/storytime:storytime-status` | All .storytime/ state | — (inline dashboard) | — |

---

## 5. Process Rules (behavioral constraints)

31 rules as of 2026-03-29. Documented in `docs/process-reference.md`.

Grouped by concern:

**Phase ordering (1-4):**
SURVEY → ASSEMBLE → ICEBREAKER → BREAKOUT → CONVERGE → REVIEW.
Phases collapse when empty.

**Team constraints (5-9):**
Min 3, max 7 personas. At least one OPERATOR. Personas are lenses,
not characters. User has veto power.

**Output requirements (10-16):**
Every claim cites code. Non-goals and success criteria required.
ASCII visual aids. Every phase writes output. Track everything.

**Artifact management (17-26):**
Prior runs are prior art. Surveys have fingerprints. Rollups replace
stale docs. Archive is git-committable and repo-local. Everything
under `.storytime/`. Bias toward consolidation.

**Measurement discipline (27-31):**
Universal frontmatter on every document. Semantic timestamps, not
duplicated git timestamps. Inferred timestamps marked with confidence.
Complexity + Scale, never time estimates. Evaluation hygiene.

---

## 6. Frontmatter Schemas (metadata storytime manages)

### Universal (all documents)

```yaml
type: <document-type>
created: <YYYY-MM-DDTHH:MM>
session: <session-id | null>    # omitted for persona files (they exist independently)
```

### Survey fingerprint

```yaml
fingerprint:
  commit: <sha>
  branch: <branch>
  paths_scanned: [...]
  paths_skipped: [...]
  paths_unvisited: [...]
  files_examined: <N>
  files_total: <N>
  coverage_ratio: <0.XX>
  artifacts_found: <N>
  artifacts_classified: {team: N, spec: N, config: N}
  artifacts_metadata:            # filesystem awareness
    - path: <file>
      git_modified: <date>
      git_author: <name>
      fs_mtime: <datetime>
      size_bytes: <N>
      uncommitted_changes: <bool>
```

### Persona

```yaml
name: <name>
archetype: <domain|systems|platform|owner|operator|skeptic>
status: <active|inactive|alumni>
inception: <YYYY-MM-DD>
last_active: <YYYY-MM-DD>
evolved:
  - date: <YYYY-MM-DD>
    change: "<description>"
    session: <session-id>
sessions: [<session-ids>]
expertise_acquired: [...]
decisions_participated:
  - id: <TOPIC-NNN>
    decision: "<summary>"
    role: "<their role>"
    date: <YYYY-MM-DD>
```

### Rollup

```yaml
last_reviewed: <YYYY-MM-DD>
sources:
  - path: <original-path>
    disposition: archived | deleted | superseded
    created: <YYYY-MM-DD>
    last_modified: <YYYY-MM-DD>
covers: <description>
```

### Archive item

```yaml
archived_at: <YYYY-MM-DD>
archived_from: <original-path>
source_created: <YYYY-MM-DD>
source_last_modified: <YYYY-MM-DD>
archive_tier: current | cold
```

### Session summary

```yaml
topic: <topic>
started: <YYYY-MM-DDTHH:MM>
completed: <YYYY-MM-DDTHH:MM>
phases_completed: [survey, assemble, icebreaker, ...]
personas: [<names>]
decisions_made: [<IDs>]
```

### Config

```yaml
mode: native | adapt | export
created: <YYYY-MM-DD>
default_mode: inline | deliberation
automation: manual | guided | auto
max_team_size: 12
default_core: [owner, operator, critic]
require_nongoals: true
visual_style: ascii
citation_format: "file:line — snippet"
```

### Timestamp confidence (optional, for backfilled values)

```yaml
created_confidence: git-derived | approximate | estimated
last_active_confidence: git-derived | approximate | estimated
```

---

## 7. External Touchpoints (what storytime points to or imports from)

### Currently implemented
- **Git** — timestamps, blame, history, commit SHAs (via Bash)
- **Filesystem** — mtime, size (via stat)
- **Claude Code plugin system** — `--plugin-dir`, skill auto-discovery

### Designed but not yet implemented
- **GitHub MCP** — PRs, issues, review comments (via feelers)
- **Slack MCP** — threads, messages (via feelers)
- **Google Docs MCP** — document content (via feelers)
- **Linear/Jira** — tickets (via feelers)

### Export targets (via `/storytime-export`)
- ADR format
- GitHub Issues (via `gh` CLI)
- Linear/Jira CSV/JSON
- Kiro spec format
- Claude Code agent definitions
- Unified markdown report

---

## 8. Bootstrap Modes (how storytime adapts to context)

| Mode | When | Creates | Persists |
|------|------|---------|----------|
| **Storytime-native** | New repos, repos that adopt storytime | Full `.storytime/` tree | Everything — cohort, archive, history |
| **Adapt-in-place** | Repos with existing doc conventions | Minimal `config.md` + archive only | Config and archive; output goes to existing locations |
| **Export-only** | One-shot use, feeding other systems | `config.md` only | Nothing — session produces output and exits |

---

## 9. Artifact Lifecycle (how documents move through the system)

```
  DISCOVERED (survey scan)
       │
       ├── team-like ──► ASSEMBLE (rehire candidate)
       │                    │
       │                    ├── rehired ──► COHORT (permanent)
       │                    └── skipped
       │
       ├── spec-like ──► ICEBREAKER (team review)
       │                    │
       │                    ├── keep hot ──► SESSION CONTEXT
       │                    ├── archive warm ──► archive/current/
       │                    ├── rollup ──► archive/rollups/ (originals → cold)
       │                    ├── send cold ──► archive/cold/
       │                    └── skip ──► left in place
       │
       └── config-like ──► loaded silently

  CONSOLIDATION (git mv into .storytime/)
       │
       └── timestamps backfilled if missing

  THAW (on request, any cold artifact can be promoted)
       │
       └── cold → warm → hot
```

---

## 10. Scripts (utilities shipped with the plugin)

| Script | Purpose | Reads | Writes |
|--------|---------|-------|--------|
| `scripts/bootstrap-cohort.sh` | Initialize `.storytime/` in a project | — | Directory tree, roster, config |
| `scripts/validate-citations.sh` | Check stale code references in specs | Spec files, codebase | Report (stdout) |
| `scripts/export-decisions.sh` | Decision log → CSV/text | `history/decisions.md` | Formatted output (stdout) |
