---
type: design-doc
created: 2026-03-28T02:24
session: null
---

# Multi-Repo Distribution

How Storytime distributes across repositories, teams, and orgs.

---

## Installation Models

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║  MODEL 1: Marketplace Symlink (current)                          ║
║                                                                  ║
║  ~/workspace/storytime/                                          ║
║       │                                                          ║
║       └── symlink ──► ~/.claude/plugins/marketplaces/            ║
║                       claude-plugins-official/external_plugins/  ║
║                       storytime/                                 ║
║                                                                  ║
║  Install: /plugin install storytime@claude-plugins-official      ║
║  Pros:  Works now. Development changes appear immediately.       ║
║  Cons:  Machine-local. Not portable across team members.         ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  MODEL 2: Private Marketplace (recommended for teams)            ║
║                                                                  ║
║  github.com/1ps0/claude-plugins/                                 ║
║       ├── external_plugins/                                      ║
║       │   └── storytime/ ──► git submodule to 1ps0/storytime     ║
║       └── README.md                                              ║
║                                                                  ║
║  Register: /plugin marketplace add github:1ps0/claude-plugins    ║
║  Install:  /plugin install storytime@1ps0-claude-plugins         ║
║  Pros:  Team-wide. Version-pinned. Standard mechanism.           ║
║  Cons:  Extra repo to maintain.                                  ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  MODEL 3: Direct Git Clone (simplest for solo use)               ║
║                                                                  ║
║  git clone git@github.com:1ps0/storytime.git                    ║
║  ln -s ~/workspace/storytime \                                   ║
║    ~/.claude/plugins/marketplaces/.../external_plugins/storytime  ║
║                                                                  ║
║  Pros:  One command. Full control.                               ║
║  Cons:  Manual. Each machine needs the symlink.                  ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  MODEL 4: Project-Local Plugin (per-repo)                        ║
║                                                                  ║
║  my-project/                                                     ║
║  ├── .claude-plugins/                                            ║
║  │   └── storytime/ ──► git submodule                            ║
║  ├── specs/.storytime/                                           ║
║  └── src/                                                        ║
║                                                                  ║
║  Pros:  Plugin version locked to project. No global install.     ║
║  Cons:  Duplicated across repos. Overhead per project.           ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

## Per-Project State vs Shared State

```
  PER-PROJECT (lives in repo)          SHARED (lives outside repo)
  ──────────────────────────           ────────────────────────────

  specs/.storytime/                    ~/.storytime/          (user)
  ├── cohort/                          ├── org-cohort/        (org)
  │   personas who know THIS code      │   personas who know
  │                                    │   the org's patterns
  ├── history/                         │
  │   decisions for THIS project       ├── templates/
  │                                    │   reusable persona defs
  ├── specialists/                     │
  │   temp experts for THIS work       └── decision-index/
  │                                        cross-repo search
  └── config.md
      THIS project's settings

  Resolution order:
  1. Project cohort (most specific)
  2. Org cohort (inherited defaults)
  3. Plugin defaults (fallback)
```

### What Goes Where

| Artifact                  | Location           | Why                                    |
|---------------------------|--------------------|----------------------------------------|
| Persona files             | project cohort     | Context is codebase-specific           |
| Decision log              | project history    | Decisions belong to the project        |
| Session summaries         | project history    | Sessions are about this code           |
| Config                    | project config.md  | Settings vary per project              |
| Persona templates         | shared templates   | Reusable across projects               |
| Org-wide expertise        | shared org-cohort  | "Our SRE practices" apply everywhere   |
| Cross-repo decision index | shared index       | "What did we decide about auth?"       |

## Org-Level Cohort

An org cohort represents expertise that applies across all projects.
Think: "how we do observability here" or "our API design standards."

```
  ~/.storytime/org-cohort/
  ├── _roster.md
  ├── platform-sre-standards.md       "How we run things in prod"
  ├── backend-api-patterns.md         "Our REST/gRPC conventions"
  └── security-compliance.md          "What legal requires"

  When a project session starts:

  ┌───────────────────────────────────────────────┐
  │  Load order:                                  │
  │                                               │
  │  1. Read specs/.storytime/config.md           │
  │     → which org personas to inherit           │
  │                                               │
  │  2. Load org personas from ~/.storytime/      │
  │     → generic expertise, no project context   │
  │                                               │
  │  3. Load project personas from specs/.storytime│
  │     → project-specific expertise              │
  │                                               │
  │  4. Merge: project overrides org on conflicts │
  │     Kim (project) knows more about THIS code  │
  │     than the org's generic "owner" template   │
  └───────────────────────────────────────────────┘
```

### Inheritance Rules

