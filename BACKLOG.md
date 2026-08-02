# Storytime Backlog

Enhancement ideas, organized by theme. Items move to the top of
their section as they become more urgent or well-defined.

---

## Board Unification Debts (v1.1)

Ingested 2026-08-02 from the board × storytime design session
(claude.ai; staged as `storytime-fix-todos.md`, archived to
`docs/drafts/` after ingest). Companion remembrance:
`specs/.storytime/sessions/board/remembrance-board-x-storytime.md`
(topic `board`). `Callout->` targets below reference BOARD-NNN ids
staged in that document and extracted into the topic thread
(`sessions/board/_thread.md`, absorbed 2026-08-02).

Severity: **blocking** = the board cannot be trusted until fixed.
**Structural** = the board works but degrades or lies at the edges.

Ordering: FIX-000 → FIX-004 (keystone) → FIX-001-near, FIX-002,
FIX-003 in any order → FIX-005 → FIX-001-far alongside the v1.2
command-set work.

### FIX-000 · Stable identity at creation

Prerequisite · rearrangement · Callout-> board/BOARD-P1

**Problem:** only decisions carry ids (TOPIC-NNN). Dreams, questions,
candidates, and directives are anonymous prose blocks.

**Consequence:** no fold can track an item across events; the board
loses object permanence — items teleport instead of migrate, which
destroys the perceptual training the whole grammar exists to produce.

**Fix:** every item kind mints an immutable id at creation
(topic-scoped counter or ulid). Ids are never reused and never
renamed.

**Acceptance:** lint fails on any id-less item; two folds spanning a
retitle resolve to the same id.

**Target:** v1.1 — blocks FIX-001, FIX-002, FIX-004.

### FIX-001 · Markdown-as-database

Blocking · containment is append, full fix is rearrangement ·
Callout-> board/BOARD-010, board/BOARD-P3

**Problem:** truth is stored as prose conventions — sigil lines,
ascii boxes, frontmatter — and read back by grep. Format drift is a
live threat; the lint exists because of it.

**Consequence:** a truth surface that parses prose can silently lie.
One off-format persona line and an item drops or misstates. A board
that can lie is worse than no board.

**Fix, near (append):** the board reads only the derived read model
(state.json). Zero grep of session markdown anywhere in the board
path. The fold owns all parsing and fails loudly — it never emits
partial state.

**Fix, far (rearrangement):** BOARD-P3 — invert selected files to
data-first with prose rendered from them. Decisions and items first;
narrative (breakouts, icebreakers, dreams) stays prose-canonical.

**Acceptance:** board.html renders from a fixture state.json with the
repo absent; the fold on malformed input exits nonzero with file and
line, never partial output.

**Target:** near v1.1 · far v1.2+.

### FIX-002 · Topic silos vs the global glance

Structural · Callout-> board/BOARD-006

**Problem:** `sessions/<topic>/` makes cross-topic state
second-class; reverse callouts are lint-cached, i.e. eventually
consistent.

**Consequence:** collisions, tensions, and shared bedrock live
between topics — exactly what the board must show first. The global
glance is the product.

**Fix:** the fold is global by construction — one state.json across
all topics. Reverse callouts are materialized inside every fold run;
the lint cache is demoted to an optimization. Cross-topic tensions
and collisions become first-class fold outputs.

**Acceptance:** a tensions edge spanning two topics renders dashed on
the board within one fold cycle, with no lint invocation required.

**Target:** v1.1.

### FIX-003 · Ceremony-shaped triggers

Blocking for freshness · Callout-> board/BOARD-010 (event stream)

**Problem:** state updates on skill invocation; the phase machine is
the only clock.

**Consequence:** drift accumulates during ordinary hacking between
storytime runs — the board is stalest exactly when it matters most.

**Fix (append):** event hooks beyond the six consolidation scales —
post-commit, post-test-run, PR state change, and an idle heartbeat —
each firing fold-then-render. Hooks are guardrail-grade: silent while
working, surfaced only on failure.

