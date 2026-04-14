---
type: breakout
schema_version: 1
created: 2026-04-13T11:30
session: v1-consolidation
episode: 001
topic: v1-consolidation
subtopic: commit-confirmation-learning
driver: "@platform [compass]"
supporters: ["@operator [tide]", "@skeptic [drift]"]
status: complete
---

# Breakout 1 — Commit Confirmation Learning Speed

## Question

V1-009 says commit confirmation "adapts to user patterns" — single prompt every time initially, but over time the system proposes quieter modes for patterns that have proven safe (proposal L459–464). The open calibration question: **how quickly should the system learn a user's approval pattern before proposing a quieter mode?** Too few samples = reckless (auto-approves commits that shouldn't be batched); too many = feature never fires for real users, making V1-009 an unkept promise.

The sub-problems collapse into one design surface: **what counts as a sample, what counts as a pattern, when does the model have standing to propose the quieter variant?** The secondary surface — "what does quieter mode actually look like, and how is it reset?" — must be answered jointly because the learning-speed numbers mean different things depending on whether the quiet variant is "skip prompt" vs "shorter prompt" vs "batch approve."

## Known / Unknown

**Known:**
- LLM drafts every commit, user confirms every one, no auto-commit (V1-001, proposal L416–419, L256–258).
- Existing automation levels are `manual / guided / auto` and apply to phase gates, not commits (`skills/storytime/references/automation.md` L11–16). Nothing today touches per-commit prompts.
- Tutorial-first onboarding is the fresh-install default; users dial down via the automation setting as trust develops (V1-007, L420–424, L450–453).
- Learning is local and reversible — "prompt me on everything" resets (V1-009, L469–470).
- `_thread.md` is the continuity ledger and decision log (V1-003, L437–439).

