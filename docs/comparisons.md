---
type: design-doc
created: 2026-03-28T02:04
session: null
---

# Storytime vs Other Spec Approaches

A practical comparison of how Storytime relates to existing tools
and frameworks for technical specification and decision-making.

---

## Quick Matrix

```
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║  Feature              Storytime  Speckit  Kiro   OpenSpec  ADRs  Manual  ║
║  ──────────────────   ─────────  ──────  ─────  ────────  ────  ──────  ║
║  Persona-driven        ●          ○       ○      ○         ○     ○      ║
║  Interactive/inline    ●          ○       ○      ○         ○     ○      ║
║  Visual aids (ASCII)   ●          ◐       ○      ○         ○     ◐      ║
║  Code citations        ●          ◐       ●      ◐         ○     ○      ║
║  Decision tracing      ●          ○       ◐      ◐         ●     ○      ║
║  Persistent memory     ●          ○       ○      ○         ○     ○      ║
║  CI integration        ◐          ●       ●      ●         ○     ○      ║
║  IDE integration       ●*         ●       ●      ○         ○     ○      ║
║  Multi-agent           ●          ○       ○      ○         ○     ○      ║
║  Automation gradient   ●          ◐       ◐      ○         ○     ○      ║
║  Non-goals (required)  ●          ○       ○      ○         ◐     ○      ║
║  Retrospectives        ●          ○       ○      ○         ○     ○      ║
║  Team management       ●          ○       ○      ○         ○     ○      ║
║                                                                          ║
║  ● = strong   ◐ = partial   ○ = absent                                  ║
║  * via Claude Code plugin                                                ║
║                                                                          ║
╚════════════════════════════════════════════════════════════════════════════╝
```

---

## Speckit

**What it is:** A spec-writing toolkit for Claude Code that structures
requirements into templates with defined sections.

**Overlap with Storytime:**
- Both produce structured spec documents
- Both are Claude Code plugins
- Both emphasize non-goals and success criteria

**Where Storytime differs:**
```
Speckit                           Storytime
─────────────────────────         ─────────────────────────
Template-driven                   Conversation-driven
Single-author voice               Multi-persona dialogue
Static output                     Living narrative with chapters
No persistent memory              Cohort persists across sessions
Pre-defined sections              Organic structure from discussion
No breakout/sub-agent support     Mid-conversation breakouts
No retrospective capability       Built-in retro workflow
```

**When to use Speckit instead:** When you need a quick, structured spec
for a well-understood problem and don't need the adversarial perspectives
that personas provide. Speckit is faster for simple features.

**When to use Storytime instead:** When the problem has multiple domains
(e.g., codec math + systems integration + observability), when you need
to surface risks through debate, or when you want decisions traceable
to specific expert rationale.

---

## Kiro (AWS)

**What it is:** AWS's spec-driven development tool that generates
implementation from specifications. Uses "steering" documents to
guide AI code generation with requirements, design, and task breakdown.

**Overlap with Storytime:**
- Both produce structured specs before code
- Both integrate with AI-assisted development
- Both support iterative refinement

**Where Storytime differs:**
```
Kiro                              Storytime
─────────────────────────         ─────────────────────────
Spec → code generation            Spec → human-readable narrative
Requirements as formal lists      Requirements as conversation
Single perspective                Multiple expert perspectives
IDE-native (VS Code ext)          Claude Code plugin
Tied to AWS ecosystem             Cloud-agnostic
Focus: generating correct code    Focus: making correct decisions
No team memory                    Persistent persona cohort
```

**When to use Kiro instead:** When your primary goal is automated code
generation from specs, especially in an AWS environment. Kiro excels
at translating requirements into implementation tasks.

**When to use Storytime instead:** When the hard part is *deciding what
to build*, not generating the code. When you need multiple domain experts
to weigh in. When the narrative and rationale matter as much as the output.

---

## OpenSpec

**What it is:** An open standard for AI-readable specifications that
defines a structured format for requirements, constraints, and
acceptance criteria.

**Overlap with Storytime:**
- Both produce structured specification documents
- Both emphasize machine-readability
- Both can reference code and tests

