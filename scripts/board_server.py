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
import json
import os
import queue
import sys
import threading
import time
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fold  # noqa: E402  — sibling module; the fold owns parsing and inputs


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


def make_handler(board_dir, bus):
    class Handler(SimpleHTTPRequestHandler):
        def __init__(self, *a, **kw):
            super().__init__(*a, directory=board_dir, **kw)

        def log_message(self, fmt, *args):
            pass  # guardrail-grade: silent while working

        def do_GET(self):
            if self.path in ("/", "/index.html"):
                self.send_response(302)
                self.send_header("Location", "/board.html")
                self.end_headers()
                return
            if self.path == "/events":
                return self.sse()
            return super().do_GET()

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

    bus = Bus()
    Watcher(root, out_path, bus, args.interval).start()

    srv = ThreadingHTTPServer(("127.0.0.1", args.port),
                              make_handler(board_dir, bus))
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
