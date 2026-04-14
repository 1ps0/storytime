---
type: plan
schema_version: 1
created: 2026-04-13T12:00
session: v1-consolidation
episode: 001
driver: "@owner [anchor]"
status: proposed
---

# Plan — v1.0 Consolidation

Synthesis of 6 breakouts into a sequenced implementation plan. Ships as
v1.0.0 after dogfood confirmation.

## Problem visualization

```
 CURRENT (v0.9.0)                      v1.0 (proposed)
 ═══════════════════════               ═══════════════════════

 ┌─ /storytime invoked ─┐              ┌─ always-on memory layer ──┐
 │   SURVEY → ASSEMBLE  │              │                            │
 │      → ICEBREAKER    │              │  commits = clock           │
 │      → BREAKOUT      │              │      │                     │
 │      → CONVERGE      │              │      ▼                     │
 │      → REVIEW        │              │  consolidation events       │
 │      → DONE          │              │  (phase|commit|pause|       │
 └──────────────────────┘              │   session|compact)         │
   "spec workflow"                     │      │                     │
   is the SURFACE                      │      ▼                     │
                                       │  unified artifacts          │
 ┌─ warm-start reactive ─┐              │  in filestructure           │
 │   synthesized each    │              │      │                     │
 │   return              │              │      ▼                     │
 └───────────────────────┘              │  pre-staged remembrance     │
                                       │  (wakeup + prompt)          │
 ┌─ history/decisions.md ┐              │      │                     │
 │   cross-topic stream   │              │      ▼                     │
 └───────────────────────┘              │  post-/compact load         │
                                       │                              │
 ┌─ phase digests ad-hoc ┐              │  spec workflow is ONE       │
 │   per skill            │              │  surface on this loop      │
 └───────────────────────┘              └────────────────────────────┘
```

## Architecture diagram (the v1.0 loop)

```
┌──────────────────────────────────────────────────────────────────────┐
│                       Consolidation Loop (v1.0)                       │
├──────────────────────────────────────────────────────────────────────┤
│                                                                        │
│   working context                                                      │
│        │                                                                │
│        │  (any triggering event)                                        │
│        ▼                                                                │
│   ┌─────────────────────────────────────────────────────────┐          │
│   │  Consolidation event                                      │          │
│   │    scale ∈ {phase, commit, nap, shift, session, compact} │          │
│   │    writes unified frontmatter + digest                    │          │
│   │    atomic: tmp → fsync → mv                               │          │
│   └─────────────────────────────────────────────────────────┘          │
│        │                                                                │
│        ▼                                                                │
│   ┌─────────────────────────────────────────────────────────┐          │
│   │  Thread (per topic)      │  Dreams (optional, .storytime/  │       │
│   │    _thread.md            │   dreams/, cross-ref by commit)│       │
│   │    - consolidation log   │                                │       │
│   │    - decision log        │                                │       │
│   │    - callouts (→/←)      │                                │       │
│   └─────────────────────────────────────────────────────────┘          │
│        │                                                                │
│        │  (pause trigger OR /compact approaching)                       │
│        ▼                                                                │
│   ┌─────────────────────────────────────────────────────────┐          │
│   │  remembrance.md (workday-shaped)                          │          │
│   │    wakeup note + consolidation prompt                     │          │
│   │    pre-staged, loaded post-/compact                       │          │
│   └─────────────────────────────────────────────────────────┘          │
│                                                                        │
└──────────────────────────────────────────────────────────────────────┘
```

## Decisions sealed during CONVERGE

Appending to the V1-001..V1-013 set from the proposal:

- **V1-014** — Commit learning: edit-distance on proposed vs final message,
  ≥7 samples AND ≥6-of-7 clean in rolling window (per-repo scope).
- **V1-015** — Quieter commit mode for v1.0 MVP is a shorter prompt, NOT
  a skipped prompt. Second "skip entirely" tier is out of scope.
- **V1-016** — Six pause signals: repetition, confusion, rut, framing
  loss, context-delta, token-budget (compact only).
