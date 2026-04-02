---
type: reference
created: 2026-03-30T14:00
session: 2026-03-30-warm-start
---

# Warm Start

A warm start is the "previously on..." moment. When a user invokes
storytime on a topic that already has a thread, the system synthesizes a
narrative preamble from the living state of documents, persona histories,
and git history — then presents it as a card that gets the user productive
in seconds, not minutes.

---

## Why Warm Start

A storytime invocation is a dedicated timeslot — like sitting down for a
bedtime story. The listeners are picking up from where they left off. They
don't need the full journey recounted. They need just enough narrative to
re-engage their human memory, then a clear path forward.

Without warm start, every invocation runs the full cold-start pipeline:
survey, artifact inventory, team assembly, icebreaker. Even with collapse
rules, the user has to re-orient by answering questions about things they
already know. That's a tax on returning, and it should be zero.

---

## Thread: The Bookmark

Every topic gets a `_thread.md` once its first episode completes. This is
the bookmark — structural state that tells the orchestrator where the story
is and who's in it.

### Format

```yaml
---
type: thread
created: <YYYY-MM-DDTHH:MM>
topic: <topic>
---
```

```markdown
# Thread: <topic>

## Current State

- **Episodes:** <N>
- **Last episode:** <NNN> (<YYYY-MM-DD>)
- **Last completed phase:** <PHASE>
- **Last commit:** <sha>
- **Active team:** <names with archetypes>
- **Completed specialists:** <names with archetypes, if any>

## Open Questions

- <question 1>
- <question 2>
(or "(none)" if the last episode completed cleanly)

## Episode Log

| Episode | Date       | Phases Completed    | Decisions               |
|---------|------------|---------------------|-------------------------|
| 001     | YYYY-MM-DD | SURVEY → DONE       | TOPIC-001 through NNN   |

## Decision Summary

- TOPIC-001: <one-line summary>
- TOPIC-002: <one-line summary>
```

### Rules

1. **Created at first phase completion.** The thread is written as soon as
   the first phase produces output — not deferred to DONE. This means even
   a session interrupted after SURVEY has a resumable checkpoint.
2. **Updated automatically at every phase boundary.** When a phase completes,
   update `last_completed_phase`, `last_commit`, and `open_questions`. No
   user action required — the checkpoint is always current.
3. **Episode log is append-only.** Each completed episode adds a row.
4. **Decision summary mirrors the decision log** but filtered to this
   topic. It's a convenience index, not the source of truth.

---

## Preamble: The Narrative

The preamble is the synthesized "previously on..." presented to the user
at warm start. It is **dynamic** — generated fresh from the living state
of documents and histories every time. Never cached, never stale.

### Synthesis Inputs

| Source | What it contributes |
|--------|---------------------|
| `_thread.md` | Episode count, last phase, team roster, open questions |
| Decision log (filtered to topic) | What was decided, by whom, and why |
| Persona files (filtered to topic) | Who drove what, how they evolved, expertise acquired |
| Last episode's artifacts (plan, icebreaker) | The substance — problem framing, constraints, solution |
| Git log since last episode | What changed in the codebase since the team last met |

### Synthesis Output

A **narrative synopsis** of 3-5 sentences. Not bullets, not a table, not
a changelog. A paragraph that reconstructs the story arc of how the topic
reached its current state, told in a way that helps the user's human memory
re-engage.

The narrative should answer:
- What problem was the team solving?
- Who drove which key decisions?
- What did they decide and why?
- What changed in the world since?
- What's still open?

### Example

> Kim noticed quiet callers were vanishing in Nova Sonic's input — the SIP
> path had no gain normalization. Dana traced it through ForkToWebSocket,
> Raj spec'd the DSP math at -40/-20 dBFS thresholds with a scratch buffer
> for zero allocs. Leo got his kill switch (ENHANCE_AUDIO) and per-call
> stats. Implementation landed at 309ns/frame against a 1ms budget. Since
> then, 2 commits touched pkg/enhance/ — minor cleanup, no decision-level
> changes.

This is context-specific. The same repo might have a `websocket-backpressure`
topic with a completely different narrative. Personas who appear in both get
their contributions sliced per-topic.

### Persistence

Once generated, the preamble is written to `<episode>/preamble.md` as an
audit trail. It records what context the session started with. If a later
episode's decisions seem off, you can read the preamble to see what the
team believed at that point.

```yaml
---
type: preamble
created: <YYYY-MM-DDTHH:MM>
session: <session-id>
episode: <NNN>
prior_episode: <NNN-1>
prior_commit: <sha>
current_commit: <sha>
drift_commits: <N>
drift_files: <N>
---
```

