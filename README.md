# Storytime

A Claude Code plugin that builds technical specifications through
structured conversations between domain-expert personas.

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   Problem Statement                                          │
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
│   │ cohort  │   │ approves  │                │ slides   │  │
│   └─────────┘   └───────────┘                └──────────┘  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## What Storytime Produces

For each feature or problem you run through it, Storytime generates
a `specs/<topic>/` directory containing:

```
specs/agc/
├── team.md           5 personas with boxed ASCII definitions
├── icebreaker.md     Status quo discussion, grounded in code
├── breakout-*.md     Deep dives on sub-problems (optional)
└── plan.md           ASCII slide deck with implementation plan
```

Plus persistent state in `specs/.storytime/`:

```
specs/.storytime/
├── cohort/
│   ├── _roster.md                 Active team index
│   ├── kim-owner-architect.md     Persona with accumulated context
│   ├── dana-systems-voip.md
│   └── leo-operator-sre.md
├── history/
│   ├── decisions.md               Append-only decision log
│   └── sessions/                  Session summaries
└── config.md                      Project-level settings
```

## Installation

```bash
claude install-plugin ~/workspace/storytime
```

Or for development:

```bash
claude --plugin-dir ~/workspace/storytime
```

## Skills

### `/storytime <problem-statement>`

The main workflow. Surveys your codebase, assembles a persona team,
runs an icebreaker discussion, executes breakouts, and produces a
plan with ASCII visual aids.

```
/storytime "we need automatic gain control for quiet SIP callers"
```

**Automation gradient:**
- `manual` — pauses for approval at each phase transition
- `guided` (default) — runs phases automatically, pauses at REVIEW
- `auto` — runs end-to-end, presents final plan for approval

### `/storytime-qa @persona <question>`

Query a specific persona or the full team about past decisions,
current code state, or hypothetical changes.

```
/storytime-qa @kim should we use the same env-var pattern for Opus?
/storytime-qa @team does our AGC decision still hold after the resample change?
```

### `/storytime-retro <topic>`

Run a retrospective on a completed spec. Reconvenes the original
team to evaluate outcomes against the plan.

```
/storytime-retro agc
```

### `/storytime-cohort <action> [args]`

Manage the permanent persona team.

```
/storytime-cohort list
/storytime-cohort hire raj domain-dsp "Audio DSP engineer, 10yr embedded"
/storytime-cohort fire old-persona
/storytime-cohort bench dana
/storytime-cohort evolve kim "now knows Opus codec internals"
/storytime-cohort promote raj-dsp-agc
```

## Automation Gradient

Storytime runs on a gradient from fully manual to fully automatic.
Set via `specs/.storytime/config.md` or per-invocation.

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  MANUAL          GUIDED (default)      AUTO                 │
│  ────────        ─────────────────     ──────               │
│                                                             │
│  Pause at        Run phases auto,      Run end-to-end,     │
│  every phase     pause at REVIEW       present final plan  │
│  transition      for user approval     for approval only   │
│                                                             │
│  User approves   User reviews plan     User reviews plan   │
│  team, each      and can challenge     and approves or     │
│  breakout, and   decisions inline      requests revision   │
│  the plan                                                  │
│                                                             │
│  Best for:       Best for:             Best for:           │
│  Learning the    Day-to-day use,       Well-understood     │
│  system, high-   most features         problems, trusted   │
│  stakes specs                          cohort              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Persona Co-Authoring

When Storytime personas contribute to implementation decisions that
lead to commits, you can credit them in commit messages:

```
feat: add per-frame AGC with RMS normalization

Designed through Storytime session 2026-03-24-agc.
Key contributors: Kim (integration), Raj (algorithm), Leo (observability).
Decisions: AGC-001 through AGC-006.
```

This creates a traceable link from git history back to the Storytime
narrative, making the "why" behind code changes discoverable.

## Conversation Modes

| Mode          | When                                     | How it works                          |
|---------------|------------------------------------------|---------------------------------------|
| **Inline**    | Active design session                    | User and personas share the thread    |
| **Deliberation** | "Go figure this out"                 | Team works, returns with Q&A          |
| **QA**        | Specific question about past decisions   | Target one persona or full team       |

## How It Compares

See [docs/comparisons.md](docs/comparisons.md) for detailed comparison with
Speckit, Kiro, OpenSpec, ADRs, and traditional spec writing.

## Project Structure

```
storytime/
├── .claude-plugin/
│   └── plugin.json           Plugin manifest
├── skills/
│   ├── storytime/            Main workflow skill
│   ├── storytime-qa/         Persona query skill
│   ├── storytime-retro/      Retrospective skill
│   └── storytime-cohort/     Team management skill
├── scripts/
│   ├── bootstrap-cohort.sh   Initialize cohort in a project
│   ├── validate-citations.sh Check for stale code references
│   └── export-decisions.sh   Export decision log as JSON
├── examples/
│   ├── agc-session.md        Real example: AGC for VoIP gateway
│   └── persona-template.md   Template for new personas
├── docs/
│   ├── comparisons.md        vs Speckit, Kiro, OpenSpec, ADRs
│   ├── process-reference.md  Full event/skill/rule reference
│   └── architecture.md       How Storytime maps to Claude Code agents
└── BACKLOG.md                Enhancement ideas and roadmap
```
