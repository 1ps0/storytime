---
type: reference
name: intents-format
description: "The .storytime/intents.md append-only log format. One line per extracted intent: timestamp, source, intent statement, driving lens(es), type. Reads via grep + awk. Load when authoring intent extraction tooling or reading the user's lens history."
---

# Intents Format

`.storytime/intents.md` is the **append-only log of extracted user
intents** per repo. One entry per user prompt or explicit intent
declaration. Read by `cohort/_user.md` to compute lens distribution and
by `/storytime-status` to surface "what mode you're in."

Per V1-031, opt-in. Doesn't exist unless user-as-role is enabled.

## Format

```yaml
---
type: intents-log
schema_version: 1
created: <YYYY-MM-DDTHH:MM>
---

# Intents log

## 2026-04-25T11:30 | session=v1.0.1-intent-graph-nascent
intent: Choose 1-2 items from intent discussion; ship user-as-role
lens: @owner + @platform
type: dispatch
source: user-prompt

## 2026-04-25T10:00 | session=null
intent: Save the intent gradient analysis to a doc
lens: @owner
type: dispatch
source: user-prompt

## 2026-04-19T09:00 | session=null
intent: Audit doc freshness against v1.0
lens: @critic + @educator
type: verify
source: user-prompt

(... entries continue, append-only ...)
```

## Per-entry shape

Each entry is a markdown sub-section with structured fields:

| Field   | Required | Format | Notes |
|---------|----------|--------|-------|
| header  | yes      | `## <ISO timestamp> \| session=<id-or-null>` | Greppable |
| intent  | yes      | one-line statement | The extracted intent |
| lens    | yes      | `@role [+ @role]` | Driving lens(es) |
| type    | yes      | one of vocabulary | See type vocabulary below |
| source  | yes      | `user-prompt | manual | hook` | Provenance |
| confidence | optional | `high | medium | low` | Tag for fuzzy extractions |
| supersedes | optional | `<entry-timestamp>` | If this entry corrects a prior |

## Type vocabulary

From the user-intent extraction analysis:

- `vision` — proposing direction
- `approval` — green-lighting a plan
- `dispatch` — directing action
- `resolve` — answering open questions
- `refine` — small correction
- `verify` — auditing / checking
- `meta` — reflection on the conversation itself

These map to the same types observed in the user-intent extraction
exercise. New types can be added; lint warns on unknown.

## Lens vocabulary

Roles from `references/team-assembly.md`:
`@owner | @operator | @critic | @domain | @systems | @platform |
@skeptic | @educator | @user`

`@user` is valid here when the user is referring to themselves
self-aware (rare; usually their lens is one of the others).

## Append-only semantics

- Entries are never edited. To correct, append a new entry with
  `supersedes: <prior-timestamp>`.
- Entries are never deleted. To remove user-as-role data, the user
  `git rm`s the whole file (and ideally `cohort/_user.md` with it).
- Entries are git-tracked. History visible via `git log .storytime/intents.md`.

## How entries arrive

Three paths in increasing automation:

1. **Manual** (v1.0.1): `/storytime-cohort update user --add-intent "..."
   --lens @owner --type dispatch`
2. **Conversation extraction** (v1.1+): hook on user message events
   produces candidate entries; user reviews/accepts.
3. **Inferred** (v1.2+): the model proposes intents during consolidation
   events; user reviews the batch at session DONE.

For v1.0.1, only manual entry is supported. The format is the bridge —
get it right now, automate population later.

## Reading the log

### Direct grep

```bash
# All @critic intents
grep -A 4 '^## 20' .storytime/intents.md | grep -B 2 'lens:.*@critic'

# Intents from a specific session
grep -A 4 'session=v1.0.1' .storytime/intents.md
```

### Via script (v1.0.1+)

```bash
./scripts/intent-graph-query.sh --user-intents --since=2026-04-01
./scripts/intent-graph-query.sh --user-intents --lens=@critic --tally
```

## Aggregation into `cohort/_user.md`

`cohort/_user.md` is a *summary view* of `intents.md`. It's not
authoritative; the log is. To rebuild the summary:

```bash
./scripts/intent-graph-query.sh --user-summary > /tmp/user-summary.md
# Then manually merge into cohort/_user.md
```

(v1.1+: this becomes automatic on session DONE.)

## Validation

Lint checks (mechanical, IT class — Intent Tracking):

| # | Check |
|---|-------|
| IT1 | Header line matches the timestamp+session regex |
| IT2 | All required fields present per entry |
| IT3 | `lens:` references known roles only |
| IT4 | `type:` is in the closed vocabulary |
| IT5 | `supersedes:` resolves to a prior entry |

Reasoning checks deferred to v1.2+ (intent-classification quality).

## Companion documents

- `references/user-as-role.md` — the persona convention
- `references/intent-graph.md` — how intents become graph nodes
- `docs/proposals/intent-extraction-user.md` — origin proposal
