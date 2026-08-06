# board — storytime's control surface client (v0, live)

Run it as an application (BOARD-017):

```
python3 scripts/board_server.py        # → http://localhost:8000/board.html
```

The server watches everything the fold reads (threads, roster, local
user state, git HEAD — `fold.inputs_snapshot` is the single source of
truth), re-folds on any change, and pushes SSE so open boards re-render
inline. Header shows a green `live` dot. Fold failures appear in the
alarm lane as `fold/self` with file:line (FIX-003) while the last good
state stays rendered. Binds 127.0.0.1 only (state may fold user-local
directives, BOARD-016).

Degraded modes (BOARD-010 loose coupling — all still work):

- **Any static server** (`python3 -m http.server -d board`): client
  falls back to silent 5s polling (`poll` dot); nothing re-folds
  automatically — run `python3 scripts/fold.py` yourself.
- **file:// double-click**: embedded fixture renders; drag-and-drop any
  state.json onto the page.

Files:

- `board.html` — self-contained client, zero external requests.
- `state.json` — live fold output, local-only and gitignored
  (BOARD-016). Regenerate manually: `python3 scripts/fold.py`.
- `fixture-state.json` — committed demo fiction ("transport v2
  cutover"), provenance-labeled; clients must banner it as fixture.

## Any project (BOARD-018)

The board ships with the tool, not with the project. Against any repo
with a bootstrapped `specs/.storytime/`:

```
python3 scripts/bootstrap_repo.py --repo /path/to/project # bare → floor (idempotent)
python3 scripts/fold.py --check --repo /path/to/project   # readiness gate
python3 scripts/board_server.py --repo /path/to/project
python3 scripts/fold.py --repo /path/to/project           # one-shot fold
```

A storytime-naive repo goes to `ready (empty)` in one command
(BOARD-020: structure is mechanical, state is interpretive — seed it
with `/storytime-absorb` over the repo's existing docs).

`--check` (BOARD-019) proves readiness instead of assuming it:
structure, ignore coverage, user-state resolution, fold validity —
verdict `ready` / `ready (empty)` / `not-bootstrapped` / `malformed`,
with the fix named next to every gap. The server prints the same
verdict at startup.

`board.html` and the fixture serve from this plugin's `board/` when
the target repo has none of its own; `state.json` always folds from
the target repo. User state resolves repo-first
(`specs/.storytime/cohort/_user.md`), then machine-level
(`~/.storytime/user.md`) — put your operator model there and your
rail directives follow you across every project, committed nowhere.
Bootstrap writes the ignore block into new repos.

Contract: `docs/board-state-schema.md` (schema 0.1.0). Producer:
`scripts/fold.py` — the only thing in the repo that computes "current"
(FIX-004, BOARD-015). Grammar: BOARD-002; one legend line must always
suffice.
