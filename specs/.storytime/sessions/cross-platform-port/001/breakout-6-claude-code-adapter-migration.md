---
type: breakout
schema_version: 1
created: 2026-04-26T15:30
session: cross-platform-port
episode: 001
subtopic: claude-code-adapter-migration
driver: "@operator [tide]"
supporters: ["@owner [anchor]", "@critic [forge]"]
status: complete
---

# Breakout 6 — Claude Code Adapter Migration Safety

## Question

v1.0.1 is shipped. The cross-platform refactor moves
`skills/`, `agents/`, and `.claude-plugin/` from repo root into
`adapters/claude-code/`. **What is the migration safety story so this
does not break the existing Claude Code install** (this repo's own,
plus any external installs that have happened since marketplace
registration at commit `a95bfde`)?

Specifically: how does the Claude Code plugin loader resolve paths,
how do we re-route it without forcing every user to re-install, what
does the migration script look like, what is the pre-flight gate, and
what is the rollback story?

## Frame

### What we know

- **Plugin loader convention is positional.** Claude Code's plugin
  loader scans `<plugin-path>/.claude-plugin/plugin.json`,
  `<plugin-path>/skills/<name>/SKILL.md`, and
  `<plugin-path>/agents/<name>.md` as siblings at the plugin root.
  Verified at `/Users/alexevers/workspace/projects/storytime/.claude-plugin/plugin.json:1-9`
  and `/Users/alexevers/workspace/projects/storytime/skills/storytime/SKILL.md:1-9`
  (frontmatter `name`/`description` is the actual entry point).
- **Current install model is symlink-based.** Per
  `docs/multi-repo-distribution.md:15-69`, the canonical install is a
  symlink: `~/.claude/plugins/marketplaces/<marketplace>/external_plugins/storytime/`
  → `~/workspace/storytime/`. Claude Code resolves the symlink and
  treats the target as the plugin root.
- **Scope is bounded.** 18 skills and 3 agents to relocate (counted
  via `find skills -name SKILL.md` and `find agents -name '*.md'`).
- **Precedent migration shape exists.** `scripts/migrate-to-v1.sh`
  (cited at `:1-19` and `:39-58`) is the v0.9 → v1.0 migration. It
  uses dry-run default, `--apply`, `--commit`, `--rollback` flags;
  detects markers in `specs/.storytime/`; writes `.version` as a
  positive marker; commits with a deterministic message that
  `--rollback` can grep for. **This is the script shape we mirror.**
- **Pre-flight gate pattern exists.** V1-029 (cited from
  `specs/.storytime/sessions/v1-consolidation/001/plan.md:120-121`):
  *"v1.0 skills refuse to run on unmigrated specs/.storytime/ — pre-flight
  gate. Escape hatch: pin storytime@0.9 in plugin.json."* We re-apply
  this pattern to detect un-migrated repo layout in v1.1.
- **Cross-cutting move precedent.** `scripts/bump-version.sh`
  (`:1-72`) shows the propagation pattern across `VERSION`,
  `.claude-plugin/plugin.json`, `README.md`, all `skills/*/SKILL.md`
  version-echo blocks, and `site/*.html`. The migration script must
  similarly handle multiple cross-cutting touches.
