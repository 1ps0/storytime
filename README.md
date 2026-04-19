# Storytime

A continuity system for LLM-harness collaboration. Builds technical
specifications through structured persona conversations — and carries
session state across compactions, sessions, and time. v1.0.0.

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   Problem Statement                                          │
│        │                                                     │
│        ▼                                                     │
│   ┌─────────┐                                                │
│   │  ROUTE  │─── thread exists? ──► WARM START               │
│   └────┬────┘         no            (load remembrance)       │
│        │                                                     │
│        ▼                                                     │
│   ┌─────────┐   ┌───────────┐   ┌──────────┐   ┌─────────┐ │
│   │ SURVEY  │──►│ ASSEMBLE  │──►│ICEBREAKER│──►│BREAKOUT │ │
│   │         │   │           │   │          │   │(×N, ∥)  │ │
│   │ explore │   │ build the │   │ status   │   │ deep    │ │
│   │ code    │   │ team      │   │ quo      │   │ dives   │ │
│   └─────────┘   └───────────┘   └──────────┘   └────┬────┘ │
│                                                      │      │
│                                                      ▼      │
│   ┌─────────┐   ┌───────────┐                ┌──────────┐  │
│   │  DONE   │◄──│  REVIEW   │◄───────────────│ CONVERGE │  │
│   │         │   │           │                │          │  │
│   │ update  │   │ user      │                │ plan.md  │  │
│   │ thread  │   │ approves  │                │ slides   │  │
│   └─────────┘   └───────────┘                └──────────┘  │
│                                                              │
│   Phases collapse when empty. Not every run uses every gear. │
│   Underneath: the consolidation loop (6 scales).             │
└──────────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# Install the plugin
claude install-plugin ~/workspace/storytime

# Or load for a single session
claude --plugin-dir ~/workspace/storytime

