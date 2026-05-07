# ADR 1：合并 Superpowers 与 Matt Pocock 技能

**日期：** 2026-05-06

## 状态

已接受

## 背景

AI 编码代理领域曾存在两大技能生态：

1. **Superpowers**（由 Obra 开发）—— 聚焦代理流程编排：头脑风暴、编写计划、执行计划、子代理驱动开发、代码审查、验证、git worktree，以及多平台宿主支持（Claude Code、Codex、Cursor、OpenCode、Gemini CLI）。

2. **Matt Pocock Skills**（由 Matt Pocock 开发）—— 聚焦工程方法论：领域语言（CONTEXT.md、ADR）、需求质询、TDD、调试、问题管理（PRD → issues → triage）、架构改进与原型设计。

两者在 TDD、调试、技能编写领域存在重叠，各有优势。用户不得不在流程（Superpowers）和方法论（Matt Pocock）之间二选一，或同时维护两套系统。

## 决策

将两套项目合并为统一的 **MySuperPowers** 项目，要求：

1. 保留两个来源的所有独有技能
2. 合并重叠技能（TDD、调试、技能编写）的版本
3. 保留 Superpowers 的多平台基础设施（钩子、插件配置、测试框架）
4. 保留 Matt Pocock 的模板系统与按仓库配置生成能力
5. 按 bucket 结构组织技能：`engineering/`、`productivity/`、`misc/`

## 影响

**积极方面：**
- 单一技能来源同时覆盖流程编排与工程方法论
- 用户可获得完整工作流：领域语言 → 头脑风暴 → 计划 → 执行 → TDD → 审查 → 验证
- 无需在系统之间做选择

**消极方面：**
- 技能总数增加可能提升上下文占用
- 部分技能引用需要将前缀从 `superpowers:` 更新为 `mysuperpowers:`
- 归属关系复杂 —— 需要同时标注两个原始项目

## 归属说明

- **Superpowers** 由 Obra 开发 — https://github.com/obra/superpowers
- **Matt Pocock Skills** 由 Matt Pocock 开发 — https://github.com/mattpocock/skills
