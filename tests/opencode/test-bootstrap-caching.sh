#!/usr/bin/env bash
# Test: Bootstrap Content Caching (#1202)
# Verifies the OpenCode transform caches bootstrap content between agent steps.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Test: Bootstrap Content Caching ==="

source "$SCRIPT_DIR/setup.sh"
trap cleanup_test_env EXIT

run_present_file_check() {
    if [ -f "$SCRIPT_DIR/test-bootstrap-caching.mjs" ]; then
        node "$SCRIPT_DIR/test-bootstrap-caching.mjs" "$MYSUPERPOWERS_PLUGIN_FILE" present
    else
        echo "  [SKIP] test-bootstrap-caching.mjs not found"
    fi
}

run_missing_file_check() {
    if [ -f "$SCRIPT_DIR/test-bootstrap-caching.mjs" ]; then
        mv "$MYSUPERPOWERS_SKILLS_DIR/engineering/using-superpowers/SKILL.md" "$TEST_HOME/using-superpowers.SKILL.md.bak"
        node "$SCRIPT_DIR/test-bootstrap-caching.mjs" "$MYSUPERPOWERS_PLUGIN_FILE" missing
        mv "$TEST_HOME/using-superpowers.SKILL.md.bak" "$MYSUPERPOWERS_SKILLS_DIR/engineering/using-superpowers/SKILL.md"
    else
        echo "  [SKIP] test-bootstrap-caching.mjs not found"
    fi
}

echo "Test 1: Caches bootstrap after the first successful transform..."
if [ -f "$SCRIPT_DIR/test-bootstrap-caching.mjs" ]; then
    run_present_file_check
    echo "  [PASS] Bootstrap content is cached while fresh message arrays still receive injection"
else
    echo "  [SKIP] Bootstrap caching test requires test-bootstrap-caching.mjs"
fi

echo "Test 2: Caches missing SKILL.md result..."
if [ -f "$SCRIPT_DIR/test-bootstrap-caching.mjs" ]; then
    run_missing_file_check
    echo "  [PASS] Missing bootstrap file is cached and not re-probed every transform"
else
    echo "  [SKIP] Bootstrap caching test requires test-bootstrap-caching.mjs"
fi

echo ""
echo "=== All bootstrap caching tests passed ==="