# Run it
/storytime "our public API has no rate limiting and scrapers are abusing /search"
```

## What It Produces

Per-topic session output with episode threading and consolidation:

```
specs/.storytime/
├── .version                         "1.0" positive marker
├── remembrance.md                   Workday-shaped wakeup (pre-/compact)
├── sessions/<topic>/
│   ├── _thread.md                   Continuity ledger + decision log
│   ├── 001/                         Episode 1
│   │   ├── survey.md                Codebase context + fingerprint
│   │   ├── team.md                  Persona definitions (ASCII boxed)
│   │   ├── icebreaker.md            Status quo discussion
│   │   ├── breakout-*.md            Deep dives on sub-problems
│   │   ├── plan.md                  ASCII slide deck + roadmap
│   │   └── buildout-*.md            Implementation traces
│   └── 002/                         Episode 2 (warm start)
├── cohort/                          Permanent personas (non-human codenames)
├── dreams/                          Optional ancillary per-commit byproducts
├── history/sessions/                Session summaries
├── archive/                         Hot/warm/cold tiers
├── commit-patterns.md               Adaptive commit-learning state
├── tutorial-state.md                Per-skill graduation progress
└── config.md                        Project settings
```

## Skills (19)

### Core Workflow

| Skill | What it does |
|-------|-------------|
| `/storytime <problem>` | Full workflow: survey, team, icebreaker, breakouts, plan |
| `/storytime-survey` | Standalone codebase survey with artifact inventory |
| `/storytime-breakout <sub-problem>` | Focused investigation: one driver + silent supporters |
| `/storytime-converge <topic>` | Merge breakout results into a unified plan |
| `/storytime-buildout <topic>` | Implement the plan — persona-driven coding with trace docs |
| `/storytime-retro <topic>` | Retrospective: plan vs built + evaluation scorecard |

### Team Management

| Skill | What it does |
|-------|-------------|
| `/storytime-cohort <action>` | Hire, fire, bench, promote, evolve personas |
| `/storytime-qa @persona <question>` | Formal queries with context + decision-log loading |
| `/storytime-echo <@role>` | One-shot spawning-pool voice (ephemeral, no state) |
| `/storytime-pr-qa <pr-number>` | Team handles PR review comments |

### Continuity and Control

| Skill | What it does |
|-------|-------------|
| `/storytime-remember [tier]` | Stage remembrance for /compact (nap/shift/compact) |
| `/storytime-lint [topic]` | Mechanical + reasoning-tier validation against process rules |
| `/storytime-bootstrap` | Initialize `.storytime/` structure in a repo |
| `/storytime-consolidate` | Organize, archive, roll up, backfill timestamps |
| `/storytime-absorb` | Team reads and interprets existing docs or code |
| `/storytime-export` | Convert output to ADRs, issues, Kiro specs, etc. |
| `/storytime-status` | Dashboard: cohort, sessions, decisions, tutorial progress |
| `/storytime-undo` | Revert at any granularity: phase, episode, thread, file |

## Key Concepts

**Consolidation** is the core loop. Context → consolidation events →
document structure → continuity. Six scales: phase, commit, nap, shift,
session, compact. The spec workflow is one surface on this loop.

**Remembrance** (`/storytime-remember`) is the handoff mechanism. A
workday-shaped wakeup document + consolidation prompt, staged before
`/compact` and loaded post-compact. Carries session state across context
boundaries.

**Personas** are domain-expert lenses with **non-human codenames**
(`anchor`, `lattice`, `kestrel`). Default core: OWNER, OPERATOR,
CRITIC x2. **One driver per leg** — supporters stay silent unless useful
AND non-distortive. `@role` is a lens directive usable inline.

**Decisions** are append-only, numbered per topic (RATE-001), pinned to
commits, stored in per-topic threads. Cross-topic references use
`Callout->` / `Callout<-` sigil lines — forward authoritative, reverse
is lint-cached.

**Threads** (`_thread.md`) are the continuity ledger — episodes,
decisions, consolidation log, open questions. Park mid-session and
resume with full context.

**Dreams** are optional ancillary per-commit byproducts capturing
hunches and noticed-but-not-said observations. Off by default.
Not on the critical path.

## Project Structure

```
storytime/
├── .claude-plugin/plugin.json    Plugin manifest (v1.0.0)
├── VERSION                       Version file
├── skills/                       19 skills (entry points)
├── agents/
│   ├── breakout-runner.md        Lifecycle-enforced breakout agent
│   ├── estimator.md              Lint reasoning-tier task force
│   └── dreamer.md                Post-commit ancillary consolidation
├── scripts/
│   ├── bootstrap-cohort.sh       Initialize cohort in any project
│   ├── bump-version.sh           Update version across all files
│   ├── check-conventions.sh      Mechanical invariant enforcement
│   ├── validate-citations.sh     Check for stale code references
│   ├── validate-breakouts.sh     Verify breakout output completeness
│   ├── validate-callouts.sh      Cross-topic callout validation
│   ├── decisions-view.sh         On-demand decisions across threads
│   ├── export-decisions.sh       Decision log → CSV (legacy compat)
│   └── migrate-to-v1.sh          v0.9.x → v1.0 migration
├── docs/
│   ├── proposals/
│   │   └── v1-consolidation.md   v1.0 architecture proposal (30 decisions)
│   ├── process-reference.md      Events, skills, 29 rules
│   ├── architecture.md           Runtime model, agent dispatch
│   ├── scale-impact.md           Scale 1-5 dimension framework
│   ├── surface-area.md           Plugin surface area map
│   ├── timestamps.md             Semantic timestamp principle
│   └── ...                       comparisons, context-feelers, etc.
├── examples/
│   ├── agc-session.md            Real session walkthrough
│   └── persona-template.md       New persona starter
├── site/                         Documentation site (4 HTML pages)
└── specs/.storytime/             Self-dogfood: storytime's own state
```

## Links

- [Guide](site/guide.html) — What, why, how to use, all 19 skills
- [Walkthrough](site/walkthrough.html) — Full simulated cold-start session
- [Reference](site/reference.html) — All 29 rules, citation formats, config, scripts
- [v1.0 Proposal](docs/proposals/v1-consolidation.md) — Architecture and 30 design decisions
- [Process Reference](docs/process-reference.md) — Internal process reference
