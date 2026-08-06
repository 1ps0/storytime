#!/usr/bin/env python3
"""fold — the reduction that owns "current" (FIX-004, BOARD-010, BOARD-015).

Parses append-only storytime state (per-topic `_thread.md` files, the
cohort roster, user-local operator state) and emits one derived
`state.json` per docs/board-state-schema.md. The only component in the
repo that computes current state; everything else reads its output.

Properties (sealed):
  deterministic  — no wall clock; same inputs → byte-identical output
  fail-loud      — malformed input exits nonzero with file:line;
                   never emits partial state (FIX-001)
  atomic         — tmp + fsync + os.replace on every write (V1-018)
  global         — one state.json across all topics (FIX-002)
  supersedes     — resolved here and nowhere else (FIX-004): a
                   `Supersedes:` on any decision retires its target
                   repo-wide, even across topics

v0 scope (BOARD-013, decisions-first): items are decisions from
threads; questions/dreams/candidates enter as identity (FIX-000)
lands per kind. Module surface: parse_thread / fold_repo / emit —
CLI stays a thin wrapper.
"""

import argparse
import json
import os
import re
import subprocess
import sys

SCHEMA_VERSION = "0.2.0"  # 0.2: + commands[] (BOARD-021 queue; additive)

DECISION_RE = re.compile(r"^### ([A-Z][A-Za-z0-9.]*-[A-Za-z0-9]+) — (.+)$")
FIELD_RE = re.compile(r"^  ([A-Za-z][A-Za-z_-]*): ?(.*)$")
CALLOUT_RE = re.compile(r"^  Callout-> (.+)$")
CONT_RE = re.compile(r"^    (\S.*)$")

DEPTH_BY_LIFECYCLE = {
    "proposed": "surface",
    "focused": "forming",
    "sealed": "bedrock",
    "realized": "bedrock",
}
GONE_LIFECYCLES = {"retired", "superseded"}


class FoldError(Exception):
    """Malformed input. Carries file and line; fold exits 2, writes nothing."""

    def __init__(self, path, line_no, msg):
        super().__init__(f"{path}:{line_no}: {msg}")
        self.path, self.line_no, self.msg = path, line_no, msg


# ---------------------------------------------------------------- parsing

def parse_frontmatter(lines, path):
    """Minimal YAML subset: top-level scalars, one list level, one nest level."""
    if not lines or lines[0].strip() != "---":
        raise FoldError(path, 1, "missing frontmatter open '---'")
    fm, key = {}, None
    for i, line in enumerate(lines[1:], start=2):
        if line.strip() == "---":
            if "topic" not in fm:
                raise FoldError(path, i, "frontmatter missing required key 'topic'")
            return fm, i
        if re.match(r"^\s*#", line) or not line.strip():
            continue
        m = re.match(r"^(\w[\w_]*):\s*(.*)$", line)
        if m:
            key = m.group(1)
            val = m.group(2).strip()
            fm[key] = _scalar(val) if val else []
            continue
        m = re.match(r"^\s+- (.+)$", line)
        if m and key is not None and isinstance(fm.get(key), list):
            fm[key].append(m.group(1).strip().strip('"'))
            continue
        if re.match(r"^\s+\w[\w_]*:", line):  # nested block (last_consolidation) — skipped
            continue
        raise FoldError(path, i, f"unparseable frontmatter line: {line.strip()!r}")
    raise FoldError(path, len(lines), "frontmatter never closed")


def _scalar(val):
    if val in ("null", "~"):
        return None
    if val in ("true", "false"):
        return val == "true"
    return val


def _strip_comment(val):
    return val.split("#", 1)[0].strip()


def parse_tensions(val, path, line_no):
    val = _strip_comment(val)
    m = re.match(r"^\[(.*)\]$", val)
    if not m:
        raise FoldError(path, line_no, f"Tensions must be a [list]: {val!r}")
    inner = m.group(1).strip()
    return [t.strip() for t in inner.split(",") if t.strip()] if inner else []