- **V1-017** — Pause tier mapping is combination-logic, not intensity.
  Nap=1 signal; shift=2+ or persistent or framing loss alone; compact=
  token-budget (authoritative) or unresolved shift.
- **V1-018** — All remembrance writes use tmp+fsync+mv atomic protocol.
  Orphan `.tmp` older than 5min is a lint warning.
- **V1-019** — Callout syntax: `Callout-> <topic>#<id> (<kind>)` and
  `Callout<- <topic>#<id> (<kind>)` inside decision metadata block.
- **V1-020** — Outgoing callout authoritative, incoming is lint-cached.
  Cache rebuildable from forward scan.
- **V1-021** — Closed 5-kind callout vocabulary for MVP: `depends-on`,
  `affects`, `supersedes`, `superseded-by`, `related`.
- **V1-022** — No pre-built global decisions index. On-demand synthesis
  via `scripts/decisions-view.sh`.
- **V1-023** — `specs/.storytime/history/decisions.md` deleted during
  V1-003 migration; content distributes to per-topic threads.
- **V1-024** — Friction calibration is hybrid: LLM proposal at threshold
  PLUS visible progress via `/storytime-status`.
- **V1-025** — Graduation per-skill, not global. Global graduation is an
  explicit escape hatch only.
- **V1-026** — Retain signals → tutorial-plus (richer "why" explanations),
  not tutorial demotion.
- **V1-027** — Initial friction thresholds ship as stated guesses; telemetry
  opt-in for retuning is a v1.1 question.
- **V1-028** — Migration is opt-in `scripts/migrate-to-v1.sh`, dry-run
  default, `--apply --commit --rollback` flags, mirrors `bump-version.sh`.
- **V1-029** — v1.0 skills refuse to run on unmigrated `specs/.storytime/`
  — pre-flight gate. Escape hatch: pin `storytime@0.9` in plugin.json.
- **V1-030** — Cohort rename deterministic default mapping + per-row
  override via `cohort/_migration.yaml` `keep: true`.

## Implementation sequence

Seven phases. Dependencies shown with `←`. Each item has Complexity + Scale.

### Phase M — Prerequisites (references exist before code)

Depends on: nothing. Unblocks: everything.

- **M.1** — Write `references/consolidation-format.md` — unified frontmatter
  for phase/commit/nap/shift/session/compact events. Includes
  `pause_posture` field (V1-016, V1-017) and `last_consolidation` block.
  - Complexity 3 — a morning. Scale 1 (file).
  - ← nothing. Gates: M.4 (migration step C), I.1.

- **M.2** — Write `references/callouts.md` — V1-019 sigil syntax, V1-020
  authoritative-forward rule, V1-021 kind vocabulary, examples.
  - Complexity 2. Scale 1 (file).
  - Gates: V.1 (callout implementation), M.4 (migration).

- **M.3** — Write `references/tutorial-signals.md` — 9-signal catalog
  from BO5 with composite rules and initial thresholds (V1-027).
  - Complexity 3. Scale 1 (file).
  - Gates: III.2 (tutorial friction detection).

- **M.4** — Write `references/commit-drafting.md` — V1-001 contract
  (draft + confirm), V1-014 learning mechanics, V1-015 quieter mode.
  - Complexity 2. Scale 1 (file).
  - Gates: III.1 (commit learning).

### Phase I — Infrastructure (MVP for dogfood)

Depends on: M.1. Unblocks: II, III.

- **I.1** — Main SKILL "Consolidation" section. Absorbs current Warm
  Start + Thread Checkpointing + Phase-boundary compaction (three
  sections → one). References M.1. Target: main SKILL ≤ 280 lines.
  - Complexity 5 — careful rewrite. Scale 2 (main SKILL + 3 deprecated sections).
  - ← M.1. Gates: everything downstream relies on it.

