# Codex 工具映射

技能使用 Claude Code 中的工具名。当你在技能中遇到这些工具时，请使用你平台的等价工具：

| 技能中引用的工具 | Codex 等价工具 |
|-----------------|------------------|
| `Task` 工具（分配 subagent） | `spawn_agent`（参见 [Subagent 分发需要 multi-agent 支持](#subagent-dispatch-requires-multi-agent-support)） |
| 多个 `Task` 调用（并行） | 多个 `spawn_agent` 调用 |
| Task 返回结果 | `wait_agent` |
| Task 自动完成 | `close_agent` 以释放槽位 |
| `TodoWrite`（任务追踪） | `update_plan` |
| `Skill` 工具（调用技能） | 技能原生加载——直接遵循指令即可 |
| `Read`、`Write`、`Edit`（文件操作） | 使用本地的文件工具 |
| `Bash`（运行命令） | 使用本地的 shell 工具 |

## Subagent 分发需要 multi-agent 支持

在 Codex 配置（`~/.codex/config.toml`）中添加：

```toml
[features]
multi_agent = true
```

这会为 `dispatching-parallel-agents` 和 `subagent-driven-development` 等技能启用 `spawn_agent`、`wait_agent` 和 `close_agent`。

遗留说明：`rust-v0.115.0` 之前的 Codex 构建版本将衍生代理的等待暴露为 `wait`。当前 Codex 对衍生代理使用 `wait_agent`。`wait` 名称现在属于 code-mode 的 `exec/wait`，它通过 `cell_id` 恢复已挂起的 exec cell；它不再是衍生代理的结果获取工具。

## 环境检测

创建 worktree 或完成分支的技能应在执行前通过只读 git 命令检测环境：

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → 已处于链接的 worktree 中（跳过创建）
- `BRANCH` 为空 → detached HEAD（无法从沙箱进行 branch/push/PR 操作）

参见 `using-git-worktrees` 的 Step 0 和 `finishing-a-development-branch`
的 Step 1，了解每个技能如何使用这些信号。

## Codex App 完成流程

当沙箱阻止 branch/push 操作（在外部管理的 worktree 中处于 detached HEAD 状态）时，代理会提交所有工作并告知用户使用 App 的原生控制功能：

- **"Create branch"**（创建分支）——指定分支名称，然后通过 App UI 进行 commit/push/PR
- **"Hand off to local"**（移交到本地）——将工作传输到用户的本地 checkout

代理仍然可以运行测试、暂存文件，并输出建议的分支名称、commit 消息和 PR 描述供用户复制。
