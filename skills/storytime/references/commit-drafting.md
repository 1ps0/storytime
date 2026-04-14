---
type: reference
name: commit-drafting
description: "Commit-drafting contract for v1.0. LLM drafts every commit message; user confirms every one; edit-distance learning proposes shorter prompts for patterns with proven safety. Load by any skill that produces commits."
---

# Commit Drafting — LLM Drafts, User Confirms, System Learns

## Core contract (V1-001)

**The LLM drafts every commit message.** The user confirms every one
before the commit happens. There is no auto-commit mode. Ever.

The LLM proposes; the user disposes. Rejecting a draft never creates the
commit. Editing the draft is the signal the learning system uses to stay
attentive.

## When to propose a commit

The LLM proposes a commit when:

- A **unit of work is finished** — phase completion, breakout completion,
  buildout slice completion, decision sealing, plan approval
- **Significant-enough progress** has crossed a milestone — problem solved,
  rewrite complete, blocker cleared, several related files in a coherent
  state

The LLM does NOT propose a commit for:

- Typo fixes (usually fold into the next substantive commit)
- Incomplete halfway states (unless user explicitly asks)
- Noisy exploratory changes without a coherent story

Judgment, not threshold. Err on the side of fewer, more meaningful commits.

## Draft shape

Every draft includes:

- **Subject line** — imperative, ≤72 chars, no period, describes the change
- **Body paragraph(s)** — what changed and *why*, file-level reasoning,
  cross-references to decisions (`V1-NNN`), personas involved if relevant
- **No co-author lines** (per user preference; see memory)

Example (from this session's own commits):

```
v1-consolidation session DONE: plan approved, buildout begins

Full cold-start storytime spec on docs/proposals/v1-consolidation.md.
8-persona team (5 rehires + 3 specialists), 6 parallel breakouts,
17 new decisions (V1-014..V1-030), 28-item 7-phase plan.

Session artifacts:
  ...
```

## Adaptive learning (V1-009, V1-014, V1-015)

Commit learning watches for patterns and proposes **shorter prompts** for
shapes the user has approved cleanly over time.

### Pattern keys (v1.0 ships three)

| Key | Values | Eligibility |
|-----|--------|-------------|
| `path_prefix` | top-level directory of changed files | eligible if single top-level; `mixed` if multiple |
| `size_bucket` | `tiny` (≤2 files, ≤20 lines), `small` (≤5 files), `medium` (rest) | only `tiny` and `small` eligible in v1.0 |
| `kind_hint` | `typo`, `docs`, `config`, `code`, `mixed` (derived from extensions + draft verb) | advisory |

Multi-top-level commits → `mixed` pattern → never eligible for quiet mode.
Medium-or-larger commits → always full prompt.

### Clean vs modified samples

A sample is **clean** when the final committed message is ≤5% token-level
edit distance from the LLM's draft. Anything more is **modified**.

### Rolling window + threshold

A pattern becomes eligible for quieter mode when:

- **≥ 7 samples** in the pattern (rolling window), AND
- **≥ 6 of 7 are clean**

If the rolling rate drops below 4-of-7 clean → pattern auto-reverts to
full prompting (soft reset, no user action).

### Quieter mode (V1-015)

**Quieter = shorter prompt, not skipped prompt.** The user stays in the
loop; only the default presentation changes.

Shape of the quieter prompt:

```
I drafted this commit matching the `docs/` pattern — accept as-is, or
show full draft?

  [accept]  [show]  [edit]
```

If `show` → full draft is displayed, user can accept/edit.
If `edit` → existing edit flow.
If `accept` → same as full-draft confirmation.

**Skipped prompts (second quiet tier) are explicitly out of scope for v1.0.**
Data collects for it, but v1.0 never proposes it.

## Tutorial interaction (V1-007, V1-027)

In tutorial automation tier, learning proposals are **deferred** — samples
collect silently but never surface a proposal. Once the user steps down to
`guided`, collected data is immediately available and the first proposal
may fire if threshold has already been crossed.

Rationale: tutorial users are still learning baseline; don't short-circuit
their learning by offering shortcuts too early.

## Reset mechanisms

- **Soft reset** (automatic): rolling rate drops below 4-of-7 clean for a
  pattern → pattern reverts to full prompting. Logged to
  `.storytime/commit-patterns.md` but not surfaced to user.
- **Hard reset** (user): *"prompt me on everything again"* → discard all
  pattern data. File is moved to `.storytime/archive/` with a timestamp,
  not deleted (undo-friendly).
- **Per-pattern reset** (user): *"stop quiet mode for docs"* → zero out
  `docs/` only; other patterns intact.

## State storage

Per-repo, at `.storytime/commit-patterns.md`:

```yaml
---
type: commit-patterns
schema_version: 1
updated: 2026-04-14T10:00
---

# Commit patterns

## path_prefix=docs/ + size_bucket=small
samples: 8
clean: 7/8
status: quieter-proposed  # none | quieter-proposed | quieter-active | soft-reset
proposed_at: 2026-04-14T09:30
accepted_at: null
rolling_window: [clean, clean, clean, modified, clean, clean, clean, clean]

## path_prefix=src/ + size_bucket=tiny + kind_hint=typo
samples: 3
clean: 3/3
status: none

## path_prefix=mixed
samples: 0  # never eligible (mixed pattern)
```

## Telemetry (V1-027)

The system logs *"would have proposed at sample N"* even when it doesn't,
so post-dogfood we can retune the 7/6 threshold to a real distribution.
Logs live alongside pattern state. No phone-home; local observation only.

## Validation

Mechanical (scripts/check-conventions.sh extension):

| Check ID | Check |
|----------|-------|
| CD1 | `.storytime/commit-patterns.md` has valid frontmatter if present |
| CD2 | Pattern entries have required fields (samples, clean, status, rolling_window) |
| CD3 | `status` in {none, quieter-proposed, quieter-active, soft-reset} |
| CD4 | `rolling_window` has ≤ 7 entries |

Reasoning (estimator agent):

| Check ID | Check |
|----------|-------|
| CD-R1 | Claimed `clean` count matches rolling window entries |
| CD-R2 | Pattern key is well-formed (valid path_prefix + size_bucket + kind_hint) |

## v1.1 and beyond

- Edit-distance normalization (whitespace, list collapse) before diff —
  reduces noise from reformatting.
- Cross-repo pattern seed — "import my pattern defaults" from another
  storytime repo.
- Second quiet tier (skipped prompt with post-hoc notification) — only
  after edit-distance signal proves reliable.
- Shared telemetry corpus for threshold retuning across users (opt-in).
