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

Post-delivery: QA (anytime), RETROSPECT (after implementation)
Thread checkpoint: _thread.md updated at every phase boundary
Standalone: CONVERGE can be invoked independently via /storytime-converge
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

## Process Rules

1. SURVEY before ASSEMBLE
2. ICEBREAKER before BREAKOUT or CONVERGE
3. CONVERGE before REVIEW
4. Phases collapse when empty — never present ceremony for absent content
5. Minimum 3 personas, maximum 12
6. At least one OPERATOR archetype (always)
7. Permanent cohort participates by default
8. User can fire, bench, or recruit at any time
9. Every technical claim must be grounded (code, docs, web, or git citation)
10. Breakout findings override prior assumptions
11. Prototypes are disposable (illustration, not production)
12. Every plan has non-goals (required)
13. Every plan has success criteria (measurable)
14. Every plan has visual aids (ASCII, inline)
15. Every document after chapter 1 opens with "Previously"
16. Persona files updated after every session
17. Decision log is append-only
18. Specialist contracts have explicit exit conditions
19. Every phase writes its output — a run is a complete snapshot
20. Prior runs are prior art — detect and present, never silently overwrite
21. Every survey writes a coverage fingerprint (commit, paths, gaps, ratios)
22. Effort uses Complexity , never time estimates
23. Rollups replace stale docs — originals go cold, rollup stays warm
24. Archive artifacts must be git-committable and repo-local
25. All storytime output lives under specs/.storytime/ — single root
26. Bias toward consolidating external artifacts into .storytime via git mv
27. Universal frontmatter on every document: type, created, session
28. Semantic events get explicit timestamps; file edits rely on git
29. Inferred timestamps marked with confidence (git-derived, approximate, estimated)
30. Scale Impact (1-5) alongside Complexity for magnitude — dimension stated in prose
31. Evaluation hygiene: observe metrics and conclusions separately, don't conflate
32. Warm start is detected, not requested — if `_thread.md` exists, warm-start
33. Preamble narrative is always dynamic — synthesized fresh, never cached
34. Personas skip introductions on warm start — speak from accumulated context
35. Thread auto-checkpoints at every phase boundary — created at first phase, no explicit save
36. Episodes are chapters, not restarts — Reset is the explicit "new story" action
37. Survey delta replaces full survey on warm start — only resurvey what changed
38. Standalone breakouts are valid — not every investigation needs the full pipeline
39. Always confirm before destructive undo — show impact inventory first
40. Prefer archive over delete — cold storage is recoverable, deletion relies on git
41. Redo is undo + immediate retry — don't make the user invoke two commands
42. Post-breakout pause is mandatory (unless auto) — present summaries, wait for user
43. Converge can run standalone — breakout results as input, plan as output
44. Personas use `@role` by default in all output — roles are functional anchors,
    names are ornaments. Qualified with focus: `@critic:architecture`. Configurable.

## File Naming Conventions

### Persona Files
```
<name>-<archetype>-<specialty>.md

Examples:
  kim-owner-architect.md
  dana-systems-voip.md
  leo-operator-sre.md
  raj-domain-dsp.md
  mira-platform-asr.md
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

## Automation Levels

| Level  | Phase transitions | Breakouts | Post-breakout | Team assembly | Review |
|--------|-------------------|-----------|---------------|---------------|--------|
| manual | user approves each| user approves | pause + summary | user approves | inline |
| guided | automatic         | automatic | pause + summary | user approves | inline |
| auto   | automatic         | automatic | auto-proceed    | automatic     | present-only |

## Configuration (`specs/.storytime/config.md`)

```yaml
default_mode: inline          # inline | deliberation
automation: guided            # manual | guided | auto
max_team_size: 12
max_concurrent_breakouts: 10
max_deliberation_rounds: 3
require_operator: true
require_nongoals: true
visual_style: ascii
citation_format: "file:line — snippet"
persona_voice: name            # name | role | both
auto_update_personas: true
```
