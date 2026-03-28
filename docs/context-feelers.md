# Context Feelers

How a production-grade Storytime pulls context from external sources
to build a historical record of "how we got here."

---

## The Problem

Code tells you *what* exists. Git tells you *when* it changed.
But the *why* — the decision that led to the code — lives in
Slack threads, Google Docs, Jira tickets, PR reviews, and meeting
notes. Today, this context is inaccessible to Storytime personas.

Feelers are pluggable connectors that let personas query external
sources mid-conversation, bringing the "why" into the narrative.

---

## Feeler Architecture

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   FEELER ARCHITECTURE                                            ║
║                                                                  ║
║   Storytime Persona                                              ║
║        │                                                         ║
║        │  "Let me check the Slack thread where                   ║
║        │   this was originally discussed"                        ║
║        │                                                         ║
║        ▼                                                         ║
║   ┌─────────────────────────────────────────────┐                ║
║   │  SKILL: external_search                     │                ║
║   │                                             │                ║
║   │  Routes to the appropriate MCP server       │                ║
║   │  based on the source type                   │                ║
║   └────────┬────────────────────────────────────┘                ║
║            │                                                     ║
║            ├──────────┬──────────┬──────────┬────────┐           ║
║            │          │          │          │        │           ║
║            ▼          ▼          ▼          ▼        ▼           ║
║   ┌────────────┐ ┌────────┐ ┌────────┐ ┌──────┐ ┌──────┐       ║
║   │   Slack    │ │ GitHub │ │ Google │ │ Jira │ │ MSFT │       ║
║   │   MCP      │ │ MCP    │ │ Docs   │ │ MCP  │ │ MCP  │       ║
║   │   Server   │ │ Server │ │ MCP    │ │Server│ │Server│       ║
║   └────────────┘ └────────┘ └────────┘ └──────┘ └──────┘       ║
║                                                                  ║
║   Each feeler is an MCP server that Storytime queries             ║
║   through Claude Code's existing MCP infrastructure.             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

### Why MCP

Claude Code already supports MCP servers via `.mcp.json`. Feelers
are just MCP servers that happen to connect to collaboration tools
instead of databases or APIs. This means:

- No custom integration layer needed
- Standard auth/config patterns
- Existing MCP servers for Slack, GitHub, etc. already exist
- Persona skills map directly to MCP tool calls

---

## MCP Configuration

In the storytime plugin or per-project:

```json
// .mcp.json (in storytime plugin root or project root)
{
  "storytime-slack": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-slack"],
    "env": {
      "SLACK_TOKEN": "${SLACK_BOT_TOKEN}",
      "SLACK_WORKSPACE": "${SLACK_WORKSPACE}"
    }
  },
  "storytime-github": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-github"],
    "env": {
      "GITHUB_TOKEN": "${GITHUB_TOKEN}"
    }
  },
  "storytime-gdocs": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-gdrive"],
    "env": {
      "GOOGLE_CREDENTIALS": "${GOOGLE_APPLICATION_CREDENTIALS}"
    }
  }
}
```

### Skill ↔ MCP Mapping

```
  Persona Skill          MCP Server          Query Type
  ──────────────         ──────────          ──────────
  slack_search           storytime-slack     Search messages by keyword
  slack_thread           storytime-slack     Fetch full thread by URL
  github_pr              storytime-github    PR details, review comments
  github_issues          storytime-github    Issue history, labels
  gdoc_read              storytime-gdocs     Read a Google Doc by URL
  gdoc_search            storytime-gdocs     Find docs by title/content
  jira_ticket            storytime-jira      Ticket history, comments
  jira_search            storytime-jira      Find tickets by project/query
```

---

## The Historical Record

Feelers feed into a new session type: **RECONSTRUCT**. The team uses
external sources to piece together the history of a feature or system.