**Where Storytime differs:**
```
OpenSpec                          Storytime
─────────────────────────         ─────────────────────────
Standard format (YAML/JSON)       Narrative format (Markdown)
Machine-first, human-readable     Human-first, machine-parseable
No authoring process defined      Full authoring process (events)
Schema-driven validation          Citation-driven validation
No personas or conversation       Persona-driven conversation
Interoperability focus            Readability focus
Static documents                  Living documents with chapters
```

**When to use OpenSpec instead:** When you need specs that are consumed
by multiple tools, CI systems, or other AI agents. OpenSpec's structured
format is better for machine consumption.

**When to use Storytime instead:** When specs are primarily read by
humans. When the process of *creating* the spec is as valuable as the
spec itself (because the conversation surfaces insights).

---

## ADRs (Architecture Decision Records)

**What it is:** A lightweight pattern for recording architectural
decisions. Each ADR captures context, decision, status, and consequences.

**Overlap with Storytime:**
- Both record decisions with rationale
- Both are append-only (decisions aren't deleted)
- Both link decisions to context

**Where Storytime differs:**
```
ADRs                              Storytime
─────────────────────────         ─────────────────────────
One decision per document         Multiple decisions per narrative
Written after the decision        Written during the decision
Single author, single voice       Multi-persona dialogue
Minimal context                   Rich narrative context
No process for creation           Full event-driven process
Status field only                 Decisions + non-goals + criteria
No visual aids                    ASCII diagrams and slides
Manual maintenance                Persona memory auto-updates
```

**When to use ADRs instead:** For recording isolated architectural
decisions that don't need the full Storytime process. ADRs are fast
to write and have broad industry adoption.

**When to use Storytime instead:** When a cluster of related decisions
needs to be made together, with debate and tradeoff analysis. Storytime
is ADRs-plus: it records the *process* of deciding, not just the result.

**Hybrid approach:** Use Storytime for the initial design discussion,
then extract individual ADRs from the decision log for long-term
reference. The Storytime decision log (`history/decisions.md`) is
already structured like a collection of ADRs.

---

## Manual Spec Writing

**What it is:** Someone opens a document and writes a spec from scratch.

**Where Storytime differs:**
```
Manual                            Storytime
─────────────────────────         ─────────────────────────
One person's perspective          3-7 domain perspectives
Risks discovered during review    Risks surfaced during authoring
Knowledge stays in author's head  Knowledge persists in personas
"Why did we decide X?" → Slack    "Why did we decide X?" → @persona
No standard format                Consistent narrative structure
No visual aids (usually)          ASCII visual aids throughout
```

**When to use manual instead:** For very small changes, bug fixes, or
problems you fully understand. If you can write the spec faster than
explaining the problem to Storytime, just write it.

**When to use Storytime instead:** For anything cross-cutting, anything
that touches multiple domains, anything where the "right answer" isn't
obvious, or anything where you want the decision rationale preserved.

---

## The Storytime Sweet Spot

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   Problem complexity                                             ║
║   ▲                                                              ║
║   │                                                              ║
║   │   ┌──────────────────────────────┐                          ║
║   │   │     STORYTIME SWEET SPOT     │                          ║
║   │   │                              │                          ║
║   │   │  Multi-domain problems       │                          ║
║   │   │  Tradeoff-heavy decisions    │                          ║
║   │   │  Cross-cutting concerns      │                          ║
║   │   │  Need rationale preserved    │                          ║
║   │   │                              │                          ║
║   │   └──────────────────────────────┘                          ║
║   │                                                              ║
║   │  ┌──────────┐                                               ║
║   │  │  Kiro /  │  ┌─────────────┐                              ║
║   │  │  OpenSpec│  │    ADRs     │                              ║
║   │  │          │  │             │                              ║
║   │  │ Code gen │  │ Record a    │                              ║
║   │  │ from spec│  │ decision    │                              ║
║   │  └──────────┘  └─────────────┘                              ║
║   │                                                              ║
║   │  ┌──────────┐  ┌─────────────┐                              ║
║   │  │ Speckit  │  │   Manual    │                              ║
║   │  │          │  │             │                              ║
║   │  │ Template │  │ Just write  │                              ║
║   │  │ a spec   │  │ it          │                              ║
║   │  └──────────┘  └─────────────┘                              ║
║   │                                                              ║
║   └──────────────────────────────────────────────► Certainty    ║
║     Low                                            High         ║
║     (many unknowns)                          (well understood)  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```