- **I.2** — Thread schema update: add `last_consolidation{scale,event,at}`,
  `dreams[]`, `remembrance_staged`, `remembrance_path` to `_thread.md`
  frontmatter; add `type: thread` (closes critic W5 from v0.9.0 review).
  Update `references/artifact-types.md`.
  - Complexity 2. Scale 1 (schema).

- **I.3** — `remembrance.md` format + load protocol.
  - Frontmatter: `type: remembrance, schema_version: 1, compact_staged,
    last_commit, active_thread, active_phase`.
  - Body: wakeup narrative + consolidation prompt + state-pinned block.
  - Load protocol: first action of any skill post-/compact reads
    remembrance if present.
  - Complexity 5. Scale 2 (new artifact type + load directive in SKILL).
  - ← I.1.

- **I.4** — `/storytime-remember` skill (explicit pre-compact or pause
  invocation). Writes remembrance.md atomically. Can be invoked manually
  or by model self-detection.
  - Complexity 3. Scale 2 (new skill + frontmatter in artifact-types).
  - ← I.3.

### Phase II — Hooks

Depends on: I. Unblocks: III.

- **II.1** — Pause detection section in main SKILL (BO2 Option C):
  rule-carried signals + `pause_posture` field. Self-check rule text.
  - Complexity 5. Scale 2 (SKILL + ref).
  - ← I.1, M.1.

- **II.2** — Post-commit hook wiring (opt-in via config flag
  `post_commit_hook: enabled`). Hook updates thread, records commit
  consolidation event. Uses atomic tmp+mv (V1-018).
  - Complexity 5. Scale 2 (hook script + install protocol + config).
  - Explicit opt-in. Dry-run installer.

- **II.3** — Dreamer agent (`agents/dreamer.md`) — optional, off by
  default (V1-004). Writes 15-line dream to `.storytime/dreams/dream-
  <sha>.md` on commit. Cheap; runs only if commit crosses interest
  threshold (≥3 files OR decision sealed OR phase boundary).
  - Complexity 3. Scale 2 (agent + dreams dir protocol).

### Phase III — Adaptive systems

Depends on: II. Unblocks: dogfood.

- **III.1** — Commit confirmation learning (BO1 Option B). Edit-distance
  + pattern keys + rolling window + reset mechanisms. State lives at
  `.storytime/commit-patterns.md`. Telemetry hooks: log "would have
  proposed at N" for post-dogfood retuning.
  - Complexity 5. Scale 3 (module).
  - ← M.4, II.2.

- **III.2** — Tutorial friction detection (BO5 Option D). 9-signal
  catalog from M.3. Proposal prompts + status extension. Per-skill
  graduation (V1-025). Tutorial-plus for retain signals (V1-026).
  - Complexity 8. Scale 5 (5 user-facing skills).
  - ← M.3.

### Phase IV — Migration (decomposed Complexity 13 → B-1..B-5)

Depends on: M.1, M.2, I.1, I.2. Blocks: v1.0 release.

- **IV.B-1** — Script scaffold: `scripts/migrate-to-v1.sh` dry-run default,
  `--apply --commit --rollback` flags, pre-flight detection, mirrors
  `bump-version.sh` style. Handles steps E (schema_version backfill) +
  G (decisions.md disposition) inline.
  - Complexity 5. Scale 2 (script + report artifact).

- **IV.B-2** — Cohort rename (migration step D): default mapping table,
  `cohort/_migration.yaml` for overrides, `git mv` + sed for back-refs.
  - Complexity 5. Scale 3 (roster + 5 persona files + fan-out refs).
  - ← IV.B-1.

- **IV.B-3** — Decision-log merge (migration step A): parse v0.9
  `history/decisions.md`, route entries to per-topic threads, preserve
  history via `git mv`. Topic routing: heuristic (regex on decision IDs)
  + user-confirm loop for ambiguous. Uses V1-019 callout syntax for
  cross-topic references.
  - Complexity 8. Scale 3.
  - ← IV.B-1, M.2.

