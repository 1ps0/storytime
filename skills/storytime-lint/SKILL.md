---
name: storytime-lint
description: "This skill should be used when the user asks to \"lint storytime\", \"validate session\", \"check the spec\", \"storytime hygiene\", \"verify citations\", or wants a structural check of storytime artifacts against the process rules. Fast mechanical checks — no prose, no philosophy. Outputs a pass/fail table."
argument-hint: "[<topic> or <session-path>] — defaults to all sessions"
allowed-tools: [Read, Glob, Grep, Bash, Agent]
---

<!-- version-echo: display "storytime v1.0.1" at start of execution -->
# Storytime Lint — Structural Checks

Fast mechanical validation of storytime artifacts against the process
rules. No prose, no commentary — just pass/fail per check, per artifact.
If you want interpretation, run `/storytime-retro`. This is the
hygiene pass.

## Two Tiers

Lint has two tiers with a hard split:

1. **Mechanical tier** (grep/file checks) — runs `scripts/check-conventions.sh`
   for version consistency, schema_version presence, type field, driver
   field, thread hygiene, icebreaker existence. Zero model reasoning.
   Deterministic. Milliseconds.

2. **Reasoning tier** (estimator task force) — spawns the
   `agents/estimator.md` sub-agent for checks that need prose parsing
   (P4, P5, P7, T4, B6, NG1, SC1, DR1). Each invocation is scoped to
   one check on one artifact, returns one line of PASS/WARN/FAIL.

Checks that violated lint's "grep only" contract in v0.7.2 (P4, P5, T4)
are now in the reasoning tier where reasoning is explicitly allowed.

## Arguments

What to lint: $ARGUMENTS (topic, session path, or empty for all)

## Scope

- **Empty** → lint every session under `specs/.storytime/sessions/`
- **`<topic>`** → lint all episodes of that topic
- **`<session-path>`** → lint one specific directory

## Checks

### Per-survey (`survey.md`)

| #  | Tier       | Check                                                      |
|----|------------|------------------------------------------------------------|
| S1 | mechanical | Has frontmatter with `type: survey`                        |
| S2 | mechanical | Has a coverage fingerprint (commit, paths, ratios)         |
| S3 | mechanical | Fingerprint commit resolves via `git cat-file -e <sha>`    |

### Per-team (`team.md`)

| #  | Tier       | Check                                                      |
|----|------------|------------------------------------------------------------|
| T1 | mechanical | Has frontmatter with `type: team`                          |
| T2 | mechanical | Every persona references a known archetype                 |
| T3 | mechanical | Same-archetype personas have distinct `focus`              |
| T4 | reasoning  | Codenames are non-human (warn on common first names)       |

### Per-breakout (`breakout-*.md`)

| #   | Tier       | Check                                                     |
|-----|------------|-----------------------------------------------------------|
| B1  | mechanical | Has frontmatter with `type: breakout`                     |
| B2  | mechanical | Frontmatter names a `driver`                              |
| B3  | mechanical | Body contains ≥1 citation (file:line, [url], commit, RFC) |
| B4  | mechanical | Body contains `Complexity` AND `Scale`                    |
| B5  | mechanical | Body contains `Recommendation:` section                   |
| B6  | reasoning  | Recommendation is substantive, not a punt                 |
| DR1 | reasoning  | Driver actually drove (voice matches attribution)         |

### Per-plan (`plan.md`)

| #   | Tier       | Check                                                     |
|-----|------------|-----------------------------------------------------------|
| P1  | mechanical | Has frontmatter with `type: plan`                         |
| P2  | mechanical | Has a `Non-goals` section with entries                    |
| P3  | mechanical | Has a `Success criteria` section with entries             |
| P4  | reasoning  | Every plan item states Complexity + Scale in prose        |
| P5  | reasoning  | No plan item has Complexity ≥ 13 as a leaf                |
| P6  | mechanical | At least one ASCII box-drawn visual                       |
| P7  | reasoning  | Citations are substantive (point to specific evidence)    |
| NG1 | reasoning  | Non-goals are specific (not "we won't boil the ocean")    |
| SC1 | reasoning  | Success criteria are measurable (number, threshold, test) |

