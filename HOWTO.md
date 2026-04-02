# Storytime HOWTO

Developer-oriented guide to using storytime effectively.

---

## Install

```bash
# Option 1: Permanent install
claude install-plugin ~/workspace/storytime

# Option 2: Per-session (for testing or development)
claude --plugin-dir ~/workspace/storytime
```

Verify it's loaded — you should see storytime skills in the slash command
list. Any skill invocation starts with `storytime v0.2.0`.

---

## Your First Session

### 1. Bootstrap (optional)

If this is the first time using storytime in a repo:

```
/storytime-bootstrap
```

This creates the `.storytime/` directory structure. You can also skip
this — the main `/storytime` skill will offer to create it on first run.

### 2. Run It

```
/storytime "describe the problem you want to solve"
```

Be specific. "Add caching" is vague. "API responses for /users are slow
because we hit the database on every request, need a caching layer that
respects our existing auth middleware" gives the team something to work with.

### 3. What Happens Next

**SURVEY** — storytime explores your codebase. If prior artifacts exist
(specs, ADRs, team docs), it presents an inventory. Check what's relevant,
skip what isn't.

**ASSEMBLE** — a team of 3-7 personas is proposed based on the problem's
domains. At least one OPERATOR (who asks about prod concerns). You can
adjust: "add a security specialist" or "we don't need a frontend persona."

**ICEBREAKER** — the team discusses the status quo, grounded in your code.
Each persona states what they see from their vantage point. Sub-problems
are identified.

**BREAKOUT** — sub-problems get parallel deep dives with 2-3 personas each.
These can run as background agents. Each produces findings + recommendation.

**CONVERGE** — the full team reconvenes, merges breakout findings, resolves
conflicts, and produces the plan.

**REVIEW** — the plan is presented to you. Challenge any decision. The
personas defend with citations or revise. When you approve, session
completes.

### 4. Reading the Output

Everything lands in `specs/.storytime/sessions/<topic>/<episode>/`:

- **survey.md** — what the codebase looks like, with a coverage fingerprint
- **team.md** — persona definitions in ASCII boxed format
- **icebreaker.md** — the status quo discussion
- **breakout-*.md** — deep dive findings (one per sub-problem)
- **plan.md** — the deliverable: ASCII slides, implementation steps, decisions

