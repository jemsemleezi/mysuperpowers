# Using MySuperPowers
MySuperPowers is a complete software development methodology for your coding agents. It merges two systems:
- **Superpowers** by Obra: A plugin-based skill system for coding agents with process orchestration, hooks, and multi-platform support.
- **Matt Pocock Skills**: Engineering methodology skills covering domain language, PRD/issue workflow, TDD, debugging, and more.

## Modes of Use

This framework is designed to support two distinct modes. You can switch between them at any time based on your prompt.

### Auto-pilot Mode (Fully Automated)
Use this when you have a clear goal and want the agent to handle everything from design to implementation.
- **Trigger phrases:** "Auto-pilot", "Fully automate this", "Help me build this feature".
- **Behavior:** The agent strictly follows **The Flow**:  
  `brainstorming → writing-plans → executing-plans/subagent-driven-development → tdd → verification-before-completion → requesting-code-review → finishing-a-development-branch`.  
  All steps are mandatory unless explicitly skipped by the user.
- **Best for:** Tedious tasks, boilerplate, well-defined features, or when you don't want to look at the code.

### Manual-first Mode (Learning & Control)
Use this when you want to write the code yourself, learn, and maintain strict control over every line.
- **Trigger phrases:** "Manual mode", "I want to write this myself", "Guide me step-by-step", "Let me drive".
- **Behavior:** The agent acts as a Senior Mentor/Pair Programmer. It will **NOT** automatically execute plans, write code, or spawn sub-agents unless explicitly told to. It will only suggest skills (like `tdd`, `diagnose`, `caveman`, `grill-me`) for you to approve or execute manually.
- **Best for:** Learning new concepts, tricky algorithms, or when you want to practice coding.

## Safety & Boundaries (Crucial for Auto-pilot)

To prevent autonomous agents from causing irreversible damage, the following boundaries are absolute:
1. **Branch Isolation:** Sub-agents MUST ONLY read/write to the current working branch. They are strictly forbidden from checking out, modifying, or pushing to `main`/`master`/protected branches.
2. **No Auto-Deploy:** Agents cannot execute deployment scripts, publish packages (npm, docker, etc.), or interact with production environments.
3. **Destructive Operations:** Dropping databases, deleting cloud resources, or running `rm -rf` on non-local directories require explicit human confirmation.
4. **PR & Merges:** Creating Pull Requests or merging branches MUST be paused for human review.

## Skill Selection Guide: `grill-me` vs `grill-with-docs`

| Skill | When to Use |
|:---|:---|
| `grill-me` | Manual-first mode, quick prototyping, personal learning projects, or when you want a lightweight interview without document changes. |
| `grill-with-docs` | Auto-pilot mode, initial phase of new features, collaborative projects, or when you need to sync `CONTEXT.md` and ADRs. |

If uncertain, manually ask the user which they prefer.

## Full-Stack Project Conventions (For `setup-project`)

To ensure Auto-pilot mode works predictably across your full-stack projects, the `setup-project` skill enforces the following standard directory layout. `CONTEXT.md` should always be generated at the root.

```
my-project/
├── .opencode/ # OpenCode specific configs
├── docs/
│ └── adr/ # Architecture Decision Records
├── src/
│ ├── frontend/ # Frontend code (React, Vue, etc.)
│ └── backend/ # Backend code (Node, Go, Python, etc.)
├── tests/ # Global or integration tests
├── scripts/ # Utility scripts
├── CONTEXT.md # Project domain language & context (Root level)
├── CLAUDE.md # Agent rules (Root level)
└── package.json / go.mod # Project manifests
```

## What's Available

### Core Implementation Flow (The Flow)
The canonical, unskippable implementation path in Auto-pilot mode is:
```
brainstorming → writing-plans → executing-plans/subagent-driven-development → tdd → verification-before-completion → requesting-code-review → finishing-a-development-branch
```
> ⚠️ **All flows MUST respect the Safety & Boundaries defined at the top of this document.**

### Domain Language and Documentation
- `grill-with-docs`: Produces and updates `CONTEXT.md` (project domain language) and ADRs (Architecture Decision Records in `docs/adr/`).
- `CONTEXT.md`: Shared terminology document to keep agents aligned on project-specific language.

### Engineering Practices
- `test-driven-development` (TDD): Write tests first, use tracer bullet approach (vertical slices, not horizontal).
- `systematic-debugging`: Structured debugging workflow before proposing fixes.

### Issue Management
Pipeline for managing work:
`to-prd` → `to-issues` → `triage`
Integrates with GitHub Issues, GitLab Issues, or local markdown trackers.

### Code Quality
- `receiving-code-review` / `requesting-code-review`: Handle code review feedback and request reviews before merging.
- `verification-before-completion`: Run verification commands and confirm output before claiming work is done.

## Agent Instructions
When a user asks to build something, the `brainstorming` skill should auto-trigger. Always use these skills when applicable. Even a 1% chance a skill matches your task means you should invoke it first.