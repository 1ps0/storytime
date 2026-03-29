# Complexity Integration Units (CIU)

How Storytime measures effort — not in time, but in complexity.

---

## Why Not Time

Time estimates are human-centric. An LLM doesn't experience "15 minutes"
the way a developer does. What actually varies is the complexity surface:
how many files to read, how many interdependencies to reason about, how
many decisions to evaluate, how much context must be held simultaneously.

CIU measures the **cognitive integration cost** — how much reasoning must
be woven together to produce a coherent output.

---

## The Scale

```
╔═══════════════════════════════════════════════════════════════════╗
║  CIU    COMPLEXITY                     HUMAN ANALOG              ║
║  ────   ───────────────────────────    ───────────────────────── ║
║                                                                   ║
║  1      Single-file, single-concept    "Quick fix"                ║
║         No cross-cutting concerns      A few minutes of thought   ║
║         One decision, obvious answer                              ║
║                                                                   ║
║  2      Few files, one system          "Straightforward task"     ║
║         Linear dependencies            An hour of focused work    ║
║         2-3 decisions, clear tradeoffs                            ║
║                                                                   ║
║  3      Multiple files, one system     "Meaningful chunk"         ║
║         Some cross-cutting concerns    A morning's work           ║
║         5+ decisions, some ambiguity                              ║
║                                                                   ║
║  5      Cross-system, multiple owners  "Solid day of work"        ║
║         Significant dependencies       Needs design before code   ║
║         Requires breakout discussions                             ║
║                                                                   ║
║  8      Architectural, multi-system    "Multi-day effort"         ║
║         Deep dependency chains         Needs team alignment       ║
║         Many competing constraints                                ║
║                                                                   ║
║  13     Foundational change            "Sprint-sized"             ║
║         Touches everything             Needs phased rollout       ║
║         Unknown unknowns likely                                   ║
║                                                                   ║
║  21+    Rewrite / new system           "Epic / quarter project"   ║
║         Unbounded complexity           Needs decomposition first  ║
║         Must be broken into sub-CIUs                              ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

The scale uses Fibonacci-like numbers because complexity is nonlinear —
an 8 is not "twice as hard" as a 4, it's qualitatively different.

---

## What Drives CIU

CIU is a composite of observable complexity signals:

| Signal                    | Low (1-2)           | Medium (3-5)          | High (8+)              |
|---------------------------|---------------------|-----------------------|------------------------|
| Files touched             | 1-3                 | 4-10                  | 10+                    |
| Systems involved          | 1                   | 1-2                   | 3+                     |
| Decision count            | 1-2                 | 3-7                   | 8+                     |
| Dependency depth          | None/linear         | Some branching        | Deep chains            |
| Ambiguity                 | Clear path          | 2-3 viable approaches | Unknown unknowns       |
| Cross-cutting concerns    | None                | Some                  | Pervasive              |
| Persona agreement         | Unanimous           | Mild debate           | Fundamental disagreement|
| Prior art state           | Clean or none       | Some stale docs       | Contradictory specs    |

---

## Where CIU Appears

### In plan.md roadmaps

```markdown
## Roadmap

| Phase | Work Item                    | CIU | Human Analog        |
|-------|------------------------------|-----|---------------------|
| Now   | Add auth middleware           | 3   | A morning's work    |
| Now   | Update API schema            | 2   | Straightforward     |
| Soon  | Migrate session storage      | 5   | Needs design first  |
| Later | Multi-tenant isolation        | 13  | Sprint-sized        |
```

### In breakout scoping

When identifying sub-problems in the icebreaker, estimate CIU per
breakout to help decide whether to parallelize or serialize:

```
Sub-problems identified:
  1. Auth token validation   — CIU 2 (straightforward)
  2. Session migration       — CIU 5 (needs design, cross-system)
  3. Rate limiting overhaul  — CIU 3 (meaningful but contained)

Recommendation: Parallelize 1+3, serialize 2 (blocking dependency)
```

### In success criteria

CIU can calibrate expectations for what "done" looks like:

```
Success criteria:
  - Auth flow consolidated (CIU 5 total across 3 sub-items)
  - No more than 2 CIU of residual work identified as "soon"
  - All CIU 8+ items decomposed into sub-CIUs ≤ 5
```

---

## Rules

1. **Always pair CIU with the human analog.** The number alone is
   opaque to people unfamiliar with the scale.
2. **CIU ≥ 13 must be decomposed.** If a work item is 13+, break it
   into sub-items before planning implementation.
3. **CIU is assessed by the team, not dictated.** Personas may disagree
   on complexity — that disagreement is signal. If the OPERATOR says 8
   and the DOMAIN expert says 3, the gap reveals hidden operational
   complexity.
4. **CIU is not a promise.** It's a complexity signal, not a contract.
   Real work reveals complexity that estimation misses.
5. **CIU applies to any scoped work** — breakouts, roadmap items,
   success criteria, specialist contracts.

---

## CIU + Scale

CIU measures **how hard**. Scale Impact measures **how big**. They are
orthogonal and both appear wherever effort is estimated.

```
CIU 3, Scale 4 (repos) — morning's work, but touches dozens of services
CIU 8, Scale 1 (files) — hard problem, contained to one module
CIU 1, Scale 5 (data) — flip a flag, enables 50GB model loading
```

See `${CLAUDE_PLUGIN_ROOT}/docs/scale-impact.md` for the full Scale
specification, dimension examples, evaluation hygiene, and design
justification.
