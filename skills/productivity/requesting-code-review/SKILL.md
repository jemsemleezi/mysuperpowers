---
name: requesting-code-review
description: 在完成任务、实现主要功能或合并前验证工作是否符合要求时使用
---

# 请求代码审查（Requesting Code Review）

分派一个代码审查子代理来在问题级联之前捕获它们。审查者获得精确构建的上下文进行评估——而非你的会话历史。这让审查者专注于工作产物而非你的思考过程，同时保留你自己的上下文以继续工作。

**核心原则：** 尽早审查，经常审查。

## 何时请求审查

**强制：**
- 在子代理驱动开发中的每个任务之后
- 在完成主要功能之后
- 在合并到 main 之前

**可选但值得：**
- 当卡住时（新鲜视角）
- 在重构之前（基线检查）
- 在修复复杂 Bug 之后

## 如何请求

**1. 获取 git SHA：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # 或 origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 分派代码审查子代理：**

使用 Task 工具，类型为 `general-purpose`，填充 `code-reviewer.md` 处的模板

**占位符：**
- `{DESCRIPTION}` —— 你构建的内容的简短摘要
- `{PLAN_OR_REQUIREMENTS}` —— 它应该做什么
- `{BASE_SHA}` —— 起始提交
- `{HEAD_SHA}` —— 结束提交

**3. 根据反馈行动：**
- 立即修复 Critical 问题
- 在继续之前修复 Important 问题
- 记录 Minor 问题供以后处理
- 如果审查者错了，反驳（附带推理）

## 示例

```
[刚完成任务 2：添加验证函数]

You: 在继续之前让我请求代码审查。

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[分派代码审查子代理]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[子代理返回]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [修复进度指示器]
[继续任务 3]
```

## 与工作流集成

**子代理驱动开发：**
- 每个任务之后审查
- 在问题累积之前捕获它们
- 在移动到下一个任务之前修复

**执行计划：**
- 在每个任务或自然检查点之后审查
- 获取反馈，应用，继续

**临时开发：**
- 合并前审查
- 卡住时审查

## 危险信号

**绝不：**
- 因为"很简单"而跳过审查
- 忽略 Critical 问题
- 带着未修复的 Important 问题继续
- 与有效的技术反馈争论

**如果审查者错了：**
- 用技术推理反驳
- 展示证明它有效的代码 / 测试
- 请求澄清

见模板：requesting-code-review/code-reviewer.md

---

*本技能源自 Obra 的 Superpowers，为 MySuperPowers 进行了适配。*
