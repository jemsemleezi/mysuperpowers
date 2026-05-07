#!/usr/bin/env bash
# Sync MySuperPowers to Codex plugin format
# Usage: sync-to-codex-plugin.sh [options] <destination-repo>
#
# Options:
#   -n, --dry-run        Show what would be done without making changes
#   -y, --apply          Apply changes (required for actual sync)
#   --bootstrap           Create plugins/mysuperpowers/ when absent
#   --local <path>        Local destination path (for testing)
#   -h, --help            Show this help
#
# Example:
#   ./sync-to-codex-plugin.sh -n --local /tmp/test-dest
#   ./sync-to-codex-plugin.sh -y --bootstrap --local /tmp/test-dest

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default values
DRY_RUN=false
APPLY=false
BOOTSTRAP=false
LOCAL_DEST=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -y|--apply)
      APPLY=true
      shift
      ;;
    --bootstrap)
      BOOTSTRAP=true
      shift
      ;;
    --local)
      LOCAL_DEST="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [options] <destination-repo>"
      echo ""
      echo "Options:"
      echo "  -n, --dry-run       Dry run (preview changes)"
      echo "  -y, --apply         Apply changes"
      echo "  --bootstrap          Create plugin directory if absent"
      echo "  --local <path>       Local destination (for testing)"
      echo "  -h, --help           Show this help"
      exit 0
      ;;
    *)
      if [[ -z "${DEST_REPO:-}" ]]; then
        DEST_REPO="$1"
      fi
      shift
      ;;
  esac
done

# Validate arguments
if [[ "$APPLY" != "true" && "$DRY_RUN" != "true" ]]; then
  echo "ERROR: Must specify either -n (dry-run) or -y (apply)"
  exit 1
fi

# Determine destination
if [[ -n "$LOCAL_DEST" ]]; then
  DEST_REPO="$LOCAL_DEST"
fi

if [[ -z "${DEST_REPO:-}" ]]; then
  echo "ERROR: Destination repo required"
  exit 1
fi

# Resolve paths
UPSTREAM_REPO="$REPO_ROOT"
DEST_REPO="$(cd "$DEST_REPO" && pwd)"

# Plugin paths
SRC_PLUGIN_DIR="$UPSTREAM_REPO/.codex-plugin"
DEST_PLUGIN_DIR="$DEST_REPO/plugins/mysuperpowers"

# Ensure destination plugin directory exists
if [[ ! -d "$DEST_PLUGIN_DIR" ]]; then
  if [[ "$BOOTSTRAP" == "true" ]]; then
    echo "Mode: BOOTSTRAP (creating plugins/mysuperpowers/ when absent)"
    mkdir -p "$DEST_PLUGIN_DIR"
  else
    echo "ERROR: Destination plugin directory not found: $DEST_PLUGIN_DIR"
    echo "Use --bootstrap to create it automatically."
    exit 1
  fi
fi

# Read version from manifest
MANIFEST_VERSION=""
if [[ -f "$SRC_PLUGIN_DIR/plugin.json" ]]; then
  MANIFEST_VERSION=$(grep -o '"version": *"[^"]*"' "$SRC_PLUGIN_DIR/plugin.json" | sed 's/"version": *"//; s/"//')
fi

if [[ -z "$MANIFEST_VERSION" ]]; then
  # Fallback to package.json
  if [[ -f "$UPSTREAM_REPO/package.json" ]]; then
    MANIFEST_VERSION=$(grep -o '"version": *"[^"]*"' "$UPSTREAM_REPO/package.json" | sed 's/"version": *"//; s/"//')
  fi
fi

echo "=== Preview (rsync --dry-run) ==="
echo "Source: $UPSTREAM_REPO"
echo "Destination: $DEST_REPO"
echo "Manifest version: ${MANIFEST_VERSION:-unknown}"
echo ""

# Build rsync filter rules
FILTER_RULES=(
  # Include plugin manifest
  --include='.codex-plugin/'
  --include='.codex-plugin/plugin.json'
  # Include assets
  --include='assets/'
  --include='assets/*.svg'
  --include='assets/*.png'
  # Include skills
  --include='skills/'
  --include='skills/***'
  # Include scripts
  --include='scripts/'
  --include='scripts/sync-to-codex-plugin.sh'
  # Include tracked .private-journal files
  --include='.private-journal/'
  --include='.private-journal/keep.txt'
  # Exclude everything else
  --exclude='*'
)

# Execute rsync preview
if [[ "$DRY_RUN" == "true" ]]; then
  rsync -avn --delete "${FILTER_RULES[@]}" "$UPSTREAM_REPO/" "$DEST_PLUGIN_DIR/"
  echo ""
  echo "Dry run only. Nothing was changed or pushed."
  exit 0
fi

# Apply changes
if [[ "$APPLY" == "true" ]]; then
  echo "=== Applying Changes ==="
  
  # Check for dirty destination
  if [[ -n $(git -C "$DEST_REPO" status --porcelain plugins/mysuperpowers 2>/dev/null) ]]; then
    echo "ERROR: local checkout has uncommitted changes under 'plugins/mysuperpowers'"
    exit 1
  fi

  # Sync files
  rsync -av --delete "${FILTER_RULES[@]}" "$UPSTREAM_REPO/" "$DEST_PLUGIN_DIR/"

  # Update plugin.json with correct version
  if [[ -n "$MANIFEST_VERSION" && -f "$DEST_PLUGIN_DIR/.codex-plugin/plugin.json" ]]; then
    sed -i "s/\"version\": *\"[^\"]*\"/\"version\": \"$MANIFEST_VERSION\"/" "$DEST_PLUGIN_DIR/.codex-plugin/plugin.json"
  fi

  # Preserve destination-owned OpenAI metadata
  if [[ -f "$DEST_PLUGIN_DIR/skills/example/agents/openai.yaml" ]]; then
    echo "Preserving destination-owned OpenAI agent metadata..."
  fi

  echo ""
  echo "Sync completed successfully."
  echo "Overlay file (.codex-plugin/plugin.json) will be regenerated on next OpenCode startup."
fi
