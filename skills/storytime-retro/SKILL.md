---
name: storytime-retro
description: "This skill should be used when the user asks to \"retro on\", \"retrospective\", \"how did it go\", \"review the spec\", \"what happened vs the plan\", or wants to evaluate outcomes against a completed Storytime spec. Reconvenes the original team to review what was planned vs what was built."
argument-hint: "<topic> (e.g., agc, opus-negotiation)"
allowed-tools: [Read, Glob, Grep, Bash, Agent]
---

<!-- version-echo: display "storytime v0.3.0" at start of execution -->
# Storytime Retrospective

Run a retrospective on a completed Storytime spec by reconvening
the original team and comparing outcomes against the plan.

## Arguments

The topic to retrospect: $ARGUMENTS

## Process

1. **Load the original spec**:
   - Read `specs/.storytime/sessions/<topic>/team.md` — the original team
   - Read `specs/.storytime/sessions/<topic>/plan.md` — what was planned
   - Read `specs/.storytime/sessions/<topic>/icebreaker.md` — original constraints
2. **Survey current state**:
   - Launch Explore agent to check what was actually implemented
   - Compare implementation against the plan's success criteria
   - Check if non-goals are still valid or need revisiting
3. **Load personas**:
   - Reconvene the original team (from cohort + specialist files)
   - Each persona evaluates from their domain perspective
4. **Run the retrospective conversation**:
   - What went as planned?
   - What diverged and why?
   - What did we learn?
   - What should change for next time?
5. **Timestamp audit**:
   - Check all session documents for universal frontmatter (`type`, `created`, `session`)
   - If timestamps are missing (common for pre-timestamp-principle docs),
     backfill from git history and filesystem evidence
   - Mark inferred timestamps with confidence level (git-derived, approximate, estimated)
   - See `${CLAUDE_PLUGIN_ROOT}/docs/timestamps.md` for backfill rules
   - Review `last_reviewed` on any decisions from this session — update if still valid
6. **Update artifacts**:
   - Add a chapter to `specs/.storytime/sessions/<topic>/changelog.md`
   - Update persona files with lessons learned (include `evolved[]` entry with date)
   - Update persona `last_active` dates
   - Flag any non-goals that should now become goals
   - Update decision `last_reviewed` dates for decisions confirmed during retro

## Output

Write `specs/.storytime/sessions/<topic>/retrospective.md` with the team's analysis.
Include universal frontmatter (`type: retrospective`, `created`, `session`).
Update persona files and decision log.
