# MySuperPowers

A merged skill system for AI coding agents, combining Superpowers (process orchestration) and Matt Pocock Skills (engineering methodology).

## Language

**Skill**: A SKILL.md document that provides instructions for an agent to follow in specific situations. Skills live under `skills/` organized by bucket.
_Avoid_: command, plugin, tool

**Bucket**: A directory category for skills - `engineering/` (code work), `productivity/` (workflow), `misc/` (rarely used).

**Engineering skill**: A skill used during code work (brainstorming, TDD, debugging, planning, domain language, issue management, architecture improvement).

**Productivity skill**: A skill used for non-code workflows (grilling, compressed communication, writing skills, code review, finishing branches).

**The Flow**: The canonical workflow: brainstorming → writing-plans → executing-plans → verification-before-completion. Preceded by grill-with-docs/grill-me for requirements clarity.

**CONTEXT.md**: Project domain language document that agents read to understand project-specific terminology. Created/updated by grill-with-docs.

**ADR**: Architecture Decision Record stored in `docs/adr/`. Documents hard-to-reverse decisions with trade-offs.

**Issue tracker**: Where issues live — GitHub Issues, GitLab Issues, or local markdown files. Used by to-prd, to-issues, and triage skills.

**Tracer bullet**: In TDD, writing ONE test first, then its implementation, before moving to the next test (vertical slice), as opposed to writing all tests first (horizontal slice).

**Harness**: The IDE/CLI environment running the agent (Claude Code, Codex CLI, Cursor, OpenCode, Gemini CLI, GitHub Copilot CLI).

## Relationships
- A **Skill** belongs to one **Bucket**
- **The Flow** consumes multiple **Skills** in sequence
- **grill-with-docs** produces and updates **CONTEXT.md** and **ADRs**
- **to-prd** → **to-issues** → **triage** form the issue management pipeline
- **brainstorming** → **writing-plans** → **executing-plans** form the implementation pipeline