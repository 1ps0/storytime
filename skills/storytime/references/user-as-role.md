---
type: reference
name: user-as-role
description: "The user is a first-class persona with their own driving lens, codename, and acquired_context. @user [codename] addresses them in artifacts. Their intents accumulate at .storytime/intents.md. Load when bootstrapping a repo or when authoring artifacts that involve user-driven decisions."
---

# User-as-Role

In v1.0.1+, the user is a first-class persona — `@user [codename]`. Just
as @owner [anchor] or @critic [forge] are addressable lenses with
acquired_context, so is the user. Their lens distribution accumulates
across sessions and becomes visible alongside the cohort.

The user can never be fired or benched (they're the user). Their lens is
not fixed like @critic or @owner — it shifts session by session. But
it's *trackable*, and tracking it makes blind spots visible.

## Why

From `intent-extraction-user.md`:
> The user's strong @owner + @platform leaves gaps in @critic, @domain,
> @skeptic, @educator. The cohort fills exactly those gaps. This is the
> cohort earning its keep, quantitatively. But: the user has no symmetric
> view of their own lens. Without aggregation, "I never operate from
> @skeptic" is invisible.

User-as-role makes this self-knowledge available.

## Convention

### Address forms

`@user` — anonymous user reference. Always works.
`@user [codename]` — addresses the specific user. Codename non-human
  per Rule 22 (default), but the user may pick a human name if they want.

When an artifact records `driver: "@user [anchor-bias]"`, that means the
user themselves drove that leg, with their own lens registered as
@user (not the cohort persona @owner [anchor]).

The codename is per-user-per-repo. A user working on multiple storytime
repos has different codenames per repo unless they explicitly seed.

### Persona file: `cohort/_user.md`

Underscore-prefixed to mark special. One per repo.

```yaml
---
type: persona
schema_version: 2
archetype: user                  # special; not in the standard 8
codename: <user-chosen>
status: active
inception: <date storytime bootstrapped>
sessions: [<session-ids>]
---

# User — lens-tracker

Persistent record of the user's driving lenses across storytime sessions
in this repo. Updated when intent extraction is enabled (v1.1+) or
manually via `/storytime-cohort update user`.

## Lens distribution (cumulative)

(Bar chart of % per lens, computed from .storytime/intents.md)

## Recent intents

(Last N from .storytime/intents.md, summarized.)

## Notable patterns

- **Driving lens:** @owner (73%) — strong architect orientation
- **Absent lens:** @skeptic (0% in last 4 weeks) — possible blind spot
- **Trending:** @platform increasing, @owner decreasing — direction shift?

## Sessions participated

(List of session-ids where user was driver or supporter.)
```

### Bootstrap behavior

`/storytime-bootstrap` does NOT auto-create `cohort/_user.md`. It's
opt-in:

```
Storytime bootstrap detected this is a new repo.
Want to enable user-as-role tracking?

  [yes] — create cohort/_user.md, choose your codename
  [no]  — skip; you can enable later via /storytime-cohort hire user
```

Skipping means storytime works as before — no user persona, no intent
extraction. Enabling later is always available.

### Where @user appears in artifacts

- **`driver:` or `supporters:` fields** when the user themselves authored
  the leg (vs a cohort persona)
- **Decision drivers** when a decision was user-decided (e.g., V1-024
  "friction calibration is hybrid" was driven by user input, could
  carry `drivers: [@user [anchor-bias], @platform [compass]]`)
- **Callouts** between user's intents and cohort decisions
- **Remembrance documents** under "active personas this session"
- **Prompt-yield documents** (V1-036) as the originating driver — the
  primary place @user appears as the document's *creator*, not just a
  participant. See `references/prompt-yield.md`.

## Differences from cohort personas

| Aspect | Cohort persona | @user |
|--------|----------------|-------|
| Created via | `/storytime-cohort hire` | bootstrap opt-in |
| Removable | yes (fire / bench) | no (only disable tracking) |
| Codename | non-human default | non-human default; user picks |
| Lens | fixed by archetype | tracked, shifts over time |
| Acquired context | session participation | user intent extraction |
| Speaks in artifacts | as persona voice | as user voice (or via @user lens annotation) |
| Multi-repo identity | per-repo file | per-repo codename, optional cross-repo seed |

## Interaction with intent extraction (v1.1+)

When intent extraction ships (v1.1+ scope per
`intent-extraction-user.md`), each user prompt → one or two short intent
statements + lens labels → appended to `.storytime/intents.md` →
aggregated into `cohort/_user.md` lens distribution.

For v1.0.1, the convention exists; the auto-extraction infrastructure is
deferred. Users who want to track lens distribution today can do it
manually via `/storytime-cohort update user --add-intent "..."`.

## Privacy

All data is **local**. Per-repo `cohort/_user.md` and
`.storytime/intents.md` are git-tracked but never sent anywhere. Users
who don't want their lens tracked don't enable user-as-role. Users who
enable it can `git rm` the files anytime.

## Companion documents

- `references/intents-format.md` — `.storytime/intents.md` schema
- `references/intent-graph.md` — graph model that user-as-role plugs into
- `docs/proposals/intent-extraction-user.md` — original proposal
- `docs/proposals/intent-extraction-roles.md` — role-side cross-reference
- `references/team-assembly.md` — cohort sizing and addressing