**Acceptance:** a commit made outside any storytime session updates
state.json within one hook cycle; a hook failure lands in the alarm
lane, not stderr oblivion.

**Target:** v1.1.

### FIX-004 · Append-only without a first-class fold

Blocking · keystone · Callout-> board/BOARD-010 (read model)

**Problem:** "current state" is derived by convention and on-demand
scripts from append-only logs. No canonical artifact owns the
reduction — supersedes resolution, latest-wins, adherence and probe
overlays.

**Consequence:** every consumer re-derives or trusts a cache, and a
stale cache on a truth surface is the cardinal failure.

**Fix:** the fold becomes a versioned artifact — one script, one
output, schema version from day one. Consolidate invokes it.
Supersedes, adherence, and probe overlays are applied inside the fold
and nowhere else in the repo.

**Acceptance:** the fold is deterministic — two runs with no
intervening events produce byte-identical state.json; schema changes
require an explicit version bump; nothing else in the repo computes
"current."

**Target:** v1.1. This is the keystone: FIX-001-near and FIX-002 land
inside it.

### FIX-005 · Voice-shaped output, unowned freshness

Structural · Callout-> board/BOARD-P2

**Problem:** outputs are persona conversation — the original
complaint, worn by the human. Remembrance is model-shaped with no
machine twin. One-driver-per-leg assigns speech, not maintenance: no
persona owns keeping an item's state fresh.

**Consequence:** the record grows while the readable surface starves;
items rot with nobody accountable.

**Fix:** consolidation dual-emits — remembrance for the model, state
delta for the surface, same event, same commit. Add `owner:` to item
frontmatter, a cohort member accountable for freshness; lint flags
items untouched by their owner across N consolidations. Threads
remain the record, the board is the read surface, and personas keep
their voices in the drill-down — never in the glance.

**Acceptance:** every consolidation commit contains both artifacts;
every item carries an owner; staleness surfaces as an amber age
marker on the board, not a lint lecture.

**Target:** dual-emit v1.1 · ownership v1.2.

## Workflow Enhancements

- **Branching narratives.** When the team reaches a fork (two viable
  approaches), run both as parallel breakouts and present a
  side-by-side comparison slide.

- **Conflict resolution protocol.** When two personas disagree and
  neither yields, escalate to the user with a structured "here's
  what A thinks, here's what B thinks, here's what's at stake."

- ~~**Warm-start sessions.**~~ IMPLEMENTED — dynamic narrative preamble
  synthesis, `_thread.md` bookmark, episode structure, survey delta mode.
  See `references/warm-start.md`.

- **Progressive detail.** Let the user set a depth level (sketch /
  standard / deep). Sketch produces team + 1-page plan. Deep
  produces full breakouts with prototypes and benchmarks.

- ~~**Checkpoint saves.**~~ IMPLEMENTED — `_thread.md` updated at every
  phase boundary, "park it here" support, mid-session resumption via warm start.

## Persona System

- **Persona performance tracking.** Track which personas' predictions
  came true vs which were wrong. Over time, calibrate how much
  weight to give each persona's opinions on different topics.

- **Persona templates by domain.** Pre-built persona definitions
  for common domains: frontend, backend, mobile, data, security,
  devops, ML. User picks from menu instead of defining from scratch.

- **Persona inheritance.** A "senior backend" persona inherits from
  a "backend" template but adds seniority-specific traits (skepticism
  about rewrites, preference for incremental changes).

- **Persona voices in commit messages.** When committing code that
  resulted from a Storytime session, optionally include which
  personas contributed to the decision in the commit message body.
  Creates a traceable link from git history to the narrative.

- **Persona disagreement log.** Track cases where a persona was
  overruled. Useful for retrospectives: "Raj warned about X and
  we ignored it — turns out Raj was right."

## Integration

