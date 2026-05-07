---
name: finishing-a-development-branch
description: 当实现完成、所有测试通过且你需要决定如何整合工作时使用——通过提供合并、PR 或清理的结构化选项来指导开发工作的完成
---

# 完成开发分支（Finishing a Development Branch）

## 概述

通过提供清晰的选项并处理所选工作流来指导完成开发工作。

**核心原则：** 验证测试 → 检测环境 → 呈现选项 → 执行选择 → 清理。

**在开始时宣布：** "我正在使用 finishing-a-development-branch 技能来完成此工作。"

## 流程

### 步骤 1：验证测试

**在呈现选项之前，验证测试通过：**

```bash
# 运行项目测试套件
npm test / cargo test / pytest / go test ./...
```

**如果测试失败：**
```
测试失败（<N> 个失败）。在完成之前必须修复：

[显示失败]

在测试通过之前无法进行合并 / PR。
```

停下来。不要进入步骤 2。

**如果测试通过：** 继续步骤 2。

### 步骤 2：检测环境

**在呈现选项之前确定工作区状态：**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

这决定了显示哪个菜单以及清理如何工作：

| 状态 | 菜单 | 清理 |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON`（普通仓库） | 标准 4 个选项 | 无需清理 worktree |
| `GIT_DIR != GIT_COMMON`，命名分支 | 标准 4 个选项 | 基于来源的清理（见步骤 6） |
| `GIT_DIR != GIT_COMMON`，detached HEAD | 减少为 3 个选项（无合并） | 无需清理（外部管理） |

### 步骤 3：确定基础分支

```bash
# 尝试常见的基础分支
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

或询问："这个分支从 main 分出——对吗？"

### 步骤 4：呈现选项

**普通仓库和命名分支 worktree——准确呈现这 4 个选项：**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Detached HEAD——准确呈现这 3 个选项：**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)
3. Discard this work

Which option?
```

**不要添加解释**——保持选项简洁。

### 步骤 5：执行选择

#### 选项 1：本地合并

```bash
# 获取主仓库根目录以确保 CWD 安全
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# 先合并——在删除任何东西之前验证成功
git checkout <base-branch>
git pull
git merge <feature-branch>

# 验证合并结果的测试
<test command>

# 合并成功后：清理 worktree（步骤 6），然后删除分支
```

然后：清理 worktree（步骤 6），然后删除分支：

```bash
git branch -d <feature-branch>
```

#### 选项 2：推送并创建 PR

```bash
# 推送分支
git push -u origin <feature-branch>

# 创建 PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

**不要清理 worktree** —— 用户需要它保持活跃以迭代 PR 反馈。

#### 选项 3：保持原样

报告："Keeping branch <name>. Worktree preserved at <path>."

**不要清理 worktree。**

#### 选项 4：丢弃

**先确认：**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

等待确切确认。

如果确认：
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

然后：清理 worktree（步骤 6），然后强制删除分支：
```bash
git branch -D <feature-branch>
```

### 步骤 6：清理工作区

**仅对选项 1 和 4 运行。** 选项 2 和 3 始终保留 worktree。

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

**如果 `GIT_DIR == GIT_COMMON`：** 普通仓库，无需清理 worktree。完成。

**如果 worktree 路径在 `.worktrees/`、`worktrees/` 或 `~/.config/mysuperpowers/worktrees/` 下：** MySuperPowers 创建了这个 worktree——我们负责清理。

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune  # 自愈：清理任何过时的注册
```

**否则：** 宿主环境（harness）拥有此工作区。不要删除它。如果你的平台提供了 workspace-exit 工具，使用它。否则，将工作区保持原位。

## 快速参考

| 选项 | 合并 | 推送 | 保留 Worktree | 清理分支 |
|--------|-------|------|---------------|----------------|
| 1. 本地合并 | 是 | - | - | 是 |
| 2. 创建 PR | - | 是 | 是 | - |
| 3. 保持原样 | - | - | 是 | - |
| 4. 丢弃 | - | - | - | 是（强制） |

## 常见错误

**跳过测试验证**
- **问题：** 合并损坏的代码，创建失败的 PR
- **修复：** 在提供选项之前始终验证测试

**开放式问题**
- **问题：** "What should I do next?" 是模糊的
- **修复：** 准确呈现 4 个结构化选项（detached HEAD 为 3 个）

**为选项 2 清理 worktree**
- **问题：** 删除用户需要用于 PR 迭代的 worktree
- **修复：** 仅对选项 1 和 4 清理

**在删除 worktree 之前删除分支**
- **问题：** `git branch -d` 失败，因为 worktree 仍然引用该分支
- **修复：** 先合并，删除 worktree，然后删除分支

**在 worktree 内部运行 git worktree remove**
- **问题：** 当 CWD 在要删除的 worktree 内时命令静默失败
- **修复：** 在 `git worktree remove` 之前始终 `cd` 到主仓库根目录

**清理 harness 拥有的 worktree**
- **问题：** 删除 harness 创建的 worktree 会导致幽灵状态
- **修复：** 仅清理 `.worktrees/`、`worktrees/` 或 `~/.config/mysuperpowers/worktrees/` 下的 worktree

**丢弃时无确认**
- **问题：** 意外删除工作
- **修复：** 要求输入"discard"确认

## 危险信号

**绝不：**
- 带着失败的测试继续
- 在未验证结果的测试的情况下合并
- 未经确认删除工作
- 未经明确请求强制推送
- 在确认合并成功之前删除 worktree
- 清理你未创建的 worktree（来源检查）
- 在 worktree 内部运行 `git worktree remove`

**始终：**
- 在提供选项之前验证测试
- 在呈现菜单之前检测环境
- 准确呈现 4 个选项（detached HEAD 为 3 个）
- 对选项 4 获取打字确认
- 仅对选项 1 和 4 清理 worktree
- 在 worktree 删除之前 `cd` 到主仓库根目录
- 在删除之后运行 `git worktree prune`

---

*本技能源自 Obra 的 Superpowers，为 MySuperPowers 进行了适配。*
