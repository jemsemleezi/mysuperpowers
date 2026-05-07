# MySuperPowers

面向 AI 编码代理的合并式技能系统，结合了 Superpowers（流程编排）和 Matt Pocock Skills（工程方法论）。

## 术语

**Skill**: 一份 `SKILL.md` 文档，为代理在特定场景下提供执行指令。技能位于 `skills/` 下，并按 bucket 组织。
_避免使用_: command, plugin, tool

**Bucket**: 技能的目录分类 - `engineering/`（编码工作）、`productivity/`（工作流）、`misc/`（很少使用）。

**Engineering skill**: 用于编码工作的技能（brainstorming、TDD、调试、规划、领域语言、问题管理、架构改进）。

**Productivity skill**: 用于非编码工作流的技能（grilling、压缩式沟通、编写技能、代码审查、完成分支）。

**The Flow**: 规范化工作流：brainstorming → writing-plans → executing-plans → verification-before-completion。开始前可先用 grill-with-docs/grill-me 澄清需求。

**CONTEXT.md**: 代理用于理解项目特定术语的项目领域语言文档，由 grill-with-docs 创建或更新。

**ADR**: 存放在 `docs/adr/` 中的架构决策记录。用于记录那些难以回退的决策及其权衡。

**Issue tracker**: 问题存放的位置 - GitHub Issues、GitLab Issues 或本地 markdown 文件。供 to-prd、to-issues 和 triage 技能使用。

**Tracer bullet**: 在 TDD 中，先写一个测试，再写它的实现，然后再进入下一个测试（垂直切片），而不是先写完所有测试（水平切片）。

**Harness**: 运行代理的 IDE/CLI 环境（Claude Code、Codex CLI、Cursor、OpenCode、Gemini CLI、GitHub Copilot CLI）。

**Auto-pilot Mode**: 由“auto”、“automate”、“build this”或高层需求触发的全自动模式。代理会在没有用户介入的情况下端到端遵循 The Flow。详情见 `docs/using-superpowers.md`。

**Manual-first Mode**: 由“I'll write it”、“guide me”、“help me learn”触发的学习/控制模式。代理扮演资深导师的角色 - 只建议技能，除非明确要求，否则不会写代码或启动子代理。详情见 `docs/using-superpowers.md`。

**Safety Boundaries**: 自动模式下用于防止不可逆操作的护栏 - 分支隔离（不向 main/master 写入）、禁止自动部署、破坏性操作需要人工确认、PR 和合并必须暂停等待人工审查。详情见 `docs/using-superpowers.md`。

## 关系
- 一个 **Skill** 只属于一个 **Bucket**
- **The Flow** 会按顺序消耗多个 **Skills**
- **grill-with-docs** 会生成并更新 **CONTEXT.md** 和 **ADRs**
- **to-prd** → **to-issues** → **triage** 构成问题管理流水线
- **brainstorming** → **writing-plans** → **executing-plans** 构成实现流水线
