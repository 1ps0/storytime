# Artifact Tiers & Rollup Format

Three temperature tiers for managing prior work artifacts through their lifecycle.

---

## Tier Definitions

```
╔═══════════════════════════════════════════════════════════════════╗
║  TIER        LOCATION                    BEHAVIOR                ║
║  ─────────   ─────────────────────────   ─────────────────────── ║
║                                                                   ║
║  HOT         specs/<topic>/              Active context. Loaded   ║
║              specs/.storytime/cohort/    into personas. Informs   ║
║                                          current work.            ║
║                                                                   ║
║  WARM        specs/.storytime/archive/   Reviewed, git-committed. ║
║              └── current/                Browsable by humans.     ║
║              └── rollups/                NOT auto-loaded into     ║
║                                          sessions.                ║
║                                                                   ║
║  COLD        specs/.storytime/archive/   Raw originals, deep      ║
║              └── cold/                   history. Available on    ║
║                                          explicit request only.   ║
║                                          Like AWS Glacier for     ║
║                                          docs.                    ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

## Archive Directory Structure

```
specs/.storytime/archive/
├── _index.md                     — TOC with tier and status per item
├── current/                      — warm: reviewed, still relevant
│   ├── agc-plan.md
│   └── architecture-overview.md
├── rollups/                      — warm: compressed multi-doc summaries
│   └── audio-pipeline-history.md
└── cold/                         — cold: raw originals, deep history
    ├── rfc-003-backpressure.md
    ├── old-agc-icebreaker.md
    └── kiro-websocket-spec.md
```

## Rollup Artifact Format

A rollup compresses multiple stale or overlapping artifacts into one
canonical document. The originals move to cold storage; the rollup
replaces them as the warm reference.

```markdown
---
type: rollup
created: <YYYY-MM-DD>
session: <session-id that produced this rollup>
sources:
  - path: <original-path>
    disposition: archived | deleted | superseded
  - path: <original-path>
    disposition: archived | deleted | superseded
covers: <one-line description of what this rollup covers>
---

# <Topic> — Rolled-Up History

## Key Decisions (carried forward)
- <DECISION-ID>: <summary> — still valid as of <date>
- <DECISION-ID>: <summary> — superseded by <new-decision-id>

## Timeline
| Date       | Event                    | Source              |
|------------|--------------------------|---------------------|
| YYYY-MM-DD | <what happened>          | <which source doc>  |

## Context Summary
<Narrative synthesis of the rolled-up documents. What matters
for someone encountering this topic for the first time.>

## Superseded By
<Pointer to current active work, if any. Or "none — this is
the latest record on this topic.">

## Raw Sources
<List of cold-storage paths for anyone who needs the originals.>
```

## Archive Index Format

The `_index.md` file is the browsable entry point for all archived artifacts.

```markdown
# Storytime Archive Index

Last updated: <YYYY-MM-DD>

## Current (warm)
| File | Source | Reviewed | Summary |
|------|--------|----------|---------|
| current/agc-plan.md | specs/agc/plan.md | 2026-03-28 | AGC implementation plan, still valid |

## Rollups (warm)
| File | Sources | Created | Covers |
|------|---------|---------|--------|
| rollups/audio-pipeline-history.md | 5 docs | 2026-03-28 | Audio pipeline evolution |

## Cold Storage
| File | Source | Archived | Reason |
|------|--------|----------|--------|
| cold/rfc-003-backpressure.md | docs/rfc-003.md | 2026-03-28 | Superseded by rollup |
```

## Tier Transitions

```
  HOT ──────────────── still relevant ──────────────── HOT
   │                                                     ▲
   │ reviewed, not active                                │
   ▼                                                     │
  WARM (current/) ────── user promotes ──────────────────┘
   │                                                     ▲
   │ stale, or rolled up                                 │
   ▼                                                     │
  WARM (rollups/) ────── user thaws ─────────────────────┘
   │
   │ originals after rollup
   ▼
  COLD ───────────────── user thaws ──── WARM or HOT
```

## Rules

1. **Rollups are opinionated summaries**, not mechanical concatenation.
   The team decides what carries forward.
2. **Cold artifacts are never deleted** from git. They're just out of
   the default view.
3. **The index is the source of truth** for what's in the archive.
   Keep it updated after every archive operation.
4. **Rollups cite their sources** so provenance is always traceable.
5. **External-system artifacts** (Slack threads, Google Docs, etc.)
   get a citation stub in the archive, not a full copy. Content from
   external systems stays in those systems.
