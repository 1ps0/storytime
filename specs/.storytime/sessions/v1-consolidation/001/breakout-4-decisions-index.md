---
type: breakout
schema_version: 1
created: 2026-04-13T11:45
session: v1-consolidation
episode: 001
topic: v1-consolidation
subtopic: decisions-index
driver: "@domain [arbor]"
supporters: ["@skeptic [drift]"]
supporters_who_spoke: ["@skeptic [drift]"]
status: complete
---

# Breakout 4 — Global decisions index necessity

## Problem framing

V1-003 merges `specs/.storytime/history/decisions.md` into per-topic `_thread.md` files. V1-011 handles cross-topic references via bidirectional callouts (no duplicated content). Together they dissolve the single aggregation point `history/decisions.md` currently provides. The question: do we still need a global index, or can cross-topic views be synthesized on demand?

Current state grounded:
- `scripts/export-decisions.sh:11` cites `specs/.storytime/history/decisions.md` as canonical path.
- `scripts/export-decisions.sh:23-32` defines the current CSV shape a shim must preserve.
- V1-003 puts decisions append-only inside threads, commit-pinned (`docs/proposals/v1-consolidation.md:209-229`).
- V1-011 bidirectional callouts, no duplication (`docs/proposals/v1-consolidation.md:471-476`).

## Use cases (the spine)

Arbor enumerated plausible global queries; drift cut anything that wouldn't actually run.

| # | Use case | Frequency | Who |
|---|---|---|---|
| U1 | All active decisions, project-wide | occasional | new contributor, retro |
| U2 | Decisions sealed in last N days | occasional | standup, release notes |
| U3 | Filter by tag (e.g., [security]) | rare | audit |
| U4 | Supersession graph across topics | rare | architectural review |
| U5 | Export to ADR / Kiro / CSV | rare | external tooling |
| U6 | In-session "is X still active?" | frequent | during work |
| U7 | "What did we decide last time we touched auth?" | frequent | before related work |

Drift's cut: U6 and U7 are answered *inside* the topic — V1-003 puts decisions on the thread, V1-011 makes cross-topic supersessions visible via callouts on the thread you're already reading. So **U6 and U7 are already solved** without a global anything. Only U1–U5 are genuinely cross-topic.

## Options considered

### Option A — Pre-built global index (`.storytime/decisions.md`)
Single aggregating file updated on every decision seal via post-commit hook.
- **Write cost:** one append per seal (negligible runtime, but new partial-failure surface on a hook already doing thread updates + optional dreams).
- **Read cost:** single file, single grep — fastest option.
- **Drift risk:** index can desync; needs reconciliation script.
- **Earning its keep:** replaces `history/decisions.md`, but is *fed by a new hook step* — added hook surface for rare read-time value.

### Option B — On-demand synthesis (script, callouts only)
No persistent global file. A script greps all `_thread.md`, parses decisions, renders the view.
- **Write cost:** zero.
- **Read cost:** ~200 grep hits for realistic scales (10 topics × 20 decisions) — sub-second. Stays sub-second at 5000 entries.
- **Drift risk:** zero by construction — threads are source of truth, view is derived.
- **Earning its keep:** *removes* `history/decisions.md`; net reduction in persistent state.

### Option C — Hybrid (on-demand default + opt-in cache)
Default = B. `/storytime-consolidate --rebuild-index` can materialize a derived `.storytime/decisions.md` with `stale_at` metadata. Cache is explicitly derived.
- **Write cost:** zero default; same as B on rebuild.
- **Read cost:** cache hit = A speed; miss = B speed.
- **Drift risk:** staleness is a feature; `/storytime-lint` can warn.
- **Earning its keep:** costs one concept (derived cached artifact) + one lint rule; pays off only if query latency becomes a real bottleneck.

### Option D — None needed (drift's strongest position)
Callouts handle U6/U7 already. U1–U5 rare enough that `grep -rn '^### V1-' specs/.storytime/sessions/` covers them. Delete both `history/decisions.md` AND `scripts/export-decisions.sh`. Net negative surface area.
- **Drift concedes:** U5 (structured external export) benefits from a parse; raw grep isn't machine-consumable. And a new contributor hits a learning-curve cliff.

## Use-case satisfaction

| Use case | A | B | C | D |
|---|---|---|---|---|
| U1 active list | direct | script | cache/script | manual grep |
| U2 recent N days | direct | script | cache/script | manual grep + date parse |
| U3 tag filter | direct (if indexed) | script | cache/script | manual grep |
| U4 supersession graph | direct | script traversal | cache/script | hard manually |
| U5 external export | direct | script | script | ad-hoc script |
| U6, U7 | irrelevant — thread+callouts handle | | | |

All four *can* satisfy U1–U5. Differences are speed, staleness risk, surface area — not capability.

## Drift's sustained challenge