- **IV.B-4** — Thread frontmatter (migration step B) + consolidation-format
  rewrite (step C): update all phase artifacts in existing sessions to
  v1.0 shape.
  - Complexity 5. Scale 3.
  - ← IV.B-1, I.2, M.1.

- **IV.B-5** — `/storytime-lint` M1-M5 migration-readiness check class.
  Advisory, surfaces unmigrated artifacts. Pre-flight gate is the
  authoritative block.
  - Complexity 3. Scale 1 (lint extension).

### Phase V — Callouts + views

Depends on: M.2, I.2, IV. Parallel with III.

- **V.1** — Callout format implementation: `scripts/validate-callouts.sh`
  (regex check), lint integration, reverse-cache materializer (lint pass
  scans for `Callout->`, writes `Callout<-` on next consolidation).
  - Complexity 5. Scale 3.
  - ← M.2.

- **V.2** — `scripts/decisions-view.sh` (BO4): traverse all `_thread.md`,
  parse `### V1-NNN —` blocks, support `--filter`, `--since`, `--tag`,
  `--format={text|csv|graph}`. Shim or replace `export-decisions.sh`.
  - Complexity 3. Scale 2.
  - ← IV.B-3.

### Phase VI — SKILL restructure

Depends on: I, II. Parallel with III-V.

- **VI.1** — Consolidate main SKILL: absorb three sections, integrate
  new sections, trim. Target: 280 lines. Progressive disclosure to new
  references.
  - Complexity 5. Scale 2 (main SKILL + references index).
  - ← I.1, II.1.

- **VI.2** — Process rules reshape: 34 → ~25. Absorb warm-start rules,
  phase-boundary rules, thread checkpointing rules into a smaller
  consolidation rule set. Add rules for callouts, pause detection,
  tutorial adaptation.
  - Complexity 3. Scale 1 (rules section of main SKILL).

### Phase VII — Dogfood + ship

Depends on: I, II, III, IV (V, VI in parallel, must complete before ship).

- **VII.1** — Migrate this repo (storytime itself) to v1.0. First user.
  - Complexity 2 — mechanical once migration script works. Scale 1.
  - ← IV.

- **VII.2** — Run `/storytime` on an external repo (boomballs, music
  studio, or ai-sip-gateway) using v1.0. Fill evaluation scorecard
  (`references/evaluation-scorecard.md`).
  - Complexity 3. Scale 3 (cross-repo).

- **VII.3** — 2–3 weeks of dogfood across at least one compact cycle.
  Log pause proposals (V1-017 false-positive data), commit learning
  triggers (V1-014 telemetry), tutorial friction events (V1-027 data).
  - Complexity 3 (observation + retros).

- **VII.4** — Retro on v1.0 cohort + dogfood data. Confirm or adjust
  V1-014, V1-017, V1-027 thresholds.
  - Complexity 3. Scale 1.

- **VII.5** — Bump to v1.0.0 via `scripts/bump-version.sh 1.0.0`. Tag.
  Push. Update site.
  - Complexity 1. Scale 1.

## Files touched summary

```
NEW:
  references/consolidation-format.md       (M.1)
  references/callouts.md                   (M.2)
  references/tutorial-signals.md           (M.3)
  references/commit-drafting.md            (M.4)
  skills/storytime-remember/SKILL.md       (I.4)
  agents/dreamer.md                        (II.3)
  scripts/migrate-to-v1.sh                 (IV.B-1..B-5)
  scripts/validate-callouts.sh             (V.1)
  scripts/decisions-view.sh                (V.2)
  .storytime/commit-patterns.md            (III.1, per-repo state)
  cohort/_migration.yaml                   (IV.B-2, written by migration)

MODIFIED:
  skills/storytime/SKILL.md                (I.1, II.1, VI.1, VI.2)
  skills/storytime/references/artifact-types.md  (I.2, I.3, I.4)
  skills/storytime/references/automation.md      (III.2, tutorial tier)
  skills/storytime-lint/SKILL.md           (IV.B-5, V.1)
  scripts/check-conventions.sh             (V.1 callout check)
  scripts/export-decisions.sh              (V.2 shim)
  5 user-facing skill SKILL.md files       (III.2 tutorial hooks)

DELETED (via migration):
  specs/.storytime/history/decisions.md    (V1-023)
```

