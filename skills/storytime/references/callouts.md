---
type: reference
name: callouts
description: "Cross-topic decision callout syntax. Sigil lines inside decision metadata. Forward callouts are authoritative, reverse callouts are lint-cached. Load when writing or validating cross-topic references."
---

# Callouts — Cross-Topic Decision References

Decisions live in per-topic threads (V1-003). When a decision in topic X
references a decision in topic Y, we use **callouts** — GitHub-PR-style
cross-references. No content duplication, no global index required.

## Syntax (V1-019)

A callout is a single line inside a decision's indented metadata block:

```
  Callout-> <topic>#<decision-id> (<kind>)
  Callout<- <topic>#<decision-id> (<kind>)
```

- `Callout->` — outgoing reference (this decision is referring to that one)
- `Callout<-` — incoming reference (that decision is referring to this one)
- `<topic>` — the topic slug (kebab-case, matches session directory name)
- `<decision-id>` — the exact decision ID as it appears in the target thread
- `<kind>` — one of the closed vocabulary below

## Kind vocabulary (V1-021, MVP closed set)

| Kind | Meaning |
|------|---------|
| `depends-on` | This decision assumes the target is true |
| `affects` | This decision changes something the target relied on |
| `supersedes` | This decision replaces the target (the target is obsolete) |
| `superseded-by` | This decision has been replaced by the target |
| `related` | Weak link; worth knowing about but no strong dependency |

**v1.0 ships this closed set.** v1.1 may open the vocabulary with a
`/storytime-lint` warning-on-unknown fallback.

## Authority rule (V1-020)

**Only the outgoing `Callout->` is authoritative.** The reverse `Callout<-`
is a *cache*, populated by `/storytime-lint` scanning all threads for
`Callout->` pointing at this decision, then writing `Callout<-` lines
into the target thread on its next consolidation event.

Why: two threads may be edited at different times. If the reverse is
authoritative, both must be edited together — which defeats the purpose
of V1-011 (no duplication, no sync burden).

If lint never runs, forward traversal still works. Reverse traversal
degrades gracefully to "run lint to rebuild."

## Where callouts live in a thread

Inside the indented metadata of a decision entry:

```markdown
### V1-011 — Cross-topic decisions use callouts
  At: 2026-04-13
  Commit: def5678
  Drivers: @domain [arbor]
  Supersedes: —
  Status: active
  Callout-> v1-consolidation#V1-003 (depends-on)
  Callout<- migration#M-007 (affected-by)

When a decision in topic X affects topic Y, each thread gets its own
entry that callouts to the other.
```

Callouts come after the core metadata (At, Commit, Drivers, Supersedes,
Status) and before the prose body. One callout per line. Alphabetical by
topic#id within direction; forward before reverse.

## Concrete round-trip example

**Source: `specs/.storytime/sessions/v1-consolidation/_thread.md`**

```markdown
### V1-003 — Thread IS decision log
  At: 2026-04-12
  Commit: abc1234
  Drivers: @owner [anchor]
  Status: active
  Callout-> naming#N-004 (affects)
  Callout-> archive#A-002 (depends-on)
```

**Target after lint materializes: `specs/.storytime/sessions/naming/_thread.md`**

```markdown
### N-004 — Topic slugs are kebab-case
  At: 2026-04-11
  Commit: 9ab12cd
  Drivers: @domain [arbor]
  Status: active
  Callout<- v1-consolidation#V1-003 (affected-by)
```

The `Callout<-` line in `N-004` was materialized by
`/storytime-lint`, not hand-edited.

## Lifecycle

Callouts pin to decision **ID**, not version. When a decision is
superseded:

- The superseded decision's `Status:` flips to `superseded`
- A new decision is added with a new ID
- Existing callouts still resolve (the old ID's header still exists)
- Lint surfaces staleness: *"callout from X#V1-011 points at Y#V1-003
  (status=superseded) — consider updating to Y#V1-022."*
- Staleness is a warning, not a failure. Updates are optional and
  human-judged.

## Circular references

Allowed and expected. `A Callout-> B (affects)` + `B Callout-> A
(affected-by)` is legal. Traversal tools (export, views) deduplicate by
edge identity `(from, to, kind)` to avoid cycles. Lint only warns on
exact-duplicate lines within a single decision (same target, same kind).

## Greppability

All callouts referencing a specific decision:

```bash
grep -E 'Callout(->|<-).*v1-consolidation#V1-003' \
  specs/.storytime/sessions/*/_thread.md
```

By kind:

```bash
grep -E 'Callout->.*\(depends-on\)' specs/.storytime/sessions/*/_thread.md
```

## Validation

Mechanical (scripts/validate-callouts.sh):

| Check ID | Check |
|----------|-------|
| CA1 | Callout line matches sigil regex |
| CA2 | `<topic>` resolves to a session directory |
| CA3 | `<decision-id>` resolves to a `### <id> —` header in target thread |
| CA4 | `<kind>` is in the closed vocabulary |
| CA5 | No exact-duplicate `(from, to, kind)` triples within one decision |

Advisory (surfaced by lint, not a fail):

| Check ID | Check |
|----------|-------|
| CA-W1 | Reverse cache is stale (forward exists without matching reverse) |
| CA-W2 | Callout target has `status: superseded` |
| CA-W3 | Dangling reverse cache (reverse exists without matching forward) |

## Reverse-cache rebuild

On each `/storytime-lint` run (or explicit `/storytime-lint --rebuild-callouts`):

1. Scan all `_thread.md` for `Callout->` lines.
2. For each, check the target thread for a matching `Callout<-`.
3. If missing, append the reverse line to the target's decision metadata
   (atomic tmp+mv per V1-018).
4. Warn on dangling reverses (no matching forward).

This is idempotent. Running multiple times produces the same result.

## v1.1 and beyond

- Open the kind vocabulary (warning-on-unknown instead of failure).
- Optional post-commit hook for timelier reverse-cache updates.
- Graph visualization (`scripts/decisions-view.sh --format=graph`).
