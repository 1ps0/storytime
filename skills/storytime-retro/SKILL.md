---
name: storytime-retro
description: "This skill should be used when the user asks to \"retro on\", \"retrospective\", \"how did it go\", \"review the spec\", \"what happened vs the plan\", or wants to evaluate outcomes against a completed Storytime spec. Reconvenes the original team to review what was planned vs what was built."
argument-hint: "<topic> (e.g., agc, opus-negotiation)"
allowed-tools: [Read, Glob, Grep, Bash, Agent]
---

# Storytime Retrospective

Run a retrospective on a completed Storytime spec by reconvening
the original team and comparing outcomes against the plan.

## Arguments

The topic to retrospect: $ARGUMENTS

## Process

1. **Load the original spec**:
   - Read `specs/<topic>/team.md` — the original team
   - Read `specs/<topic>/plan.md` — what was planned
   - Read `specs/<topic>/icebreaker.md` — original constraints
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
5. **Update artifacts**:
   - Add a chapter to `specs/<topic>/changelog.md`
   - Update persona files with lessons learned
   - Flag any non-goals that should now become goals

## Output

Write `specs/<topic>/retrospective.md` with the team's analysis.
Update persona files and decision log.
