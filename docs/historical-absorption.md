# Historical Absorption

How Storytime teams absorb existing codebases, reconstruct history,
and produce cross-codebase interface documents.

---

## The Problem

Storytime was designed for forward-looking work: "let's design X."
But most engineering work happens in existing systems where the
hard question is "how did we get here?" and "how does this talk
to everything else?"

This document extends Storytime with:
- **Codebase archaeology** — understanding existing systems
- **Interface documents** — describing how systems communicate
- **The absorption workflow** — ingesting an unfamiliar codebase

---

## New Event Types

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║  ABSORB          (new)  Team ingests an existing codebase        ║
║  ARCHAEOLOGY     (new)  Deep-dive into git history and patterns  ║
║  INTERFACE-MAP   (new)  Document how systems communicate         ║
║  RECONSTRUCT     (new)  Piece together history from artifacts    ║
║                                                                  ║
║  These extend the existing event registry.                       ║
║  They can be triggered standalone or as part of a full session.  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## Codebase Archaeology

A session type where the team surveys an existing codebase to build
understanding of what exists, why it was built that way, and what
patterns were chosen.

```
  ┌─────────────────────────────────────────────────────────────┐
  │  ARCHAEOLOGY SESSION                                        │
  │                                                             │
  │  Input:  A codebase (or subsystem) to understand            │
  │  Team:   Permanent cohort + Archivist specialist            │
  │                                                             │
  │  Phase 1: AUTOMATED SURVEY                                  │
  │  ┌───────────────────────────────────────────┐              │
  │  │  Explore agent scans:                     │              │
  │  │  • File structure and package layout      │              │
  │  │  • Dependency graph (go.mod, imports)     │              │
  │  │  • API surfaces (exported funcs, types)   │              │
  │  │  • Config and env var inventory           │              │
  │  │  • Test coverage map                      │              │
  │  └───────────────────────────────────────────┘              │
  │                                                             │
  │  Phase 2: GIT HISTORY ANALYSIS                              │
  │  ┌───────────────────────────────────────────┐              │
  │  │  Git-focused agent examines:              │              │
  │  │  • Major commits (by diff size, impact)   │              │
  │  │  • Contributor patterns (who owns what)   │              │
  │  │  • Commit message conventions             │              │
  │  │  • File churn (most-modified files)       │              │
  │  │  • PR history (if GitHub)                 │              │
  │  └───────────────────────────────────────────┘              │
  │                                                             │
  │  Phase 3: TEAM INTERPRETATION                               │
  │  ┌───────────────────────────────────────────┐              │
  │  │  Personas discuss findings:               │              │
  │  │  Dana: "The RTP handling changed 3 times  │              │
  │  │   — that suggests the requirements were   │              │
  │  │   shifting or the first approach failed"  │              │
  │  │  Kim: "The research/ dir has 4 prototypes │              │
  │  │   that never shipped. That tells me they  │              │
  │  │   were experimenting before committing"   │              │
  │  └───────────────────────────────────────────┘              │
  │                                                             │
  │  Phase 4: ORIGIN STORY DOCUMENT                             │
  │  ┌───────────────────────────────────────────┐              │
  │  │  Output: specs/<topic>/origin-story.md    │              │
  │  │  A narrative explaining:                  │              │
  │  │  • Why this system exists                 │              │
  │  │  • How it evolved (major phases)          │              │
  │  │  • Key architectural decisions            │              │
  │  │  • Patterns and conventions used          │              │
  │  │  • Known debt and rough edges             │              │
  │  └───────────────────────────────────────────┘              │
  │                                                             │
  └─────────────────────────────────────────────────────────────┘
```

### The Archivist Persona

A specialist archetype for archaeology sessions:

```
┌─────────────────────────────────────────────────┐
│  ARCHIVIST — Codebase Historian                 │
│                                                 │
│  Reads git blame the way a historian reads      │
│  primary sources. Knows that commit messages    │
│  lie, but diffs don't. Asks "when did this      │
│  change and what else changed at the same time?"│
│                                                 │
│  Skills: git log, git blame, PR review history  │
│  Focus: temporal patterns, evolution, intent    │
└─────────────────────────────────────────────────┘
```

---

## Cross-Codebase Interface Documents

When systems talk to each other, each team understands their side
but nobody documents the contract in a way both teams can use.

### Interface Document Format

```
  specs/interfaces/
  └── gateway-to-nova-sonic.md

  Structure:
  ┌──────────────────────────────────────────────────────────┐
  │  # Interface: AI SIP Gateway ↔ Nova Sonic                │
  │                                                          │
  │  ## Overview                                             │
  │  One-paragraph description of what this interface does    │
  │                                                          │
  │  ## Protocol                                             │
  │  WebSocket (wss://) with binary and text messages        │
  │                                                          │
  │  ## Data Flow                                            │
  │  [ASCII diagram showing message types and direction]     │
  │                                                          │
  │  ## Messages: Gateway → Nova                             │
  │  [Each message type with format, frequency, constraints] │
  │                                                          │
  │  ## Messages: Nova → Gateway                             │
  │  [Each message type with format, frequency, constraints] │
  │                                                          │
  │  ## Error Handling                                       │
  │  [What happens when things break]                        │
  │                                                          │
  │  ## Assumptions                                          │
  │  [What each side assumes about the other]                │
  │                                                          │
  │  ## History                                              │
  │  [How this interface evolved, with git citations]        │
  │                                                          │
  │  ## Team Notes                                           │
  │  [Persona commentary: risks, debt, improvement ideas]    │
  │                                                          │
  └──────────────────────────────────────────────────────────┘
```