### Per-buildout (`buildout-*.md`)

| #   | Tier       | Check                                                     |
|-----|------------|-----------------------------------------------------------|
| BO1 | mechanical | Has frontmatter with `type: buildout`                     |
| BO2 | mechanical | Frontmatter names a `driver`                              |
| BO3 | mechanical | Frontmatter has `plan_items` and `decisions`              |
| BO4 | mechanical | Body contains an `Implementation Trace` section           |
| BO5 | mechanical | Every file_created/file_modified listed actually exists   |

### Per-thread (`_thread.md`)

| #   | Tier       | Check                                                     |
|-----|------------|-----------------------------------------------------------|
| Th1 | mechanical | Has frontmatter `type: thread`                            |
| Th2 | mechanical | Has `last_completed_phase` and `last_commit`              |
| Th3 | mechanical | `last_commit` resolves via `git cat-file -e <sha>`        |

### Per-icebreaker (`icebreaker.md`)

| #   | Tier       | Check                                                     |
|-----|------------|-----------------------------------------------------------|
| I1  | mechanical | Exists if `team.md` exists and breakouts are present      |
| I2  | mechanical | Has frontmatter `type: icebreaker`                        |

### Per-citation (across all files)

| #  | Tier       | Check                                                      |
|----|------------|------------------------------------------------------------|
| C1 | mechanical | File citations (`path:line`) — the file exists             |
| C2 | mechanical | File citations — the line number is in bounds             |
| C3 | mechanical | Commit citations — commit exists in the repo              |

Stale citations (file moved, line shifted) are **warnings**, not
failures — the process allows rot but we want visibility.

### Decision staleness (across decision log)

| # | Check                                                       |
|---|-------------------------------------------------------------|
| D1 | Each decision cites at least one code reference             |
| D2 | Cited files exist in the current tree                       |
| D3 | If decision has a `commit` pin, check if cited files changed since that commit (⚠ if yes) |

Decision staleness is **commit-delta based**: compare the decision's
pin commit against HEAD for the cited paths. If the file changed since
the decision was written, it's a staleness warning. The decision may
still be valid — but it needs re-verification.

### Repo-level checks

