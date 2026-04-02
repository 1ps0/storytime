# Storytime

A Claude Code plugin that builds technical specifications through
structured conversations between domain-expert personas. v0.2.0.

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   Problem Statement                                          │
│        │                                                     │
│        ▼                                                     │
│   ┌─────────┐                                                │
│   │  ROUTE  │─── thread exists? ──► WARM START               │
│   └────┬────┘         no            (previously on...)       │
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
└──────────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# Install the plugin
claude install-plugin ~/workspace/storytime

# Or load for a single session
claude --plugin-dir ~/workspace/storytime

# Run it
/storytime "we need automatic gain control for quiet SIP callers"
```

That's it. Storytime surveys your code, assembles a team, and produces a
plan. See [PRIMER.md](PRIMER.md) for what it is, [HOWTO.md](HOWTO.md)
for how to use it.

## What It Produces

Per-topic session output with episode threading:

```
specs/.storytime/
├── sessions/<topic>/
│   ├── _thread.md                   Episode bookmark
│   ├── 001/                         Episode 1
│   │   ├── survey.md                Codebase context + fingerprint
│   │   ├── team.md                  Persona definitions (ASCII boxed)
│   │   ├── icebreaker.md            Status quo discussion
│   │   ├── breakout-*.md            Deep dives on sub-problems
│   │   └── plan.md                  ASCII slide deck + roadmap
│   └── 002/                         Episode 2 (warm start)
│       ├── preamble.md              "Previously on..." narrative
│       ├── survey-delta.md          Incremental changes only
│       └── plan.md                  Updated plan
├── cohort/                          Permanent personas
├── history/
│   ├── decisions.md                 Append-only decision log
│   └── sessions/                    Session summaries
└── config.md                        Project settings
```

## Skills

### Core Workflow

| Skill | What it does |
|-------|-------------|
| `/storytime <problem>` | Full workflow: survey, team, icebreaker, breakouts, plan |
| `/storytime-survey` | Standalone codebase survey with artifact inventory |
| `/storytime-breakout <sub-problem>` | Focused 2-3 persona investigation without the full pipeline |
| `/storytime-converge <topic>` | Merge breakout results into a unified plan |
| `/storytime-retro <topic>` | Retrospective: plan vs what was actually built |

### Team Management

| Skill | What it does |
|-------|-------------|
| `/storytime-cohort <action>` | Hire, fire, bench, promote, evolve personas |
| `/storytime-qa @persona <question>` | Query personas about past decisions or code |
| `/storytime-pr-qa <pr-number>` | Team handles PR review comments with proposed responses |

### Document Operations

| Skill | What it does |
|-------|-------------|
| `/storytime-bootstrap` | Initialize `.storytime/` structure in a repo |
| `/storytime-consolidate` | Organize, archive, roll up, backfill timestamps |
| `/storytime-absorb` | Team reads and interprets existing docs or code |
| `/storytime-export` | Convert output to ADRs, issues, Kiro specs, etc. |

### Session Control

| Skill | What it does |
|-------|-------------|
| `/storytime-status` | Dashboard: cohort, sessions, decisions, citations |
| `/storytime-undo` | Revert at any granularity: phase, episode, thread, or specific file |

## Key Concepts

**Personas** are domain-expert lenses, not characters. An OPERATOR asks
about kill switches. A SKEPTIC asks "do we need this?" They ground every
claim in code citations.

**Episodes** are chapters in an ongoing story. Same topic, continuing
narrative. Warm start synthesizes a "previously on..." so you pick up
without re-reading the book.

**Decisions** are append-only, numbered per topic (AGC-001, AGC-002).
They cite the code and personas that drove them. Never deleted, only
superseded.

**Threads** (`_thread.md`) are the bookmark. They track episodes, team
state, open questions, and the last git commit. Phase checkpointing means
you can park mid-session and resume later.

## Project Structure

```
storytime/
├── .claude-plugin/plugin.json    Plugin manifest (v0.2.0)
├── VERSION                       Version file
├── skills/                       14 skills (entry points)
├── agents/
│   └── breakout-runner.md        Lifecycle-enforced breakout agent
├── scripts/
│   ├── bootstrap-cohort.sh       Initialize cohort in any project
│   ├── validate-citations.sh     Check for stale code references
│   ├── validate-breakouts.sh     Verify breakout output completeness
│   ├── export-decisions.sh       Decision log → JSON
│   └── bump-version.sh           Update version across all files
├── docs/
│   ├── process-reference.md      Events, skills, 43 rules
│   ├── architecture.md           Runtime model, agent dispatch
│   ├── comparisons.md            vs Speckit, Kiro, OpenSpec, ADRs
│   ├── multi-repo-distribution.md Installation models, org cohort
│   ├── context-feelers.md        MCP connectors for external context
│   ├── historical-absorption.md  Codebase archaeology
│   ├── timestamps.md             Semantic timestamp principle
│   ├── scale-impact.md           Scale 1-5 dimension framework
│   ├── surface-area.md           Plugin surface area map
│   └── proposals/                Future-looking design specs
│       ├── cross-repo-interface.md
│       ├── worktrees-workflow.md
│       └── git-archaeology.md
├── examples/
│   ├── agc-session.md            Real AGC walkthrough
│   └── persona-template.md       New persona starter
├── PRIMER.md                     What storytime is and why
├── HOWTO.md                      Developer-oriented usage guide
├── BACKLOG.md                    Enhancement roadmap
└── SESSION-CONTEXT.md            Genesis session context
```

## Links

- [PRIMER.md](PRIMER.md) — What storytime is, the value proposition
- [HOWTO.md](HOWTO.md) — Developer guide to using storytime effectively
- [docs/process-reference.md](docs/process-reference.md) — Complete reference
- [docs/comparisons.md](docs/comparisons.md) — How it compares to other tools
- [BACKLOG.md](BACKLOG.md) — What's next
