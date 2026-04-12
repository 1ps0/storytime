---
name: storytime-lint
description: "This skill should be used when the user asks to \"lint storytime\", \"validate session\", \"check the spec\", \"storytime hygiene\", \"verify citations\", or wants a structural check of storytime artifacts against the process rules. Fast mechanical checks — no prose, no philosophy. Outputs a pass/fail table."
argument-hint: "[<topic> or <session-path>] — defaults to all sessions"
allowed-tools: [Read, Glob, Grep, Bash]
---

<!-- version-echo: display "storytime v0.7.2" at start of execution -->
# Storytime Lint — Structural Checks

Fast mechanical validation of storytime artifacts against the process
rules. No prose, no commentary — just pass/fail per check, per artifact.
If you want interpretation, run `/storytime-retro`. This is the
hygiene pass.

## Arguments

What to lint: $ARGUMENTS (topic, session path, or empty for all)

## Scope

- **Empty** → lint every session under `specs/.storytime/sessions/`
- **`<topic>`** → lint all episodes of that topic
- **`<session-path>`** → lint one specific directory

## Checks

### Per-survey (`survey.md`)

| # | Check                                                       |
|---|-------------------------------------------------------------|
| S1 | Has frontmatter with `type: survey`                         |
| S2 | Has a coverage fingerprint (commit, paths, ratios)          |
| S3 | Fingerprint commit resolves via `git cat-file -e <sha>`     |

### Per-team (`team.md`)

| # | Check                                                       |
|---|-------------------------------------------------------------|
| T1 | Has frontmatter with `type: team`                           |
| T2 | Every persona card references a known archetype (owner, operator, critic, domain, systems, platform, skeptic, educator) |
| T3 | If two personas share an archetype, each has a distinct `focus` |
| T4 | Codename is non-human (warn only — soft check)              |

### Per-breakout (`breakout-*.md`)

| # | Check                                                       |
|---|-------------------------------------------------------------|
| B1 | Has frontmatter with `type: breakout`                       |
| B2 | Frontmatter names a `driver`                                |
| B3 | Body contains at least one citation (file:line, [url], commit, RFC) |
| B4 | Body contains `Complexity` AND `Scale` with prose           |
| B5 | Body contains `Recommendation:` section                     |

### Per-plan (`plan.md`)

| # | Check                                                       |
|---|-------------------------------------------------------------|
| P1 | Has frontmatter with `type: plan`                           |
| P2 | Has a `Non-goals` section with entries                      |
| P3 | Has a `Success criteria` section with entries               |
| P4 | Every plan item states Complexity + Scale in prose          |
| P5 | No plan item has Complexity ≥ 13 (must decompose)           |
| P6 | At least one ASCII box-drawn visual                         |
| P7 | Body contains at least one citation                         |

### Per-buildout (`buildout-*.md`)

| # | Check                                                       |
|---|-------------------------------------------------------------|
| BO1 | Has frontmatter with `type: buildout`                      |
| BO2 | Frontmatter names a `driver`                               |
| BO3 | Frontmatter has `plan_items` and `decisions`               |
| BO4 | Body contains an `Implementation Trace` section            |
| BO5 | Every file_created/file_modified listed actually exists    |

### Per-thread (`_thread.md`)

| # | Check                                                       |
|---|-------------------------------------------------------------|
| Th1 | Has frontmatter with `last_completed_phase` and `last_commit` |
| Th2 | `last_commit` resolves via `git cat-file -e <sha>`          |

### Per-citation (across all files)

| # | Check                                                       |
|---|-------------------------------------------------------------|
| C1 | File citations (`path:line`) — the file exists              |
| C2 | File citations — the line number is in bounds              |
| C3 | Commit citations — commit exists in the repo               |

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

| # | Check                                                       |
|---|-------------------------------------------------------------|
| R1 | VERSION, plugin.json, all SKILL.md version-echo lines match |
| R2 | site/*.html version strings match VERSION                   |
| R3 | README.md version strings match VERSION                     |

Run `R1-R3` only when `--repo` flag is given or scope is empty
(full-repo lint). These catch version drift from manual bumps.

## Process

1. Enumerate targets (sessions, episodes, artifacts) based on `$ARGUMENTS`.
2. For each artifact, run the checks in its category in order.
3. Collect results into a per-artifact row.
4. Output a single table grouped by session → episode → artifact.
5. Print a summary footer: `N passed, M warnings, K failed`.
6. Exit with status 0 if no failures, 1 if any failures (warnings ok).

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

1. **No interpretation.** A check either passes or fails. If it needs
   explanation, it's not a lint check — it's a retro.
2. **Warnings are visibility, not failures.** Stale citations warn.
   Missing required fields fail.
3. **Fast.** Grep and file existence checks only. No Agent calls. No
   WebSearch. No model reasoning about the content.
4. **Deterministic.** Same input → same output, every run.
5. **Exit code signals status.** 0 = clean or warnings only, 1 = failures.
6. **Checks are listed above.** Don't invent new ones without adding them
   to the table first.