```
  ┌──────────────────────────────────────────────────────────────┐
  │  RECONSTRUCT SESSION                                         │
  │                                                              │
  │  Input: "How did the audio pipeline get to its current state?"│
  │                                                              │
  │  Step 1: PULL SOURCES                                        │
  │  ┌────────────────────────────────────────────────────┐     │
  │  │  Archivist: "Let me pull the relevant history."    │     │
  │  │                                                    │     │
  │  │  → slack_search: "audio pipeline" in #engineering  │     │
  │  │    Found: 3 threads spanning Feb-Mar 2026          │     │
  │  │                                                    │     │
  │  │  → github_pr: search PRs touching cmd/v1/main.go  │     │
  │  │    Found: 8 PRs, 4 with substantive review threads │     │
  │  │                                                    │     │
  │  │  → gdoc_search: "audio" in shared drive            │     │
  │  │    Found: "Audio Pipeline Proposals" doc            │     │
  │  │                                                    │     │
  │  │  → git log: commits touching audio path            │     │
  │  │    Found: 23 commits across 4 major phases         │     │
  │  └────────────────────────────────────────────────────┘     │
  │                                                              │
  │  Step 2: BUILD TIMELINE                                      │
  │  ┌────────────────────────────────────────────────────┐     │
  │  │  Archivist synthesizes sources into chronology:    │     │
  │  │                                                    │     │
  │  │  Feb 10: Slack thread — team debates Opus vs G.711 │     │
  │  │  Feb 15: Google Doc — "Audio Pipeline Proposals"   │     │
  │  │  Feb 20: PR #34 — initial Opus decoder attempt     │     │
  │  │  Feb 28: PR #34 review — "Opus adds CGO dep,      │     │
  │  │          let's defer" — Kim                        │     │
  │  │  Mar 5:  PR #38 — revert to G.711 only            │     │
  │  │  Mar 24: Storytime AGC session — quiet speaker fix │     │
  │  └────────────────────────────────────────────────────┘     │
  │                                                              │
  │  Step 3: TEAM INTERPRETATION                                 │
  │  ┌────────────────────────────────────────────────────┐     │
  │  │  Kim: "The Opus attempt shows we wanted higher     │     │
  │  │   quality audio from the start. The CGO dependency │     │
  │  │   was the blocker, not the idea."                  │     │
  │  │                                                    │     │
  │  │  Dana: "The Slack thread from Feb 10 reveals that  │     │
  │  │   Dana (original, not me) pushed for Opus but was  │     │
  │  │   outvoted on operational complexity grounds."     │     │
  │  │                                                    │     │
  │  │  Leo: "Nobody mentioned monitoring until the AGC   │     │
  │  │   work. That's a 6-week blind spot."              │     │
  │  └────────────────────────────────────────────────────┘     │
  │                                                              │
  │  Step 4: PROCEDURAL HISTORY DOCUMENT                         │
  │  ┌────────────────────────────────────────────────────┐     │
  │  │  Output: specs/audio-pipeline/procedural-history.md│     │
  │  │                                                    │     │
  │  │  A narrative combining all sources into a coherent │     │
  │  │  story of how the audio pipeline evolved, with     │     │
  │  │  citations to Slack, PRs, docs, and commits.       │     │
  │  └────────────────────────────────────────────────────┘     │
  │                                                              │
  └──────────────────────────────────────────────────────────────┘
```

---

## External Citation Format

When personas cite external sources, the citation must include
enough context to find the source without leaking sensitive content.

```
  ┌──────────────────────────────────────────────────────────┐
  │  EXTERNAL CITATION FORMATS                                │
  │                                                           │
  │  Slack:                                                   │
  │  [slack: #engineering, 2026-02-10, thread by @kim,        │
  │   topic: "opus vs g711 codec choice"]                     │
  │                                                           │
  │  GitHub PR:                                               │
  │  [github: PR #34, "Add Opus decoder support",             │
  │   review comment by @dana, 2026-02-28]                    │
  │                                                           │
  │  Google Doc:                                              │
  │  [gdoc: "Audio Pipeline Proposals", § "Codec Selection",  │
  │   last modified 2026-02-15]                               │
  │                                                           │
  │  Jira:                                                    │
  │  [jira: GATE-142, "Quiet speakers not understood",        │
  │   reported 2026-03-20, status: resolved]                  │
  │                                                           │
  │  Git:                                                     │
  │  [git: commit abc123, "revert opus decoder",              │
  │   author: @kim, 2026-03-05]                               │
  └──────────────────────────────────────────────────────────┘
```

---

## Privacy and Access Control

