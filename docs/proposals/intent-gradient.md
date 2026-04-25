---
type: proposal
schema_version: 1
created: 2026-04-25T11:00
name: intent-gradient
status: exploration
session: null
---

# Intent Gradient — Coarse to Fine and the Structure Between

Companion to the three earlier intent proposals. This one challenges the
metaphors used to talk about coarse-to-fine intent (FFT, calculus, AST),
proposes the model that actually fits (typed intent DAG), and identifies
the asymmetry between decomposition and composition as the most valuable
unexplored direction.

## Where the metaphors stretch

### FFT is suggestive but lies

FFT requires orthogonal basis functions and a smooth signal. Intents are
neither:

- They aren't orthogonal — they overlap, depend on each other, contradict
  each other.
- They aren't smooth — they're discrete decisions with hard transitions.

If you computed a literal "intent power spectrum" you'd be measuring an
artifact of your encoding, not a property of the intent set. The vocabulary
is suggestive (broad-band vs narrow-band, coarse-amplitude vs fine-
amplitude) but treating it as actual signal processing would be theatre.

### Calculus fits a little better, only as vocabulary

Intents don't move continuously. There's no real derivative — only a hop
from one settlement to another. ∇I in "lens-space" sounds nice, but lens-
space is finite, sparse, and discrete. What would "the gradient pointing
toward @critic" mean if @critic is one of eight bins? You'd be computing
finite differences and dressing them up.

The honest version of calculus-vocabulary that survives:

- **Decomposition is differentiation-shaped** (one to many at finer
  resolution).
- **Composition is integration-shaped** (many to one at coarser
  resolution).

Useful as direction names, not as math.

## The model that actually fits — typed intent DAG

Intents form a graph, not a signal. Nodes are intent statements. Edges
carry semantic types:

```
refines       — child adds constraints to parent
specializes   — child is a more specific case of parent
implements    — child realizes parent at a lower level
co-implies    — two siblings jointly imply a third
tensions      — siblings partially contradict
supersedes    — replaces an earlier subtree
links         — cross-topic edge (callouts, today)
```

This is closer to AST than FFT, but with **typed edges and cross-topic
links** ASTs don't have. Programs are trees; intents are DAGs (directed
acyclic, mostly — supersession can create cycles you have to break
manually).

Storytime already produces this graph implicitly:

- Decisions (V1-NNN) are nodes.
- `supersedes:` is a graph operation.
- Callouts (`Callout->`, `Callout<-`) are cross-graph links.
- The plan's roadmap is a topological sort of the relevant subgraph.
- Breakouts are decomposition events recorded as artifacts.
- Process rules are root-adjacent constraints.

We've been building a typed intent DAG without naming it that.

## The "lines between coarse and fine" aren't 1D

Coarse-to-fine reads as a single axis but it's at least four collapsed:

```
        commitment    specificity    lens-monochromaticity    citation-density
coarse      ←              ←                  ←                    ←
fine        →              →                  →                    →
```

A vision statement is *uncommitted, vague, multi-lens, ungrounded*. A lint
check is *committed, specific, single-lens, grounded*. They're at opposite
corners of a 4-cube, not opposite ends of a line.

The "middle" — where most breakout outputs live — is some specific
combination of these attributes:

- **Sealed but not specific** — committed direction, undetermined
  implementation. Common after CONVERGE.
- **Specific but lens-monochromatic** — an @critic micro-decision in
  isolation. Common in BO follow-up work.
- **Grounded but uncommitted** — well-cited concern that hasn't been
  resolved. Common in icebreaker concerns that didn't make it to a
  breakout.
- **Multi-lens but specific** — a tightly-scoped decision that nonetheless
  required broad agreement. Often architectural inflection points.

The geometry is rich and underexplored.

## What's empirically computable

Graph metrics, on the artifacts we already produce, no new instrumentation:

| Metric | Definition | What it surfaces |
|--------|-----------|------------------|
| **Depth** | edges from root to node | How concrete this intent is |
| **Branching factor** | avg children per parent | Healthy ≈ 2-5; <2 under-decomposed; >5 disorganized |
| **Tree balance** | std dev of subtree depths | Areas over-spec'd vs ignored |
| **Tension density** | sibling-tension edges / sibling pairs | Coarse high = productive friction; fine high = unresolved bugs |
| **Decomposition rate** | child-creation events per parent per N commits | Slow rate = stuck |
| **Lens-spectrum-per-node** | which lenses contributed | Should narrow as depth increases — multi-lens at fine scope is suspicious |
| **Re-decomposition frequency** | supersession events on nodes-with-children | High at coarse = direction-finding; high at fine = thrashing |

These aren't novel as graph metrics. They're novel as *intent metrics*.
We have the data; we're not aggregating it.

## The asymmetry that matters most

**Decomposition is the easy direction.** Given a coarse intent, the system
can propose plausible children by pattern-matching prior decompositions.
This is what `/storytime-breakout` already does, just not explicitly framed
that way. The breakout is a decomposition event — it takes a coarse intent
(the sub-problem) and produces 3-4 finer alternatives, then commits to one.

**Composition is the hard direction and the more valuable one.** Given
many fine intents, can the system suggest a coarse intent the user hasn't
named?

