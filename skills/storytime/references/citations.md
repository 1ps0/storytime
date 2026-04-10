---
type: reference
name: citations
description: "Citation formats per evidence source, evidence hierarchy, when to web search, grounding challenge pattern. Load when a claim needs evidence or when personas need to ground external statements."
---

# Citation Formats

Claims must be grounded. Use the format that matches the source:

```
Code:      src/middleware/auth.ts:32 — JWT tier extraction
Repo file: docs/api-design.md:15 — "all public endpoints require auth"
Lib docs:  [redis.io/commands/zrangebyscore] — sorted set range query
Git:       commit abc123 — "revert Opus decoder, CGO dependency blocker"
External:  RFC 6585 §4 — 429 Too Many Requests status code
Web:       [blog.example.com/redis-sliding-window] — benchmark comparison
```

## Evidence Hierarchy (strongest to weakest)

1. **Code** — the actual runtime truth. If it's in the code, it's fact.
2. **Git** — factual record of what changed and when. Needs interpretation.
3. **Repo files** — READMEs, ADRs, config comments. Describes intent, may be stale.
4. **Library/API docs** — official documentation for dependencies. Authoritative
   for external system behavior. Fetch via WebFetch when needed.
5. **External standards** — RFCs, specs, compliance docs. Authoritative for protocols.
6. **Web research** — blog posts, benchmarks, SO answers, CVE databases. Useful
   but verify freshness. Use WebSearch to find, WebFetch to read.

Personas should reach for the strongest available evidence. A claim about
code behavior cites code. A claim about design intent cites a repo file.
A claim about how Redis works cites Redis docs (fetched via web). A claim
about HTTP status codes cites the RFC.

## Grounding Challenge

If a persona makes a claim without grounding, other personas should
challenge: **"can you ground that?"** This is one of the trigger
conditions for a supporter to break silence (see `driving-persona.md`).

Ungrounded external claims get the same skepticism as ungrounded code
claims. "I think Redis supports X" should become "Let me check the Redis
docs" → WebSearch → WebFetch → cite.

## When to Web Search

Personas should proactively research when discussing external systems,
libraries, or protocols they're not certain about. The team should treat
web research as a first-class grounding source when the claim is about
anything outside the repo.

**Workflow:**
1. Identify the claim needs external evidence (library behavior, protocol
   spec, benchmark result, known issue).
2. WebSearch for the authoritative source (official docs > blog posts).
3. WebFetch the page to get the actual content.
4. Cite with format: `[source-url] — one-line summary`.

**Don't cite:**
- Search result snippets without fetching (they can mislead).
- Blog posts for questions the official docs answer.
- Ancient references when the library version has moved on.

## Multi-Source Grounding

A single claim can stack evidence from multiple sources:

> "The rate limiter uses Redis sorted sets because (a) Redis is already
> in the stack (`src/config/redis.ts:5`), (b) sorted sets support
> ZRANGEBYSCORE for sliding-window queries
> ([redis.io/commands/zrangebyscore]), and (c) we tried in-memory counters
> in commit abc123 and reverted due to multi-instance sync issues."

Code + docs + git = a claim that's hard to knock down.
