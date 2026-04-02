#!/bin/sh
# bump-version.sh — update storytime version across all files
# Usage: ./scripts/bump-version.sh 0.3.0

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <new-version>"
  echo "Current version: $(cat VERSION)"
  exit 1
fi

NEW_VERSION="$1"
OLD_VERSION=$(cat VERSION)
REPO_ROOT=$(git rev-parse --show-toplevel)

if [ "$NEW_VERSION" = "$OLD_VERSION" ]; then
  echo "Already at version $NEW_VERSION"
  exit 0
fi

echo "Bumping storytime: $OLD_VERSION → $NEW_VERSION"

# 1. VERSION file
echo -n "$NEW_VERSION" > "$REPO_ROOT/VERSION"
echo "  updated VERSION"

# 2. plugin.json
sed -i '' "s/\"version\": \"$OLD_VERSION\"/\"version\": \"$NEW_VERSION\"/" \
  "$REPO_ROOT/.claude-plugin/plugin.json"
echo "  updated .claude-plugin/plugin.json"

# 3. All SKILL.md version-echo blocks
count=0
for f in "$REPO_ROOT"/skills/*/SKILL.md; do
  sed -i '' "s/storytime v$OLD_VERSION/storytime v$NEW_VERSION/g" "$f"
  count=$((count + 1))
done
echo "  updated $count SKILL.md files"

echo ""
echo "Done. storytime is now v$NEW_VERSION"
echo "Don't forget to commit and tag: git tag v$NEW_VERSION"