## Risk matrix

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Migration corrupts existing session data | low | critical | Dry-run default; atomic tmp+mv; `git revert`-able commit; pre-flight re-check after apply |
| Pause thresholds mis-calibrated (too sensitive or too lax) | high | medium | Dogfood in VII.3 with logging; V1-027 acknowledged as guesses |
| Commit-learning edit-distance noisy on prose | medium | low | Soft reset auto-recovers; telemetry captures "would have proposed" |
| Tutorial strands users or graduates too fast | medium | medium | Per-skill graduation; explicit user escape (`back to tutorial`); retain signals first-class |
| `/compact` has no pre-hook; remembrance staging depends on heuristic | high | medium | Explicit `/storytime-remember` always available; pause detection uses signals, not just token count |
| Callout reverse-cache drifts if lint never runs | medium | low | Forward callouts still work standalone; drift is visible in lint output |
| `references/consolidation-format.md` blocks migration | certain | high | **Sequencing:** M.1 is first thing shipped. Unblocks IV.B-4. |
| Users pin `storytime@0.9` and never migrate | medium | low | Pre-flight message is friendly; plugin.json pin is supported; advisory lint M5 |

## Non-goals (REQUIRED)

- **Auto-commit mode.** V1.0 never commits without user confirmation.
  *Why skip:* V1-001 is a hard rule; auto-commit removes user agency and
  contradicts "LLM drafts, user confirms."
  *When to revisit:* never, unless a fundamentally different use case
  emerges (e.g., CI automation where user agency is already explicit).

- **Silent adapter for v0.9 formats.** v1.0 refuses to read v0.9 state;
  migration is mandatory (with explicit pin-to-0.9 escape hatch).
  *Why skip:* carrying v0.9 readers forever creates archaeological debt.
  *When to revisit:* if v1.0 adoption data shows migration is a major
  friction point AND lint M5 isn't resolving it.

- **Pre-built global decisions index.** On-demand synthesis only (V1-022).
  *Why skip:* new post-commit write surface for rare read-time value.
  *When to revisit:* if `decisions-view.sh` latency exceeds 1s at real
  repo scale. Option C hybrid is a 1-day change from Option B.

- **Skipped commit prompts (second quiet tier).** V1-015 keeps shorter-
  prompt only.
  *Why skip:* preserves V1-001 "no auto-commit" invariant; learning-speed
  data doesn't exist yet.
  *When to revisit:* v1.1+ after dogfood proves edit-distance signal is
  reliable enough.

- **Global tutorial graduation.** Per-skill only.
  *Why skip:* skills have different mental models; fluency in one ≠ all.
  *When to revisit:* if users consistently graduate all skills within a
  short window, consider an opt-in "graduate from all."

- **Telemetry collection beyond per-install.** No phone-home, no
  aggregation, no cloud service.
  *Why skip:* scope discipline; storytime is a file-based plugin, not a
  SaaS. Honor-system retro feedback is enough.
  *When to revisit:* never as default; could be an opt-in add-on.

- **Archive tier rename (hot/warm/cold → working/consolidated/archived).**
  Deferred from v1.0 (keep the existing names).
  *Why skip:* tide's "smaller migration = safer migration"; the rename
  is purely semantic and can ship in v1.1 without breaking anything.
  *When to revisit:* v1.1, as a minor-version cleanup once v1.0 is stable.

## Success criteria (REQUIRED)

Measurable. Verified at VII.4 retro.

1. **Main SKILL.md ≤ 280 lines.** Current: 410. Measured via `wc -l`.
2. **Migration script migrates this repo cleanly.** `scripts/migrate-to-v1.sh
   --apply` runs on current storytime repo, pre-flight re-check passes.
   `/storytime-lint --all` shows zero M-class failures post-migration.