### Two-Team Interface Sessions

When both sides of an interface have Storytime cohorts, their
personas can produce a joint document:

```
  ai-sip-gateway team              freeswitch-config team
  ─────────────────────            ────────────────────────
  Kim (owner)                      Yuki (owner)
  Dana (VoIP systems)              Dana (shared — VoIP systems)
  Leo (operator)                   Marco (operator)

  Joint session:
  ┌────────────────────────────────────────────────────┐
  │  Dana (shared between both teams):                 │
  │  "I see both sides. The SIP trunk between          │
  │   FreeSWITCH and the gateway uses TCP:7000.        │
  │   The codec negotiation happens in the SDP offer.  │
  │   FreeSWITCH sends PCMU/PCMA, gateway accepts."   │
  │                                                    │
  │  Kim: "On our side, the diago library handles      │
  │   the INVITE. Here's the codec config..."          │
  │   [cites: cmd/v1/main.go:789-796]                  │
  │                                                    │
  │  Yuki: "On our side, the dialplan routes to        │
  │   extension 1001. Here's the config..."            │
  │   [cites: dialplan/default.xml:42]                 │
  │                                                    │
  │  Output: specs/interfaces/gateway-to-freeswitch.md │
  └────────────────────────────────────────────────────┘
```

---

## The Absorption Workflow

