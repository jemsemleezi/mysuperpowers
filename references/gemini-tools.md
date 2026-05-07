# Gemini CLI 工具映射

当技能引用 Gemini CLI 中不可用的工具时，请使用以下等效工具：

| Claude Code 工具 | Gemini CLI 等效工具 |
|---|---|
| `TodoWrite` | 使用 `todowrite` 工具 |
| `Task` 搭配子代理 | 使用 Gemini 子代理系统 |
| `Skill` 工具 | 使用 `activate_skill` 或 `skill` 工具 |
| `Read`、`Write`、`Edit` | 使用 Gemini 原生工具 |
| `Bash` | 使用 `bash` 工具 |
| `mcp` | 不可用，请使用 Gemini 的 MCP 集成 |

注意：Gemini CLI 使用 `activate_skill` 激活技能，Claude Code 使用 `Skill` 工具。
