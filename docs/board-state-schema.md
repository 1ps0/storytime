# Board State Schema — v0

The contract between the fold (producer) and the board (client), per
BOARD-010. One derived `state.json` is the only thing the board reads;
this document is the authority on its shape. Schema carries a version
from day one; changes require an explicit bump (FIX-004 acceptance).

Status: v0, sealed into buildout 2026-08-02 (topic `board`, episode
001). Producer: `scripts/fold.py`. Committed sample:
`board/fixture-state.json` (fictional, provenance-labeled). Live
output `board/state.json` is local-only — it may fold user-local
directives (BOARD-016) — and is gitignored.

## Design constraints (inherited, load-bearing)

- **Determinism (FIX-004):** two folds with no intervening events are
  byte-identical. Therefore: no wall-clock timestamps anywhere;
  `generated_from` is the source commit SHA; keys are emitted sorted;
  arrays are emitted in stable (id-sorted or source-order) order.
- **"Moved since last look" is client-side (BOARD-002).** The accent
  dot marks change since the *human* last looked, not since the last
  fold. The board diffs incoming state against the state it last
  rendered (localStorage); the fold emits pure current state. A
  `moved` field in state.json would break determinism and encode the
  wrong semantics.
- **No trend lines, ambiently (OP-004 / D-3).** State is current-only.
  No timeseries arrays, no sparklines, no history in the glance.
  History lives in threads (drill retrieves it, BOARD-004); felt
  change arrives as discrete harvest events at natural boundaries —
  `harvest_events[]` is reserved (v0.2+), emitted only at boundary
  folds, never accumulated ambiently.
- **Atomicity (V1-018, via tide):** every state.json write is
  tmp + fsync + mv. A consumer never observes a torn file.
- **Fail loud (FIX-001):** the fold on malformed input exits nonzero
  with file and line; it never emits partial state.
- **Degrade gracefully (BOARD-010):** every top-level key is optional
  for the client. A producer that supplies less gets a quieter board,
  not a broken one. Missing = quiet absence (BOARD-003), not a warning.

## Top level

```json
{
  "schema_version": "0.4.0",
  "provenance": "fold" | "fixture",
  "generated_from": "<git short sha>",
  "repo": { "name": "kickbox", "root": "/abs/path", "branch": "main" },
  "producers": [ { "name": "kickbox", "as_of": "<iso>", "items": 12 } ],
  "topics": [Topic],
  "items": [Item],
  "directives": [Directive],
  "commands": [Command],
  "guardrail_blocks": [GuardrailBlock],
  "candidates": [Candidate],
  "budget": Budget,
  "lenses": [Lens],
  "teammates": [Teammate]
}
```

Version history: 0.2.0 added `commands[]` (BOARD-021). 0.3.0 added
`producers[]`, per-entity `producer` stamps, `Item.action`, and
itemized question items with `identity: "derived"` (BOARD-022..024).
0.4.0 added `repo{}` identity (BOARD-025). All additive.

`repo` is the board's identity: clients MUST render `repo.name` in the
header and the page title (multiple boards over different repos must
be tellable apart at a glance and in the tab bar); `root` and `branch`
belong in a tooltip, not the glance.

## Producers — the multi-producer contract (BOARD-022)

The fold merges partial states from other systems so the board surveys
the whole project, not just storytime threads. **Producers are inputs;
the fold owns the reduction** — no producer computes "current", and
none can overwrite another.

A producer drops `board/producers.d/<name>.json` (atomic write,
please): a JSON object with `schema_version` (same major),
`producer: "<name>"` (must equal the filename stem), optional
`as_of` (ISO string, the producer's own freshness claim, surfaced in
the header), and any subset of `items`, `candidates`,
`guardrail_blocks`, `directives`, `lenses`, `topics` — same shapes as
this schema. The fold stamps every merged entity with
`producer: "<name>"` (its own get `"storytime"`), auto-stubs topics
referenced only by producer items, and **fails loud** on: version
major mismatch, name ≠ stem, malformed JSON, or duplicate item ids
across producers. Nothing is silently dropped (FIX-001).

First intended producer: kickbox's `kb board-state` (see kickbox
`specs/architecture/board-producer.md`).

`provenance: "fixture"` MUST be rendered visibly by any client (the
widget lineage's "transport v2 cutover" content is demo fiction; a
fixture that could be mistaken for real work is a lying board).

