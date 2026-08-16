---
type: remembrance
schema_version: 1
created: 2026-08-16T01:55
updated: 2026-08-16T01:55
compact_staged: true
last_commit: 2c1f746
active_threads:
  - topic: board
    path: specs/.storytime/sessions/board/_thread.md
    active_phase: BUILDOUT
    driver: "@user"
active_personas:
  - "@user"
---

# Remembrance — board extraction workday

## Wakeup

This workday executed BOARD-026's extraction: **foldboard** now stands
alone at `/Users/alexevers/workspace/projects/foldboard` — four prose
spec docs (schema/security/transport/versioning), the JSON Schema and
transport-demo fixture carried verbatim, the reference client (header
provenance comment is its only change), a reducer-agnostic transport
server (the fold import became a `--reducer` shell contract), and
foldboard's own sealed laws FB-001..FB-005 restating the inherited
board lineage under its own authority. The open items were then
closed: the behavioral conformance suite landed executable (black-box
reducer harness, cross-document linter, canonical checker, client
obligations checklist, plus a toy reducer whose cheat modes prove the
suite fails law-breakers), and the first frozen release was cut —
`releases/0.5/` with sha256 pins, tag `foldboard/0.5`. Everything
verified green: `conformance/run_all.py` exit 0, the server exercised
end-to-end over SSE (state push, fold-error parse/replay/dedup,
error-to-recovery), Host/Origin guards 403-proven, `node --check`
clean. Work has already moved past that point: foldboard tip `210e1da`
opens a **0.6 draft** (Topic.retired_ids referential closure,
corrected fixture, client/schema sync; the linter liveness check now
pins the frozen 0.5 fixture), leaving the tag one commit behind.
storytime itself was read-only all session per the extraction brief;
publishing foldboard to github.com/1ps0 is reserved to @user.

## Consolidation prompt

You are continuing after the foldboard extraction (BOARD-026,
realized externally). To re-engage:

1. Read `/Users/alexevers/workspace/projects/foldboard/decisions/_thread.md`
   — Episode 000 (extraction), Episode 001 (suite + 0.5 freeze),
   decisions FB-001..FB-005.
2. Run `git -C /Users/alexevers/workspace/projects/foldboard log --oneline`
   and read `/Users/alexevers/workspace/projects/foldboard/CHANGELOG.md`
   — note HEAD `210e1da` is a 0.6 draft, one commit past tag
   `foldboard/0.5` (`312548f`).
3. Read `/Users/alexevers/workspace/projects/foldboard/conformance/README.md`
   (suite map + Known limits), then run
   `python3 conformance/run_all.py` there to re-prove green before
   extending anything.
4. For lineage: `specs/.storytime/sessions/board/_thread.md`
   (BOARD-001..027 and the Next action ladder) and
   `docs/proposals/projectstate-spec-breakdown.md` (Annex E — the
   seams the extraction followed).
5. Confirm orientation with @user before proceeding: "foldboard
   extracted and 0.5 frozen; 0.6 draft open at 210e1da — continue on
   storytime-side wiring (plugin copy decision, cross-CI tether,
   BOARD-026 realization entry) or on the 0.6 draft?"

## Do NOT

- Re-run the extraction or re-create the foldboard repo — it exists
  (9 local commits, tag `foldboard/0.5`, clean tree).
- Edit anything under `foldboard/releases/0.5/` — frozen and
  sha256-pinned (RELEASE.md self-verifies).
- Create a GitHub remote or push foldboard — @user handles publishing
  explicitly.
- Assume `fixtures/valid/transport-demo.json` still trips the
  waiting_user lint — the 0.6 draft corrected the fixture; the
  liveness check moved to the frozen 0.5 copy.
- Treat this file as authoritative — it is a prompt to load, not a
  replacement for the source artifacts above.

## State pinned

- foldboard repo: `/Users/alexevers/workspace/projects/foldboard`,
  branch main @ `210e1da` (9 commits, clean, local-only, no remote);
  tag `foldboard/0.5` -> `312548f`; tip is the 0.6 draft
  (Topic.retired_ids closure, corrected fixture, client sync).
- Verified green at 312548f: run_all exit 0 — schema half 1 PASS + 3
  expected-FAIL; reducer suite 14/14 vs toy reducer; cheat modes
  nondet/noncanon/tear/quiet-accept all caught. Transport server:
  serve-only + reducer modes, SSE `state`/`fold-error` (parse, late
  replay, dedup, recovery push), Host/Origin 403s, fsync'd /command
  queue.
- Extraction seams cut (server): `import fold` -> `--reducer` shell
  contract (exit 2 + "file:line: message"); packaged-UI fallback ->
  `--ui`; queue path + allow-list -> `--queue`/`--commands`;
  storytime invocation strings -> spec/schema.md §8 producer profile.
- In-flight work:
  - publish foldboard to github.com/1ps0 + push tag (@user, explicit)
  - storytime plugin: vendored vs pinned board copy (undecided)
  - cross-CI tether: storytime CI runs
    `python3 conformance/reducer_suite.py --repo . --reducer "python3 scripts/fold.py"`;
    foldboard CI runs `run_all.py`
  - BOARD-026 realization entry not yet recorded on the board thread
  - rendered-DOM client walkthrough (known limit, conformance README)
  - 0.6 draft open at foldboard tip
- Open questions: the four on the board thread frontmatter (heartbeat
  granularity; FIX-005 item ownership; FIX-002 callout target; OP-009
  root-context persistence) — none touched this session.
- Personas at the table: none convened — direct @user-driven
  execution session.
- Last pause: 2026-08-16T01:55, trigger=explicit /storytime-remember,
  tier=compact.
