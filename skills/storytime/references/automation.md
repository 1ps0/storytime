---
type: reference
name: automation
description: "Three automation levels and how they gate user prompts. Load at the start of any skill that prompts the user."
---

# Automation Levels

Read `specs/.storytime/config.md` → `automation` field. Gate prompts:

| Level    | Phase transitions | Breakout start | Post-breakout | Team assembly | Review       |
|----------|-------------------|----------------|---------------|---------------|--------------|
| manual   | prompt + wait     | prompt + wait  | pause + wait  | prompt + wait | inline       |
| guided   | auto              | auto           | pause + wait  | prompt + wait | inline       |
| auto     | auto              | auto           | auto-proceed  | auto          | present-only |

## How to Apply (in every skill that prompts)

```
1. Read config.md at skill start. Default: guided.
2. Before any user prompt, check the level:
   - auto  → skip the prompt, proceed
   - guided → prompt, but proceed without explicit "yes" for non-critical steps
   - manual → prompt and wait for explicit approval before every step
3. Post-breakout pause is ALWAYS a pause in guided and manual.
   Only auto skips it.
```

## What "prompted" Means

A prompt is any `[approve / join / defer / pause / cancel]` choice
point or any "ready to proceed?" question. It does NOT include:
- Presenting inventory results (always shown)
- Asking clarifying questions (always asked)
- Surfacing errors (always surfaced)

Those are information, not gates. Automation controls gates only.