def parse_decisions(lines, path, fm_end):
    """Decision/proposal blocks: '### ID — title' + indented fields + body."""
    blocks, cur, last_field = [], None, None
    for i, line in enumerate(lines[fm_end:], start=fm_end + 1):
        if line.startswith("## "):
            cur, last_field = None, None
            continue
        m = DECISION_RE.match(line)
        if m:
            cur = {"id": m.group(1), "title": m.group(2).strip(), "line": i,
                   "fields": {}, "callouts": [], "body": []}
            blocks.append(cur)
            last_field = None
            continue
        if cur is None:
            continue
        m = CALLOUT_RE.match(line)
        if m:
            raw = m.group(1).strip()
            km = re.match(r"^(\S+)\s+\((\w[\w-]*)\)(.*)$", raw)
            if km:
                cur["callouts"].append({"target": km.group(1), "kind": km.group(2)})
            else:
                cur["callouts"].append({"target": raw, "kind": None})
            last_field = "Callout"
            continue
        m = FIELD_RE.match(line)
        if m:
            last_field = m.group(1)
            cur["fields"][last_field] = m.group(2).strip()
            cur["fields"].setdefault("_line_" + last_field, i)
            continue
        m = CONT_RE.match(line)
        if m and last_field and last_field != "Callout":
            cur["fields"][last_field] += " " + m.group(1).strip()
            continue
        if line.strip():
            cur["body"].append(line.rstrip())
            last_field = None
        elif cur["body"]:
            cur["body"].append("")
    return blocks


def parse_thread(path):
    with open(path, encoding="utf-8") as f:
        lines = f.read().splitlines()
    fm, fm_end = parse_frontmatter(lines, path)
    open_qs = fm.get("open_questions") or []
    topic = {
        "id": str(fm["topic"]),
        "title": str(fm["topic"]),
        "phase": str(fm.get("last_completed_phase") or "UNKNOWN"),
        "last_commit": str(fm.get("last_commit") or ""),
        "open_questions": len(open_qs) if isinstance(open_qs, list) else 0,
        "retired": 0,
    }
    return topic, parse_decisions(lines, path, fm_end), path


def parse_roster(path):
    """Active Roster table → teammates."""
    teammates = []
    with open(path, encoding="utf-8") as f:
        lines = f.read().splitlines()
    in_active = False
    for i, line in enumerate(lines, start=1):
        if line.startswith("## "):
            in_active = line.strip() == "## Active Roster"
            continue
        if in_active and line.startswith("|") and "---" not in line:
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if not cells or cells[0].lower() in ("codename", ""):
                continue
            if len(cells) < 7:
                raise FoldError(path, i, f"roster row has {len(cells)} cells, expected 7")
            teammates.append({
                "codename": cells[0], "role": cells[2], "focus": "",
                "status": cells[3], "last_active": cells[6],
            })
    for t in teammates:  # focus lives in the resolution table; join by role
        t.pop("focus")
    return teammates


def parse_local_directives(path):
    """User-local rail directives (BOARD-016): 'D-N text (refs).' entries
    under '## Derived directives'. Multi-line continuation indented."""
    if not os.path.exists(path):
        return []
    directives, in_section, cur = [], False, None
    with open(path, encoding="utf-8") as f:
        for line in f.read().splitlines():
            if line.startswith("## "):
                in_section = line.startswith("## Derived directives")
                cur = None
                continue
            if not in_section:
                continue
            m = re.match(r"^(D-\d+) (.+)$", line)
            if m:
                cur = {"id": m.group(1), "text": m.group(2).strip()}
                directives.append(cur)
            elif cur and re.match(r"^\s{4}\S", line):
                cur["text"] += " " + line.strip()
    out = []
    for d in directives:
        text = re.sub(r"\s*\(OP-[^)]*\)\.?$", "", d["text"]).rstrip(".")
        out.append({"id": d["id"], "text": text, "origin": "@user",
                    "status": "alive", "fired": 0, "last_candidate": None,
                    "source": "local"})
    return out