Step by step: how a team ingests a codebase they've never seen.

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   ABSORPTION WORKFLOW                                            ║
║                                                                  ║
║   ┌────────────────────────────────────────────────────────┐     ║
║   │  INPUT: "Understand the ai-sip-gateway codebase"      │     ║
║   └─────┬──────────────────────────────────────────────────┘     ║
║         │                                                        ║
║         ▼                                                        ║
║   ┌─ Phase 0: STRUCTURAL SURVEY ───────────────────────────┐     ║
║   │  Agent(Explore, thorough) scans:                       │     ║
║   │  • 15 Go files across cmd/, pkg/                       │     ║
║   │  • 12 external dependencies                            │     ║
║   │  • 2 build modes (server, registration)                │     ║
║   │  • 5 environment variable groups                       │     ║
║   │  Produces: structural-survey.md                        │     ║
║   └─────┬──────────────────────────────────────────────────┘     ║
║         │                                                        ║
║         ▼                                                        ║
║   ┌─ Phase 1: GIT ARCHAEOLOGY ─────────────────────────────┐     ║
║   │  Agent(general) with git access examines:              │     ║
║   │  • 63 commits, 5 contributors                          │     ║
║   │  • Major phases: initial build, opus experiments,      │     ║
║   │    audio buffer refactor, AGC addition                  │     ║
║   │  • Most-churned files: main.go (45 changes)            │     ║
║   │  • Dependabot pattern: regular dep updates             │     ║
║   │  Produces: git-archaeology.md                          │     ║
║   └─────┬──────────────────────────────────────────────────┘     ║
║         │                                                        ║
║         ▼                                                        ║
║   ┌─ Phase 2: TEAM ICEBREAKER ON FINDINGS ─────────────────┐     ║
║   │  Full team interprets the survey:                       │     ║
║   │                                                         │     ║
║   │  Kim: "The research/ dir shows 3 abandoned approaches  │     ║
║   │   before they settled on the current enhance.go"        │     ║
║   │  Dana: "The codec negotiation code has changed 4 times │     ║
║   │   — PCMU only, then PCMA added, then Opus attempted,  │     ║
║   │   then Opus deferred back to PCMU/PCMA"                │     ║
║   │  Leo: "Monitoring was an afterthought — no metrics     │     ║
║   │   until the AGC work added enhancement stats"          │     ║
║   │                                                         │     ║
║   │  Produces: icebreaker.md (in absorption context)       │     ║
║   └─────┬──────────────────────────────────────────────────┘     ║
║         │                                                        ║
║         ▼                                                        ║
║   ┌─ Phase 3: INTERFACE MAPPING ───────────────────────────┐     ║
║   │  Identify all external touchpoints:                     │     ║
║   │                                                         │     ║
║   │  ┌──────────────┐  ┌────────────┐  ┌───────────────┐  │     ║
║   │  │ FreeSWITCH   │  │ Nova Sonic │  │ Mango VOIP    │  │     ║
║   │  │ SIP/RTP      │  │ WebSocket  │  │ REST API      │  │     ║
║   │  │ TCP:7000     │  │ wss://     │  │ IP validation │  │     ║
║   │  └──────────────┘  └────────────┘  └───────────────┘  │     ║
║   │                                                         │     ║
║   │  For each: produce an interface document                │     ║
║   │  Produces: specs/interfaces/*.md                       │     ║
║   └─────┬──────────────────────────────────────────────────┘     ║
║         │                                                        ║
║         ▼                                                        ║
║   ┌─ Phase 4: ORIGIN STORY ───────────────────────────────┐      ║
║   │  Team synthesizes everything into a narrative:         │      ║
║   │                                                        │      ║
║   │  "The ai-sip-gateway was born to bridge PSTN callers  │      ║
║   │   with Amazon Nova Sonic for AI voice conversations.  │      ║
║   │   It started as a simple SIP→WebSocket bridge, grew   │      ║
║   │   codec negotiation, then AGC for quiet speakers.     │      ║
║   │   The Opus experiment (research/) was deferred in     │      ║
║   │   favor of G.711 reliability. The codebase reflects   │      ║
║   │   a team that prototypes in research/ before           │      ║
║   │   promoting to pkg/."                                  │      ║
║   │                                                        │      ║
║   │  Produces: specs/<topic>/origin-story.md              │      ║
║   └────────────────────────────────────────────────────────┘      ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## Practical Examples

### Example 1: Gateway ↔ FreeSWITCH Interface

```
  What the team would discover:

  Protocol:     SIP over TCP (port 7000 in server mode)
  Codecs:       PCMU (payload 0), PCMA (payload 8)
  Sample rate:  8000 Hz
  Direction:    FreeSWITCH initiates INVITE → gateway answers

  Key code:     cmd/v1/main.go getMediaConfig() line 789-796
  Config:       SIP_MODE=registration requires EXTENSION_* env vars
  Validation:   Server mode validates caller IP against Mango VOIP list

  Dana would note: "The gateway only listens — it never initiates
  calls. FreeSWITCH is always the caller. This is a deliberate
  architectural constraint."
```

### Example 2: Gateway ↔ Nova Sonic Interface

```
  What the team would discover:

  Protocol:     WebSocket (wss://)
  Direction:    Gateway connects to Nova Sonic endpoint

  Gateway → Nova:
    • Binary messages: raw PCM audio (8kHz, 16-bit LE)
    • Text messages: {"type": "hangup"} on call end
    • Setup: caller info with sampleRate at connection start

  Nova → Gateway:
    • Text messages: JSON events
      - audioOutput: base64-encoded 24kHz PCM
      - clearAudioBuffer: barge-in signal
      - toolResult: call transfer with extension
    • Binary messages: raw PCM (alternate path)

  Kim would note: "The sample rate mismatch (8kHz in, expects 16kHz)
  is a known issue we're working around. Nova handles it but it's
  not ideal." [cites: CLAUDE.md § Nova Sonic Audio Format]
```

### Example 3: Gateway ↔ Mango VOIP API

```
  What the team would discover:

  Protocol:     HTTPS REST
  Direction:    Gateway calls Mango API at startup (server mode only)
  Purpose:      Validate caller IPs against known Mango SIP servers

  Auth:         API key from AWS Secrets Manager (MANGO_API_SECRET)
  Frequency:    On startup, periodically refreshed
  Failure mode: If API unreachable, gateway rejects all calls (safe default)

  Leo would note: "This is a single point of failure in server mode.
  If Secrets Manager or Mango API is down, no calls get through.
  There's no local cache of valid IPs."
```

---

## New File Formats

### origin-story.md

```markdown
# Origin Story: <system-name>

## In One Sentence
<What this system does and why it exists>

## Timeline
| Date       | Event                              | Evidence          |
|------------|------------------------------------|--------------------|
| 2025-06-xx | Initial commit, basic SIP bridge   | commit abc123     |
| 2025-08-xx | Added codec negotiation            | PR #12            |
| 2026-01-xx | Opus experiment (deferred)         | research/ dir     |
| 2026-03-24 | AGC for quiet speakers             | specs/agc/plan.md |

## Architecture Decisions
<Discovered decisions with rationale from git history>

## Patterns and Conventions
<What the codebase does consistently>

## Known Debt
<What the team acknowledges is imperfect>

## Team Commentary
<Persona observations about the codebase>
```

### interface document

```markdown
# Interface: <System A> ↔ <System B>

## Summary
<One paragraph>

## Protocol
<Transport, encoding, authentication>

## Data Flow
<ASCII diagram>

## Messages: A → B
<Message catalog with formats>

## Messages: B → A
<Message catalog with formats>

## Failure Modes
<What happens when things break>

## Assumptions
<What each side assumes about the other>

## History
<How this interface evolved>
```

---

## Open Questions

1. **How deep should git archaeology go?** Scanning every commit
   is expensive. Should we sample (first/last per month) or use
   heuristics (large diffs, merge commits, tagged releases)?

2. **Interface documents as contracts?** Should they be machine-
   verifiable (like OpenAPI but for all protocols), or purely
   narrative? Narrative is more readable but not enforceable.

3. **Cross-codebase sessions?** Can a single Storytime invocation
   access two repos simultaneously, or does each repo's team
   produce their half and someone merges?
