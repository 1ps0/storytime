---
type: reference
name: artifact-types
description: "Registry of all storytime artifact types, their required fields, and schema version. Used by artifact scan and lint for classification and validation. Schema v2 at v1.0 adds consolidation, remembrance, dream, proposal, thread-is-decision-log."
---

# Artifact Type Registry

Every storytime-generated file carries `schema_version` in frontmatter.
This registry defines what "valid" means per type.

## Schema Version History

| Version | Since  | Changes                                                              |
|---------|--------|----------------------------------------------------------------------|
| 1       | v0.7.2 | Initial — survey, team, breakout, plan, buildout, preamble, config, persona, errors, thread |
| 2       | v1.0   | +consolidation, +remembrance, +dream, +proposal. Thread gains `type: thread`, `last_consolidation`, `dreams`, `remembrance_staged`, `remembrance_path`. Decisions merge into threads (V1-003). |

When reading an artifact without `schema_version`, treat as version 0
(pre-v0.7.2). Apply best-effort parsing; warn but don't fail.

## Types

### Phase artifacts (written by storytime phases)

| Type       | Required fields                              | Optional fields                     |
|------------|----------------------------------------------|-------------------------------------|
| survey     | type, created, schema_version                | session, fingerprint.commit         |
| team       | type, created, schema_version                | session, naming_note                |
| icebreaker | type, created, schema_version, driver        | session, supporters                 |
| breakout   | type, created, driver, schema_version        | supporters, supporters_who_spoke, session, topic, subtopic |
| plan       | type, created, schema_version, driver        | session, status                     |
| buildout   | type, created, driver, schema_version        | supporters, plan_items, decisions, files_created, files_modified |
| preamble   | type, created, episode, schema_version       | prior_episode, prior_commit, current_commit, drift_commits |

### State artifacts (thread, history)

| Type              | Required fields                                           | Optional fields                     |
|-------------------|-----------------------------------------------------------|-------------------------------------|
| thread (v2)       | type, schema_version, topic                               | last_consolidation, last_completed_phase, last_commit, remembrance_staged, remembrance_path, episodes, decisions, dreams, open_questions, failures |
| session-summary   | type, schema_version, topic, episode, status              | created                             |
| errors            | type, created, session, episode                           | (entries in body)                   |

### v1.0 new types

| Type            | Required fields                                                       | Optional fields                     |
|-----------------|-----------------------------------------------------------------------|-------------------------------------|
| consolidation   | type, schema_version, scale, at, event, pause_posture                 | session, topic, commit, driver, supporters, signals, prior_consolidation, files_touched, decisions_pinned |
| remembrance     | type, schema_version, created, updated, compact_staged, last_commit, active_threads | active_personas, tutorial_state_path, commit_patterns_path |
| dream           | type, schema_version, created, commit                                 | session, topic, active_personas     |
| proposal        | type, schema_version, created, name, status                           | updated                             |
| commit-patterns | type, schema_version, updated                                         | (pattern entries in body)           |
| tutorial-state  | type, schema_version, updated                                         | (per-skill sections in body)        |
| migration-report| type, schema_version, created                                         | (applied/deferred/files sections)   |

### Config/persona

| Type    | Required fields                              | Optional fields                     |
|---------|----------------------------------------------|-------------------------------------|
| config  | type, created                                | mode, automation, naming, driving_persona, team_size, pause_mode, dreams_enabled, post_commit_hook |
| persona | type, created, archetype, status             | name, codename, focus, inception, last_active, sessions, evolved, acquired_context |
| agent   | type, created, name                          | (content in body)                   |

## Classification During Artifact Scan

When scanning non-storytime artifacts, classify by heuristic:

| Heuristic                                                 | Classification |
|-----------------------------------------------------------|----------------|
| Has `type:` in frontmatter                                | storytime artifact → use registry |
| Filename matches `*-agent.md`, `*-persona.md`, `team.md`  | team-like      |
| Filename matches `spec-*`, `plan-*`, `*.adr`, `*.rfc`     | spec-like      |
| Filename matches `CLAUDE.md`, `.cursorrules`, `*.kiro`    | config-like    |
| Contains decision IDs (`TOPIC-NNN` pattern)               | spec-like      |
| None of the above                                         | noise (skip)   |

See `references/import-adapters.md` for non-storytime artifact mapping.
