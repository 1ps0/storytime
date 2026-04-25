---
type: proposal
schema_version: 1
created: 2026-04-19T10:00
name: intent-visualization
status: exploration
session: null
---

# Intent Visualization

Companion to `intent-extraction-user.md` and `intent-extraction-roles.md`.
Three visualization sketches for tracking intent over a storytime project:
adherence (sealed-vs-delivered), active-attention window (working-set per
leg), and driver-attribution per leg.

## What we want to see

The user asked for two specific signals to make visible:

1. **Intent adherence** — are we actually doing what we said we'd do?
2. **The window of active intent attention at any given leg of work** —
   how wide is the working set, and is it growing/shrinking healthily?

These two signals operate on the intent lifecycle from
`intent-extraction-roles.md`:

```
Loose → Surfaced → Focused → Sealed → Realized → Retired
```

Adherence asks: *of all sealed intents, which are realized vs drifting?*
Active-attention asks: *which intents am I actively touching right now?*

A third visualization — driver-attribution per leg — confirms the
"one driver per leg" rule (V1-023) is being held.

## Visualization 1 — Adherence grid

Cross-references each sealed decision (V1-NNN) against the artifacts that
implement it. Status markers per phase show whether the decision was
addressed at that phase.

```
Adherence — v1-consolidation (sealed → delivered)
                        Phase  Doc  Code  Run    Status
V1-001 LLM drafts        ·     ✓    ◐     ·     doc'd, mechanism prose-only
V1-002 model pauses      ·     ✓    ✓     ·     in SKILL, not exercised
V1-003 thread=decisions  ✓     ✓    ✓     ✓     fully delivered
V1-008 unified format    ✓     ✓    ✓     ◐     consolidation events not yet exercised
V1-014 commit-learning   ·     ✓    ·     ·     reference doc only
V1-015 shorter prompt    ·     ✓    ·     ·     spec only
V1-016 6 signals         ·     ✓    ✓     ·     in SKILL prose
V1-018 atomic mv         ✓     ✓    ✓     ✓     fully delivered (used in migration)
V1-019 callout sigils    ✓     ✓    ✓     ✓     validate-callouts.sh works
V1-022 on-demand view    ✓     ✓    ✓     ✓     decisions-view.sh works
V1-024 friction hybrid   ·     ✓    ·     ·     reference only
V1-028 migrate script    ✓     ✓    ✓     ✓     used on self
V1-030 cohort rename     ✓     ✓    ✓     ✓     applied (5 files renamed)
                                         ────
                                         ~12/30 fully delivered
                                         ~10/30 doc'd-not-coded
                                         ~8/30 awaiting dogfood
```

### Status legend

