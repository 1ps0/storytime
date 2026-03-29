# Timestamps

How storytime tracks time across documents, personas, decisions, and archives.

---

## The Timestamp Principle

> **If git can answer it, don't duplicate it.
> If it's a semantic event that git can't distinguish from a file edit,
> timestamp it explicitly.**

Git tracks when files were edited. Storytime tracks when things *happened* —
when a persona was last active in a session, when a decision was revisited,
when an artifact moved from hot to cold. These are semantic events that look
like ordinary file edits to git but mean something specific to storytime.

---

## Universal Frontmatter

Every markdown file that storytime produces includes at minimum:

```yaml
---
type: <document-type>
created: <YYYY-MM-DDTHH:MM>
session: <session-id | null>
---
```

| Field     | Description                                            |
|-----------|--------------------------------------------------------|
| `type`    | Document type: survey, team, icebreaker, breakout, plan, rollup, persona, decision, absorption, retrospective, session-summary |
| `created` | When this document was first written. ISO 8601 with minute precision. |
| `session` | The session that produced it (e.g., `2026-03-29-timestamps`), or null for documents created outside a session. |

These three fields are non-negotiable. Everything else is format-specific.

---

## Timestamp Granularity

```
╔═══════════════════════════════════════════════════════════════════╗
║  GRANULARITY    FORMAT                 WHEN TO USE                ║
║  ───────────    ──────────────────     ────────────────────────── ║
║                                                                   ║
║  Day            YYYY-MM-DD             Decisions, inception dates, ║
║                                        archive transitions,       ║
║                                        reviews. Most storytime    ║
║                                        timestamps use this.       ║
║                                                                   ║
║  Minute         YYYY-MM-DDTHH:MM       Session start/end, document║
║                                        creation time. When you    ║
║                                        need to order events       ║
║                                        within a single day.       ║
║                                                                   ║
║  Approximate    YYYY-MM or YYYY-Qn     Inferred/backfilled dates  ║
║                                        where exact date isn't     ║
║                                        recoverable. Mark with ~.  ║
║                                        e.g., ~2026-02 means       ║
║                                        "sometime in Feb 2026."    ║
║                                                                   ║
║  Git-derived    (commit SHA)           When the authoritative     ║
║                                        timestamp is in git, store ║
║                                        the SHA and let git resolve║
║                                        the date. Used in survey   ║
║                                        fingerprints.              ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

### Coarseness Markers

When a timestamp is inferred rather than recorded at the time of the event,
mark its confidence level:

```yaml
# Exact — recorded when it happened
created: 2026-03-29T14:30

# Inferred from git — high confidence, exact date
created: 2026-03-24              # from: git log
created_confidence: git-derived

# Inferred from context — medium confidence, approximate
created: ~2026-02                # from: slack thread mention
created_confidence: approximate

# Unknown — best guess or range
created: ~2025-Q4                # from: adjacent file dates
created_confidence: estimated
```

The `_confidence` suffix is optional. Use it when backfilling timestamps
that weren't recorded originally. Omit it for timestamps recorded in
real time (confidence is implicit: exact).

---

## Per-Format Semantic Timestamps

Beyond the universal minimum, each format has timestamps for semantic
events specific to its lifecycle.

### Persona Files

```yaml
---
type: persona
created: <YYYY-MM-DDTHH:MM>
session: <session-id>
name: <name>
archetype: <archetype>
status: <active|inactive|alumni>
inception: <YYYY-MM-DD>
last_active: <YYYY-MM-DD>
evolved:
  - date: <YYYY-MM-DD>
    change: "<what changed>"
    session: <session-id>
decisions_participated:
  - id: <TOPIC-NNN>
    decision: "<summary>"
    role: "<their role>"
    date: <YYYY-MM-DD>
