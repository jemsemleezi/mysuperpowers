# 技能编写最佳实践

> 学习如何编写 Claude 能成功发现并使用的有效技能。

优秀的技能应简洁、结构清晰，且经过实际使用测试。本指南提供实用的编写决策建议，帮助你编写 Claude 能有效发现并使用的技能。如需了解技能的工作原理，可查看 [技能概述](/en/docs/agents-and-tools/agent-skills/overview)。

## 核心原则

### 简洁是关键

[上下文窗口](https://platform.claude.com/docs/en/build-with-claude/context-windows)是共享资源。你的技能与 Claude 需要了解的所有其他内容共享上下文窗口，包括：
* 系统提示词
* 对话历史
* 其他技能的元数据
* 你的实际请求

技能中的每个 token 并非都有即时成本。启动时，仅预加载所有技能的元数据（名称和描述）。只有当技能相关时，Claude 才会读取 SKILL.md，且仅在需要时读取其他文件。但 SKILL.md 的简洁性仍然重要：一旦 Claude 加载它，每个 token 都会与对话历史和其他上下文竞争。

**默认假设**：Claude 本身已经非常智能

仅添加 Claude 尚未掌握的信息。对每条信息提出质疑：
* “Claude 真的需要这段解释吗？”
* “我可以假设 Claude 已经知道这个吗？”
* “这段内容值得消耗这些 token 吗？”

**好例子：简洁版**（约 50 token）：

```markdown  theme={null}
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
```

**坏例子：过于冗长**（约 150 token）：

```markdown  theme={null}
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available for PDF processing, but we
recommend pdfplumber because it's easy to use and handles most cases well.
First, you'll need to install it using pip. Then you can use the code below...
```

简洁版假设 Claude 知道 PDF 是什么，以及库的工作原理。

### 设定合适的自由度

根据任务的脆弱性和多变性匹配具体的程度。

**高自由度**（基于文本的指令）：

适用场景：
* 多种方法都可行
* 决策依赖上下文
* 启发式方法指导方案

示例：

```markdown  theme={null}
## Code review process

1. Analyze the code structure and organization
2. Check for potential bugs or edge cases
3. Suggest improvements for readability and maintainability
4. Verify adherence to project conventions
```

**中自由度**（带参数的伪代码或脚本）：

适用场景：
* 存在首选模式
* 允许一定变化
* 配置影响行为

示例：

```markdown  theme={null}
## Generate report

Use this template and customize as needed:

```python
def generate_report(data, format="markdown", include_charts=True):
    # Process data
    # Generate output in specified format
    # Optionally include visualizations
```
```

**低自由度**（特定脚本，极少或无参数）：

适用场景：
* 操作脆弱且易出错
* 一致性至关重要
* 必须遵循特定顺序

示例：

```markdown  theme={null}
## Database migration

Run exactly this script:

```bash
python scripts/migrate.py --verify --backup
```

Do not modify the command or add additional flags.
```

**类比**：把 Claude 想象成探索路径的机器人：
* **两侧都是悬崖的窄桥**：只有一条安全前进路线。提供具体的护栏和精确指令（低自由度）。例如：必须按精确顺序运行的数据库迁移。
* **没有危险的开阔田野**：多条路径都能成功。给出大致方向，信任 Claude 找到最佳路线（高自由度）。例如：上下文决定最佳方案的代码审查。

### 用你计划使用的所有模型测试

技能是模型的补充，因此效果取决于底层模型。用你计划使用的所有模型测试你的技能。

**按模型的测试注意事项**：
* **Claude Haiku**（快速、经济）：技能是否提供了足够的指导？
* **Claude Sonnet**（平衡）：技能是否清晰高效？
* **Claude Opus**（强大推理）：技能是否避免了过度解释？

对 Opus 完美生效的内容，对 Haiku 可能需要更多细节。如果你计划跨多个模型使用技能，目标是编写对所有模型都适用的指令。

## 技能结构

<Note>
  **YAML 前置元数据**：SKILL.md 的前置元数据需要两个字段：
  * `name`——技能的可读名称（最多 64 字符）
  * `description`——技能功能和适用场景的单行描述（最多 1024 字符）

  完整技能结构详情请查看 [技能概述](/en/docs/agents-and-tools/agent-skills/overview#skill-structure)。
</Note>

### 命名规范

使用一致的命名模式，让技能更容易引用和讨论。我们推荐技能名称使用**动名词形式**（动词 + -ing），因为这能清晰描述技能提供的活动或能力。

**好的命名示例（动名词形式）**：
* “处理 PDF”
* “分析电子表格”
* “管理数据库”
* “测试代码”
* “编写文档”

**可接受的替代方案**：
* 名词短语：“PDF 处理”、“电子表格分析”
* 行动导向：“处理 PDF”、“分析电子表格”

**避免**：
* 模糊名称：“助手”、“工具集”、“工具”
* 过于通用：“文档”、“数据”、“文件”
* 技能集合内模式不一致

一致的命名让以下操作更简单：
* 在文档和对话中引用技能
* 一眼看懂技能的功能
* 组织和搜索多个技能
* 维护专业、统一的技能库

### 编写有效的描述

`description` 字段用于技能发现，应包含技能功能和适用场景。

<Warning>
  **始终使用第三人称**。描述会被注入系统提示词，视角不一致会导致发现问题。
  * **好：** “处理 Excel 文件并生成报告”
  * **避免：** “我可以帮你处理 Excel 文件”
  * **避免：** “你可以用这个处理 Excel 文件”
</Warning>

**要具体，包含关键术语**。同时包含技能功能和触发使用的具体场景/上下文。

每个技能只有一个 description 字段。描述是技能选择的关键：Claude 用它从可能 100+ 的可用技能中选择合适的那个。你的描述必须提供足够细节，让 Claude 知道何时选择该技能，而 SKILL.md 的其余部分提供实现细节。

有效示例：

**PDF 处理技能：**
```yaml  theme={null}
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Excel 分析技能：**
```yaml  theme={null}
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
```

**Git 提交助手技能：**
```yaml  theme={null}
description: Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.
```

避免以下模糊描述：
```yaml  theme={null}
description: Helps with documents
```
```yaml  theme={null}
description: Processes data
```
```yaml  theme={null}
description: Does stuff with files
```

### 渐进式披露模式

SKILL.md 作为概述，根据需要指向详细材料，就像入职指南中的目录。关于渐进式披露的工作原理，请查看概述中的 [技能工作原理](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

**实用指导：**
* 保持 SKILL.md 正文在 500 行以内，以获得最佳性能
* 接近此限制时，将内容拆分到单独文件
* 使用以下模式有效组织指令、代码和资源

#### 视觉概述：从简单到复杂

基础技能仅包含带元数据和指令的 SKILL.md 文件：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=87782ff239b297d9a9e8e1b72ed72db9" alt="Simple SKILL.md file showing YAML frontmatter and markdown body" data-og-width="2048" width="2048" data-og-height="1153" height="1153" data-path="images/agent-skills-simple-file.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=c61cc33b6f5855809907f7fda94cd80e 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=90d2c0c1c76b36e8d485f49e0810dbfd 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=ad17d231ac7b0bea7e5b4d58fb4aeabb 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f5d0a7a3c668435bb0aee9a3a8f8c329 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0e927c1af9de5799cfe557d12249f6e6 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=46bbb1a51dd4c8202a470ac8c80a893d 2500w" />

随着技能增长，你可以打包额外内容，仅当需要时 Claude 才加载：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=a5e0aa41e3d53985a7e3e43668a33ea3" alt="Bundling additional reference files like reference.md and forms.md." data-og-width="2048" width="2048" data-og-height="1327" height="1327" data-path="images/agent-skills-bundling-content.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f8a0e73783e99b4a643d79eac86b70a2 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=dc510a2a9d3f14359416b706f067904a 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=82cd6286c966303f7dd914c28170e385 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=56f3be36c77e4fe4b523df209a6824c6 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=d22b5161b2075656417d56f41a74f3dd 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=3dd4bdd6850ffcc96c6c45fcb0acd6eb 2500w" />

完整的技能目录结构可能如下：

```
pdf/
├── SKILL.md              # Main instructions (loaded when triggered)
├── FORMS.md              # Form-filling guide (loaded as needed)
├── reference.md          # API reference (loaded as needed)
├── examples.md           # Usage examples (loaded as needed)
└── scripts/
    ├── analyze_form.py   # Utility script (executed, not loaded)
    ├── fill_form.py      # Form filling script
    └── validate.py       # Validation script
```

#### 模式 1：带引用的高层指南

```markdown  theme={null}
---
name: PDF Processing
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

# PDF Processing

## Quick start

Extract text with pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Advanced features

**Form filling**: See [FORMS.md](FORMS.md) for complete guide
**API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
**Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
```

Claude 仅在需要时加载 FORMS.md、REFERENCE.md 或 EXAMPLES.md。

#### 模式 2：按领域组织

对于多领域技能，按领域组织内容，避免加载无关上下文。当用户询问销售指标时，Claude 只需读取销售相关 schema，无需读取财务或营销数据。这能降低 token 使用，保持上下文聚焦。

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

```markdown SKILL.md theme={null}
# BigQuery Data Analysis

## Available datasets

**Finance**: Revenue, ARR, billing → See [reference/finance.md](reference/finance.md)
**Sales**: Opportunities, pipeline, accounts → See [reference/sales.md](reference/sales.md)
**Product**: API usage, features, adoption → See [reference/product.md](reference/product.md)
**Marketing**: Campaigns, attribution, email → See [reference/marketing.md](reference/marketing.md)

## Quick search

Find specific metrics using grep:

```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
grep -i "api usage" reference/product.md
```
```

#### 模式 3：条件性细节

展示基础内容，链接到高级内容：

```markdown  theme={null}
# DOCX Processing

## Creating documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

仅当用户需要那些功能时，Claude 才读取 REDLINING.md 或 OOXML.md。

### 避免深层嵌套引用

当文件被其他引用文件引用时，Claude 可能会部分读取。遇到嵌套引用时，Claude 可能使用 `head -100` 等命令预览内容，而非读取整个文件，导致信息不完整。

**保持引用距 SKILL.md 仅一层深度**。所有引用文件应直接从 SKILL.md 链接，确保 Claude 在需要时读取完整文件。

**坏例子：层级过深**：

```markdown  theme={null}
# SKILL.md
See [advanced.md](advanced.md)...

# advanced.md
See [details.md](details.md)...

# details.md
Here's the actual information...
```

**好例子：仅一层深度**：

```markdown  theme={null}
# SKILL.md

**Basic usage**: [instructions in SKILL.md]
**Advanced features**: See [advanced.md](advanced.md)
**API reference**: See [reference.md](reference.md)
**Examples**: See [examples.md](examples.md)
```

### 为较长引用文件添加目录

对于超过 100 行的引用文件，在顶部添加目录。这能确保 Claude 即使预览部分内容，也能看到可用信息的完整范围。

**示例**：

```markdown  theme={null}
# API Reference

## Contents
- Authentication and setup
- Core methods (create, read, update, delete)
- Advanced features (batch operations, webhooks)
- Error handling patterns
- Code examples

## Authentication and setup
...

## Core methods
...
```

Claude 随后可以读取完整文件，或根据需要跳转到特定章节。

关于这种基于文件系统的架构如何实现渐进式披露，请查看下文高级章节中的 [运行时环境](#runtime-environment) 部分。

## 工作流与反馈循环

### 用工作流处理复杂任务

将复杂操作拆分为清晰、顺序的步骤。对于特别复杂的工作流，提供检查清单，Claude 可以复制到回复中，并随着进度勾选。

**示例 1：研究综合工作流**（无代码技能）：

```markdown  theme={null}
## Research synthesis workflow

Copy this checklist and track your progress:

```
Research Progress:
- [ ] Step 1: Read all source documents
- [ ] Step 2: Identify key themes
- [ ] Step 3: Cross-reference claims
- [ ] Step 4: Create structured summary
- [ ] Step 5: Verify citations
```

**Step 1: Read all source documents**

Review each document in the `sources/` directory. Note the main arguments and supporting evidence.

**Step 2: Identify key themes**

Look for patterns across sources. What themes appear repeatedly? Where do sources agree or disagree?

**Step 3: Cross-reference claims**

For each major claim, verify it appears in the source material. Note which source supports each point.

**Step 4: Create structured summary**

Organize findings by theme. Include:
- Main claim
- Supporting evidence from sources
- Conflicting viewpoints (if any)

**Step 5: Verify citations**

Check that every claim references the correct source document. If citations are incomplete, return to Step 3.
```

此示例展示了工作流如何应用于不需要代码的任务。检查清单模式适用于任何复杂的多步骤流程。

**示例 2：PDF 表单填写工作流**（有代码技能）：

```markdown  theme={null}
## PDF form filling workflow

Copy this checklist and check off items as you complete them:

```
Task Progress:
- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```

**Step 1: Analyze the form**

Run: `python scripts/analyze_form.py input.pdf`

This extracts form fields and their locations, saving to `fields.json`.

**Step 2: Create field mapping**

Edit `fields.json` to add values for each field.

**Step 3: Validate mapping**

Run: `python scripts/validate_fields.py fields.json`

Fix any validation errors before continuing.

**Step 4: Fill the form**

Run: `python scripts/fill_form.py input.pdf fields.json output.pdf`

**Step 5: Verify output**

Run: `python scripts/verify_output.py output.pdf`

If verification fails, return to Step 2.
```

清晰的步骤防止 Claude 跳过关键验证。检查清单帮助 Claude 和你跟踪多步骤工作流的进度。

### 实现反馈循环

**常见模式**：运行验证器 → 修复错误 → 重复

此模式能大幅提升输出质量。

**示例 1：风格指南合规**（无代码技能）：

```markdown  theme={null}
## Content review process

1. Draft your content following the guidelines in STYLE_GUIDE.md
2. Review against the checklist:
   - Check terminology consistency
   - Verify examples follow the standard format
   - Confirm all required sections are present
3. If issues found:
   - Note each issue with specific section reference
   - Revise the content
   - Review the checklist again
4. Only proceed when all requirements are met
5. Finalize and save the document
```

这展示了使用参考文档而非脚本的验证循环模式。“验证器”是 STYLE_GUIDE.md，Claude 通过阅读和比对执行检查。

**示例 2：文档编辑流程**（有代码技能）：

```markdown  theme={null}
## Document editing process

1. Make your edits to `word/document.xml`
2. **Validate immediately**: `python ooxml/scripts/validate.py unpacked_dir/`
3. If validation fails:
   - Review the error message carefully
   - Fix the issues in the XML
   - Run validation again
4. **Only proceed when validation passes**
5. Rebuild: `python ooxml/scripts/pack.py unpacked_dir/ output.docx`
6. Test the output document
```

验证循环能尽早捕获错误。

## 内容指南

### 避免时间敏感信息

不要包含会过时的信息：

**坏例子：时间敏感**（会过时）：

```markdown  theme={null}
If you're doing this before August 2025, use the old API.
After August 2025, use the new API.
```

**好例子**（使用“旧模式”章节）：

```markdown  theme={null}
## Current method

Use the v2 API endpoint: `api.example.com/v2/messages`

## Old patterns

<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>

The v1 API used: `api.example.com/v1/messages`

This endpoint is no longer supported.
</details>
```

“旧模式”章节提供历史背景，不会让主内容杂乱。

### 使用一致术语

选择一个术语，在整个技能中统一使用：

**好——一致**：
* 始终用“API 端点”
* 始终用“字段”
* 始终用“提取”

**坏——不一致**：
* 混用“API 端点”、“URL”、“API 路由”、“路径”
* 混用“字段”、“框”、“元素”、“控件”
* 混用“提取”、“拉取”、“获取”、“检索”

一致性帮助 Claude 理解并遵循指令。

## 常见模式

### 模板模式

为输出格式提供模板。根据需求匹配严格程度。

**严格需求**（如 API 响应或数据格式）：

```markdown  theme={null}
## Report structure

ALWAYS use this exact template structure:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview of key findings]

## Key findings
- Finding 1 with supporting data
- Finding 2 with supporting data
- Finding 3 with supporting data

## Recommendations
1. Specific actionable recommendation
2. Specific actionable recommendation
```
```

**灵活指导**（需要适配时）：

```markdown  theme={null}
## Report structure

Here is a sensible default format, but use your best judgment based on the analysis:

```markdown
# [Analysis Title]

## Executive summary
[Overview]

## Key findings
[Adapt sections based on what you discover]

## Recommendations
[Tailor to the specific context]
```

Adjust sections as needed for the specific analysis type.
```

### 示例模式

对于输出质量依赖示例的技能，提供输入/输出对，就像常规提示词一样：

```markdown  theme={null}
## Commit message format

Generate commit messages following these examples:

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**Example 2:**
Input: Fixed bug where dates displayed incorrectly in reports
Output:
```
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
```

**Example 3:**
Input: Updated dependencies and refactored error handling
Output:
```
chore: update dependencies and refactor error handling

- Upgrade lodash to 4.17.21
- Standardize error response format across endpoints
```

Follow this style: type(scope): brief description, then detailed explanation.
```

示例比单纯描述更能帮助 Claude 理解期望的风格和细节程度。

### 条件工作流模式

引导 Claude 通过决策点：

```markdown  theme={null}
## Document modification workflow

1. Determine the modification type:

   **Creating new content?** → Follow "Creation workflow" below
   **Editing existing content?** → Follow "Editing workflow" below

2. Creation workflow:
   - Use docx-js library
   - Build document from scratch
   - Export to .docx format

3. Editing workflow:
   - Unpack existing document
   - Modify XML directly
   - Validate after each change
   - Repack when complete
```

<Tip>
  If workflows become large or complicated with many steps, consider pushing them into separate files and tell Claude to read the appropriate file based on the task at hand.
</Tip>

## 评估与迭代

### 先构建评估

**在编写大量文档前先创建评估。** 这能确保你的技能解决真实问题，而非记录想象中的问题。

**评估驱动开发：**
1. **识别差距**：在不使用技能的情况下，让 Claude 处理代表性任务。记录具体的失败或缺失上下文
2. **创建评估**：构建三个测试这些差距的场景
3. **建立基线**：测量不使用技能时 Claude 的表现
4. **编写最小化指令**：仅创建足够解决差距并通过评估的内容
5. **迭代**：执行评估，与基线对比，优化内容

这种方法确保你解决的是实际问题，而非预判可能永远不会出现的需求。

**评估结构**：
```json  theme={null}
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate PDF processing library or command-line tool",
    "Extracts text content from all pages in the document without missing any pages",
    "Saves the extracted text to a file named output.txt in a clear, readable format"
  ]
}
```

<Note>
  This example demonstrates a data-driven evaluation with a simple testing rubric. We do not currently provide a built-in way to run these evaluations. Users can create their own evaluation system. Evaluations are your source of truth for measuring Skill effectiveness.
</Note>

### 与 Claude 迭代开发技能

最有效的技能开发过程需要 Claude 本身参与。与一个 Claude 实例（“Claude A”）合作，创建供其他实例（“Claude B”）使用的技能。Claude A 帮你设计和优化指令，Claude B 在真实任务中测试它们。这之所以有效，是因为 Claude 模型既懂如何编写有效的代理指令，也知道代理需要什么信息。

**创建新技能：**
1. **不使用技能完成任务**：用常规提示词和 Claude A 一起解决问题。过程中你会自然提供上下文、解释偏好、分享流程知识。注意你重复提供的信息。
2. **识别可复用模式**：完成任务后，找出你提供的、对未来类似任务有用的上下文。**示例**：如果你做了 BigQuery 分析，可能提供了表名、字段定义、过滤规则（如“始终排除测试账户”）和常用查询模式。
3. **让 Claude A 创建技能**： “Create a Skill that captures this BigQuery analysis pattern we just used. Include the table schemas, naming conventions, and the rule about filtering test accounts.”
   <Tip>
     Claude 模型原生理解技能格式和结构。你不需要特殊系统提示词或“编写技能”技能来让 Claude 帮忙创建技能。直接让 Claude 创建技能，它就会生成结构正确的 SKILL.md 内容，包含合适的前置元数据和正文。
   </Tip>
4. **检查简洁性**：确认 Claude A 没有添加不必要的解释。可以问：“删掉关于胜率含义的解释——Claude 已经知道这个了。”
5. **优化信息架构**：让 Claude A 更有效地组织内容。例如：“整理一下，把表结构放到单独的引用文件里。我们之后可能会加更多表。”
6. **在类似任务上测试**：在相关用例上，用加载了技能的 Claude B（新实例）测试技能。观察 Claude B 是否能找到正确信息、正确应用规则、成功处理任务。
7. **根据观察迭代**：如果 Claude B 遇到困难或遗漏内容，带着具体问题回到 Claude A：“When Claude used this Skill, it forgot to filter by date for Q4. Should we add a section about date filtering patterns?”

**迭代现有技能：**
改进技能时，同样遵循分层模式。你在以下角色间切换：
* **与 Claude A 合作**（帮助优化技能的专家）
* **用 Claude B 测试**（使用技能执行真实工作的代理）
* **观察 Claude B 的行为**，并将见解反馈给 Claude A

1. **在真实工作流中使用技能**：给 Claude B（加载了技能）真实任务，而非测试场景
2. **观察 Claude B 的行为**：记录它遇到困难、成功或做出意外选择的地方。**示例观察**：“当我让 Claude B 做区域销售报告时，它写了查询但忘了过滤测试账户，尽管技能里提到了这条规则。”
3. **回到 Claude A 进行改进**：分享当前的 SKILL.md，描述你的观察。可以问：“我注意到 Claude B 做区域报告时忘了过滤测试账户。技能里提到了过滤，但可能不够突出？”
4. **审查 Claude A 的建议**：Claude A 可能建议重新组织让规则更突出，使用更强的语气如“必须过滤”而非“始终过滤”，或重构工作流章节。
5. **应用并测试更改**：用 Claude A 的优化更新技能，然后用类似请求再次用 Claude B 测试
6. **根据使用重复流程**：遇到新场景时，继续这个观察-优化-测试循环。每次迭代都基于真实代理行为优化技能，而非假设。

**收集团队反馈：**
1. 与队友分享技能，观察他们的使用情况
2. 询问：技能是否在预期时激活？指令是否清晰？缺少什么？
3. 整合反馈，解决你自己使用模式中的盲点

**为什么这种方法有效**：Claude A 理解代理需求，你提供领域专业知识，Claude B 通过真实使用暴露差距，迭代优化基于观察到的行为而非假设来改进技能。

### 观察 Claude 如何导航技能

迭代技能时，注意 Claude 实际如何使用它们。观察以下几点：
* **意外的探索路径**：Claude 是否按你没预料到的顺序读取文件？这可能说明你的结构不如想象中直观
* **遗漏的关联**：Claude 是否没遵循对重要文件的引用？你的链接可能需要更明确或更突出
* **过度依赖某些章节**：如果 Claude 反复读取同一个文件，考虑是否该把内容放到主 SKILL.md 里
* **被忽略的内容**：如果 Claude 从不访问某个打包文件，可能是它不必要，或在主指令中信号太弱

基于这些观察而非假设迭代。技能元数据中的 `name` 和 `description` 尤其关键。Claude 用它们决定是否触发技能来响应当前任务。确保它们清晰描述技能功能和适用场景。

## 要避免的反模式

### 避免 Windows 风格路径

即使在 Windows 上，文件路径始终使用正斜杠：
* ✓ **好**：`scripts/helper.py`、`reference/guide.md`
* ✗ **避免**：`scripts\helper.py`、`reference\guide.md`

Unix 风格路径跨平台通用，而 Windows 风格路径在 Unix 系统上会报错。

### 避免提供过多选项

除非必要，否则不要展示多种方法：

```markdown  theme={null}
**Bad example: Too many choices** (confusing):
"You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or..."

**Good example: Provide a default** (with escape hatch):
"Use pdfplumber for text extraction:
```python
import pdfplumber
```

For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."
```

## 高级：带可执行代码的技能

以下章节聚焦包含可执行脚本的技能。如果你的技能仅使用 Markdown 指令，跳转到 [有效技能检查清单](#checklist-for-effective-skills)。

### 解决问题，而非甩锅

为技能编写脚本时，处理错误情况，而非甩给 Claude。

**好例子：显式处理错误**：

```python  theme={null}
def process_file(path):
    """Process a file, creating it if it doesn't exist."""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        # Create file with default content instead of failing
        print(f"File {path} not found, creating default")
        with open(path, 'w') as f:
            f.write('')
        return ''
    except PermissionError:
        # Provide alternative instead of failing
        print(f"Cannot access {path}, using default")
        return ''
```

**坏例子：甩给 Claude**：

```python  theme={null}
def process_file(path):
    # Just fail and let Claude figure it out
    return open(path).read()
```

配置参数也应说明理由并记录，避免“玄学常量”（Ousterhout 定律）。如果你不知道正确值，Claude 又如何确定？

**好例子：自文档化**：

```python  theme={null}
# HTTP requests typically complete within 30 seconds
# Longer timeout accounts for slow connections
REQUEST_TIMEOUT = 30

# Three retries balances reliability vs speed
# Most intermittent failures resolve by the second retry
MAX_RETRIES = 3
```

**坏例子：魔法数字**：

```python  theme={null}
TIMEOUT = 47  # Why 47?
RETRIES = 5   # Why 5?
```

### 提供实用脚本

即使 Claude 能编写脚本，预置脚本也有优势：

**实用脚本的好处**：
* 比生成的代码更可靠
* 节省 token（无需将代码加入上下文）
* 节省时间（无需生成代码）
* 确保跨使用场景的一致性

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=4bbc45f2c2e0bee9f2f0d5da669bad00" alt="Bundling executable scripts alongside instruction files" data-og-width="2048" width="2048" data-og-height="1154" height="1154" data-path="images/agent-skills-executable-scripts.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=9a04e6535a8467bfeea492e517de389f 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=e49333ad90141af17c0d7651cca7216b 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=954265a5df52223d6572b6214168c428 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=2ff7a2d8f2a83ee8af132b29f10150fd 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=48ab96245e04077f4d15e9170e081cfb 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0301a6c8b3ee879497cc5b5483177c90 2500w" />

上图展示了可执行脚本如何与指令文件配合工作。指令文件（forms.md）引用脚本，Claude 可以执行它，无需将脚本内容加载到上下文。

**重要区别**：在指令中明确 Claude 应该：
* **执行脚本**（最常见）：“运行 `analyze_form.py` 提取字段”
* **作为参考读取**（复杂逻辑）：“查看 `analyze_form.py` 了解字段提取算法”

大多数实用脚本优先选择执行，因为更可靠高效。脚本执行的工作原理详见下文 [运行时环境](#runtime-environment) 章节。

**示例**：

```markdown  theme={null}
## Utility scripts

**analyze_form.py**: Extract all form fields from PDF

```bash
python scripts/analyze_form.py input.pdf > fields.json
```

Output format:
```json
{
  "field_name": {"type": "text", "x": 100, "y": 200},
  "signature": {"type": "sig", "x": 150, "y": 500}
}
```

**validate_boxes.py**: Check for overlapping bounding boxes

```bash
python scripts/validate_boxes.py fields.json
# Returns: "OK" or lists conflicts
```

**fill_form.py**: Apply field values to PDF

```bash
python scripts/fill_form.py input.pdf fields.json output.pdf
```
```

### 使用视觉分析

当输入可以渲染为图像时，让 Claude 分析它们：

```markdown  theme={null}
## Form layout analysis

1. Convert PDF to images:
   ```bash
   python scripts/pdf_to_images.py form.pdf
   ```

2. Analyze each page image to identify form fields
3. Claude can see field locations and types visually
```

<Note>
  In this example, you'd need to write the `pdf_to_images.py` script.
</Note>

Claude 的视觉能力有助于理解布局和结构。

### 创建可验证的中间输出

当 Claude 执行复杂的开放式任务时，可能会出错。“计划-验证-执行”模式能尽早捕获错误：让 Claude 先用结构化格式创建计划，再用脚本验证计划，最后执行。

**示例**：假设让 Claude 根据电子表格更新 PDF 中的 50 个表单字段。没有验证的话，Claude 可能引用不存在的字段、创建冲突值、遗漏必填字段，或应用错误的更新。

**解决方案**：使用上述工作流模式（PDF 表单填写），但添加中间文件 `changes.json`，在应用更改前验证。工作流变为：分析 → **创建计划文件** → **验证计划** → 执行 → 验证。

**此模式有效的原因：**
* **尽早捕获错误**：验证在应用更改前发现问题
* **机器可验证**：脚本提供客观验证
* **可逆规划**：Claude 可以迭代计划，无需修改原始文件
* **清晰调试**：错误消息指向具体问题

**适用场景**：批量操作、破坏性更改、复杂验证规则、高风险操作。

**实现建议**：让验证脚本输出详细错误信息，如“未找到字段 `signature_date`。可用字段：customer_name, order_total, signature_date_signed”，帮助 Claude 修复问题。

### 包依赖

技能在代码执行环境中运行，有平台特定限制：
* **claude.ai**：可以从 npm 和 PyPI 安装包，从 GitHub 仓库拉取
* **Anthropic API**：无网络访问，无运行时包安装能力

在 SKILL.md 中列出所需包，并确认它们在 [代码执行工具文档](/en/docs/agents-and-tools/tool-use/code-execution-tool) 中可用。

### 运行时环境

技能在代码执行环境中运行，拥有文件系统访问、bash 命令和代码执行能力。关于此架构的概念解释，请查看概述中的 [技能架构](/en/docs/agents-and-tools/agent-skills/overview#the-skills-architecture)。

**这对编写的影响：**

**Claude 如何访问技能：**
1. **元数据预加载**：启动时，所有技能的 YAML 前置元数据中的名称和描述被加载到系统提示词中
2. **文件按需读取**：需要时，Claude 使用 bash 读取工具访问文件系统中的 SKILL.md 和其他文件
3. **脚本高效执行**：实用脚本可以通过 bash 执行，无需将完整内容加载到上下文。仅脚本输出消耗 token
4. **大文件无上下文惩罚**：引用文件、数据或文档在实际读取前不消耗上下文 token

* **文件路径很重要**：Claude 像文件系统一样导航技能目录。使用正斜杠（`reference/guide.md`），不用反斜杠
* **文件命名要具描述性**：用表明内容的名称：`form_validation_rules.md`，而非 `doc2.md`
* **为可发现性组织**：按领域或功能组织目录
  * 好：`reference/finance.md`、`reference/sales.md`
  * 坏：`docs/file1.md`、`docs/file2.md`
* **打包全面资源**：包含完整 API 文档、大量示例、大型数据集；访问前无上下文惩罚
* **确定性操作优先用脚本**：编写 `validate_form.py`，而非让 Claude 生成验证代码
* **明确执行意图**：
  * “运行 `analyze_form.py` 提取字段”（执行）
  * “查看 `analyze_form.py` 了解提取算法”（作为参考读取）
* **测试文件访问模式**：用真实请求验证 Claude 能导航你的目录结构

**示例：**

```
bigquery-skill/
├── SKILL.md (overview, points to reference files)
└── reference/
    ├── finance.md (revenue metrics)
    ├── sales.md (pipeline data)
    └── product.md (usage analytics)
```

当用户询问收入时，Claude 读取 SKILL.md，看到对 `reference/finance.md` 的引用，然后调用 bash 仅读取该文件。sales.md 和 product.md 文件保留在文件系统中，在需要前消耗零上下文 token。这种基于文件系统的模型实现了渐进式披露。Claude 可以导航并选择性加载每个任务所需的内容。

技术架构的完整详情请查看技能概述中的 [技能工作原理](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

### MCP 工具引用

如果技能使用 MCP（模型上下文协议）工具，始终使用完全限定的工具名称，避免“未找到工具”错误。

**格式**：`服务器名:工具名`

**示例**：

```markdown  theme={null}
Use the BigQuery:bigquery_schema tool to retrieve table schemas.
Use the GitHub:create_issue tool to create issues.
```

其中：
* `BigQuery` 和 `GitHub` 是 MCP 服务器名称
* `bigquery_schema` 和 `create_issue` 是服务器中的工具名称

没有服务器前缀，Claude 可能无法定位工具，尤其当有多个 MCP 服务器时。

### 避免假设工具已安装

不要假设包已可用：

```markdown  theme={null}
**Bad example: Assumes installation**:
"Use the pdf library to process the file."

**Good example: Explicit about dependencies**:
"Install required package: `pip install pypdf`

Then use it:
```python
from pypdf import PdfReader
reader = PdfReader("file.pdf")
```"
```

## 技术说明

### YAML 前置元数据要求

SKILL.md 的前置元数据需要 `name`（最多 64 字符）和 `description`（最多 1024 字符）字段。完整结构详情请查看 [技能概述](/en/docs/agents-and-tools/agent-skills/overview#skill-structure)。

### Token 预算

保持 SKILL.md 正文在 500 行以内，以获得最佳性能。如果内容超过此限制，使用前文所述的渐进式披露模式拆分到单独文件。架构详情请查看 [技能概述](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)。

## 有效技能检查清单

分享技能前，确认：

### 核心质量
* [ ] 描述具体，包含关键术语
* [ ] 描述同时包含技能功能和适用场景
* [ ] SKILL.md 正文在 500 行以内
* [ ] 额外细节放在单独文件（如需要）
* [ ] 无时间敏感信息（或放在“旧模式”章节）
* [ ] 全文术语一致
* [ ] 示例具体，非抽象
* [ ] 文件引用仅一层深度
* [ ] 合理使用渐进式披露
* [ ] 工作流步骤清晰

### 代码与脚本
* [ ] 脚本解决问题，而非甩给 Claude
* [ ] 错误处理显式且有用
* [ ] 无“玄学常量”（所有值都有理由）
* [ ] 所需包在指令中列出，且确认可用
* [ ] 脚本有清晰文档
* [ ] 无 Windows 风格路径（全用正斜杠）
* [ ] 关键操作有验证/确认步骤
* [ ] 质量关键任务包含反馈循环

### 测试
* [ ] 至少创建三个评估
* [ ] 用 Haiku、Sonnet 和 Opus 测试过
* [ ] 用真实使用场景测试过
* [ ] 整合了团队反馈（如适用）

## 后续步骤

<CardGroup cols={2}>
  <Card title="开始使用代理技能" icon="rocket" href="/en/docs/agents-and-tools/agent-skills/quickstart">
    创建你的第一个技能
  </Card>

  <Card title="在 Claude Code 中使用技能" icon="terminal" href="/en/docs/claude-code/skills">
    在 Claude Code 中创建和管理技能
  </Card>

  <Card title="通过 API 使用技能" icon="code" href="/en/api/skills-guide">
    以编程方式上传和使用技能
  </Card>
</CardGroup>