- **GitHub PR integration.** When a Storytime plan leads to a PR,
  auto-link the PR description to the spec directory. Include a
  summary of the decisions that drove the implementation.

- **CI citation validation.** Run `validate-citations.sh` as a
  CI check. Fail the build (or warn) when Storytime documents
  reference code that no longer exists.

- **Slack/Discord notifications.** Post a summary to a channel
  when a Storytime session completes. Useful for team visibility
  when the permanent cohort represents real team members.

- **Decision search.** A tool or skill that searches across all
  decision logs for a keyword. "What did we decide about caching?"
  → returns all decisions mentioning caching with links.

- **Export formats.** Export plan.md as: PDF (via pandoc), Confluence
  page, Notion page, GitHub wiki page. ASCII art survives all of
  these.

## Multi-Repo / Distribution

- **Plugin registry.** Publish storytime to a Claude Code plugin
  marketplace or GitHub releases so other projects can install it
  without cloning the repo.

- **Shared cohort across repos.** A "meta-cohort" that lives outside
  any single repo (e.g., in `~/.storytime/cohort/`) and represents
  org-level expertise. Project-level cohorts override or extend.

- **Org-level decision graph.** Aggregate decisions across repos
  into a single graph. "Show me all security-related decisions
  across all projects." Requires a lightweight indexing service
  or a local aggregation script.

- **Template marketplace.** Share persona templates, workflow
  configurations, and visual aid styles across teams. "Install the
  security-review template" → gets a pre-built team for security
  audits.

## Output Quality

- **Smarter visual aids.** Detect when a table would be better than
  a diagram, or when a flow chart would be better than a list.
  Currently all visual decisions are implicit.

- **Citation density scoring.** Rate each document section by how
  well-cited it is. Flag sections that make claims without evidence.

- **Reading time estimates.** Add "~5 min read" to document headers
  based on word count and visual aid density.

- **Diff-friendly output.** Structure documents so that git diffs
  are meaningful. Avoid long lines that create noisy diffs when
  one word changes.

## Developer Experience

- ~~**`/storytime-breakout`** — Standalone breakout skill.~~ IMPLEMENTED —
  focused investigation with 2-3 personas without the full pipeline.

- ~~**`/storytime-undo`** — Cancel/undo at any granularity.~~ IMPLEMENTED —
  fine (last phase), medium (episode), coarse (thread), surgical (specific
  file), and redo (undo + retry).

- ~~**`/storytime status`**~~ IMPLEMENTED — `/storytime-status` shows
  active cohort, recent sessions, specialist contracts, stale
  citations. BOARD-P5 (see Board Unification Debts) proposes the
  board as this surface's successor.

- **`/storytime diff <topic>`** — Show what changed between the
  original plan and the current code. Like a continuous retro.

- **`/storytime replay <session>`** — Re-read a past session and
  summarize the key decisions and rationale. Quick refresher.

- **Onboarding mode.** New team member reads through Storytime
  narratives to understand why the codebase is shaped the way it
  is. Better than reading code comments alone.

- **Interactive mode improvements.** Let the user "rewind" a
  conversation to a specific beat and re-run from there with
  different constraints. "What if we HAD included FreeSWITCH?"

## Experimental

- **Real-person mapping.** Map personas to actual team members.
  Kim represents the real Kim's domain knowledge. When the real
  Kim reviews a PR, Storytime can pre-populate their likely
  concerns based on the persona's history.

- **Audio narration.** Generate a podcast-style audio version of
  the icebreaker using text-to-speech with different voices per
  persona. For teams that prefer listening over reading.

- **Live collaboration.** Multiple users in a Claude Code session
  each "inhabit" a persona and contribute their real expertise
  through that lens. Hybrid human-AI team discussion.

- **Decision impact scoring.** After implementation, measure which
  decisions had the most impact (positive or negative) on the
  outcome. Feed this back into persona calibration.
