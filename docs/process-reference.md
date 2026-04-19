---
type: reference
created: 2026-03-28T02:04
session: null
---

# Storytime Process Reference

Complete reference for events, skills, rules, and file formats.

---

## Events

| Event       | Participants    | Input              | Output             | Parallelizable |
|-------------|-----------------|--------------------|--------------------|----------------|
| ROUTE       | (system)        | topic + _thread.md | cold start or warm start | no       |
| WARM_START  | (system + user) | thread + artifacts | preamble.md + routing  | no         |
| SURVEY      | (system + user) | problem + codebase | survey.md + fingerprint | no        |
| ASSEMBLE    | (system + user) | context + archetypes| team.md           | no             |
| ICEBREAKER  | full team       | context + team     | icebreaker.md      | no             |
| BREAKOUT    | sub-team (2-3)  | sub-question       | breakout-N.md      | **yes**        |
| POST-BREAK  | (system + user) | breakout results   | user direction     | no             |
| CONVERGE    | full team       | all breakouts      | plan.md            | no / standalone|
| DELIBERATE  | full team       | topic + constraints| deliberation round | no             |
| REVIEW      | user + team     | plan.md            | feedback/revisions | no             |
| RETROSPECT  | full team       | plan + actuals     | retrospective.md   | no             |
| QA          | user + persona  | question           | answer w/ citations| no             |
| BUILDOUT    | sub-team (2-3)  | plan item + code   | code + buildout.md | **yes** (slices)|
| BREAKOUT(s) | sub-team (2-3)  | sub-problem        | breakout.md        | standalone     |
| UNDO        | (system + user) | scope + confirm    | reverted state     | no             |

## Event Transitions

```
START → ROUTE ─┬─ cold start ─→ SURVEY → ASSEMBLE → ICEBREAKER ─→ {BREAKOUT×N | DELIBERATE}
               │                                                          │
               │                                                          ▼
               │                                                   POST-BREAKOUT PAUSE
               │                                                   (user reviews summaries)
               │                                                          │
               │                                                          ▼
               │                                                   CONVERGE → REVIEW → DONE
               │                                                               ↑      │
               │                                                               └──────┘
               │                                                              (revisions)
               │
               └─ warm start ─→ WARM_START → [SURVEY-DELTA] → ICEBREAKER ─→ ...same as above
                                    │
                                    ├─ Continue (resume at incomplete phase or new episode)
                                    ├─ Retro → RETROSPECT
                                    ├─ New sub-topic → ICEBREAKER (scoped)
                                    └─ Reset → archive thread → cold start

Post-plan: BUILDOUT (persona-driven implementation with trace docs)
Post-delivery: QA (anytime), RETROSPECT (after implementation)
Thread checkpoint: _thread.md updated at every phase boundary
Standalone: CONVERGE via /storytime-converge, BUILDOUT via /storytime-buildout
```

## Skills (Available to Personas Mid-Conversation)

| Skill        | Backing          | Speed   | Blocks? | Use case                    |
|--------------|------------------|---------|---------|-----------------------------|
| explore_code | Agent(Explore)   | slow    | optional| Map dependencies, find code |
| web_search   | WebSearch        | medium  | optional| Look up RFCs, docs, papers  |
| web_fetch    | WebFetch         | medium  | optional| Pull specific page content  |
| read_file    | Read             | fast    | inline  | Verify a specific line      |
| read_doc     | Read             | fast    | inline  | Check repo docs, ADRs, specs|
| grep_code    | Grep             | fast    | inline  | Find callers, patterns      |
| prototype    | Agent + Write    | slow    | blocking| Sketch implementation       |
| benchmark    | Agent + Bash     | slow    | blocking| Measure performance         |
| discover     | Agent(Explore)   | slow    | optional| Comprehensive code survey   |
| cite_check   | Grep + Read      | fast    | inline  | Verify citation still valid |

## Breakout Types

| Type              | Agents        | Returns                 | When                        |
|-------------------|---------------|-------------------------|-----------------------------|
| RESEARCH          | WebSearch     | Findings + URLs         | Need external info          |
| DISCOVERY         | Explore       | Code map + deps         | Need to understand code     |
| PROTOTYPE         | general + Write| Draft code + explanation| Need to sketch a solution   |
| BENCHMARK         | general + Bash| Timing + analysis       | Need performance data       |
| VERIFY            | Grep + Read   | Confirmed/corrected     | Need to check a code claim  |
| GROUND            | Read          | Confirmed/corrected     | Need to check a doc claim   |
| SUB-DELIBERATION  | general       | Analysis + recommendation| Complex sub-problem        |

## Process Rules (29, v1.0.0)

