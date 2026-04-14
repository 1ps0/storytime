---
type: roster
schema_version: 1
created: 2026-03-29T16:00
updated: 2026-04-14T12:30
---

# Storytime Cohort Roster

## Address Resolution

Roles are the functional address. Codenames resolve to roles.

| @codename | Resolves to | Focus                  |
|-----------|-------------|------------------------|
| @anchor   | @owner      | architecture           |
| @tide     | @operator   | reliability            |
| @arbor    | @domain     | info-architecture      |
| @drift    | @skeptic    | developer-experience   |
| @compass  | @platform   | ai-human-interaction   |

## Active Roster

| Codename | File                              | Archetype | Status | Since      | Sessions | Last Active |
|----------|-----------------------------------|-----------|--------|------------|----------|-------------|
| anchor   | anchor-owner-architect.md         | owner     | active | 2026-03-29 | 1        | 2026-04-14  |
| tide     | tide-operator-reliability.md      | operator  | active | 2026-03-29 | 1        | 2026-04-14  |
| arbor    | arbor-domain-infoarch.md          | domain    | active | 2026-03-29 | 1        | 2026-04-14  |
| drift    | drift-skeptic-devex.md            | skeptic   | active | 2026-03-29 | 1        | 2026-04-14  |
| compass  | compass-platform-interaction.md   | platform  | active | 2026-03-29 | 1        | 2026-04-14  |

## Prior names (migration v0.9 → v1.0)

On 2026-04-14 during v1.0 migration, the grandfathered human-named
cohort was renamed to non-human codenames per Rule 22 (codenames
non-human by default). Mapping preserved for lookback:

| v0.9 name | v1.0 codename |
|-----------|---------------|
| reva      | anchor        |
| deshi     | tide          |
| oona      | arbor         |
| pike      | drift         |
| taro      | compass       |

All back-references in session artifacts were updated in the migration
commit. Persona file `git log --follow` preserves history.
