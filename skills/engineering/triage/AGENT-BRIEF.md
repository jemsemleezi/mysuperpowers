# 编写代理简报（Writing Agent Briefs）

代理简报是在问题移动到 `ready-for-agent` 时发布在 GitHub 问题上的结构化评论。它是 AFK 代理将依据的权威规格。原始问题正文和讨论是上下文——代理简报是契约。

## 原则

### 持久性重于精确性

问题可能在 `ready-for-agent` 中停留数天或数周。在此期间代码库会变化。编写简报时确保即使文件被重命名、移动或重构后仍然有用。

- **要** 描述接口、类型和行为契约
- **要** 命名代理应该查找或修改的具体类型、函数签名或配置形状
- **不要** 引用文件路径——它们会过时
- **不要** 引用行号
- **不要** 假设当前实现结构会保持不变

### 行为性的，而非过程性的

描述系统 **应该做什么**，而非 **如何实现它**。代理将新鲜探索代码库并做出自己的实现决策。

- **好：** "`SkillConfig` 类型应接受一个可选的 `schedule` 字段，类型为 `CronExpression`"
- **坏：** "打开 src/types/skill.ts 并在第 42 行添加 schedule 字段"
- **好：** "当用户不带参数运行 `/triage` 时，他们应该看到需要关注的问题摘要"
- **坏：** "在主处理函数中添加一个 switch 语句"

### 完整的验收标准

代理需要知道何时完成。每个代理简报必须有具体的、可测试的验收标准。每个标准应该可以独立验证。

- **好：** "运行 `gh issue list --label needs-triage` 返回已通过初步分类的问题"
- **坏：** "分类应该正常工作"

### 明确的范围边界

声明什么不在范围内。这防止代理镀金或对相邻功能做出假设。

## 模板

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** 一行描述需要做什么

**Current behavior:**
描述当前发生的情况。对于 Bug，这是损坏的行为。
对于改进，这是功能构建在其上的现状。

**Desired behavior:**
描述代理工作完成后应该发生的情况。
对边界情况和错误条件要具体。

**Key interfaces:**
- `TypeName` —— 需要改什么以及为什么
- `functionName()` 返回类型 —— 当前返回什么 vs 应该返回什么
- Config shape —— 需要的任何新配置选项

**Acceptance criteria:**
- [ ] 具体的、可测试的标准 1
- [ ] 具体的、可测试的标准 2
- [ ] 具体的、可测试的标准 3

**Out of scope:**
- 不应在此问题中更改或处理的事项
- 看起来相关但独立的功能
```

## 示例

### 好的代理简报（Bug）

```markdown
## Agent Brief

**Category:** bug
**Summary:** Skill description truncation drops mid-word, producing broken output

**Current behavior:**
当技能描述超过 1024 字符时，它被精确截断在 1024 字符处，
不考虑词边界。这产生在词中间截断的描述
（例如 "Use when the user wants to confi"）。

**Desired behavior:**
截断应该在 1024 字符之前的最后一个词边界处断开，
并附加 "..." 表示截断。

**Key interfaces:**
- `SkillMetadata` 类型的 `description` 字段——不需要类型变更，
  但填充它的验证 / 处理逻辑需要尊重词边界
- 任何从 SKILL.md frontmatter 读取并提取 description 的函数

**Acceptance criteria:**
- [ ] 1024 字符以下的描述不变
- [ ] 超过 1024 字符的描述在 1024 字符之前的最后一个词边界处截断
- [ ] 截断的描述以 "..." 结尾
- [ ] 包含 "..." 的总长度不超过 1024 字符

**Out of scope:**
- 更改 1024 字符限制本身
- 多行描述支持
```

### 好的代理简报（改进）

```markdown
## Agent Brief

**Category:** enhancement
**Summary:** Add `.out-of-scope/` directory support for tracking rejected feature requests

**Current behavior:**
当功能请求被拒绝时，问题使用 `wontfix` 标签和评论关闭。
没有关于决策或推理的持久记录。未来类似的请求需要维护者
回忆或搜索先前的讨论。

**Desired behavior:**
被拒绝的功能请求应记录在 `.out-of-scope/<concept>.md` 文件中，
捕获决策、推理和所有请求该功能的问题链接。在分类新问题时，
应检查这些文件以匹配。

**Key interfaces:**
- `.out-of-scope/` 中的 Markdown 文件格式——每个文件应有
  `# Concept Name` 标题、`**Decision:**` 行、`**Reason:**` 行，
  以及带有问题链接的 `**Prior requests:**` 列表
- 分类工作流应尽早读取所有 `.out-of-scope/*.md` 文件，
  并通过概念相似性匹配传入的问题

**Acceptance criteria:**
- [ ] 以 wontfix 关闭功能会在 `.out-of-scope/` 中创建 / 更新文件
- [ ] 文件包含决策、理由和关闭问题的链接
- [ ] 如果已存在匹配的范围外文件，新问题追加到其 "Prior requests" 列表
      而非创建重复
- [ ] 在分类期间，检查已有的范围外文件并在新问题匹配先前拒绝时展示

**Out of scope:**
- 自动匹配（由人类确认匹配）
- 重新打开先前拒绝的功能
- Bug 报告（仅改进拒绝进入 `.out-of-scope/`）
```

### 坏的代理简报

```markdown
## Agent Brief

**Summary:** Fix the triage bug

**What to do:**
The triage thing is broken. Look at the main file and fix it.
The function around line 150 has the issue.

**Files to change:**
- src/triage/handler.ts (line 150)
- src/types.ts (line 42)
```

这很糟糕因为：
- 没有类别
- 模糊的描述（"the triage thing is broken"）
- 引用会过时的文件路径和行号
- 没有验收标准
- 没有范围边界
- 没有当前 vs 期望行为的描述

---

*本技能源自 Matt Pocock Skills，为 MySuperPowers 进行了适配。*
