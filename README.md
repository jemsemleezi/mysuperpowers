# MySuperPowers — 面向 AI 代理的完整开发方法论
MySuperPowers 是一套为 AI 编码代理整合的技能系统，结合了 Superpowers（流程编排）和 Matt Pocock 的工程方法论。它为代理提供了一种结构化、可重复的方式，确保每次都能构建出符合你预期的软件。

## 它为何存在
编码代理很强大，但它们常常会以可预测的方式失败。MySuperPowers 解决了代理原始能力与稳定、高质量软件交付之间的鸿沟。它融合了两套经过验证的系统：
- **Superpowers**：一种基于插件的技能系统，具备钩子、多平台支持以及面向代理的流程编排能力。
- **Matt Pocock Skills**：在真实世界 TypeScript 项目中打磨出的工程方法论技能，涵盖 TDD、调试、问题管理和领域语言。

## 从哪里开始？（使用场景）

别觉得压力太大！你不需要一次用上所有技能。按你的场景来选：

**场景 1: “我在学习，想自己写代码” (Manual-first)**
从这套最小技能集开始：
1. `grill-me`：和代理沟通，搞清楚你真正需要构建什么。
2. `tdd`：让代理在你写代码 *之前* 指导你写测试。
3. `diagnose`：当代码出问题时，用它一步一步定位根因。
4. `caveman`：用它强制代理用更简单的方式说话，并节省 token。

**场景 2: “我只想去喝杯咖啡，顺手把这个功能做完” (Auto-pilot)**
直接说：*“Auto-pilot mode: Add user authentication.”*
代理会自动串联：`brainstorming` → `writing-plans` → `executing-plans`/`subagent-driven-development` → `tdd` → `verification-before-completion` → `code-review`。

**场景 3: “我有一个很乱的全栈项目，帮我把它理顺”**
1. 使用 `setup-project` 标准化你的目录结构。
2. 使用 `grill-with-docs` 生成 `CONTEXT.md`，让代理理解你的代码库。
3. 使用 `improve-codebase-architecture` 获取可执行的重构建议。

## 快速开始
根据你使用的代理，把 MySuperPowers 安装到项目中：
### Claude Code
1. 将 `MySuperPowers/skills` 文件夹复制到你项目的 `.claude/skills/` 目录。
2. 将 `MySuperPowers/CLAUDE.md` 复制到你项目根目录。

### OpenCode

