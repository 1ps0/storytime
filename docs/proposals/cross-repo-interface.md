---
type: proposal
created: 2026-04-02T10:00
session: 2026-04-02-cross-repo-interface
status: draft
---

# Proposal: Cross-Repo Storytime Interface

How two loosely-storytime'd repositories share lore without tight coupling.

---

## Problem

A user works across multiple repos that each have storytime state. Decisions
in repo A affect work in repo B. Personas exist in both. But today, each
repo's storytime is an island — sessions can't see or reference state in
sibling repos without manual effort.

The interface must work in two scenarios:
1. **Single session, one cwd** — working in repo A, reading repo B's state
2. **Two sessions, two cwds** — separate conversations bridged by git and memory

---

## Constraints (Claude Code Reality)

```
+------------------------------------------------------------+
|  CLAUDE CODE FILESYSTEM RULES                              |
|                                                            |
|  READ:  Any absolute path. No sandbox.                     |
|  WRITE: Main thread can write anywhere (with permission).  |
|         Subagents sandboxed to project directory.           |
|  CWD:   Set at conversation start. Skills inherit it.      |
|                                                            |
|  IMPLICATION: reads are free, writes are local.            |
|  The interface is read-heavy by design.                    |
+------------------------------------------------------------+
```

---

## Three-Layer Interface

```
+------------------------------------------------------------+
|  LAYER 1: FILESYSTEM (read-across)                         |
|  +---------------------------------------------------------+
|  |  Any session can read any sibling repo's storytime      |
|  |  state via absolute path resolved from config.md.       |
|  |                                                         |
|  |  Artifacts readable cross-repo:                         |
|  |  - _thread.md     (topic awareness)                     |
|  |  - decisions.md   (qualified decision references)       |
|  |  - preamble.md    (narrative context)                   |
|  |  - persona files  (cross-pollination)                   |
|  |  - survey.md      (codebase fingerprint)                |
|  +---------------------------------------------------------+
|                                                            |
|  LAYER 2: QUALIFIED REFERENCES (cite-across)               |
|  +---------------------------------------------------------+
|  |  Decision IDs from sibling repos use qualified form:    |
|  |                                                         |
|  |  Within same repo:     AGC-001                          |
|  |  Cross-repo:           gateway:AGC-001                  |
|  |  Org-level:            org:SRE-STANDARDS-001            |
|  |                                                         |
|  |  The qualifier resolves to a path via config.md.        |
|  |  Citations in session output include the qualified form.|
|  +---------------------------------------------------------+
|                                                            |
|  LAYER 3: NARRATIVE BRIDGE (story-across)                  |
|  +---------------------------------------------------------+
|  |  Warm-start preambles are self-contained story          |
|  |  summaries. Reading repo B's preamble from repo A       |
|  |  gives you the "previously on" without parsing raw      |
|  |  session state.                                         |
|  |                                                         |
|  |  The narrative IS the API. Preambles are the cross-repo |
|  |  interface artifact.                                    |
|  +---------------------------------------------------------+
|                                                            |
|  AMBIENT BRIDGE: Claude Code memory                        |
|  +---------------------------------------------------------+
|  |  ~/.claude/projects/*/memory/ is per-project.           |
|  |  ~/.claude/memory/ is global.                           |
|  |  Cross-repo insights go in global memory.               |
|  |  This bridges what the repos can't.                     |
|  +---------------------------------------------------------+
+------------------------------------------------------------+
```

---

## Config Schema

Add a `siblings` section to `specs/.storytime/config.md`:

```yaml
siblings:
  - alias: storytime
    path: ~/workspace/storytime
    read:
      - threads       # _thread.md files for topic awareness
      - decisions     # qualified decision references
      - preambles     # narrative context for warm starts
    personas: shared  # shared | isolated | import-only

  - alias: billing
    path: ~/workspace/billing-service
    read:
      - threads
      - decisions
    personas: isolated
```

### Persona Modes

| Mode | Behavior |
|------|----------|
| `shared` | Persona in repo A can read counterpart in repo B. Cross-pollination of context. |
| `isolated` | No cross-repo persona reading. Each repo's Kim is independent. |
| `import-only` | Manually import context via `/storytime-cohort import`. No automatic reading. |

### Path Resolution

- `~/` expands to `$HOME`
- Relative paths resolve from the repo root
- Paths are validated at session start — missing siblings are warned, not fatal

---

## Scenario 1: Single Session, One CWD

```
+------------------------------------------------------------+
|  CWD: ~/workspace/ai-sip-gateway                          |
|  User: /storytime "add opus codec support, the storytime   |
|         plugin discussions about codecs are relevant"       |
|                                                            |
|  SURVEY phase:                                             |
|  1. Scan local repo as normal                              |
|  2. Detect siblings from config.md                         |
|  3. Read sibling storytime state:                          |
|     - storytime: _thread.md files, decisions.md            |
|  4. Include in artifact inventory:                         |
|                                                            |
|  Artifact Inventory:                                       |
|                                                            |
|  Local:                                                    |
|  [x] specs/agc/plan.md                    [spec]           |
|  [x] specs/.storytime/cohort/kim-*.md     [team]           |
|                                                            |
|  Sibling: storytime                                        |
|  [x] sessions/warm-start/_thread.md       [cross-repo]     |
|  [ ] history/decisions.md                 [cross-repo]     |
|                                                            |
|  ICEBREAKER:                                               |
|  Kim: "Over in the storytime repo, we discussed episode    |
|        threading. The key decision was storytime:WARM-001.  |
|        That's relevant because..."                         |
|                                                            |
|  WRITES: All output stays in ai-sip-gateway/specs/         |
|  References use qualified form: "Per storytime:WARM-001..."  |
+------------------------------------------------------------+
```

