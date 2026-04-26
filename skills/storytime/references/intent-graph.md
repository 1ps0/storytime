---
type: reference
name: intent-graph
description: "The intent graph model — nodes are V1-NNN decisions, edges are typed (refines, specializes, supersedes, tensions, links), DAG with cross-topic connectivity. Read-only operations in v1.0.1; write-side mutations are still hand-edits to frontmatter. Load when querying decision relationships, computing adherence, or proposing new decisions."
---

# Intent Graph

The graph of all storytime decisions and their relationships, extracted
from existing artifacts. **Implicit in v1.0; named and queryable in v1.0.1.**

This reference defines the model. `scripts/intent-graph-query.sh` is the
read-side query tool. Composition (write-side and distillation) is
deferred to v1.2+.

## Model

**Nodes** are decisions. Identified by their decision ID (e.g., V1-014,
RATE-002). Each node has:

- ID
- Title
- Topic (the session it lives in)
- Status (active | superseded | retired)
- Driver(s) (the persona(s) that sealed it)
- Commit (the sealing commit)
- Optional: parent, edge_type, tensions, realized_at, lifecycle_state

**Edges** are typed:

| Type | Direction | Meaning |
|------|-----------|---------|
| refines | child → parent | child adds constraints to parent |
| specializes | child → parent | child is a more specific case of parent |
| implements | child → parent | child realizes parent at a lower level |
| co-implies | sibling ↔ sibling | two siblings jointly imply a third |
| tensions | sibling ↔ sibling | siblings partially contradict |
| supersedes | new → old | new replaces old |
| links | A ↔ B (cross-topic) | callout-style cross-reference |

The graph is a **DAG with cross-topic links**. A node may have multiple
parents (refines several coarser intents). Tensions and links are
symmetric; refines/specializes/implements/supersedes are asymmetric.

## Where the graph lives

Implicit in artifacts. No graph database.

| Source | Provides |
|--------|----------|
| `_thread.md` decision blocks | nodes (with title, drivers, status, commit) |
| `supersedes:` field | supersedes edges |
| `Callout->` / `Callout<-` lines | links edges |
| `parent:` field (v1.0.1+) | refines/specializes/implements edges |
| `tensions:` field (v1.0.1+) | tensions edges |
| `realized_at:` field (v1.0.1+) | lifecycle state (sealed → realized) |
| commit messages mentioning V1-NNN | implicit realized markers |

A complete graph reconstruction is `parse(_thread.md)` + `parse(commits)`.

## Frontmatter convention (v1.0.1+, opt-in)

New decisions may include:

```yaml
### V1-031 — User-as-role becomes first-class
  At: 2026-04-25
  Drivers: @owner [anchor]
  Status: active
  Parent: V1-005
  Edge_type: refines
  Tensions: []
  Realized_at: <commit-sha-when-shipped>
  Lifecycle_state: realized
```

All five new fields are **optional**. Existing v1.0 decisions remain
valid as-is. The graph is sparse but legitimate.

Field semantics:

- `parent` — the coarser intent this refines/specializes/implements.
  May be a list if the node refines multiple coarse intents.
- `edge_type` — type of the edge to parent. Required if parent is set.
- `tensions` — list of decision IDs this contradicts. Lint reconciles
  symmetry (if X tensions Y, Y should also tensions X).
- `realized_at` — commit SHA where this decision was implemented in
  code. Promotes status from sealed → realized.
- `lifecycle_state` — explicit state (proposed | focused | sealed |
  realized | retired). Inferred from commit/status if absent.

## Lifecycle states

```
proposed  →  focused  →  sealed  →  realized  →  retired
   ↑           ↑          ↑           ↑
icebreaker  breakout    plan        code        superseded
 concern     rec        decision    commit       or shipped
```

`realized` requires `realized_at:` (a resolved commit).
`retired` happens when the node is superseded or the work it represented
is fully shipped and no longer subject to change.

## Read operations

Implemented in `scripts/intent-graph-query.sh`:

| Operation | Description |
|-----------|-------------|
| `get_node <id>` | Return one node with all fields |
| `get_children <id>` | Direct children (nodes whose parent: matches) |
| `get_parents <id>` | Direct parents (from this node's parent: field) |
| `get_path <id>` | Walk up to root via parents |
| `get_subtree <id> [--depth N]` | All descendants to depth N |
| `get_orphans [<topic>]` | Sealed nodes with no parent and no `root: true` |
| `get_unrealized [<topic>]` | Sealed but no realized_at |
| `get_tensions [<topic>]` | All tension pairs |
| `get_supersedes <id>` | What this node supersedes / what supersedes it |
| `get_callouts <id>` | Cross-topic links from/to this node |

All operations are read-only and idempotent. No state changes.

## Write operations (v1.2+)

Deferred. Mutations are hand-edits to frontmatter for v1.0.1. Future
write API:

| Operation | Description |
|-----------|-------------|
| `add_node` | Create a new decision node with parent + edge_type |
| `refine` | Add a child node of type=refines |
| `supersede` | Mark old superseded, point new |
| `mark_tension` | Symmetric edge with rationale |
| `realize` | Promote sealed → realized with commit ref |
| `freeze_subtree` | Mark "no re-decomposition" |
| `thaw_subtree` | Re-open for re-decomposition |

## Composition operations (v1.2+)

The hard direction. Deferred until enough corpus exists.

| Operation | Description |
|-----------|-------------|
| `distill <ids[]>` | Find a coarser intent the input nodes share |
| `name <node>` | Suggest a label for a distilled node |
| `generalize <id> <param>` | Lift one parameter to abstract |
| `conjugate <a> <b>` | Find the coarser intent that contains both siblings |

These are hypothesis-generators, not classifiers. User accepts/rejects.
See `docs/proposals/intent-gradient.md`.

## Invariants

- No node deleted (only superseded).
- Every edge has a type.
- Cross-topic edges become bidirectional after lint reconciles.
- Tensions are symmetric.
- Realized nodes have a resolvable commit_sha.

## Lint (IG class, mechanical)

Per V1-035:

| # | Check |
|---|-------|
| IG1 | Every sealed decision with `parent:` has a resolvable target |
| IG2 | Every `supersedes:` has a resolvable target |
| IG3 | `tensions:` are symmetric (X tensions Y ↔ Y tensions X) |

Advisory (deferred to v1.2+):

| # | Check |
|---|-------|
| IG4 | Realized nodes have valid commit_sha (mechanical, can ship in v1.0.x) |
| IG5 | Stale-edge count below threshold (advisory, dogfood-tunable) |

## How this connects to existing storytime concepts

Several existing concepts are now first-class graph operations:

| Existing concept | Graph framing |
|------------------|---------------|
| Append-only decision log | Sealed-and-supersede invariants |
| Callouts | Cross-topic edges with edge_type |
| Buildout traces | Realized state for nodes |
| Retro plan-vs-built | Lifecycle audit |
| Driver per leg | Lens-attribution per node |
| Process rules | Root-adjacent constraint nodes |
| Non-goals | Negative-edge nodes ("not refining toward this") |

The graph framing **renames** existing structure. Most data already
exists; we're elevating the abstraction.

## Companion documents

- `references/user-as-role.md` — the user as a participant in the graph
- `references/intents-format.md` — the user-intent log
- `references/callouts.md` — cross-topic edge syntax
- `references/artifact-types.md` — schema_version 2 fields
- `docs/proposals/intent-gradient.md` — full model rationale
- `docs/proposals/intent-visualization.md` — graph projections