Feelers touch sensitive data. Rules:

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║  FEELER ACCESS RULES                                             ║
║                                                                  ║
║  1. READ-ONLY. Feelers never write to external systems.          ║
║     No posting to Slack, no creating issues, no editing docs.    ║
║                                                                  ║
║  2. SCOPED. Each feeler config specifies:                        ║
║     • Which channels/folders/projects to access                  ║
║     • Time range (e.g., last 6 months only)                     ║
║     • Content filters (e.g., exclude #random, #social)          ║
║                                                                  ║
║  3. SUMMARIZE, DON'T QUOTE. Personas cite external sources      ║
║     by reference (topic, date, author) not by copying            ║
║     verbatim content into spec documents.                        ║
║                                                                  ║
║  4. NO CREDENTIALS IN DOCS. External citations use topic         ║
║     descriptions, not URLs with auth tokens or session IDs.      ║
║                                                                  ║
║  5. USER APPROVES. The first time a feeler is invoked in a       ║
║     session, the user sees what's being accessed and approves.   ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

### Scoped Configuration Example

```yaml
# In specs/.storytime/config.md
feelers:
  slack:
    channels: ["#engineering", "#sip-gateway", "#incidents"]
    exclude_channels: ["#random", "#social", "#hr"]
    time_range: "6 months"

  github:
    repos: ["1ps0/ai-sip-gateway"]
    include: ["prs", "issues", "reviews"]
    exclude: ["actions-logs"]  # too noisy

  gdocs:
    folders: ["Engineering/Design Docs", "Engineering/RFCs"]
    exclude_folders: ["HR", "Finance"]
```

---

## The Reality Check

Not all feelers are created equal. Here's the honest assessment:

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║  FEELER DIFFICULTY MATRIX                                        ║
║                                                                  ║
║  Source          Difficulty   MCP Exists?   Auth Pain   Value    ║
║  ──────────     ──────────   ───────────   ─────────   ─────    ║
║                                                                  ║
║  GitHub          Easy         Yes (good)    Token       High     ║
║  git (local)     Trivial      N/A (Bash)    None        High     ║
║  Slack           Easy         Yes (good)    Bot token   High     ║
║  Linear          Easy         Yes           API key     Medium   ║
║  Jira            Medium       Partial       OAuth       Medium   ║
║  Google Docs     Medium       Yes (basic)   OAuth/SA    Medium   ║
║  Notion          Medium       Yes           API key     Medium   ║
║  Confluence      Hard         Partial       OAuth+SSO   Medium   ║
║  Teams           Hard         No            Graph API   Low*     ║
║  SharePoint      Nightmare    No            Graph+SPO   Low*     ║
║  Azure DevOps    Hard         No            PAT+OAuth   Medium   ║
║                                                                  ║
║  * Value is low because the auth/setup cost exceeds the          ║
║    information value for most teams. The data is usually         ║
║    duplicated in Slack or GitHub anyway.                          ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

### Why Microsoft Is Painful

- **Teams:** Requires Azure AD app registration, admin consent for
  message read permissions, Graph API with delegated + application
  scopes, pagination through delta queries. The API returns HTML
  fragments wrapped in JSON wrapped in OData. Rate limits are
  aggressive and opaque.

- **SharePoint:** Everything above plus SharePoint-specific REST API
  (separate from Graph for many operations), site collection
  permissions, list/library distinction, managed metadata term
  store. File content requires download + parse (not inline).

- **Azure DevOps:** Separate auth from Azure AD (PATs or OAuth with
  different scopes). Work item query language (WIQL) is its own
  DSL. Git repos have different API paths than GitHub despite
  similar concepts.

The pragmatic path: **don't build Microsoft feelers unless someone
is paying for it.** The information in Teams/SharePoint is almost
always duplicated in tools that are easier to access.

---

## Phased Rollout

```
  Phase 1 (now):     git (local) + GitHub
  ─────────────      Already available via Bash and existing
                     MCP servers. No new infrastructure.

  Phase 2 (soon):    Slack
  ─────────────      MCP server exists. High value — most
                     engineering decisions happen in Slack.

  Phase 3 (later):   Google Docs + Linear/Jira
  ─────────────      MCP servers exist or are straightforward.
                     OAuth setup is annoying but one-time.

  Phase 4 (if needed): Confluence + Notion
  ─────────────────    Enterprise customers may require these.
                       Build on demand.

  Phase 5 (never*):   Microsoft tooling
  ──────────────────   * Unless contractually required and
                         budget-funded. Life is too short.
```

---

## The RECONSTRUCT Event

New event type for the event registry:

```
  Event: RECONSTRUCT
  ─────────────────
  Participants: full team + Archivist specialist
  Input:        topic/system to reconstruct + feeler config
  Output:       procedural-history.md

  Phases:
  1. PULL SOURCES   — invoke feelers, gather raw material
  2. BUILD TIMELINE — chronological ordering of events
  3. INTERPRET      — team discussion of what happened and why
  4. CRYSTALLIZE    — produce the procedural history document

  Skills available:
  • All standard skills (read_file, grep_code, etc.)
  • All configured feelers (slack_search, github_pr, etc.)
  • git_archaeology (specialized: blame, log, diff analysis)
```

---

## Open Questions

1. **How much external context is too much?** If a Slack search
   returns 50 threads, the context window explodes. Need a
   relevance filter or summarization step before passing to personas.

2. **Feeler caching?** Should results be cached locally to avoid
   repeated API calls? If yes, where? How long? Cache invalidation
   is already the hardest problem in computer science.

3. **Offline mode?** If feelers are unavailable (no network, expired
   tokens), should RECONSTRUCT degrade gracefully to git-only
   archaeology, or refuse to run?

4. **Cross-team privacy?** If Team A's Storytime accesses Slack
   channels that Team B considers private, who arbitrates? The
   scoped config helps but doesn't solve the social problem.
