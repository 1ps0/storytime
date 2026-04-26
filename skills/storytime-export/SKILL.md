---
name: storytime-export
description: "This skill should be used when the user asks to \"export\", \"convert to\", \"format as\", \"create issues from\", \"make this into ADRs\", \"output for kiro\", \"generate tickets\", or wants to produce storytime output in another system's format. Transforms storytime artifacts into formats other tools can consume."
argument-hint: "<source> as <target-format>"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch]
---

<!-- version-echo: display "storytime v1.0.1" at start of execution -->
# Storytime Export — Format Transformation

Transform storytime artifacts into formats that other systems can consume.
Takes existing storytime output (plans, decisions, team definitions) and
produces equivalent artifacts in another system's conventions.

## Arguments

What to export and target format: $ARGUMENTS

## Supported Export Targets

### Decision Records → ADRs

Transform `specs/.storytime/history/decisions.md` entries into individual
Architecture Decision Record files:

```markdown
# ADR-<NNN>: <Decision Title>

## Status
Accepted

## Context
<From icebreaker discussion and breakout findings>

## Decision
<The decision and rationale>

## Consequences
<From team discussion — what this enables and what it costs>
```

Output to `docs/adr/` or wherever the repo keeps ADRs.

### Plan → GitHub Issues

Transform a `plan.md` roadmap into GitHub issues:
- Each roadmap item becomes an issue
- Complexity maps to labels (e.g., `complexity:3`, `complexity:5`)
- Non-goals become a tracking issue with "won't do" rationale
- Success criteria become acceptance criteria in issue bodies
- Use `gh` CLI to create issues if the user approves

### Plan → Linear/Jira Tickets

Same structure as GitHub issues but formatted for Linear or Jira:
- Linear: use `linear` CLI or produce a CSV import
- Jira: produce a CSV or JSON import format

### Personas → Agent Definitions

Transform cohort persona files into another system's agent format:
- Claude Code agents (`.md` files in `agents/`)
- Kiro agent definitions
- Custom agent specs

Map: archetype → role, background → system prompt, expertise → capabilities.

### Plan → Kiro Spec

Transform a plan into Kiro's spec format:
- Requirements from success criteria
- Tasks from roadmap items
- Design from architecture diagrams (converted from ASCII to Kiro format)

### Session → Markdown Report

Flatten an entire session (survey + team + icebreaker + breakouts + plan)
into a single readable document for sharing outside the repo:
- Executive summary
- Team and their perspectives
- Key decisions with rationale
- Plan with visual aids
- Appendix with full discussion

### Custom Export

If the user specifies a format not listed above:
1. Ask what the target system expects
2. Read an example of the target format if available
3. Map storytime concepts to the target's conventions
4. Produce the output

## Process

1. **Identify source** — which storytime artifacts to export
2. **Identify target** — which format and where to write
3. **Read source material** — load the storytime artifacts
4. **Transform** — map to target format, preserving content and intent
5. **Write output** — to the location the user specifies
6. **Report** — show what was produced and where

## Rules

1. **Preserve content** — export transforms format, not substance.
   Don't lose decisions, rationale, or nuance in translation.
2. **Match target conventions** — if ADRs in this repo use a specific
   template, match it. If GitHub issues use specific labels, use them.
3. **Cite source** — each exported artifact should note its storytime
   origin (e.g., "Exported from storytime session: visual-identity").
4. **Don't modify source** — export is read-only on storytime artifacts.
   The originals stay unchanged.
5. **User approves external actions** — creating GitHub issues, posting
   to Linear, etc. requires explicit approval per batch.