def parse_commands(path):
    """Pending board commands (BOARD-021): @user intent queued by the
    board client, actioned by the agent with full authority — the
    board never edits the record itself. Malformed lines fail loud."""
    if not os.path.exists(path):
        return []
    out = []
    with open(path, encoding="utf-8") as f:
        for i, line in enumerate(f, start=1):
            if not line.strip():
                continue
            try:
                c = json.loads(line)
            except json.JSONDecodeError as e:
                raise FoldError(path, i, f"malformed command line: {e}")
            if c.get("status", "pending") == "pending":
                out.append({
                    "id": str(c.get("id", f"line{i}")),
                    "command": str(c.get("command", "")),
                    "item": c.get("item"),
                    "args": c.get("args"),
                    "origin": str(c.get("origin", "@user")),
                    "at": str(c.get("at", "")),
                })
    return sorted(out, key=lambda c: c["id"])


def user_state_path(root):
    """Where @user's local state lives: repo-first, then machine-level.

    The operator travels across projects (BOARD-018) without committing
    anywhere (BOARD-016). Returns the canonical repo path even when
    absent, so callers can treat it uniformly.
    """
    repo_user = os.path.join(root, "specs", ".storytime", "cohort", "_user.md")
    if os.path.exists(repo_user):
        return repo_user
    home_user = os.path.expanduser(os.path.join("~", ".storytime", "user.md"))
    if os.path.exists(home_user):
        return home_user
    return repo_user


# ---------------------------------------------------------------- folding

def _label(title):
    words = re.split(r"\s+", re.split(r" — |: ", title)[0].strip())
    return " ".join(words[:7]).lower()


def _origin(fields):
    drivers = fields.get("Drivers", "")
    first = drivers.split(",")[0].strip()
    return first or "@user"


def _summary(body):
    paras, cur = [], []
    for line in body:
        if line.strip():
            cur.append(line.strip())
        elif cur:
            paras.append(" ".join(cur))
            cur = []
    if cur:
        paras.append(" ".join(cur))
    return paras[0] if paras else ""


def fold_repo(root):
    st_root = os.path.join(root, "specs", ".storytime")
    sess_dir = os.path.join(st_root, "sessions")
    if not os.path.isdir(sess_dir):
        raise FoldError(sess_dir, 0,
                        "no specs/.storytime/sessions — repo not bootstrapped "
                        "(run /storytime-bootstrap)")

    topics, all_blocks, skipped = [], [], []
    for name in sorted(os.listdir(sess_dir)):
        tdir = os.path.join(sess_dir, name)
        tpath = os.path.join(tdir, "_thread.md")
        if not os.path.isdir(tdir):
            continue
        if not os.path.exists(tpath):
            skipped.append(name)
            continue
        topic, blocks, path = parse_thread(tpath)
        rel = os.path.relpath(path, root)
        for b in blocks:
            b["topic"], b["path"] = topic["id"], rel
        topics.append(topic)
        all_blocks.extend(blocks)

    # supersedes resolution — fold-owned, global (FIX-004, FIX-002)
    superseded = set()
    for b in all_blocks:
        target = b["fields"].get("Supersedes")
        if target:
            superseded.add(_strip_comment(target).split()[0])
        if b["fields"].get("Superseded-by"):
            superseded.add(b["id"])
        if (b["fields"].get("Status", "active").split()[0] == "superseded"
                or b["fields"].get("Lifecycle_state") in GONE_LIFECYCLES):
            superseded.add(b["id"])

    by_topic = {t["id"]: t for t in topics}
    items = []
    for b in all_blocks:
        if b["id"] in superseded:
            by_topic[b["topic"]]["retired"] += 1
            continue
        lifecycle = b["fields"].get("Lifecycle_state", "sealed")
        if lifecycle not in DEPTH_BY_LIFECYCLE:
            raise FoldError(b["path"], b["line"],
                            f"{b['id']}: unknown lifecycle_state {lifecycle!r}")
        tensions = []
        if "Tensions" in b["fields"]:
            tensions = parse_tensions(b["fields"]["Tensions"], b["path"],
                                      b["fields"].get("_line_Tensions", b["line"]))
        items.append({
            "id": b["id"],
            "topic": b["topic"],
            "kind": "decision",
            "label": _label(b["title"]),
            "depth": DEPTH_BY_LIFECYCLE[lifecycle],
            "state": "normal",
            "contested": bool(tensions),
            "is_candidate": False,
            "origin": _origin(b["fields"]),
            "owner": None,
            "lifecycle_state": lifecycle,
            "probe": {"status": "none", "pointer": None},
            "canonical": f"{b['path']}#{b['id']}",
            "summary": _summary(b["body"]),
            "options": [],
            "edges": {
                "parent": (b["fields"].get("Parent", "") or None) and
                          b["fields"]["Parent"].split()[0],
                "edge_type": b["fields"].get("Edge_type") or None,
                "tensions": sorted(tensions),
                "supersedes": (b["fields"].get("Supersedes", "") or None) and
                              _strip_comment(b["fields"]["Supersedes"]).split()[0],
                "callouts": b["callouts"],
            },
            "track": None,
        })

    roster_path = os.path.join(st_root, "cohort", "_roster.md")
    teammates = parse_roster(roster_path) if os.path.exists(roster_path) else []
    user_path = user_state_path(root)
    if os.path.exists(user_path):
        teammates.insert(0, {"codename": "user", "role": "user",
                             "status": "active", "last_active": ""})

    state = {
        "schema_version": SCHEMA_VERSION,
        "provenance": "fold",
        "generated_from": _head(root),
        "topics": sorted(topics, key=lambda t: t["id"]),
        "items": sorted(items, key=lambda x: (x["topic"], x["id"])),
        "directives": parse_local_directives(user_path),
        "commands": parse_commands(os.path.join(st_root, "commands.jsonl")),
        "guardrail_blocks": [],
        "candidates": [],
        "budget": {"open_questions": sum(t["open_questions"] for t in topics)},
        "lenses": [],
        "teammates": teammates,
    }
    return state, skipped


