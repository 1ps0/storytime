# board — storytime's control surface client (v0)

- `board.html` — self-contained client (no external requests). Open the
  file directly and it renders the embedded fixture; serve the directory
  to see live state instead:
  `python3 -m http.server -d board 8000` → http://localhost:8000/board.html
  (drag-and-drop any state.json onto the page also works, anywhere.)
- `state.json` — live fold output, local-only and gitignored (it may
  fold user-local directives, BOARD-016). Regenerate any time:
  `python3 scripts/fold.py`
- `fixture-state.json` — committed demo fiction ("transport v2
  cutover"), provenance-labeled; clients must banner it as fixture.

Contract: `docs/board-state-schema.md` (schema 0.1.0). Producer:
`scripts/fold.py` — the only thing in the repo that computes "current"
(FIX-004, BOARD-015). Grammar: BOARD-002; one legend line must always
suffice.
