# Storytime Architecture

How Storytime maps to Claude Code's agent and tool system.

---

## Runtime Model

Storytime runs inside Claude Code as a skill that orchestrates
sub-agents. The main conversation thread is the orchestrator.

```
┌─────────────────────────────────────────────────────────────┐
│  Claude Code Main Thread (Orchestrator)                     │
│                                                             │
│  Responsibilities:                                          │
│  • Parse /storytime invocation                              │
│  • Load cohort from specs/.storytime/cohort/                │
│  • Run the event state machine                              │
│  • Write all output files                                   │
│  • Manage persona continuity                                │
│                                                             │
│  Skills Used:                                               │
│  • Read, Write, Edit (file I/O)                             │
│  • Glob, Grep (code search)                                 │
│  • Agent (sub-agent dispatch)                               │
│  • WebSearch, WebFetch (research breakouts)                 │
│  • Bash (benchmarks, script execution)                      │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Phase 0: SURVEY                                      │  │
│  │  → Agent(Explore) — codebase survey                   │  │
│  │  ← context summary returned to orchestrator           │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Phase 1: ASSEMBLE + ICEBREAKER                       │  │
│  │  → Orchestrator reads cohort files                    │  │
│  │  → Orchestrator runs conversation in main thread      │  │
│  │  → Writes team.md and icebreaker.md                   │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Phase 2: BREAKOUT (parallel dispatch)                │  │
│  │                                                       │  │
│  │  Agent("breakout-a") ─┐                               │  │
│  │  Agent("breakout-b") ─┼─ parallel, independent        │  │
│  │  Agent("breakout-c") ─┘                               │  │
│  │                                                       │  │
│  │  Each agent receives:                                 │  │
│  │  • Persona subset definitions                         │  │
│  │  • Sub-question to investigate                        │  │
│  │  • Icebreaker summary for shared context              │  │
│  │  • Access to skills (Grep, Read, WebSearch, etc.)     │  │
│  │                                                       │  │
│  │  Each agent returns:                                  │  │
│  │  • Findings with citations                            │  │
│  │  • Recommendation                                     │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Phase 3: CONVERGE                                    │  │
│  │  → Orchestrator merges breakout results               │  │
│  │  → Runs convergence conversation in main thread       │  │
│  │  → Writes plan.md with ASCII visual aids              │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Phase 4: REVIEW                                      │  │
│  │  → Present plan to user                               │  │
│  │  → User can challenge (inline mode)                   │  │
│  │  → Iterate until approved                             │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Phase 5: DONE                                        │  │
│  │  → Update persona files with new context              │  │
│  │  → Log session and decisions                          │  │
│  │  → Evaluate specialist contracts                      │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Mid-Conversation Breakout Architecture

During any phase, a persona can trigger a breakout. The orchestrator
decides how to execute it based on the type.

```
  Persona says: "Let me check the docs on that..."
       │
       ▼
  ┌─────────────────────────────────┐
  │  Orchestrator classifies:       │
  │                                 │
  │  INLINE (fast)?                 │
  │  → Grep/Read directly          │──→ result in <1s
  │  → No agent needed             │
  │                                 │
  │  BACKGROUND (slow)?             │
  │  → Agent(general-purpose)      │──→ result in 10-60s
  │  → Conversation continues      │    notified on complete
  │                                 │
  │  BLOCKING (critical)?           │
  │  → Agent(general-purpose)      │──→ conversation pauses
  │  → Must wait for result        │    resumes with findings
  └─────────────────────────────────┘
```

## Persistent State Model

```
  specs/.storytime/           (per-project, checked into git)
       │
       ├── cohort/            (permanent personas, evolve over time)
       │   └── *.md           (each has frontmatter with decisions[])
       │
       ├── specialists/       (temporary, scoped engagements)
       │   └── *.md
       │
       ├── history/           (append-only record)
       │   ├── decisions.md   (all decisions, all sessions)
       │   └── sessions/      (per-session summaries)
       │
       └── config.md          (project-level settings)
```

All state is Markdown files in the repo. No external databases,
no services, no API calls for persistence. Git is the database.

## Plugin Distribution

```
  ~/workspace/storytime/       (the plugin itself)
       │
       ├── .claude-plugin/     (manifest — tells Claude Code this is a plugin)
       ├── skills/             (4 skills — the entry points)
       ├── scripts/            (bash utilities for cohort/citations)
       ├── docs/               (comparisons, reference, architecture)
       └── examples/           (real sessions for reference)

  Installed via:
    claude install-plugin ~/workspace/storytime
    # or
    claude --plugin-dir ~/workspace/storytime

  Per-project state created via:
    ./scripts/bootstrap-cohort.sh /path/to/project
```