def _head(root):
    try:
        out = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=root,
                             capture_output=True, text=True, check=True)
        return out.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "nogit"


def inputs_snapshot(root):
    """Fingerprint of everything the fold reads, as {key: stamp}.

    The watcher (scripts/board_server.py) re-folds when this changes.
    Living here means the watcher and the fold can never disagree about
    what the inputs are. Includes HEAD so commits refresh the board
    even before FIX-003's git hooks exist.
    """
    st_root = os.path.join(root, "specs", ".storytime")
    snap = {}

    def stamp(p):
        try:
            snap[p] = os.stat(p).st_mtime_ns
        except OSError:
            pass

    sess = os.path.join(st_root, "sessions")
    stamp(sess)
    if os.path.isdir(sess):
        for name in sorted(os.listdir(sess)):
            stamp(os.path.join(sess, name, "_thread.md"))
    stamp(os.path.join(st_root, "cohort", "_roster.md"))
    stamp(os.path.join(st_root, "cohort", "_user.md"))
    stamp(os.path.expanduser(os.path.join("~", ".storytime", "user.md")))
    stamp(os.path.join(st_root, "commands.jsonl"))
    snap["git:HEAD"] = _head(root)
    return snap


# ---------------------------------------------------------------- readiness

def _ignore_coverage(root):
    try:  # --git-dir succeeds even on unborn HEAD (zero-commit repos)
        r = subprocess.run(["git", "-C", root, "rev-parse", "--git-dir"],
                           capture_output=True)
        if r.returncode != 0:
            return "n/a (not a git repo)"
    except FileNotFoundError:
        return "n/a (git unavailable)"
    misses = []
    for rel in ("board/state.json", "specs/.storytime/cohort/_user.md"):
        try:
            r = subprocess.run(["git", "-C", root, "check-ignore", "-q", rel],
                               capture_output=True)
        except FileNotFoundError:
            return "n/a (git unavailable)"
        if r.returncode != 0:
            misses.append(rel)
    if misses:
        return ("GAPS — not ignored: " + ", ".join(misses) +
                " (add bootstrap's ignore block)")
    return "covers user-local + derived state"


