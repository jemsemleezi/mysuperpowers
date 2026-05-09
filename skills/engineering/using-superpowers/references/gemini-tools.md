# Gemini CLI 工具映射

技能使用 Claude Code 中的工具名。当你在技能中遇到这些工具时，请使用你平台的等价工具：

| 技能中引用的工具 | Gemini CLI 等价工具 |
|-----------------|----------------------|
| `Read`（文件读取） | `read_file` |
| `Write`（文件创建） | `write_file` |
| `Edit`（文件编辑） | `replace` |
| `Bash`（运行命令） | `run_shell_command` |
| `Grep`（搜索文件内容） | `grep_search` |
| `Glob`（按名称搜索文件） | `glob` |
| `TodoWrite`（任务追踪） | `write_todos` |
| `Skill` 工具（调用技能） | `activate_skill` |
| `WebSearch` | `google_web_search` |
| `WebFetch` | `web_fetch` |
| `Task` 工具（分配 subagent） | `@agent-name`（参见 [Subagent 支持](#subagent-support)） |

## Subagent 支持

Gemini CLI 通过 `@` 语法原生支持 subagent。使用内置的 `@generalist` 代理可以分配任何任务——它可以访问所有工具并遵循你提供的 prompt。

当技能要求分配指定类型的代理时，使用 `@generalist` 并从技能的 prompt 模板中提取完整的 prompt：

| 技能指令 | Gemini CLI 等价工具 |
|-------------------|----------------------|
| `Task tool (superpowers:implementer)` | `@generalist`，搭配填充好的 `implementer-prompt.md` 模板 |
| `Task tool (superpowers:spec-reviewer)` | `@generalist`，搭配填充好的 `spec-reviewer-prompt.md` 模板 |
| `Task tool (superpowers:code-reviewer)` | `@code-reviewer`（内置代理）或 `@generalist`，搭配填充好的 review prompt |
| `Task tool (superpowers:code-quality-reviewer)` | `@generalist`，搭配填充好的 `code-quality-reviewer-prompt.md` 模板 |
| `Task tool (general-purpose)` 配合内联 prompt | `@generalist`，搭配你的内联 prompt |

### 填充 Prompt

技能提供了带有占位符的 prompt 模板，例如 `{WHAT_WAS_IMPLEMENTED}` 或 `[FULL TEXT of task]`。填充所有占位符，然后将完整的 prompt 作为消息传递给 `@generalist`。prompt 模板本身包含了代理的角色、审查标准和期望的输出格式——`@generalist` 会遵循这些指令。

### 并行分配

Gemini CLI 支持并行分配 subagent。当技能要求你并行分配多个独立的 subagent 任务时，在同一个 prompt 中同时请求所有这些 `@generalist` 或指定名称的 subagent 任务。保持有依赖关系的任务顺序执行，但不要为了保持历史记录简洁而将独立的 subagent 任务串行化。

## 附加 Gemini CLI 工具

以下工具在 Gemini CLI 中可用，但 Claude Code 没有等价功能：

| 工具 | 用途 |
|------|------|
| `list_directory` | 列出文件和子目录 |
| `save_memory` | 将事实信息持久化到 GEMINI.md，跨会话保留 |
| `ask_user` | 向用户请求结构化输入 |
| `tracker_create_task` | 丰富的任务管理（创建、更新、列出、可视化） |
| `enter_plan_mode` / `exit_plan_mode` | 在进行更改前切换到只读研究模式 |