> **重要**: 当前 OpenCode 版本（包括 v1.14.40）存在已知限制：通过 plugin 注册的技能**不会**暴露 `skill` 函数工具给 agent（[superpowers#1492](https://github.com/obra/superpowers/issues/1492)）。因此**不能只靠插件安装**，必须执行下方的技能复制步骤。

#### 必做：复制技能到全局目录

将整个 `skills/` 目录复制到 OpenCode 的全局技能扫描目录：

```powershell
Copy-Item -Recurse -Path "<path-to-mysuperpowers>\skills" -Destination "$env:USERPROFILE\.config\opencode\skills\mysuperpowers"
```

#### 可选：添加插件引用

将以下内容添加到你项目的 `opencode.json`（或 `opencode.jsonc`）文件中：

```json
{
  "plugin": [
  "mysuperpowers@git+https://github.com/jemsemleezi/mysuperpowers.git"
  ]
}
```

> 插件注册可以提供钩子（hooks）和消息转换（message transforms），但无法解决 `skill` tool 不可用的问题。技能复制是 **必做步骤**。

**验证：**
安装完成后，启动 OpenCode，并使用 `skill` 工具列出可用技能：
- 运行 `list` 查看所有 MySuperPowers 技能。
- 运行 `load mysuperpowers/tdd`（示例）来激活某个特定技能。


### Cursor / GitHub Copilot CLI
1. 将 `MySuperPowers/skills` 文件夹复制到你项目的 `.cursor/skills/`（Cursor）或 `.github/copilot/skills/`（Copilot）目录。
2. 将 `MySuperPowers/CLAUDE.md` 复制到你项目根目录。

### Gemini CLI / Codex CLI
1. 将 `MySuperPowers/skills` 文件夹复制到你项目的 `skills/` 目录。
2. 将 `MySuperPowers/CLAUDE.md` 复制到你项目根目录。
3. 对于 Gemini CLI，入口规则文件是 `GEMINI.md`（在 `gemini-extension.json` 中配置）。如果你想自定义 Gemini 的专属行为，请将 `MySuperPowers/GEMINI.md` 复制到项目根目录。

## 我们解决的 5 种失败模式
### 1. 代理没有按我想要的去做
代理经常会误判你的意图。使用 `brainstorming`、`grill-me` 或 `grill-with-docs`，在任何工作开始前先澄清需求。这些技能会强制代理探索你的意图、提出问题，并对齐你真正想要的结果。

### 2. 代理太啰嗦了
代理经常使用通用且冗长的表达。`CONTEXT.md` 定义了项目共享术语，因此代理会使用你的语言，而不是空洞的官话。配合 `caveman` 使用，可以获得更简洁、低冗余的沟通。

### 3. 没有结构化流程
代理常常不做计划就直接开写代码。请遵循核心流程：`brainstorming` → `writing-plans` → `executing-plans` → `verification-before-completion`。每一步都有文档记录，可审查，也可重复执行。

### 4. 代码跑不起来
代理常常不经过调试就直接给出修复方案。使用 `tdd` 先写测试，再用 `diagnose` 在修改代码前定位问题。别再靠猜了。

### 5. 我们造出了一个泥球
代理在没有架构约束的情况下不断往里加代码。使用 `improve-codebase-architecture` 对代码进行重构，并让它与你项目的 ADR 和领域语言保持一致。

## 完整技能参考
### Engineering Skills
用于日常编码工作：
- [brainstorming](skills/engineering/brainstorming/SKILL.md)：在任何创作工作开始前，先探索用户意图和需求。
- [writing-plans](skills/engineering/writing-plans/SKILL.md)：在编码前，基于规格或需求创建实现计划。
- [executing-plans](skills/engineering/executing-plans/SKILL.md)：带着审查检查点执行已写好的实现计划。
- [subagent-driven-development](skills/engineering/subagent-driven-development/SKILL.md)：使用子代理执行包含独立任务的实现计划。
- [dispatching-parallel-agents](skills/engineering/dispatching-parallel-agents/SKILL.md)：将 2 个或更多独立任务分派给并行子代理。
- [tdd](skills/engineering/tdd/SKILL.md)：对所有功能和 bug 修复强制执行测试优先开发。
- [diagnose](skills/engineering/diagnose/SKILL.md)：针对 bug 和测试失败的结构化调试流程。
- [grill-with-docs](skills/engineering/grill-with-docs/SKILL.md)：根据项目文档生成并更新 CONTEXT.md 和 ADR。
- [zoom-out](skills/engineering/zoom-out/SKILL.md)：提供项目的高层概览和架构上下文。
- [to-prd](skills/engineering/to-prd/SKILL.md)：将功能需求转换为结构化的产品需求文档（PRD）。
- [to-issues](skills/engineering/to-issues/SKILL.md)：把 PRD 拆解为可执行、可跟踪的问题。
- [triage](skills/engineering/triage/SKILL.md)：对问题跟踪器中的问题进行优先级排序和分类。
- [using-superpowers](skills/engineering/using-superpowers/SKILL.md)：MySuperPowers 核心方法论——Auto-pilot 模式、Manual-first 模式、安全边界与 The Flow。
- [setup-project](skills/engineering/setup-project/SKILL.md)：使用标准工具和配置初始化新项目。
- [prototype](skills/engineering/prototype/SKILL.md)：创建快速、可运行的原型来验证想法。
- [verification-before-completion](skills/engineering/verification-before-completion/SKILL.md)：在宣称完成之前，用证据验证工作。
- [improve-codebase-architecture](skills/engineering/improve-codebase-architecture/SKILL.md)：重构并改进整体代码库架构和结构。

### Productivity Skills
用于非编码工作流：
- [grill-me](skills/productivity/grill-me/SKILL.md)：与用户进行快速需求澄清会话。
- [caveman](skills/productivity/caveman/SKILL.md)：面向代理的压缩式、低冗余沟通风格。
- [writing-skills](skills/productivity/writing-skills/SKILL.md)：指导创建、编辑和验证技能。
- [receiving-code-review](skills/productivity/receiving-code-review/SKILL.md)：以技术严谨性处理代码审查反馈。
- [requesting-code-review](skills/productivity/requesting-code-review/SKILL.md)：在合并或完成工作前请求代码审查。
- [finishing-a-development-branch](skills/productivity/finishing-a-development-branch/SKILL.md)：指导已完成开发分支的整合。

### Misc Skills
保留但很少使用：
- [using-git-worktrees](skills/misc/using-git-worktrees/SKILL.md)：为功能开发创建隔离的 git worktree。

## 致谢 / Acknowledgments

MySuperPowers 是以下两个开源项目的合并与衍生：

| 项目 | 作者 | 地址 | 许可 |
|------|------|------|------|
| **Superpowers** | Jesse Vincent (obra) | https://github.com/obra/superpowers | MIT |
| **Matt Pocock Skills** | Matt Pocock | https://github.com/mattpocock/skills | MIT |

本项目采用了 MIT 开源许可（见 `LICENSE`），并在此致谢上述项目的原作者。
