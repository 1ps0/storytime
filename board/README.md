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

Contract: `docs/board-state-schema.md` (schema 0.1.0). Producer:
`scripts/fold.py` — the only thing in the repo that computes "current"
(FIX-004, BOARD-015). Grammar: BOARD-002; one legend line must always
suffice.