## Topic

```json
{
  "id": "board",
  "title": "board",
  "phase": "BUILD",
  "last_commit": "175a104",
  "open_questions": 3,
  "retired": 1
}
```

`retired` counts decisions with lifecycle retired/superseded — they do
not appear in `items[]` (OP-004: out of sight once settled; drill and
lenses can still reach them through the thread).

## Item

One card on the board. v0 items are decisions and delivery work;
kinds widen per BOARD-013 as identity (FIX-000) arrives.

```json
{
  "id": "BOARD-010",
  "topic": "board",
  "kind": "decision" | "question" | "delivery",
  "label": "control surface seam",
  "depth": "surface" | "forming" | "bedrock" | "track",
  "state": "normal" | "waiting_user" | "violated" | "blocked" | "collision",
  "contested": false,
  "is_candidate": false,
  "origin": "@user" | "@owner [anchor]" | "probe" | "ci",
  "owner": null,
  "lifecycle_state": "proposed" | "focused" | "sealed" | "realized",
  "probe": { "status": "green" | "red" | "none", "pointer": null },
  "canonical": "specs/.storytime/sessions/board/_thread.md#BOARD-010",
  "summary": "one to three sentences for the drill panel",
  "options": [ { "text": "...", "mark": "measured" | "judgment", "pointer": "file:line" | null } ],
  "edges": {
    "parent": "BOARD-001",
    "edge_type": "refines",
    "tensions": [],
    "supersedes": null,
    "callouts": [ { "target": "v1-consolidation/V1-022", "kind": "supersedes" } ]
  },
  "track": { "stage": "criteria" | "build" | "pr" | "review" | "merged" | "deployed",
             "acceptance": { "green": 0, "red": 3 } }
}
```

Field rules:

- `label` — the handle, ≤ 7 words (BOARD-001). The fold derives it
  from the decision title; lint (future) flags overruns.
- `depth` mapping v0: `proposed` → surface, `focused` → forming,
  `sealed`/`realized` → bedrock; `track` only via `track` object.
  Retired/superseded items are excluded from `items[]` entirely.
- `state` drives the loudness budget (BOARD-003): `normal` renders
  quiet; `waiting_user` renders amber AND physically larger;
  `violated`/`blocked`/`collision` are red-tier — the loudest things
  that can exist. The fold asserts state, the client renders weight.
- `contested` = dashed border; true iff `edges.tensions` is non-empty
  (BOARD-002: data source is tensions edges).
- `is_candidate` = dashed outline; not yet accepted (BOARD-008 entry
  state). Full Candidate records live in `candidates[]` until
  accepted; an accepted candidate becomes an Item.
- `options[].mark` — solid dot = `measured` (fact with pointer),
  hollow dot = `judgment` (OP-008). A `measured` option without a
  `pointer` is invalid; the fold rejects it.
- `canonical` — drill target (BOARD-004): file + anchor of the
  authoritative entry. Drill retrieves; it never regenerates.
- `owner` — FIX-005 (v1.2); null until ownership lands.
- `producer` — which system emitted this entity (stamped by the fold;
  `"storytime"` for thread-derived). Clients show non-storytime
  producers as a card chip.
- `identity: "derived"` (optional) — the id is content-derived, not
  minted (question items today: `<TOPIC>-Q-<hash6>`, stable under
  reorder, new id on rewording). Interim until FIX-000; clients treat
  it like any id.
- `action` (optional) — a real-world act this card offers, executed by
  the *producing* project's own machinery, never the board's
  (BOARD-023, "compose never mint"):

  ```json
  { "verb": "kb fix stale-mirror", "args": null,
    "risk": "routine" | "sensitive",
    "execution": "local-bridge" | "copy-command",
    "bridge": "http://127.0.0.1:7077/act" }
  ```

  Client obligations, non-negotiable: `sensitive` NEVER renders as a
  button — the card copies the command and says why in plain words
  (the password ceremony is the safety). `routine` +
  `execution: "local-bridge"` may be one click: POST
  `{verb, args, item}` to `bridge`, which must be localhost — clients
  refuse any non-localhost bridge. The bridge shells the producer's
  own verb through its own runner, allow-list, and audit log, and
  responds `{ok, output?|error?}`. `copy-command` always copies.
