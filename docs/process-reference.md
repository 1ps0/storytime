# Storytime Process Reference

Complete reference for events, skills, rules, and file formats.

---

## Events

| Event       | Participants    | Input              | Output             | Parallelizable |
|-------------|-----------------|--------------------|--------------------|----------------|
| SURVEY      | (system + user) | problem + codebase | survey.md + fingerprint | no        |
| ASSEMBLE    | (system + user) | context + archetypes| team.md           | no             |
| ICEBREAKER  | full team       | context + team     | icebreaker.md      | no             |
| BREAKOUT    | sub-team (2-3)  | sub-question       | breakout-N.md      | **yes**        |
| CONVERGE    | full team       | all breakouts      | plan.md            | no             |
| DELIBERATE  | full team       | topic + constraints| deliberation round | no             |
| REVIEW      | user + team     | plan.md            | feedback/revisions | no             |
| RETROSPECT  | full team       | plan + actuals     | retrospective.md   | no             |
| QA          | user + persona  | question           | answer w/ citations| no             |

## Event Transitions

```
START → SURVEY → ASSEMBLE → ICEBREAKER → {BREAKOUT×N | DELIBERATE} → CONVERGE → REVIEW → DONE
                                                                                    ↑      │
                                                                                    └──────┘
                                                                                   (revisions)
Post-delivery: QA (anytime), RETROSPECT (after implementation)
```

## Skills (Available to Personas Mid-Conversation)

| Skill        | Backing          | Speed   | Blocks? | Use case                    |
|--------------|------------------|---------|---------|-----------------------------|
| explore_code | Agent(Explore)   | slow    | optional| Map dependencies, find code |
| web_search   | WebSearch        | medium  | optional| Look up RFCs, docs, papers  |
| web_fetch    | WebFetch         | medium  | optional| Pull specific page content  |
| read_file    | Read             | fast    | inline  | Verify a specific line      |
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
| VERIFY            | Grep + Read   | Confirmed/corrected     | Need to check a claim       |
| SUB-DELIBERATION  | general       | Analysis + recommendation| Complex sub-problem        |

## Process Rules

1. SURVEY before ASSEMBLE
2. ICEBREAKER before BREAKOUT or CONVERGE
3. CONVERGE before REVIEW
4. Phases collapse when empty — never present ceremony for absent content
5. Minimum 3 personas, maximum 7
6. At least one OPERATOR archetype (always)
7. Permanent cohort participates by default
8. User can fire, bench, or recruit at any time
9. Every technical claim must be verifiable (cite or VERIFY)
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
22. Effort uses CIU (Complexity Integration Units), never time estimates
23. Rollups replace stale docs — originals go cold, rollup stays warm
24. Archive artifacts must be git-committable and repo-local

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

### Spec Files
```
specs/<topic>/
  survey.md                 (codebase context + artifact inventory + fingerprint)
  team.md
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

## Complexity Integration Units (CIU)

Effort measurement for all scoped work — breakouts, roadmap items,
success criteria, specialist contracts.

| CIU | Complexity                    | Human Analog            |
|-----|-------------------------------|-------------------------|
| 1   | Single-file, single-concept   | Quick fix               |
| 2   | Few files, one system         | Straightforward task    |
| 3   | Multiple files, one system    | A morning's work        |
| 5   | Cross-system, multiple owners | Solid day of work       |
| 8   | Architectural, multi-system   | Multi-day effort        |
| 13  | Foundational change           | Sprint-sized (MUST decompose) |
| 21+ | Rewrite / new system          | Epic (MUST decompose)   |

Rules: Always pair CIU with the human analog. CIU ≥ 13 must be
broken into sub-items ≤ 5. Persona disagreement on CIU is signal.

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

| Level  | Phase transitions | Breakouts | Team assembly | Review |
|--------|-------------------|-----------|---------------|--------|
| manual | user approves each| user approves | user approves | inline |
| guided | automatic         | automatic | user approves | inline |
| auto   | automatic         | automatic | automatic     | present-only |

## Configuration (`specs/.storytime/config.md`)

```yaml
default_mode: inline          # inline | deliberation
automation: guided            # manual | guided | auto
max_team_size: 7
max_concurrent_breakouts: 3
max_deliberation_rounds: 3
require_operator: true
require_nongoals: true
visual_style: ascii
citation_format: "file:line — snippet"
auto_update_personas: true
```
