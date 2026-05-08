---
name: setup-project
description: 搭建其他 MySuperPowers 技能所消费的仓库级配置（问题跟踪器、分类标签词汇、领域文档布局）。在使用 to-issues、to-prd、triage、diagnose、tdd、improve-codebase-architecture 或 zoom-out 之前，每个仓库运行一次。
disable-model-invocation: true
---

# 设置 MySuperPowers

> **⚠️ 目录结构强制要求：** 在初始化全栈项目时，此技能 **必须** 按照 `using-superpowers` 技能中定义的标准布局创建项目（见"全栈项目约定"章节）：
> ```
> my-project/
> ├── .opencode/          # OpenCode 专属配置
> ├── docs/
> │   └── adr/            # 架构决策记录
> ├── src/
> │   ├── frontend/       # 前端代码（React、Vue 等）
> │   └── backend/        # 后端代码（Node、Go、Python 等）
> ├── tests/              # 全局或集成测试
> ├── scripts/            # 工具脚本
> ├── CONTEXT.md          # 项目领域语言与上下文（根目录级——必需）
> ├── CLAUDE.md           # 代理规则（根目录级）
> └── package.json / go.mod  # 项目清单文件
> ```
> 
> 此布局确保 Auto-pilot 模式能够可靠地定位关键文件（例如根目录的 `CONTEXT.md`、`docs/adr/` 用于架构决策）。**根目录级别的 `CONTEXT.md` 是强制性的**——`grill-with-docs`、`diagnose`、`tdd` 和 `improve-codebase-architecture` 等下游技能都依赖它。

搭建 MySuperPowers 技能所假设的仓库级配置：

- **问题跟踪器** —— 问题存放的地方（默认 GitHub；也原生支持本地 Markdown）
- **分类标签** —— 用于五个规范分类角色的字符串
- **领域文档** —— `CONTEXT.md` 和 ADR 的位置，以及读取它们的消费者规则

这是一个由提示驱动的技能，不是确定性脚本。探索、呈现你的发现、与用户确认，然后写入。

## 流程

### 1. 探索

查看当前仓库以了解其起始状态。阅读已有的内容，不要假设：

- `git remote -v` 和 `.git/config` —— 这是 GitHub 仓库吗？是哪一个？
- 仓库根目录的 `AGENTS.md` 和 `CLAUDE.md` —— 是否存在？其中是否已有 `## Agent skills` 章节？
- 仓库根目录的 `CONTEXT.md` 和 `CONTEXT-MAP.md`
- `docs/adr/` 和任何 `src/*/docs/adr/` 目录
- `docs/agents/` —— 此技能的先前输出是否已存在？
- `.scratch/` —— 已在使用本地 Markdown 问题跟踪器约定的迹象

### 2. 呈现发现并询问

总结存在的和缺失的内容。然后引导用户逐一完成三个决策 **一次一个** —— 呈现一个章节，获取用户答案，然后进入下一个。不要一次性全部抛出。

假设用户不知道这些术语的含义。每个章节都以简短的解释开始（它是什么、为什么这些技能需要它、不同选择会带来什么变化）。然后展示选项和默认值。

**章节 A —— 问题跟踪器。**

> 解释："问题跟踪器"是此仓库问题的存放地。`to-issues`、`triage`、`to-prd` 和 `qa` 等技能从中读取和写入——它们需要知道是调用 `gh issue create`、在 `.scratch/` 下写 Markdown 文件，还是遵循你描述的其他工作流。选择你实际为此仓库跟踪工作的地方。

默认姿态：MySuperPowers 技能是为 GitHub 设计的。如果 `git remote` 指向 GitHub，提议它。如果 `git remote` 指向 GitLab（`gitlab.com` 或自托管），提议 GitLab。否则（或如果用户偏好），提供：

