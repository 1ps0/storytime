---
type: proposal
topic: board
created: 2026-08-14
status: synthesis — five-seat subagent breakdown, decisions pending @user
cross-refs: schema/state.schema.json (machine-readable seed),
  docs/board-state-schema.md (prose contract 0.4.0),
  specs/.storytime/sessions/board/_thread.md (BOARD-001..025)
---

# Project State as a publishable spec — breakdown synthesis

@user asked: can the board live in its own publishable project, with a
state.json specification of OpenAPI caliber — and how should "state as
derived from experience through storytime" split into a primary file
with secondaries, which use cases pilot it, what the versioning
contract is across main/branches/releases, and what else. Five
parallel investigators covered spec surface, file architecture,
pilots, versioning, and the adversarial what-else seat. Full reports
are annexed verbatim; this synthesis is the operative plan.

## Answers to the two lead questions

**Own project: yes.** The client is one self-contained file, the
contract is versioned, and every hard dependency crossing the future
repo boundary is enumerated with its cut (Annex E §1). What moves:
spec + JSON Schema + fixtures + conformance suite + reference client +
reducer-agnostic transport server. What stays: fold.py as the first
reference producer, threads, skills. The tether: conformance suites
run in both CIs, so divergence is a red run, not a drifted copy.

**Spec of OpenAPI caliber: seeded.** The trio is JSON Schema 2020-12
(`schema/state.schema.json` — written, and both the committed fixture
and the live 73-item state validate against it), RFC-2119 normative
prose (31 rules inventoried with sources, Annex A §1), and an
executable conformance suite (assertion list drafted, Annex A §2c).
Extension mechanism: `x-` prefixed fields, un-prefixed namespace
reserved for the spec (Annex A §3).

## Already done during the breakdown (realized at 5419939)

- Origin + Host guards on the server: cross-site browser POSTs and
  DNS-rebinding requests get 403; curl/local tools unaffected. (The
  critic's top risk — any webpage could previously write your command
  queue.)
- Last-look snapshot scoped per (repo.root, branch) — boards over
  different checkouts can no longer cross-pollinate moved dots.
- `measured`-option-without-pointer now fails loud in the fold (was
  documented, unenforced).
- `budget.unrealized` now emits (sealed decisions, all producers).

## Decisions that are yours (ranked)

1. **Extraction: go / not yet.** Everything is prepared either way;
   going means a new repo (private → github.com/1ps0) built from the
   Annex E layout.
2. **Name.** Candidates: `foldstate` (names the contract),
   `glanceboard` (names the UX law), `quietboard` (names the loudness
   budget). Spec releases would read `<name>/0.5`.
3. **Adopt the two permanent non-goals** (Annex C §4): no
   history/timeseries in state (OP-004 sealed law); no
   producer-computed "moved" (BOARD-002). Both are decline-by-design.
4. **Pilot order.** Recommended: kb `board-state` first (zero schema
   work, proves everything external), then harvest-events shape +
   morning surface (one definition, two OP-law clients), then CI
   probe-overlay key (`probe_results` — annotation without ownership).
5. **VERIF-P1** remains open on the thread (dot fill = measurement
   honesty; amends frozen BOARD-002).

## The plan, phased

- **P0 (done):** security + honesty fixes above; schema seed validated.
- **P1 — spec hardening in place:** promote the 31-rule inventory into
  RFC-2119 prose sections (core vs storytime-producer-profile split;
  restate inherited laws in the spec's own words — OP-009's text is
  unpublishable by design); close the 12 gap items (id grammar,
  RFC 3339 timestamps, ordering collation, null-vs-absent, unknown-enum
  client rule, localhost definition, sentinels); write the wire-protocol
  section (SSE events, /command, bridge `{verb,args,item}` →
  `{ok,output|error}`, reserved `fold/self` and `command/<id>` ids);
  make the publish profile normative (strip `source:"local"` entities,
  `repo.root`, command timestamps).
- **P2 — extraction (on your go):** new repo per Annex E layout; server
  gains a config-driven reducer command + packaged default UI + queue
  path/allow-list from producer config; invocation templates move into
  state so the client is producer-agnostic; plugin decides vendored vs
  pinned board copy.
- **P3 — pilots in the recommended order**, each landing with fixture +
  conformance case in the same change ("every MUST has a test" as the
  governance meta-rule).
