---
type: reference
created: 2026-03-29T14:57
session: 2026-03-29-scale-awareness
---

# Scale Impact

How storytime measures magnitude — not complexity, but bigness.

---

## Relationship to CIU

CIU measures **how hard** something is to think about (cognitive complexity).
Scale measures **how big** something is in the world (magnitude of impact).

These are orthogonal dimensions. A task can be:
- CIU 1, Scale 5 — trivially simple but the sheer magnitude changes everything
- CIU 8, Scale 1 — architecturally hard but contained to one small thing
- CIU 3, Scale 3 — moderate work at moderate magnitude

Both appear in plans, breakouts, and roadmaps. Together they answer
"how hard is this?" (CIU) and "how big is this?" (Scale).

---

## The Scale

Scale is 1-5 by default. The number measures how much magnitude changes
the nature of the task — not "how many items" but "how much does size
matter here."

```
╔══════════════════════════════════════════════════════════════════╗
║  SCALE   MEANING                                                ║
║  ─────   ──────────────────────────────────────────────────────  ║
║  1       Contained — one unit, self-contained, no ripple        ║
║  2       Modest — a small multiple, comfortably manageable      ║
║  3       Significant — order of magnitude above baseline,       ║
║                        needs conscious attention                 ║
║  4       Large — crosses a threshold, changes planning          ║
║                  assumptions or requires new coordination        ║
║  5       Massive — changes the nature of the problem itself     ║
╚══════════════════════════════════════════════════════════════════╝
```

### Design Justification

**Why 1-5?**

1-5 was chosen over 1-10 and 1-20 after testing all three:

- **1-10** became a counting system. It worked for discrete items (files,
  repos) but fell apart for continuous dimensions (time, money, data)
  where magnitude matters more than count.
- **1-20** had excellent resolution for countable things but was really
  just a log scale of item counts. 20 levels is too many to hold in your
  head during a planning conversation.
- **1-5** maps to qualitative magnitude shifts — each level represents
  a change in the *nature* of the problem, not just a larger number.
  The difference between Scale 2 and Scale 3 isn't "more items" — it's
  "you now need to pay attention to this dimension."

The 5-point range also parallels well-understood scales: Likert scales,
severity ratings, priority levels. People can assign a 1-5 rating
intuitively without a reference table.

**Why not logarithmic / numeric?**

Exact numbers create false precision. "Scale 7.2" implies a measurement
accuracy that doesn't exist in planning. The 1-5 range forces the
estimator to think in terms of qualitative thresholds:
- Does this cross a planning boundary? (3 → 4)
- Does this change what kind of problem this is? (4 → 5)

**Future-proofing: changing the scale**

If 1-5 proves too coarse for a specific domain, the scale can be
adjusted. When doing so:

1. Record the old scale alongside the new one during transition
2. Historical Scale values keep their original meaning — don't
   retroactively renumber
3. Document the mapping: "Scale 3 (1-5) ≈ Scale 5-6 (1-10)"
4. The *definitions* (contained → modest → significant → large → massive)
   are more stable than the numbers. If the scale changes, the
   definitions anchor the translation.

---

## Dimensions Are Arbitrary

Scale is dimensionless. The *what* it measures is stated in prose,
not encoded in the notation. Any dimension that matters is valid:

```
╔═══════════════╦══════════════╦══════════════╦════════════════╦══════════════════╦═══════════════════╗
║               ║ 1 Contained  ║ 2 Modest     ║ 3 Significant  ║ 4 Large          ║ 5 Massive         ║
╠═══════════════╬══════════════╬══════════════╬════════════════╬══════════════════╬═══════════════════╣
║               ║              ║              ║                ║                  ║                   ║
║ Files         ║ 1 file       ║ 3-5 files    ║ Dozens of      ║ Hundreds, or     ║ Thousands+, or    ║
║               ║              ║              ║ files          ║ every file in    ║ generated/derived ║
║               ║              ║              ║                ║ a system         ║ output at scale   ║
║               ║              ║              ║                ║                  ║                   ║
╠═══════════════╬══════════════╬══════════════╬════════════════╬══════════════════╬═══════════════════╣
║               ║              ║              ║                ║                  ║                   ║
║ People        ║ Just me      ║ 2-3 people,  ║ A team (5-10), ║ Multiple teams,  ║ Org-wide or       ║
║               ║              ║ same room    ║ needs a lead   ║ needs a program  ║ cross-org, needs  ║
║               ║              ║              ║                ║ manager          ║ executive sponsor ║
║               ║              ║              ║                ║                  ║                   ║
╠═══════════════╬══════════════╬══════════════╬════════════════╬══════════════════╬═══════════════════╣
║               ║              ║              ║                ║                  ║                   ║
║ Time          ║ A day or     ║ A sprint     ║ A quarter      ║ Multiple         ║ A year+, crosses  ║
║               ║ less         ║ (1-2 weeks)  ║                ║ quarters,        ║ fiscal/strategic  ║
║               ║              ║              ║                ║ crosses a        ║ boundaries        ║
║               ║              ║              ║                ║ planning cycle   ║                   ║
║               ║              ║              ║                ║                  ║                   ║
╠═══════════════╬══════════════╬══════════════╬════════════════╬══════════════════╬═══════════════════╣
║               ║              ║              ║                ║                  ║                   ║
║ Repos /       ║ This repo    ║ 2-3 repos,   ║ A service      ║ A platform       ║ The whole org's   ║
║ Systems       ║              ║ tightly      ║ cluster (5-10  ║ (dozens of       ║ infrastructure    ║
║               ║              ║ coupled      ║ services)      ║ services)        ║                   ║
║               ║              ║              ║                ║                  ║                   ║
╠═══���═══════════╬══════════════╬══════════════╬════════════════╬══════════════════╬═══════════════════╣
║               ║              ║              ║                ║                  ║                   ║
║ Tickets /     ║ 1 ticket     ║ A handful    ║ A backlog      ║ Cross-team       ║ Cross-org         ║
║ Work Items    ║              ║ (3-5)        ║ (20-50)        ║ epic (hundreds)  ║ program           ║
║               ║              ║              ║                ║                  ║ (thousands)       ║
║               ║              ║              ║                ║                  ║                   ║
╠═══════════════╬══════════════╬══════════════╬════════════════╬══════════════════╬═══════════════════╣
║               ║              ║              ║                ║                  ║                   ║
║ Data /        ║ KB, fits     ║ MB, fits in  ║ Hundreds of    ║ GB range,        ║ Tens of GB+,      ║
║ Resources     ║ anywhere     ║ memory       ║ MB, needs      ║ exceeds single   ║ needs distributed ║
║               ║              ║ comfortably  ║ awareness      ║ machine / GPU    ║ systems or        ║
║               ║              ║              ║                ║ capacity         ║ specialized infra ║
║               ║              ║              ║                ║                  ║                   ║
╠═══════════════╬══════════════╬══════════════╬════════════════╬══════════════════╬═══════════════════╣
║               ║              ║              ║                ║                  ║                   ║
║ Money         ║ Trivial /    ║ A budget     ║ Needs approval ║ Needs director+  ║ Board-level /     ║
║               ║ petty cash   ║ line item    ║ (manager)      ║ approval         ║ fundraising       ║
║               ║              ║              ║                ║                  ║                   ║
╠═══════════════╬══════════════╬══════════════╬════════════════╬══════════════════╬═══════════════════╣
║               ║              ║              ║                ║                  ║                   ║
║ Users /       ║ Just the     ║ A team or    ║ A department,  ║ All internal     ║ External users,   ║
║ Impact        ║ author       ║ a few users  ║ or a user      ║ users, or a      ║ public-facing,    ║
║               ║              ║              ║ cohort         ║ major segment    ║ regulatory scope  ║
║               ║              ║              ║                ║                  ║                   ║
╠═══════════════╬══════════════╬══════════════╬════════════════╬══════════════════╬═══════════════════╣
║               ║              ║              ║                ║                  ║                   ║
║ Dependencies  ║ None         ║ 1-2 direct   ║ A dependency   ║ Cross-cutting    ║ Foundational —    ║
║               ║              ║ deps         ║ chain (3+      ║ (many consumers, ║ everything        ║
║               ║              ║              ║ levels deep)   ║ breaking change) ║ depends on this   ║
║               ║              ║              ║                ║                  ║                   ║
╚═══════════════╩══════════════╩══════════════╩════════════════╩══════════════════╩═══════════════════╝
```

