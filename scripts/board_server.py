#!/usr/bin/env python3
"""board server — serve, watch, fold, push (BOARD-017; FIX-003 ambient half).

The liveness loop behind board.html: watches everything the fold reads
(`fold.inputs_snapshot` — single source of truth, so watcher and fold
can never disagree), re-folds on change (including HEAD moves, so
commits refresh the board before FIX-003's git hooks exist), and pushes
SSE events so open boards re-render inline. Fold failures land in the
alarm lane as guardrail `fold/self` (FIX-003: never stderr oblivion)
while the last good state.json stays untouched (atomic emit, V1-018).

Liveness is an enhancement layer (BOARD-010 loose coupling): board.html
still works from file:// (static + drag-drop) and under any plain
static server (silent polling fallback in the client).

Usage:
    python3 scripts/board_server.py [--repo .] [--port 8000] [--interval 1.5]

Binds 127.0.0.1 only — the live state may fold user-local directives
(BOARD-016); a personal instrument does not LAN-expose by default.
"""

import argparse
import datetime
import json
import os
import queue
import sys
import threading
import time
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fold  # noqa: E402  — sibling module; the fold owns parsing and inputs

# Tool UI ships with the tool (BOARD-018): when the target repo has no
# board/board.html of its own, serve the plugin's copy. state.json is
# always the target repo's fold — never the plugin's.
PLUGIN_BOARD = os.path.normpath(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "board"))


# BOARD-010's command set. A click queues intent (BOARD-021); the agent
# actions it with full authority — the server never edits the record.
COMMANDS = {"seal", "add-option", "accept-candidate", "edit-item",
            "add-directive", "park", "request-review"}


def enqueue_command(root, command, item=None, args=None):
    """Append a pending command to specs/.storytime/commands.jsonl.
    Append-only, fsync'd; local-only (gitignored, BOARD-016)."""
    path = os.path.join(root, "specs", ".storytime", "commands.jsonl")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    n = 0
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            n = sum(1 for ln in f if ln.strip())
    entry = {"id": f"CMD-{n + 1:03d}", "command": command, "item": item,
             "args": args, "origin": "@user", "status": "pending",
             "at": datetime.datetime.now().isoformat(timespec="seconds")}
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, sort_keys=True) + "\n")
        f.flush()
        os.fsync(f.fileno())
    return entry


class Bus:
    """Fan-out of watcher events to connected SSE clients."""

    def __init__(self):
        self._lock = threading.Lock()
        self._subs = []
        self.last_error = None  # replayed to clients that connect after a failure

    def subscribe(self):
        q = queue.Queue()
        with self._lock:
            self._subs.append(q)
        return q

    def unsubscribe(self, q):
        with self._lock:
            if q in self._subs:
                self._subs.remove(q)

    def publish(self, event):
        with self._lock:
            subs = list(self._subs)
        for q in subs:
            q.put(event)


class Watcher(threading.Thread):
    """Poll fold inputs; re-fold on change; publish state / fold-error."""

    def __init__(self, root, out_path, bus, interval):
        super().__init__(daemon=True)
        self.root, self.out_path = root, out_path
        self.bus, self.interval = bus, interval
        self._last = None

    def fold_once(self):
        try:
            state, _skipped = fold.fold_repo(self.root)
            fold.emit(state, self.out_path)
            self.bus.last_error = None
            self.bus.publish({"type": "state"})
            print(f"board: folded — {len(state['items'])} items, "
                  f"from {state['generated_from']}", flush=True)
        except fold.FoldError as e:
            path = str(e.path)
            if os.path.isabs(path):
                path = os.path.relpath(path, self.root)
            err = {"type": "fold-error", "message": e.msg,
                   "file": path, "line": e.line_no}
            self.bus.last_error = err
            self.bus.publish(err)
            print(f"board: FOLD FAILED — {e} (last good state.json kept)",
                  file=sys.stderr)

    def run(self):
        while True:
            snap = fold.inputs_snapshot(self.root)
            if snap != self._last:
                self._last = snap
                self.fold_once()
            time.sleep(self.interval)


