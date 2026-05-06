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

**Auto-pilot Mode**: Fully automated mode triggered by "auto", "automate", "build this" or high-level requirements. The agent follows The Flow end-to-end without user intervention. See `docs/using-superpowers.md` for details.

**Manual-first Mode**: Learning/control mode triggered by "I'll write it", "guide me", "help me learn". Agent acts as Senior Mentor — suggests skills, does NOT write code or spawn sub-agents unless explicitly asked. See `docs/using-superpowers.md` for details.

**Safety Boundaries**: Irreversible-operation guardrails for autonomous mode — Branch Isolation (no writes to main/master), No Auto-Deploy, Destructive Operations require human confirmation, PR & Merges must pause for human review. See `docs/using-superpowers.md` for details.

## Relationships
- A **Skill** belongs to one **Bucket**
- **The Flow** consumes multiple **Skills** in sequence
- **grill-with-docs** produces and updates **CONTEXT.md** and **ADRs**
- **to-prd** → **to-issues** → **triage** form the issue management pipeline
- **brainstorming** → **writing-plans** → **executing-plans** form the implementation pipeline