3. **Remembrance load survives a /compact cycle.** Dogfood: work session
   hits compact; post-compact first action reads remembrance.md; work
   resumes coherently. Verified by user observation.
4. **Pause signals fire at least 3 times** over the dogfood window, with
   at least 1 accepted by the user. Logged in consolidation ledger.
5. **Commit learning proposes at least once** over the dogfood window
   (docs/ pattern most likely). Logged with sample count.
6. **Tutorial friction fires at least once** (even synthetically — user
   explicitly tests "stop holding my hand" wording). Logged.
7. **Cross-topic callout round-trips.** Create callout from topic X to
   topic Y; `/storytime-lint` materializes `Callout<-` on Y; round-trip
   verified by grep.
8. **External repo dogfood completes.** One full `/storytime` run on a
   non-storytime project (VII.2). Scorecard filled.
9. **No regression on v0.9 processes.** Retro scorecard shows plan
   production, citation quality, driver discipline at least equal to
   v0.9.0 baseline (subjective judgment, recorded in VII.4).
10. **Zero data loss reports** across dogfood repos.

## Roadmap

### Now (v1.0.0 — ships at VII.5)

- All phases M through VII.

### Soon (v1.1)

- Archive tier rename (hot/warm/cold → working/consolidated/archived).
  Complexity 2, Scale 2.
- Open callout-kind vocabulary (lint warning on unknown, not error).
  Complexity 2, Scale 1.
- Hybrid decisions index cache (Option C from BO4) if latency data
  warrants. Complexity 3, Scale 1.
- Friction threshold retuning from dogfood data. Complexity 2, Scale 1.
- Commit-learning edit-distance normalization (whitespace/list collapse
  before diff). Complexity 3, Scale 1.

### Later (v1.x+)

- Import-my-pattern-defaults for commit learning cross-repo seed.
  Complexity 5, Scale 3.
- Telemetry opt-in with aggregation path (still no SaaS, but a shared
  corpus mechanism). Complexity 8, Scale 4.
- Second commit quiet tier (skip entirely with post-hoc notification) —
  only after edit-distance signal proves reliable. Complexity 5, Scale 2.
- Cross-persona memory consistency (critic W7 from v0.9.0 review).
  Complexity 8, Scale 3.

### Non-goaled (see Non-goals section)

- Auto-commit mode. Silent v0.9 adapter. Pre-built global index. Skipped
  commit prompts (MVP). Global tutorial graduation. Telemetry-as-default.

## Open items from breakouts (23 returned)

Most are absorbed by V1-014..V1-030. Residuals worth noting:

- **BO1 OQ-1:** edit-distance noise on markdown → addressed in v1.1
  roadmap (normalization).
- **BO2 OQ-4:** tutorial wants every nap surfaced, proposal says "may
  not surface" by default → **resolved by V1-024/V1-026**: tutorial
  mode surfaces all pauses; post-graduation uses default.
- **BO3 OQ-1:** callouts spec standalone or folded → **resolved:
  standalone `references/callouts.md`** (M.2).
- **BO3 OQ-2:** reverse-cache lint-only or hook too → **MVP is lint-only.**
- **BO4 OQ-1:** decisions-view as script or `/storytime-status` subcommand
  → **script.** `/storytime-status` may gain `--decisions` flag in v1.1.
- **BO5 OQ-1:** signal-counter storage → **`.storytime/tutorial-state.md`**
  top-level, per-skill sections. Survives /compact via remembrance link.
- **BO5 OQ-5:** V1-009 and V1-013 share state? → **Independent for MVP.**
  Threshold counters don't compose across skills.
- **BO6 OQ-5:** plugin.json pin mechanism for users who don't migrate →
  **documented in README + lint M5 non-blocking advisory.**
- **BO6 OQ-6:** positive `.storytime/.version` marker → **yes, written by
  migration script** (simpler pre-flight logic).

## Next action

User reviews this plan at REVIEW phase. Challenge, revise, or approve.
On approve, decomposition begins with M.1 (consolidation-format.md).
