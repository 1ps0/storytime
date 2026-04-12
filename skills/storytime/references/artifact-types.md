---
type: reference
name: artifact-types
description: "Registry of all storytime artifact types, their required fields, and schema version. Used by artifact scan and lint for classification and validation."
---

# Artifact Type Registry

Every storytime-generated file carries `schema_version: 1` in frontmatter.
This registry defines what "valid" means per type.

## Schema Version History

| Version | Since  | Changes                                        |
|---------|--------|------------------------------------------------|
| 1       | v0.7.2 | Initial — all types below                      |

When reading an artifact without `schema_version`, treat as version 0
(pre-v0.7.2). Apply best-effort parsing; warn but don't fail.

## Types

| Type       | Required fields                              | Optional fields                     |
|------------|----------------------------------------------|-------------------------------------|
| survey     | type, created, schema_version                | session, fingerprint.commit         |
| team       | type, created, schema_version                | session                             |
| breakout   | type, created, driver, schema_version        | supporters, supporters_who_spoke, session, topic, subtopic |
| plan       | type, created, schema_version                | session                             |
| buildout   | type, created, driver, schema_version        | supporters, plan_items, decisions, files_created, files_modified |
| preamble   | type, created, episode, schema_version       | prior_episode, prior_commit, current_commit, drift_commits |
| config     | type, created                                | mode, automation, naming, driving_persona, team_size |
| persona    | type, created, archetype, status             | name, focus, inception, last_active, sessions, evolved |
| errors     | type, created, session, episode              | (entries in body)                   |
| thread     | last_completed_phase, last_commit            | episodes, open_questions, failures  |

## Classification During Artifact Scan

When scanning non-storytime artifacts, classify by heuristic:

| Heuristic                        | Classification |
|----------------------------------|----------------|
| Has `type:` in frontmatter       | storytime artifact → use registry |
| Filename matches `*-agent.md`, `*-persona.md`, `team.md` | team-like |
| Filename matches `spec-*`, `plan-*`, `*.adr`, `*.rfc`    | spec-like |
| Filename matches `CLAUDE.md`, `.cursorrules`, `*.kiro`    | config-like |
| Contains decision IDs (TOPIC-NNN pattern)                 | spec-like |
| None of the above                                         | noise (skip) |
