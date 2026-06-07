---
type: survey
schema_version: 1
session: cross-platform-port
episode: 001
created: 2026-04-26T14:00
---

# Survey — cross-platform-port / 001

## Mode

Collapsed. Proposal at `docs/proposals/cross-platform-storytime.md` is
the prior art (just shipped at `a95bfde`). OpenCode codebase cloned
locally at `opencode/` (gitignored). Storytime codebase is loaded from
this conversation.

## Coverage fingerprint

```yaml
commit: a95bfde8fd9a2d96ff28b38379fb549348ebdd10
branch: main
paths_scanned:
  - docs/proposals/cross-platform-storytime.md  # the input
  - opencode/packages/{plugin,core,opencode,sdk,llm,docs}/  # via prior research agent
  - skills/storytime/SKILL.md  # main storytime SKILL
  - skills/storytime/references/*.md  # all references
  - .claude-plugin/plugin.json  # current Claude Code manifest
paths_unvisited:
  - opencode/packages/extensions/  # not yet inspected
  - opencode/packages/desktop/, console/, etc.  # adapter-irrelevant
coverage_ratio: ~75%  # high because proposal already digested both sides
```

## Prior art summary

- **Proposal** (`docs/proposals/cross-platform-storytime.md`) — 364 lines
  defining: soul priorities (10 items), OpenCode paradigm-extension
  specifics, mapping table per concept, phased plan (M / I / II / III /
  IV / V), six open questions.
- **Architecture brief** (from prior research agent against `opencode/`)
  — full plugin/hook/agent/tool/session-state model documented; verdict:
  moderate difficulty for naive port, but soul-first paradigm extension
  is the directed approach.
- **storytime current state** — v1.0.1 shipped with intent graph,
  user-as-role, prompt-yield. ~30 V1-NNN decisions. Main SKILL at 262
  lines. 19 skills, 3 agents, 9 scripts.

## What we're specifying

The path from current Claude-Code-only storytime to a cross-platform
core+adapters layout, with first OpenCode adapter as paradigm extension.
v1.1 or v2.0 effort — version question itself is a breakout.

## Status quo to challenge in ICEBREAKER

- Six open questions from the proposal need resolution
- The "soul" priorities need ratification (are all 10 must-haves, or do
  some defer?)
- The persona runtime design in TS is the largest unknown
- Distribution model (npm package?) affects everything downstream
