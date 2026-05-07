#!/usr/bin/env bash
# Run all explicit skill request tests
# Usage: ./run-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"

echo "=== Running All Explicit Skill Request Tests ==="
echo ""

PASSED=0
FAILED=0
RESULTS=""

# Test: subagent-driven-development, please
echo ">>> Test 1: subagent-driven-development-please"
if "$SCRIPT_DIR/run-test.sh" "subagent-driven-development" "$PROMPTS_DIR/subagent-driven-development-please.txt"; then
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\nPASS: subagent-driven-development-please"
else
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\nFAIL: subagent-driven-development-please"
fi
echo ""

# Test: use systematic-debugging
echo ">>> Test 2: use-systematic-debugging"
if "$SCRIPT_DIR/run-test.sh" "systematic-debugging" "$PROMPTS_DIR/use-systematic-debugging.txt"; then
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\nPASS: use-systematic-debugging"
else
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\nFAIL: use-systematic-debugging"
fi
echo ""

# Test: please use brainstorming
echo ">>> Test 3: please-use-brainstorming"
if "$SCRIPT_DIR/run-test.sh" "brainstorming" "$PROMPTS_DIR/please-use-brainstorming.txt"; then
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\nPASS: please-use-brainstorming"
else
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\nFAIL: please-use-brainstorming"
fi
echo ""

# Test: mid-conversation execute plan
echo ">>> Test 4: mid-conversation-execute-plan"
if "$SCRIPT_DIR/run-test.sh" "subagent-driven-development" "$PROMPTS_DIR/mid-conversation-execute-plan.txt"; then
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\nPASS: mid-conversation-execute-plan"
else
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\nFAIL: mid-conversation-execute-plan"
fi
echo ""

# Test: action-oriented
echo ">>> Test 5: action-oriented"
if "$SCRIPT_DIR/run-test.sh" "executing-plans" "$PROMPTS_DIR/action-oriented.txt"; then
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\nPASS: action-oriented"
else
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\nFAIL: action-oriented"
fi
echo ""

# Test: after-planning-flow
echo ">>> Test 6: after-planning-flow"
if "$SCRIPT_DIR/run-test.sh" "executing-plans" "$PROMPTS_DIR/after-planning-flow.txt"; then
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\nPASS: after-planning-flow"
else
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\nFAIL: after-planning-flow"
fi
echo ""

# Test: claude-suggested-it
echo ">>> Test 7: claude-suggested-it"
if "$SCRIPT_DIR/run-test.sh" "writing-plans" "$PROMPTS_DIR/claude-suggested-it.txt"; then
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\nPASS: claude-suggested-it"
else
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\nFAIL: claude-suggested-it"
fi
echo ""

# Test: i-know-what-sdd-means
echo ">>> Test 8: i-know-what-sdd-means"
if "$SCRIPT_DIR/run-test.sh" "subagent-driven-development" "$PROMPTS_DIR/i-know-what-sdd-means.txt"; then
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\nPASS: i-know-what-sdd-means"
else
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\nFAIL: i-know-what-sdd-means"
fi
echo ""

# Test: skip-formalities
echo ">>> Test 9: skip-formalities"
if "$SCRIPT_DIR/run-test.sh" "brainstorming" "$PROMPTS_DIR/skip-formalities.txt"; then
    PASSED=$((PASSED + 1))
    RESULTS="$RESULTS\nPASS: skip-formalities"
else
    FAILED=$((FAILED + 1))
    RESULTS="$RESULTS\nFAIL: skip-formalities"
fi
echo ""

echo "=== Summary ==="
echo -e "$RESULTS"
echo ""
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total: $((PASSED + FAILED))"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
