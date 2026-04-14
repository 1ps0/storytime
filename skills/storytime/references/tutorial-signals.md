---
type: reference
name: tutorial-signals
description: "Nine-signal catalog for tutorial friction detection. Composite rules for graduation and retention. Per-skill scope. Load by any user-facing skill that runs in tutorial automation tier."
---

# Tutorial Friction Signals

Tutorial mode is the fresh-install default (V1-007). It asks about
everything to help the user learn the framework. V1-013 says tutorial
exit is **adaptive** — the LLM watches for friction signals and proposes
stepping down to a lower automation tier, per skill.

This reference is the catalog of signals, composite rules, thresholds,
and where state lives.

## Signal catalog

Nine signals. Each has a direction (graduate vs retain), a pattern, an
initial threshold (V1-027, tunable), and notes.

| # | Signal | Pattern | Direction | Threshold | Notes |
|---|--------|---------|-----------|-----------|-------|
| 1 | Impatience | Response time between prompt and approval shrinks; recent median < 30% of baseline (first 3 prompts of same skill establish baseline) | graduate | 8 prompts showing pattern, same skill | Needs baseline calibration per-skill |
| 2 | Skim approval | User approves verbatim (no edit, no question, no pause) | graduate | 6 consecutive, same skill | Reset counter on any edit, question, or defer |
| 3 | Short-affirmative | Approvals consistently 1-3 tokens ("yes", "ok", "proceed", "just do it") with no engagement | graduate | 8 across same skill | Contrast with substantive approvals |
| 4 | Explicit request | User says "stop holding my hand", "less prompting", "just do it without asking", "get out of tutorial" | graduate | 1 occurrence | Hard signal. Match on intent, not exact wording. |
| 5 | Deliberate modification | User edits commit messages, adjusts personas, renames breakouts — operating the framework | graduate | 4 modifications across same skill | Strongest positive signal; user is steering, not just approving |
| 6 | Clarifying-question repeat | User asks a question that the most recent tutorial explanation already answered | retain | 2 in same skill | Tutorial text isn't landing — refresh framing |
| 7 | Backing-out pattern | User chooses `defer`, `pause`, or `cancel` repeatedly in a skill session | retain | 3 in one session of same skill | Indicates overwhelm — scaffold more, not less |
| 8 | Meta-confusion | User asks "why are you asking me this?" or "what does this do?" about a tutorial prompt | retain | 1 occurrence | Triggers richer explanation; do NOT demote |
| 9 | Self-reported struggle | User says "I don't get this", "confused", "what's going on" | retain | 1 occurrence | Hard retain signal |

## Composite rules (V1-013)

### Graduation

Propose step-down IF:

```
(signal #4 fires) OR
(≥ 2 graduate-direction signals hit threshold in same skill
  AND no retain signals in last 5 prompts)
```

### Retention

Block graduation AND offer tutorial-plus IF:

```
Any retain-direction signal fires → block graduation for next 5 prompts
Two retain signals in one session → propose tutorial-plus (richer "why")
```

### Tutorial-plus (V1-026)

Tutorial-plus is not a new tier — it's an enhancement of tutorial prompts:

- Add "why are we doing this?" annotation to each prompt
- Explain the framework concept the prompt is demonstrating
- Reference the related reference file for deeper reading
- Check understanding ("does this make sense?") before proceeding

Does NOT demote tutorial → guided. The user stays in tutorial; the
tutorial gets *better*.

## Scope

**Per-skill, not global (V1-025).** Completing tutorial for
`/storytime-breakout` graduates the user from breakout tutorials only.
`/storytime-buildout` starts in tutorial mode the first time the user
runs it.

Global graduation is available as an explicit escape hatch
(`/storytime-status tutorial --graduate-all`) but never automatic.

## Proposal UX (V1-024)

When graduation threshold hits, the LLM proposes with named rationale:

```
You've approved the last 6 breakout-start prompts without modification
and your response times are getting faster. You look comfortable with
how breakouts work. Want to drop to `guided` mode for breakouts?

In guided mode, I'll skip the "ready to proceed?" pause but still prompt
on critical decisions.

  [yes, graduate]  [not yet]  [explain what changes]  [stay in tutorial]
```

- **Named rationale** — tells the user WHAT pattern the LLM saw.
- **Explain option** — teaches by naming the quieter mode's behavior.
- **Escape always visible** — the "back to tutorial" path is named in
  every graduation prompt.

## State storage

Signal counters live at `.storytime/tutorial-state.md`:

```yaml
---
type: tutorial-state
schema_version: 1
updated: 2026-04-14T10:00
---

# Tutorial state

## /storytime-breakout
skim_approvals: 4/6
impatience_baseline: 45s (from 3 prompts)
impatience_recent_median: 12s
deliberate_modifications: 2/4
retain_signals_last_5: 0
graduated: false

## /storytime-buildout
skim_approvals: 0/6
graduated: false
(no data yet)
```

Survives `/compact` via remembrance staging — the path to
`tutorial-state.md` is included in remembrance.md so post-compact
skills reload counters.

## Visible progress (V1-024)

Users can query accumulated signals via `/storytime-status tutorial`:

```
Tutorial progress (per skill):

  /storytime-breakout:  4/6 skim-approvals, 2/4 modifications, 0 retain
                        (approaching graduation)
  /storytime-buildout:  no data yet (haven't run)
  /storytime:           1/6 skim-approvals
```

## Interaction with pause surfacing (V1-002, V1-016)

Pause-detection references say nap "may not surface to the user unless
asked." In tutorial mode, **every pause surfaces** (pedagogy): naps
become visible so the user learns when the system thinks it needs a
break. Post-graduation, nap surfacing returns to the default ("may not
surface").

This is enforced by: `pause_posture: nap-proposed` in consolidation
events is always surfaced when the active skill is in tutorial tier.

## Initial thresholds are guesses

Thresholds (6, 8, 2, 4) are reasoned starting values. Dogfood data will
retune them. `/storytime-lint` logs "would have proposed at sample N"
even when graduation doesn't fire, so post-dogfood we can see where the
real distribution sits.

## Validation

Mechanical:

| Check ID | Check |
|----------|-------|
| TS1 | `.storytime/tutorial-state.md` has valid frontmatter if present |
| TS2 | Per-skill sections reference known skill names |
| TS3 | `graduated: true` is accompanied by a `graduated_at` timestamp |

Reasoning (estimator agent):

| Check ID | Check |
|----------|-------|
| TS-R1 | If `graduated: true`, the log shows sufficient signal evidence |
| TS-R2 | Recent "would have proposed" entries cluster or disperse (tuning hint) |
