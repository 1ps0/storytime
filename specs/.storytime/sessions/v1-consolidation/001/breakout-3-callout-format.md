---
type: breakout
schema_version: 1
created: 2026-04-13T11:40
session: v1-consolidation
episode: 001
topic: v1-consolidation
subtopic: callout-format
driver: "@domain [arbor]"
supporters: ["@critic [forge]"]
supporters_who_spoke: ["@critic [forge]"]
status: complete
---

# Breakout 3 — Callout format for cross-topic decisions

## Question

V1-011 says cross-topic decisions use GitHub-PR-style callouts rather than merging content into both threads. What is the concrete YAML/markdown shape for a cross-topic decision callout that is:

(a) readable by a human skimming a thread,
(b) greppable by scripts and lint,
(c) preserves bidirectional links without duplicating decision bodies, and
(d) lives cleanly inside the v1-003 "thread IS decision log" shape?

The answer must also address: bidirectional link maintenance, search resolution, lifecycle (supersede propagation), rendering posture (expand vs link), and circular references.

## Framing

`@domain [arbor]` leads. The constraint space:

- V1-003 already fixes the decision entry shape: `### ID — Title` header, followed by indented `At / Commit / Drivers / Supersedes / Status` metadata lines, pinned to the commit that sealed it (proposal:209-220).
- V1-011 commits to the principle: each thread owns its own decision entry; neither duplicates the other's body; pointers are bidirectional (proposal:469-473).
- `scripts/export-decisions.sh` already assumes a grep-friendly header pattern (`^## ID:` today, becoming `^### ID —` under V1-003). Whatever callout syntax we pick must also be grep-friendly so a global "who references TOPIC-Y-003?" query resolves with a single regex.
- No existing callout convention lives in the repo today (`grep callout|see_also` returned nothing). Greenfield.

What we know: append-only entries, commit-pinned, per-topic thread files.
What we don't know: the exact line shape for the cross-reference, where it lives within the entry, and how the inverse pointer gets maintained when the two threads are updated at different times.

## Options considered

### Option A — Inline markdown link in the decision body

Every decision body that relates to another topic contains an inline link:

```markdown
### V1-011 — Cross-topic decisions use callouts
  At: 2026-04-13
  ...

This follows from [V1-003](../other-topic/_thread.md#v1-003) which made threads the decision log...
```

Pros: zero new syntax, renders naturally in any markdown viewer.
Cons: not greppable as a *callout* (indistinguishable from any other link), no way to find the inverse without reading prose, lint can't structurally detect it, no distinction between "inspired by" / "affects" / "supersedes."

### Option B — YAML block inside decision frontmatter

Each decision gets its own fenced YAML block:

````markdown
### V1-011 — Cross-topic decisions use callouts
```yaml
callouts:
  - to: consolidation-format#V1-003
    kind: depends-on
  - from: naming#N-004
    kind: affected-by
```
````