**Unknown (this breakout's gap):** sample size to trigger "propose quieter"; signal shape (approved vs modified vs quick accept); pattern scope (global/repo/branch); reset granularity (nuclear vs per-pattern); where quieter-mode state lives; whether it mirrors the automation tiers or introduces a fourth surface.

## Options considered

### Option A — Fixed sample threshold, per-pattern scope

**Shape.** Track exact-match approvals by pattern key (e.g. `path_prefix=docs/`, `file_count≤2`, `keyword=typo`). After **N=5** consecutive approvals in a pattern with zero user edits, surface a one-shot proposal: *"I noticed you've approved the last 5 `docs/`-only commits without changes — want me to prompt less for these? [yes / no / tell me more]."* If accepted, future commits in that pattern get a **shorter prompt** (summary only), not a skipped prompt.

**Pros.** Simple, auditable, deterministic — "5 in a row of the same shape" is a rule a human can reason about. Matches the existing `manual/guided/auto` mental model: quiet mode is a per-pattern `guided` override inside a `manual` user.

**Cons.** N=5 is a guess. A user who commits docs 20×/day fires on day one (maybe too fast). A user who commits docs 3×/week takes two weeks (maybe too slow). Fixed N ignores velocity.

### Option B — Edit-distance based, with confidence window

**Shape.** Every commit captures `(proposed_message, final_message)`. A sample is "clean approval" when token-level edit distance is <5% of the proposed message. A pattern proposes quieter mode with **≥7 samples AND ≥6 clean in the last 7** (rolling window). If the rolling rate drops below 4-of-7 for any reason, the pattern auto-reverts to full prompting (soft reset, no user action).

**Pros.** Richer signal — not just "did they approve?" but "did they approve *what I drafted*?". Self-correcting: if the user starts editing again, the system steps back without manual reset. Directly answers @skeptic [drift]'s icebreaker concern about "vibes vs concrete signals."

**Cons.** More state (must store proposed messages for approved commits — small but real). Edit-distance on natural language is noisy — reformatting bullets can look like a large edit while being semantically trivial.

### Option C — Adaptive velocity-aware (Bayesian-ish)

**Shape.** Each pattern has a Beta-ish belief about its clean-approval rate with a uniform prior. Propose quieter mode when the lower bound of a 90% credible interval on the rate exceeds 80%. A user 10-for-10 triggers at ~8 samples; a user 7-of-10 never triggers (lower bound stays below 80%).

**Pros.** Principled — confidence is mechanical. Scales gracefully across pattern volumes. Single policy knob (the 80% threshold). Feels right for the proposal's "statistically meaningful, few enough to feel responsive" (L487–488).

**Cons.** Harder to explain — "why did the system propose now?" gets a statistics answer, not a story answer. Implementation cost higher (priors, small-sample edge cases). Over-engineered for v1.0 when we don't yet know the real distribution of approval patterns.

## Recommendation

**Option B with constrained scope and explicit reset.**

Edit-distance based learning, scoped **per-repo** (not global, not per-branch), over a small fixed set of pattern keys, with both hard and soft reset mechanisms.

**Concrete shape:**

1. **Pattern keys** (v1.0 ships with three, extensible later):
   - `path_prefix` — top-level directory of changed files. Multi-top-level commits = `mixed` pattern, never eligible for quiet mode.
   - `size_bucket` — `tiny` (≤2 files, ≤20 lines), `small` (≤5 files), `medium` (everything else). Only `tiny` and `small` are eligible in v1.0; `medium` always gets full prompt.
   - `kind_hint` — one of `{typo, docs, config, code, mixed}`, derived from extensions and the LLM's own draft verb. Advisory, not authoritative.

2. **Sample definition.** Clean when final committed message is ≤5% token-level edit distance from the LLM's draft. Anything more is "modified."

3. **Threshold.** **≥7 samples AND ≥6-of-7 clean** in the rolling window. Seven was picked as "a working week of commits in that shape" — earned but responsive. The 6-of-7 rule allows one oddball without blocking.

4. **Quieter mode = shorter prompt, not skipped prompt.** First quiet tier: *"I drafted this commit matching the `docs/` pattern — accept as-is, or show full draft? [accept / show / edit]."* User remains in the loop; only the default presentation changes. This preserves V1-001's no-auto-commit contract. A *second* quiet tier (skip entirely with post-hoc notification) is **explicitly out of scope for v1.0** — data can be collected for it, but it is never proposed in v1.0.

5. **Reset mechanisms:**
   - **Soft reset (automatic):** rolling rate drops below 4-of-7 clean → pattern reverts to full prompting without user action. Logged but not surfaced.
   - **Hard reset (user):** "prompt me on everything again" discards all accumulated pattern data across all patterns in this repo. The pattern file is moved to `.storytime/archive/` with a timestamp (not deleted, per undo-friendliness).
   - **Per-pattern reset (user):** "stop quiet mode for docs" zeros out `docs/` only; other patterns intact.

6. **Scope = per-repo.** Pattern data at `.storytime/commit-patterns.md` (format YAML-or-markdown-table decision deferred). Per-repo is the smallest scope where users have stable "what I commit looks like" habits; per-branch is too fiddly for v1.0.

7. **Tutorial mode interaction.** In `tutorial` automation (V1-007), quiet-mode proposals are deferred — samples collect silently but never surface a proposal while the user is still learning the baseline. Once the user steps down to `guided`, collected data is immediately available and the first proposal may fire if the threshold has already been crossed.

### Complexity and Scale

**Complexity 5 — a focused day's work.** Pattern-keying logic is straightforward (file-list analysis, extension map, size bucketing). Edit-distance is an off-the-shelf library call. Rolling-window accounting is a small state machine. Real work is integration into the commit-draft skill, the hard/soft reset surfaces, and tests for threshold boundaries (exactly 6-of-7, exactly 4-of-7, mixed-pattern commits, empty history, post-reset state).

**Scale 3 (module) — touches the commit-drafting skill, one new reference, one new state file, and the automation surface.** Affected surfaces:
- `skills/storytime/references/commit-drafting.md` (new or extended) — pattern keys, clean-approval rule, threshold math.
- `.storytime/commit-patterns.md` — per-repo state file.
- `skills/storytime/SKILL.md` — a few lines in the Consolidation section pointing at the learning surface.
- `skills/storytime/references/automation.md` — brief note on quiet-mode relationship to `manual/guided/auto`.
- Post-commit hook pathway (V1-009 context) — records the sample.
- `/storytime-lint` — validates `commit-patterns.md` shape (minor).

Not touched: persona system, thread/decision log schema, remembrance, dreams. Self-contained in the commit-drafting module.

## Citations

- `docs/proposals/v1-consolidation.md` L252–270 — commit confirmation contract (adaptive), pattern examples
- `docs/proposals/v1-consolidation.md` L416–424 — LLM drafts / user confirms / tutorial-first onboarding principles
- `docs/proposals/v1-consolidation.md` L459–464 — V1-009 text establishing the learning surface
- `docs/proposals/v1-consolidation.md` L485–488 — open question on learning speed ("statistically meaningful, few enough to feel responsive")
- `docs/proposals/v1-consolidation.md` L450–453 — V1-007 tutorial onboarding interaction
- `skills/storytime/references/automation.md` L11–16 — existing automation tier table `manual/guided/auto`
- `skills/storytime/references/automation.md` L30–38 — what "prompted" means; info is not a gate
- `specs/.storytime/sessions/v1-consolidation/001/icebreaker.md` L99–105 — constraints agreed pre-breakout (kill switch, atomic writes, earning-its-keep)

## Open questions returned to CONVERGE

1. **Edit-distance on markdown is genuinely noisy.** A user who re-wraps bullets at 80 columns registers a large edit even when they semantically approved. Do we normalize (strip whitespace, collapse lists) before distance, or accept the noise? Likely a v1.1 refinement after dogfood data — not a v1.0 blocker, but CONVERGE should note it.

2. **First-time behavior across repos.** A heavy storytime user on their fifth repo has strong priors from repos 1–4. V1.0 ships per-repo fresh-start. If users complain, a v1.x "import my pattern defaults" one-time seed could follow. Confirm per-repo-only is acceptable.

3. **Threshold tuning telemetry.** The 7-sample / 6-clean threshold is a reasoned guess with no data behind it. The system should log "would have proposed at sample N" even when it doesn't, so post-dogfood we can retune. This is a dogfood telemetry decision the plan must include — do not ship without it.

## Participants

- **@platform [compass]** (driver) — framed the surface, sized the three options (fixed-N, edit-distance, Bayesian), landed on Option B as the "principled but shippable" middle. Drove per-repo scoping and the "shorter prompt not skipped prompt" constraint.
- **@operator [tide]** (silent supporter) — no reliability issue fired. Pattern-state file is a standard artifact; atomic-write rule from icebreaker constraint 4 applies without elaboration.
- **@skeptic [drift]** (silent supporter) — no scope creep fired. The "second quiet tier = skip entirely" was explicitly pushed out of v1.0 scope as a drift-prevention measure.
