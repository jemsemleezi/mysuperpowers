# ADR 1: Merge Superpowers and Matt Pocock Skills

**Date:** 2026-05-06

## Status

Accepted

## Context

Two major skill ecosystems existed for AI coding agents:

1. **Superpowers** (by Obra) — focused on agent process orchestration: brainstorming, writing plans, executing plans, subagent-driven development, code review, verification, git worktrees, and multi-platform harness support (Claude Code, Codex, Cursor, OpenCode, Gemini CLI).

2. **Matt Pocock Skills** (by Matt Pocock) — focused on engineering methodology: domain language (CONTEXT.md, ADRs), requirements grilling, TDD, debugging, issue management (PRD → issues → triage), architecture improvement, and prototyping.

Both had overlapping skills in TDD, debugging, and skill-writing, with different strengths. Users had to choose between process (Superpowers) and methodology (Matt Pocock) or maintain both.

## Decision

Merge both projects into a single **MySuperPowers** project that:

1. Preserves all unique skills from both sources
2. Creates merged versions of overlapping skills (TDD, debugging, skill-writing)
3. Retains Superpowers' multi-platform infrastructure (hooks, plugin configs, testing framework)
4. Retains Matt Pocock's template system and per-repo configuration generation
5. Organizes skills into bucket structure: `engineering/`, `productivity/`, `misc/`

## Consequences

**Positive:**
- Single skill source for both process orchestration and engineering methodology
- Users get the full workflow: domain language → brainstorming → plans → execution → TDD → review → verification
- No need to choose between systems

**Negative:**
- Larger total skill count may increase context usage
- Some skill references needed updating from `superpowers:` to `mysuperpowers:` prefix
- Attribution complexity — need to credit both original projects

## Attribution

- **Superpowers** by Obra — https://github.com/obra/superpowers
- **Matt Pocock Skills** by Matt Pocock — https://github.com/mattpocock/skills
