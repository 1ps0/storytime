# Artifact Scan Reference

How SURVEY discovers prior work artifacts across a repository.

---

## Scan Targets

Cast a wide net. Expect high variance across repos in the wild.

```
╔═══════════════════════════════════════════════════════════════════╗
║  PATTERN                      WHAT IT MIGHT BE                    ║
║  ───────────────────────────  ─────────────────────────────────── ║
║                                                                   ║
║  specs/**/*.md                Prior storytime output, spec docs   ║
║  .storytime/                  Prior cohort state, decision logs   ║
║  docs/**/*.md                 Design docs, ADRs, RFCs             ║
║  .kiro/**                     Kiro spec files                     ║
║  AGENTS.md, agents.md         Agent definitions                   ║
║  agents/**/*.md               Agent definitions (directory form)  ║
║  **/*.adr.*                   Architecture decision records       ║
║  **/README.md                 May contain design rationale         ║
║  CLAUDE.md, .claude/**        Prior Claude instructions            ║
║  .cursor/**                   Cursor rules and context             ║
║  .github/**/*.md              PR templates, contributing guides    ║
║  rfcs/**/*.md                 RFC documents                        ║
║  design/**/*.md               Design documents                    ║
║  adr/**/*.md                  ADR directories                     ║
║                                                                   ║
║  SKIP: node_modules, vendor, .git, dist, build, __pycache__      ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

## Classification

Each discovered artifact gets classified for routing:

| Classification | Routes to       | Examples                              |
|---------------|-----------------|---------------------------------------|
| **team-like** | ASSEMBLE (rehire candidates) | persona files, agent defs, team.md |
| **spec-like** | ICEBREAKER (prior work review) | plan.md, RFC, ADR, design doc    |
| **config-like** | Loaded silently | CLAUDE.md, .cursor rules, config.md |
| **noise**     | Skipped         | Generic README, changelog, license   |

### Team-Like Heuristics

An artifact is team-like if it contains:
- Persona definitions (name + archetype/role + background)
- Agent definitions (description + capabilities)
- Team rosters or role assignments
- Anything in `.storytime/cohort/` or `agents/`

### Spec-Like Heuristics

An artifact is spec-like if it contains:
- Decision records (numbered decisions, rationale)
- Implementation plans (steps, requirements)
- Architecture descriptions (diagrams, component lists)
- Design proposals (problem statement + solution)
- Interface specifications (protocols, data formats)

## Inventory Presentation

Present the inventory to the user as a checklist. Each item gets:
- Checkbox (pre-checked for likely-relevant items)
- Filename
- Short description (< 10 words) if filename isn't self-descriptive
- Classification tag: `[team]` `[spec]` `[config]`

### Example Output

```
Prior artifacts found (12 files):

Team-like:
 [x] specs/.storytime/cohort/kim-owner-architect.md  [team]
 [x] specs/.storytime/cohort/dana-systems-voip.md     [team]
 [ ] .kiro/agents/reviewer.md — Kiro code review agent [team]

Specs & docs:
 [x] specs/agc/plan.md — AGC implementation plan       [spec]
 [x] specs/agc/icebreaker.md — AGC team discussion      [spec]
 [ ] docs/architecture.md — system architecture          [spec]
 [ ] docs/rfc-003-backpressure.md — draft, never merged  [spec]
 [ ] .kiro/specs/websocket-reconnect.md                  [spec]

Config (auto-loaded):
 [i] CLAUDE.md — project instructions
 [i] .cursor/rules — Cursor editor rules

Keep checked items? Options:
  • Toggle items on/off
  • "tell me about <item>" — get a one-paragraph summary
  • "bring the team in on <item>" — team reviews it during icebreaker
  • "skip all" — cold start, no prior context
```

## User Interaction Model

The inventory is presented as a checklist first. Then the user can:

1. **Toggle items** — check/uncheck to include or exclude
2. **Ask about an item** — get a quick summary before deciding
3. **Direct instruction** — "ignore all the kiro stuff" or "keep all specs"
4. **Bring the team in** — flag an item for team review during icebreaker
5. **Skip all** — proceed with no prior context (cold start)

Team-like artifacts route to ASSEMBLE as rehire candidates.
Spec-like artifacts route to ICEBREAKER for team review.
Config-like artifacts load silently into session context.