- `✓` — addressed at this phase
- `◐` — partially addressed (e.g., doc'd but not coded; coded but not run)
- `·` — not addressed yet at this phase

### Implementation cost

**Cheap.** Parse `## Decisions` blocks in `_thread.md` for V1-NNN entries,
grep commits for V1-NNN mentions in messages, grep code for the artifacts
each decision implies. ASCII output, no chart library.

```sh
# scripts/intent-adherence.sh sketch
for decision in $(grep -hE '^### V1-' specs/.storytime/sessions/*/_thread.md); do
  id=$(extract_id "$decision")
  commits=$(git log --grep="$id" --format=%h)
  files=$(git log --grep="$id" --name-only)
  classify "$id" "$commits" "$files"  # → ✓ / ◐ / ·
done
```

### What this surfaces

- **Drift** — decisions sealed long ago that have never received a commit.
  These are candidates for either de-prioritization or active backlog
  promotion.
- **Doc-only debt** — decisions that have references written but no
  exercising code. Common after a planning sprint; gives a clear "what's
  next" backlog.
- **Run-coverage gaps** — decisions that have code but have never been
  exercised by a real session (no commits referencing them outside the
  initial implementation). These are dogfood candidates.

## Visualization 2 — Active-attention window

Timeline of which intents are active at each leg of work. "Active" means
the leg's commit message, files changed, or recorded `active_intents`
field references the intent.

```
Active intents over the buildout (intent ▓ = touched in this commit)

                  M    I.3  I.4  I.1+  II.3 IV.B-1 IV.B-5+ V.1   IV.B-2  rest+ ship
                  │    │    │    │     │    │      │       │     │       │     │
V1-001 commit     ─────────────────────────▓───────────────────────────────────▓
V1-002 pauses     ───────────────▓───────────────────────────────────────────▓
V1-003 thread=    ▓───▓───▓───▓─▓─────▓─────▓────────────▓─▓
V1-008 unified    ▓───▓───▓───▓─▓─────────▓─▓
V1-014 learning   ▓
V1-016 signals    ▓───────────────▓───────▓
V1-018 atomic     ▓───▓───▓───▓─────▓─▓───▓─▓───▓───────▓
V1-019 callouts   ▓                                ▓
V1-022 view       ▓                                      ▓
V1-028 migrate    ▓                          ▓                   ▓
V1-030 cohort     ▓                                              ▓

Active count:    [6]  [3]  [3]  [10]  [3]  [4]    [4]    [4]   [5]    [4]   [10]
                  ──   ──   ──   ◆◆    ──   ──     ──     ──    ──     ──    ◆◆
                                  WIDE                                       WIDE
                                 (consol-                                   (ship
                                  idation                                    review)
                                  fan-in)
```

### What this surfaces

- **Attention spikes** are visible — the I.1 phase (Consolidation section
  absorbs three sections + touches 10 intents) and the ship phase
  (everything reconsidered) both show active counts of 10. These are
  expected; the narrow phases between them are healthy focus.
- **Overload signal** — when active count >10 sustained, the user's working
  memory is overloaded. Surface as a pause-trigger candidate.
- **Drift signal** — when intents go dark for many commits in a row, that's
  abandonment risk. The visualization makes it visible.
- **Healthy focus** — narrow active sets during the M, IV.B-1, IV.B-2,
  V.1, V.2 phases are GOOD. They indicate one thing being done well at
  a time.

### Implementation cost

**Medium.** Requires `active_intents` field in commit consolidation events
(an addition to the unified consolidation format). Once that's there,
parsing the thread's commit-consolidation entries gives the timeline
directly. Grid output via plain text formatting.

```sh
# scripts/intent-window.sh sketch
for thread in specs/.storytime/sessions/*/_thread.md; do
  parse_consolidation_events "$thread" | \
    extract_active_intents | \
    render_grid
done
```

### Variants

- **Per-leg** (default) — one column per phase or commit consolidation.
- **Per-day** — bucket by day for longer projects.
- **Per-topic** — show one row per topic instead of one per intent.

## Visualization 3 — Driver attribution per leg

Confirms the "one driver per leg" rule (V1-023) is held. One row, columns
by leg, value is the driving lens.

```
                           Driver lens at each leg
M     I.1   I.2   I.3   I.4   II.1   II.3  IV.B-1  IV.B-5  V.1   IV.B-2  ship
@owner @owner @owner @owner @ow  @op   @op   @op    @ow    @dom   @ed    @owner
↓      ↓     ↓     ↓     ↓    ↓     ↓     ↓      ↓      ↓      ↓      ↓
ref    SKILL thread remem rem   pause dream migrt  lint   call   migrt  ship
       restr        format skill prose agent script class  outs   stepD bump
```

### What this surfaces

- **Rule adherence** — no leg has multiple drivers; no driver dominates
  outside their domain. The discipline holds.
- **Driver imbalance** — if @owner drives 80% of legs across many sessions,
  the cohort might be under-leveraged. Other personas should drive their
  own domain legs.
- **Specialist usage** — beacon (educator) drove only the migration step.
  That matches their specialist contract. Visualizing it confirms scoped
  use.

### Implementation cost

**Trivial.** Parse `driver:` from each phase artifact's frontmatter. ASCII
table. Already cheap because the field is already required for breakouts
and buildouts; extending to all phases is a small frontmatter convention
addition.

## Where these go in the framework

### v1.0 (already)

- `driver:` field is already required on breakouts and buildouts.
- `_thread.md` already records consolidation events (per `consolidation-format.md`).
- Decisions are pinned to commits.

### v1.1 (proposed)

1. Extend `consolidation-format.md` to include `active_intents:` array
   on commit-scale events.
2. Add `intent:` line to breakout and plan frontmatter (one short statement
   of the document's primary intent).
3. Ship three scripts:
   - `scripts/intent-adherence.sh` — Visualization 1
   - `scripts/intent-window.sh` — Visualization 2
   - `scripts/intent-driver-grid.sh` — Visualization 3
4. Surface in `/storytime-status` — a compact summary of all three.
5. Surface in `/storytime-retro` — adherence becomes a first-class retro
   input, not an afterthought.

### Lint integration

`/storytime-lint` gains check class **ID** (intent drift):

| # | Tier      | Check |
|---|-----------|-------|
| ID1 | advisory | Decision sealed >30 days ago, never touched in code |
| ID2 | advisory | Decision touched once, then dormant 60+ days |
| ID3 | advisory | Active intent count exceeded 10 sustained over 5+ legs (overload signal) |

All advisory. The pre-flight gate is not used for intent drift — drift is a
slow signal, not a blocker.

## Visualization design notes

### Why ASCII

All three visualizations use plain ASCII for the same reason storytime's
plans use ASCII slide decks:

- **Greppable** — output is text, can be searched, piped, embedded in
  remembrance docs.
- **Diff-friendly** — version-controllable, comparable across sessions.
- **No external dependencies** — no chart library, no SVG, no rendering
  step. Works in any terminal, any markdown viewer.
- **LLM-readable** — the next-self loading remembrance can read these
  without an additional renderer.

### Why three visualizations and not one combined

Each answers a different question:

- Adherence: *did we ship what we said?*
- Window: *what are we touching right now?*
- Driver: *is the driver pattern healthy?*

A combined view would be either too dense to read or too lossy to be
useful. Three small focused views, each cheap to generate, beats one
ambitious one.

## Companion documents

- `intent-extraction-user.md` — user-intent extraction analysis
- `intent-extraction-roles.md` — role-intent extraction + flow analysis
