---
type: proposal
created: 2026-04-02T10:00
session: 2026-04-02-worktrees
status: draft
---

# Proposal: Git Worktrees for Storytime Development

Using git worktrees to isolate storytime plugin development from stable
usage, enable parallel feature work, and support external testing via
`--plugin-dir`.

---

## Problem

When developing the storytime plugin, changes affect the installed plugin
immediately (symlink model). This means:

```
+------------------------------------------------------------+
|  THE COLLISION PROBLEM                                     |
|                                                            |
|  ~/workspace/storytime/  (symlinked to plugin marketplace) |
|       |                                                    |
|       |-- You edit SKILL.md to add warm-start              |
|       |   (half-finished, broken syntax)                   |
|       |                                                    |
|       |-- Meanwhile, in ai-sip-gateway:                    |
|       |   /storytime "add opus support"                    |
|       |   --> loads the BROKEN SKILL.md                    |
|       |   --> session fails or behaves unexpectedly        |
|       |                                                    |
|  No isolation between "developing storytime" and           |
|  "using storytime."                                        |
+------------------------------------------------------------+
```

Additionally:
- Multiple in-flight features collide on the same files
- No way to test a feature branch in another repo without switching branches
- Rollback requires git stash/checkout (destructive to flow)

---

## Worktree Solution

```
+------------------------------------------------------------+
|  WORKTREE LAYOUT                                           |
|                                                            |
|  ~/workspace/storytime/           MAIN WORKTREE (stable)   |
|  |  Branch: main                                           |
|  |  Symlinked to plugin marketplace                        |
|  |  This is what /storytime loads by default               |
|  |                                                         |
|  ~/workspace/storytime-wt/        WORKTREE ROOT            |
|  |                                                         |
|  +-- warm-start/                  FEATURE WORKTREE         |
|  |   Branch: feat/warm-start                               |
|  |   Independent copy of repo                              |
|  |   Test via: --plugin-dir ~/workspace/storytime-wt/      |
|  |             warm-start/                                  |
|  |                                                         |
|  +-- pr-qa/                       FEATURE WORKTREE         |
|  |   Branch: feat/pr-qa                                    |
|  |   Can be tested independently                           |
|  |                                                         |
|  +-- v0.3.0-rc/                   RELEASE CANDIDATE        |
|      Branch: release/0.3.0                                 |
|      Full regression testing before merge to main          |
+------------------------------------------------------------+
```

---

## Workflow

### Creating a Feature Worktree

```bash
cd ~/workspace/storytime
git worktree add ../storytime-wt/warm-start -b feat/warm-start

# Now work in the worktree:
cd ~/workspace/storytime-wt/warm-start
# Edit files, test changes
```

### Testing in Another Repo

```bash
cd ~/workspace/ai-sip-gateway

# Load the feature version of storytime:
claude --plugin-dir ~/workspace/storytime-wt/warm-start

# Run storytime — it loads the feature branch's skills:
# /storytime "test the warm-start flow"
```

The main worktree at `~/workspace/storytime/` stays on `main` and
continues serving as the stable plugin for all other usage.

### Merging Back

```bash
cd ~/workspace/storytime
git merge feat/warm-start
# Worktree can be cleaned up:
git worktree remove ../storytime-wt/warm-start
```

---

## Integration with Versioning

```
+------------------------------------------------------------+
|  VERSION AWARENESS                                         |
|                                                            |
|  Main worktree:     v0.2.0 (stable, released)             |
|  Worktree warm-start: v0.2.0-feat.warm-start (dev)        |
|  Worktree pr-qa:      v0.2.0-feat.pr-qa (dev)             |
|                                                            |
|  When a skill echoes its version, include the branch:      |
|    storytime v0.2.0                    (main)              |
|    storytime v0.2.0-feat.warm-start    (worktree)          |
|                                                            |
|  This way, when testing in ai-sip-gateway, you see:        |
|    "storytime v0.2.0-feat.warm-start"                      |
|  and know you're running the feature branch, not stable.   |
+------------------------------------------------------------+
```