---
```

| Field | Semantic event |
|-------|---------------|
| `inception` | When the persona was first created |
| `last_active` | Last session this persona participated in |
| `evolved[].date` | When each expertise/personality change occurred |
| `decisions_participated[].date` | When each decision was made |

### Rollup Artifacts

```yaml
---
type: rollup
created: <YYYY-MM-DDTHH:MM>
session: <session-id>
last_reviewed: <YYYY-MM-DD>
sources:
  - path: <original-path>
    disposition: archived | deleted | superseded
    created: <YYYY-MM-DD>
    last_modified: <YYYY-MM-DD>
covers: <one-line description>
---
```

| Field | Semantic event |
|-------|---------------|
| `last_reviewed` | When a human or team last confirmed this rollup is current |
| `sources[].created` | When the original source document was created |
| `sources[].last_modified` | When the original was last modified (git-derived) |

### Decision Log Entries

```yaml
## <DECISION-ID>: <Title>
- **Date:** <YYYY-MM-DD>
- **Session:** <session-id>
- **Decision:** <the decision>
- **Status:** <accepted|superseded|deferred>
- **Last reviewed:** <YYYY-MM-DD>
- **Superseded by:** <DECISION-ID | null>
```

| Field | Semantic event |
|-------|---------------|
| `Date` | When the decision was made |
| `Last reviewed` | When someone last confirmed this decision still holds |
| `Superseded by` | Forward reference to the replacement decision |

### Archive Items

When an artifact moves into the archive (warm or cold), its frontmatter
gains transition timestamps:

```yaml
---
type: <original-type>
created: <original-created>
session: <original-session>
archived_at: <YYYY-MM-DD>
archived_from: <original-path>
source_created: <YYYY-MM-DD>
source_last_modified: <YYYY-MM-DD>
archive_tier: current | cold
---
```

| Field | Semantic event |
|-------|---------------|
| `archived_at` | When this artifact was moved into the archive |
| `source_created` | When the original was first created |
| `source_last_modified` | When the original was last modified before archiving |

### Session Summaries

```yaml
---
type: session-summary
created: <YYYY-MM-DDTHH:MM>
session: <session-id>
topic: <topic>
started: <YYYY-MM-DDTHH:MM>
completed: <YYYY-MM-DDTHH:MM>
phases_completed: [survey, assemble, icebreaker, breakout, converge, review]
personas: [<name>, <name>, ...]
decisions_made: [<ID>, <ID>, ...]
---
```

| Field | Semantic event |
|-------|---------------|
| `started` | When the session began |
| `completed` | When the session ended (DONE phase) |

---

## Filesystem Awareness

The survey artifact scan should capture filesystem metadata for each
discovered artifact. This isn't a source of truth — git is — but it's
a **staleness signal**.

### Per-Artifact Metadata in Survey

When inventorying artifacts, capture:

```yaml
artifacts_metadata:
  - path: docs/architecture.md
    git_modified: 2026-03-24
    git_author: kim
    fs_mtime: 2026-03-28T09:15
    size_bytes: 4823
    uncommitted_changes: true
  - path: team/DECISIONS.md
    git_modified: 2026-03-20
    fs_mtime: 2026-03-20T16:42
    size_bytes: 2104
    uncommitted_changes: false
```

| Field | What it tells you |
|-------|------------------|
| `git_modified` | Last commit that touched this file |
| `git_author` | Who last committed changes to this file |
| `fs_mtime` | Filesystem modification time |
| `size_bytes` | File size (change detection signal across surveys) |
| `uncommitted_changes` | `true` if fs_mtime > git_modified (someone edited but didn't commit) |

### How to Capture

```bash
# Git last modified date for a file
git log -1 --format=%aI -- <path>

# Git last author
git log -1 --format=%an -- <path>

# Filesystem mtime (macOS)
stat -f "%Sm" -t "%Y-%m-%dT%H:%M" <path>

# Filesystem mtime (Linux)
stat -c "%y" <path> | cut -d. -f1

