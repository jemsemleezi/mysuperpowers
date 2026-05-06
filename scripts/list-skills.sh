#!/usr/bin/env bash
# List all skills in MySuperPowers
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Engineering Skills ==="
for skill in "$ROOT_DIR"/skills/engineering/*/; do
  name=$(basename "$skill")
  desc=$(head -5 "$skill/SKILL.md" 2>/dev/null | grep "^description:" | sed 's/^description: //' || echo "No description")
  echo "  $name - $desc"
done

echo ""
echo "=== Productivity Skills ==="
for skill in "$ROOT_DIR"/skills/productivity/*/; do
  name=$(basename "$skill")
  desc=$(head -5 "$skill/SKILL.md" 2>/dev/null | grep "^description:" | sed 's/^description: //' || echo "No description")
  echo "  $name - $desc"
done

echo ""
echo "=== Misc Skills ==="
for skill in "$ROOT_DIR"/skills/misc/*/; do
  name=$(basename "$skill")
  desc=$(head -5 "$skill/SKILL.md" 2>/dev/null | grep "^description:" | sed 's/^description: //' || echo "No description")
  echo "  $name - $desc"
done