The `VERSION` file could be extended to include branch info:
```bash
# In bump-version.sh or a separate dev-version script:
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
  echo "$(cat VERSION)-${BRANCH}" > VERSION
fi
```

Or the version-echo in SKILL.md could read the branch dynamically.

---

## Integration with --plugin-dir

Claude Code's `--plugin-dir` flag loads a plugin from a specific path.
This is the key integration point:

```
+------------------------------------------------------------+
|  PLUGIN LOADING PATHS                                      |
|                                                            |
|  DEFAULT (via marketplace symlink):                        |
|  ~/.claude/plugins/marketplaces/.../storytime              |
|    --> ~/workspace/storytime/  (main branch)               |
|                                                            |
|  OVERRIDE (via --plugin-dir):                              |
|  claude --plugin-dir ~/workspace/storytime-wt/warm-start   |
|    --> loads skills from the worktree                       |
|    --> main installation is unaffected                     |
|                                                            |
|  PER-PROJECT (via .claude-plugins):                        |
|  my-project/.claude-plugins/storytime                      |
|    --> git submodule pinned to a tag                       |
|    --> independent of user's global installation           |
+------------------------------------------------------------+
```

---

## Worktree Lifecycle

| Phase | Action |
|-------|--------|
| **Create** | `git worktree add ../storytime-wt/<name> -b feat/<name>` |
| **Develop** | Edit in worktree, test via `--plugin-dir` |
| **Test** | Load worktree plugin in target repo, run sessions |
| **Review** | PR from feature branch, review diffs |
| **Merge** | Merge to main, stable plugin auto-updates (symlink) |
| **Cleanup** | `git worktree remove ../storytime-wt/<name>` |

### Helper Script (future)

```bash
# storytime-worktree.sh — manage plugin worktrees
./scripts/storytime-worktree.sh create warm-start
./scripts/storytime-worktree.sh list
./scripts/storytime-worktree.sh test warm-start  # prints --plugin-dir flag
./scripts/storytime-worktree.sh remove warm-start
```

---

## Interaction with superpowers:using-git-worktrees

The user's Claude Code setup includes a `superpowers:using-git-worktrees`
skill. Storytime worktrees should be compatible:

- The superpowers skill creates worktrees for implementation work
- Storytime worktrees are for plugin development specifically
- Both use the same git worktree mechanism
- Convention: storytime worktrees go in `storytime-wt/`, general
  worktrees go wherever the superpowers skill puts them

---

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Worktree proliferation (too many feature branches) | Convention: one worktree per active feature, clean up after merge |
| Stale worktrees (forgotten, diverged from main) | `storytime-worktree.sh list` shows age and divergence |
| Confusion about which version is loaded | Version echo shows branch name. `storytime v0.2.0-feat.warm-start` is unambiguous |
| Worktree state conflicts with main | Git handles this — worktrees share the object store but have independent working trees |

---

## Non-Goals

| Non-goal | Why not | Revisit when |
|----------|---------|-------------|
| Automatic worktree creation per feature | Over-engineering for solo use | Multiple contributors working on storytime simultaneously |
| Worktree-per-session in target repos | Sessions don't modify the plugin, only read it | Plugin development workflow stabilizes |
| CI/CD integration with worktrees | No CI for storytime yet | Plugin is distributed to teams |

---

## Open Questions

1. **Should `--plugin-dir` be detectable by the skill?** If the skill could
   know it's loaded from a worktree (vs marketplace), it could adjust
   behavior (e.g., enable debug mode, show more verbose version info).

2. **Worktree root convention?** `~/workspace/storytime-wt/` is proposed.
   Alternatives: `~/workspace/.storytime-worktrees/`, or colocated at
   `~/workspace/storytime/.worktrees/` (but this pollutes the repo).

3. **Should the version-echo always show the branch?** On main, just
   `storytime v0.2.0`. On feature branches, `storytime v0.2.0-feat.warm-start`.
   Or always show the branch for transparency?
