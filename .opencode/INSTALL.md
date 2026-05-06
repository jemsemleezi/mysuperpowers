# MySuperPowers for OpenCode

## Installation

Add MySuperPowers to the `plugin` array in your `opencode.json`:

```json
{
  "plugin": ["<path-to-mysuperpowers>"]
}
```

Or install via git:

```json
{
  "plugin": ["mysuperpowers@git+https://github.com/your-org/mysuperpowers.git"]
}
```

## Usage

Use OpenCode's native `skill` tool to list and load skills:

```
skill tool to list skills
skill tool to load mysuperpowers/brainstorming
```

## Tool Mapping

| Claude Code Tool | OpenCode Equivalent |
|---|---|
| `TodoWrite` | `todowrite` |
| `Task` with subagents | Use OpenCode's `task` tool |
| `Skill` tool | OpenCode's native `skill` tool |
| File operations | Native OpenCode tools |