def make_handler(board_dir, bus, repo_root):
    class Handler(SimpleHTTPRequestHandler):
        def __init__(self, *a, **kw):
            super().__init__(*a, directory=board_dir, **kw)

        def log_message(self, fmt, *args):
            pass  # guardrail-grade: silent while working

        def translate_path(self, path):
            p = super().translate_path(path)
            if not os.path.exists(p):
                name = os.path.basename(p)
                if name in ("board.html", "fixture-state.json"):
                    alt = os.path.join(PLUGIN_BOARD, name)
                    if os.path.exists(alt):
                        return alt
            return p

        def do_GET(self):
            if self.path in ("/", "/index.html"):
                self.send_response(302)
                self.send_header("Location", "/board.html")
                self.end_headers()
                return
            if self.path == "/events":
                return self.sse()
            return super().do_GET()

        def do_POST(self):
            if self.path != "/command":
                self.send_error(404)
                return
            try:
                n = int(self.headers.get("Content-Length", 0))
                cmd = json.loads(self.rfile.read(n) or b"{}")
            except (ValueError, json.JSONDecodeError):
                return self._json(400, {"ok": False, "error": "bad json"})
            name = str(cmd.get("command", ""))
            if name not in COMMANDS:
                return self._json(400, {"ok": False,
                                        "error": f"unknown command {name!r}"})
            entry = enqueue_command(repo_root, name, cmd.get("item"),
                                    cmd.get("args"))
            print(f"board: queued {entry['id']} — {name}"
                  f"{' on ' + str(cmd.get('item')) if cmd.get('item') else ''}",
                  flush=True)
            self._json(200, {"ok": True, "id": entry["id"]})
            # the watcher sees commands.jsonl change and refolds+pushes

        def _json(self, code, obj):
            body = json.dumps(obj).encode()
            self.send_response(code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def sse(self):
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            q = bus.subscribe()
            try:
                if bus.last_error:
                    self._send_event(bus.last_error)
                while True:
                    try:
                        ev = q.get(timeout=15)
                    except queue.Empty:
                        self.wfile.write(b": ping\n\n")
                        self.wfile.flush()
                        continue
                    self._send_event(ev)
            except (BrokenPipeError, ConnectionResetError, OSError):
                pass
            finally:
                bus.unsubscribe(q)

        def _send_event(self, ev):
            data = json.dumps(ev, sort_keys=True)
            self.wfile.write(f"event: {ev['type']}\ndata: {data}\n\n".encode())
            self.wfile.flush()

    return Handler


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="serve board.html live: watch inputs, re-fold, push SSE")
    ap.add_argument("--repo", default=".", help="repo root (default: cwd)")
    ap.add_argument("--port", type=int, default=8000)
    ap.add_argument("--interval", type=float, default=1.5,
                    help="input scan interval in seconds")
    args = ap.parse_args(argv)

    root = os.path.abspath(args.repo)
    board_dir = os.path.join(root, "board")
    os.makedirs(board_dir, exist_ok=True)
    out_path = os.path.join(board_dir, "state.json")

    code, verdict, lines = fold.check_repo(root)
    print(f"board: readiness — {verdict}", flush=True)
    if code:
        for ln in lines:
            print(f"board:   {ln}", flush=True)

    bus = Bus()
    Watcher(root, out_path, bus, args.interval).start()

    srv = ThreadingHTTPServer(("127.0.0.1", args.port),
                              make_handler(board_dir, bus, root))
    print(f"board: live at http://localhost:{args.port}/board.html "
          f"(watching fold inputs every {args.interval}s; Ctrl-C stops)",
          flush=True)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        print("\nboard: stopped")
    return 0


if __name__ == "__main__":
    sys.exit(main())
