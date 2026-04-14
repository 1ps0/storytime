---
type: reference
name: automation
description: "Four automation tiers and how they gate user prompts. Tutorial is the v1.0 fresh-install default; graduation is adaptive per skill. Load at the start of any skill that prompts the user."
---

# Automation Tiers

Read `specs/.storytime/config.md` → `automation` field. Default for fresh
installs is `tutorial` (V1-007). The user dials down via friction
detection (V1-013) or explicit graduation.

| Tier     | Phase transitions | Breakout start | Post-breakout | Team assembly | Review       | Commit drafts | Pauses surfaced |
|----------|-------------------|----------------|---------------|---------------|--------------|---------------|-----------------|
| tutorial | prompt + explain  | prompt + explain | pause + explain | prompt + explain | inline + explain | full prompt + explain | every nap, shift, compact |
| manual   | prompt + wait     | prompt + wait  | pause + wait  | prompt + wait | inline       | full prompt   | shift, compact  |
| guided   | auto              | auto           | pause + wait  | prompt + wait | inline       | full prompt (quieter if V1-014 learned) | shift, compact |
| auto     | auto              | auto           | auto-proceed  | auto          | present-only | full prompt (V1-001 never skipped) | shift, compact |

**Commits are never auto-approved.** V1-001 is a hard invariant across
all tiers. `auto` tier only automates phase transitions; commits remain
LLM-drafts-user-confirms.

## How to Apply (in every skill that prompts)

```
1. Read config.md at skill start. Default: tutorial.
2. Before any user prompt, check the tier:
   - tutorial → prompt AND include a "why are we doing this?" annotation
   - manual   → prompt and wait for explicit approval
   - guided   → prompt; proceed without explicit "yes" for non-critical steps
   - auto     → skip the prompt, proceed (except commits — never skipped)
3. Post-breakout pause is ALWAYS a pause in tutorial, guided, and manual.
   Only auto skips it.
4. If tier == tutorial, also check tutorial-signals.md for graduation
   candidacy.
```

## Tutorial tier specifics (V1-007, V1-013)

Tutorial is not just "more prompting." Every prompt includes a **why**
annotation — what concept this prompt demonstrates, what the user
should be paying attention to, which reference explains it.

Example:

```
Ready to proceed to ASSEMBLE?

[why we're asking: after SURVEY, storytime normally proposes the team
 before any technical discussion — this ensures lenses are agreed before
 decisions get made. See references/team-assembly.md.]

  [yes]  [show me the survey first]  [tell me more]  [back to tutorial menu]
```

Tutorial tier also **surfaces every pause** (including naps that other
tiers may not show) so the user learns when the framework thinks it
needs to consolidate. See `references/tutorial-signals.md` for
graduation/retention signal rules.

## What "prompted" Means

A prompt is any `[approve / join / defer / pause / cancel]` choice point
or "ready to proceed?" question. It does NOT include:

- Presenting inventory results (always shown)
- Asking clarifying questions (always asked)
- Surfacing errors (always surfaced)

Those are information, not gates. Automation controls gates only.

## Graduation and retention (adaptive)

V1-013: tutorial exit is adaptive. The LLM watches for friction signals
(impatience, skim-approvals, explicit requests, deliberate modifications)
and proposes step-down to `guided`. User confirms. Per-skill, not global.

Retain signals (confusion, backing out, meta-confusion) trigger
**tutorial-plus** — richer explanations, not demotion.

See `references/tutorial-signals.md` for the full catalog and thresholds.

## Reverting

A user can always re-enter tutorial for a skill:

```
/storytime tutorial /storytime-breakout   # re-enter tutorial for one skill
/storytime tutorial all                    # re-enter tutorial globally
```

Graduation state at `.storytime/tutorial-state.md` records per-skill
status and signal counters. Moving back to tutorial preserves the data
(soft reset) unless the user explicitly clears it.