| #  | Tier       | Check                                                      |
|----|------------|------------------------------------------------------------|
| R1 | mechanical | VERSION, plugin.json, all SKILL.md version-echo lines match |
| R2 | mechanical | site/*.html version strings match VERSION                  |
| R3 | mechanical | README.md version strings match VERSION                    |

Run `R1-R3` only when `--repo` flag is given or scope is empty
(full-repo lint). These catch version drift from manual bumps.
**All repo-level checks are delegated to
`scripts/check-conventions.sh`** — run it first, parse its output.

### Per-consolidation event (v1.0)

Delegated to `references/consolidation-format.md` check table.

| #   | Tier       | Check                                                    |
|-----|------------|----------------------------------------------------------|
| CF1 | mechanical | `type: consolidation` present                            |
| CF2 | mechanical | `schema_version: 1` present                              |
| CF3 | mechanical | `scale` in {phase, commit, nap, shift, session, compact} |
| CF4 | mechanical | `at` parseable as ISO 8601                               |
| CF5 | mechanical | `pause_posture` in allowed set                           |
| CF6 | mechanical | `signals` present when scale ∈ {nap, shift, compact}     |
| CF7 | mechanical | `signals` drawn from allowed vocabulary                  |
| CF8 | mechanical | `commit` resolves via git when scale = commit            |
| CF9 | mechanical | `driver` matches @role or @role [codename] pattern       |
| CF10| mechanical | No orphan `.tmp` files older than 5 minutes              |
| CF-R1 | reasoning | Digest is substantive (phase scale)                      |
| CF-R2 | reasoning | Signals match the event description                     |

### Per-callout (v1.0 cross-topic references)

Delegated to `scripts/validate-callouts.sh`.

| #   | Tier       | Check                                                    |
|-----|------------|----------------------------------------------------------|
| CA1 | mechanical | Callout line matches sigil regex (`Callout->` or `Callout<-`) |
| CA2 | mechanical | `<topic>` resolves to a session directory                |
| CA3 | mechanical | `<decision-id>` resolves to a `### <id> —` header        |
| CA4 | mechanical | `<kind>` in closed vocabulary (depends-on, affects, supersedes, superseded-by, related) |
| CA5 | mechanical | No exact-duplicate (from, to, kind) within one decision  |
| CA-W1 | advisory  | Reverse cache is stale (forward without reverse)        |
| CA-W2 | advisory  | Callout target has `status: superseded`                 |
| CA-W3 | advisory  | Dangling reverse cache (reverse without forward)        |

### Per-remembrance (v1.0 wakeup document)

| #   | Tier       | Check                                                    |
|-----|------------|----------------------------------------------------------|
| RM1 | mechanical | `type: remembrance`, `schema_version` present            |
| RM2 | mechanical | All three body sections present (Wakeup, Prompt, State)  |
| RM3 | mechanical | `last_commit` resolves via git                           |
| RM4 | mechanical | `active_threads[].path` all exist as files               |
| RM5 | mechanical | No orphan `remembrance.md.tmp` older than 5 minutes      |
| RM-R1 | reasoning | Wakeup narrative substantive (not placeholder)           |
| RM-R2 | reasoning | Consolidation prompt names specific files                |
| RM-R3 | reasoning | State pinned captures actual in-flight work              |

### Per-tutorial-state (v1.0 friction tracking)

| #   | Tier       | Check                                                    |
|-----|------------|----------------------------------------------------------|
| TS1 | mechanical | Valid frontmatter if present                             |
| TS2 | mechanical | Per-skill sections reference known skill names           |
| TS3 | mechanical | `graduated: true` paired with `graduated_at`             |
| TS-R1 | reasoning | If graduated, log shows sufficient signal evidence       |
| TS-R2 | reasoning | "would have proposed" entries cluster/disperse tuning hint |

### Per-commit-patterns (v1.0 adaptive learning)

| #   | Tier       | Check                                                    |
|-----|------------|----------------------------------------------------------|
| CD1 | mechanical | Valid frontmatter if present                             |
| CD2 | mechanical | Pattern entries have required fields                     |
| CD3 | mechanical | `status` in {none, quieter-proposed, quieter-active, soft-reset} |
| CD4 | mechanical | `rolling_window` has ≤ 7 entries                         |
| CD-R1 | reasoning | Claimed `clean` count matches rolling window             |
| CD-R2 | reasoning | Pattern key is well-formed                               |

### Per-dream (v1.0 ancillary byproduct)

| #   | Tier       | Check                                                    |
|-----|------------|----------------------------------------------------------|
| DM1 | mechanical | `type: dream`, `commit` present in frontmatter           |
| DM2 | mechanical | `commit` resolves via git                                |
| DM3 | mechanical | Body length ≤ 30 lines (dreams stay small)               |

### Migration-readiness (M-class, v0.9 → v1.0)

| #   | Tier       | Check                                                    |
|-----|------------|----------------------------------------------------------|
| M1  | advisory   | No `specs/.storytime/history/decisions.md` present       |
| M2  | advisory   | All artifacts have `schema_version`                      |
| M3  | advisory   | Cohort `_roster.md` uses non-human codenames             |
| M4  | advisory   | `_thread.md` files have v1.0 fields                      |
| M5  | advisory   | `.storytime/.version` = `1.0` or higher                  |

Full-repo lint surfaces M1-M5 as advisory warnings. The pre-flight gate
in v1.0 skills (V1-029) is the authoritative block.

### Intent graph (IG-class, v1.0.1+)

Per V1-035. Mechanical only; reasoning checks deferred.

| #   | Tier       | Check                                                    |
|-----|------------|----------------------------------------------------------|
| IG1 | mechanical | Every sealed decision with `parent:` has a resolvable target |
| IG2 | mechanical | Every `supersedes:` has a resolvable target              |
| IG3 | mechanical | `tensions:` are symmetric (X tensions Y ↔ Y tensions X)  |

### Prompt-yield (PY-class, v1.0.1+)

Per V1-036. Mechanical only.

| #   | Tier       | Check                                                    |
|-----|------------|----------------------------------------------------------|
| PY1 | mechanical | Frontmatter `type: prompt-yield` present                 |
| PY2 | mechanical | `originating_user` is a `@user [codename]` reference     |
| PY3 | mechanical | `status` in {seeded, hydrating, maturing, crystallized}  |
| PY4 | mechanical | If status=crystallized, `crystallized_into` resolves     |

### Intent tracking (IT-class, v1.0.1+)

Per V1-031, V1-033. Mechanical only.

| #   | Tier       | Check                                                    |
|-----|------------|----------------------------------------------------------|
| IT1 | mechanical | `.storytime/intents.md` header lines match timestamp+session pattern |
| IT2 | mechanical | Each intent entry has required fields (intent, lens, type, source) |
| IT3 | mechanical | `lens:` references known roles only                      |
| IT4 | mechanical | `type:` is in the closed vocabulary                      |
| IT5 | mechanical | `supersedes:` resolves to a prior entry                  |

## Process

1. **Run mechanical tier first:** invoke `./scripts/check-conventions.sh`
   (with `$ARGUMENTS` if provided). Capture its output and exit code.
   If any mechanical check fails, surface those first — they're blockers.
2. **Enumerate artifacts in scope** (sessions, episodes, or the given
   path).
3. **Run per-artifact mechanical checks** (S1-S3, T1-T3, B1-B5, P1-P3, P6,
   BO1-BO5, Th1-Th2, C1-C3, D1-D3) using Grep/Read/Bash.
4. **Run reasoning-tier checks via Estimator.** For each artifact that
   has reasoning checks (P4, P5, P7, T4, B6, NG1, SC1, DR1), spawn the
   estimator agent with one check at a time:
   - `agents/estimator.md` — scoped to the single check
   - Pass: check-id, artifact path, context paths
   - Receive: one-line PASS/WARN/FAIL + justification
5. **Merge results** into a single pass/fail table.
6. **Print summary footer:** `N passed, M warnings, K failed`.
7. **Exit 0** if no failures, **1** if any failures (warnings ok).

## Output Format

Single pass/fail table. No prose. No "analysis". No "consider revising":

```
Session: rate-limiting / episode 001

  survey.md           S1 ✓  S2 ✓  S3 ✓
  team.md             T1 ✓  T2 ✓  T3 ✓  T4 ✓
  icebreaker.md       (no checks — informational artifact)
  breakout-algo.md    B1 ✓  B2 ✗ (no driver)  B3 ✓  B4 ✓  B5 ✓
  breakout-store.md   B1 ✓  B2 ✓  B3 ✓  B4 ✓  B5 ✓
  plan.md             P1 ✓  P2 ✓  P3 ✓  P4 ✓  P5 ✓  P6 ✓  P7 ✓

Citation hygiene:
  breakout-algo.md:23 → src/server.ts:14       ✓
  breakout-algo.md:45 → src/config/redis.ts:5  ⚠ line now at :7 (drift 2)
  plan.md:67           → commit abc123         ✓

Summary: 21 passed, 1 warning, 1 failed
```

## Rules

1. **Two tiers, hard split.** Mechanical checks are grep/file only —
   no interpretation. Reasoning checks delegate to the estimator agent
   with one check per invocation.
2. **Warnings are visibility, not failures.** Stale citations warn.
   Missing required fields fail.
3. **Mechanical tier is fast.** Grep and file existence only. Zero
   Agent calls in this tier.
4. **Reasoning tier is scoped.** Estimator receives one check at a
   time, returns one line. No free-form analysis.
5. **Deterministic for mechanical.** Same input → same output.
   Reasoning tier may drift at the margins; that's why it returns
   justification — so drift is visible.
6. **Exit code signals status.** 0 = clean or warnings only, 1 = failures.
7. **Checks are listed above.** Don't invent new ones without adding
   them to the table first.
8. **Mechanical tier is the primary gate.** Reasoning tier is advisory
   polish. A session that passes the mechanical tier is releasable.
