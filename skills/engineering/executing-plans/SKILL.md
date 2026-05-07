---
name: executing-plans
description: 当你有已写好的实现计划需要在独立会话中执行并带有审查检查点时使用
---

# 执行计划

## 概述

加载计划、严格审查、执行所有任务、完成后汇报。

**在开始时宣布：** "我正在使用 executing-plans 技能来实现此计划。"

**注意：** 告诉你的用户伙伴，MySuperPowers 在能够访问子代理时表现要好得多。如果能在支持子代理的平台（如 Claude Code 或 Codex）上运行，其工作质量会显著提升。如果有子代理可用，请使用 mysuperpowers:subagent-driven-development 而非此技能。

## 流程

### 步骤 1：加载并审查计划
1. 阅读计划文件
2. 严格审查——发现任何关于计划的疑虑或担忧
3. 如有疑虑：在开始前向你的用户伙伴提出
4. 如无疑虑：创建 TodoWrite 并继续

### 步骤 2：执行任务

对每个任务：
1. 标记为 in_progress
2. 严格遵循每个步骤（计划包含 bite-sized 步骤）
3. 运行指定的验证
4. 标记为 completed

### 步骤 3：完成开发

所有任务完成并验证后：
- 宣布："我正在使用 finishing-a-development-branch 技能来完成此工作。"
- **必需子技能：** 使用 mysuperpowers:finishing-a-development-branch
- 遵循该技能验证测试、呈现选项、执行选择

## 何时停下来求助

**在以下情况下立即停止执行：**
- 遇到阻塞（缺少依赖、测试失败、指令不明确）
- 计划存在阻止开始的关键空白
- 你不理解某条指令
- 验证反复失败

**请求澄清而非猜测。**

## 何时回溯到更早的步骤

**在以下情况下返回审查（步骤 1）：**
- 用户伙伴根据你的反馈更新了计划
- 需要重新思考基本方法

**不要强行通过阻塞——停下来问。**

## 牢记
- 先严格审查计划
- 严格按照计划步骤执行
- 不要跳过验证
- 当计划指示时引用技能
- 被阻塞时停下来，不要猜测
- 未经用户明确同意，绝不在 main/master 分支上开始实现

## 集成

**必需工作流技能：**
- **mysuperpowers:using-git-worktrees** —— 确保隔离的工作区（创建一个或验证已有的）
- **mysuperpowers:writing-plans** —— 创建此技能执行的计划
- **mysuperpowers:finishing-a-development-branch** —— 所有任务完成后完成开发

---

*本技能源自 Obra 的 Superpowers，为 MySuperPowers 进行了适配。*