- Org personas provide **default expertise** (e.g., "our SRE always
  checks for circuit breakers")
- Project personas **override** org personas with the same name
- If a project persona references an org persona's decision, the
  citation uses a qualified ID: `org:SRE-STANDARDS-001`
- Org personas cannot be fired at the project level — only benched

## Cross-Repo Persona Continuity

When Kim works on both ai-sip-gateway and a separate service, her
knowledge should carry across — but scoped appropriately.

```
  ┌─────────────────────────────┐    ┌─────────────────────────────┐
  │  ai-sip-gateway             │    │  billing-service             │
  │                             │    │                             │
  │  specs/.storytime/cohort/   │    │  specs/.storytime/cohort/   │
  │  kim-owner-architect.md     │    │  kim-owner-architect.md     │
  │                             │    │                             │
  │  Kim knows:                 │    │  Kim knows:                 │
  │  • Audio pipeline           │    │  • Payment flow             │
  │  • AGC decisions            │    │  • Stripe integration       │
  │  • Enhance package          │    │  • Idempotency patterns     │
  │                             │    │                             │
  │  Kim can reference:         │    │  Kim can reference:         │
  │  • AGC-001 through AGC-006  │    │  • BILLING-001              │
  │  • gateway:AGC-001 (qual'd) │    │  • billing:BILLING-001      │
  └─────────────────────────────┘    └─────────────────────────────┘
                │                                │
                └──────────┬─────────────────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │  Kim's persona  │
                  │  is the SAME    │
                  │  archetype but  │
                  │  DIFFERENT      │
                  │  context per    │
                  │  project.       │
                  └─────────────────┘
```

### Qualified Decision IDs

When referencing decisions across repos:

```
  Within same project:     AGC-001
  Cross-project:           gateway:AGC-001
  Org-level:               org:SRE-STANDARDS-001
```

### Sync Protocol (optional, manual)

If you want Kim's gateway experience to inform her billing work:

```bash
# Export Kim's context summary from gateway
cd ai-sip-gateway
./scripts/export-persona-context.sh kim > /tmp/kim-gateway.md

# Import as reference into billing
cd billing-service
cat /tmp/kim-gateway.md >> specs/.storytime/cohort/kim-owner-architect.md
```

This is deliberately manual. Automatic cross-repo sync is a future
feature (see BACKLOG.md) and carries risks of context pollution.

## Versioning

```
  Plugin version:     0.1.0, 0.2.0, ...  (storytime repo tags)
  State format:       v1, v2, ...          (persona/decision file format)

  ┌──────────────────────────────────────────────────┐
  │  Compatibility Matrix                            │
  │                                                  │
  │  Plugin 0.1.x  →  State format v1               │
  │  Plugin 0.2.x  →  State format v1 (compatible)  │
  │  Plugin 1.0.x  →  State format v2 (migration)   │
  │                                                  │
  │  State format version in config.md:              │
  │  ---                                             │
  │  state_format: v1                                │
  │  ---                                             │
  └──────────────────────────────────────────────────┘

  On plugin load:
  1. Read config.md state_format
  2. Compare to plugin's expected format
  3. If mismatch: run migration script or warn
  4. If compatible: proceed
```

## Team Workflows

Multiple humans using Claude Code on the same repo will interact
with the same Storytime state through git.

```
  Alice's session                    Bob's session
  ──────────────                     ──────────────
  /storytime "add caching"          /storytime-qa @kim "auth pattern?"
       │                                  │
       ▼                                  ▼
  Writes:                            Reads:
  specs/caching/team.md              specs/.storytime/cohort/kim-*.md
  specs/caching/plan.md              specs/.storytime/history/decisions.md
  Updates:
  specs/.storytime/cohort/kim-*.md   No writes needed (QA only)
  specs/.storytime/history/decisions.md
       │
       ▼
  git add + commit
  git push
       │
       ▼
  Bob pulls, sees new decisions
  His next session has updated context
```

### Conflict Resolution

Git handles most conflicts automatically (markdown is text).
For the rare case where two sessions update the same persona:

- **Decision log:** Append-only. No conflicts possible.
- **Persona files:** Last writer wins on `acquired_context` section.
  Both sessions' context gets merged on the next pull.
- **Roster:** If two sessions hire personas simultaneously, manual
  merge needed (rare — typically one person manages the cohort).

### Decision ID Namespacing

To avoid ID collisions when multiple people run Storytime:

```
  Convention: <TOPIC>-<NNN>

  Alice: CACHING-001, CACHING-002
  Bob:   AUTH-001, AUTH-002

  No collision because topics are different.
  If same topic: coordinate via git (first push wins the ID).
```

## Open Questions

1. **Should org-cohort live in a git repo or ~/.storytime/?**
   Git repo is shareable. Home dir is faster. Hybrid: git repo
   checked out to ~/.storytime/org-cohort/?

2. **How often should cross-repo persona sync happen?**
   Every session? On-demand? Never (keep personas isolated)?
   Current answer: on-demand manual export/import.

3. **Should the plugin auto-detect other Storytime-enabled repos?**
   e.g., scan ~/workspace/*/specs/.storytime/ to build a cross-repo
   index. Useful but potentially slow and surprising.
