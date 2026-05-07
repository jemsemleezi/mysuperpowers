# 问题跟踪器：GitLab

本仓库的问题（Issues）和产品需求文档（PRDs）均使用 GitLab Issues 管理。所有操作请使用 [`glab`](https://gitlab.com/gitlab-org/cli) 命令行工具。

## 操作规范

- **创建问题**：`glab issue create --title "..." --description "..."`。多行描述请使用 heredoc 语法，也可传 `--description -` 打开编辑器。
- **查看问题**：`glab issue view <number> --comments`。添加 `-F json` 可获取机器可读的输出。
- **列出问题**：`glab issue list --state opened -F json`，可搭配 `--label` 参数过滤。注意 GitLab 的状态值用 `opened` 而非 `open`。
- **评论问题**：`glab issue note <number> --message "..."`。GitLab 将评论称为 "notes"。
- **添加/移除标签**：`glab issue update <number> --label "..."` / `--unlabel "..."`。多个标签可用逗号分隔，或重复添加该参数。
- **关闭问题**：`glab issue close <number>`。`glab issue close` 不支持添加关闭评论，请先通过 `glab issue note <number> --message "..."` 发布说明，再执行关闭。
- **合并请求**：GitLab 将 PR 称为“合并请求（merge requests）”。可使用 `glab mr create`、`glab mr view`、`glab mr note` 等命令，格式与 `gh pr ...` 类似，仅将 `pr` 替换为 `mr`，`comment`/`--body` 替换为 `note`/`--message`。

仓库信息可通过 `git remote -v` 自动推断，`glab` 工具在克隆仓库内运行时会自动识别。

## 当技能要求“发布到问题跟踪器”时

创建一个 GitLab Issue。

## 当技能要求“获取相关工单”时

运行 `glab issue view <number> --comments`。

---

*本技能源自 Matt Pocock Skills，已适配 MySuperPowers。*
