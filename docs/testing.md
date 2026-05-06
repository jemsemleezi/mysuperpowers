# Testing MySuperPowers Skills

## Overview

Testing skills involves running real agent sessions and verifying behavior through session transcripts.

## Test Structure

```
tests/
├── claude-code/           # Claude Code integration tests
├── opencode/              # OpenCode integration tests
└── skill-triggering/      # Verify auto-trigger logic
```

## Writing Tests

Each test should:
1. Create a temp project
2. Run an agent session with the skill
3. Parse session transcript to verify correct behavior
4. Report pass/fail and token usage

## Token Analysis

Use the token analysis script to understand cost per skill invocation:

```bash
python3 tests/claude-code/analyze-token-usage.py <session-file>.jsonl
```