- Authored fields (`label`, `summary`, `options[].text`) are
  edit-round-trip surfaces (BOARD-005); everything else is derived
  and read-only in any client.

## Directive

The rail (BOARD-009): visible standing intent, an intake pump.

```json
{
  "id": "DIR-001",
  "text": "never trade clean for easy silently",
  "origin": "@user",
  "status": "alive" | "parked",
  "fired": 3,
  "last_candidate": "CAND-004",
  "source": "local" | "repo"
}
```

`fired` counts candidates generated — the chip that shows the pump is
alive. `source: "local"` marks directives folded from user-local state
(BOARD-016): they appear on a local board but are absent from any
committed state. The fold emits `[]` when no directives source exists.

## Command

The pending half of the control loop (BOARD-021). A board click POSTs
`{command, item}` to the server, which appends a pending entry to
`specs/.storytime/commands.jsonl` (append-only, fsync'd, gitignored —
it is @user intent, BOARD-016). The fold surfaces pending entries
here; the board renders them as queued chips. The agent consumes the
queue with full authority — thread edits, skill runs — then marks
entries `done`; the next fold clears them from the board. Neither the
server nor the board ever edits the record itself.

```json
{
  "id": "CMD-001",
  "command": "seal",
  "item": "TRAN-012",
  "args": null,
  "origin": "@user",
  "at": "2026-08-06T10:12:00"
}
```

## GuardrailBlock

The alarm lane — the only place guardrails surface (BOARD-009), only
on block, attached to the blocked item.

```json
{
  "id": "GRB-001",
  "item": "TRAN-014",
  "guardrail": "check-conventions/atomic-writes",
  "message": "state write skipped tmp+fsync+mv",
  "at_commit": "abc1234"
}
```

Includes fold/hook failures themselves (FIX-003: a hook failure lands
here, not stderr oblivion — reserved guardrail id `fold/self`).

## Candidate

Dashed-outline pre-items awaiting acceptance (BOARD-008 entry).

```json
{
  "id": "CAND-004",
  "label": "extract retry into transport module",
  "origin": "directive:DIR-001" | "@skeptic [drift]" | "probe",
  "argument": "one-paragraph case, carried verbatim",
  "target_topic": "transport-v2"
}
```

## Budget

The strip — scalar debts, current-only (no trends, OP-004).

```json
{
  "review_debt": 2,
  "waiting_user": 1,
  "open_questions": 4,
  "unrealized": 3
}
```

`waiting_user` is derived by the fold (count of items in state
`waiting_user`, across all producers) — producers set item states,
never budget totals.

`unrealized` = sealed decisions with no delivery under them —
`get_unrealized` as a first-class alarm (BOARD-006).

## Lens

Codebase-truth views (BOARD-004): togglable, swappable, expandable.

```json
{
  "id": "arch",
  "title": "architecture",
  "kind": "ascii" | "mermaid",
  "content": "...",
  "source": "README.md:154"
}
```

## Teammate

The roster rails (origin, BOARD-002). From committed roster data only.

```json
{
  "codename": "anchor",
  "role": "owner",
  "focus": "architecture",
  "status": "active",
  "last_active": "2026-08-02"
}
```

@user appears as a first-class teammate (V1-031).

## Command set (BOARD-010) — client obligations

Two tiers, by what is on the other end. **Live** (served by
board_server): a click POSTs to `/command`, the intent is queued
instantly (OP-001: the click always lands), and the queued state
renders on the card until the agent actions it. **Not live** (static
server or file://): the click copies the skill invocation for pasting
to the agent, and the drill says so in plain words. In both tiers no
command mutates state directly — the board is a client of storytime's
authority, never a fork. Every action button carries a plain-language
caption (BOARD-021: no insider vocabulary); the invocations behind
them:

| command | stub target |
|---|---|
| seal | `/storytime-qa seal <id>` |
| add-option | `/storytime-qa add option to <id>` |
| accept-candidate | `/storytime-consolidate accept <cand-id>` |
| edit-item | `/storytime-qa edit <id>` |
| add-directive | `/storytime-qa add directive` |
| park | `/storytime-remember nap` |
| request-review | `/storytime-lint <topic>` |

## Versioning

`schema_version` is semver-shaped. Additive optional keys bump minor;
anything a v0 client would misrender bumps major. The fold and any
client MUST print the version they speak when they disagree.