---

## Scenario 2: Two Sessions, Two CWDs

```
+------------------------------------------------------------+
|  SESSION A                    SESSION B                    |
|  cwd: ai-sip-gateway         cwd: storytime               |
|  (separate conversations, possibly different days)         |
|                                                            |
|  These sessions don't share context window.                |
|  They CAN'T talk to each other in real-time.               |
|                                                            |
|  Bridge mechanisms:                                        |
|                                                            |
|  1. GIT (committed artifacts)                              |
|     Session B commits new decisions to storytime.          |
|     User opens Session A later.                            |
|     Session A's survey delta picks up:                     |
|     "Sibling 'storytime' has 3 new commits since           |
|      last cross-check."                                    |
|                                                            |
|  2. CLAUDE MEMORY (ambient bridge)                         |
|     Learning in Session B gets saved to memory.            |
|     Session A reads memory at conversation start.          |
|     "In the storytime session, we decided X."              |
|                                                            |
|  3. FILESYSTEM (read-across)                               |
|     Session A reads storytime's current state:             |
|     - Latest _thread.md (even uncommitted)                 |
|     - Latest decisions (even uncommitted)                  |
|     Real-time-ish without real-time coordination.          |
+------------------------------------------------------------+
```

---

## Warm-Start Cross-Repo Clause

When warm-starting a topic, if siblings are configured and have relevant
threads, the preamble synthesis extends:

> Kim and Dana designed the per-frame gain normalizer for quiet speakers.
> Implementation landed at 309ns/frame. **Meanwhile, in the storytime
> repo,** the team added warm-start support with episode threading —
> which changes how future AGC sessions resume. Storytime has 3 new
> commits since your last gateway session.

The "meanwhile, over there..." clause is synthesized from:
- Sibling `_thread.md` files (what topics are active)
- Sibling git delta (what changed since last local session)
- Sibling decisions filtered to relevant topics

---

## Impact on Existing Skills

| Skill | Cross-repo behavior |
|-------|-------------------|
| `/storytime` (main) | SURVEY reads siblings. Warm-start includes sibling clause. |
| `/storytime-survey` | Scans siblings if configured. Tags cross-repo artifacts. |
| `/storytime-qa` | Can answer "what did we decide in <sibling>?" via qualified IDs. |
| `/storytime-status` | Shows sibling status: active threads, recent decisions, drift. |
| `/storytime-retro` | Can reference sibling decisions as external context. |
| `/storytime-absorb` | Can absorb sibling artifacts as input. |

---

## Error Handling

| Condition | Behavior |
|-----------|----------|
| Sibling path doesn't exist | Warn: "Sibling 'storytime' at ~/workspace/storytime not found. Skipping." |
| Sibling has no .storytime/ | Silent skip — sibling exists but isn't storytime-enabled yet. |
| Sibling has uncommitted changes | Read them anyway — filesystem reads see working tree. Note in inventory: "(uncommitted)". |
| Sibling config conflicts | Local config wins. Sibling's opinion of the relationship doesn't matter. |

---

## Non-Goals

| Non-goal | Why not | Revisit when |
|----------|---------|-------------|
| Automatic persona sync | Too surprising. Context from repo A might pollute repo B decisions. | Clear multi-repo team workflow with defined sync points. |
| Shared decision namespace | Each repo owns its IDs. Merging creates governance overhead. | Org-level decision graph with aggregation service. |
| Write-across | Session in A writing to B is surprising and hard to track. | Claude Code relaxes agent sandboxing or adds cross-project coordination. |
| Real-time bridge | Two simultaneous sessions can't coordinate. | Claude Code adds inter-session messaging or shared state. |
| Automatic sibling discovery | Scanning ~/workspace/*/.storytime/ is slow and surprising. | Opt-in discovery with caching, or org-level registry. |

---

## Migration Path

### Phase 1: Config only (minimal)
- Add `siblings` field to config.md schema
- Document qualified reference format
- No skill changes — just the ability to declare siblings

### Phase 2: SURVEY awareness
- SURVEY reads sibling state when configured
- Cross-repo items appear in artifact inventory
- Qualified references work in session output

### Phase 3: Warm-start integration
- Preamble synthesis includes sibling clause
- `/storytime-status` shows sibling state
- `/storytime-qa` resolves qualified references

### Phase 4: Persona cross-pollination
- `personas: shared` mode reads counterpart files
- Import/export commands for persona context
- Cross-repo persona evolution tracking

---

## Open Questions

1. **Should sibling config be bidirectional?** If gateway declares storytime
   as a sibling, should storytime auto-detect gateway? Current answer: no,
   each repo declares its own siblings independently.

2. **How to handle stale sibling state?** If a sibling hasn't been touched
   in months, its context may be misleading. Should there be a staleness
   threshold? Or just show the last-modified date and let the user decide?

3. **Org-level sibling registry?** Instead of per-repo config, a
   `~/.storytime/siblings.md` that lists all known repos. Would reduce
   duplication but add a global config dependency.

4. **Cross-repo decision conflicts?** If gateway:AGC-001 says "no Opus"
   and billing:CODEC-001 says "yes Opus", there's a conflict. Should
   storytime detect and surface these? Or is that the user's problem?
