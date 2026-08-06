#!/usr/bin/env python3
"""bootstrap_repo — the mechanical board-ready floor (BOARD-020).

Takes any repo, storytime-naive or partial, to structural readiness
non-interactively and idempotently: directories, config.md (only if
absent), the ignore block (only if missing). Never overwrites, never
deletes — safe to run on any repo in any state, repeatedly.

The guided ceremony — mode judgment against existing conventions,
cohort setup, reporting — stays with /storytime-bootstrap, which calls
this module for the file ops so skill and script cannot drift.

State is NOT fabricated (BOARD-019): a fresh repo folds to
`ready (empty)`; state arrives through /storytime-absorb or a session.

Usage:
    python3 scripts/bootstrap_repo.py [--repo .] [--mode native|adapt|export]

Chain to proof:
    python3 scripts/bootstrap_repo.py --repo X && python3 scripts/fold.py --check --repo X
"""

import argparse
import datetime
import os
import sys

DIRS = {
    "native": ["sessions", "cohort", "specialists", "archive/current",
               "archive/rollups", "archive/cold", "history/sessions"],
    "adapt": ["sessions", "archive"],
    "export": [],
}

# Idempotence keys on the rule itself, not comment wording — existing
# repos may carry the same rules under different comments.
IGNORE_SENTINEL = "specs/.storytime/cohort/_user.md"
IGNORE_BLOCK = """
# storytime: user-local state (BOARD-016) + derived board state (FIX-004)
specs/.storytime/cohort/_user.md
specs/.storytime/cohort/operator-model-*.md
specs/.storytime/intents.md
specs/.storytime/commands.jsonl
board/state.json
"""

CONFIG_NATIVE = """---
type: config
created: {today}
schema_version: 1
---

# core
mode: native
default_mode: inline
automation: guided
team_size: project-appropriate    # bias small; sized to the work
max_team_size: 12                 # hard ceiling, override required
default_core: [owner, operator, critic]
naming: codename                  # non-human by default
driving_persona: required         # one driver per leg
require_nongoals: true
visual_style: ascii
citation_format: "file:line — snippet"

# v1.0 consolidation
pause_mode: model-introspection
dreams_enabled: false             # V1-004 off by default
post_commit_hook: disabled        # V1-028 opt-in
remembrance_load_on_compact: true # V1-029 post-/compact first action
"""

CONFIG_MINIMAL = """---
type: config
created: {today}
schema_version: 1
---

# core
mode: {mode}
"""


def ensure_structure(root, mode="native"):
    """Create the board-ready floor. Returns [(action, relpath)] where
    action is 'created' or 'kept'. Idempotent; never overwrites."""
    if mode not in DIRS:
        raise ValueError(f"unknown mode {mode!r} (native|adapt|export)")
    actions = []
    st_root = os.path.join(root, "specs", ".storytime")

    def ensure_dir(rel):
        p = os.path.join(st_root, rel) if rel else st_root
        made = not os.path.isdir(p)
        os.makedirs(p, exist_ok=True)
        actions.append(("created" if made else "kept",
                        os.path.relpath(p, root)))

    ensure_dir("")
    for rel in DIRS[mode]:
        ensure_dir(rel)

    cfg = os.path.join(st_root, "config.md")
    if os.path.exists(cfg):
        actions.append(("kept", os.path.relpath(cfg, root)))
    else:
        today = datetime.date.today().isoformat()
        tpl = CONFIG_NATIVE if mode == "native" else CONFIG_MINIMAL
        with open(cfg, "w", encoding="utf-8") as f:
            f.write(tpl.format(today=today, mode=mode))
        actions.append(("created", os.path.relpath(cfg, root)))

    gi = os.path.join(root, ".gitignore")
    existing = ""
    if os.path.exists(gi):
        with open(gi, encoding="utf-8") as f:
            existing = f.read()
    if IGNORE_SENTINEL in existing:
        actions.append(("kept", ".gitignore (ignore block)"))
    else:
        with open(gi, "a", encoding="utf-8") as f:
            if existing and not existing.endswith("\n"):
                f.write("\n")
            f.write(IGNORE_BLOCK)
        actions.append(("created", ".gitignore (ignore block appended)"))

    return actions


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="mechanical board-ready floor: dirs, config, ignore block")
    ap.add_argument("--repo", default=".", help="repo root (default: cwd)")
    ap.add_argument("--mode", default="native",
                    choices=["native", "adapt", "export"])
    args = ap.parse_args(argv)

    root = os.path.abspath(args.repo)
    try:
        actions = ensure_structure(root, args.mode)
    except (OSError, ValueError) as e:
        print(f"bootstrap: {e}", file=sys.stderr)
        return 2

    for action, rel in actions:
        print(f"bootstrap: {action}  {rel}")
    made = sum(1 for a, _ in actions if a == "created")
    print(f"bootstrap: floor ready ({made} created, "
          f"{len(actions) - made} kept) — prove it: "
          f"python3 scripts/fold.py --check --repo {args.repo}")
    print("bootstrap: state arrives via /storytime-absorb or a session "
          "— nothing is fabricated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