1. SURVEY before ASSEMBLE. Never build a team blind.
2. ICEBREAKER before BREAKOUT. Shared understanding first.
3. CONVERGE before showing the user. Internal consensus first.
4. Every claim grounded — code, docs, web, or git.
5. Default core: OWNER, OPERATOR, CRITIC ×2 (two critics contest).
6. Non-goals + success criteria required on every plan.
7. Visuals use ASCII box-drawing. No external tools.
8. Personas are lenses, not characters. No role-play.
9. Team size project-appropriate. Bias small. Ceiling 12.
10. User has veto power everywhere.
11. Phases collapse when empty.
12. Every phase writes output — run is a complete snapshot.
13. Prior runs are prior art — never silently overwrite.
14. Survey writes a coverage fingerprint.
15. Effort = Complexity + Scale (never time). ≥13 decomposes.
16. Evaluation hygiene: observe metrics and conclusions separately.
17. Warm entry detected, not requested. If thread exists, warm.
18. Remembrance is pre-staged (at pause/compact), never reactive.
19. Post-breakout pause mandatory unless auto. Present options considered.
20. Grounding multi-source: code > git > repo > library > standards > web.
21. `@role` is a lens directive, not a skill trigger.
22. Codenames non-human by default.
23. **One driving persona per leg.** Supporters silent unless useful AND non-distortive.
24. LLM drafts every commit. User confirms every one. No auto-commit.
25. Pauses are model-driven, not threshold-driven (threshold is opt-in fallback).
26. All consolidation writes atomic (tmp+fsync+mv).
27. Cross-topic decisions use callouts (`Callout->` / `Callout<-`), not merging.
28. Thread IS decision log — per-topic, append-only, commit-pinned.
29. Dreams ancillary and disablable. Never on critical path.

## File Naming Conventions

### Persona Files
```
<codename>-<archetype>-<specialty>.md

Examples:
  anchor-owner-architect.md
  lattice-systems-voip.md
  tide-operator-sre.md
  arbor-domain-dsp.md
  compass-platform-asr.md
```

### Session Output Files
```
specs/.storytime/sessions/<topic>/
  _thread.md                (episode bookmark — created at DONE)
  <NNN>/                    (episode directory — zero-padded)
    preamble.md             (warm start only — synthesized narrative)
    survey.md               (cold start — full survey + fingerprint)
    survey-delta.md         (warm start — incremental survey)
    team.md                 (cold start or team changes)
    icebreaker.md
    breakout-<subtopic>.md
    plan.md
    buildout-<slice>.md         (implementation trace — decisions to code)
    changelog.md
    retrospective.md
```

### Session Files
```
specs/.storytime/history/sessions/
  <YYYY-MM-DD>-<topic>.md

Examples:
  2026-03-24-agc.md
  2026-04-01-opus-negotiation.md
```

### Decision IDs
```
<TOPIC>-<NNN>

Examples:
  AGC-001
  OPUS-001
  RESAMPLE-003
```

## Complexity

Effort measurement for all scoped work — breakouts, roadmap items,
success criteria, specialist contracts.

| Complexity | Complexity                   | Human Analog            |
|-----|-------------------------------|-------------------------|
| 1   | Single-file, single-concept   | Quick fix               |
| 2   | Few files, one system         | Straightforward task    |
| 3   | Multiple files, one system    | A morning's work        |
| 5   | Cross-system, multiple owners | Solid day of work       |
| 8   | Architectural, multi-system   | Multi-day effort        |
| 13  | Foundational change           | Sprint-sized (MUST decompose) |
| 21+ | Rewrite / new system          | Epic (MUST decompose)   |

Rules: Always pair Complexity with the human analog. Complexity ≥ 13 must be
broken into sub-items ≤ 5. Persona disagreement on Complexity is signal.

## Survey Coverage Fingerprint

Every survey.md includes a fingerprint in its frontmatter:

```yaml
fingerprint:
  commit: <sha>
  branch: <branch>
  paths_scanned: [cmd/**, pkg/**]
  paths_skipped: [vendor/**]
  paths_unvisited: [test/**]
  files_examined: 23
  files_total: 87
  coverage_ratio: 0.26
  artifacts_found: 8
  artifacts_classified: {team: 2, spec: 4, config: 2}
```

On subsequent runs, compute the delta (commit drift + coverage gaps)
and let the user decide: resurvey stale, extend to gaps, full resurvey,
or trust prior.

## Automation Tiers (v1.0)

| Tier     | Phase transitions | Breakouts | Post-breakout | Commits | Pauses surfaced |
|----------|-------------------|-----------|---------------|---------|-----------------|
| tutorial | prompt + explain  | prompt + explain | pause + explain | full + explain | all |
| manual   | prompt + wait     | prompt + wait | pause + wait | full prompt | shift, compact |
| guided   | auto              | auto | pause + wait | full (quieter if learned) | shift, compact |
| auto     | auto              | auto | auto-proceed | full (never skipped) | shift, compact |

Commits are **never auto-approved** across any tier (V1-001).
Tutorial is the fresh-install default; graduation is adaptive and per-skill.

## Configuration (`specs/.storytime/config.md`)

```yaml
mode: native                     # native | adapt | export
default_mode: inline             # inline | deliberation
automation: tutorial             # tutorial | manual | guided | auto
team_size: project-appropriate   # bias small; sized to the work
max_team_size: 12                # hard ceiling, override required
max_concurrent_breakouts: 10
default_core: [owner, operator, critic]
naming: codename                 # non-human by default
driving_persona: required        # one driver per leg
require_nongoals: true
visual_style: ascii
citation_format: "file:line — snippet"
auto_update_personas: true

# v1.0 consolidation
pause_mode: model-introspection  # model-introspection | threshold
dreams_enabled: false            # off by default, opt-in
post_commit_hook: disabled       # opt-in
remembrance_load_on_compact: true
commit_learning: enabled         # V1-014 adaptive quieter prompts
tutorial_graduation: adaptive    # V1-013 per-skill friction detection
```
