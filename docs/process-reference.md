# Storytime Process Reference

Complete reference for events, skills, rules, and file formats.

---

## Events

| Event       | Participants    | Input              | Output             | Parallelizable |
|-------------|-----------------|--------------------|--------------------|----------------|
| SURVEY      | (system)        | problem + codebase | context summary    | no             |
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
4. No event may be skipped
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
