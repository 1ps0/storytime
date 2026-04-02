---
name: storytime-converge
description: "This skill should be used when the user asks to \"converge\", \"merge the breakouts\", \"build the plan\", \"synthesize findings\", \"make the plan\", or wants to take existing breakout results and produce a unified plan. Standalone convergence — takes breakout findings and produces a plan.md."
argument-hint: "<topic> (e.g., agc, caching)"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent]
---

<!-- version-echo: display "storytime v0.5.0" at start of execution -->
# Storytime Converge — Standalone Plan Synthesis

Take existing breakout results and produce a unified plan. Use this when
breakouts were run independently (via `/storytime-breakout` or background
agents) and need to be merged into a coherent plan.

## Arguments

The topic to converge: $ARGUMENTS

## Process

### 1. Locate Breakout Results

Search for breakout files:
- `specs/.storytime/sessions/<topic>/<episode>/breakout-*.md`
- `specs/<topic>/breakout-*.md`
- Or wherever the user indicates

Read each breakout file. Extract:
- Subtopic and question
- Findings and citations
- Recommendation
- Confidence level
- Complexity and Scale estimates
- Participating personas
- Open questions

If any breakout has `status: incomplete`, flag it for the user before
proceeding.

### 2. Load Team Context

- Read the team file (`team.md`) for this topic
- Load persona files for all participants across breakouts
- Read the icebreaker if it exists (for original constraints and context)
- Read any prior plan for this topic (to detect what's being updated)

### 3. Present Breakout Summary

Before synthesizing, present the recommendation summary to the user:

```
Converging breakouts for: <topic>

1. [subtopic-a] <recommendation summary>
   Confidence: high | Complexity 3 | <personas>

2. [subtopic-b] <recommendation summary>
   Confidence: medium | Complexity 5 | <personas>

Conflicts: <any where breakout recommendations contradict>
Open questions: <aggregated from all breakouts>

Proceed with convergence? [y / adjust / add context]
```

The user can adjust scope or add context before convergence runs.

### 4. Reconvene the Full Team

All personas from all breakouts participate. The convergence discussion:

- **Merge findings** — combine breakout results into a unified view
- **Resolve conflicts** — if breakouts contradict, the team debates and
  decides. The user can weigh in.
- **Identify gaps** — are there sub-problems the breakouts missed?
- **Sequence the work** — order implementation steps considering dependencies
- **Assign Complexity + Scale** to each plan item

### 5. Write the Plan

**Write `specs/.storytime/sessions/<topic>/<episode>/plan.md`** with:
- ASCII slide deck (use box-drawing for slides)
- Problem visualization
- Solution architecture diagram
- Implementation steps (numbered, sequential, with breakout cross-references)
- Code changes summary (files touched, lines added)
- Risk matrix
- Non-goals section (REQUIRED — each with "why skip" + "when to revisit")
- Success criteria (REQUIRED — measurable)
- Roadmap sketch (now / soon / later) with Complexity and Scale per item

Each plan item should reference which breakout(s) informed it:
```
3. Add Redis cache layer (from breakout-caching.md)
   Complexity 3 — a morning's work | Scale 2 (module)
```

### 6. Present for Approval

Show the plan to the user. Enter inline mode for review — same as the
REVIEW phase in the full workflow.

## When to Use This

- Breakouts were run independently (via `/storytime-breakout`) at different
  times and need to be combined
- A full storytime run was parked after breakouts and you want to resume
  at convergence without re-running everything
- You want to re-converge with different constraints after a plan was
  already produced (undo the plan, re-converge)
- Breakout results from different sessions need to be synthesized

## Rules

1. All breakouts must be read before convergence starts.
2. Incomplete breakouts are flagged, not silently skipped.
3. Conflicts between breakouts are surfaced and resolved, not papered over.
4. The plan must reference which breakout informed each item.
5. Non-goals and success criteria are required. Always.
6. Complexity and Scale on every plan item. Always with prose.