# File size
wc -c < <path>

# Uncommitted changes check
git diff --name-only -- <path>  # non-empty = uncommitted
```

---

## Timestamp Backfill

When storytime encounters documents that predate the timestamp system
(or were created outside storytime), it can infer timestamps from
available evidence.

### Evidence Sources (in priority order)

```
╔═══════════════════════════════════════════════════════════════════╗
║  SOURCE               CONFIDENCE     GRANULARITY   METHOD         ║
║  ───────────────────  ────────────   ───────────   ────────────── ║
║                                                                   ║
║  git log              High           Minute        git log -1     ║
║                                      (exact)       --format=%aI   ║
║                                                                   ║
║  git blame            High           Minute        Per-line first ║
║                                      (exact)       appearance     ║
║                                                                   ║
║  Frontmatter dates    High           Day           Parse existing ║
║                                      (exact)       YAML dates     ║
║                                                                   ║
║  Filename dates       High           Day           Parse YYYY-MM- ║
║                                      (exact)       DD from name   ║
║                                                                   ║
║  Filesystem mtime     Medium         Minute        stat command   ║
║                                      (may be reset)               ║
║                                                                   ║
║  Adjacent file dates  Low            Month/quarter Files created  ║
║                                      (inferred)    around same    ║
║                                                    time           ║
║                                                                   ║
║  Content references   Low            Month/quarter "As of March"  ║
║                                      (inferred)    or "last week" ║
║                                                    in body text   ║
║                                                                   ║
║  No evidence          None           Unknown       Mark as        ║
║                                                    unknown        ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

### Backfill Rules

1. **Always mark inferred timestamps with confidence level.**
   Don't present a guess as a fact.
2. **Git is the best source.** If git has a date, use it.
3. **Prefer coarse-and-honest over precise-and-wrong.**
   `~2026-02` is better than `2026-02-15` if you're guessing.
4. **Backfill is additive.** Add `created` and `created_confidence`
   to frontmatter. Never remove existing metadata.
5. **Report what couldn't be inferred.** If a file has no recoverable
   timestamp, say so. Don't silently skip it.
6. **Batch backfill is a consolidation operation.** Run via
   `/storytime:storytime-consolidate` or a dedicated backfill pass.

### Backfill Frontmatter Example

```yaml
---
type: persona
created: 2026-03-24T10:30
created_confidence: git-derived    # from first commit adding this file
session: 2026-03-24-agc
last_active: ~2026-03-24
last_active_confidence: approximate  # inferred from session filename
---
```

---

## What Git Tracks vs What Storytime Tracks

```
╔═══════════════════════════════════════════════════════════════════╗
║  GIT TRACKS                        STORYTIME TRACKS              ║
║  ─────────────────────────────     ──────────────────────────── ║
║                                                                   ║
║  When a file was edited            When a persona was active      ║
║  Who committed the edit            When a decision was made       ║
║  What changed (diff)               When a decision was revisited  ║
║  Commit message (why)              When an artifact changed tier  ║
║                                    When a session started/ended   ║
║  These are FILE events.            When expertise was acquired    ║
║                                    When a specialist was promoted ║
║                                                                   ║
║                                    These are SEMANTIC events.     ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

If you're asking "when was this file last changed?" — ask git.
If you're asking "when did this *thing* last *happen*?" — check the
storytime timestamp.

---

## Rules Summary

1. Universal minimum: `type`, `created`, `session` on every document.
2. Semantic events get explicit timestamps; file edits rely on git.
3. Day granularity for most timestamps. Minute for session timing.
4. Approximate timestamps use `~` prefix and confidence markers.
5. Backfill uses git as primary evidence, marks inferred dates.
6. Filesystem mtime is a staleness signal, not a source of truth.
7. Survey fingerprints capture per-artifact fs metadata.
8. Transition timestamps (archive, promotion, evolution) are always explicit.
