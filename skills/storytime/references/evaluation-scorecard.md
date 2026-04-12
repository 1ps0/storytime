---
type: reference
name: evaluation-scorecard
description: "Post-session scorecard for evaluating storytime runs. Fill out at retro time. Not a metric — a structured self-check."
---

# Evaluation Scorecard

Fill out one per storytime run, especially on non-storytime repos.
These accumulate into a confidence corpus. Not a grade — a signal.

## The Card

```
Session:  _____________________
Repo:     _____________________
Date:     _____________________
Team:     _____________________

1. Did it produce a plan?                        [ yes / partial / no ]
2. Did breakouts cite code (not just reason)?    [ all / some / none ]
3. Was the team size appropriate to the problem? [ too few / right / too many ]
4. Did the driver pattern hold or degenerate?    [ held / mixed / round-robin ]
5. Did the plan survive contact with buildout?   [ matched / adapted / abandoned ]
6. How many decisions needed revision post-build?[ 0 / 1-2 / 3+ ]
7. Did non-goals prevent scope creep?            [ yes / no non-goals / N/A ]
8. Were there phases that should have collapsed? [ which: _______ ]

Notes: ________________________________________________
```

## Scoring

No numeric score. The pattern across 5+ scorecards reveals:
- Which phases consistently add value vs create ceremony
- Whether team sizing rules are working
- Whether the driver pattern holds under different repo shapes
- What kind of problems storytime handles well vs poorly

## When to Fill Out

- After every `/storytime-retro` (mandatory — retro reviews the card)
- After every `/storytime-buildout` completion
- After any run on a repo that isn't storytime itself