1. **"Is any of U1–U5 load-bearing?"** — No, none blocks a session. U5 is the only one with a current concrete consumer (`export-decisions.sh`).
2. **"Write-on-every-commit = new failure mode."** — True. The post-commit hook already writes thread updates and optional dreams; Option A adds another partial-failure surface under constraint #4 (atomic writes).
3. **"On-demand is a script you run twice a year."** — True. Amortized, zero-write beats always-write.
4. **"Is Option C's cache worth its concept cost?"** — Only at scales storytime doesn't yet have.

Arbor's reshape: the decisions graph IS the thread-plus-callouts graph. A global "index" is really a **view**, and views don't need persistent state. This collapses the question.

## Recommendation

**Option B — on-demand synthesis, with a companion script.**

Concretely:
1. **Delete** `specs/.storytime/history/decisions.md` during V1-003 migration; decompose content into per-thread decision blocks with callouts where cross-topic references existed.
2. **Retire or rewrite** `scripts/export-decisions.sh` as a thin wrapper over the new view script (preserve its CSV shape at `:23-32` for downstream consumers).
3. **Add** `scripts/decisions-view.sh` — traverses `specs/.storytime/sessions/*/_thread.md`, parses `### V1-NNN — Title` blocks per V1-008 unified format, supports `--filter=status:active`, `--since=<date>`, `--tag=<tag>`, `--format=text|csv|graph`.
4. **Do not** add a post-commit index-write step. Hook's only decision action stays "append to owning thread."
5. **Leave room for Option C** as a future refinement if dogfooding shows query latency hurts a real workflow — it's a 1-day step from B.

**Why not A:** new always-on write surface for rare read-time value. Violates earning-its-keep against constraint #4.
**Why not C as MVP:** optimizes a workload storytime doesn't have yet. Violates earning-its-keep (constraint #3).
**Why not D:** U5 has a real consumer; U1–U4 discoverability matters for onboarding (drift conceded this).

## Confidence

**Medium-high.** Consistent with V1-003 and V1-011. Drift's challenge survived and reshaped framing — we're *removing* `history/decisions.md`, not adding infrastructure. Remaining uncertainty: whether query latency stays acceptable at dogfooding scale. Mitigated by the explicit door to Option C.

## Effort estimate

- **Complexity: 3** — a few hours of focused work. Parse is a straightforward regex over `### V1-NNN —`, with three output formats (text, csv, graph). Migration of `history/decisions.md` content to per-thread blocks is mechanical and happens under V1-003's migration anyway, not new cost here. `export-decisions.sh` rewrite ≈ 20 lines. No new hooks, no new persistent files.
- **Scale: 2 (files)** — new `scripts/decisions-view.sh`, shim or delete `scripts/export-decisions.sh`, delete `specs/.storytime/history/decisions.md` (under V1-003), update references in main SKILL and possibly `/storytime-status`. Single-repo, single-process, no external systems.

## Citations

- `docs/proposals/v1-consolidation.md:209-229` — V1-003 thread-as-decision-log shape
- `docs/proposals/v1-consolidation.md:471-476` — V1-011 callouts contract
- `docs/proposals/v1-consolidation.md:496-498` — the open question this breakout closes
- `scripts/export-decisions.sh:11` — current canonical path for global aggregation
- `scripts/export-decisions.sh:23-32` — current CSV shape the shim must preserve
- `skills/storytime/SKILL.md:244-245` — `history/` as DONE-phase log destination
- `specs/.storytime/sessions/v1-consolidation/001/icebreaker.md:108-109` — earning-its-keep constraint
- `specs/.storytime/sessions/v1-consolidation/001/icebreaker.md:110-111` — atomic-artifact-write constraint

## Open questions for CONVERGE

- **Surfacing path:** standalone `scripts/decisions-view.sh` or subcommand of `/storytime-status`? Decide based on whether other cross-topic view queries (open questions, stale citations) cluster into the same skill.
- **Graph output format:** ASCII box-drawing per process rule #7 (internal view), with optional `--format=dot` for external tooling — confirm.
- **Legacy migration:** some entries in `history/decisions.md` predate per-topic threads. Does V1-003's migration script attach orphan decisions to a `_legacy/_thread.md`, or attribute by inspection? **Defer to breakout 6 (migration path).**
- **Downstream path pin:** grep external consumers at CONVERGE time to see if `scripts/export-decisions.sh` path must stay or can be renamed.

## Participants

- **@domain [arbor]** (driver) — framed use-case analysis, separated in-topic (U6–U7) from cross-topic (U1–U5), argued the decisions graph IS the thread-plus-callouts graph so "global index" is really a view.
- **@skeptic [drift]** (supporter) — pressed "do we need this?" throughout, cut U6/U7 from the cross-topic set, forced earning-its-keep framing, and conceded U5 (external export) is the durable consumer that keeps a script alive.