- **File architecture (as needed, additive):** core/overlay split
  (publishable `state.json` + local `state.local.json`) when sharing
  state matters; `state.d/` content-addressed shards when payloads
  outgrow the glance; harvest files keyed by boundary commit. The
  partition principle and atomicity design are settled in Annex B.

---

# Annex A — Spec surface & formalization (investigator 1)

[Report follows verbatim.]

## 1. Inventory of normative rules now living in prose

1. Determinism: identical inputs → byte-identical output; no wall clock anywhere; `generated_from` = source short SHA.
2. Canonical serialization (load-bearing for #1, currently only in code): UTF-8, 2-space indent, sorted keys, non-ASCII unescaped, trailing newline.
3. Stable ordering: topics id-sorted; items sorted by (topic, id); tensions sorted; commands id-sorted.
4. Atomicity: every write is tmp + fsync + rename; a reader never observes a torn file.
5. Fail loud: malformed input → exit 2 with file:line; never partial state.
6. Degrade quiet: every top-level key is client-optional; missing = quiet absence, never a warning or error.
7. "Moved since last look" is client-side; a `moved` field is forbidden in state.json.
8. Current-only: no timeseries/trends; `harvest_events[]` reserved, boundary-folds only, never ambient.
9. Top-level shape: 14 keys; `provenance` ∈ {fold, fixture}.
10. Versioning: semver-shaped; additive optional keys → minor; anything a v0 client would misrender → major; both parties MUST print the version they speak on disagreement; client fail-honest on major mismatch.
11. `provenance:"fixture"` MUST render visibly — a fixture mistakable for real work is a lying board.
12. Repo identity: clients MUST render `repo.name` in header and tab title; root/branch tooltip-only.
13. Producer partial contract: `board/producers.d/<name>.json`, same schema major, `producer` == filename stem, optional `as_of` ISO, any subset of six entity keys, atomic write.
14. Fold owns the reduction — exactly one reducer, globally; no producer computes "current" or overwrites another.
15. Fold stamps `producer` on every entity, auto-stubs referenced topics, fails loud on major mismatch / name≠stem / malformed JSON / duplicate item ids; nothing silently dropped.
16. Supersedes resolved by the fold alone, repo-wide, cross-topic; retired/superseded items excluded from `items[]`, counted in `Topic.retired`.
17. `label` ≤ 7 words.
18. depth ← lifecycle mapping: proposed→surface, focused→forming, sealed/realized→bedrock; `track` depth only via `track{}`.
19. `state` drives the loudness budget: normal quiet; waiting_user amber + larger; violated/blocked/collision red-tier; fold asserts state, client renders weight.
20. `contested` true iff `edges.tensions` non-empty.
21. `options[].mark: "measured"` REQUIRES a pointer (now fold-enforced).
22. `canonical` is the drill target; drill retrieves the authoritative entry, never regenerates.
23. Derived question identity: `<TOPIC>-Q-<hash6>`, stable under reorder, new id on rewording, marked `identity:"derived"`.
24. Action ladder: `risk:"sensitive"` NEVER renders as a button; `routine` + `local-bridge` may be one click POSTing `{verb,args,item}`; bridge MUST be localhost, clients refuse anything else; `copy-command` always copies; bridge is the producer's own runner/allow-list/audit; board holds no credential, mints no verb.
25. Authored fields round-trip through the agent; everything else derived, read-only in any client.
26. Directives: `fired` counts candidates generated; `source:"local"` entries never appear in committed state; `[]` when no source.
27. Command queue custody: click → POST → append-only fsync'd `commands.jsonl` (gitignored); fold surfaces `pending` only; agent actions with full authority and marks `done`; neither server nor board edits the record.
28. Guardrails surface in exactly one place — `guardrail_blocks[]`, only on block, attached to the item; fold self-failures land as reserved id `fold/self` while last-good state persists.
29. Budget is fold-derived only; producers set item states, never totals.
30. Command set: two tiers (live POST vs copy-invocation, plain words); no command mutates state directly; every button captioned in plain language.
31. Locality: server binds 127.0.0.1 only; state.json is always the target repo's fold; per-machine variance in local inputs is by design.

## 2. Formalization split

(a) JSON Schema 2020-12 — two schemas over shared $defs: full document + producer partial. Expressible in-schema: contested⇔tensions, measured→pointer, label word-count approximation, sensitive⇒copy-command, enums, id/timestamp patterns, bridge URL pattern.
(b) Normative prose (RFC 2119) — rules 1–8, 10–12, 14–16, 19, 22, 24–31.
(c) Executable conformance suite — double-fold byte-compare; re-serialize canonical-form check; malformed-input corpus → exit 2 + output untouched; tmp+rename protocol check; producer accept/reject corpus; cross-document linter (contested⇔tensions, measured→pointer, budget recount, retired-excluded, dangling refs); golden fixture validates; client checklist (fixture banner, sensitive-not-a-button, non-localhost refusal, major-mismatch fail-honest, missing-key quiet).
Unformalizable in JSON Schema, must not be pretended otherwise: byte determinism, serialization/ordering, atomicity, exit codes, cross-document derivations, referential integrity, client rendering/refusal obligations.

## 3. Extension mechanism — recommendation

`x-` prefixed fields (OpenAPI-style), convention `x-<producer>-<name>`: strict schema sets `additionalProperties: false` plus `patternProperties: {"^x-": {}}`; reducer MUST pass `x-` fields through untouched; clients MUST ignore unknown `x-` fields. Rejected: bare `additionalProperties: true` (spec can't claim new names in a minor without silent collision) and registered extensions (process overhead unjustified; fights append-first).

## 4. Conformance classes

Producer MUST: atomic-write its partial; declare same schema major and `producer` == filename stem; emit only subset entity keys in conforming shapes; mint ids unique and stable within itself; never emit `budget`, `provenance`, `repo`, `moved`, or another producer's stamp; declare honest `risk` with localhost-only bridges. SHOULD: RFC 3339 `as_of`; `x-<name>-` for private fields.
Reducer MUST: be the sole computer of "current"; deterministic, byte-identical, no wall clock; canonical serialization, stable ordering; atomic writes; fail loud (exit 2, file:line, no partial output); stamp `producer`; resolve supersedes globally, exclude retired; derive budget; auto-stub topics; pass `x-` through; surface own failures as `fold/self`.
Client MUST: tolerate missing keys as quiet absence; render fixture provenance visibly; render `repo.name` in header + tab; fail-honest on major mismatch printing both versions; treat non-authored fields read-only; mutate nothing directly; never render `sensitive` as a button; refuse non-localhost bridges; compute "moved" locally; ignore unknown fields; keep last-good state on fold error.

## 5. Gaps in the 0.4.0 contract

1. Id grammar unconstrained (charset, length, uniqueness scope beyond items/topics).
2. Cross-reference formats inconsistent (bare ids vs topic/ID); dangling refs and cycles unaddressed.
3. Timestamps: three shapes coexist; no RFC 3339 profile, no timezone rule.
4. Ordering for six arrays unspecified; collation undefined.
5. Lengths/sizes unbounded (summary, argument, message, lens content; document size).
6. Encoding rules only exist as fold behavior — never normative.
7. Null vs absent vs "" undefined; sentinels coexist with nulls.
8. Unknown enum values: client behavior undefined — every new enum value silently becomes a major-version question.
9. Budget divergence (now partially closed: unrealized emits; review_debt remains unemittable).
10. Rule 21 unenforced (closed during breakdown — fold now rejects).
11. "Localhost" undefined (127.0.0.1 vs ::1 vs literal; scheme/port).
12. `generated_from` sentinels and short-SHA length undocumented; minor-skew behavior beyond majors unspecified; producer-file atomicity is "please"-strength.

---

# Annex B — Primary/secondary file architecture (investigator 2)

[Report follows verbatim.]

## 1. Partition principle

One rule, four tests. A datum stays PRIMARY iff all four hold; failing any sends it secondary:
- Rendered-at-altitude — the glance or the drill summary panel paints it. The primary is exactly "one read renders a complete, quieter board."
- Bounded-per-card — size scales with card count, not content volume. Working threshold: inline lens content ≤ ~2 KB, else shard + bounded fallback.
- Fold-cadenced — regenerated whole every fold. Data with its own cadence (append-only queues, boundary-only harvests) is a different file by nature.
- Same privacy class — BOARD-016 splits publishable from user-local; one file cannot be both.
Corollary: the loud tier (violated/blocked/collision/waiting_user) is unconditionally primary — deviation must never cost a second fetch.

## 2. Secondary taxonomy

Three families: inputs (feed the fold), truth (fold summarizes, never owns), derived (fold emits beside the primary under `board/state.d/`).

| kind | file | family | purpose |
|---|---|---|---|
| producer partial | `board/producers.d/<name>.json` | input (exists) | same-schema subsets merged by the fold |
| command queue | `specs/.storytime/commands.jsonl` | input (exists) | append-only @user intent; local-only |
| canonical record | `sessions/<topic>/_thread.md#<ID>` | truth (exists) | drill target; retrieved live, never restated |
| lens payload | `board/state.d/<sha8>-lens-<id>.json` | derived | oversized lens content; primary keeps meta + ref + truncated fallback |
| topic shard | `board/state.d/<sha8>-topic-<id>.json` | derived | drill-tier overflow; card-tier fields never leave items[] |
| harvest log | `board/state.d/harvest-<boundary-sha>.json` | derived | one file per boundary fold; keyed by commit SHA, never wall clock |
| local overlay | `board/state.local.json` | derived | all BOARD-016 classes: local directives, commands, user teammate row, machine facts (repo.root) |

Core/overlay split is the payoff: the core folds committed inputs only and becomes committable/shareable; the overlay folds `_user.md` + `commands.jsonl` + machine state. The client merges overlay onto core; a core alone is a valid, quieter board.

## 3. Reference mechanism

Derived-secondary ref object: `{ref: "board/state.d/<file>", sha256, bytes}` — repo-root-relative, not JSON-Schema $ref (these are optional fetches with degrade semantics, not inline substitution). Canonical-record refs stay bare path#anchor strings, no hash — threads move ahead of folds by design; hash-pinning would manufacture false staleness. Served: fetch relative, verify sha256, cache by hash. file://: refs unreachable, so the primary embeds a bounded fallback for any ref whose absence would blank a rendered region. Every ref optional; unreachable ref = quiet absence, never an error.

## 4. Atomicity + coherence

Per file: V1-018 exactly (tmp + fsync + replace). Cross file: content-addressed shards, primary written last — the primary doubles as the manifest, so a ref can only name a file that fully existed before the primary swapped in. Rejected: swap directory (POSIX can't atomically replace a dir), symlink-flip (breaks file://). Generation stamp: every file carries the same `generated_from`; the overlay carries `core_sha256` of the core it was folded with — clients merge only on match, else render core alone quietly. GC after primary replace unlinks unreferenced shards; crash leaves only harmless orphans. Determinism holds: hash-derived names are pure functions of content.

## 5. Anti-goals

1. No N-fetch glance — nothing loud-tier may exist only in a shard; shards add drill/lens depth, never board width.
2. No second opinion — exactly one file asserts any fact per generation; no secondary is hand-editable.
3. No privacy bleed — BOARD-016 classes exist only in the overlay; the core never references the overlay; the dependency arrow points local→core, never core→local.
4. No ambient history — harvest secondaries are boundary-emitted and drill-fetched; neither fold nor client may accumulate them into glance-altitude timeseries.

---

# Annex C — Use-case pilots (investigator 3)

[Report follows verbatim.]

## 1. Pilot inventory

| Pilot | Role | Status | Exercises | Gaps in 0.4.0 |
|---|---|---|---|---|
| storytime board.html | client | live | Full grammar, SSE/poll/file:// degradation, drill, lenses, queued-command chips, repo header | None schema-side; data gaps only (FIX-000 minted ids, Realized_at backfill) |
| storytime fold | producer | live | Determinism, atomicity, fail-loud, merge ownership, supersede resolution | harvest_events[] reserved but never emitted; probe/adherence overlays have no feed |
| kickbox board :9999 | client | live (25 real items) | --repo portability, --check readiness, repo{} identity | None |
| kb board-state | producer | planned; contract settled | producers.d merge, as_of, delivery lane from status.json, amber from DRIFT rows, candidates from gaps ledger | No topic-level health tint; no warn tier |
| kickbox action bridge | executor | planned, last | Action ladder end-to-end | Streamed output vs one-shot response — acceptable v0 |
| fixture/demo | producer surrogate | live, committed | Fixture banner, file:// embed, drag-drop | Fixture staleness = lint concern |
| agent as queue-consumer | consumer | live (manual drain) | Command lifecycle pending→done→cleared | No surface for a failed command; auto-drain is skill wiring |
| status surface (BOARD-012) | client | planned | Fold as status authority | Skill wiring only |
| morning surface (D-4/OP-006) | client | planned | Zero-ask warm view | Blocked on harvest_events shape |
| harvest events (OP-004/D-3) | producer feature | planned | Boundary-only felt change | Shape undefined; naive timestamps would violate FIX-004 |
| sleep capture → residue (D-5) | producer | implied | 3am voice → intent-map → residue slot | Transport fits already; intent-map is a new secondary |
| meta-board | client | implied; deferred | N state files, repo{} as namespace | No cross-repo id convention; no aggregate artifact |
| CI as producer | producer | implied | Probe overlays, acceptance flips, guardrails at_commit | Cannot annotate foreign items (dup-id fail-loud) |
| retro/adherence views | client | implied | Unrealized alarm, plan-vs-built | No Item.realized_at; history out of scope by law |

## 2. Smallest unblocking addition per gap (all additive)

- Topic health: optional `Topic.health: "green"|"amber"|"red"`.
- Warn tier: optional `Item.severity: "warn"` (do NOT widen the state enum).
- Bridge streaming: out of scope (wire protocol, not state).
- Command failure: convention — guardrail entry with reserved id `command/<id>`.
- Auto-drain: out of scope (skill wiring).
- Harvest events: `HarvestEvent {id, at_commit, scale, kind: settled|probe_green|superseded, item?, text}` — boundary-commit-pinned, never wall clock.
- Sleep capture: no schema change — a `capture` producer emitting candidates with `origin: "capture:sleep"`; intent-map is a new secondary.
- Meta-board: no schema change; document `repo.name/<id>` display convention; aggregate artifact deferred.
- CI probe overlay: additive producers.d key `probe_results: [{item, status, pointer, at_commit}]` — annotation the fold applies onto items regardless of owner.
- Retro: optional `Item.realized_at`. History/timeseries: out of scope.
- Fixture staleness: lint, not schema.

## 3. Next 3 pilots by leverage

1. kb board-state — zero schema work remaining; first external producer proves the whole multi-producer contract against real ops data.
2. Harvest events + morning surface — one shape unblocks two OP-law clients and tests determinism under event-driven emission.
3. CI probe overlay — one additive key proves reduction monopoly under cross-producer annotation and turns probe/acceptance from schema fiction into measured fact.

## 4. Explicit NON-goals

1. History/timeseries in state.json — OP-004/D-3 sealed law; history lives in threads, reached by drill; determinism becomes unmaintainable otherwise.
2. Producer-computed "moved"/recency — BOARD-002 seals moved-since-the-human-last-looked as client-side. Decline by design, permanently.

---

# Annex D — Versioning contract (investigator 4)

[Report follows verbatim.]

## 1. Three version axes

(a) Spec/schema version — `schema_version` (full semver) in state.json and every producer partial. Major N clients render any N.x; minor = additive; major = misrender risk.
(b) Producing repo's state identity — `generated_from` (short sha), `repo{}`, `provenance`, per-producer `as_of`. Promise: provenance, not reproducibility — the fold reads the working tree; `generated_from` is a lower bound; determinism holds per machine per instant.
(c) Implementation versions — deliberately not independently versioned; each declares only which schema it speaks. The self-reloading server's implementation version is definitionally "what's on disk"; a version const would lie.

## 2. Branch semantics

State is branch-scoped already, de facto and correctly — derived, disposable, per-checkout, gitignored. Worktrees: each root is its own board; identity key is (repo.root, repo.branch); nothing may join boards on name. Detached HEAD: treat branch ∈ {"", "HEAD"} as detached, render generated_from in its place. Cross-branch comparison is out-of-band: fold both checkouts and diff — determinism + sorted keys make plain diff meaningful. The last-look snapshot key must include (repo.root, branch) [implemented during the breakdown]. Merges need no state semantics: threads merge as text; the first fold after merge recomputes everything — re-fold IS the merge semantics.

## 3. Release contract

Frozen numbered releases `projectstate/<major>.<minor>` (immutable copies + git tag) plus one LATEST living draft. A release pins: JSON Schema file + sha256, conformance suite version (fixtures promoted per-release), prose revision. Instances conform to a release, not a git tip. Deprecation: never remove within a major; deprecate in a minor (doc + "deprecated": true); remove only at next major with migration notes; renames = add-new + deprecate-old.
Compatibility matrix: producer→fold same major else FoldError naming both; client←state render iff same major (fail-honest banner); minor skew always renders (unknown ignored, absent quiet); patch never observable; any major mismatch refuses loud with both versions printed. Optional escape hatch: fold MAY accept major N−1 behind an explicit --migrate-producer shim; default refuse.

## 4. Identifier scheme

Keep `schema_version` as the sole instance field; name spec releases `projectstate/<major>.<minor>` carried as a URI-style $id in the JSON Schema. Do NOT introduce `spec_version` — two names invite skew; renaming the emitted field is a gratuitous major. Patch lives only in instances.

## 5. Major-bump migration story

Single switch: SCHEMA_VERSION in fold.py. (1) Freeze outgoing release (hash + fixtures). (2) One lockstep commit: schema doc + JSON Schema + fold const + client gate + both fixture copies. (3) Fixtures regenerated + validated; stale fixture rejected instantly at load. (4) producers.d files from other repos fail loud per file on next fold — the designed failure site; that repo's board stays on last-good with fold/self in the alarm lane until its producer updates on its own clock. (5) Old state.json is never migrated — derived state is re-derived. (6) Threads untouched — inputs are schema-unversioned prose. Invariant: no component silently accepts, drops, or partially migrates; every refusal names both versions and a file:line.

---

# Annex E — Completeness critic (investigator 5)

[Report follows verbatim.]

## 1. Extraction seams audit

Moves: spec (genericized), board.html, fixtures (+ future invalid cases), transport server (serve + SSE + queue half), conformance suite (born in the new repo). Stays: fold.py (first reference producer), thread format/parsing, bootstrap_repo.py, skills.
Boundary-crossing dependencies and cuts: server `import fold` → config-driven reducer command (subprocess; exit 2 + file:line stderr as the error contract) + declared watch-inputs manifest; PLUGIN_BOARD `../board` fallback → packaged default UI + --ui override; hardcoded `/storytime-*` invocation strings in board.html → invocation templates move into state (schema addition), client becomes producer-agnostic; COMMANDS allow-list + queue path hardcoded → producer config; schema doc carries storytime flavor as if core → mark core vs producer-profile sections; fold stamps "storytime" and reads ~/.storytime → stays, but the spec hardcodes neither name.

## 2. Trust & privacy in a published context

Promote BOARD-016 to normative data classification: define local-only classes by name (user operator models, intents, command queue, any state folding source:"local" directives); entities marked source:"local" MUST NOT appear in committed, served-off-machine, or published state; producers MUST support a publish profile that strips them. The publish profile also strips repo.root (path leaks usernames/machine layout) and command timestamps (behavioral metadata). Fixture banner stays a MUST (anti-fabrication). BOARD-023's ladder becomes an RFC-style Security Considerations section in MUST language. Normative provenance problem: OP-009's text is unpublishable — the spec must restate every inherited law in its own words under its own authority.

## 3. Naming + governance

Candidates: foldstate (names the contract), glanceboard (names the UX law), quietboard (names the loudness budget). Avoid bare "board." Governance: spec repo carries its own public decision log (same thread format — dogfood it); Alex as maintainer/final seal; any normative change lands only with fixture + conformance case in the same PR; major bumps require sign-off from at least one non-storytime implementation. Storytime becomes first-among-producers, not the authority.

## 4. Publishing mechanics

License: MIT (c) 2026 Alex Evers — clean fit; plugin manifest already declares MIT. Repo sketch: spec/ (schema.md, security.md, transport.md), schema/ (state.schema.json), fixtures/ (valid + invalid, provenance-labeled), conformance/ (producer + client runners), client/ (board.html), server/ (reducer-agnostic transport), decisions/ (public thread; CHANGELOG; LICENSE). Storytime keeps fold.py, pins a spec version, declares what it emits. Sync tether: each CI runs the other's conformance suite; divergence is a red run, not a drifted copy.

## 5. Genuinely missed, ranked by risk-if-ignored

1. CSRF/DNS-rebinding on /command — any webpage could POST into the queue the agent executes. [Fixed during the breakdown: Origin + Host guards.]
2. Wire protocol is lore, not spec — SSE event shapes, /command POST, poll fallback, reserved fold/self; a second server/client pair cannot interop from the spec alone.
3. Bridge protocol ownership — {verb,args,item} → {ok,output|error} half-lives in kickbox docs; spec must own it or scope it out.
4. `canonical` drill resolution is local-only — spec needs a resolver contract or an explicit local-only marking.
5. Plugin packaging split — once the new repo exists, decide whether the marketplace plugin vendors, pins, or drops its board copy; otherwise two silently divergent boards.