The **plan.md** always includes:
- Non-goals (what we're NOT doing, and why)
- Success criteria (measurable)
- CIU estimates (effort, not time)
- Risk matrix

---

## Returning to a Topic

When you run `/storytime <topic>` on a topic that already has a thread,
you get a warm start:

```
/storytime agc
```

Storytime reads the thread state, decision log, persona histories, and
git delta, then synthesizes a narrative recap. You pick:

- **Continue** — resume where you left off or start a new episode
- **Retro** — compare plan vs what was built
- **New sub-topic** — focused episode within the same topic
- **Reset** — archive everything, fresh start

### Parking Mid-Session

Say "park it here" at any phase boundary. Storytime checkpoints the
thread and exits. Next invocation picks up at the parked phase.

---

## Skill Reference

### `/storytime <problem-statement>`

The main workflow. Use for any feature, architecture decision, or
investigation that needs a structured plan.

```
/storytime "we need rate limiting on the public API"
/storytime "the auth middleware stores session tokens in a way that doesn't meet compliance"
/storytime "should we migrate from REST to gRPC for internal services?"
```

### `/storytime-breakout <sub-problem>`

Focused investigation without the full pipeline. Use when you already
have a team and context but need a deep dive on one thing.

```
/storytime-breakout "is Redis or Memcached better for our session cache?"
/storytime-breakout "what are the failure modes of the current retry logic?"
```

### `/storytime-qa @persona <question>`

Query a persona about past decisions or current code state.

```
/storytime-qa @kim should we use the same env-var pattern for Opus?
/storytime-qa @team does our AGC decision still hold after the resample change?
```

### `/storytime-retro <topic>`

Reconvene the original team to compare outcomes against the plan.

```
/storytime-retro agc
```

### `/storytime-pr-qa <pr-number>`

Load PR comments and have the team formulate responses. Useful when
reviewers challenge decisions that storytime already discussed.

```
/storytime-pr-qa 42
/storytime-pr-qa https://github.com/org/repo/pull/42
```

### `/storytime-cohort <action>`

Manage personas. The cohort persists across sessions.

```
/storytime-cohort list              # show active roster
/storytime-cohort hire raj domain-dsp "Audio DSP, 10yr embedded"
/storytime-cohort bench dana        # temporarily inactive
/storytime-cohort evolve kim "now knows Opus internals"
/storytime-cohort promote raj       # specialist → permanent
/storytime-cohort fire old-persona  # remove from roster
```

### `/storytime-survey`

Standalone codebase survey with artifact inventory and coverage fingerprint.
Use when you want to understand a repo without running a full session.

```
/storytime-survey
```

### `/storytime-status`

Dashboard showing cohort state, active threads, recent sessions,
pending specialist contracts, and stale citations.

```
/storytime-status
```

### `/storytime-bootstrap`

Initialize the `.storytime/` structure in a repo. Chooses between
storytime-native, adapt-in-place, or export-only modes.

```
/storytime-bootstrap
```

### `/storytime-consolidate`

Organize documents: archive stale specs, roll up related docs, backfill
missing timestamps, move artifacts into storytime structure.

```
/storytime-consolidate
```

### `/storytime-absorb`

Have the team read, interpret, and discuss existing documents or code.
Builds shared understanding without producing a plan.

```
/storytime-absorb docs/old-architecture.md
```

### `/storytime-export`

Transform storytime output into other formats: ADRs, GitHub issues,
Linear tickets, Kiro specs.

```
/storytime-export agc --format=adr
/storytime-export agc --format=github-issues
```

### `/storytime-undo`

Revert storytime output at any granularity.

```
/storytime-undo last step          # undo most recent phase
/storytime-undo last episode       # undo entire episode
/storytime-undo entirely           # archive whole thread
/storytime-undo the breakout       # remove specific file
```

---

## Configuration

Project-level settings in `specs/.storytime/config.md`:

```yaml
default_mode: inline          # inline | deliberation
automation: guided            # manual | guided | auto
max_team_size: 7
max_concurrent_breakouts: 3
require_operator: true
require_nongoals: true
visual_style: ascii
citation_format: "file:line — snippet"
auto_update_personas: true
```

### Automation Gradient

| Level | Phase transitions | Breakouts | Team assembly | Review |
|-------|-------------------|-----------|---------------|--------|
| manual | user approves each | user approves | user approves | inline |
| guided | automatic | automatic | user approves | inline |
| auto | automatic | automatic | automatic | present-only |

---

## Effort Estimation

Storytime uses **CIU** (Complexity Integration Units) and **Scale**
instead of time estimates.

| CIU | Complexity | Human analog |
|-----|-----------|-------------|
| 1 | Single-file, single-concept | Quick fix |
| 2 | Few files, one system | Straightforward task |
| 3 | Multiple files, one system | A morning's work |
| 5 | Cross-system, multiple owners | Solid day of work |
| 8 | Architectural, multi-system | Multi-day effort |
| 13 | Foundational change | Sprint-sized (MUST decompose) |

**Scale** (1-5) measures blast radius, not complexity:
- 1 (file) — a single file
- 2 (module/repo) — a module or repo
- 3 (service cluster) — touches a service cluster
- 4 (users) — affects users directly
- 5 (ecosystem) — crosses organizational boundaries

---

## Validation Scripts

```bash
# Check for stale code citations in storytime output
./scripts/validate-citations.sh specs/.storytime/sessions/agc/

# Verify breakout output completeness
./scripts/validate-breakouts.sh specs/.storytime/sessions/agc/001/

# Export decision log as JSON
./scripts/export-decisions.sh specs/.storytime/history/decisions.md

# Bump storytime version across all files
./scripts/bump-version.sh 0.3.0
```

---

## Tips

**Be specific in your problem statement.** "Add caching" gives the team
nothing to work with. "API /users endpoint hits Postgres on every call,
p95 latency is 800ms, need a cache layer that respects auth tokens" sets
up a productive session.

**Challenge the team.** During REVIEW, push back on decisions. "Why not
use Redis instead?" forces the team to defend or revise with evidence.
That's the point.

**Use breakouts for focused questions.** Don't run the full pipeline when
you just need one investigation. `/storytime-breakout` is faster and
produces a focused recommendation.

**Park when you need to think.** Say "park it here" at any phase boundary.
The thread checkpoints and you can resume later with full context.

**Check status regularly.** `/storytime-status` shows you everything:
active threads, pending decisions, stale citations, persona state.

**Trust the warm start.** When you come back to a topic, the "previously
on..." preamble is dynamically synthesized from the current state. It's
never stale. Let it catch you up.

---

## Further Reading

- [PRIMER.md](PRIMER.md) — What storytime is and why it exists
- [docs/process-reference.md](docs/process-reference.md) — Full reference: 41 rules, all events, all skills
- [docs/architecture.md](docs/architecture.md) — How storytime maps to Claude Code agents
- [docs/comparisons.md](docs/comparisons.md) — vs Speckit, Kiro, OpenSpec, ADRs
- [examples/agc-session.md](examples/agc-session.md) — Real walkthrough of an AGC session
- [examples/persona-template.md](examples/persona-template.md) — Template for creating personas
