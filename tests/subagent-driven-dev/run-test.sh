#!/usr/bin/env bash
# Run a subagent-driven-development test
# Usage: ./run-test.sh <test-name> [--plugin-dir <path>]
#
# Example:
#   ./run-test.sh go-fractals
#   ./run-test.sh svelte-todo --plugin-dir /path/to/mysuperpowers

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_NAME="${1:?Usage: $0 <test-name> [--plugin-dir <path>]}"
shift

# Parse optional arguments
PLUGIN_DIR=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --plugin-dir)
      PLUGIN_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Default plugin dir to parent of tests directory
if [[ -z "$PLUGIN_DIR" ]]; then
  PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

# Verify test exists
TEST_DIR="$SCRIPT_DIR/$TEST_NAME"
if [[ ! -d "$TEST_DIR" ]]; then
  echo "Error: Test '$TEST_NAME' not found at $TEST_DIR"
  echo "Available tests:"
  ls -1 "$SCRIPT_DIR" | grep -v '\.sh$' | grep -v '\.md$'
  exit 1
fi

# Create timestamped output directory
TIMESTAMP=$(date +%s)
OUTPUT_BASE="/tmp/mysuperpowers-tests/$TIMESTAMP/subagent-driven-development"
OUTPUT_DIR="$OUTPUT_BASE/$TEST_NAME"
mkdir -p "$OUTPUT_DIR"

echo "=== Subagent-Driven Development Test ==="
echo "Test: $TEST_NAME"
echo "Output: $OUTPUT_DIR"
echo "Plugin: $PLUGIN_DIR"
echo ""

# Scaffold the project
echo ">>> Scaffolding project..."
if [[ -f "$TEST_DIR/scaffold.sh" ]]; then
  "$TEST_DIR/scaffold.sh" "$OUTPUT_DIR/project"
else
  echo "  No scaffold.sh found, copying test directory..."
  cp -r "$TEST_DIR"/* "$OUTPUT_DIR/project/" 2>/dev/null || true
fi
echo ""

# Prepare the prompt
PLAN_PATH="$OUTPUT_DIR/project/plan.md"
if [[ ! -f "$PLAN_PATH" ]]; then
  # Look for any .md file that might be the plan
  PLAN_PATH=$(find "$OUTPUT_DIR/project" -name "*.md" -type f | head -1)
fi

if [[ -z "$PLAN_PATH" ]]; then
  echo "Error: No plan file found in $OUTPUT_DIR/project"
  exit 1
fi

PROMPT="Execute this plan using mysuperpowers:subagent-driven-development. The plan is at: $PLAN_PATH"

# Run Claude with JSON output for token tracking
LOG_FILE="$OUTPUT_DIR/claude-output.json"
echo ">>> Running Claude..."
echo "Prompt: $PROMPT"
echo "Log file: $LOG_FILE"
echo ""

# Run claude and capture output
# Using stream-json to get token usage stats
# --dangerously-skip-permissions for automated testing (subagents don't inherit parent settings)
cd "$OUTPUT_DIR/project"
claude -p "$PROMPT" \
  --plugin-dir "$PLUGIN_DIR" \
  --dangerously-skip-permissions \
  --output-format stream-json \
  --verbose \
  > "$LOG_FILE" 2>&1 || true

# Extract final stats
echo ""
echo ">>> Test complete"
echo "Project directory: $OUTPUT_DIR/project"
echo "Claude log: $LOG_FILE"
echo ""

# Show token usage if available
if command -v jq &> /dev/null; then
  echo ">>> Token usage:"
  # Extract usage from the last message with usage info
  jq -s '[.[] | select(.type == "result")] | last | .usage' "$LOG_FILE" 2>/dev/null || echo "(could not parse usage)"
  echo ""
fi

echo ">>> Next steps:"
echo "1. Review the project: cd $OUTPUT_DIR/project"
echo "2. Review Claude's log: less $LOG_FILE"
echo "3. Check if tests pass:"
if [[ "$TEST_NAME" == "go-fractals" ]]; then
  echo "   cd $OUTPUT_DIR/project && go test ./..."
elif [[ "$TEST_NAME" == "svelte-todo" ]]; then
  echo "   cd $OUTPUT_DIR/project && npm test && npx playwright test"
else
  echo "   Check the project for completion"
fi
