---
name: using-superpowers
description: MySuperPowers 核心方法论——Auto-pilot 模式、Manual-first 模式、安全边界、The Flow 和全栈项目约定。作为AI Agent软件开发的基础框架规则。
---

# 使用 MySuperPowers

## 使用模式

根据用户的对话意向选择 Auto-pilot 模式（全自动）或者 Manual-first 模式（学习与掌控）

### Auto-pilot 模式（全自动）
当用户有明确目标，希望你从设计到实现一手包办时使用。
- **触发短语：** "Auto-pilot"、"Fully automate this"、"Help me build this feature"。
- **行为：** 你将严格遵循 **The Flow**：  
  `brainstorming → writing-plans → executing-plans/subagent-driven-development → tdd → verification-before-completion → requesting-code-review → finishing-a-development-branch`。  
  除非用户明确跳过，否则所有步骤均不可省略。
- **最适合：** 繁琐任务、模板代码、定义清晰的功能，或者用户不想亲自看代码的场景。

### Manual-first 模式（学习与掌控）
当用户想自己写代码、学习新知，并对每一行代码保持严格控制时使用。
- **触发短语：** "Manual mode"、"I want to write this myself"、"Guide me step-by-step"、"Let me drive"。
- **行为：** 你将扮演高级导师 / 结对编程角色。除非用户明确指示，否则你 **不要** 自动执行计划、编写代码或创建子Agent。你只需要推荐技能（如 `tdd`、`diagnose`、`caveman`、`grill-me`）供用户审批或手动执行。
- **最适合：** 学习新概念、处理棘手算法，或者用户想练习编码时。

## 安全边界（Auto-pilot 模式的关键）

为防止你造成不可逆的损害，以下边界是绝对不可逾越的：
1. **分支隔离：** 子Agent **只能** 在当前工作分支上读写。严禁检出、修改或推送至 `main` / `master` / 受保护分支。
2. **禁止自动部署：** 你不得执行部署脚本、发布包（npm、docker 等），或与生产环境进行交互。
3. **破坏性操作：** 删除数据库、清除云资源，或在非本地目录上执行 `rm -rf` 等操作，必须经过人工明确确认。
4. **PR 与合并：** 创建 Pull Request 或合并分支 **必须** 暂停以等待人工审查。

## 技能选择指南：`grill-me` vs `grill-with-docs`

| 技能 | 适用场景 |
|:---|:---|
| `grill-me` | Manual-first 模式、快速原型验证、个人学习项目，或用户只想进行一次轻量级访谈而不改动文档时。 |
| `grill-with-docs` | Auto-pilot 模式、新功能启动阶段、团队协作项目，或需要同步 `CONTEXT.md` 和 ADR 时。 |

如果不确定，请直接询问用户偏好。

## 全栈项目约定（`setup-project` 适用）

为确保 Auto-pilot 模式在全栈项目中表现一致，`setup-project` 技能会强制执行以下标准目录结构。`CONTEXT.md` 应始终生成在项目根目录。

```
my-project/
├── .opencode/          # OpenCode 专属配置
├── docs/
│   └── adr/            # 架构决策记录（Architecture Decision Records）
├── src/
│   ├── frontend/       # 前端代码（React、Vue 等）
│   └── backend/        # 后端代码（Node、Go、Python 等）
├── tests/              # 全局或集成测试
├── scripts/            # 工具脚本
├── CONTEXT.md          # 项目领域语言与上下文（根目录级）
├── CLAUDE.md           # Agent规则（根目录级）
└── package.json / go.mod  # 项目清单文件
```

## 可用技能概览

### 核心实现流程（The Flow）
Auto-pilot 模式下规范的、不可跳过的实现路径为：
```
brainstorming → writing-plans → executing-plans/subagent-driven-development → tdd → verification-before-completion → requesting-code-review → finishing-a-development-branch
```
> ⚠️ **所有流程均须遵守本文档顶部定义的安全边界。**

### 领域语言与文档
- `grill-with-docs`：产出并更新 `CONTEXT.md`（项目领域语言）和 ADR（位于 `docs/adr/` 的架构决策记录）。
- `CONTEXT.md`：共享术语文档，用于保持Agent对项目专属语言的对齐。

### 工程实践
- `test-driven-development`（TDD）：先写测试，采用示踪弹（tracer bullet）方式（纵向切片，而非横向分层）。
- `systematic-debugging`：在提出修复方案之前，遵循结构化的调试流程。

### 问题管理
管理工作项的流水线：
`to-prd` → `to-issues` → `triage`
支持与 GitHub Issues、GitLab Issues 或本地 Markdown 跟踪器集成。

### 代码质量
- `receiving-code-review` / `requesting-code-review`：处理代码审查反馈，在合并前请求审查。
- `verification-before-completion`：在宣称工作完成前，运行验证命令并确认输出结果。

## Agent 指令
当用户要求构建某样东西时，`brainstorming` 技能应自动触发。始终在适用时使用这些技能。只要有 1% 的可能性某个技能与用户的任务匹配，就应该先调用它。
