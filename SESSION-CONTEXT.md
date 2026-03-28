# Session Context — Storytime Genesis

Full context dump from the session that created Storytime.
Use this to resume work in the storytime repo with full continuity.

---

## What Happened (chronological)

### Phase 1: AGC Feature Spec via Persona Team (ai-sip-gateway)

**Problem:** Quiet speakers on SIP calls aren't picked up by Nova Sonic.
The gateway forwards 8kHz G.711 PCM to the WebSocket with no level normalization.

**What was built:**
1. `specs/agc/team.md` — 5 personas: Kim (owner), Dana (VoIP), Raj (DSP specialist), Mira (ASR specialist), Leo (SRE)
2. `specs/agc/icebreaker.md` — Status quo discussion, code-grounded
3. `specs/agc/plan.md` — 10-slide ASCII deck with implementation plan

**Key decisions (AGC-001 through AGC-006):**
- Per-frame gain normalization at -40/-20 dBFS
- ENHANCE_AUDIO env var kill switch (default: enabled)
- Scratch buffer reuse for zero-alloc processing
- SIP→Nova path only (not Nova→SIP)
- Per-call stats in call-end log
- Measure-only mode when enhancement disabled

### Phase 2: Storytime System Design

**What was built:**
1. `specs/storytime/plan.md` — High-level overview, principles, concepts
2. `specs/storytime/ideas.md` — Brainstorm with a meta-team (Noa/DX, Tomas/knowledge, Priya/agents, Kai/narrative)
3. `specs/storytime/core.md` — Formal process spec with three pillars:
   - **Pillar 1:** Interactive conversation modes (inline, deliberation, QA)
   - **Pillar 2:** Persistent cohort system (lifecycle, specialists, cross-session memory)
   - **Pillar 3:** Speckit process engine (events, skills, mid-conversation breakouts, state machine, 18 rules)

### Phase 3: AGC Code Implementation

**What was built (in ai-sip-gateway):**
- `pkg/enhance/enhance.go` — StreamEnhancer with scratch buffer, measure-only mode, all DSP math
- `pkg/enhance/enhance_test.go` — 7 tests + 1 benchmark, all passing
- `pkg/config/config.go` — EnhanceAudio field, ENHANCE_AUDIO env var
- `cmd/v1/main.go` — Integration: enhancer created per-call in ForkToWebSocket, ProcessBytes in hot path, stats in defer

**Benchmark:** 309ns/frame, 0 allocs/op (Apple M4 Max). Budget was 1ms.

### Phase 4: Storytime Plugin Scaffold

**What was built (~/workspace/storytime → github.com/1ps0/storytime):**

```
storytime/
├── .claude-plugin/plugin.json
├── skills/
│   ├── storytime/SKILL.md          Full workflow skill
│   ├── storytime-qa/SKILL.md       Persona query skill
│   ├── storytime-retro/SKILL.md    Retrospective skill
│   └── storytime-cohort/SKILL.md   Team management skill
├── scripts/
│   ├── bootstrap-cohort.sh         Init .storytime/ in any project
│   ├── validate-citations.sh       Check stale code references
│   └── export-decisions.sh         Decision log → CSV/text
├── docs/
│   ├── comparisons.md              vs Speckit, Kiro, OpenSpec, ADRs
│   ├── process-reference.md        Events, skills, rules, formats
│   ├── architecture.md             Agent model, breakout dispatch
│   ├── multi-repo-distribution.md  Install models, org cohort, versioning
│   ├── historical-absorption.md    Codebase archaeology, interface docs
│   └── context-feelers.md          MCP connectors, RECONSTRUCT event
├── examples/
│   ├── agc-session.md              Real AGC walkthrough
│   └── persona-template.md         New persona starter
├── README.md
└── BACKLOG.md                      25+ ideas across 6 themes
```

### Phase 5: Cohort Bootstrap (ai-sip-gateway)

**What was built:**
```
specs/.storytime/
├── cohort/
│   ├── _roster.md                  3 permanent personas
│   ├── kim-owner-architect.md      With AGC session context
│   ├── dana-systems-voip.md        With AGC session context
│   └── leo-operator-sre.md         With AGC session context
├── specialists/                    (empty — Raj and Mira completed contracts)
├── history/
│   ├── decisions.md                AGC-001 through AGC-006
│   └── sessions/
│       └── 2026-03-24-agc.md       Session summary
└── config.md                       Project settings
```

### Phase 6: Plugin Installation

**Current state:** Plugin is symlinked into the Claude Code marketplace:
```
~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/storytime
  → /Users/alexevers/workspace/storytime
```

Install command: `/plugin install storytime@claude-plugins-official`
(user needs to run this in Claude Code)

---

## Open Threads (not yet resolved)

### Plugin Installation
The symlink approach works for local dev. For team distribution,
need either a private marketplace repo or the project-local model
(see docs/multi-repo-distribution.md).

### Verbose Filename Convention
Persona files now use `name-archetype-specialty.md` format.
Applied to ai-sip-gateway cohort. Documented in process-reference.md.

### Automation Gradient
Three levels defined (manual/guided/auto) in README and config.
Not yet implemented in the skill — the SKILL.md references it
but the actual phase-gating logic needs to be built.

### Subagent Permission Issue
Background agents dispatched from ai-sip-gateway can't write to
~/workspace/storytime/ (outside project sandbox). Two options:
1. Run agents from the storytime repo context
2. Write docs from the main thread (current workaround)

### Feeler Integration
Context feelers are designed (docs/context-feelers.md) but not
implemented. Priority order: git (trivial) → GitHub (easy) →
Slack (easy) → Google (medium) → Microsoft (never unless paid).

---

## User Preferences (from this session)

1. **No Co-Authored-By lines** in commits. Never.
2. **No sed/cat -A** for file inspection. Use Read/Grep.
3. **Batch operations** — don't n+1 permission prompts.
4. **Persona co-authoring in commits** is a desired feature for
   Storytime (crediting personas who contributed to decisions).
5. **ASCII visual aids** — user prefers boxed slides and diagrams.
6. **Verbose filenames** for personas (name-archetype-specialty.md).
7. **Private repos** go to the `1ps0` GitHub org.

---

## Key File Locations

### Storytime Plugin
- Repo: `~/workspace/storytime/` → `github.com/1ps0/storytime`
- Symlink: `~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/storytime`

### AI SIP Gateway (first Storytime project)
- Repo: `~/workspace/ai-sip-gateway/`
- AGC spec: `specs/agc/{team,icebreaker,plan}.md`
- Storytime state: `specs/.storytime/`
- AGC code: `pkg/enhance/`, `cmd/v1/main.go`, `pkg/config/config.go`
- Storytime design specs: `specs/storytime/{plan,core,ideas}.md`

### Memory
- `~/.claude/projects/-Users-alexevers-workspace-ai-sip-gateway/memory/`
  - `feedback_no_claude_coauthor.md`
  - `feedback_no_sed_cat_A.md`
  - `feedback_batch_permissions.md`
  - `project_storytime.md`

---

## Next Steps (from user's stated goals)

1. **Install the plugin** — user runs `/plugin install storytime@claude-plugins-official`
2. **Run storytime on a real feature** — validate the full workflow end-to-end
3. **Multi-repo distribution** — discussed in docs, needs implementation
4. **Feeler connectors** — start with GitHub + Slack MCP integration
5. **Backlog prioritization** — 25+ ideas to triage
