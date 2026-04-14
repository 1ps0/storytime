---
type: team
created: 2026-04-13T11:05
schema_version: 1
session: v1-consolidation
episode: 001
size: 8
rationale: foundational architectural scope (T≥8 for most items); team-size table recommends 8-10 for "foundational, broad blast radius"
naming_note: all codenames non-human per v0.7.2 principle; grandfathered cohort members assigned codenames for this session (cohort file renames part of v1.0 migration work)
---

# Team — v1-consolidation / 001

8 personas. Upper band of team-size recommendations, justified by the
foundational scope of v1.0 (consolidation reshapes most of the framework).

All codenames are non-human (concept words). Cohort members have been
assigned codenames for this session; the underlying cohort file rename
is part of the v1.0 migration work (Breakout 6).

## Codename → cohort file mapping

| Codename    | Archetype/focus     | Cohort file (prior human name)          |
|-------------|---------------------|------------------------------------------|
| @owner [anchor]   | framework architect | cohort/reva-owner-architect.md     |
| @operator [tide]  | plugin reliability  | cohort/deshi-operator-reliability.md |
| @domain [arbor]   | info architecture   | cohort/oona-domain-infoarch.md     |
| @skeptic [drift]  | devex skeptic       | cohort/pike-skeptic-devex.md       |
| @platform [compass]| AI-human interaction | cohort/taro-platform-interaction.md |
| @critic [forge]   | architecture critic | specialist (new)                         |
| @critic [lattice] | performance critic  | specialist (new)                         |
| @educator [beacon]| migration & onboarding | specialist (new)                     |

## Rehires from cohort

```
┌──────────────────────────────────────────────────────────────────┐
│  @owner [anchor] — Framework Architect                           │
│  Role: drives the v1.0 restructuring, owns the T-scale decisions │
│  Focus: main SKILL structure, phase unification, principle       │
│         preservation                                             │
│  Will speak up on: any change that breaks an existing principle  │
│    without a clear replacement                                   │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @operator [tide] — Plugin Reliability                           │
│  Role: owns hook mechanics, failure modes, recovery paths        │
│  Focus: post-commit hooks, compact detection, pause triggers,    │
│         thread state consistency                                 │
│  Will speak up on: any new mechanism without a kill switch,      │
│    any hook that can fail silently                               │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @domain [arbor] — Spec Methodology & Information Architecture   │
│  Role: owns the unified consolidation format and thread-as-log   │
│         merge                                                    │
│  Focus: frontmatter schemas, decision log structure, callout     │
│         format for cross-topic references                        │
│  Will speak up on: any artifact shape that loses information     │
│    fidelity, any format that isn't greppable                     │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @skeptic [drift] — Developer Experience Skeptic                 │
│  Role: asks "do we need this?" at every level                    │
│  Focus: scope discipline, "minimum viable v1.0" pressure         │
│  Will speak up on: any addition that doesn't earn its keep,      │
│    any mechanism that duplicates existing capability             │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @platform [compass] — AI-Human Interaction                      │
│  Role: owns UX of commit confirmation, pause proposals, tutorial │
│         onboarding, friction-signal detection                    │
│  Focus: prompt design, adaptive learning, graduation criteria    │
│  Will speak up on: any flow that's chatty without value, any     │
│    prompt that assumes a mental model the user doesn't have      │
└──────────────────────────────────────────────────────────────────┘
```

## Specialists (v1-consolidation-scoped)

```
┌──────────────────────────────────────────────────────────────────┐
│  @critic [forge] — Architecture Critic                           │
│  Recruited: because the T-map needs adversarial review           │
│  Focus: what breaks in the transformation, what's over-engineered│
│  Contract: release at DONE or promote if pattern of contestation │
│            proves load-bearing                                   │
│  Productive tension with: @owner [anchor] (advocates change),    │
│    @critic [lattice] (different critique angle)                  │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @critic [lattice] — Performance Critic                          │
│  Recruited: two critics contest each other (process rule 5);     │
│    this lens weights cost and complexity where forge weights     │
│    shape                                                         │
│  Focus: token cost of mechanisms, latency of hooks, storage      │
│         amplification of dreams                                  │
│  Contract: release at DONE                                       │
│  Productive tension with: @critic [forge] (shape vs cost)        │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  @educator [beacon] — Migration & Onboarding                     │
│  Recruited: v1.0 has a migration story that existing v0.9.2      │
│    users need explained                                          │
│  Focus: how existing sessions/artifacts migrate to v1.0 shapes;  │
│         what the tutorial-mode onboarding looks like in practice │
│  Contract: release at DONE unless "migration" becomes a          │
│            permanent cohort concern                              │
└──────────────────────────────────────────────────────────────────┘
```

## Drivers per phase/breakout

Per the driver-per-leg rule:

| Phase         | Driver                 | Rationale                                  |
|---------------|------------------------|--------------------------------------------|
| SURVEY        | @owner [anchor]        | Already done (collapsed)                   |
| ASSEMBLE      | @owner [anchor]        | Team composition is architect's call       |
| ICEBREAKER    | @owner [anchor]        | Frames the status quo for the team         |
| BREAKOUT 1    | @platform [compass]    | Commit confirmation learning = UX problem  |
| BREAKOUT 2    | @operator [tide]       | Pause detection = mechanics problem        |
| BREAKOUT 3    | @domain [arbor]        | Callout format = info architecture problem |
| BREAKOUT 4    | @domain [arbor]        | Decisions index = info architecture        |
| BREAKOUT 5    | @platform [compass]    | Friction calibration = UX problem          |
| BREAKOUT 6    | @educator [beacon]     | Migration path = onboarding problem        |
| CONVERGE      | @owner [anchor]        | Synthesis is the architect's call          |
| REVIEW        | @owner [anchor]        | Presents plan to user                      |
