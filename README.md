# MySuperPowers — Complete Development Methodology for AI Agents
MySuperPowers is a merged skill system for AI coding agents, combining Superpowers (process orchestration) and Matt Pocock's engineering methodology. It gives agents a structured, repeatable way to build software that matches what you want, every time.

## Why It Exists
Coding agents are powerful, but they often fail in predictable ways. MySuperPowers addresses the gap between raw agent capability and reliable, high-quality software delivery. It merges two proven systems:
- **Superpowers**: A plugin-based skill system with hooks, multi-platform support, and process orchestration for agents.
- **Matt Pocock Skills**: Engineering methodology skills honed on real-world TypeScript projects, covering TDD, debugging, issue management, and domain language.

## Quickstart
Install MySuperPowers in your project based on your agent:
### Claude Code
1. Copy the `MySuperPowers/skills` folder to your project's `.claude/skills/` directory.
2. Copy `MySuperPowers/CLAUDE.md` to your project's root.
3. Copy `MySuperPowers/docs/using-superpowers.md` to your project's `docs/` folder.

### OpenCode
1. Copy the `MySuperPowers/skills` folder to your project's `.config/opencode/skills/` directory.
2. Copy `MySuperPowers/CLAUDE.md` to your project's root.

### Cursor / GitHub Copilot CLI
1. Copy the `MySuperPowers/skills` folder to your project's `.cursor/skills/` (Cursor) or `.github/copilot/skills/` (Copilot) directory.
2. Copy `MySuperPowers/CLAUDE.md` to your project's root.

### Gemini CLI / Codex CLI
1. Copy the `MySuperPowers/skills` folder to your project's `skills/` directory.
2. Copy `MySuperPowers/CLAUDE.md` to your project's root.

## The 5 Failure Modes We Fix
### 1. The Agent Didn't Do What I Want
Agents often guess your intent wrong. Use `brainstorming`, `grill-me`, or `grill-with-docs` to clarify requirements before any work starts. These skills force the agent to explore your intent, ask questions, and align on what you actually want.

### 2. The Agent Is Way Too Verbose
Agents use generic, bloated language. `CONTEXT.md` defines shared project terminology, so agents use your language, not corporate filler. Pair it with `caveman` for compressed, low-verbosity communication.

### 3. No Structured Process
Agents jump straight to coding without a plan. Follow the core flow: `brainstorming` → `writing-plans` → `executing-plans` → `verification-before-completion`. Every step is documented, reviewable, and repeatable.

### 4. The Code Doesn't Work
Agents propose fixes without debugging. Use `tdd` to write tests first, and `diagnose` to diagnose issues before changing code. No more guessing.

### 5. We Built A Ball Of Mud
Agents add code without architectural oversight. Use `improve-codebase-architecture` to refactor and align code with your project's ADRs and domain language.

## Full Skill Reference
### Engineering Skills
Used during daily code work:
- [brainstorming](skills/engineering/brainstorming/SKILL.md): Explores user intent and requirements before any creative work.
- [writing-plans](skills/engineering/writing-plans/SKILL.md): Creates implementation plans from specs or requirements before coding.
- [executing-plans](skills/engineering/executing-plans/SKILL.md): Executes written implementation plans with review checkpoints.
- [subagent-driven-development](skills/engineering/subagent-driven-development/SKILL.md): Executes implementation plans with independent tasks using subagents.
- [dispatching-parallel-agents](skills/engineering/dispatching-parallel-agents/SKILL.md): Dispatches 2+ independent tasks to parallel subagents.
- [tdd](skills/engineering/tdd/SKILL.md): Enforces test-first development for all features and bugfixes.
- [diagnose](skills/engineering/diagnose/SKILL.md): Structured debugging workflow for bugs and test failures.
- [grill-with-docs](skills/engineering/grill-with-docs/SKILL.md): Generates and updates CONTEXT.md and ADRs from project documentation.
- [zoom-out](skills/engineering/zoom-out/SKILL.md): Provides high-level project overview and architectural context.
- [to-prd](skills/engineering/to-prd/SKILL.md): Converts feature requests into structured Product Requirement Documents (PRDs).
- [to-issues](skills/engineering/to-issues/SKILL.md): Breaks PRDs into actionable, trackable issues.
- [triage](skills/engineering/triage/SKILL.md): Prioritizes and categorizes issues in the issue tracker.
- [setup-project](skills/engineering/setup-project/SKILL.md): Initializes new projects with standard tooling and configuration.
- [prototype](skills/engineering/prototype/SKILL.md): Creates quick, functional prototypes to validate ideas.
- [verification-before-completion](skills/engineering/verification-before-completion/SKILL.md): Verifies work with evidence before claiming completion.
- [improve-codebase-architecture](skills/engineering/improve-codebase-architecture/SKILL.md): Refactors and improves overall codebase architecture and structure.

### Productivity Skills
Used for non-code workflows:
- [grill-me](skills/productivity/grill-me/SKILL.md): Quick requirements clarification session with the user.
- [caveman](skills/productivity/caveman/SKILL.md): Compressed, low-verbosity communication style for agents.
- [writing-skills](skills/productivity/writing-skills/SKILL.md): Guides creating, editing, and verifying skills.
- [receiving-code-review](skills/productivity/receiving-code-review/SKILL.md): Handles code review feedback with technical rigor.
- [requesting-code-review](skills/productivity/requesting-code-review/SKILL.md): Requests code reviews before merging or completing work.
- [finishing-a-development-branch](skills/productivity/finishing-a-development-branch/SKILL.md): Guides integration of completed development branches.

### Misc Skills
Kept around but rarely used:
- [using-git-worktrees](skills/misc/using-git-worktrees/SKILL.md): Creates isolated git worktrees for feature work.