Pros: structured, machine-parsable.
Cons: heavyweight, breaks the readable-prose flow of a thread entry, still requires both sides to be updated (the `from:` field is hand-maintained — exactly the duplication we're trying to avoid), and it visually fights the `### ID —` + indented metadata pattern that V1-003 already set.

### Option C — Separate callouts file per thread (`_callouts.md`)

Each topic gets a sibling `_callouts.md` that records all cross-topic pointers in a table.

Pros: single place to edit for cross-topic changes.
Cons: splits decision context from its references (you'd have to read two files to understand one decision), inverts the V1-003 consolidation ("thread IS the decision log" becomes "thread + callouts file together are the decision log"), and introduces a new artifact type for lint to validate. Fails the "earning its keep" test.

### Option D (RECOMMENDED) — Sigil line inside the decision entry, one-sided

A callout is a single line inside the decision's indented metadata, marked with a distinctive sigil:

```
  Callout-> consolidation-format#V1-003 (depends-on)
  Callout<- naming#N-004 (affected-by)
```

Direction is baked into the sigil: `Callout->` is an outgoing reference this thread is making; `Callout<-` is an incoming reference noted when this thread is next touched. The relation kind is in parentheses: `depends-on | affects | supersedes | superseded-by | related`.

**Only the outgoing side is authoritative.** `Callout->` lines are written by the author sealing the decision. `Callout<-` lines are *cached materializations* of outgoing callouts from other threads — populated by `/storytime-lint` (or an opt-in hook) scanning all threads for `Callout->` pointing at this decision, then writing `Callout<-` lines into the target thread on its next consolidation event.

This solves the bidirectional-without-duplication problem: the source of truth is a single `Callout->` line; the inverse is a derived view, rebuildable from a grep. If lint or scanning is disabled, the forward links still work (just not the reverse).

`@critic [forge]` interjects: *"The sigil has to be unambiguous in regex. `Callout->` and `Callout<-` with literal arrows work — `grep -E '^\s*Callout(->|<-)' **/_thread.md` resolves every callout in the repo. Kind-filter with `grep -E 'Callout->.*\(depends-on\)'`. Lint can enforce that the target reference resolves to an existing `### <ID> —` header in the named thread. Structurally enforceable, no new artifact type. Approve."*

## Recommended format (concrete example)

A thread with 2-3 cross-topic callouts, showing the full shape:

````markdown
---
type: thread
schema_version: 1
topic: v1-consolidation
last_consolidation:
  scale: commit
  event: abc1234
  at: 2026-04-13T11:40
remembrance_staged: false
---

# Thread — v1-consolidation

## Episodes
- 001 (incomplete — CONVERGE)

## Decisions (append-only, pinned to commit)

### V1-003 — Thread IS decision log
  At: 2026-04-12
  Commit: abc1234
  Drivers: @owner [anchor]
  Supersedes: —
  Status: active
  Callout-> naming#N-004 (affects)
  Callout-> archive#A-002 (depends-on)

`history/decisions.md` merges into `_thread.md`. One file per topic, decisions append-only within.

### V1-011 — Cross-topic decisions use callouts
  At: 2026-04-13
  Commit: def5678
  Drivers: @domain [arbor]
  Supersedes: —
  Status: active
  Callout-> v1-consolidation#V1-003 (depends-on)
  Callout<- migration#M-007 (affected-by)

When a decision in topic X affects topic Y, each thread gets its own entry that callouts to the other. Forward callouts are authoritative; reverse callouts are cached materializations.
````

Corresponding entry in `specs/.storytime/sessions/naming/_thread.md`:

```markdown
### N-004 — Topic slugs are kebab-case
  At: 2026-04-11
  Commit: 9ab12cd
  Drivers: @domain [arbor]
  Supersedes: —
  Status: active
  Callout<- v1-consolidation#V1-003 (affected-by)

All topic directory names follow [a-z0-9-]+.
```

Note: `naming/N-004` predates `v1-consolidation/V1-003` but only gains its `Callout<-` line on its next consolidation event — the line is materialized, not hand-edited.

## Answers to the specific sub-questions

**1. Exact markdown shape inside a thread's decision entry.**
A line inside the indented metadata block: `  Callout-> <topic>#<id> (<kind>)`. Sigil is the literal arrow. Kinds are a closed vocabulary: `depends-on | affects | supersedes | superseded-by | related`.

**2. Bidirectional linking without synchronous updates.**
Only the outgoing `Callout->` is authoritative. The reverse `Callout<-` is a *cache*, populated by lint or an opt-in hook that scans every thread for `Callout->` lines and back-propagates. Thread Y does not need to be touched at the same time as thread X — the reverse link materializes on Y's next consolidation or lint pass. If the lint never runs, forward traversal still works.

**3. Greppability.**
"All decisions that reference v1-consolidation#V1-003":
`grep -E 'Callout(->|<-).*v1-consolidation#V1-003' specs/.storytime/sessions/*/_thread.md`. One regex, every thread, symmetric on direction.

**4. Lifecycle / supersede propagation.**
A callout does NOT pin to a version — it pins to the decision *ID*. When a decision is superseded, its `Status:` changes to `superseded` and a new entry with a new ID is added. Callouts to the old ID still resolve (the header still exists; status is just different). Lint surfaces this as a *staleness warning*: "callout from X#V1-011 points at Y#V1-003, which is status=superseded — consider updating to Y#V1-022." The warning is advisory, not blocking. Matches the v0.9 staleness policy from `scripts/check-conventions.sh`.

**5. Rendering — expand inline or stay as links.**
Stay as links. The whole point of V1-011 is *no content duplication*. A reader who wants to follow the callout reads the target thread. Tools that produce a "global decisions view" (see Breakout 4) may expand callouts into preview snippets, but the thread itself renders them as compact pointer lines.

**6. Circular references (A<->B).**
Allowed and expected. `V1-003 Callout-> naming#N-004 (affects)` + `N-004 Callout-> v1-consolidation#V1-003 (affected-by)` is legal — each thread is asserting its own relationship. Traversal tooling (export, global view) MUST deduplicate by edge-identity `(from, to, kind)` to avoid cycles. Lint warns only on exact-duplicate lines within a single decision (same target, same kind) — cross-file cycles are informational, not errors.

## Confidence

High — on the syntax choice and on the forward/reverse-cache pattern.
Medium — on the closed kind vocabulary (we may discover we want `blocks` or `informs` in practice; easy to extend, but the initial five should hold for v1.0 MVP).

## Effort Estimate

- **Complexity: 5** — Fibonacci. The format itself is a few-line addition to the V1-003 thread shape; the reverse-cache materializer is a lint pass over all threads with a straightforward scan+rewrite. No new artifact type, no new schema. Work is (a) document the format in `references/consolidation-format.md` or a new `references/callouts.md`, (b) extend `scripts/check-conventions.sh` or add `validate-callouts.sh`, (c) teach `/storytime-lint` about reverse-cache materialization, (d) update `export-decisions.sh` to follow callout edges. Each step small and isolated.

- **Scale: 3 (files)** — Touches `references/` (1 doc add or extend), `scripts/` (1 new or extended script), and the main SKILL's lint section (a few lines to name the new check). Pre-existing threads get backfilled with empty callout sections during the V1-003 migration — but those are mechanical edits inside the same file.

## Citations

- `docs/proposals/v1-consolidation.md:209-220` — V1-003 thread shape with `### ID —` headers and indented metadata (the structure the callout line plugs into)
- `docs/proposals/v1-consolidation.md:469-473` — V1-011 callout principle: per-thread entries, bidirectional pointers, no substantial content duplication
- `skills/storytime/references/artifact-types.md:34` — `thread` artifact type in the registry; required fields are only `last_completed_phase` and `last_commit`, so callout lines need no schema bump
- `scripts/export-decisions.sh:22-31` — existing decision-header grep pattern; callout format must stay grep-compatible so this script can be extended, not rewritten
- `scripts/check-conventions.sh` — existing conventions-lint home for a `validate-callouts` extension

## Open questions (returned to CONVERGE)

1. **Where does the format spec live?** Standalone `references/callouts.md` (focused, one-topic doc) or folded into `references/consolidation-format.md` (unified consolidation ref)? Arbor leans standalone; forge argues folded is fewer files. Defer to CONVERGE.

2. **Reverse-cache materializer: lint pass, commit hook, or both?** Lint-only is simpler and matches the "kill switch" constraint (lint can be skipped). Hook-driven is more timely but adds a write to `post-commit`. Recommend lint-only for MVP; revisit if users find reverse-cache staleness frustrating.

3. **Kind vocabulary extension policy.** If a user wants a `blocks` kind, do they add to repo-local config, or does it go through a decision? Propose: closed set in v1.0 MVP, open-list with `/storytime-lint` warning-on-unknown in v1.1.

4. **Interaction with global decision index (Breakout 4).** If a global index exists at `.storytime/decisions/`, does it materialize callout edges too, or only list decision IDs? This breakout assumes per-thread is canonical; global index is a projection. Cross-check with Breakout 4.

## Participants

- `@domain [arbor]` (driver) — led the investigation, proposed the sigil-line format (Option D), mapped it to the V1-003 thread shape, answered the six sub-questions, surfaced the lint-pass reverse-cache mechanism as the bidirectional-without-synchrony answer.
- `@critic [forge]` (supporter) — confirmed the arrow-sigil regex is unambiguous and structurally lintable, validated no new artifact type is introduced, approved the format on structural grounds.
