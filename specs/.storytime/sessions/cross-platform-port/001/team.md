---
type: team
schema_version: 1
session: cross-platform-port
episode: 001
created: 2026-04-26T14:05
size: 9
rationale: foundational architectural scope (cross-platform refactor + first new harness adapter); team-size table recommends 8-10 for "foundational, broad blast radius"
---

# Team — cross-platform-port / 001

9 personas. Cohort rehires + 2 specialists for the OpenCode-specific
work + standard architectural critics.

## Codename → cohort file mapping

| Codename | Archetype/focus | Cohort file |
|---|---|---|
| @owner [anchor]   | framework architect          | cohort/anchor-owner-architect.md |
| @operator [tide]  | plugin reliability           | cohort/tide-operator-reliability.md |
| @domain [arbor]   | info architecture            | cohort/arbor-domain-infoarch.md |
| @skeptic [drift]  | devex skeptic                | cohort/drift-skeptic-devex.md |
| @platform [compass]| AI-human interaction        | cohort/compass-platform-interaction.md |
| @critic [forge]   | architecture critic          | specialist (re-recruited from v1-consolidation) |
| @critic [lattice] | performance/cost critic      | specialist (re-recruited from v1-consolidation) |
| @educator [beacon]| migration & onboarding       | specialist (re-recruited from v1-consolidation) |
| @systems [opcode] | OpenCode runtime specialist  | specialist (NEW for this session) |

## Rehires from cohort (5)

```
┌──────────────────────────────────────────────────────────────────┐
│  @owner [anchor] — Framework Architect                           │
│  Drives the v1.1 vs v2.0 versioning + repo-shape decisions.      │
│  Owns the soul-priorities ratification.                          │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @operator [tide] — Plugin Reliability                           │
│  Refactor without breaking v1.0.1 Claude Code installs.          │
│  Atomic moves, kill switches, rollback story.                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @domain [arbor] — Information Architecture                      │
│  core/ vs adapters/ vs shared/ shape. Path conventions across    │
│  harnesses. Ownership of cross-references in markdown.           │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @skeptic [drift] — Developer Experience Skeptic                 │
│  "Do we really need to do this now?" Pressures scope discipline. │
│  Earns-its-keep test on every adapter feature.                   │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @platform [compass] — AI-Human Interaction                      │
│  UX of `@role` lens directives across harnesses. Adoption story  │
│  for OpenCode users.                                             │
└──────────────────────────────────────────────────────────────────┘
```

## Specialists (re-recruited from v1-consolidation)

```
┌──────────────────────────────────────────────────────────────────┐
│  @critic [forge] — Architecture Critic                           │
│  Re-recruited: cross-platform abstractions are exactly the kind  │
│  of architecture call where forge proved durable last session.   │
│  Focus: what breaks in the abstraction; what we lose vs gain.    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @critic [lattice] — Performance/Cost Critic                     │
│  Re-recruited: contests forge on cost grounds.                   │
│  Focus: per-tool-call overhead, token cost of persona runtime,   │
│  startup cost of plugin load.                                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @educator [beacon] — Migration & Adoption                       │
│  Re-recruited: this is a breaking-change-shaped operation.       │
│  Focus: npm publish flow, install guide, first-time-user docs.   │
└──────────────────────────────────────────────────────────────────┘
```

## Specialist (new for this session)

```
┌──────────────────────────────────────────────────────────────────┐
│  @systems [opcode] — OpenCode Runtime Specialist                 │
│  Recruited: needs deep OpenCode-specific knowledge (Effect/Zod   │
│  tools, plugin function signature, hook system, SQLite session   │
│  model, compaction template). Lives in opencode/packages/.       │
│  Contract: release at DONE; promote if cross-harness work        │
│  becomes ongoing.                                                │
└──────────────────────────────────────────────────────────────────┘
```

## Drivers per phase

| Phase / breakout | Driver | Rationale |
|---|---|---|
| SURVEY (collapsed) | @owner [anchor] | Already done |
| ASSEMBLE | @owner [anchor] | Composition is architect's call |
| ICEBREAKER | @owner [anchor] | Frames status quo |
| BO1 — version (v1.1 vs v2.0) | @owner [anchor] | Versioning is architect's call |
| BO2 — repo strategy (single vs multi) | @domain [arbor] | IA decision |
| BO3 — MVP soul-elements | @owner [anchor] | What ships day-one |
| BO4 — persona runtime in TS | @systems [opcode] | OpenCode-specific design |
| BO5 — npm distribution | @educator [beacon] | Adoption surface |
| BO6 — Claude Code adapter migration | @operator [tide] | Reliability-critical: must not break v1.0.1 |
| CONVERGE | @owner [anchor] | Plan synthesis |
| REVIEW | @owner [anchor] | Present to user |
