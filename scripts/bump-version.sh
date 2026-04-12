#!/bin/sh
# bump-version.sh — update storytime version across all files
# Usage: ./scripts/bump-version.sh 0.8.0
#
# Updates: VERSION, plugin.json, README.md, all SKILL.md version-echo
# comments, site/*.html. Verifies consistency after bump.

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <new-version>"
  echo "Current version: $(cat VERSION)"
  exit 1
fi

NEW_VERSION="$1"
OLD_VERSION=$(cat VERSION | tr -d '[:space:]')
REPO_ROOT=$(git rev-parse --show-toplevel)

if [ "$NEW_VERSION" = "$OLD_VERSION" ]; then
  echo "Already at version $NEW_VERSION"
  exit 0
fi

echo "Bumping storytime: $OLD_VERSION → $NEW_VERSION"

# 1. VERSION file
printf '%s\n' "$NEW_VERSION" > "$REPO_ROOT/VERSION"
echo "  updated VERSION"

# 2. plugin.json
sed -i '' "s/\"version\": \"$OLD_VERSION\"/\"version\": \"$NEW_VERSION\"/" \
  "$REPO_ROOT/.claude-plugin/plugin.json"
echo "  updated .claude-plugin/plugin.json"

# 3. README.md
sed -i '' "s/v$OLD_VERSION/v$NEW_VERSION/g" "$REPO_ROOT/README.md"
echo "  updated README.md"

# 4. All SKILL.md version-echo blocks
skill_count=0
for f in "$REPO_ROOT"/skills/*/SKILL.md; do
  sed -i '' "s/storytime v$OLD_VERSION/storytime v$NEW_VERSION/g" "$f"
  skill_count=$((skill_count + 1))
done
echo "  updated $skill_count SKILL.md files"

# 5. Site HTML
site_count=0
for f in "$REPO_ROOT"/site/*.html; do
  [ -f "$f" ] || continue
  sed -i '' "s/v$OLD_VERSION/v$NEW_VERSION/g" "$f"
  site_count=$((site_count + 1))
done
echo "  updated $site_count site/*.html files"

# 6. Verify — check for any lingering old version
STALE=$(grep -rn "v$OLD_VERSION" "$REPO_ROOT/VERSION" \
  "$REPO_ROOT/.claude-plugin/plugin.json" "$REPO_ROOT/README.md" \
  "$REPO_ROOT"/skills/*/SKILL.md "$REPO_ROOT"/site/*.html 2>/dev/null || true)

if [ -n "$STALE" ]; then
  echo ""
  echo "WARNING: old version v$OLD_VERSION still found in:"
  echo "$STALE"
  exit 1
fi

echo ""
echo "Done. storytime is now v$NEW_VERSION"
echo "Don't forget to commit and tag: git tag v$NEW_VERSION"