- **GitHub** —— 问题存放在仓库的 GitHub Issues 中（使用 `gh` CLI）
- **GitLab** —— 问题存放在仓库的 GitLab Issues 中（使用 [`glab`](https://gitlab.com/gitlab-org/cli) CLI）
- **本地 Markdown** —— 问题作为文件存放在此仓库的 `.scratch/<feature>/` 下（适合个人项目或没有远程仓库的项目）
- **其他**（Jira、Linear 等）—— 请用户用一段话描述工作流；技能将其记录为自由格式文本

**章节 B —— 分类标签词汇。**

> 解释：当 `triage` 技能处理新传入的问题时，它会通过一个状态机来移动问题——需要评估、等待报告者、准备好供 AFK 代理处理、准备好供人类处理，或不予修复。为此，它需要应用与你 **实际配置** 的字符串匹配的标签（或问题跟踪器中的等效物）。如果你的仓库已经使用不同的标签名称（例如 `bug:triage` 而非 `needs-triage`），在这里映射它们，以便技能应用正确的标签而不是创建重复项。

五个规范角色：

- `needs-triage` —— 维护者需要评估
- `needs-info` —— 等待报告者
- `ready-for-agent` —— 完整规格化，AFK 就绪（代理可以在无需人类上下文的情况下接手）
- `ready-for-human` —— 需要人类来实现
- `wontfix` —— 将不采取行动

默认值：每个角色的字符串等于其名称。询问用户是否希望覆盖任何值。如果他们的问题跟踪器还没有现有标签，默认值就足够了。

**章节 C —— 领域文档。**

> 解释：一些技能（`improve-codebase-architecture`、`diagnose`、`tdd`）读取 `CONTEXT.md` 文件以学习项目的领域语言，以及 `docs/adr/` 获取过去的架构决策。它们需要知道仓库有一个全局上下文还是多个（例如具有前后端独立上下文的 monorepo），以便它们找对位置。

确认布局：

- **单上下文** —— 仓库根目录一个 `CONTEXT.md` + `docs/adr/`。大多数仓库是这样的。
- **多上下文** —— 根目录 `CONTEXT-MAP.md` 指向每个上下文的 `CONTEXT.md` 文件（通常是 monorepo）。

### 3. 确认并编辑

向用户展示以下草稿：

- 将添加到 `CLAUDE.md` / `AGENTS.md` 的 `## Agent skills` 块（选择规则见步骤 4）
- `docs/agents/issue-tracker.md`、`docs/agents/triage-labels.md`、`docs/agents/domain.md` 的内容

让用户在写入之前编辑。

### 4. 写入

**选择要编辑的文件：**

- 如果 `CLAUDE.md` 存在，编辑它。
- 否则如果 `AGENTS.md` 存在，编辑它。
- 如果都不存在，询问用户创建哪一个——不要替他们选择。

永远不要在 `CLAUDE.md` 已存在时创建 `AGENTS.md`（反之亦然）——始终编辑已存在的那个。

如果所选文件中已存在 `## Agent skills` 块，就地更新其内容而非追加重复项。不要覆盖用户对周围章节的编辑。

该块：

```markdown
## Agent skills

### Issue tracker

[一行摘要，说明问题跟踪的位置]。详见 `docs/agents/issue-tracker.md`。

### Triage labels

[一行摘要，说明标签词汇]。详见 `docs/agents/triage-labels.md`。

### Domain docs

[一行摘要，说明布局——"single-context" 或 "multi-context"]。详见 `docs/agents/domain.md`。
```

然后使用此技能文件夹中的种子模板作为起点，写入三个文档文件：

- [issue-tracker-github.md](./issue-tracker-github.md) —— GitHub 问题跟踪器
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) —— GitLab 问题跟踪器
- [issue-tracker-local.md](./issue-tracker-local.md) —— 本地 Markdown 问题跟踪器
- [triage-labels.md](./triage-labels.md) —— 标签映射
- [domain.md](./domain.md) —— 领域文档消费者规则 + 布局

对于"其他"问题跟踪器，使用用户的描述从头编写 `docs/agents/issue-tracker.md`。

### 5. 完成

告诉用户设置已完成，以及哪些 MySuperPowers 技能现在将从这些文件中读取。提及他们以后可以直接编辑 `docs/agents/*.md`——只有在他们想切换问题跟踪器或从头开始时才需要重新运行此技能。

---

*本技能源自 Matt Pocock Skills，为 MySuperPowers 进行了适配。*
