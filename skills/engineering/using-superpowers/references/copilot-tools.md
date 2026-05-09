# Copilot CLI 工具映射

技能使用 Claude Code 中的工具名。当你在技能中遇到这些工具时，请使用你平台的等价工具：

| 技能中引用的工具 | Copilot CLI 等价工具 |
|-----------------|----------------------|
| `Read`（文件读取） | `view` |
| `Write`（文件创建） | `create` |
| `Edit`（文件编辑） | `edit` |
| `Bash`（运行命令） | `bash` |
| `Grep`（搜索文件内容） | `grep` |
| `Glob`（按名称搜索文件） | `glob` |
| `Skill` 工具（调用技能） | `skill` |
| `WebFetch` | `web_fetch` |
| `Task` 工具（分配 subagent） | `task`，搭配 `agent_type: "general-purpose"` 或 `"explore"` |
| 多个 `Task` 调用（并行） | 多个 `task` 调用 |
| Task 状态/输出 | `read_agent`、`list_agents` |
| `TodoWrite`（任务追踪） | `sql`，使用内置的 `todos` 表 |
| `WebSearch` | 无等价工具——使用 `web_fetch` 配合搜索引擎 URL |
| `EnterPlanMode` / `ExitPlanMode` | 无等价工具——在主会话中直接操作 |

## 异步 shell 会话

Copilot CLI 支持持久化的异步 shell 会话，Claude Code 没有直接等价功能：

| 工具 | 用途 |
|------|------|
| 带 `async: true` 的 `bash` | 在后台启动长时间运行的命令 |
| `write_bash` | 向运行中的异步会话发送输入 |
| `read_bash` | 从异步会话读取输出 |
| `stop_bash` | 终止异步会话 |
| `list_bash` | 列出所有活跃的 shell 会话 |

## 附加 Copilot CLI 工具

| 工具 | 用途 |
|------|------|
| `store_memory` | 持久化代码库的事实信息供未来会话使用 |
| `report_intent` | 使用当前意图更新 UI 状态栏 |
| `sql` | 查询会话的 SQLite 数据库（todos、metadata） |
| `fetch_copilot_cli_documentation` | 查阅 Copilot CLI 文档 |
| GitHub MCP 工具（`github-mcp-server-*`） | 原生 GitHub API 访问（issues、PRs、代码搜索） |
