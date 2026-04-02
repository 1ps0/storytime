#!/bin/sh
# validate-breakouts.sh — validate breakout output files after a session
# Usage: ./scripts/validate-breakouts.sh <session-path>
# Example: ./scripts/validate-breakouts.sh specs/.storytime/sessions/agc/001/

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <session-path>"
  echo "  Validates all breakout-*.md files in the given directory."
  echo "  Checks: non-empty, frontmatter, required sections, citations."
  exit 1
fi

SESSION_PATH="$1"
PASS=0
FAIL=0
INCOMPLETE=0

# Colors (if terminal supports them)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  NC=''
fi

check_section() {
  file="$1"
  section="$2"
  if grep -q "^## $section" "$file" 2>/dev/null; then
    return 0
  else
    return 1
  fi
}

# Find all breakout files
breakouts=$(find "$SESSION_PATH" -name 'breakout-*.md' -type f 2>/dev/null)

if [ -z "$breakouts" ]; then
  echo "No breakout files found in $SESSION_PATH"
  exit 0
fi

echo "Validating breakouts in: $SESSION_PATH"
echo ""

for file in $breakouts; do
  name=$(basename "$file")
  errors=""

  # Check non-empty
  if [ ! -s "$file" ]; then
    errors="${errors}  - File is empty\n"
  fi

  # Check frontmatter exists (starts with ---)
  if ! head -1 "$file" | grep -q '^---$'; then
    errors="${errors}  - Missing frontmatter\n"
  fi

  # Check for incomplete status
  if grep -q 'status: incomplete' "$file" 2>/dev/null; then
    INCOMPLETE=$((INCOMPLETE + 1))
    printf "${YELLOW}INCOMPLETE${NC} %s\n" "$name"
    echo "  - Marked as incomplete — needs re-run or extension"
    echo ""
    continue
  fi

  # Check required sections
  for section in "Question" "Findings" "Recommendation" "Confidence" "Effort Estimate" "Citations" "Open Questions" "Participants"; do
    if ! check_section "$file" "$section"; then
      errors="${errors}  - Missing section: ## ${section}\n"
    fi
  done

  # Check for at least one citation (code, doc, web, or git)
  has_citation=false
  grep -qE '[a-zA-Z0-9_/.-]+:[0-9]+' "$file" 2>/dev/null && has_citation=true    # file:line
  grep -qE '\[https?://' "$file" 2>/dev/null && has_citation=true                  # [url]
  grep -qiE 'commit [a-f0-9]{7}' "$file" 2>/dev/null && has_citation=true         # commit sha
  grep -qiE 'RFC [0-9]' "$file" 2>/dev/null && has_citation=true                  # RFC reference
  if [ "$has_citation" = false ]; then
    errors="${errors}  - No citations found (expected code, doc, web, or git references)\n"
  fi

  # Check Complexity mention
  if ! grep -qi 'Complexity' "$file" 2>/dev/null; then
    errors="${errors}  - No Complexity estimate found\n"
  fi

  # Check Scale mention
  if ! grep -qi 'Scale' "$file" 2>/dev/null; then
    errors="${errors}  - No Scale estimate found\n"
  fi

  # Report
  if [ -z "$errors" ]; then
    PASS=$((PASS + 1))
    printf "${GREEN}PASS${NC} %s\n" "$name"
  else
    FAIL=$((FAIL + 1))
    printf "${RED}FAIL${NC} %s\n" "$name"
    printf "%b" "$errors"
  fi
  echo ""
done

# Summary
echo "---"
TOTAL=$((PASS + FAIL + INCOMPLETE))
printf "Results: %d breakouts — " "$TOTAL"
printf "${GREEN}%d passed${NC}, " "$PASS"
printf "${RED}%d failed${NC}, " "$FAIL"
printf "${YELLOW}%d incomplete${NC}\n" "$INCOMPLETE"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