---

## Warm-Start Card

The preamble is presented inside a structured card:

```
╔═══════════════════════════════════════════════════╗
║  Previously on <topic>                            ║
╠═══════════════════════════════════════════════════╣
║                                                   ║
║  [narrative synopsis — 3-5 sentences]             ║
║                                                   ║
╠═══════════════════════════════════════════════════╣
║  Team: [names]                                    ║
║  Episodes: N (last: YYYY-MM-DD)                   ║
║  Decisions: TOPIC-001 through TOPIC-NNN           ║
║  Open questions: [from _thread.md]                ║
║  Codebase drift: [N commits, M files changed]     ║
╠═══════════════════════════════════════════════════╣
║  Continue · Retro · New sub-topic · Reset         ║
╚═══════════════════════════════════════════════════╝
```

The synopsis is the part that helps human memory. The structured section
below it is machine-readable reference. Both are needed.

---

## Routing After the Card

| Choice | What happens |
|--------|-------------|
| **Continue** | Resume at first incomplete phase. If last episode completed all phases, start new episode at ICEBREAKER (team loaded silently, survey delta for codebase). |
| **Retro** | Invoke `/storytime-retro` with the topic context. The team reconvenes to compare plan vs. what was built. |
| **New sub-topic** | User provides a sub-problem. New episode, same team, scoped to the sub-topic. Starts at ICEBREAKER. |
| **Reset** | Archive the entire thread (all episodes move to cold storage). Fresh cold start — new story. |

---

## Episode Structure

Sessions for the same topic are **episodes** of an ongoing story. Each
episode gets its own subdirectory under the topic.

```
sessions/<topic>/
├── _thread.md                      ← the bookmark
├── 001/                            ← episode 1 (cold start)
│   ├── survey.md
│   ├── team.md
│   ├── icebreaker.md
│   ├── breakout-<subtopic>.md
│   └── plan.md
├── 002/                            ← episode 2 (warm start)
│   ├── preamble.md                 ← synthesized narrative
│   ├── survey-delta.md             ← incremental survey
│   ├── icebreaker.md               ← new discussion with existing team
│   └── plan.md                     ← revised or extended plan
```

Episode 1 never has a preamble (it's the cold start — there's no "previously").
Episode 2+ always start with a preamble.

Not every episode produces every artifact. If the team doesn't change, no
`team.md`. If the problem doesn't need breakouts, no breakout files. The
phase collapse rules still apply within episodes.

---

## Survey Delta

On warm start, SURVEY produces a **delta** instead of a full survey:

1. Read the last episode's survey fingerprint (commit sha, paths scanned)
2. Compute git drift: `git rev-list <prior_commit>..HEAD`
3. Identify changed files within scanned paths (stale)
4. Identify new files outside scanned paths (new)
5. Skip unchanged, previously-scanned paths entirely

Output is `survey-delta.md` with:
- Changed files and what changed (commit messages, diff stats)
- New files discovered
- Assessment: do any changes affect the topic?
- Updated fingerprint (extends the prior one)

If the delta is empty (no relevant changes), report that and move on.
Don't make the user sit through a survey that found nothing.

---

## Automatic Checkpointing

Checkpointing is automatic, not user-triggered. At every phase boundary,
the orchestrator writes or updates `_thread.md`:

```
last_completed_phase: <PHASE>
last_commit: <current HEAD sha>
open_questions:
  - <any unresolved questions from the completed phase>
```

The `_thread.md` is created at the first phase completion (not deferred to
DONE). This means the thread is always current. If a session is interrupted
for any reason — context limit, terminal close, user walks away — the next
invocation detects the incomplete thread and offers to resume.

No explicit "park" command is needed. The checkpoint is already there.

---

## Rules

1. **Warm start is detected, not requested.** If `_thread.md` exists for
   the topic, warm start happens automatically. The user doesn't have to
   ask for it.
2. **The preamble is always dynamic.** Synthesized fresh from current
   state. Never cached from a prior run.
3. **The preamble is always persisted.** Written to `<episode>/preamble.md`
   as an audit trail after synthesis.
4. **Personas skip introductions on warm start.** They speak from their
   accumulated context, not from their bio.
5. **The user controls depth.** "Skip the recap" is valid. "Tell me more
   about decision X" is valid. The card is a starting point, not a gate.
6. **Thread state is the checkpoint.** Updated at every phase boundary.
   The source of truth for where the story is.
7. **Episodes are chapters, not restarts.** Same topic, same thread,
   continuing story. Reset is the explicit "new story" action.
8. **Survey delta replaces full survey on warm start.** Only resurvey
   what changed. The user can request a full resurvey if needed.