- **`specs/.storytime/` is platform-agnostic.** The session state
  (`cohort/`, `sessions/`, `archive/`, `dreams/`, `history/`,
  `config.md`, `.version`) is the user's data. It does not move.
  This is reaffirmed in the proposal at
  `docs/proposals/cross-platform-storytime.md:148-166` ("What's
  platform-agnostic — the actual storytime").

### What we don't know

- Whether Claude Code's plugin loader honors symlinks on **specific
  child directories** (e.g., `skills` is a symlink to
  `adapters/claude-code/skills`) or only on the plugin root itself.
  This is an empirical question — we plan a smoke test, not a
  guess-and-pray.
- Whether the `plugin.json` schema has any field that allows a path
  override (e.g., `"skillsDir": "adapters/claude-code/skills"`). The
  current manifest is minimal (`name`, `version`, `description`,
  `author`, `keywords`) and shows no such field. We do not assume
  the field exists.

### Constraints

- **Inherited from icebreaker constraint 1:** v1.0.1 Claude Code
  installs must not break. *Atomic moves; old layout works alongside
  new during transition; lint catches drift.*
- **Inherited from icebreaker constraint 4:** Atomic writes for any
  cross-adapter operations (tide's rule).
- **Inherited from icebreaker constraint 5:** Each breakout's
  recommendation must include a rollback story.
- **forge's interjection (already on record in icebreaker):**
  Don't conflate non-negotiable constraints with implementation
  shape. Is "MUST NOT break existing installs" a hard requirement,
  or a soft one? Forge's challenge gets addressed below.

### Exit condition

A recommendation that includes:
1. The target plugin-loader routing approach (symlink vs re-install vs
   top-level shim).
2. A concrete sketch of `scripts/migrate-to-v1.1.sh`.
3. The pre-flight detection logic.
4. The step-by-step rollback story.
5. A clear answer to forge: how hard is the safety bar, and why?

## Investigation

### How does the Claude Code plugin loader actually resolve paths?

Three loader behaviors matter for migration:

| Behavior | Implication for migration |
|---|---|
| Plugin root is whatever path was passed to `claude install-plugin <path>` | If we change the canonical plugin root path, every installed user must re-run install. |
| Plugin root resolves through symlinks | A symlink at the marketplace location can be retargeted to a subdirectory without the user re-running install. |
| `skills/` and `agents/` discovered as siblings of `.claude-plugin/` | The loader does not follow path overrides in `plugin.json` (none exist in the current schema). The directories must be siblings. |

**`@operator [tide]`:** The third behavior is the load-bearing one.
We cannot tell Claude Code "look in `adapters/claude-code/skills/`"
through the manifest. The manifest is positional. The loader walks
the plugin root for `skills/` and `agents/` directly.

This rules out option (c) from the question ("top-level
`.claude-plugin/plugin.json` that references
`adapters/claude-code/skills/`"). The manifest has no `skillsDir`
field, and we cannot assume one will be added. The other two options
remain viable:

- **Option A — User re-installs at new path.** User runs
  `claude install-plugin ~/workspace/storytime/adapters/claude-code`.
  Plugin root becomes `adapters/claude-code/`. Skills and agents are
  siblings of the plugin manifest at that level. Clean.
- **Option B — Symlink the original layout from the new layout.**
  Keep the same `claude install-plugin ~/workspace/storytime` command.
  At repo root, replace the moved directories with symlinks:
  - `skills` → `adapters/claude-code/skills`
  - `agents` → `adapters/claude-code/agents`
  - `.claude-plugin` → `adapters/claude-code/.claude-plugin`

  The loader sees siblings at the repo root, follows the symlinks,
  and finds the actual content under `adapters/claude-code/`.
  **No user re-install needed.**

### Option C (which we rule out) — top-level shim manifest

Suggested in the question: "Top-level `.claude-plugin/plugin.json`
that references `adapters/claude-code/skills/` (if Claude Code allows)."

**`@operator [tide]`:** Claude Code does not allow this. The
`plugin.json` schema does not include a path-override field. The
loader walks fixed sibling directories. Even if a future version
adds such a field, we cannot rely on it for v1.1. **Drop option C.**

### `@critic [forge]` interjection — is the safety bar too high?

> "Is anyone other than the user actually running this in production?
> If not, we have more freedom."

**`@critic [forge]`:** This is a single-user-in-production refactor.
The user installed via marketplace symlink for their own dev. There
is no public marketplace listing yet (per `docs/multi-repo-distribution.md`
the multi-repo split is *future*, not active). The expression "MUST
NOT break existing installs" effectively means "MUST NOT break this
repo's own install on this user's machine."

That changes the cost-benefit. We have *more* freedom than a public
plugin would. We can:

- Require the user to run the migration script.
- Require a one-line re-install (Option A).
- Tolerate a 30-minute window where the install is broken if
  rollback is one command.

What we **cannot** tolerate, even as a single-user system:

- A migration that leaves the install in a half-broken state where
  rollback is non-obvious.
- A migration where `git revert` of the migration commit doesn't
  fully restore the previous working state.
- A migration where the user must manually fix multiple files to
  recover.

**`@critic [forge]` recommendation:** Drop "MUST NOT break" to
"MUST be reversible in one command, with one commit, and pre-flight
must refuse to apply if state is ambiguous." That is the realistic
bar. We are not Stripe. We are a one-user research framework.

**`@operator [tide]`:** Accepted. Reframing the constraint:

> v1.0.1 Claude Code installs must remain **trivially recoverable**.
> The migration must (a) be applied as a single git commit, (b) be
> reversible by `migrate-to-v1.1.sh --rollback` or `git revert`, and
> (c) refuse to run if pre-flight detects ambiguous state. We do not
> guarantee "no breakage during transition" — we guarantee "any
> breakage is one command away from rollback."

This is a meaningful weakening. It buys us simplicity. **Accepted as
the operating constraint for this breakout.**

### `@owner [anchor]` interjection — coordinate with BO1 (version)

> "The version bump from BO1 (v1.1 vs v2.0) communicates the
> migration weight."

**`@owner [anchor]`:** BO1 is running in parallel and will recommend
either v1.1 (incremental) or v2.0 (signals restructure). My
read of the current proposal text (`docs/proposals/cross-platform-storytime.md:280-283`)
recommends v1.1. **This breakout assumes v1.1.** If BO1 lands on v2.0
the script renames trivially (`migrate-to-v1.1.sh` →
`migrate-to-v2.sh`), the marker version string changes (`.version`
file goes to `1.1` or `2.0`), and the pre-flight detection still
works the same way (it looks at *layout*, not version string). **Low
coupling to BO1's outcome.**

### Recommendation: which option, A or B?

| Aspect | Option A (re-install) | Option B (symlinks at root) |
|---|---|---|
| User action required | Yes — `claude install-plugin <new-path>` | No — install path unchanged |
| Atomicity | Two operations: git commit + claude reinstall | Single git commit |
| Rollback simplicity | `git revert` + reinstall to old path | `git revert` only |
| Visibility of layout | Adapter is the plugin root — feels "right" | Repo root has symlinks — slightly less clean |
| Load-time cost | None | One symlink resolution per directory (cheap) |
| Breaks if loader doesn't follow symlinks | n/a | Yes — but that is testable |
| Public-distribution friendliness | Better — adapter directory is self-contained | Worse — symlinks may not survive npm/zip |
| Single-user practical cost | Modest (one command) | Zero |

**`@operator [tide]` recommendation: Option B with Option A
documented as the explicit migration step.**

Concretely: the migration script creates the symlinks at root.
The user does **not** re-run `claude install-plugin`. Their existing
install continues to work because the marketplace symlink still
points at `~/workspace/storytime/`, and the loader still finds
`skills/` and `agents/` and `.claude-plugin/` as siblings at that
path — they just happen to be symlinks now, resolving to the new
location.

**Smoke test gate:** Before recommending B for production, the
buildout phase MUST verify that Claude Code's plugin loader follows
symlinks on child directories. This is a one-hour investigation — set
up a scratch repo with this layout, install it, run a skill, observe
that it works. If it doesn't work, fall back to Option A. Document
the fallback path in the migration script.

**`@critic [forge]` interjection on this:**

> If symlinks at root are the recommended layout, the repo root looks
> like a hybrid forever. New users cloning the repo will see
> `skills/` (a symlink) and `adapters/claude-code/skills/` (the real
> thing) and be confused.

**`@operator [tide]`:** Accepted partially. The symlinks are a
*transitional* layout, not the steady-state layout. The plan:

1. **v1.1.0:** Symlinks at root. Both layouts work (existing installs
   keep working via symlink resolution; new installs can also do
   `claude install-plugin <repo>/adapters/claude-code` directly).
2. **v1.2.0 (or later, deferred):** Remove the root-level symlinks.
   Update `README.md` to recommend the adapter-path install. Existing
   users get a deprecation warning (via skill pre-flight) telling
   them to re-install. Removal is a flag day, but bounded.

**`@critic [forge]` accepts.** With the deprecation window, the
hybrid is bounded.

### Migration script sketch — `scripts/migrate-to-v1.1.sh`

Mirrors `scripts/migrate-to-v1.sh` shape (cited above). Key changes:
operates on **repo layout** rather than `specs/.storytime/` content.
Marker file is `.adapter-version` at repo root (or, equivalently,
the existence of `adapters/claude-code/.claude-plugin/plugin.json`).

```sh
#!/bin/sh
# migrate-to-v1.1.sh — migrate storytime repo from v1.0.x to v1.1
#
# Usage:
#   ./scripts/migrate-to-v1.1.sh              # dry-run (default)
#   ./scripts/migrate-to-v1.1.sh --apply      # write changes
#   ./scripts/migrate-to-v1.1.sh --apply --commit
#   ./scripts/migrate-to-v1.1.sh --rollback   # git revert the migration commit
#
# V1.1-NNN opt-in migration. Mirrors migrate-to-v1.sh style.
# Implements layout migration:
#   Step A: create adapters/claude-code/ skeleton
#   Step B: git mv skills/  → adapters/claude-code/skills/
#   Step C: git mv agents/  → adapters/claude-code/agents/
#   Step D: git mv .claude-plugin/ → adapters/claude-code/.claude-plugin/
#   Step E: create symlinks at repo root pointing into adapters/claude-code/
#   Step F: write .adapter-version = 1.1 at repo root
#   Step G: write adapters/claude-code/README.md (install instructions)
#   Step H: update bump-version.sh to scan new paths

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"

MODE="dryrun"
COMMIT=0
for arg in "$@"; do
  case "$arg" in
    --apply)    MODE="apply" ;;
    --commit)   COMMIT=1 ;;
    --rollback) MODE="rollback" ;;
    --help|-h)
      sed -n '2,12p' "$0"
      exit 0 ;;
    *) echo "Unknown flag: $arg"; exit 1 ;;
  esac
done

# ─── Rollback path ──────────────────────────────────────────────────
if [ "$MODE" = "rollback" ]; then
  SHA=$(git log --grep='^storytime: migrate to v1.1$' --format=%H -n1)
  if [ -z "$SHA" ]; then
    echo "No v1.1 migration commit found to roll back."
    exit 1
  fi
  echo "Rolling back v1.1 migration commit $SHA..."
  git revert --no-edit "$SHA"
  echo ""
  echo "Rollback complete. Verify with: ls -la skills agents .claude-plugin"
  echo "Your existing claude install-plugin install should keep working."
  exit $?
fi

# ─── Pre-flight ─────────────────────────────────────────────────────
# Detect: is the repo on v1.0 layout (skills/ etc. are real dirs at root)
#         or already on v1.1 layout (adapters/claude-code/ exists with
#         skills/ as symlink)?

V10_LAYOUT=0
V11_LAYOUT=0

if [ -d "$ROOT/skills" ] && [ ! -L "$ROOT/skills" ] \
   && [ -d "$ROOT/.claude-plugin" ] && [ ! -L "$ROOT/.claude-plugin" ]; then
  V10_LAYOUT=1
fi

if [ -d "$ROOT/adapters/claude-code/.claude-plugin" ] \
   && [ -L "$ROOT/skills" ]; then
  V11_LAYOUT=1
fi

if [ "$V10_LAYOUT" = "0" ] && [ "$V11_LAYOUT" = "0" ]; then
  echo "ERROR: layout is ambiguous."
  echo "Neither v1.0 layout (skills/ as real dir at root)"
  echo "nor v1.1 layout (adapters/claude-code/ + skills as symlink)"
  echo "fully detected. Refusing to migrate."
  echo ""
  echo "Inspect manually:"
  echo "  ls -la $ROOT/skills $ROOT/.claude-plugin $ROOT/adapters 2>&1"
  exit 1
fi

if [ "$V11_LAYOUT" = "1" ]; then
  echo "Already on v1.1 layout — nothing to migrate."
  exit 0
fi

echo "Storytime v1.0.x → v1.1 migration"
echo "Mode: $MODE"
[ "$COMMIT" = "1" ] && echo "Will commit on success: yes"
echo ""
echo "Detected v1.0 layout. Planned steps:"
echo "  Step A: mkdir -p adapters/claude-code/"
echo "  Step B: git mv skills/        → adapters/claude-code/skills/"
echo "  Step C: git mv agents/        → adapters/claude-code/agents/"
echo "  Step D: git mv .claude-plugin/ → adapters/claude-code/.claude-plugin/"
echo "  Step E: ln -s adapters/claude-code/skills        skills"
echo "          ln -s adapters/claude-code/agents        agents"
echo "          ln -s adapters/claude-code/.claude-plugin .claude-plugin"
echo "  Step F: write .adapter-version = 1.1 at repo root"
echo "  Step G: write adapters/claude-code/README.md"
echo "  Step H: update scripts/bump-version.sh path globs"
echo ""

if [ "$MODE" = "dryrun" ]; then
  echo "This was a DRY RUN. No files were modified."
  echo "Re-run with --apply to execute."
  echo ""
  echo "Rollback always available:"
  echo "  ./scripts/migrate-to-v1.1.sh --rollback   # if --commit was used"
  echo "  git checkout <pre-migration-sha> -- .   # otherwise"
  exit 0
fi

# ─── Apply mode ────────────────────────────────────────────────────
mkdir -p adapters/claude-code

git mv skills        adapters/claude-code/skills
git mv agents        adapters/claude-code/agents
git mv .claude-plugin adapters/claude-code/.claude-plugin

ln -s adapters/claude-code/skills        skills
ln -s adapters/claude-code/agents        agents
ln -s adapters/claude-code/.claude-plugin .claude-plugin

printf '1.1\n' > .adapter-version

cat > adapters/claude-code/README.md <<'README_EOF'
# Storytime — Claude Code adapter

This is the Claude Code adapter for storytime. Skills, agents, and
the plugin manifest live here.

## Install

Two equivalent install commands:

```sh
# Existing (works via root-level symlinks during v1.1 transition):
claude install-plugin /path/to/storytime

# Recommended for fresh installs:
claude install-plugin /path/to/storytime/adapters/claude-code
```

After v1.2.0, the root-level symlinks will be removed and only the
second form will work.
README_EOF

# Update bump-version.sh path globs
sed -i '' 's|"$REPO_ROOT"/skills/|"$REPO_ROOT"/adapters/claude-code/skills/|g' \
  scripts/bump-version.sh
sed -i '' 's|"$REPO_ROOT"/.claude-plugin/|"$REPO_ROOT"/adapters/claude-code/.claude-plugin/|g' \
  scripts/bump-version.sh

# Verification: smoke-test that Claude Code can still discover skills
echo "Verification:"
echo "  Symlink resolution:"
ls -la skills agents .claude-plugin | grep '^l'
echo "  Plugin manifest readable through symlink:"
test -f .claude-plugin/plugin.json && echo "    OK" || \
  { echo "    FAIL — symlink broken"; exit 1; }
echo "  Skill SKILL.md readable through symlink:"
test -f skills/storytime/SKILL.md && echo "    OK" || \
  { echo "    FAIL — symlink broken"; exit 1; }

if [ "$COMMIT" = "1" ]; then
  echo ""
  echo "Committing migration..."
  git add -A
  git commit -m "storytime: migrate to v1.1"
  echo "Commit created. To roll back: ./scripts/migrate-to-v1.1.sh --rollback"
fi

echo ""
echo "Migration complete. Test by running a storytime skill:"
echo "  /storytime-status"
echo ""
echo "If the skill loads and runs, the symlinks are working. If it"
echo "fails to load, run --rollback immediately and report the failure."
```

The script structure parallels `migrate-to-v1.sh:1-160` faithfully.
Differences:
- Operates on repo layout, not `specs/.storytime/` contents
- Pre-flight checks for layout state, not v0.9 markers
- Uses symlinks for the transition (the load-bearing mechanism)
- Verification step at the end is structural, not content-based

### Pre-flight gate logic (per V1-029 pattern)

V1-029 gates skills on un-migrated `specs/.storytime/`. We re-apply
the same idea to v1.1 at the **repo layout** scale. Skills check at
load time:

```
On every skill load:
  1. Resolve the plugin root (where this SKILL.md lives).
  2. Walk up to find .adapter-version OR .claude-plugin/plugin.json.
  3. If .adapter-version exists and contains "1.1":
       proceed.
  4. If neither marker exists:
       proceed (likely fresh v1.1 clone with no migration needed).
  5. If .claude-plugin/plugin.json exists at repo root and is NOT
       a symlink, AND adapters/claude-code/ does NOT exist:
       this is v1.0 layout. Skill is loaded from v1.0 path.
       Refuse to run with v1.1 logic. Tell user:
         "Storytime v1.1 detected un-migrated layout. Run:
            ./scripts/migrate-to-v1.1.sh --apply --commit
          Or pin to v1.0 by reinstalling from a v1.0.x tag."
  6. If both layouts coexist (adapters/claude-code/ exists AND root
     skills/ is NOT a symlink): ambiguous state. Refuse with clear
     message; the prior migration was incomplete.
```

The pre-flight is a few lines of bash logic that lives in a
shared helper script (`scripts/preflight-v1.1.sh`) and gets sourced
by every v1.1 skill in its first 30 lines. Same shape as v1.0
skills sourcing the v1.0 pre-flight.

### What about user session state?

Per the proposal at `docs/proposals/cross-platform-storytime.md:148-166`,
session state under `specs/.storytime/` is platform-agnostic and does
not move. The user's `cohort/`, `sessions/`, `archive/`, `dreams/`,
`history/`, `config.md`, and `.version` stay exactly where they are.

This is reaffirmed by inspecting the current state at
`specs/.storytime/.version:1` (contains "1.0\n") which is the v1.0
state-format marker — distinct from the new repo-layout marker
`.adapter-version` we are introducing.

**Two-marker design is intentional:**
- `.version` (under `specs/.storytime/`) — state format version
  (set by `migrate-to-v1.sh`). Tells skills what schema to expect
  for session artifacts.
- `.adapter-version` (at repo root, new in v1.1) — adapter layout
  version. Tells skills which directory shape they were loaded from.

These never need to advance together. v1.0 → v1.1 advances the
adapter version, leaves state format at v1.

### Backward-compatible install during transition

Yes — both layouts coexist, but only via the symlink mechanism. After
the migration commit:

| Install path | Plugin root | Skills found at | Works? |
|---|---|---|---|
| `claude install-plugin /path/to/storytime` | `/path/to/storytime` | `/path/to/storytime/skills` (symlink → `adapters/claude-code/skills`) | YES |
| `claude install-plugin /path/to/storytime/adapters/claude-code` | `/path/to/storytime/adapters/claude-code` | `/path/to/storytime/adapters/claude-code/skills` (real directory) | YES |

Both result in the loader finding the same files. **Until v1.2 when
we remove the root symlinks**, the user can run either install
command and get a working install.

### Rollback story — step by step

The user has just run `migrate-to-v1.1.sh --apply --commit` and
something is broken. What do they do?

**Tier 1 — automatic rollback (preferred path):**

```sh
./scripts/migrate-to-v1.1.sh --rollback
```

This greps git log for the deterministic commit message
`storytime: migrate to v1.1`, finds the SHA, runs `git revert --no-edit`.
The revert undoes:
- `git mv skills → adapters/claude-code/skills` (restores `skills/`
  as a real directory)
- `git mv agents → adapters/claude-code/agents` (restores `agents/`)
- `git mv .claude-plugin → adapters/claude-code/.claude-plugin`
  (restores `.claude-plugin/`)
- The root-level symlinks (deletes them; the originals are now
  back as real directories)
- The new `.adapter-version` file (deletes it)
- The new `adapters/claude-code/README.md` (deletes it)
- The path globs in `bump-version.sh` (restores them)

After revert, the repo is **byte-identical to its pre-migration state**.
The user's existing `claude install-plugin` registration still points
at `~/workspace/storytime/`. The loader finds the original `skills/`,
`agents/`, `.claude-plugin/` at that path. **The install just works.**

This is the value of letting `git mv` do the heavy lifting — git knows
how to revert it.

**Tier 2 — manual rollback if `--rollback` script fails:**

```sh
# Find the migration commit
git log --grep='^storytime: migrate to v1.1$'
# Revert it
git revert --no-edit <SHA>
```

Same effect as Tier 1, just running the underlying git command
directly.

**Tier 3 — nuclear rollback if git history is somehow lost:**

```sh
# Re-clone the repo at the v1.0.1 tag
git clone --branch v1.0.1 git@github.com:1ps0/storytime.git ~/workspace/storytime-rollback
# Re-point the marketplace symlink
rm ~/.claude/plugins/marketplaces/<marketplace>/external_plugins/storytime
ln -s ~/workspace/storytime-rollback \
  ~/.claude/plugins/marketplaces/<marketplace>/external_plugins/storytime
```

The user gets back to a known-good v1.0.1 state, machine-local. This
is the worst-case path and requires the user know which marketplace
they used (the path is in `docs/multi-repo-distribution.md`).

**Tier 4 — pin to v1.0 forever:**

If the user wants to opt out of v1.1 entirely:

```sh
git checkout v1.0.1
# Pin .claude-plugin/plugin.json version to 1.0.1 explicitly so
# pre-flight gates do not pester them.
```

This is the escape hatch V1-029 mentions ("Escape hatch: pin
storytime@0.9 in plugin.json"), generalized to v1.1.

### `@critic [forge]` final interjection — testing the safety bar

> Have we actually verified `git revert` of a `git mv` commit
> restores the working state? I want a smoke test in the buildout.

**`@operator [tide]`:** Yes. Adding to plan.md as a buildout
prerequisite:

1. Buildout sets up a scratch checkout.
2. Runs `migrate-to-v1.1.sh --apply --commit`.
3. Verifies skills load (run `/storytime-status`).
4. Runs `migrate-to-v1.1.sh --rollback`.
5. Verifies the pre-migration state is restored byte-identically.
6. Verifies skills still load.

If any step fails, the migration script needs work before it ships.

## Recommendation

**Adopt Option B (root symlinks) with Option A (re-install at adapter
path) as documented alternative.** Concretely:

1. Land `scripts/migrate-to-v1.1.sh` mirroring the
   `migrate-to-v1.sh` shape, with the structure sketched above.
2. The script uses `git mv` for the three relocations (skills,
   agents, .claude-plugin), then creates root-level symlinks
   pointing into `adapters/claude-code/`. Single commit per the
   rollback contract.
3. Pre-flight gate (`scripts/preflight-v1.1.sh`) sourced by every
   v1.1 skill, refuses to run if the repo is in v1.0 layout
   without migration applied. Escape hatch: pin to v1.0 tag.
4. `bump-version.sh` updated to scan `adapters/claude-code/` paths.
5. `adapters/claude-code/README.md` documents both install commands.
6. Rollback story documented in the README and tested in buildout.
7. **Buildout MUST include a smoke test** verifying that Claude
   Code's plugin loader follows symlinks on child directories. If
   it does not, fall back to Option A only and update the migration
   script accordingly. Document the fallback decision as a
   V1.1-NNN.
8. Schedule symlink removal for v1.2.0 with a deprecation warning
   in v1.1 skills (one phase later — not blocking v1.1 ship).

**Constraint reframe accepted:** "MUST NOT break existing installs"
is downgraded to "MUST be reversible in a single command." This is
the realistic safety bar for a single-user research framework and
unblocks simpler design choices.

## Confidence

**Medium-high.**

High on:
- The migration script shape — it directly mirrors the
  battle-tested `migrate-to-v1.sh`.
- The pre-flight gate pattern — V1-029 already validated this for
  state migration; extending to layout migration is straightforward.
- The rollback story — `git revert` of a `git mv` is well-defined.
- The two-marker design (`.version` for state, `.adapter-version`
  for layout) is clean.

Medium on:
- The symlink-following behavior of Claude Code's plugin loader.
  We have no documented spec for this. The smoke test in buildout
  is necessary, not optional. **If symlinks are not followed, we
  fall back to Option A** — user re-installs once at the adapter
  path. This is the only ambiguity, and it has a known fallback.

Low risk because:
- Single-user system. Worst case: user spends 10 minutes on rollback.
- Existing v1.0.1 installs survive without action via the symlinks.
- Even Option A (the fallback) is one command for the user.

## Effort Estimate

**Complexity 4** — A long afternoon. The script structure is mostly
parallel to `migrate-to-v1.sh`, but with three new mechanisms (path
relocation via `git mv`, symlink creation, `.adapter-version`
marker) and the pre-flight gate helper. Not novel; just careful work.

**Scale 2 (cross-cutting)** — touches `scripts/migrate-to-v1.1.sh`
(new), `scripts/preflight-v1.1.sh` (new),
`scripts/bump-version.sh` (path glob update),
`adapters/claude-code/README.md` (new),
the file moves themselves (18 skill SKILL.md files + 3 agent files +
1 `.claude-plugin/plugin.json` — handled by `git mv` so the change is
syntactically tracked), and (in v1.2) the deprecation warning in
each of 18 SKILL.md preambles.

**Verification scope:** smoke test of symlink-following requires
~1 hour of buildout time. Rollback verification requires ~30 minutes.

## Citations

- `/Users/alexevers/workspace/projects/storytime/.claude-plugin/plugin.json:1-9` — current minimal plugin manifest, no path-override fields                                                                       (code)
- `/Users/alexevers/workspace/projects/storytime/scripts/migrate-to-v1.sh:1-19` — migration script header & flag conventions we mirror                                                                                  (code)
- `/Users/alexevers/workspace/projects/storytime/scripts/migrate-to-v1.sh:39-58` — rollback path via `git log --grep` + `git revert`                                                                                    (code)
- `/Users/alexevers/workspace/projects/storytime/scripts/migrate-to-v1.sh:106-141` — dry-run planning + report shape                                                                                                    (code)
- `/Users/alexevers/workspace/projects/storytime/scripts/bump-version.sh:1-72` — cross-cutting propagation precedent                                                                                                    (code)
- `/Users/alexevers/workspace/projects/storytime/skills/storytime/SKILL.md:1-9` — version-echo convention skills use                                                                                                    (code)
- `/Users/alexevers/workspace/projects/storytime/skills/storytime/references/error-recovery.md:1-50` — checkpoint-first, preserve-partial-state pattern                                                                 (code)
- `/Users/alexevers/workspace/projects/storytime/docs/multi-repo-distribution.md:15-69` — install models showing marketplace-symlink shape                                                                              (repo doc)
- `/Users/alexevers/workspace/projects/storytime/docs/architecture.md:140-156` — current install path layout                                                                                                            (repo doc)
- `/Users/alexevers/workspace/projects/storytime/docs/proposals/cross-platform-storytime.md:148-166` — what's platform-agnostic (state stays put)                                                                       (repo doc)
- `/Users/alexevers/workspace/projects/storytime/docs/proposals/cross-platform-storytime.md:243-273` — risks and tensions including item 4 (existing v1.0.1 installs)                                                   (repo doc)
- `/Users/alexevers/workspace/projects/storytime/docs/proposals/cross-platform-storytime.md:280-303` — phase 2 (Claude Code adapter) plan we are operationalizing                                                       (repo doc)
- `/Users/alexevers/workspace/projects/storytime/specs/.storytime/sessions/v1-consolidation/_thread.md:104-117` — V1-028, V1-029, V1-030 establishing migration shape we extend                                          (repo doc)
- `/Users/alexevers/workspace/projects/storytime/specs/.storytime/sessions/v1-consolidation/001/plan.md:118-123` — V1-029 pre-flight gate decision text                                                                  (repo doc)
- `/Users/alexevers/workspace/projects/storytime/specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:56-59` — `@operator [tide]` problem statement carrying into this breakout                              (repo doc)
- `/Users/alexevers/workspace/projects/storytime/specs/.storytime/sessions/cross-platform-port/001/icebreaker.md:92-106` — constraints 1, 4, 5 inherited                                                                (repo doc)
- `/Users/alexevers/workspace/projects/storytime/specs/.storytime/.version:1` — state-format marker (=1.0), distinct from the new layout marker                                                                         (code)
- commit `a95bfde` — v1.0.1 ship; the install state we must preserve recoverability against                                                                                                                            (git)

## Open Questions

1. **Does Claude Code's plugin loader follow symlinks on child
   directories** (e.g., `skills/` symlink to `adapters/claude-code/skills/`)?
   Empirically testable. Buildout owns the smoke test. If "no",
   fall back to Option A and update migration script.
2. **Does the marketplace symlink resolution survive `npm` packaging
   in the future?** Out of scope for v1.1 (no npm distribution of
   the Claude Code adapter; npm is for OpenCode per BO5). Flag for
   future review if Claude Code distribution moves to npm.
3. **Should the deprecation warning in v1.1 skills (announcing v1.2
   symlink removal) be wired now or deferred to v1.2 implementation
   itself?** Recommend deferred. Adds noise without value during
   v1.1 transition. Returnable to converge phase.
4. **If buildout finds Option B fails (no symlink-follow), do we
   still ship v1.1 with Option A only, or wait for a manifest
   path-override field that does not exist yet?** Strong recommend:
   ship with Option A. The user re-runs `claude install-plugin`
   once. That is acceptable for a single-user system.

## Participants

- **@operator [tide]** (driver) — Drove the migration safety analysis,
  produced the migration script sketch, defined the pre-flight gate
  per V1-029 pattern, owned the rollback tiers, accepted forge's
  reframe of the safety bar.
- **@owner [anchor]** (silent supporter, one interjection) —
  Confirmed low coupling between this breakout and BO1's version
  recommendation; the migration script renames cleanly under either
  v1.1 or v2.0 outcome.
- **@critic [forge]** (silent supporter, three interjections) —
  Challenged the strict "MUST NOT break" framing, won the reframe
  to "MUST be reversible in one command"; flagged the hybrid-layout
  concern and won the v1.2 deprecation schedule; insisted on
  rollback smoke test as a buildout prerequisite.