def check_repo(root):
    """Mechanical board-readiness gate (BOARD-019; V1-029 precedent).

    Returns (exit_code, verdict, lines). 0 = ready (possibly empty),
    1 = not bootstrapped, 2 = malformed state. Every gap names its fix.
    """
    lines = []
    st_root = os.path.join(root, "specs", ".storytime")
    sess = os.path.join(st_root, "sessions")
    if not os.path.isdir(sess):
        lines.append("structure: specs/.storytime/sessions/ missing")
        lines.append("fix: run /storytime-bootstrap (guided) or "
                     "`python3 scripts/bootstrap_repo.py --repo .` "
                     "(mechanical floor, BOARD-020)")
        return 1, "not-bootstrapped", lines

    cfg = os.path.join(st_root, "config.md")
    lines.append("config.md: " + ("present" if os.path.exists(cfg)
                 else "MISSING — run /storytime-bootstrap"))
    roster = os.path.join(st_root, "cohort", "_roster.md")
    lines.append("cohort/_roster.md: " + ("present" if os.path.exists(roster)
                 else "absent — teammates rail empty until a cohort exists"))
    upath = user_state_path(root)
    if os.path.exists(upath):
        machine = upath.startswith(os.path.expanduser(
            os.path.join("~", ".storytime")))
        lines.append("user state: " + ("machine (" + upath + ")" if machine
                     else "repo (" + os.path.relpath(upath, root) + ")"))
    else:
        lines.append("user state: none — directives rail empty "
                     "(optional: ~/.storytime/user.md)")
    lines.append("ignore rules: " + _ignore_coverage(root))

    try:
        state, skipped = fold_repo(root)
    except FoldError as e:
        lines.append(f"MALFORMED — {e}")
        lines.append("fix: correct that file:line (see /storytime-lint)")
        return 2, "malformed", lines

    for name in skipped:
        lines.append(f"note: sessions/{name} has no _thread.md — not folded")
    lines.append(f"state: {len(state['items'])} items · "
                 f"{len(state['topics'])} topics · "
                 f"{sum(t['retired'] for t in state['topics'])} retired · "
                 f"{len(state['directives'])} directives · "
                 f"schema {state['schema_version']} · "
                 f"from {state['generated_from']}")
    if not state["topics"]:
        lines.append("empty — structure is sound; state arrives with the "
                     "first session or /storytime-absorb")
        return 0, "ready (empty)", lines
    return 0, "ready", lines


# ---------------------------------------------------------------- emit

def emit(state, out_path):
    """Atomic write per V1-018: tmp + fsync + replace. Never a torn file."""
    payload = json.dumps(state, indent=2, sort_keys=True, ensure_ascii=False) + "\n"
    tmp = out_path + ".tmp"
    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(payload)
        f.flush()
        os.fsync(f.fileno())
    os.replace(tmp, out_path)


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="fold storytime state into board/state.json")
    ap.add_argument("--repo", default=".", help="repo root (default: cwd)")
    ap.add_argument("--out", default=None,
                    help="output path (default: <repo>/board/state.json)")
    ap.add_argument("--stdout", action="store_true", help="print instead of write")
    ap.add_argument("--check", action="store_true",
                    help="board-readiness report: structure, hygiene, state, "
                         "verdict; writes nothing (BOARD-019)")
    args = ap.parse_args(argv)

    root = os.path.abspath(args.repo)

    if args.check:
        code, verdict, lines = check_repo(root)
        for ln in lines:
            print(f"fold: {ln}")
        print(f"fold: verdict — {verdict}")
        return code

    try:
        state, skipped = fold_repo(root)
    except FoldError as e:
        print(f"fold: {e}", file=sys.stderr)
        return 2

    for name in skipped:
        print(f"fold: note: sessions/{name} has no _thread.md — not folded",
              file=sys.stderr)

    if args.stdout:
        sys.stdout.write(json.dumps(state, indent=2, sort_keys=True,
                                    ensure_ascii=False) + "\n")
        return 0

    out = args.out or os.path.join(root, "board", "state.json")
    emit(state, out)
    print(f"fold: wrote {out} ({len(state['items'])} items, "
          f"schema {state['schema_version']}, from {state['generated_from']})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
