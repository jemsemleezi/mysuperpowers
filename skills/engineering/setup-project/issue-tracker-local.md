# 问题追踪器：本地 Markdown

本仓库的问题和需求文档（PRD）以 Markdown 文件形式存放在 `.scratch/` 目录下。

## 约定

- 每个功能对应一个目录：`.scratch/<feature-slug>/`
- 需求文档（PRD）路径为 `.scratch/<feature-slug>/PRD.md`
- 实现问题文件为 `.scratch/<feature-slug>/issues/<NN>-<slug>.md`，编号从 `01` 开始
- 分类状态记录在每个问题文件顶部的 `Status:` 行中（角色字符串参见 `triage-labels.md`）
- 评论和对话历史追加到文件底部的 `## Comments` 标题下

## 当技能要求“发布到问题追踪器”时

在 `.scratch/<feature-slug>/` 目录下创建新文件（如需请先创建目录）。

## 当技能要求“获取相关工单”时

读取引用路径下的文件。用户通常会直接提供路径或问题编号。

---

*本技能源自 Matt Pocock Skills，为 MySuperPowers 进行了适配。*
