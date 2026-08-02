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
  "schema_version": "0.1.0",
  "provenance": "fold" | "fixture",
  "generated_from": "<git short sha>",
  "topics": [Topic],
  "items": [Item],
  "directives": [Directive],
  "guardrail_blocks": [GuardrailBlock],
  "candidates": [Candidate],
  "budget": Budget,
  "lenses": [Lens],
  "teammates": [Teammate]
}
```

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

v0 clients stub commands as copy-to-clipboard skill invocations; no
command mutates state directly (the board is a client of storytime's
authority, never a fork):

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
