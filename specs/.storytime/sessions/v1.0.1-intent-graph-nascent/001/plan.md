---
type: plan
schema_version: 1
created: 2026-04-25T11:30
session: v1.0.1-intent-graph-nascent
episode: 001
driver: "@owner [anchor]"
status: shipped
---

# Plan — v1.0.1 nascent intent graph

Minor release. Three deliverables, all read-side or convention-only.
No changes to existing v1.0 behavior.

## Architecture sketch

```
       ┌────────────────────────────────────────┐
       │  Existing v1.0 artifacts                │
       │  (V1-NNN decisions in _thread.md,       │
       │   callouts as cross-topic edges,        │
       │   commits referencing decisions)        │
       └────────────────────────────────────────┘
                       │
              ┌────────┼────────┬───────────────┐
              ▼        ▼        ▼               ▼
        @user [you]  graph     adherence    intent-graph
        cohort       query     viz          lint (IG class)
        persona     script    script
              │        │        │               │
              └────────┴────────┴───────────────┘
                          │
                  Playable nascent graph
```

## Deliverables

### 1. User-as-role
- `references/user-as-role.md` — convention spec
- `references/intents-format.md` — `.storytime/intents.md` schema
- Cohort template: `cohort/_user.md` written at first user-driven
  session (storytime checks for it on bootstrap; doesn't auto-create
  to avoid surprise)
- `team-assembly.md` updated to mention @user

### 2. Read-side intent graph
- `references/intent-graph.md` — model spec (nodes, edges, invariants,
  read operations only for this release)
- `scripts/intent-graph-query.sh` — read operations (get_node,
  get_children, get_parents, get_path, get_unrealized, get_tensions,
  get_orphans)
- `references/artifact-types.md` — schema_version 2 fields documented
  (parent, edge_type, tensions, realized_at, lifecycle_state)

### 3. Adherence visualization
- `scripts/intent-adherence.sh` — renders the sealed-vs-realized grid
  per topic or repo-wide

### Lint additions
- `/storytime-lint` SKILL gains IG1-IG3 (mechanical) under "intent graph"

## Non-goals (v1.0.1)

- **No composition / distillation.** That's v1.2+. Needs corpus first.
- **No write-side mutations.** Read-only. Mutations are still hand-edits
  to frontmatter.
- **No automatic intent extraction from prompts.** That requires hook
  infrastructure or model self-instrumentation. v1.1+.
- **No graph database.** Grep + awk over artifacts.
- **No mass-update of existing v1.0 decisions** to add new fields.
  Backward-compatible. Sparse graph is legitimate.

## Success criteria

1. `scripts/intent-graph-query.sh --orphans` runs cleanly on the
   v1-consolidation thread.
2. `scripts/intent-adherence.sh v1-consolidation` renders a grid of
   the 30 V1-NNN decisions with status per decision.
3. `/storytime-lint` exits 0 on the current repo state.
4. `cohort/_user.md` is documented but not auto-created.
5. Version bump 1.0.0 → 1.0.1 propagates clean (bump-version.sh check).

## Ship sequence

1. Write references (user-as-role, intents-format, intent-graph)
2. Write scripts (intent-graph-query, intent-adherence)
3. Update lint skill + artifact-types
4. Update team-assembly to mention @user
5. Bump to 1.0.1
6. Tag + push
