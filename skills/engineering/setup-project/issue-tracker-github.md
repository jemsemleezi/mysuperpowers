# 问题跟踪器：GitHub

本仓库的问题（Issues）和产品需求文档（PRDs）均使用 GitHub Issues 管理。所有操作请使用 `gh` 命令行工具。

## 操作规范

- **创建问题**：`gh issue create --title "..." --body "..."`。多行内容请使用 heredoc 语法。
- **查看问题**：`gh issue view <number> --comments`，可通过 `jq` 过滤评论，同时获取标签信息。
- **列出问题**：`gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`，可搭配 `--label` 和 `--state` 参数按需过滤。
- **评论问题**：`gh issue comment <number> --body "..."`
- **添加/移除标签**：`gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **关闭问题**：`gh issue close <number> --comment "..."`

仓库信息可通过 `git remote -v` 自动推断，`gh` 工具在克隆仓库内运行时会自动识别。

## 当技能要求“发布到问题跟踪器”时

创建一个 GitHub Issue。

## 当技能要求“获取相关工单”时

运行 `gh issue view <number> --comments`。

---

*本技能源自 Matt Pocock Skills，已适配 MySuperPowers。*
