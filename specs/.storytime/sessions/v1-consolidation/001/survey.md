---
type: survey
created: 2026-04-13T11:00
schema_version: 1
session: v1-consolidation
episode: 001
---

# Survey — v1-consolidation / 001

## Mode

Collapsed. Codebase context is already loaded from the current
orchestrator conversation. Proposal at `docs/proposals/v1-consolidation.md`
is the primary prior-art artifact. Full codebase scan would be redundant.

## Coverage fingerprint

```yaml
commit: c2df6c107026ee6b5d58a3729c09abb402a3102d
branch: main
paths_scanned:
  - skills/storytime/SKILL.md (410 lines)
  - skills/storytime/references/*.md (16 files, 2284 lines)
  - skills/storytime-*/SKILL.md (17 skills)
  - scripts/bump-version.sh, scripts/check-conventions.sh
  - agents/estimator.md, agents/breakout-runner.md
  - docs/proposals/v1-consolidation.md (primary input)
  - specs/.storytime/config.md
paths_unvisited:
  - specs/.storytime/cohort/* (roster; will load at ASSEMBLE)
  - specs/.storytime/archive/* (not relevant to this spec)
  - site/* (docs surface; touched in v0.9 bump)
coverage_ratio: ~85%  # high because we're specifying what we built
artifact_counts:
  team: 0 (prior cohort in specs/.storytime/cohort/)
  spec: 1 (the proposal)
  config: 2 (config.md, plugin.json)
```

## Artifact disposition

- **`docs/proposals/v1-consolidation.md`** — primary icebreaker input.
  13 resolved decisions (V1-001..V1-013), 5 remaining open questions,
  full transformation map with Fibonacci T-scale.
- **Existing cohort** (`specs/.storytime/cohort/_roster.md` if present)
  — will be loaded at ASSEMBLE as rehire candidates. Permanent personas
  from prior work should rejoin if their domains fit.
- **Existing references** (`skills/storytime/references/*`) — these are
  the *current* architecture. Breakouts will touch many of them during
  the CONVERGE phase. No consolidation needed now; they'll be updated
  per the plan.
- **v0.9.0 version strings everywhere** — no stale versions found
  (confirmed by `scripts/check-conventions.sh`).

## What we are specifying

A v1.0 release that restructures storytime around **consolidation as
the primary loop**. The spec workflow becomes one surface on a deeper
continuity mechanism. Existing primitives get absorbed, renamed, or
removed per the T-scale in the proposal. Scope is foundational —
Fibonacci Complexity 13+ for the overall effort, decomposed into
MVP slice + full adaptation.

## Status quo to challenge in ICEBREAKER

- Current main SKILL is 410 lines (post-v0.9 refactor). Target 280.
- Warm-start preamble is synthesized reactively per `references/warm-start.md`.
  Under v1.0 it's replaced by pre-staged remembrance.md (T=21).
- Phase-boundary digests are ad-hoc across skills. v1.0 unifies them.
- Decisions live in `history/decisions.md` separate from threads. v1.0
  merges them into threads (V1-003).
- There is no hook for `post-commit`, no hook for `/compact`. Both are
  entirely new in v1.0.
