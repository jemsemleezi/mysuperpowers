# Using MySuperPowers
MySuperPowers is a complete software development methodology for your coding agents. It merges two systems:
- **Superpowers** by Obra: A plugin-based skill system for coding agents with process orchestration, hooks, and multi-platform support.
- **Matt Pocock Skills**: Engineering methodology skills covering domain language, PRD/issue workflow, TDD, debugging, and more.

## What's Available
### Core Implementation Flow
The canonical workflow for building features:
`brainstorming` → `writing-plans` → `executing-plans` → `verification-before-completion`
Use `grill-with-docs` or `grill-me` first to clarify requirements.

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