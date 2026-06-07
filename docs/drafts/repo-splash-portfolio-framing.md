---
type: draft
schema_version: 1
created: 2026-04-26T15:00
name: repo-splash-portfolio-framing
status: cache
purpose: "Reference material for future improvement of the repo's README and/or site/index.html. Originally written as a personal-site landing page (1ps0.github.io/storytime/) but archived here when Option A — repo Pages as canonical landing — was chosen. The text is portfolio-shaped (sales angle for a fresh visitor) rather than docs-shaped (what current users need). Pull from this when polishing README's top section or rewriting site/index.html's hero."
---

# Storytime — portfolio-framing splash (draft / cache)

> a continuity system for AI-coding sessions

Storytime is a continuity system for AI-coding sessions. It assembles
**persona-driven teams** — lenses, not characters — to spec features through
structured conversations, then carries the resulting narrative across
context compactions, restarts, and weeks of drift. Shipped as a Claude
Code plugin at v1.0.1; v2.0 in development with OpenCode as the second
harness via a paradigm-extension adapter.

## What you get

```
/storytime "our public API has no rate limiting"

→ Surveys your code, assembles @owner [anchor], @systems [lattice],
  @critic [forge], @operator [tide]. They investigate, debate, produce:

  specs/.storytime/sessions/rate-limiting/001/
  ├── survey.md          Codebase context + fingerprint
  ├── team.md            Persona definitions
  ├── icebreaker.md      Status quo discussion
  ├── breakout-algo.md   Sliding window vs token bucket
  ├── breakout-store.md  Redis vs in-memory
  └── plan.md            ASCII slides + decisions + roadmap
```

## Why it's interesting

- **Personas are lenses, not characters.** Codenames non-human by
  default. `@critic [forge]` reads as a perspective; `@critic [sarah]`
  reads as a coworker the model owes politeness to.
- **One driver per leg.** Supporters stay silent unless their
  interjection is both useful AND non-distortive. Round-robin
  commentary is the failure mode this prevents.
- **The graph survives.** Decisions are append-only, commit-pinned,
  cross-referenceable via `Callout->` / `Callout<-` sigils. Queryable
  as a typed DAG.
- **Remembrance carries state.** Pre-staged workday-shaped wakeup docs
  survive `/compact` boundaries. Continuity is cheap.
- **Eats its own dogfood.** Storytime specs storytime with storytime.

## Status

- **v1.0.1 shipped** — Claude Code plugin, 19 skills, 3 custom agents,
  ~36 sealed decisions, nascent intent graph
- **v2.0 in spec** — cross-platform refactor with OpenCode as a
  paradigm-extension adapter (not a translation shim)

## Links

- [GitHub](https://github.com/1ps0/storytime)
- [Full docs](https://github.com/1ps0/storytime/tree/main/site) —
  guide, walkthrough, reference
- [v1.0 architecture proposal](https://github.com/1ps0/storytime/blob/main/docs/proposals/v1-consolidation.md)
- [Cross-platform proposal](https://github.com/1ps0/storytime/blob/main/docs/proposals/cross-platform-storytime.md)

## Install (Claude Code)

```bash
# Local install (until marketplace approval)
git clone https://github.com/1ps0/storytime ~/workspace/storytime
claude install-plugin ~/workspace/storytime

# Or per-session
claude --plugin-dir ~/workspace/storytime
```

Then in any conversation:

```
/storytime:storytime "describe your problem"
```

---

## Notes for future use

- The "Why it's interesting" bullets are the punchiest framing in any
  storytime doc right now. Worth porting verbatim to README's "Why" section.
- The terminal-block "What you get" example is more concrete than the
  current README's intro. Consider promoting.
- The status line ("v1.0.1 shipped... v2.0 in spec...") is the kind of
  honest forward-pointing language that builds trust. Update the version
  numbers when applying.
- This was written specifically for portfolio/sales context. For the
  README, soften the "Why it's interesting" bullets to read less
  sales-y and more inviting — but keep the same content.