This table is **illustrative, not exhaustive**. Any dimension that
matters for a given task is valid. Physical things, organizational
structures, legal jurisdictions, languages, time zones — if magnitude
in that dimension changes how you approach the work, it gets a Scale
rating.

---

## Usage

### In Roadmaps (alongside CIU)

```markdown
| Phase | Work Item              | CIU | Scale              | Analog                           |
|-------|------------------------|-----|--------------------|----------------------------------|
| Now   | Add auth cache         | 3   | 4 (data)           | Morning's work, GB memory impact |
| Soon  | Migrate auth service   | 5   | 3 (repos), 4 (users) | Day's work, 10 services, all users |
| Later | Multi-region deploy    | 8   | 5 (infra), 3 (time) | Multi-day, changes everything    |
```

### In Breakout Scoping

```
Sub-problems identified:
  1. Token validation    — CIU 2, Scale 1 (contained)
  2. Session migration   — CIU 5, Scale 3 (repos), Scale 4 (users)
  3. Rate limit overhaul — CIU 3, Scale 2 (files)

Note: #2 is CIU 5 but Scale 4 on users — the code change is moderate
but the rollout touches everyone. Plan the rollout, not just the code.
```

### Multiple Dimensions on One Item

When scale differs across dimensions, list them:

```
"CIU 2, Scale 3 (time), Scale 4 (users)"
 → Quick fix that takes a quarter to roll out to all users

"CIU 1, Scale 5 (data)"
 → Flip a flag, but it enables 50GB model loading
```

### Prose Is Required

The number alone is not enough. Always state the dimension and why
it matters:

```
✓  Scale 4 (repos) — touches dozens of services, needs coordinated deploy
✗  Scale 4
```

---

## Evaluation Hygiene

When encountering external projects, tools, or dependencies — or when
assessing storytime's own artifacts — do not weight signals without
understanding what they measure.

```
╔══════════════════════════════════════════════════════════════════╗
║  EVALUATION HYGIENE                                              ║
║                                                                  ║
║  Observe metrics. Do not weight them without understanding       ║
║  what they measure.                                              ║
║                                                                  ║
║  • 1 star ≠ bad. 10k stars ≠ good. 0 issues ≠ stable.          ║
║  • Evaluate fitness for purpose, not popularity.                 ║
║  • A 50-line RFC from 6 months ago may be more valuable          ║
║    than a 500-line doc from yesterday.                           ║
║  • A repo with no PRs might be one person's stable tool.         ║
║    A repo with 200 PRs might be in crisis.                       ║
║                                                                  ║
║  When logging evaluations, record observations and conclusions   ║
║  separately. "3 stars, no issues, last commit 2 months ago"      ║
║  is an observation. "Probably abandoned" is a conclusion.        ║
║  Keep them apart so the conclusion can be challenged without     ║
║  re-gathering the observations.                                  ║
║                                                                  ║
║  This applies to storytime's own artifact assessment:            ║
║  a file's size, age, or location doesn't determine its value.   ║
║  Scale is a property of the work, not a judgment of quality.     ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## Rules

1. Scale is 1-5 by default. The number measures magnitude shift, not count.
2. Always pair the number with prose: dimension and why it matters.
3. Dimensions are arbitrary — any dimension relevant to the task is valid.
4. Multiple dimensions on one item when scale differs across them.
5. Scale and CIU are orthogonal. Report both where effort is estimated.
6. The example table is illustrative, not exhaustive. Don't limit
   dimensions to what's listed.
7. Evaluation hygiene: observe and conclude separately. Don't conflate
   signal with judgment.
8. If the 1-5 scale is adjusted in the future, document the mapping
   to preserve historical meaning. The qualitative definitions
   (contained → modest → significant → large → massive) anchor translation
   across scale changes.
