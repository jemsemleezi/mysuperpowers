#!/usr/bin/env bash
# Scaffold a Svelte Todo app project for testing subagent-driven-development
# Usage: ./scaffold.sh <output-dir>

set -e

OUTPUT_DIR="${1:?Usage: $0 <output-dir>}"
mkdir -p "$OUTPUT_DIR"

echo ">>> Scaffolding Svelte Todo project in $OUTPUT_DIR..."

cd "$OUTPUT_DIR"

# Initialize Svelte project (skip interactive prompts)
cat > package.json <<'EOF'
{
  "name": "svelte-todo",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test": "playwright test"
  },
  "devDependencies": {
    "@sveltejs/vite-plugin-svelte": "^3.0.0",
    "svelte": "^4.0.0",
    "vite": "^5.0.0",
    "playwright": "^1.40.0"
  }
}
EOF

mkdir -p src/lib src/routes tests

# Create main layout
cat > src/routes/+layout.svelte <<'EOF'
<script>
  export let children;
</script>

<main>
  {@render children()}
</main>

<style>
  main {
    max-width: 800px;
    margin: 0 auto;
    padding: 1rem;
  }
</style>
EOF

# Create plan.md for subagent execution
cat > plan.md <<'EOF'
# Svelte Todo App Implementation Plan

## Task 1: Create Todo Store

Create a Svelte store for managing todos.

**File:** `src/lib/todoStore.js`

**Implementation:**
- Create a writable store for todos array
- Export functions: `addTodo(text)`, `toggleTodo(id)`, `removeTodo(id)`
- Each todo should have: `id`, `text`, `completed`, `createdAt`
- Add `filter` store for filtering (all/active/completed)

**Tests:** Write tests in `tests/todoStore.test.js`:
- Test adding todos
- Test toggling completion
- Test removing todos
- Test filtering

**Verification:** `npm test`

## Task 2: Create Todo List Component

Create the TodoList component.

**File:** `src/routes/+page.svelte`

**Implementation:**
- Display list of todos from store
- Each todo shows text and completion checkbox
- Click checkbox to toggle
- Show delete button for each todo
- Style with CSS

**Tests:** Add component tests with Playwright

**Verification:** `npm run build`

## Task 3: Add New Todo Input

Add input form for creating new todos.

**File:** `src/routes/+page.svelte` (update)

**Implementation:**
- Add input field and "Add" button
- On submit, call `addTodo()`
- Clear input after adding
- Disable button when input is empty
- Add Enter key support

**Tests:** Update tests to cover new todo creation

**Verification:** `npm test && npm run build`
EOF

echo ">>> Svelte Todo project scaffolded successfully"
echo "  Plan: $OUTPUT_DIR/plan.md"
echo "  Package: $OUTPUT_DIR/package.json"