> "Your last 12 sealed decisions all add atomic-write constraints — there's
> an unnamed parent intent here ('reliability invariant: no partial state')
> that should be elevated."

This is where automated assist gets genuinely hard. It's closer to
conceptual clustering / topic modeling than tree expansion. LDA-shaped,
not BFS-shaped. The honest answer: this is where LLM judgment with full
context beats statistics.

But the system can do something cheaper than full composition: **suggest
candidate coarsenings**. Read N recent fine intents, propose 1-3 candidate
parents, let the user accept/reject. Hypothesis-generator, not classifier.
Fits the "user has veto power" posture.

## Useful behaviors that fall out

Not "track intents" but specific operations on the graph:

1. **Show me the path** — given a fine intent, walk up to its coarsest
   sealed ancestor. Useful for justification: *"why did we make this
   micro-decision?"*

2. **Show me the leaves** — given a coarse intent, walk down to still-
   realized sub-decisions. Useful for impact: *"if I supersede this, what
   falls?"*

3. **Find the orphans** — intents at depth >1 with no living parent
   (parent superseded, child not re-attached). Dead branches.

4. **Find the unresolved tensions** — sibling pairs marked contradictory,
   both sealed, no resolution decision. Bug nests.

5. **Suggest a parent** — for a cluster of fine intents sharing attributes,
   propose a coarse parent. The composition operation.

6. **Re-fork point** — when project direction shifts, find the highest
   still-valid ancestor; re-decompose from there. Cheaper than starting
   over.

7. **Subtree freeze/thaw** — mark a decomposed subtree as "implemented,
   don't touch" vs "open for re-decomposition." Helps with focus.

## What gets persisted to make this real

Don't build a graph database. The graph is implicit in artifacts; querying
it is a script over those artifacts. The minimum metadata to make the graph
extractable:

```yaml
# in V1-NNN decision frontmatter
parent: V1-001          # the coarser intent this refines
edge_type: refines      # refines | specializes | implements | supersedes | ...
tensions: [V1-014]      # sibling-or-cousin intents this contradicts
```

That's enough to extract everything in the metrics table above with grep
and a small script.

For the cross-topic case, we already have callouts (`Callout->`,
`Callout<-`) which are exactly the cross-graph edges. They just need a
broader edge_type vocabulary than `depends-on | affects | supersedes |
superseded-by | related` to capture decomposition relationships.

## How this connects to the earlier intent docs

- `intent-extraction-user.md` — the user's intents are also nodes in this
  graph. Their lens distribution is a property of which subtrees they
  drive. **User-as-persona** means @user is a node-attribution, not a
  separate graph.
- `intent-extraction-roles.md` — role-driven intents populate the graph
  at finer scopes. The icebreaker is breadth-first divergence; breakouts
  are depth-first refinement; plans are topological flattening for
  execution.
- `intent-visualization.md` — the three visualizations are projections of
  this graph onto different axes (time, leg, lens). The graph is the
  underlying data; the viz is the rendering.

This document **completes the set** by naming the underlying structure.
The other three operate on it; this one specifies what it is.

## The meta-introspection part

This entire exploration has been doing intent-graph operations on a graph
that doesn't exist yet. The conversation walked from a coarse intent
("intent gradient is interesting") down to specific operations (the seven
above) — that's a depth-first decomposition.

An earlier coarsening ("storytime is an intent-flow system" from
`intent-extraction-roles.md`) retroactively organized many fine intents
into a unified parent. That was a composition operation.

Both directions, both valuable, both currently happening only in
conversation, not in persisted artifacts. **If we persist the graph
operations, the conversation we're having becomes part of the intent
tree itself.** The conversation isn't just *about* intent structure — it
*is* intent structure being shaped.

That loops back to the conversation-as-artifact question from
`intent-extraction-user.md` (item 10).

## Where the next jump is

The thing genuinely new in this framing: **the asymmetry of decomposition
vs composition, and the fact that storytime already does decomposition
implicitly but ignores composition entirely.**

That's where the next jump probably is. Not better decomposition — better
*noticing* of the coarse intents that emerge from the fines.

Concrete v1.2+ proposal: a `/storytime-coarsen` skill that reads N recent
fine intents and proposes 1-3 candidate parents. Hypothesis-generator,
explicit accept/reject UX, no auto-promotion. Different operation from
breakout (which decomposes). Both directions deserve a first-class skill.

## Summary tradeoffs

| Direction | Easy or hard? | First-class today? | Value |
|-----------|--------------|--------------------|-------|
| Decomposition (coarse → fine) | easy, well-trod | yes (breakout) | high but understood |
| Composition (fine → coarse) | hard, novel | no | high and unexplored |
| Cross-topic linking | medium | yes (callouts) | medium |
| Tension marking | medium | partially (supersedes) | high (bug-nest detection) |
| Subtree freeze/thaw | medium | no | medium (focus discipline) |

The unexplored quadrant is composition + tension. Both ask "what's the
shape of intent we have, that we haven't named?" — which is the question
storytime has been implicitly answering through cohort discussion all along.

## Companion documents

- `intent-extraction-user.md` — user-intent extraction, user-as-persona reframe
- `intent-extraction-roles.md` — role-intent cross-reference, intent-flow-system reframe
- `intent-visualization.md` — three visualizations as graph projections
